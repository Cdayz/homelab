#!/usr/bin/env bash
set -euo pipefail

WG_SRC="/run/wg-secrets/wg0.conf"
WG_TMP="/tmp/wg0.conf"
SQUID_CONF="/tmp/squid.conf"

log() {
  echo "[entrypoint] $*"
}

# --- sanity ---
if [ ! -f "$WG_SRC" ]; then
  log "wg0.conf not found at $WG_SRC"
  exit 1
fi

if [ ! -f "/run/squid-secrets/htpasswd" ]; then
  log "htpasswd not found"
  exit 1
fi

# --- extract DNS ---
DNS_SERVERS="$(grep -E '^[[:space:]]*DNS[[:space:]]*=' "$WG_SRC" \
  | sed 's/^[[:space:]]*DNS[[:space:]]*=[[:space:]]*//' \
  | tr ',' ' ' || true)"

log "DNS from wg config: ${DNS_SERVERS:-<none>}"

# --- prepare wg config (without DNS=) ---
grep -vE '^[[:space:]]*DNS[[:space:]]*=' "$WG_SRC" > "$WG_TMP"
chmod 600 "$WG_TMP"

# --- bring up wireguard ---
log "bringing up wg0"
wg-quick up "$WG_TMP"

# --- kill switch ---
log "installing kill-switch"
iptables -I OUTPUT 1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -I OUTPUT 2 ! -o wg0 \
  -m mark ! --mark "$(wg show wg0 fwmark)" \
  -m addrtype ! --dst-type LOCAL \
  -j REJECT

# --- generate squid config ---
log "generating squid config"

{
  echo "http_port 3128"

  if [ -n "${DNS_SERVERS}" ]; then
    echo "dns_nameservers ${DNS_SERVERS}"
  fi

  cat <<'SQUID'
auth_param basic program /usr/lib/squid/basic_ncsa_auth /run/squid-secrets/htpasswd
auth_param basic realm wg-http-proxy
acl authenticated proxy_auth REQUIRED

http_access allow authenticated
http_access deny all

cache deny all
pinger_enable off

cache_log /tmp/squid-cache.log
access_log stdio:/tmp/squid-access.log
SQUID

} > "$SQUID_CONF"

# --- cleanup handler ---
cleanup() {
  log "cleanup..."

  iptables -D OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true

  iptables -D OUTPUT ! -o wg0 \
    -m mark ! --mark "$(wg show wg0 fwmark)" \
    -m addrtype ! --dst-type LOCAL \
    -j REJECT || true

  wg-quick down "$WG_TMP" || true
}

trap cleanup TERM INT EXIT

# --- prepare squid log files ---
mkfifo /tmp/squid-access.log
mkfifo /tmp/squid-cache.log

chown proxy:proxy /tmp/squid-access.log /tmp/squid-cache.log

cat /tmp/squid-access.log &
cat /tmp/squid-cache.log >&2 &

# --- start squid ---
log "starting squid"
exec squid -N -f "$SQUID_CONF"
