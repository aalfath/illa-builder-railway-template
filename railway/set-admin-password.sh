#!/usr/bin/env bash
# Replaces the upstream default password of the built-in "root" account with ILLA_ADMIN_PASSWORD.
# Runs on every boot but only changes the password while it is still the upstream default,
# so a password changed later in the UI is kept.
set -euo pipefail
DEFAULT_DIGEST='$2a$10$iVIxJRgy1K6RIV389AYg3OiMIbuDyuCIja1xrHGkCljdg/6gdmWXa'
q() { psql -U postgres -v ON_ERROR_STOP=1 -qAt "$@"; }
for i in $(seq 1 30); do
  cur="$(q -d illa_supervisor -c "select password_digest from users where email = 'root'" 2>/dev/null)" && [ -n "$cur" ] && break
  sleep 2
done
if [ -z "${cur:-}" ]; then echo "[railway] could not read the root account" >&2; exit 1; fi
if [ "$cur" != "$DEFAULT_DIGEST" ]; then echo "[railway] root password already set; leaving it"; exit 0; fi
digest="$(printf '%s\n' "create extension if not exists pgcrypto;" "select crypt(:'pw', gen_salt('bf', 10));" | q -d postgres -v pw="$ILLA_ADMIN_PASSWORD" | tail -n1)"
case "$digest" in '$2a$'*) ;; *) echo "[railway] bcrypt failed" >&2; exit 1;; esac
printf '%s\n' "update users set password_digest = :'d', updated_at = now() where email = 'root';" | q -d illa_supervisor -v d="$digest"
echo "[railway] root password set from ILLA_ADMIN_PASSWORD"
