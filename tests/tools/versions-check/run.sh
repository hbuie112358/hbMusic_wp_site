#!/usr/bin/env bash
# Tests the versions check's alerts (bin/versions-check, template plan 1.3c): for each situation in
# scenarios/, which issues it would open, run by the tools' self-check every time. The real script
# runs, copied with the files it reads into a folder of its own whose lock file holds one neutral
# plugin (composer.lock here), so nothing depends on the site's own plugins. GitHub, WordPress.org
# and Alpine's package list (1.4d-4) are stand-ins (fakes/), answering from files written for each
# situation, with its dates counted back from now: the script itself is not changed for the test.
# Needs bash, jq and tar.
#
# The real gh must never be reached, since --act opens issues: the stand-ins come first on the
# search path, which is checked before every run, and the run has no GitHub login (an empty gh
# configuration, no token) and no repository around it.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$(cd "$HERE/../../.." && pwd)"
readonly HERE TOOLS_DIR
# Every situation's folder, removed when the run ends, also when it is interrupted.
TEST_ROOT=""
# The script's pins at their pinned versions, as JSON (pinned_versions), read once in main.
PINNED_VERSIONS=""
# The test server's packages at their pinned versions, "package|version" a line, and the Alpine
# branch of the pinned image (test_server_pins, alpine_branch), read once in main.
TEST_SERVER_PINS=""
ALPINE_BRANCH=""
# The words before the failed parts' list in the script's last message, read from the script.
FAILED_PARTS_INTRODUCTION=""
readonly PLUGIN_SLUG="example-plugin"
readonly PLUGIN_PINNED="1.0.0"
readonly PLUGIN_NEWER="1.1.0"
# Long past any wait, for a release that is current.
readonly SETTLED_DAYS=30

log() { printf '%s [versions-check tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

# The versions check and the files it reads, in a folder of its own.
copy_versions_check() {
  local root="$1"
  mkdir -p "$root/bin" "$root/tools" "$root/site-packages"
  cp "$TOOLS_DIR/bin/versions-check" "$root/bin/"
  cp "$TOOLS_DIR/tools/paths.sh" "$TOOLS_DIR/tools/versions.sh" "$TOOLS_DIR/tools/site-packages.sh" "$root/tools/"
  cp "$HERE/composer.lock" "$root/site-packages/"
  # The tools beside a site.json are that site's own (tools/paths.sh); the check reads none of it.
  cp "$TOOLS_DIR/tests/tools/site-settings/valid.json" "$root/site.json"
}

# The situation's brokenPin: that variable in the copied tools/versions.sh made unusable.
break_pin() {
  local variable
  variable="$(jq -r '.brokenPin // empty' "$1")"
  [[ -n "$variable" ]] || return 0
  sed -i -E "s/^(readonly $variable=)\"[^\"]*\"$/\1\"not a version\"/" "$2"
  grep -qxF "readonly $variable=\"not a version\"" "$2" || { log "tools/versions.sh has no $variable to break"; exit 1; }
}

# Dependabot's open pull requests as GitHub reports them, opened daysOpen days (and an hour) ago.
write_pull_requests() {
  local scenario="$1" services="$2"
  jq '[.pullRequests[] | {
      number, url: "https://github.test/pull/\(.number)",
      createdAt: ((now - .daysOpen * 86400 - 3600) | todate),
      files: [.paths[] | {path: .}], mergeStateStatus: .mergeState,
      statusCheckRollup: [.checks[] | {conclusion: .}]}]' "$scenario" >"$services/pull-requests.json"
  with_pins "$(jq '[(.existingIssues // [])[] | {title: .}]' "$scenario")" >"$services/issues.json"
}

# The script's own pins (its PINS list: kind|slug|variable|name), each with the version
# tools/versions.sh pins, as {"slug": "version", ...}; read from them, so a changed pin is followed.
pinned_versions() {
  local slug variable version pins="{}"
  while IFS='|' read -r _ slug variable _; do
    version="$(pinned_in_versions_file "$variable")"
    pins="$(jq -c --arg slug "$slug" --arg version "$version" '. + {($slug): $version}' <<<"$pins")"
  done < <(listed_in_versions_check PINS)
  [[ "$pins" != "{}" ]] || { log "no pins found in bin/versions-check's PINS"; exit 1; }
  printf '%s' "$pins"
}

