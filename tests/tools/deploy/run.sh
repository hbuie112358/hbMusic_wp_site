#!/usr/bin/env bash
# Tests bin/deploy (template plan 1.4d-1, 1.4d-2) on known situations, run by bin/check every
# time: for each situation in scenarios/, its exit status, what its output names, what it copied
# where and in which order, and what the stand-in servers hold afterwards. The real script runs in
# a throwaway Git repository of its own, with the files it reads, the neutral valid site.json
# example (theme example-child, own plugin example-plugin) and one downloaded plugin,
# example-download 1.1.0, cloned from a throwaway "GitHub" (a bare repository). GitHub, the
# servers, the Composer build and WordPress.org's checksums are stand-ins (fakes/), first on the
# search path, checked before each run. Nothing goes over the network. Needs bash, git and jq.
#
# Each stand-in server has the folders a key's settings would name (example-download,
# example-plugin, example-child, deploy-note); example-plugin and example-child hold an old file
# that a copy must remove, and example-download holds version 1.0.0 unless the situation says
# otherwise.
#
# Each situation has two commits on main, A and then B, made fresh, so it names them as {A} and
# {B} (in full) or {A7} and {B7} (the first 7 characters); {H} is a merged pull request's last
# commit, made beside main, and {C} a commit only in the local repository. Its fields:
# description; place; options (bin/deploy's, after the place); checks ({commit: [[name,
# conclusion], ...]}, in the order they ran); pullRequest ({holds: [commits], number, sameFiles,
# checks}); notes ({short name: commit or text}, the note on each stand-in server); unreachable
# (short names that do not answer); githubDown; workingCopy ("modified" or "untracked");
# noDeploySection; noStaging; answer (typed at the question, "yes" when left out); missingTool;
# sshConfigFile (a file made in the situation's folder and passed with --ssh-config); workingCopy
# "broken" (an index git cannot read); expectSshNaming (text the ssh command must hold, {work}
# for the situation's folder); serverPluginVersion ({short name: version} of example-download
# there, "" for an empty folder); missingFolders (["<short name>/<folder>"]); tamperDownloaded;
# buildFails; checksumsUnavailable; copyFailsAt (a folder whose copy fails); interruptAt (a folder
# during whose copy bin/deploy is interrupted);
# expectStatus; expectOutputNaming; expectWrites (every copy, in order, "<short name>::<folder>",
# [] for none); expectServerFiles ({"<short name>/<folder>/<file>": text it holds});
# expectServerLacking ({"<short name>/<folder>/<file>": text it must not hold}); expectServerMissing
# (["<short name>/<folder>/<file>"]).
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"
readonly HERE REPO_ROOT
readonly VALID_SITE_SETTINGS="$REPO_ROOT/tests/tools/site-settings/valid.json"
readonly DOWNLOADED_PLUGIN="example-download"
readonly PINNED_VERSION="1.1.0"
readonly SERVER_FOLDERS=(example-download example-plugin example-child deploy-note)
# shellcheck source=tests/tools/deploy/fakes/plugin-files.sh
source "$HERE/fakes/plugin-files.sh"
TEST_ROOT=""

