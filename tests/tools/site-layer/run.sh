#!/usr/bin/env bash
# Tests the site-layer check (tools/site-layer.sh, template plan 1.6b) on known examples, run by the
# tools' self-check every time: a layer and a theme that agree with the list pass, and each broken
# one is refused, naming the file that is wrong. The examples are written fresh into a temporary
# folder, so nothing depends on this site's theme. Needs bash, find, grep, sed, sort and comm.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HERE
# shellcheck source=tools/site-layer.sh
source "$HERE/../../../tools/site-layer.sh"

log() { printf '%s [site layer tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

EXAMPLES_DIR=""

readonly LIST_TEXT='# A comment line, then the files.
theme.json
parts/header.html   # a comment after a path

'
readonly AGREEING_LAYER='theme.json parts/header.html assets/images/logo.svg'
readonly AGREEING_THEME='theme.json parts/header.html functions.php assets/images/grain.png'

# expected problem ## what the example breaks ## the layer's files ## the theme's files
readonly BROKEN_EXAMPLES=(
  "listed but missing from the layer: parts/header.html ## a listed file the layer lacks ## theme.json ## $AGREEING_THEME"
  "in the layer but not listed: functions.php ## a generic file copied into the layer ## $AGREEING_LAYER functions.php ## $AGREEING_THEME"
  "in the layer but not listed: parts/extra.html ## a site-layer file not added to the list ## $AGREEING_LAYER parts/extra.html ## $AGREEING_THEME"
  "listed but missing from the theme: parts/header.html ## a listed file the theme lacks ## $AGREEING_LAYER ## theme.json functions.php"
)

# Creates each named file (space-separated paths) under the folder, empty.
write_files() {
  local folder="$1" path
  rm -rf "$folder"
  mkdir -p "$folder"
  for path in $2; do
    mkdir -p "$folder/$(dirname "$path")"
    : >"$folder/$path"
  done
}

write_example() {
  printf '%s' "$LIST_TEXT" >"$EXAMPLES_DIR/site-layer-files.txt"
  write_files "$EXAMPLES_DIR/layer" "$1"
  write_files "$EXAMPLES_DIR/theme" "$2"
}

differences_of_example() {
  site_layer_differences "$EXAMPLES_DIR/site-layer-files.txt" "$EXAMPLES_DIR/layer" "$EXAMPLES_DIR/theme"
}

expect_agreement() {
  local differences
  write_example "$AGREEING_LAYER" "$AGREEING_THEME"
  differences="$(differences_of_example)"
  [[ -z "$differences" ]] && { log "ok    a layer and a theme that agree with the list, with a logo of the layer's own"; return 0; }
  log "FAIL  a layer and a theme that agree with the list were refused: $differences"
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

expect_missing() {
  local failed=0
  write_example "$AGREEING_LAYER" "$AGREEING_THEME"
  rm -r "$EXAMPLES_DIR/theme"
  expect_problem "missing folder: theme" "the theme's folder missing" || failed=1
  rm -r "$EXAMPLES_DIR/layer"
  expect_problem "missing folder: layer" "the layer's folder missing" || failed=1
  rm "$EXAMPLES_DIR/site-layer-files.txt"
  expect_problem "missing list: site-layer-files.txt" "the list missing" || failed=1
  return "$failed"
}

main() {
  local entry expected what rest layer_files theme_files failed=0
  EXAMPLES_DIR="$(mktemp -d)"
  trap 'rm -rf "$EXAMPLES_DIR"' EXIT
  expect_agreement || failed=1
  for entry in "${BROKEN_EXAMPLES[@]}"; do
    expected="${entry%% ## *}"
    rest="${entry#* ## }"
    what="${rest%% ## *}"
    rest="${rest#* ## }"
    layer_files="${rest%% ## *}"
    theme_files="${rest#* ## }"
    write_example "$layer_files" "$theme_files"
    expect_problem "$expected" "$what" || failed=1
  done
  expect_missing || failed=1
  return "$failed"
}

main "$@"
