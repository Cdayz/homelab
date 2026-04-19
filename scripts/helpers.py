import subprocess
from pathlib import Path


def find_secret_dirs(root: Path) -> list[Path]:
    return sorted(p for p in root.rglob("secrets") if p.is_dir())


def encrypt_raw_secrets(root: Path) -> None:
    for secrets_dir in find_secret_dirs(root):
        raw_files = sorted(secrets_dir.glob("*.raw.yaml"))
        if not raw_files:
            continue

        for raw in raw_files:
            enc = raw.with_name(raw.name.removesuffix(".raw.yaml") + ".yaml")
            print(f"encrypting {raw} -> {enc}")
            with enc.open("w", encoding="utf-8") as out:
                subprocess.run(
                    [
                        "sops",
                        "encrypt",
                        "--input-type",
                        "yaml",
                        "--output-type",
                        "yaml",
                        str(raw),
                    ],
                    check=True,
                    stdout=out,
                    stderr=subprocess.PIPE,
                )


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
            with raw.open("w", encoding="utf-8") as out:
                subprocess.run(
                    [
                        "sops",
                        "decrypt",
                        "--input-type",
                        "yaml",
                        "--output-type",
                        "yaml",
                        str(enc),
                    ],
                    check=True,
                    stdout=out,
                )