log() { printf '%s [deploy tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
in_git() { git -c user.name=Test -c user.email=test@example.invalid -c init.defaultBranch=main "$@"; }

# The site's repository as bin/deploy sees it: its tools, its site.json, two commits on main.
make_repository() {
  local work="$1" scenario="$2"
  in_git init -q --bare "$work/origin.git"
  in_git init -q "$work/repo"
  mkdir -p "$work/repo/bin" "$work/repo/tools"
  cp "$REPO_ROOT/bin/deploy" "$work/repo/bin/"
  cp "$REPO_ROOT/tools/site-settings.sh" "$REPO_ROOT/tools/site-settings.jq" \
    "$REPO_ROOT/tools/site-packages.sh" "$REPO_ROOT/tools/versions.sh" "$work/repo/tools/"
  site_settings_for "$scenario" >"$work/repo/site.json"
  write_site_code "$work/repo"
  in_git -C "$work/repo" add -A && in_git -C "$work/repo" commit -qm "A: the site"
  printf 'a change\n' >"$work/repo/change.txt"
  printf '/* B */\n' >>"$work/repo/themes/example-child/style.css"
  in_git -C "$work/repo" add -A && in_git -C "$work/repo" commit -qm "B: a change"
  in_git -C "$work/repo" remote add origin "$work/origin.git"
  in_git -C "$work/repo" push -q origin main
}

# The site's own theme and plugin, and site-packages/ pinning the downloaded plugin.
write_site_code() {
  local repo="$1"
  mkdir -p "$repo/themes/example-child" "$repo/plugins/example-plugin" "$repo/site-packages"
  printf '/* Theme Name: Example Child */\n' >"$repo/themes/example-child/style.css"
  printf '<?php\n/**\n * Plugin Name: Example Plugin\n */\n' >"$repo/plugins/example-plugin/example-plugin.php"
  printf '{"require": {"wpackagist-plugin/%s": "%s"}}\n' "$DOWNLOADED_PLUGIN" "$PINNED_VERSION" >"$repo/site-packages/composer.json"
  jq -n --arg slug "$DOWNLOADED_PLUGIN" --arg version "$PINNED_VERSION" '{packages: [{
    name: "wpackagist-plugin/\($slug)", version: $version, type: "wordpress-plugin",
    dist: {type: "zip", url: "https://downloads.wordpress.org/plugin/\($slug).\($version).zip"}}]}' >"$repo/site-packages/composer.lock"
}

site_settings_for() {
  local scenario="$1"
  jq --slurpfile situation "$scenario" '
    if $situation[0].noDeploySection then del(.deploy)
    elif $situation[0].noStaging then del(.deploy.staging) else . end' "$VALID_SITE_SETTINGS"
}

# {H}: a pull request's last commit beside main, with B's files or with one more; {C}: local only.
make_side_commits() {
  local work="$1" scenario="$2" tree a
  tree="$(git -C "$work/repo" rev-parse 'HEAD^{tree}')" a="$(git -C "$work/repo" rev-parse HEAD~1)"
  # Compared with false itself: jq's // would replace a false with the default.
  if [[ "$(jq -r '.pullRequest.sameFiles == false' "$scenario")" == true ]]; then
    tree="$(printf '100644 blob %s\tother.txt\n' "$(printf 'other\n' | git -C "$work/repo" hash-object -w --stdin)" |
      cat - <(git -C "$work/repo" ls-tree HEAD) | git -C "$work/repo" mktree)"
  fi
  in_git -C "$work/repo" commit-tree "$tree" -p "$a" -m "H: the pull request's last commit" >"$work/H"
  printf 'local only\n' >"$work/repo/local.txt"
  in_git -C "$work/repo" add -A && in_git -C "$work/repo" commit -qm "C: not pushed"
  git -C "$work/repo" rev-parse HEAD >"$work/C"
  in_git -C "$work/repo" reset -q --hard origin/main
}

# The situation with {A}, {B}, {H}, {C} and their short forms replaced by the commits made.
resolve_commit_names() {
  local work="$1" scenario="$2" a b h c
  a="$(git -C "$work/repo" rev-parse main~1)" b="$(git -C "$work/repo" rev-parse main)"
  h="$(cat "$work/H")" c="$(cat "$work/C")"
  sed -e "s/{A}/$a/g; s/{B}/$b/g; s/{H}/$h/g; s/{C}/$c/g" \
    -e "s/{A7}/${a:0:7}/g; s/{B7}/${b:0:7}/g; s/{H7}/${h:0:7}/g; s/{C7}/${c:0:7}/g" "$scenario" >"$work/situation.json"
}

