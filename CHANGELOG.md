# Changelog

## 4.8.5-railway.1 (2026-11-17)

- First release: ILLA Builder v4.8.5 (`illasoft/illa-builder:v4.8.5@sha256:4cb2e832e4d4b678863442c091975e1250ba60891712a3f825812480bcaa0562`).
- All state on one volume at `/data` (PostgreSQL in `/data/pgdata`, MinIO in `/data/drive`).
- Generated secrets replace the upstream default `root` password, JWT key and MinIO credentials.
- Internal services bound to loopback; watchdog restarts the container when a core process dies.
