import os
from pathlib import Path

from scripts.helpers import decrypt_tracked_secrets

cwd = Path(os.getcwd())

print(f"Decrypt all secrets inside {cwd}")

decrypt_tracked_secrets(cwd)
