#!/usr/bin/env bash
# Railway start script: checks the secrets, wires MinIO credentials, sets the public port, then runs upstream main.sh.
set -euo pipefail
for v in ILLA_SECRET_KEY ILLA_ADMIN_PASSWORD ILLA_DRIVE_PASSWORD; do
  if [ -z "${!v:-}" ]; then echo "[railway] $v must be set (the template generates it)." >&2; exit 1; fi
done
if [ "${#ILLA_DRIVE_PASSWORD}" -lt 8 ]; then echo "[railway] ILLA_DRIVE_PASSWORD needs at least 8 characters." >&2; exit 1; fi

# Internal MinIO object store: replace the upstream minioadmin/minioadmin credentials
export MINIO_ROOT_USER=illa-drive MINIO_ROOT_PASSWORD="$ILLA_DRIVE_PASSWORD"
export ILLA_DRIVE_ACCESS_KEY_ID=illa-drive ILLA_DRIVE_ACCESS_KEY_SECRET="$ILLA_DRIVE_PASSWORD"

PORT="${PORT:-8080}"
case "$PORT" in ''|*[!0-9]*) echo "[railway] PORT must be a number" >&2; exit 1;; esac
sed "s/port_value: 2022$/port_value: ${PORT}/" /opt/illa/railway/illa-unit-ingress.yaml.orig > /opt/illa/envoy/illa-unit-ingress.yaml

mkdir -p /data
echo "[railway] ILLA Builder starting; data in /data, listening on port ${PORT}"
exec /opt/illa/main.sh