# The entries of one of bin/versions-check's lists (readonly NAME=( ... ), one quoted entry a line).
listed_in_versions_check() {
  sed -nE "/^readonly $1=\($/,/^\)$/s/^  \"([^\"]*)\"$/\1/p" "$TOOLS_DIR/bin/versions-check"
}

pinned_in_versions_file() {
  local version
  version="$(sed -nE "s/^readonly $1=\"([^\"]*)\"$/\1/p" "$TOOLS_DIR/tools/versions.sh")"
  [[ -n "$version" ]] || { log "tools/versions.sh pins no $1, which bin/versions-check names"; exit 1; }
  printf '%s' "$version"
}

# The script's TEST_SERVER_PACKAGES (package|variable), each with its pinned version.
test_server_pins() {
  local package variable pins=""
  while IFS='|' read -r package variable; do
    pins+="$package|$(pinned_in_versions_file "$variable")"$'\n'
  done < <(listed_in_versions_check TEST_SERVER_PACKAGES)
  [[ -n "$pins" ]] || { log "no packages found in bin/versions-check's TEST_SERVER_PACKAGES"; exit 1; }
  printf '%s' "${pins%$'\n'}"
}

alpine_branch() {
  local branch
  branch="$(sed -nE 's/^readonly DEPLOY_TEST_SERVER_BASE_IMAGE="alpine:([0-9]+\.[0-9]+)\..*$/v\1/p' "$TOOLS_DIR/tools/versions.sh")"
  [[ -n "$branch" ]] || { log "tools/versions.sh pins no Alpine image as DEPLOY_TEST_SERVER_BASE_IMAGE"; exit 1; }
  printf '%s' "$branch"
}

# Alpine's package list for the pinned image's branch: each test server package at its pinned
# version, or as the situation's "alpine" says (replaced, missing, malformed), each after a
# look-alike whose name begins with its own; or no list at all, or a file that is no archive.
write_alpine_index() {
  local scenario="$1" folder="$2/alpine/$ALPINE_BRANCH" package pinned built
  jq -e '.alpine.unanswered // false' "$scenario" >/dev/null && return 0
  mkdir -p "$folder"
  if jq -e '.alpine.notAnArchive // false' "$scenario" >/dev/null; then
    printf 'Service Unavailable\n' >"$folder/APKINDEX.tar.gz"
    return 0
  fi
  built="$(($(date -u +%s) - SETTLED_DAYS * 86400))"
  while IFS='|' read -r package pinned; do
    printf 'P:%s-doc\nV:0.0.1-r0\nt:%s\n\n' "$package" "$built"
    jq -e --arg package "$package" '.alpine.missing // [] | any(. == $package)' "$scenario" >/dev/null && continue
    printf 'C:Q1example=\nP:%s\nV:%s\nt:%s\no:%s\n\n' "$package" \
      "$(alpine_listed_version "$scenario" "$package" "$pinned")" "$built" "$package"
  done <<<"$TEST_SERVER_PINS" >"$folder/APKINDEX"
  tar -czf "$folder/APKINDEX.tar.gz" -C "$folder" APKINDEX
}

