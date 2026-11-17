#!/usr/bin/env bash
# Build-time patches to the upstream all-in-one scripts. Fails the build if a patch no longer applies.
set -euo pipefail
M=/opt/illa/main.sh
rep() { # file, sed expression, expected marker
  sed -i "$2" "$1"
  grep -qF -- "$3" "$1" || { echo "patch failed: $1 :: $3" >&2; exit 1; }
}
# All state on one volume at /data
rep $M 's#^export PGDATA=.*#export PGDATA=/data/pgdata#' 'export PGDATA=/data/pgdata'
rep $M 's#^export MINIODATA=.*#export MINIODATA=/data/drive/#' 'export MINIODATA=/data/drive/'
# Postgres, Redis and MinIO only on loopback
rep $M 's#postgres 2>&1 | _label#postgres -c listen_addresses=127.0.0.1 2>\&1 | _label#g' 'postgres -c listen_addresses=127.0.0.1 2>&1'
rep $M 's#^redis-server 2>&1#redis-server --bind 127.0.0.1 --save "" --appendonly no 2>\&1#' 'redis-server --bind 127.0.0.1'
rep $M 's#minio server $MINIODATA 2>&1#minio server --address 127.0.0.1:9000 --console-address 127.0.0.1:9101 $MINIODATA 2>\&1#' 'minio server --address 127.0.0.1:9000'
# Replace the upstream default admin password right after the database init
rep $M 's#^\(/opt/illa/postgres/postgres-init.sh .*\)$#\1\n/opt/illa/railway/set-admin-password.sh || exit 1#' '/opt/illa/railway/set-admin-password.sh || exit 1'
# Exit (so Railway restarts the container) when a core process dies
rep $M 's#^    sleep 1;$#    sleep 10; /opt/illa/railway/watchdog.sh || exit 1;#' '/opt/illa/railway/watchdog.sh || exit 1'
# Static file servers on loopback too
for f in /etc/nginx/conf.d/illa-builder-frontend.conf /etc/nginx/conf.d/illa-cloud-frontend.conf; do
  sed -i -E 's#listen ([0-9]+)#listen 127.0.0.1:\1#' "$f"
  grep -q 'listen 127.0.0.1:' "$f" || { echo "patch failed: $f" >&2; exit 1; }
done
# Keep a pristine copy of the Envoy config; start.sh writes the listener port from $PORT
grep -q 'port_value: 2022$' /opt/illa/envoy/illa-unit-ingress.yaml
cp /opt/illa/envoy/illa-unit-ingress.yaml /opt/illa/railway/illa-unit-ingress.yaml.orig
nginx -t
