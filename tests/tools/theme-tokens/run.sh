#!/usr/bin/env bash
# Tests the design-token check (tools/theme-tokens.sh, template plan 1.6b) on known examples, run by
# the tools' self-check every time: a look defining every token its components use passes, and each
# broken one is refused, naming the token or file that is wrong. The examples are written fresh into
# a temporary folder, so nothing depends on this site's look. Needs bash, grep, sed, sort, comm and
# jq.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HERE
# shellcheck source=tools/theme-tokens.sh
source "$HERE/../../../tools/theme-tokens.sh"

log() { printf '%s [theme tokens tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

EXAMPLES_DIR=""

# A stylesheet using one token of each kind the check knows, a camelCase path among them.
readonly COMPONENT_CSS='.example { color: var(--wp--custom--call-to-action--button-text); background: var(--wp--preset--color--base); box-shadow: var(--wp--preset--shadow--glow); }'
readonly COMPLETE_THEME_JSON='{ "settings": {
  "color": { "palette": [ { "slug": "base", "color": "#fff", "name": "Base" } ] },
  "shadow": { "presets": [ { "slug": "glow", "shadow": "none", "name": "Glow" } ] },
  "custom": { "callToAction": { "buttonText": "var(--wp--preset--color--base)" } }
} }'

# expected problem ## what the example breaks ## stylesheet ## theme.json
readonly BROKEN_EXAMPLES=(
  "used but not defined: --wp--custom--call-to-action--button-text ## a custom token removed from theme.json ## $COMPONENT_CSS ## { \"settings\": { \"color\": { \"palette\": [ { \"slug\": \"base\" } ] }, \"shadow\": { \"presets\": [ { \"slug\": \"glow\" } ] } } }"
  "used but not defined: --wp--custom--call-to-action--button-text ## the token's key under another group ## $COMPONENT_CSS ## { \"settings\": { \"color\": { \"palette\": [ { \"slug\": \"base\" } ] }, \"shadow\": { \"presets\": [ { \"slug\": \"glow\" } ] }, \"custom\": { \"color\": { \"buttonText\": \"red\" } } } }"
  "used but not defined: --wp--preset--color--base ## a palette color removed ## $COMPONENT_CSS ## { \"settings\": { \"shadow\": { \"presets\": [ { \"slug\": \"glow\" } ] }, \"custom\": { \"callToAction\": { \"buttonText\": \"red\" } } } }"
  "used but not defined: --wp--preset--shadow--glow ## a shadow preset removed ## $COMPONENT_CSS ## { \"settings\": { \"color\": { \"palette\": [ { \"slug\": \"base\" } ] }, \"custom\": { \"callToAction\": { \"buttonText\": \"red\" } } } }"
  "used but not defined: --wp--custom--missing ## a token only theme.json itself reads ## .example { color: red; } ## { \"settings\": { \"custom\": { \"text\": \"var(--wp--custom--missing)\" } } }"
  "a kind of token this check does not know: --wp--preset--font-size--large ## a preset kind the check does not know ## .example { font-size: var(--wp--preset--font-size--large); } ## { \"settings\": {} }"
  "not valid JSON: theme.json ## a theme.json that is not JSON ## $COMPONENT_CSS ## { \"settings\": "
)

write_example() {
  mkdir -p "$EXAMPLES_DIR/components"
  printf '%s\n' "$1" >"$EXAMPLES_DIR/components/example.css"
  printf '%s\n' "$2" >"$EXAMPLES_DIR/theme.json"
}

differences_of_example() {
  theme_token_differences "$EXAMPLES_DIR/components" "$EXAMPLES_DIR/theme.json"
}

expect_agreement() {
  local differences
  write_example "$COMPONENT_CSS" "$COMPLETE_THEME_JSON"
  differences="$(differences_of_example)"
  [[ -z "$differences" ]] && { log "ok    a look defining every token it uses"; return 0; }
  log "FAIL  a look defining every token it uses was refused: $differences"
  return 1
}

# The problem must be named exactly, as one of the lines printed.
expect_problem() {
  local expected="$1" what="$2" differences
  differences="$(differences_of_example)"
  grep -qxF -- "$expected" <<<"$differences" && { log "ok    $what"; return 0; }
  log "FAIL  $what: expected \"$expected\", got: ${differences:-nothing}"
  return 1
}

# Keys in each form WordPress breaks into words, used by the names WordPress gives them
# (_wp_to_kebab_case(), checked on the dev site, 2026-11-23): all must count as defined.
readonly KEBAB_CASE_CSS='.example { a: var(--wp--custom--heading-2-xl); b: var(--wp--custom--html-color); c: var(--wp--custom--font-size-xl); d: var(--wp--custom--accent-1); e: var(--wp--custom--size-2-xl); }'
readonly KEBAB_CASE_THEME_JSON='{ "settings": { "custom": { "heading2Xl": "1", "HTMLColor": "1", "fontSizeXL": "1", "accent1": "1", "size2xl": "1" } } }'

expect_wordpress_names() {
  local differences
  write_example "$KEBAB_CASE_CSS" "$KEBAB_CASE_THEME_JSON"
  differences="$(differences_of_example)"
  [[ -z "$differences" ]] && { log "ok    keys named as WordPress names them"; return 0; }
  log "FAIL  keys named as WordPress names them were refused: $differences"
  return 1
}

expect_missing() {
  write_example "$COMPONENT_CSS" "$COMPLETE_THEME_JSON"
  rm "$EXAMPLES_DIR/theme.json"
  expect_problem "missing file: theme.json" "theme.json missing" || return 1
  rm -r "$EXAMPLES_DIR/components"
  expect_problem "missing folder: components" "the components' folder missing"
}

main() {
  local entry expected what rest stylesheet theme_json failed=0
  EXAMPLES_DIR="$(mktemp -d)"
  trap 'rm -rf "$EXAMPLES_DIR"' EXIT
  expect_agreement || failed=1
  expect_wordpress_names || failed=1
  for entry in "${BROKEN_EXAMPLES[@]}"; do
    expected="${entry%% ## *}"
    rest="${entry#* ## }"
    what="${rest%% ## *}"
    rest="${rest#* ## }"
    stylesheet="${rest%% ## *}"
    theme_json="${rest#* ## }"
    write_example "$stylesheet" "$theme_json"
    expect_problem "$expected" "$what" || failed=1
  done
  expect_missing || failed=1
  return "$failed"
}

main "$@"
