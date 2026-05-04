import sys
import yaml
from pathlib import Path

fpath = Path(sys.argv[-1]).resolve()

obj = yaml.safe_load(fpath.read_text())
print(obj["content"])
