#!/usr/bin/env bash
# Scenario (dev site): with no .env but the site's database still present, creating a new .env is
# refused, since its new passwords would not match that database (tools/settings.sh). Runs
# against a temporary path, never the real .env.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

# The dev site's database volume, named from site.json's slug as bin/dev-site names it.
load_site_volume_names || exit 1

# Runs create_env_file in a separate shell with ENV_FILE pointing into a temporary folder.
attempt_new_env_file() {
  local scratch_env="$1"
  # shellcheck disable=SC2016 # the variables expand in the inner shell, on purpose
  run_capturing env TOOLS_DIR="$TOOLS_DIR" ENV_FILE="$scratch_env" DEV_DATABASE_VOLUME="$DEV_DATABASE_VOLUME" bash -c '
    set -euo pipefail
    log() { printf "%s\n" "$*" >&2; }
    fail() { log "ERROR: $*"; exit 1; }
    source "$TOOLS_DIR/tools/settings.sh"
    create_env_file
  '
}

main() {
  docker volume inspect "$DEV_DATABASE_VOLUME" >/dev/null 2>&1 ||
    fail "the dev site's database ($DEV_DATABASE_VOLUME) does not exist; run bin/dev-site first"
  local scratch_dir
  scratch_dir="$(mktemp -d)"
  # shellcheck disable=SC2064 # the folder is known now
  trap "rm -rf '$scratch_dir'" EXIT
  attempt_new_env_file "$scratch_dir/.env"
  assert_status 1 "creating a .env while the database exists"
  assert_output_names "$DEV_DATABASE_VOLUME" "the refusal"
  [[ ! -e "$scratch_dir/.env" ]] || fail "a .env was created despite the refusal"
  log "PASSED"
}

main "$@"
