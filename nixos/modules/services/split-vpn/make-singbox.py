import json
import sys
from urllib.parse import parse_qs, urlparse

OUT_PATH, DOMAINS_PATH, VLESS_URI_PATH = (
    sys.argv[1],
    sys.argv[2],
    sys.argv[3],
)

with open(DOMAINS_PATH) as f:
    data = json.load(f)

VPN_DOMAINS = data["vpn"]
DIRECT_DOMAINS = data["direct"]

with open(VLESS_URI_PATH) as f:
    uri = f.read().strip()

parsed = urlparse(uri)
params = {k: v[0] for k, v in parse_qs(parsed.query).items()}

uuid = parsed.username or ""
public_key = params.get("pbk", "")
if not uuid or not public_key:
    sys.exit("vless uri: missing uuid or pbk (fill vpn.vless-uri in secrets)")

flow = params.get("flow", "")

reality = {
    "enabled": True,
    "public_key": public_key,
}
if params.get("sid"):
    reality["short_id"] = params["sid"]

vless_outbound = {
    "type": "vless",
    "tag": "via-vpn",
    "server": parsed.hostname,
    "server_port": parsed.port or 443,
    "uuid": uuid,
    "tls": {
        "enabled": True,
        "server_name": params.get("sni", parsed.hostname),
        "alpn": [params["alpn"]] if params.get("alpn") else None,
        "utls": {
            "enabled": True,
            "fingerprint": params.get("fp", "chrome"),
        },
        "reality": reality,
    },
}
if flow:
    vless_outbound["flow"] = flow
if params.get("type") == "grpc":
    vless_outbound["transport"] = {
        "type": "grpc",
        "service_name": params.get("serviceName", ""),
    }

config = {
    "log": {"level": "info", "timestamp": True},
    "dns": {
        "strategy": "ipv4_only",
        "servers": [
            {
                "type": "https",
                "tag": "vpn-dns",
                "server": "9.9.9.9",
                "detour": "via-vpn",
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
        vless_outbound,
    ],
    "route": {
        "rules": [
            {"action": "sniff"},
            {"action": "hijack-dns", "protocol": "dns"},
            {"ip_is_private": True, "outbound": "direct"},
            {"domain_suffix": DIRECT_DOMAINS, "outbound": "direct"},
            {"rule_set": "antizapret", "outbound": "via-vpn"},
            {"domain_suffix": VPN_DOMAINS, "outbound": "via-vpn"},
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
