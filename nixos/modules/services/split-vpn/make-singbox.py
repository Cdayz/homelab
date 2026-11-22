import json
import sys

OUT_PATH, DOMAINS_PATH = sys.argv[1], sys.argv[2]

RULESET_URL = (
    "https://github.com/savely-krasovsky/antizapret-sing-box"
    "/releases/latest/download/antizapret.srs"
)

# github всегда direct: иначе nix не может скачать фикс самого VPN,
# если туннель лежит (antizapret-список включает github CDN)
GITHUB_DOMAINS = [
    "github.com",
    "githubusercontent.com",
    "github.io",
    "githubassets.com",
    "ghcr.io",
]

with open(DOMAINS_PATH) as f:
    domains = json.load(f)

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
            {"domain_suffix": GITHUB_DOMAINS, "server": "direct-dns"},
            {"rule_set": "antizapret", "server": "vpn-dns"},
            {"domain_suffix": domains, "server": "vpn-dns"},
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
            {"domain_suffix": GITHUB_DOMAINS, "outbound": "direct"},
            {"rule_set": "antizapret", "outbound": "via-awg"},
            {"domain_suffix": domains, "outbound": "via-awg"},
        ],
        "rule_set": [
            {
                "type": "remote",
                "tag": "antizapret",
                "format": "binary",
                "url": RULESET_URL,
                "update_interval": "24h",
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
