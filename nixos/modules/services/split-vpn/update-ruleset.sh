#!/usr/bin/env bash
set -euo pipefail

GENERATOR=$1
STATE=/var/lib/split-vpn
SRS=$STATE/antizapret.srs

if [ -f "$SRS" ] && find "$SRS" -mmin -1140 | grep -q .; then
  echo "rule-set is fresh, skipping"
  exit 0
fi

curl -fsSL --max-time 600 \
  https://antifilter.download/list/domains.lst \
  -o "$STATE/domains.lst"
curl -fsSL --max-time 120 \
  https://community.antifilter.download/list/community.lst \
  -o "$STATE/community.lst"
curl -fsSL --max-time 120 \
  https://raw.githubusercontent.com/1andrevich/Re-filter-lists/main/domains_all.lst \
  -o "$STATE/refilter.lst"

cat "$STATE/domains.lst" "$STATE/refilter.lst" > "$STATE/domains-all.lst"

"$GENERATOR" "$STATE/domains-all.lst" "$STATE/community.lst" \
  "$STATE/antizapret.src.json"

sing-box rule-set compile "$STATE/antizapret.src.json" -o "$SRS.tmp"
mv "$SRS.tmp" "$SRS"
rm -f "$STATE/domains.lst" "$STATE/community.lst" "$STATE/refilter.lst" \
  "$STATE/domains-all.lst" "$STATE/antizapret.src.json"

systemctl try-restart split-vpn.service