# GitHub's answers: check runs with rising ids in the order listed, the pull request's links, trees.
write_github() {
  local work="$1" h
  local situation="$work/situation.json"
  h="$(cat "$work/H")"
  jq --arg h "$h" --arg h_tree "$(git -C "$work/repo" rev-parse "$h^{tree}")" '
    { isDown: (.githubDown // false),
      checks: ((.checks // {}) + (if .pullRequest then {($h): .pullRequest.checks} else {} end)
        | map_values([to_entries[] | {id: (.key + 1), name: .value[0], conclusion: .value[1], status: "completed"}])),
      pulls: (if .pullRequest then .pullRequest as $pull
        | [$pull.holds[] | {(.): [{number: $pull.number, merged_at: "2026-01-01T00:00:00Z", base: {ref: "main"}, head: {sha: $h}}]}] | add
        else {} end),
      trees: {($h): $h_tree} }' "$situation" >"$work/services/github.json"
}

# The folders each stand-in server's key may reach, with what they hold before the deploy.
write_server_folders() {
  local work="$1" ssh_host folder version
  local situation="$work/situation.json" server="$work/services/server"
  for ssh_host in example-staging example-live; do
    for folder in "${SERVER_FOLDERS[@]}"; do
      jq -e --arg missing "$ssh_host/$folder" '(.missingFolders // []) | index($missing)' "$situation" >/dev/null && continue
      mkdir -p "$server/$ssh_host/$folder"
    done
    for folder in example-plugin example-child; do
      [[ -d "$server/$ssh_host/$folder" ]] && printf 'old\n' >"$server/$ssh_host/$folder/old.txt"
    done
    version="$(jq -r --arg host "$ssh_host" '.serverPluginVersion[$host] // "1.0.0"' "$situation")"
    [[ -z "$version" || ! -d "$server/$ssh_host/$DOWNLOADED_PLUGIN" ]] ||
      write_plugin_files "$server/$ssh_host/$DOWNLOADED_PLUGIN" "$DOWNLOADED_PLUGIN" "$version"
  done
}

# WordPress.org's checksum file for the pinned release, from the same files the build writes.
write_checksums() {
  local work="$1" release="$TEST_ROOT/release-files"
  jq -e '.checksumsUnavailable // false' "$work/situation.json" >/dev/null && return 0
  rm -rf "$release" && write_plugin_files "$release" "$DOWNLOADED_PLUGIN" "$PINNED_VERSION"
  mkdir -p "$work/services/checksums/$DOWNLOADED_PLUGIN"
  write_checksum_file "$release" "$DOWNLOADED_PLUGIN" "$PINNED_VERSION" >"$work/services/checksums/$DOWNLOADED_PLUGIN/$PINNED_VERSION.json"
}

write_servers() {
  local work="$1" ssh_host note
  local situation="$work/situation.json"
  cp "$situation" "$work/services/situation.json"
  write_server_folders "$work"
  write_checksums "$work"
  while IFS=$'\t' read -r ssh_host note; do
    mkdir -p "$work/services/server/$ssh_host/deploy-note"
    printf '%s\n' "$note" >"$work/services/server/$ssh_host/deploy-note/deployed-commit"
  done < <(jq -r '.notes // {} | to_entries[] | "\(.key)\t\(.value)"' "$situation")
  jq -r '.unreachable // [] | .[]' "$situation" >"$work/services/unreachable.txt"
}

change_working_copy() {
  local work="$1" kind
  kind="$(jq -r '.workingCopy // "clean"' "$work/situation.json")"
  case "$kind" in
    modified) printf 'edited\n' >>"$work/repo/change.txt" ;;
    untracked) printf 'new\n' >"$work/repo/untracked.txt" ;;
    # An index Git cannot read, so git status itself fails.
    broken) printf 'not an index\n' >"$work/repo/.git/index" ;;
  esac
}

# The SSH settings file the situation passes with --ssh-config, made in its folder under the
# name it gives; nothing when it names none.
ssh_config_options() {
  local work="$1" name
  name="$(jq -r '.sshConfigFile // empty' "$work/situation.json")"
  [[ -n "$name" ]] || return 0
  printf '# stand-in SSH settings\n' >"$work/$name"
  printf '%s\n' --ssh-config "$work/$name"
}

# A folder of links to every command on the search path but one, for a computer without it.
search_path_without() {
  local tool="$1" folder="$TEST_ROOT/without-$1" directory command_path name directories=()
  [[ -d "$folder" ]] || {
    mkdir -p "$folder"
    IFS=: read -ra directories <<<"$HERE/fakes:$PATH"
    for directory in "${directories[@]}"; do
      for command_path in "$directory"/*; do
        name="${command_path##*/}"
        [[ -x "$command_path" && "$name" != "$tool" && ! -e "$folder/$name" ]] && ln -s "$command_path" "$folder/$name"
      done
    done
  }
  printf '%s' "$folder"
}

search_path_for() {
  local situation="$1" missing tool
  missing="$(jq -r '.missingTool // empty' "$situation")"
  [[ -z "$missing" ]] || { search_path_without "$missing"; return; }
  for tool in gh rsync docker curl; do
    [[ "$(PATH="$HERE/fakes:$PATH" command -v "$tool")" == "$HERE/fakes/$tool" ]] ||
      { log "the stand-in $tool is not first on the search path; nothing run"; exit 1; }
  done
  printf '%s' "$HERE/fakes:$PATH"
}

