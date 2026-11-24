#!/usr/bin/env bash
# Tests the page check (bin/site-check, template plan 1.4b) on known situations, run by bin/check
# every time: for each situation in scenarios/, its exit status, what its output names, and which
# addresses it asked for. The real script runs, copied with the files it reads into a folder of its
# own, whose site.json is the neutral valid example of the site.json checks (theme
# "example-child"). The site is a stand-in for curl (fakes/), first on the search path, checked
# before each run, so nothing goes over the network. Needs bash and jq.
#
# A situation's fields: description; address (the site's, https://site.test when left out);
# options (bin/site-check's, "--deadline 0" when left out, so a failure is reported at once); login (SITE_CHECK_USER and SITE_CHECK_PASSWORD to set); the site
# (pageList, pages, siteRequiresLogin, as fakes/curl reads them); curlMissing (run with every
# command but curl, and no stand-in); expectStatus; expectOutputNaming;
# expectNotAsked (addresses that must never be asked for); expectAskedTimes ({address: count});
# expectAskedAtLeast ({address: count}, where the exact number depends on timing); expectStdout (the
# lines printed on standard output, exactly; left out: nothing).
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$(cd "$HERE/../../.." && pwd)"
readonly HERE TOOLS_DIR
readonly VALID_SITE_SETTINGS="$TOOLS_DIR/tests/tools/site-settings/valid.json"
TEST_ROOT=""

log() { printf '%s [site-check tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

copy_site_check() {
  local root="$1"
  mkdir -p "$root/bin" "$root/tools"
  cp "$TOOLS_DIR/bin/site-check" "$root/bin/"
  cp "$TOOLS_DIR/tools/paths.sh" "$TOOLS_DIR/tools/site-settings.sh" "$TOOLS_DIR/tools/site-settings.jq" "$root/tools/"
  cp "$VALID_SITE_SETTINGS" "$root/site.json"
}

# The login variables the situation sets, as env arguments; none are inherited from the caller.
login_environment() {
  local scenario="$1"
  jq -r '.login // {} | to_entries[] | "\(.key)=\(.value)"' "$scenario"
}

# A folder of links to every command on the search path except curl, for the situation of a
# computer without curl; made once per run.
make_search_path_without_curl() {
  local folder="$1" directory command_path name directories=()
  mkdir -p "$folder"
  IFS=: read -ra directories <<<"$PATH"
  for directory in "${directories[@]}"; do
    for command_path in "$directory"/*; do
      name="${command_path##*/}"
      [[ -x "$command_path" && "$name" != curl && ! -e "$folder/$name" ]] && ln -s "$command_path" "$folder/$name"
    done
  done
  return 0
}

# The search path for a situation: the stand-in curl first, or no curl at all.
search_path_for() {
  local scenario="$1" stand_in
  if [[ "$(jq -r '.curlMissing // false' "$scenario")" == true ]]; then
    printf '%s' "$TEST_ROOT/no-curl"
    return
  fi
  stand_in="$(PATH="$HERE/fakes:$PATH" command -v curl)"
  [[ "$stand_in" == "$HERE/fakes/curl" ]] || { log "the stand-in curl is not first on the search path ($stand_in); nothing run"; exit 1; }
  printf '%s' "$HERE/fakes:$PATH"
}

run_site_check() {
  local scenario="$1" work="$2" options=() login=() search_path
  mapfile -t options < <(jq -r '(.options // ["--deadline", "0"])[]' "$scenario")
  mapfile -t login < <(login_environment "$scenario")
  search_path="$(search_path_for "$scenario")" || exit 1
  env -u SITE_CHECK_USER -u SITE_CHECK_PASSWORD PATH="$search_path" FAKE_SITE_DIR="$work/site" "${login[@]}" \
    bash "$work/repo/bin/site-check" "${options[@]}" "$(jq -r '.address // "https://site.test"' "$scenario")" >"$work/stdout.txt" 2>"$work/stderr.txt"
  local status=$?
  cat "$work/stderr.txt" "$work/stdout.txt" >"$work/output.txt"
  return "$status"
}

