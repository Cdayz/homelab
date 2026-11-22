import ipaddress
import json
import re
import sys

DOMAINS_PATH, COMMUNITY_PATH, OUT_PATH = (
    sys.argv[1],
    sys.argv[2],
    sys.argv[3],
)

DOMAIN_RE = re.compile(
    r"^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$"
)

domains = set()
subnets = set()

with open(DOMAINS_PATH, encoding="utf-8", errors="ignore") as f:
    for line in f:
        value = line.strip().strip('"').lower().lstrip("*.")
        if DOMAIN_RE.match(value):
            domains.add(value)

with open(COMMUNITY_PATH, encoding="utf-8", errors="ignore") as f:
    for line in f:
        value = line.strip().strip('"')
        try:
            subnets.add(str(ipaddress.ip_network(value, strict=False)))
        except ValueError:
            pass

rules = []
if domains:
    rules.append({"domain_suffix": sorted(domains)})
if subnets:
    rules.append({"ip_cidr": sorted(subnets)})

ruleset = {"version": 3, "rules": rules}

with open(OUT_PATH, "w") as f:
    json.dump(ruleset, f)

print(f"antizapret: {len(domains)} domains, {len(subnets)} subnets")
