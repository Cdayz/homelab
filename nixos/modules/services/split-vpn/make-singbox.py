import json
import sys

OUT_PATH, DOMAINS_PATH = sys.argv[1], sys.argv[2]

with open(DOMAINS_PATH) as f:
    data = json.load(f)

VPN_DOMAINS = data["vpn"]
DIRECT_DOMAINS = data["direct"]

config = {
    "log": {"level": "info", "timestamp": True},
    "dns": {
        "strategy": "ipv4_only",
        "servers": [
            {
                "type": "https",
                "tag": "vpn-dns",
                "server": "9.9.9.9",
                "detour": "via-awg",
            },
            {
                "type": "udp",
                "tag": "direct-dns",
                "server": "192.168.1.1",
            },
        ],
        "rules": [
            {"domain_suffix": DIRECT_DOMAINS, "server": "direct-dns"},
            {"rule_set": "antizapret", "server": "vpn-dns"},
            {"domain_suffix": VPN_DOMAINS, "server": "vpn-dns"},
        ],
        "final": "direct-dns",
    },
    "inbounds": [
        {
            "type": "tun",
            "tag": "tun-in",
            "interface_name": "split-vpn",
            "address": ["172.19.0.1/30", "fdfe:dcba:9876::1/126"],
            "auto_route": True,
            "auto_redirect": True,
            "strict_route": True,
            "gso": False,
        }
    ],
    "outbounds": [
        {"type": "direct", "tag": "direct"},
        {"type": "direct", "tag": "via-awg", "bind_interface": "awg0"},
    ],
    "route": {
        "rules": [
            {"action": "sniff"},
            {"action": "hijack-dns", "protocol": "dns"},
            {"ip_is_private": True, "outbound": "direct"},
            {"domain_suffix": DIRECT_DOMAINS, "outbound": "direct"},
            {"rule_set": "antizapret", "outbound": "via-awg"},
            {"domain_suffix": VPN_DOMAINS, "outbound": "via-awg"},
        ],
        "rule_set": [
            {
                "type": "local",
                "tag": "antizapret",
                "format": "binary",
                "path": "/var/lib/split-vpn/antizapret.srs",
            }
        ],
        "final": "direct",
        "default_domain_resolver": {"server": "direct-dns"},
        "auto_detect_interface": True,
    },
    "experimental": {
        "cache_file": {"enabled": True, "path": "/var/lib/split-vpn/cache.db"},
    },
}

with open(OUT_PATH, "w") as f:
    json.dump(config, f, indent=2)
