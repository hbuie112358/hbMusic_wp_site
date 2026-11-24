#!/usr/bin/env bash
# Tests the status sheet's check (tools/status-sheet.sh, template plan 1.5d-4) on known examples,
# run by the tools' self-check every time: a complete sheet passes, and each broken copy of it is
# refused, naming the item and what is wrong. The blank, the sheet, the exceptions record and the
# files a row names are written fresh into a temporary folder, so nothing depends on this site's
# sheet. The folder holds a stand-in site and, apart from it, a stand-in for the tools (template
# plan T19), with the files the complete sheet names split between them: a sheet names the site's
# files and the tools' (bin/check, the shared tests), so each must be found in either. Needs bash,
# awk, grep and sort.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HERE
# shellcheck source=tools/status-sheet.sh
source "$HERE/../../../tools/status-sheet.sh"

log() { printf '%s [status-sheet tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

EXAMPLE_ROOT=""
SITE_ROOT=""
TOOLS_ROOT=""

readonly BLANK='| Item | Status | How it was checked | Date |
|---|---|---|---|
| 1.1 First item | | | |
| 1.2 | retired | | |
| 2.1 Second item | | | |'

# shellcheck disable=SC2016 # The backticks are the sheet's Markdown, never run.
readonly COMPLETE_SHEET='| Item | Status | How it was checked | Date |
|---|---|---|---|
| 1.1 First item | done | `tests/e2e/first.spec.ts`, `dev-probe.sh` and `plugins/*/rules.xml` on every pull request, by `bin/check` | 2026-11-23 |
| 1.2 | retired | | |
| 2.1 Second item | exception | [E1](exceptions.md#e1): a reason | 2026-11-23 |'

# expected problem ## what the copy breaks ## a sed expression turning the complete sheet into it
# (" ## " separates the parts.)
readonly BROKEN_COPIES=(
  "missing item: 2.1 ## an item left out ## /^| 2.1 /d"
  "not an item of the standard: 3.1 ## an item the standard does not have ## \$a| 3.1 Extra | done | by hand | 2026-11-23 |"
  "listed twice: 1.1 ## an item listed twice ## /^| 1.1 /p"
  "1.2: retired in the standard, so its status is \"retired\" ## a retired item answered ## s/^| 1.2 | retired | |/| 1.2 | done | by hand |/; s/^\\(| 1.2 .*\\)| |$/\\1| 2026-11-23 |/"
  "1.1: status \"open\", not done or exception ## an item left open ## s/^| 1.1 First item | done |/| 1.1 First item | open |/"
  "2.1: exception with no check or reason ## an exception without its reason ## s/| exception | .* | 2026/| exception | | 2026/"
  "2.1: no date (YYYY-MM-DD) ## a row without its date ## s/^\\(| 2.1 .*\\)| 2026-11-23 |$/\\1| soon |/"
  "2.1: links E7, which exceptions.md does not have ## a link to an exception never recorded ## s/\\[E1\\](exceptions.md#e1)/[E7](exceptions.md#e7)/"
  "1.1: names tests/e2e/gone.spec.ts, which does not exist ## a test file deleted or renamed ## s#tests/e2e/first.spec.ts#tests/e2e/gone.spec.ts#"
  "1.1: names dev-gone.sh, found nowhere under tests/ ## a test named alone that is gone ## s/dev-probe.sh/dev-gone.sh/"
  "1.1: names plugins/*/gone.xml, which does not exist ## a path with a * matching nothing ## s#plugins/\\*/rules.xml#plugins/*/gone.xml#"
  "1.1: names bin/gone, which does not exist ## a path in neither folder ## s#bin/check#bin/gone#"
)

# The site holds the site's own test and the plugin's file; the tools hold the shared scenario
# check, a command and the blank.
write_example_folders() {
  mkdir -p "$SITE_ROOT/tests/e2e" "$SITE_ROOT/plugins/example/" "$SITE_ROOT/records" \
    "$TOOLS_ROOT/tests/scenario/generic" "$TOOLS_ROOT/tools" "$TOOLS_ROOT/bin"
  : >"$TOOLS_ROOT/bin/check"
  : >"$SITE_ROOT/tests/e2e/first.spec.ts"
  : >"$TOOLS_ROOT/tests/scenario/generic/dev-probe.sh"
  : >"$SITE_ROOT/plugins/example/rules.xml"
  printf '%s\n' "$BLANK" >"$TOOLS_ROOT/tools/status-sheet-blank.md"
  printf '# Recorded exceptions\n\n## E1\n\nA reason.\n' >"$SITE_ROOT/records/exceptions.md"
}

sheet_problems() {
  status_sheet_problems "$SITE_ROOT/records/status.md" "$TOOLS_ROOT/tools/status-sheet-blank.md" \
    "$SITE_ROOT/records/exceptions.md" "$SITE_ROOT" "$TOOLS_ROOT"
}

problems_of() {
  printf '%s\n' "$1" >"$SITE_ROOT/records/status.md"
  sheet_problems
}

expect_complete_sheet_accepted() {
  local problems
  problems="$(problems_of "$COMPLETE_SHEET")"
  [[ -z "$problems" ]] && { log "ok    a complete sheet"; return 0; }
  log "FAIL  a complete sheet was refused: $problems"
  return 1
}

# The copy's problem must be named exactly, as one of the lines printed.
expect_problem() {
  local expected="$1" what="$2" sheet="$3" problems
  problems="$(problems_of "$sheet")"
  grep -qxF -- "$expected" <<<"$problems" && { log "ok    $what"; return 0; }
  log "FAIL  $what: expected \"$expected\", got: ${problems:-nothing}"
  return 1
}

expect_missing_sheet_named() {
  local problems
  rm -f "$SITE_ROOT/records/status.md"
  problems="$(sheet_problems)"
  [[ "$problems" == "missing file: status.md" ]] && { log "ok    no sheet at all"; return 0; }
  log "FAIL  no sheet at all: got ${problems:-nothing}"
  return 1
}

main() {
  local entry expected what expression failed=0
  EXAMPLE_ROOT="$(mktemp -d)"
  trap 'rm -rf "$EXAMPLE_ROOT"' EXIT
  SITE_ROOT="$EXAMPLE_ROOT/site"
  TOOLS_ROOT="$EXAMPLE_ROOT/tools-apart"
  write_example_folders
  expect_complete_sheet_accepted || failed=1
  for entry in "${BROKEN_COPIES[@]}"; do
    expected="${entry%% ## *}"
    what="${entry#* ## }"
    expression="${what#* ## }"
    what="${what%% ## *}"
    expect_problem "$expected" "$what" "$(sed "$expression" <<<"$COMPLETE_SHEET")" || failed=1
  done
  expect_missing_sheet_named || failed=1
  return "$failed"
}

main "$@"
