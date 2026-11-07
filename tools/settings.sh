#!/usr/bin/env bash
# The local settings in .env, used by bin/dev-site: .env is created from .env.example with random
# secrets, new settings are appended, and every setting the script needs is checked. Sourced,
# never run.
#
# The sourcing script defines REPO_ROOT, ENV_FILE, REQUIRED_SETTINGS (an array), log and fail.

# The dev site's database keeps the passwords it was first started with, so a new .env is refused
# while that database exists.
readonly SETTINGS_DATABASE_VOLUMES=(hbmusic-dev_db_data)

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
    fail "there is no .env, but these databases still have the passwords of an earlier one: ${volumes}. Restore that .env, or remove the site (docker compose -f compose.dev.yaml down -v), then run again."
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
