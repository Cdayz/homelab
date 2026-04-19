import os
from pathlib import Path

from scripts.helpers import encrypt_raw_secrets

cwd = Path(os.getcwd())

print(f"Encrypt all secrets inside {cwd}")

encrypt_raw_secrets(cwd)
