#!/usr/bin/env bash
# Tests the theme assembly (tools/site-theme.sh, template plan 1.6c) on known examples, run by the
# tools' self-check every time: the full theme holds the shared files, the layer's version of each
# listed file and the layer's pictures; a stale file from an earlier build is gone; and a layer that
# does not match the list is refused with the earlier build left as it was. The examples are written
# fresh into a temporary folder. Needs bash, cp, find, grep, sed, sort and comm.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HERE
# shellcheck source=tools/site-layer.sh
source "$HERE/../../../tools/site-layer.sh"
# shellcheck source=tools/site-theme.sh
source "$HERE/../../../tools/site-theme.sh"

log() { printf '%s [site theme tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

EXAMPLES_DIR=""

# Writes a file with the given text, making its folder.
write_file() {
  mkdir -p "$(dirname "$1")"
  printf '%s\n' "$2" >"$1"
}

write_example() {
  rm -rf "${EXAMPLES_DIR:?}"/*
  write_file "$EXAMPLES_DIR/site-layer-files.txt" 'theme.json'
  write_file "$EXAMPLES_DIR/shared/theme.json" 'shared look'
  write_file "$EXAMPLES_DIR/shared/functions.php" 'shared code'
  write_file "$EXAMPLES_DIR/shared/assets/images/grain.png" 'shared picture'
  write_file "$EXAMPLES_DIR/layer/theme.json" 'layer look'
  write_file "$EXAMPLES_DIR/layer/assets/images/logo.svg" 'layer picture'
}

assemble_example() {
  assemble_site_theme "$EXAMPLES_DIR/site-layer-files.txt" "$EXAMPLES_DIR/layer" "$EXAMPLES_DIR/shared" "$EXAMPLES_DIR/out/themes/site"
}

# Passes when the file in the output holds exactly the expected text.
expect_file() {
  local path="$1" expected="$2" what="$3"
  [[ "$(cat "$EXAMPLES_DIR/out/themes/site/$path" 2>/dev/null)" == "$expected" ]] && return 0
  log "FAIL  $what: $path does not hold \"$expected\""
  return 1
}

expect_assembled() {
  local failed=0
  write_example
  assemble_example >/dev/null || { log "FAIL  a layer matching the list was refused"; return 1; }
  expect_file theme.json 'layer look' "the layer's version of a listed file" || failed=1
  expect_file functions.php 'shared code' "a shared file" || failed=1
  expect_file assets/images/grain.png 'shared picture' "a shared picture" || failed=1
  expect_file assets/images/logo.svg 'layer picture' "the layer's own picture" || failed=1
  ((failed == 0)) && log "ok    the full theme: shared files, the layer's listed files and pictures"
  return "$failed"
}

expect_stale_file_removed() {
  write_example
  write_file "$EXAMPLES_DIR/out/themes/site/old.php" 'from an earlier build'
  assemble_example >/dev/null || { log "FAIL  a layer matching the list was refused"; return 1; }
  [[ ! -e "$EXAMPLES_DIR/out/themes/site/old.php" ]] && { log "ok    a file from an earlier build is gone"; return 0; }
  log "FAIL  a file from an earlier build was left in the theme"
  return 1
}

expect_refusal_keeps_earlier_build() {
  local output
  write_example
  assemble_example >/dev/null || { log "FAIL  a layer matching the list was refused"; return 1; }
  write_file "$EXAMPLES_DIR/layer/functions.php" 'a generic file copied into the layer'
  output="$(assemble_example)" && { log "FAIL  a layer not matching the list was assembled"; return 1; }
  grep -qxF 'in the layer but not listed: functions.php' <<<"$output" ||
    { log "FAIL  the refusal did not name the file: ${output:-nothing}"; return 1; }
  expect_file functions.php 'shared code' "the earlier build after a refusal" || return 1
  log "ok    a layer not matching the list is refused, naming the file, the earlier build kept"
}

main() {
  local failed=0
  EXAMPLES_DIR="$(mktemp -d)"
  trap 'rm -rf "$EXAMPLES_DIR"' EXIT
  expect_assembled || failed=1
  expect_stale_file_removed || failed=1
  expect_refusal_keeps_earlier_build || failed=1
  return "$failed"
}

main "$@"
