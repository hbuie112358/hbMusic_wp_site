#!/usr/bin/env bash
# The routines' two files kept in step (template plan 1.5c): docs/ROUTINES.md, the same for every
# site, links each site's detail to a heading of docs/SITE_SPECIFIC_ROUTINES.md as
# "SITE_SPECIFIC_ROUTINES.md#<anchor>". Sourced by bin/check and tested on known examples by
# tests/tools/routines/run.sh. Needs bash, grep, sed and sort.

readonly ROUTINES_LINK_PATTERN='SITE_SPECIFIC_ROUTINES\.md#[a-z0-9-]+'

# A level-two heading's anchor as GitHub writes it: lower case, every character other than a
# letter, digit, space or dash dropped, each space a dash. So "Deploy keys (SSH)" is
# "deploy-keys-ssh" and "Plugins & theme" is "plugins--theme"; a link written by hand from the
# heading's words then finds it on GitHub too.
routines_heading_anchor() {
  tr '[:upper:]' '[:lower:]' <<<"$1" | sed 's/[^a-z0-9 -]//g; s/ /-/g'
}

# The anchors of the file's "## " headings, one per line; a "## " line inside a ``` block is an
# example, not a heading.
routines_site_anchors() {
  local site_file="$1" line fence_lines_seen=0
  while IFS= read -r line; do
    if [[ "$line" == '```'* ]]; then
      fence_lines_seen=$((fence_lines_seen + 1))
    elif ((fence_lines_seen % 2 == 0)) && [[ "$line" == '## '* ]]; then
      routines_heading_anchor "${line#\#\# }"
    fi
  done <"$site_file"
}

# The anchors the routines file links to, one per line.
routines_linked_anchors() {
  grep -oE "$ROUTINES_LINK_PATTERN" "$1" | sed 's/.*#//'
}

# Prints one line per difference, nothing when the two files agree: a link with no heading, a
# heading no link reaches, or a file that is missing.
routines_link_differences() {
  local routines_file="$1" site_file="$2" anchors links
  [[ -f "$routines_file" ]] || { printf 'missing file: %s\n' "${routines_file##*/}"; return 0; }
  [[ -f "$site_file" ]] || { printf 'missing file: %s\n' "${site_file##*/}"; return 0; }
  anchors="$(routines_site_anchors "$site_file" | sort -u)"
  links="$(routines_linked_anchors "$routines_file" | sort -u)"
  comm -13 <(printf '%s\n' "$anchors") <(printf '%s\n' "$links") | sed '/^$/d; s/^/linked but no such heading: #/'
  comm -23 <(printf '%s\n' "$anchors") <(printf '%s\n' "$links") | sed '/^$/d; s/^/heading with no link: #/'
}
