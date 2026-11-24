#!/usr/bin/env bash
# Tests the routines' link check (tools/routines.sh, template plan 1.5c) on known examples, run by
# the tools' self-check every time: two files that agree pass, and each broken pair is refused,
# naming the anchor or file that is wrong. The examples are written fresh into a temporary folder,
# so nothing depends on this site's routines. Needs bash, grep, sed and sort.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HERE
# shellcheck source=tools/routines.sh
source "$HERE/../../../tools/routines.sh"

log() { printf '%s [routines tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

EXAMPLES_DIR=""

readonly AGREEING_ROUTINES='# Routines
Mail goes out (site details: [Mail](SITE_SPECIFIC_ROUTINES.md#mail)); keys are unlocked
([Deploy keys (SSH)](SITE_SPECIFIC_ROUTINES.md#deploy-keys-ssh)); see also
[Plugins & theme](SITE_SPECIFIC_ROUTINES.md#plugins--theme) and [Mail](SITE_SPECIFIC_ROUTINES.md#mail) again.'
readonly AGREEING_SITE_DETAILS='# This site
## Mail
The inbox.
## Deploy keys (SSH)
The keys.
## Plugins & theme
```
## Not a heading, an example inside a code block
```'

# expected problem ## what the example breaks ## routines text ## site details text
# (" ## " separates the parts; the texts use "\n" for line ends.)
readonly BROKEN_EXAMPLES=(
  "linked but no such heading: #mail ## a link whose heading is gone ## [Mail](SITE_SPECIFIC_ROUTINES.md#mail) ## # Site\n## Inbox"
  "linked but no such heading: #deploy-keys ## a link written without the heading's brackets ## [Keys](SITE_SPECIFIC_ROUTINES.md#deploy-keys) ## # Site\n## Deploy keys (SSH)"
  "heading with no link: #host ## a heading nothing links to ## [Mail](SITE_SPECIFIC_ROUTINES.md#mail) ## # Site\n## Mail\n## Host"
  "heading with no link: #host ## a link only inside the site details file itself ## [Mail](SITE_SPECIFIC_ROUTINES.md#mail) ## # Site\n## Mail\n## Host\nsee [Host](SITE_SPECIFIC_ROUTINES.md#host)"
  "linked but no such heading: #example ## a heading only inside a code block ## [Ex](SITE_SPECIFIC_ROUTINES.md#example) ## # Site\n\`\`\`\n## Example\n\`\`\`"
)

write_example() {
  printf '%b\n' "$2" >"$EXAMPLES_DIR/ROUTINES.md"
  printf '%b\n' "$3" >"$EXAMPLES_DIR/SITE_SPECIFIC_ROUTINES.md"
  [[ "$1" == keep-both ]] || rm -f "$EXAMPLES_DIR/$1"
}

differences_of_example() {
  routines_link_differences "$EXAMPLES_DIR/ROUTINES.md" "$EXAMPLES_DIR/SITE_SPECIFIC_ROUTINES.md"
}

expect_agreement() {
  local differences
  write_example keep-both "$AGREEING_ROUTINES" "$AGREEING_SITE_DETAILS"
  differences="$(differences_of_example)"
  [[ -z "$differences" ]] && { log "ok    two files that agree"; return 0; }
  log "FAIL  two files that agree were refused: $differences"
  return 1
}

# The difference must be named exactly, as one of the lines printed.
expect_problem() {
  local expected="$1" what="$2" differences
  differences="$(differences_of_example)"
  grep -qxF "$expected" <<<"$differences" && { log "ok    $what"; return 0; }
  log "FAIL  $what: expected \"$expected\", got: ${differences:-nothing}"
  return 1
}

main() {
  local entry expected what rest routines_text site_text missing failed=0
  EXAMPLES_DIR="$(mktemp -d)"
  trap 'rm -rf "$EXAMPLES_DIR"' EXIT
  expect_agreement || failed=1
  for entry in "${BROKEN_EXAMPLES[@]}"; do
    expected="${entry%% ## *}"
    rest="${entry#* ## }"
    what="${rest%% ## *}"
    rest="${rest#* ## }"
    routines_text="${rest%% ## *}"
    site_text="${rest#* ## }"
    write_example keep-both "$routines_text" "$site_text"
    expect_problem "$expected" "$what" || failed=1
  done
  for missing in ROUTINES.md SITE_SPECIFIC_ROUTINES.md; do
    write_example "$missing" "$AGREEING_ROUTINES" "$AGREEING_SITE_DETAILS"
    expect_problem "missing file: $missing" "$missing missing" || failed=1
  done
  return "$failed"
}

main "$@"
