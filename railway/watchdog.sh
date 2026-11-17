#!/usr/bin/env bash
# Returns non-zero when a core process is gone, so main.sh exits and Railway restarts the container.
for p in /usr/local/bin/envoy /opt/illa/illa-supervisor-backend/bin/illa-supervisor-backend /opt/illa/illa-builder-backend/bin/illa-builder-backend; do
  pgrep -f "^$p" >/dev/null || { echo "[railway] watchdog: $p is not running" >&2; exit 1; }
done
pg_isready -q -h 127.0.0.1 -U postgres || { echo "[railway] watchdog: postgres is not ready" >&2; exit 1; }