alpine_listed_version() {
  jq -r --arg package "$2" --arg pinned "$3" '
    if (.alpine.malformed // [] | any(. == $package)) then "1.0;touch planted"
    else (.alpine.replaced[$package] // $pinned) end' "$1"
}

# A situation's text with {pinned:<package>} replaced by that test server package's pinned version.
with_pins() {
  local text="$1" package version
  while IFS='|' read -r package version; do
    text="${text//"{pinned:$package}"/$version}"
  done <<<"$TEST_SERVER_PINS"
  printf '%s' "$text"
}

# WordPress.org's answers: every pin at its pinned version, the plugin at its pinned version or a
# newer one released daysOld days ago, or no answer for the plugin.
write_releases() {
  local scenario="$1" services="$2"
  jq --argjson pins "$PINNED_VERSIONS" --arg plugin "$PLUGIN_SLUG" \
    --arg pinned "$PLUGIN_PINNED" --arg newer "$PLUGIN_NEWER" --argjson settled "$SETTLED_DAYS" '
    def released(days): (now - days * 86400 - 3600) | strftime("%Y-%m-%d %I:%M%p GMT");
    ($pins | map_values({version: ., last_updated: released($settled)}))
    + if .pluginUnanswered then {}
      elif .newerPluginRelease then {($plugin): {version: $newer, last_updated: released(.newerPluginRelease.daysOld)}}
      else {($plugin): {version: $pinned, last_updated: released($settled)}} end' "$scenario" >"$services/releases.json"
}

# Runs the copied check with the stand-ins; its output goes to output.txt, its status is returned.
run_versions_check() {
  local scenario="$1" work="$2" act_option=()
  [[ "$(jq -r '.act' "$scenario")" == true ]] && act_option=(--act)
  mkdir -p "$work/gh-config"
  local stand_in
  stand_in="$(PATH="$HERE/fakes:$PATH" command -v gh)"
  [[ "$stand_in" == "$HERE/fakes/gh" ]] || { log "the stand-in gh is not first on the search path ($stand_in); nothing run"; exit 1; }
  (cd "$work" && env -u GH_TOKEN -u GITHUB_TOKEN PATH="$HERE/fakes:$PATH" GH_CONFIG_DIR="$work/gh-config" \
    FAKE_SERVICES_DIR="$work/services" bash "$work/repo/bin/versions-check" "${act_option[@]}") >"$work/output.txt" 2>&1
}

# The problems with one situation's outcome, one per line; nothing when it is as expected.
outcome_problems() {
  local scenario="$1" work="$2" status="$3" expected created naming
  expected="$(with_pins "$(jq -r '.expectedIssues[]' "$scenario")" | sort)"
  created="$(sed '/^$/d' "$work/services/created-issues.txt" 2>/dev/null | sort)"
  [[ "$created" == "$expected" ]] || printf 'issues opened: [%s], expected: [%s]\n' "${created//$'\n'/; }" "${expected//$'\n'/; }"
  if [[ "$(jq -r '.expectFailure // false' "$scenario")" == true ]]; then
    ((status != 0)) || printf 'it succeeded; expected it to fail\n'
  else
    ((status == 0)) || printf 'it failed with status %s\n' "$status"
  fi
  naming="$(with_pins "$(jq -r '.expectOutputNaming // empty' "$scenario")")"
  [[ -z "$naming" ]] || grep -qF -- "$naming" "$work/output.txt" || printf 'its output does not name %s\n' "$naming"
  failed_parts_problem "$scenario" "$work/output.txt"
}

# The parts the check named as failed, exactly the situation's expectFailedParts, in order.
failed_parts_problem() {
  local expected named="" line
  jq -e 'has("expectFailedParts")' "$1" >/dev/null || return 0
  expected="$(jq -r '.expectFailedParts | join("; ")' "$1")"
  while IFS= read -r line; do
    [[ "$line" == *"$FAILED_PARTS_INTRODUCTION"* ]] && named="${line#*"$FAILED_PARTS_INTRODUCTION"}"
  done <"$2"
  [[ "$named" == "$expected" ]] || printf 'failed parts named: [%s], expected: [%s]\n' "$named" "$expected"
}

failed_parts_introduction() {
  local introduction
  introduction="$(sed -nE 's/^readonly FAILED_PARTS_INTRODUCTION="(.+)"$/\1/p' "$TOOLS_DIR/bin/versions-check")"
  [[ -n "$introduction" ]] || { log "bin/versions-check has no FAILED_PARTS_INTRODUCTION"; exit 1; }
  printf '%s' "$introduction"
}

# One situation, in a fresh folder; prints its verdict, returns 1 if it is not as expected.
test_scenario() {
  local scenario="$1" work status problems name
  name="$(basename "$scenario" .json)"
  work="$(mktemp -d "$TEST_ROOT/$name.XXXXXX")"
  copy_versions_check "$work/repo"
  break_pin "$scenario" "$work/repo/tools/versions.sh"
  mkdir -p "$work/services"
  write_pull_requests "$scenario" "$work/services"
  write_releases "$scenario" "$work/services"
  write_alpine_index "$scenario" "$work/services"
  run_versions_check "$scenario" "$work"
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
  # Read once, here: a pin that cannot be read stops the run instead of every situation.
  PINNED_VERSIONS="$(pinned_versions)" || return 1
  TEST_SERVER_PINS="$(test_server_pins)" || return 1
  ALPINE_BRANCH="$(alpine_branch)" || return 1
  FAILED_PARTS_INTRODUCTION="$(failed_parts_introduction)" || return 1
  for scenario in "$HERE"/scenarios/*.json; do
    [[ -f "$scenario" ]] || continue
    count=$((count + 1))
    test_scenario "$scenario" || failed=1
  done
  ((count > 0)) || { log "no situations found in $HERE/scenarios/"; return 1; }
  return "$failed"
}

main "$@"
