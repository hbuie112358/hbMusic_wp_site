#!/usr/bin/env bash
# Tests the debug log rule (tests/scenario/debug-log.sh, template plan 1.5b) on sample lines, run by
# the tools' self-check every time: which lines fail and which are only shown. The site is a neutral
# one (an example theme and plugin), so nothing depends on this site's names. Needs bash and jq.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HERE
# shellcheck source=tests/scenario/debug-log.sh
source "$HERE/../../scenario/debug-log.sh"

log() { printf '%s [debug-log tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

readonly STAMP='[22-Nov-2026 13:31:29 UTC]'
# expected verdict ## log line ## what it is (" ## " never occurs in a log line)
readonly CASES=(
  "fail ## $STAMP DEV ORIGIN Warning themes/example-child/functions.php:12 | Undefined variable \$x in /var/www/html/wp-content/themes/example-child/functions.php on line 12 ## the site's theme"
  "fail ## $STAMP DEV ORIGIN Notice plugins/example-plugin/example-plugin.php:40 | Function wp_enqueue_script was called incorrectly in /var/www/html/wp-includes/functions.php on line 6121 ## the site's plugin, though WordPress's file wrote it"
  "fail ## $STAMP DEV ORIGIN Deprecated mu-plugins/dev-services.php:7 | Something in /var/www/html/wp-content/mu-plugins/dev-services.php on line 7 ## the dev site's must-use plugins"
  "shown ## $STAMP DEV ORIGIN Deprecated plugins/downloaded-plugin/inc/helpers.php:60 | trim(): Passing null to parameter #1 in /var/www/html/wp-includes/formatting.php on line 5581 ## a downloaded plugin's deprecation"
  "shown ## $STAMP DEV ORIGIN Warning plugins/example-plugin-extra/main.php:3 | Undefined array key in /var/www/html/wp-content/plugins/example-plugin-extra/main.php on line 3 ## a plugin whose name only begins like the site's"
  "shown ## $STAMP DEV ORIGIN Notice WordPress | Something in /var/www/html/wp-includes/load.php on line 9 ## WordPress's own notice"
  "fail ## $STAMP PHP Fatal error:  Uncaught Error: Call to undefined function nope() in /var/www/html/wp-content/plugins/downloaded-plugin/x.php:3 ## a fatal error, even from someone else's code"
  "fail ## #0 /var/www/html/wp-settings.php(545): include_once() ## a fatal error's stack trace line"
  "fail ## $STAMP PHP Warning:  Undefined variable \$y in /var/www/html/wp-content/plugins/downloaded-plugin/x.php on line 4 ## a message written without its origin"
  "fail ## $STAMP DEV ORIGIN Error plugins/downloaded-plugin/x.php:4 | Something in /x.php on line 4 ## an origin line of an unknown level"
)

SITE_SETTINGS=""

main() {
  local own_places entry expected line what verdict failed=0
  SITE_SETTINGS="$(mktemp)"
  trap 'rm -f "$SITE_SETTINGS"' EXIT
  printf '{"theme": "example-child", "localPlugins": ["example-plugin"]}\n' >"$SITE_SETTINGS"
  own_places="$(own_code_places "$SITE_SETTINGS")"
  [[ -z "$(debug_log_verdicts "" "$own_places")" ]] || { log "FAIL  an empty log gave a verdict"; failed=1; }
  for entry in "${CASES[@]}"; do
    expected="${entry%% ## *}"
    what="${entry##* ## }"
    line="${entry#* ## }"
    line="${line% ## *}"
    verdict="$(debug_log_verdicts "$line" "$own_places" | cut -f1)"
    if [[ "$verdict" == "$expected" ]]; then
      log "ok    $what: $verdict"
    else
      log "FAIL  $what: $verdict, expected $expected"
      failed=1
    fi
  done
  return "$failed"
}

main "$@"
