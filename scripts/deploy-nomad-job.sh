#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <plan|run> <job-dir>"
  exit 1
fi

COMMAND="$1"
JOB_DIR="$2"

JOB_FILE="$JOB_DIR/job.hcl"

if [ ! -f "$JOB_FILE" ]; then
  echo "job.hcl not found: $JOB_FILE"
  exit 1
fi

create_missing_volumes() {
  local volumes_dir="$JOB_DIR/volumes"

  if [ ! -d "$volumes_dir" ]; then
    return
  fi

  shopt -s nullglob

  for volume_file in "$volumes_dir"/*.hcl; do
    local volume_id

    volume_id="$(
      sed -n 's/^[[:space:]]*id[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' \
        "$volume_file" \
        | head -n1
    )"

    if [ -z "$volume_id" ]; then
      echo "failed to extract volume id from $volume_file"
      exit 1
    fi

    if nomad volume status "$volume_id" >/dev/null 2>&1; then
      echo "volume exists: $volume_id"
      continue
    fi

    echo "creating volume: $volume_id"

    nomad volume create "$volume_file"
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
    echo "unknown command: $COMMAND"
    exit 1
    ;;
esac