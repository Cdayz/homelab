import subprocess
from pathlib import Path


def find_secret_dirs(root: Path) -> list[Path]:
    return sorted(p for p in root.rglob("secrets") if p.is_dir())


def decrypt_secret_file(path: Path) -> str:
    proc = subprocess.run(
        [
            "sops",
            "decrypt",
            "--input-type",
            "yaml",
            "--output-type",
            "yaml",
            str(path),
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return proc.stdout


def encrypt_secret_file(path: Path) -> str:
    proc = subprocess.run(
        [
            "sops",
            "encrypt",
            "--input-type",
            "yaml",
            "--output-type",
            "yaml",
            str(path),
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return proc.stdout


def encrypt_raw_secrets(root: Path) -> None:
    for secrets_dir in find_secret_dirs(root):
        raw_files = sorted(secrets_dir.glob("*.raw.yaml"))
        if not raw_files:
            continue

        for raw in raw_files:
            enc = raw.with_name(raw.name.removesuffix(".raw.yaml") + ".yaml")
            raw_content = raw.read_text(encoding="utf-8")

            if enc.exists():
                enc_plaintext = decrypt_secret_file(enc)
                if enc_plaintext == raw_content:
                    print(f"skipping unchanged {raw} -> {enc}")
                    continue

            print(f"encrypting {raw} -> {enc}")
            enc.write_text(encrypt_secret_file(raw), encoding="utf-8")


def decrypt_tracked_secrets(root: Path) -> None:
    for secrets_dir in find_secret_dirs(root):
        enc_files = sorted(
            p for p in secrets_dir.glob("*.yaml") if not p.name.endswith(".raw.yaml")
        )
        if not enc_files:
            continue

        for enc in enc_files:
            raw = enc.with_name(enc.name.removesuffix(".yaml") + ".raw.yaml")
            print(f"decrypting {enc} -> {raw}")
            raw.write_text(decrypt_secret_file(enc), encoding="utf-8")
