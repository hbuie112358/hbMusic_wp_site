#!/usr/bin/env bash
# The rule for WordPress's debug log on the dev site (template plan 1.5b, agreed with the user on
# 2026-11-22), sourced by tests/scenario/lib.sh and tested on sample logs by
# tests/tools/debug-log/run.sh. Every line is sorted:
#   - a message whose origin is the site's own code (its theme, its own plugins, the dev site's
#     must-use plugins) fails, whatever its level;
#   - a notice, warning or deprecation from other people's code (WordPress, downloaded plugins)
#     is shown, not failed: their code is theirs to fix, and the browser tests show whether it
#     breaks anything;
#   - every other line fails: a fatal error (which PHP writes itself), or a message written
#     without an origin, so a gap in the sorting can only err on the strict side.
# The origins come from config/dev-mu-plugins/dev-error-origin.php's "DEV ORIGIN" lines.

readonly DEBUG_LOG_ORIGIN_LINE='^\[[^]]+\] DEV ORIGIN (Warning|Notice|Deprecated) ([^ ]+) \| '

# The site's own code, as paths under wp-content/, one per line, from the given site.json.
own_code_places() {
  jq -r '"themes/\(.theme)/", (.localPlugins[] | "plugins/\(.)/"), "mu-plugins/"' "$1"
}

# Sorts the log text (first argument) against the own-code places (second, one per line): prints
# "fail<TAB>line" or "shown<TAB>line" for each line that is not empty.
debug_log_verdicts() {
  local log_text="$1" own_places="$2" line origin place is_own
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    if [[ ! "$line" =~ $DEBUG_LOG_ORIGIN_LINE ]]; then
      printf 'fail\t%s\n' "$line"
      continue
    fi
    origin="${BASH_REMATCH[2]}"
    is_own=false
    while IFS= read -r place; do
      [[ -n "$place" && "$origin" == "$place"* ]] && is_own=true
    done <<<"$own_places"
    if [[ "$is_own" == true ]]; then printf 'fail\t%s\n' "$line"; else printf 'shown\t%s\n' "$line"; fi
  done <<<"$log_text"
}
