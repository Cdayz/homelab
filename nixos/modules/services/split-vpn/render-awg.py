import sys

SRC, DST = sys.argv[1], sys.argv[2]

with open(SRC) as f:
    lines = f.read().splitlines()

lines = [
    line
    for line in lines
    if not line.strip().startswith("DNS =")
    and not line.strip().lower().startswith("table =")
]

tunnel_v4 = next(
    part.strip().split(",")[0]
    for line in lines
    if line.strip().startswith("Address")
    for part in [line.split("=", 1)[1]]
    if "." in part
)

rule_up = f"ip rule add from {tunnel_v4} lookup 51820 priority 100"
rule_down = f"ip rule del from {tunnel_v4} lookup 51820 priority 100"

interface_extra = [
    "Table = off",
    "PostUp = ip route replace default dev awg0 table 51820; " + rule_up,
    "PreDown = " + rule_down + "; ip route flush table 51820",
]

out = []
for line in lines:
    if line.strip() == "[Peer]":
        out.extend(interface_extra)
    out.append(line)

with open(DST, "w") as f:
    f.write("\n".join(out) + "\n")
