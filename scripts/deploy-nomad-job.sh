#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <plan|run> <job-dir>" >&2
  exit 1
fi

COMMAND="$1"
JOB_DIR="$2"

JOB_FILE="$JOB_DIR/job.hcl"

ZFS_PARENT_DATASET="${ZFS_PARENT_DATASET:-tank/nomad-csi}"

if [ ! -f "$JOB_FILE" ]; then
  echo "job.hcl not found: $JOB_FILE" >&2
  exit 1
fi

extract_volume_id() {
  sed -n 's/^[[:space:]]*id[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$1" | head -n1
}

wait_for_zfs_dataset() {
  local dataset="$1"

  for _ in $(seq 1 30); do
    if sudo zfs list -H "$dataset" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "zfs dataset did not appear: $dataset" >&2
  return 1
}

apply_zfs_properties() {
  local volume_file="$1"
  local volume_id="$2"
  local props_file="${volume_file%.hcl}.zfs.properties"
  local dataset="${ZFS_PARENT_DATASET}/${volume_id}"

  [ -f "$props_file" ] || return 0

  echo "applying zfs properties for $volume_id"

  wait_for_zfs_dataset "$dataset"

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    [ -z "$line" ] && continue
    case "$line" in \#*) continue ;; esac

    key="${line%%=*}"
    value="${line#*=}"

    if [ -z "$key" ] || [ "$key" = "$value" ]; then
      echo "invalid zfs property line in $props_file: $line" >&2
      exit 1
    fi

    echo "zfs set $key=$value $dataset"
    sudo zfs set "$key=$value" "$dataset"
  done < "$props_file"
}

create_missing_volumes() {
  local volumes_dir="$JOB_DIR/volumes"

  [ -d "$volumes_dir" ] || return 0

  shopt -s nullglob

  for volume_file in "$volumes_dir"/*.hcl; do
    volume_id="$(extract_volume_id "$volume_file")"

    if [ -z "$volume_id" ]; then
      echo "failed to extract volume id from $volume_file" >&2
      exit 1
    fi

    if nomad volume status "$volume_id" >/dev/null 2>&1; then
      echo "volume exists: $volume_id"
    else
      echo "creating volume: $volume_id"
      nomad volume create "$volume_file"
    fi

    apply_zfs_properties "$volume_file" "$volume_id"
  done
}

create_missing_volumes

case "$COMMAND" in
  plan)
    exec nomad job plan "$JOB_FILE"
    ;;

  run)
    exec nomad job run "$JOB_FILE"
    ;;

  *)
    echo "unknown command: $COMMAND" >&2
    exit 1
    ;;
esac
