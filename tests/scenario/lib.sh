#!/usr/bin/env bash
# Shared helpers for the scenario checks (plan step 3e), which run against the dev site
# (bin/dev-site). Sourced by each check, never run on its own.
#
# Plain bash instead of the bats test framework: bats would run in a container that needs the
# Docker socket to reach the stack, which gives that container full control of the user's
# Docker. Revisit if that trade-off changes.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly REPO_ROOT
SCENARIO_NAME="$(basename "${BASH_SOURCE[1]:-scenario}" .sh)"
readonly SCENARIO_NAME

log() { printf '%s [%s] %s\n' "$(date +%H:%M:%S)" "$SCENARIO_NAME" "$*" >&2; }
fail() { log "FAILED: $*"; exit 1; }

# --progress quiet keeps Compose's "Container ..." lines out of captured output, so a failure
# message shows what the command itself printed.
dev_compose() { docker compose --progress quiet --project-directory "$REPO_ROOT" -f "$REPO_ROOT/compose.dev.yaml" "$@"; }

load_settings() {
  [[ -f "$REPO_ROOT/.env" ]] || fail "no .env; run bin/dev-site first"
  set -a
  # shellcheck source=/dev/null
  source "$REPO_ROOT/.env"
  set +a
}

# Runs a command and stores its combined output and exit status for the assertions below,
# without letting a non-zero status stop the calling script.
RUN_OUTPUT=""
RUN_STATUS=0
run_capturing() {
  RUN_STATUS=0
  RUN_OUTPUT="$("$@" 2>&1)" || RUN_STATUS=$?
}

assert_status() {
  local expected="$1" context="$2"
  [[ "$RUN_STATUS" -eq "$expected" ]] && return 0
  fail "$context: expected exit status $expected, got $RUN_STATUS. Output: $RUN_OUTPUT"
}

# WordPress's debug log on the dev site: any PHP error, warning, notice or deprecation lands here
# (docs/SITE_CHECKLIST.md 6.9).
readonly DEBUG_LOG="/var/www/html/wp-content/debug.log"

expect_empty_debug_log() {
  local entries
  entries="$(dev_compose exec -T wordpress sh -c "[ -f '$DEBUG_LOG' ] && cat '$DEBUG_LOG' || true")"
  [[ -z "$entries" ]] || fail "WordPress's debug log is not empty:
$entries"
  log "the debug log is empty"
}

# Error messages are checked for the name of the offending setting, never for their wording.
assert_output_names() {
  local name="$1" context="$2"
  [[ "$RUN_OUTPUT" == *"$name"* ]] && return 0
  fail "$context: the output does not name $name. Output: $RUN_OUTPUT"
}
