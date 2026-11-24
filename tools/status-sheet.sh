#!/usr/bin/env bash
# The status sheet held to the site standard (template plan 1.5d-4): a site's records/status.md
# against the blank sheet, tools/status-sheet-blank.md, which lists every item of the handbook's
# chapter 12. Sourced by bin/check and tested on known examples by tests/tools/status-sheet/run.sh.
# Needs bash, awk, grep and sort.
#
# A row is "| <item> <short name> | <status> | <how it was checked> | <date> |". The sheet is
# complete when every item of the blank is there once and nothing else is; an item the blank marks
# retired stays "retired", every other one is "done" or "exception" with its check or reason and
# a date; an exception's link to a recorded exception ([E4](exceptions.md#e4)) finds its heading;
# and every file a row names still exists, in the repository or the tools' folder, so a renamed or
# deleted test cannot leave the sheet pointing at nothing.

readonly STATUS_SHEET_ROW='^\| [0-9]+\.[0-9]+[ |]'
readonly STATUS_SHEET_DATE='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
readonly STATUS_SHEET_SEPARATOR=$'\037'
# The repository's own folders: a name in backticks starting with one of them is a path that
# must exist. A test file named alone (`theme.spec.ts`, `dev-site-check.sh`) must exist under
# tests/. Other names in backticks (settings, commands, addresses) are not files.
readonly STATUS_SHEET_PATH_PREFIX='^(bin|tools|tests|plugins|themes|records|docs|config|site-packages)/'
readonly STATUS_SHEET_TEST_NAME='^([a-z0-9-]+\.spec\.ts|dev-[a-z0-9-]+\.sh)$'

# Each row as item, status, check and date, the cells trimmed, separated by the ASCII unit
# separator: a tab is whitespace to read, which would merge an empty cell into the next one. The
# pattern reaches awk through its environment: awk -v would turn its "\|" into "|", which matches
# every line.
status_sheet_rows() {
  STATUS_SHEET_ROW_PATTERN="$STATUS_SHEET_ROW" awk -F'|' '
    function trim(text) { gsub(/^[ \t]+|[ \t]+$/, "", text); return text }
    $0 ~ ENVIRON["STATUS_SHEET_ROW_PATTERN"] {
      split(trim($2), item, " "); print item[1] "\037" trim($3) "\037" trim($4) "\037" trim($5)
    }
  ' "$1"
}

# The items both lists hold, and those only one does.
status_sheet_item_problems() {
  local sheet="$1" blank="$2" sheet_items blank_items
  sheet_items="$(status_sheet_rows "$sheet" | cut -d "$STATUS_SHEET_SEPARATOR" -f1 | sort)"
  blank_items="$(status_sheet_rows "$blank" | cut -d "$STATUS_SHEET_SEPARATOR" -f1 | sort)"
  comm -13 <(sort -u <<<"$sheet_items") <(printf '%s\n' "$blank_items") | sed '/^$/d; s/^/missing item: /'
  comm -23 <(sort -u <<<"$sheet_items") <(printf '%s\n' "$blank_items") | sed '/^$/d; s/^/not an item of the standard: /'
  uniq -d <<<"$sheet_items" | sed '/^$/d; s/^/listed twice: /'
}

# One row's status, check and date, against whether the blank retires its item.
status_sheet_row_problem() {
  local item="$1" status="$2" check="$3" date="$4" is_retired="$5"
  if [[ "$is_retired" == true ]]; then
    [[ "$status" == retired ]] || printf '%s: retired in the standard, so its status is "retired"\n' "$item"
    return 0
  fi
  [[ "$status" == done || "$status" == exception ]] || { printf '%s: status "%s", not done or exception\n' "$item" "$status"; return 0; }
  [[ -n "$check" ]] || printf '%s: %s with no check or reason\n' "$item" "$status"
  [[ "$date" =~ $STATUS_SHEET_DATE ]] || printf '%s: no date (YYYY-MM-DD)\n' "$item"
}

# Each recorded exception a row links to must have its heading in the exceptions record.
status_sheet_exception_problems() {
  local item="$1" check="$2" exceptions="$3" number
  while IFS= read -r number; do
    grep -qxF "## E$number" "$exceptions" 2>/dev/null ||
      printf '%s: links E%s, which %s does not have\n' "$item" "$number" "${exceptions##*/}"
  done < <(grep -oE '\[E[0-9]+\]\(exceptions\.md#e[0-9]+\)' <<<"$check" | grep -oE '#e[0-9]+' | tr -d '#e')
}

# Whether a path, which may hold a * standing for one folder, exists in either folder.
status_sheet_path_exists() {
  local name="$1" project_root="$2" tools_root="$3"
  compgen -G "$project_root/$name" >/dev/null || compgen -G "$tools_root/$name" >/dev/null
}

# Whether a test file named alone is under either folder's tests/.
status_sheet_test_exists() {
  local name="$1" project_root="$2" tools_root="$3"
  [[ -n "$(find "$project_root/tests" "$tools_root/tests" -name "$name" -print -quit 2>/dev/null)" ]]
}

# Every path or test file in backticks must exist, in the site's repository or in the tools' folder
# (template plan T19): the sheet names both, and the two are apart once the tools are installed.
status_sheet_file_problems() {
  local item="$1" check="$2" project_root="$3" tools_root="$4" name
  while IFS= read -r name; do
    if [[ "$name" =~ $STATUS_SHEET_PATH_PREFIX ]]; then
      status_sheet_path_exists "$name" "$project_root" "$tools_root" ||
        printf '%s: names %s, which does not exist\n' "$item" "$name"
    elif [[ "$name" =~ $STATUS_SHEET_TEST_NAME ]]; then
      status_sheet_test_exists "$name" "$project_root" "$tools_root" ||
        printf '%s: names %s, found nowhere under tests/\n' "$item" "$name"
    fi
  done < <(grep -oE '`[^`]+`' <<<"$check" | tr -d '`')
}

# Prints one line per problem, nothing when the sheet is complete. The files rows name are looked
# for in the site's repository (fourth argument) and the tools' folder (fifth).
status_sheet_problems() {
  local sheet="$1" blank="$2" exceptions="$3" project_root="$4" tools_root="$5" retired item status check date
  [[ -f "$sheet" ]] || { printf 'missing file: %s\n' "${sheet##*/}"; return 0; }
  [[ -f "$blank" ]] || { printf 'missing file: %s\n' "${blank##*/}"; return 0; }
  status_sheet_item_problems "$sheet" "$blank"
  retired="$(status_sheet_rows "$blank" | awk -F'\037' '$2 == "retired" { print $1 }')"
  while IFS="$STATUS_SHEET_SEPARATOR" read -r item status check date; do
    status_sheet_row_problem "$item" "$status" "$check" "$date" \
      "$(grep -qxF -- "$item" <<<"$retired" && echo true || echo false)"
    status_sheet_exception_problems "$item" "$check" "$exceptions"
    status_sheet_file_problems "$item" "$check" "$project_root" "$tools_root"
  done < <(status_sheet_rows "$sheet")
}