# What the run printed on standard output, exactly: the list --print-pages gives, and nothing at
# all otherwise, since the log goes to standard error and the list may be piped on.
stdout_problems() {
  local scenario="$1" work="$2" expected
  expected="$(jq -r '.expectStdout // [] | .[]' "$scenario")"
  [[ "$(cat "$work/stdout.txt")" == "$expected" ]] && return 0
  printf 'standard output was "%s", expected "%s"\n' "$(paste -sd ' ' "$work/stdout.txt")" "$(paste -sd ' ' <<<"$expected")"
}

# No requests file means nothing was asked for at all.
asked_times() {
  local work="$1" address="$2"
  [[ -f "$work/site/requests.txt" ]] || { printf '0'; return; }
  grep -cxF -- "$address" "$work/site/requests.txt" || true
}

# The problems with one situation's outcome, one per line; nothing when it is as expected.
outcome_problems() {
  local scenario="$1" work="$2" status="$3" expected naming address count
  expected="$(jq -r '.expectStatus' "$scenario")"
  [[ "$status" == "$expected" ]] || printf 'exit status %s, expected %s\n' "$status" "$expected"
  stdout_problems "$scenario" "$work"
  while IFS= read -r naming; do
    grep -qF -- "$naming" "$work/output.txt" || printf 'its output does not name %s\n' "$naming"
  done < <(jq -r '.expectOutputNaming // [] | .[]' "$scenario")
  while IFS= read -r address; do
    [[ "$(asked_times "$work" "$address")" == 0 ]] || printf 'it asked for %s, which it must never open\n' "$address"
  done < <(jq -r '.expectNotAsked // [] | .[]' "$scenario")
  while IFS=$'\t' read -r address count; do
    [[ "$(asked_times "$work" "$address")" == "$count" ]] || printf 'it asked for %s %s time(s), expected %s\n' "$address" "$(asked_times "$work" "$address")" "$count"
  done < <(jq -r '.expectAskedTimes // {} | to_entries[] | "\(.key)\t\(.value)"' "$scenario")
  # A lower bound where the exact number depends on how many tries fit before a deadline.
  while IFS=$'\t' read -r address count; do
    (($(asked_times "$work" "$address") >= count)) || printf 'it asked for %s %s time(s), expected at least %s\n' "$address" "$(asked_times "$work" "$address")" "$count"
  done < <(jq -r '.expectAskedAtLeast // {} | to_entries[] | "\(.key)\t\(.value)"' "$scenario")
}

test_scenario() {
  local scenario="$1" work status problems name
  name="$(basename "$scenario" .json)"
  work="$(mktemp -d "$TEST_ROOT/$name.XXXXXX")"
  copy_site_check "$work/repo"
  mkdir -p "$work/site/counts"
  cp "$scenario" "$work/site/scenario.json"
  run_site_check "$scenario" "$work"
  status=$?
  problems="$(outcome_problems "$scenario" "$work" "$status")"
  if [[ -z "$problems" ]]; then
    log "ok    $name"
    return 0
  fi
  log "FAIL  $name: $(jq -r '.description' "$scenario")"
  log "$problems"
  sed 's/^/        /' "$work/output.txt" >&2
  return 1
}

remove_test_root() {
  [[ -n "$TEST_ROOT" ]] && rm -rf "$TEST_ROOT"
  return 0
}

main() {
  local scenario failed=0 count=0
  TEST_ROOT="$(mktemp -d)"
  trap remove_test_root EXIT
  trap 'exit 130' INT TERM
  make_search_path_without_curl "$TEST_ROOT/no-curl"
  for scenario in "$HERE"/scenarios/*.json; do
    [[ -f "$scenario" ]] || continue
    count=$((count + 1))
    test_scenario "$scenario" || failed=1
  done
  ((count > 0)) || { log "no situations found in $HERE/scenarios/"; return 1; }
  return "$failed"
}

main "$@"
