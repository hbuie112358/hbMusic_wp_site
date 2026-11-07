#!/usr/bin/env bash
# Scenario (dev site): with no .env but the site's database still present, creating a new .env is
# refused, since its new passwords would not match that database (tools/settings.sh). Runs
# against a temporary path, never the real .env.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

readonly DEV_SITE_VOLUME="hbmusic-dev_db_data"

# Runs create_env_file in a separate shell with ENV_FILE pointing into a temporary folder.
attempt_new_env_file() {
  local scratch_env="$1"
  # shellcheck disable=SC2016 # the variables expand in the inner shell, on purpose
  run_capturing env REPO_ROOT="$REPO_ROOT" ENV_FILE="$scratch_env" bash -c '
    set -euo pipefail
    log() { printf "%s\n" "$*" >&2; }
    fail() { log "ERROR: $*"; exit 1; }
    source "$REPO_ROOT/tools/settings.sh"
    create_env_file
  '
}

main() {
  docker volume inspect "$DEV_SITE_VOLUME" >/dev/null 2>&1 ||
    fail "the dev site's database ($DEV_SITE_VOLUME) does not exist; run bin/dev-site first"
  local scratch_dir
  scratch_dir="$(mktemp -d)"
  # shellcheck disable=SC2064 # the folder is known now
  trap "rm -rf '$scratch_dir'" EXIT
  attempt_new_env_file "$scratch_dir/.env"
  assert_status 1 "creating a .env while the database exists"
  assert_output_names "$DEV_SITE_VOLUME" "the refusal"
  [[ ! -e "$scratch_dir/.env" ]] || fail "a .env was created despite the refusal"
  log "PASSED"
}

main "$@"
