import re
import shutil
import hashlib
from pathlib import Path

import yaml


class RenderError(RuntimeError):
    pass


def render_secret_yaml_to_file(src: Path, dst: Path) -> None:
    data = yaml.safe_load(src.read_text(encoding="utf-8"))

    if not isinstance(data, dict):
        raise RenderError(f"{src}: expected YAML mapping")

    content = data.get("content")
    if not isinstance(content, str):
        raise RenderError(f"{src}: expected string field 'content'")

    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(content, encoding="utf-8")
    dst.chmod(0o644)


def compute_deploy_id(src_dir: Path) -> str:
    hasher = hashlib.sha256()

    def update_with_file(path: Path) -> None:
        rel = path.relative_to(src_dir)
        hasher.update(rel.as_posix().encode("utf-8"))
        hasher.update(b"\0")
        hasher.update(path.read_bytes())
        hasher.update(b"\0")

    job_file = src_dir / "job.hcl"
    if job_file.is_file():
        update_with_file(job_file)

    configs_dir = src_dir / "configs"
    if configs_dir.is_dir():
        for path in sorted(p for p in configs_dir.rglob("*") if p.is_file()):
            update_with_file(path)

    secrets_dir = src_dir / "secrets"
    if secrets_dir.is_dir():
        for path in sorted(secrets_dir.glob("*.raw.yaml")):
            update_with_file(path)

    return hasher.hexdigest()


_VAR_RE = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}")


def substitute_env_vars(text: str, env: dict[str, str]) -> str:
    def repl(match: re.Match[str]) -> str:
        name = match.group(1)
        try:
            return env[name]
        except KeyError:
            print(f"missing template variable: {name}")
            return "${" + name + "}"

    return _VAR_RE.sub(repl, text)


def render_job_dir(
    repo_root: Path,
    job_name: str,
    remote_root: str = "/opt/nomad-jobs",
    deploy_id: str | None = None,
) -> Path:
    src_dir = repo_root / "nomad" / "jobs" / job_name
    out_dir = repo_root / "nomad" / "render" / job_name
    job_file = src_dir / "job.hcl"

    if not src_dir.is_dir():
        raise RenderError(f"job directory not found: {src_dir}")
    if not job_file.is_file():
        raise RenderError(f"job file not found: {job_file}")

    if deploy_id is None:
        deploy_id = compute_deploy_id(src_dir)

    if out_dir.exists():
        shutil.rmtree(out_dir)

    (out_dir / "configs").mkdir(parents=True, exist_ok=True)
    (out_dir / "secrets").mkdir(parents=True, exist_ok=True)

    configs_dir = src_dir / "configs"
    if configs_dir.is_dir():
        for item in configs_dir.iterdir():
            target = out_dir / "configs" / item.name
            if item.is_dir():
                shutil.copytree(item, target)
            else:
                shutil.copy2(item, target)

    secrets_dir = src_dir / "secrets"
    if secrets_dir.is_dir():
        raw_files = sorted(secrets_dir.glob("*.raw.yaml"))
        tracked_files = sorted(
            p for p in secrets_dir.glob("*.yaml") if not p.name.endswith(".raw.yaml")
        )
        if tracked_files and not raw_files:
            raise RenderError(f"no decrypted raw secrets found in {secrets_dir}")

        for raw in raw_files:
            name = raw.name.removesuffix(".raw.yaml")
            render_secret_yaml_to_file(raw, out_dir / "secrets" / name)

    env = {
        "JOB_NAME": job_name,
        "JOB_DEPLOY_ID": deploy_id,
        "JOB_REMOTE_DIR": f"{remote_root}/{job_name}",
        "JOB_REMOTE_CONFIGS_DIR": f"{remote_root}/{job_name}/configs",
        "JOB_REMOTE_SECRETS_DIR": f"{remote_root}/{job_name}/secrets",
    }

    rendered_job = substitute_env_vars(
        job_file.read_text(encoding="utf-8"),
        env,
    )
    (out_dir / "job.hcl").write_text(rendered_job, encoding="utf-8")

    return out_dir


if __name__ == "__main__":
    import os
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--job-name", action="store", dest="job_name", required=True)
    parser.add_argument(
        "--remote-jobs-dir",
        action="store",
        dest="remote_jobs_dir",
        default="/opt/nomad-jobs",
    )
    parser.add_argument(
        "--deploy-id",
        action="store",
        dest="deploy_id",
    )

    ns = parser.parse_args()

    root = Path(os.getcwd())

    render_job_dir(
        root,
        job_name=ns.job_name,
        remote_root=ns.remote_jobs_dir,
        deploy_id=ns.deploy_id,
    )