run_deploy() {
  local work="$1" options=() search_path
  local situation="$work/situation.json"
  mapfile -t options < <(jq -r '.options // [] | .[]' "$situation"; ssh_config_options "$work")
  search_path="$(search_path_for "$situation")" || exit 1
  jq -r '.answer // "yes"' "$situation" |
    env -u GH_TOKEN -u GITHUB_TOKEN PATH="$search_path" FAKE_SERVICES_DIR="$work/services" \
      bash "$work/repo/bin/deploy" "$(jq -r '.place' "$situation")" "${options[@]}" >"$work/output.txt" 2>&1
}

outcome_problems() {
  local work="$1" status="$2" expected naming
  local situation="$work/situation.json"
  expected="$(jq -r '.expectStatus' "$situation")"
  [[ "$status" == "$expected" ]] || printf 'exit status %s, expected %s\n' "$status" "$expected"
  while IFS= read -r naming; do
    grep -qF -- "$naming" "$work/output.txt" || printf 'its output does not name %s\n' "$naming"
  done < <(jq -r '.expectOutputNaming // [] | .[]' "$situation")
  while IFS= read -r naming; do
    naming="${naming//\{work\}/$work}"
    grep -qF -- "$naming" "$work/services/remote-shells.txt" 2>/dev/null || printf 'ssh was not run with %s\n' "$naming"
  done < <(jq -r '.expectSshNaming // [] | .[]' "$situation")
  server_problems "$work"
}

# What was copied where, in order, and what the stand-in servers hold afterwards.
server_problems() {
  local work="$1" expected written file text
  local situation="$work/situation.json" server="$work/services/server"
  if jq -e 'has("expectWrites")' "$situation" >/dev/null; then
    expected="$(jq -r '.expectWrites[]' "$situation")"
    written="$(cat "$work/services/writes.txt" 2>/dev/null || true)"
    [[ "$written" == "$expected" ]] || printf 'copied [%s], expected [%s]\n' "${written//$'\n'/, }" "${expected//$'\n'/, }"
  fi
  while IFS=$'\t' read -r file text; do
    grep -qF -- "$text" "$server/$file" 2>/dev/null || printf '%s does not hold %s\n' "$file" "$text"
  done < <(jq -r '.expectServerFiles // {} | to_entries[] | "\(.key)\t\(.value)"' "$situation")
  while IFS=$'\t' read -r file text; do
    ! grep -qF -- "$text" "$server/$file" 2>/dev/null || printf '%s still holds %s\n' "$file" "$text"
  done < <(jq -r '.expectServerLacking // {} | to_entries[] | "\(.key)\t\(.value)"' "$situation")
  while IFS= read -r file; do
    [[ ! -e "$server/$file" ]] || printf '%s is still on the server\n' "$file"
  done < <(jq -r '.expectServerMissing // [] | .[]' "$situation")
}

# The repository, the stand-in GitHub and servers, and the working copy, as the situation says.
set_up_situation() {
  local work="$1" scenario="$2"
  make_repository "$work" "$scenario" &&
    make_side_commits "$work" "$scenario" &&
    resolve_commit_names "$work" "$scenario" &&
    write_github "$work" &&
    write_servers "$work" &&
    change_working_copy "$work"
}

test_scenario() {
  local scenario="$1" work status problems name
  name="$(basename "$scenario" .json)"
  work="$(mktemp -d "$TEST_ROOT/$name.XXXXXX")"
  mkdir -p "$work/services"
  if ! set_up_situation "$work" "$scenario"; then
    log "FAIL  $name: could not set the situation up"
    return 1
  fi
  run_deploy "$work"
  status=$?
  problems="$(outcome_problems "$work" "$status")"
  [[ -z "$problems" ]] && { log "ok    $name"; return 0; }
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
  for scenario in "$HERE"/scenarios/*.json; do
    [[ -f "$scenario" ]] || continue
    count=$((count + 1))
    test_scenario "$scenario" || failed=1
  done
  ((count > 0)) || { log "no situations found in $HERE/scenarios/"; return 1; }
  return "$failed"
}

main "$@"
