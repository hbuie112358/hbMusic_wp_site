#!/usr/bin/env bash
# The local settings in .env, shared by bin/local-import (the old-site copy) and bin/dev-site
# (the dev site): .env is created from .env.example with random secrets, new settings are
# appended, and every setting a script needs is checked. Sourced, never run.
#
# The sourcing script defines REPO_ROOT, ENV_FILE, REQUIRED_SETTINGS (an array), log and fail.

# Both sites' databases keep the passwords they were first started with, and both sets of
# passwords live in the one .env, so a new .env is refused while either database exists.
readonly SETTINGS_DATABASE_VOLUMES=(hbmusic_db_data hbmusic-dev_db_data)

random_secret() { od -An -N24 -tx1 /dev/urandom | tr -d ' \n'; }

# Prints a line of .env.example as it goes into .env: "generate" becomes a random secret.
expand_setting_line() {
  local line="$1"
  [[ "$line" == *=generate ]] && line="${line%=generate}=$(random_secret)"
  printf '%s\n' "$line"
}

existing_database_volumes() {
  local volume
  for volume in "${SETTINGS_DATABASE_VOLUMES[@]}"; do
    docker volume inspect "$volume" >/dev/null 2>&1 && printf '%s ' "$volume"
  done
  return 0
}

create_env_file() {
  # A new .env would not match the passwords an existing database was started with, and the
  # script would fail later with an unexplained "access denied".
  local volumes
  volumes="$(existing_database_volumes)"
  if [[ -n "$volumes" ]]; then
    fail "there is no .env, but these databases still have the passwords of an earlier one: ${volumes}. Restore that .env, or remove the site whose database it is (docker compose down -v, with -f compose.dev.yaml for the dev site), then run again."
  fi
  log "Creating .env from .env.example with new random secrets"
  local line
  (
    umask 077
    while IFS= read -r line; do expand_setting_line "$line"; done <"$REPO_ROOT/.env.example" >"$ENV_FILE"
  )
}

# Settings added to .env.example after .env was created are appended, so an existing .env
# (and the database passwords it holds) never has to be recreated.
add_missing_settings() {
  local line name
  while IFS= read -r line; do
    [[ "$line" =~ ^([A-Z_]+)= ]] || continue
    name="${BASH_REMATCH[1]}"
    grep -q "^${name}=" "$ENV_FILE" && continue
    log "Adding the new setting $name to .env"
    expand_setting_line "$line" >>"$ENV_FILE"
  done <"$REPO_ROOT/.env.example"
}

ensure_env_file() {
  if [[ ! -f "$ENV_FILE" ]]; then
    create_env_file
    return
  fi
  log "Using the existing .env"
  add_missing_settings
}

load_env() {
  set -a
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +a
}

require_settings() {
  local name
  for name in "${REQUIRED_SETTINGS[@]}"; do
    [[ -n "${!name:-}" ]] || fail "the setting $name is missing or empty in .env (see .env.example)"
  done
}
