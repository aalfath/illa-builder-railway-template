# ILLA Builder on Railway

Railway template for [ILLA Builder](https://github.com/illacloud/illa-builder), the open-source low-code platform for building internal tools (dashboards, CRUD apps, admin panels) on top of your databases and APIs.

## What it deploys

One service built from this repo's `Dockerfile`:

- Base image: the official all-in-one image `illasoft/illa-builder:v4.8.5`, pinned by digest (`sha256:4cb2e832e4d4b678863442c091975e1250ba60891712a3f825812480bcaa0562`). v4.8.5 (August 2024) is the latest upstream release.
- Inside the container: ILLA's frontend, builder and supervisor backends, an Envoy proxy on Railway's `PORT`, and the bundled PostgreSQL 14, Redis and MinIO. Only Envoy listens on a public interface; everything else is bound to `127.0.0.1`.
- One Railway volume at `/data` holds the PostgreSQL data (`/data/pgdata`) and the MinIO file store (`/data/drive`).
- Health check: `GET /supervisor/api/v1/status`.

## What this wrapper changes

Upstream ships fixed credentials. The wrapper replaces them:

- The built-in `root` account's default password `password` is replaced on first boot by `ILLA_ADMIN_PASSWORD`. If you later change the password in ILLA, the wrapper leaves it alone.
- The JWT signing key comes from `ILLA_SECRET_KEY` instead of the upstream default.
- MinIO's `minioadmin` credentials are replaced by `ILLA_DRIVE_PASSWORD`, and MinIO's console is off.
- Postgres, Redis and MinIO listen on loopback only.
- A watchdog stops the container when a core process dies, so Railway restarts it.

## Variables

| Variable | Default in the template | Purpose |
|---|---|---|
| `ILLA_ADMIN_PASSWORD` | generated, 24 characters | Password of the `root` account (sign in with username `root`) |
| `ILLA_SECRET_KEY` | generated, 48 characters | Signs ILLA's login tokens. Changing it signs everyone out |
| `ILLA_DRIVE_PASSWORD` | generated, 32 characters | Credentials of the internal MinIO file store. Keep it stable after the first deploy |

Sign in at your Railway domain with username `root` and the value of `ILLA_ADMIN_PASSWORD` from the service's Variables tab, then change the password and invite your team.

## Notes

- Self-hosted ILLA has no e-mail delivery: sign-up and password-reset e-mails go to ILLA's cloud service and don't work on a self-hosted instance. Add users through team invites from the `root` account.
- Some cloud-only features (AI agents, marketplace, Google Sheets OAuth) need ILLA Cloud and are not available here.

## Updates

This template builds from this repository. Version bumps land on `main` with an entry in [CHANGELOG.md](CHANGELOG.md); Railway then shows an "update available" notice to everyone who deployed the template, and you choose when to apply it. Back up `/data` before applying an update that changes the PostgreSQL major version.
