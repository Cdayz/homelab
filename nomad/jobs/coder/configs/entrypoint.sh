#!/bin/sh
set -eu

pg_password="$(cat /run/coder-secrets/db_password)"

export CODER_PG_CONNECTION_URL="postgres://coder:${pg_password}@127.0.0.1:15432/coder?sslmode=disable"
export CODER_OIDC_CLIENT_SECRET="$(cat /run/coder-secrets/oidc_client_secret)"

exec /opt/coder server
