#!/usr/bin/env bash
# Shared helpers for the scenario checks (plan step 3e), which run against the dev site
# (bin/dev-site). Sourced by each check, never run on its own.
#
# Plain bash instead of the bats test framework: bats would run in a container that needs the
# Docker socket to reach the stack, which gives that container full control of the user's
# Docker. Revisit if that trade-off changes.

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly TOOLS_DIR
# shellcheck source=tools/paths.sh
source "$TOOLS_DIR/tools/paths.sh"
# The site tested (SITE_DIR, from the user's environment as bin/test received it) and its
# site.json, by the same rule as every tool (template plan T19): the debug log's own-code places
# are the tested site's, so a notice from the starter's theme fails as this site's would.
# shellcheck source=tools/site-settings.sh
source "$TOOLS_DIR/tools/site-settings.sh"
SCENARIO_NAME="$(basename "${BASH_SOURCE[1]:-scenario}" .sh)"
readonly SCENARIO_NAME

log() { printf '%s [%s] %s\n' "$(date +%H:%M:%S)" "$SCENARIO_NAME" "$*" >&2; }
fail() { log "FAILED: $*"; exit 1; }

# --progress quiet keeps Compose's "Container ..." lines out of captured output, so a failure
# message shows what the command itself printed.
# The recipe's site part, compose.site.yaml, is written from site.json by bin/dev-site, which the
# scenario checks run after.
dev_compose() { docker compose --progress quiet --project-directory "$PROJECT_DIR" -f "$TOOLS_DIR/compose.dev.yaml" -f "$PROJECT_DIR/compose.site.yaml" "$@"; }

load_settings() {
  [[ -f "$PROJECT_DIR/.env" ]] || fail "no .env; run bin/dev-site first"
  set -a
  # shellcheck source=/dev/null
  source "$PROJECT_DIR/.env"
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
# shellcheck source=tests/scenario/debug-log.sh
source "$TOOLS_DIR/tests/scenario/debug-log.sh"

# The debug log holds nothing from the site's own code and no fatal error; other people's notices,
# warnings and deprecations are shown (the rule in tests/scenario/debug-log.sh, template plan 1.5b).
expect_clean_debug_log() {
  local entries verdicts shown failing
  entries="$(dev_compose exec -T wordpress sh -c "[ -f '$DEBUG_LOG' ] && cat '$DEBUG_LOG' || true")"
  verdicts="$(debug_log_verdicts "$entries" "$(own_code_places "$SITE_SETTINGS_FILE")")"
  shown="$(sed -n 's/^shown\t//p' <<<"$verdicts")"
  failing="$(sed -n 's/^fail\t//p' <<<"$verdicts")"
  [[ -z "$shown" ]] || log "other people's code wrote to the debug log (shown, not failed):
$shown"
  [[ -z "$failing" ]] || fail "the debug log holds the site's own code's messages or an error:
$failing"
  log "the debug log holds nothing from the site's own code and no error"
}

# Error messages are checked for the name of the offending setting, never for their wording.
assert_output_names() {
  local name="$1" context="$2"
  [[ "$RUN_OUTPUT" == *"$name"* ]] && return 0
  fail "$context: the output does not name $name. Output: $RUN_OUTPUT"
}
