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
# phpLogExtraFile; noPageCheckLogin; lockHeld (another deploy holding the lock); pageCheckFails,
# pageCheckAddsLogLines, logStartsAnew (played by the stand-in page check);
# expectStatus; expectOutputNaming; expectOutputLacking; expectPageCheck ("<address>\tuser=<user>\t
# password=<password>", as the stand-in records it); expectNoPageCheck; expectWrites (every copy, in order, "<short name>::<folder>",
# [] for none); expectServerFiles ({"<short name>/<folder>/<file>": text it holds});
# expectServerLacking ({"<short name>/<folder>/<file>": text it must not hold}); expectServerMissing
# (["<short name>/<folder>/<file>"]).
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$(cd "$HERE/../../.." && pwd)"
readonly HERE TOOLS_DIR
readonly VALID_SITE_SETTINGS="$TOOLS_DIR/tests/tools/site-settings/valid.json"
readonly DOWNLOADED_PLUGIN="example-download"
readonly PINNED_VERSION="1.1.0"
readonly SERVER_FOLDERS=(example-download example-plugin example-child deploy-note php-log)
readonly PHP_LOG_FILE="error_log_example"
readonly OLD_LOG_LINE="[01-Jan-2026 00:00:00 UTC] an old line"
SCENARIOS_DIR="$HERE/scenarios"
IS_REAL_SERVER=false
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
  cp "$TOOLS_DIR/bin/deploy" "$work/repo/bin/"
  # The page check, a stand-in here: bin/deploy runs the one beside it.
  cp "$HERE/fakes/site-check" "$work/repo/bin/site-check"
  cp "$TOOLS_DIR/tools/paths.sh" "$TOOLS_DIR/tools/site-settings.sh" "$TOOLS_DIR/tools/site-settings.jq" \
    "$TOOLS_DIR/tools/site-packages.sh" "$TOOLS_DIR/tools/versions.sh" "$work/repo/tools/"
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
  # The settings file stays out of git, as in a real site's repository.
  printf '.env\n' >"$repo/.gitignore"
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
    write_server_log "$server/$ssh_host/php-log" "$situation"
    version="$(jq -r --arg host "$ssh_host" '.serverPluginVersion[$host] // "1.0.0"' "$situation")"
    [[ -z "$version" || ! -d "$server/$ssh_host/$DOWNLOADED_PLUGIN" ]] ||
      write_plugin_files "$server/$ssh_host/$DOWNLOADED_PLUGIN" "$DOWNLOADED_PLUGIN" "$version"
  done
}

# The site's PHP log with one old line, alone in its folder unless the situation adds another
# file (phpLogExtraFile), as a wrongly set read-only folder would show.
write_server_log() {
  local log_folder="$1" situation="$2"
  [[ -d "$log_folder" ]] || return 0
  printf '%s\n' "$OLD_LOG_LINE" >"$log_folder/$PHP_LOG_FILE"
  if jq -e '.phpLogExtraFile // false' "$situation" >/dev/null; then
    printf 'mail\n' >"$log_folder/mail.log"
  fi
  return 0
}

# A place's rsync daemon settings on the throwaway server, as the host's: one folder entry for
# each folder the stand-in tree holds for it, the log folder read-only and showing only the
# site's log file.
real_server_rsync_settings() {
  local tree="$1" ssh_host="$2" folder
  printf 'use chroot = no\nmunge symlinks = yes\nread only = no\nlist = no\nmax connections = 1\n'
  printf 'lock file = /home/deploy/.deploy/%s.lock\nincoming chmod = Du=rwx,Dgo=rx,Fu=rw,Fgo=r\n' "$ssh_host"
  for folder in "$tree/$ssh_host"/*/; do
    folder="$(basename "$folder")"
    printf '\n[%s]\n    path = /srv/%s/%s\n' "$folder" "$ssh_host" "$folder"
    [[ "$folder" != php-log ]] || printf '    read only = yes\n    filter = + %s - *\n' "$PHP_LOG_FILE"
  done
}

# The stand-in tree copied onto the throwaway server, with each place's rsync settings, owned by
# the account the keys log in as.
push_server_state() {
  local work="$1" ssh_host
  local tree="$work/services/server"
  docker exec "$REAL_SERVER_CONTAINER" sh -c 'rm -rf /srv/* /home/deploy/.deploy/*.conf' || return 1
  docker cp -q "$tree/." "$REAL_SERVER_CONTAINER:/srv/" || return 1
  for ssh_host in example-staging example-live; do
    real_server_rsync_settings "$tree" "$ssh_host" >"$work/rsyncd-$ssh_host.conf"
    docker cp -q "$work/rsyncd-$ssh_host.conf" "$REAL_SERVER_CONTAINER:/home/deploy/.deploy/rsyncd-$ssh_host.conf" || return 1
  done
  docker exec "$REAL_SERVER_CONTAINER" chown -R deploy:deploy /srv /home/deploy/.deploy
}

# What the throwaway server holds after the run, read back into the stand-in tree, so the same
# expectations apply.
pull_server_state() {
  local work="$1"
  rm -rf "$work/services/server" && mkdir -p "$work/services/server"
  docker cp -q "$REAL_SERVER_CONTAINER:/srv/." "$work/services/server/"
}

# The page check's login for staging, in the repository's settings file, unless the situation
# leaves it out (noPageCheckLogin).
write_settings_file() {
  local work="$1"
  jq -e '.noPageCheckLogin // false' "$work/situation.json" >/dev/null && return 0
  printf 'DEV_SITE_PORT=10102\nSTAGING_CHECK_USER=checker\nSTAGING_CHECK_PASSWORD=pa ss"word\n' >"$work/repo/.env"
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

# The stand-ins without rsync's, ahead of the computer's own programs: the real rsync and ssh
# reach the throwaway server.
search_path_for_real_server() {
  local folder="$TEST_ROOT/fakes-but-rsync" stand_in
  if [[ ! -d "$folder" ]]; then
    mkdir -p "$folder"
    for stand_in in "$HERE"/fakes/*; do
      [[ -x "$stand_in" && "${stand_in##*/}" != rsync ]] && ln -s "$stand_in" "$folder/${stand_in##*/}"
    done
  fi
  [[ "$(PATH="$folder:$PATH" command -v rsync)" != "$HERE/fakes/rsync" ]] || { log "the stand-in rsync would be used against the real server; nothing run"; exit 1; }
  printf '%s' "$folder:$PATH"
}

search_path_for() {
  local situation="$1" missing tool
  [[ "$IS_REAL_SERVER" == false ]] || { search_path_for_real_server; return; }
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
  [[ "$IS_REAL_SERVER" == false ]] || options+=(--ssh-config "$REAL_SERVER_SSH_CONFIG")
  search_path="$(search_path_for "$situation")" || exit 1
  mkdir -p "$work/tmp"
  # Another deploy of the same site running: its lock held for the whole run (lockHeld).
  if jq -e '.lockHeld // false' "$situation" >/dev/null; then
    exec {held_lock}>"$work/tmp/example-deploy.lock" && flock "$held_lock"
  fi
  jq -r '.answer // "yes"' "$situation" |
    env -u GH_TOKEN -u GITHUB_TOKEN PATH="$search_path" FAKE_SERVICES_DIR="$work/services" TMPDIR="$work/tmp" \
      bash "$work/repo/bin/deploy" "$(jq -r '.place' "$situation")" "${options[@]}" >"$work/output.txt" 2>&1
  local status=$?
  [[ -z "${held_lock:-}" ]] || exec {held_lock}>&-
  return "$status"
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
    ! grep -qF -- "$naming" "$work/output.txt" || printf 'its output shows %s, which it must not\n' "$naming"
  done < <(jq -r '.expectOutputLacking // [] | .[]' "$situation")
  while IFS= read -r naming; do
    naming="${naming//\{work\}/$work}"
    grep -qF -- "$naming" "$work/services/remote-shells.txt" 2>/dev/null || printf 'ssh was not run with %s\n' "$naming"
  done < <(jq -r '.expectSshNaming // [] | .[]' "$situation")
  server_problems "$work"
  page_check_problems "$work"
}

# How the page check was run: the address and login it was given, or that it never ran.
page_check_problems() {
  local work="$1" expected ran
  local situation="$work/situation.json"
  ran="$(cat "$work/services/page-checks.txt" 2>/dev/null || true)"
  if jq -e '.expectNoPageCheck // false' "$situation" >/dev/null; then
    [[ -z "$ran" ]] || printf 'the page check ran: %s\n' "$ran"
  fi
  expected="$(jq -r '.expectPageCheck // empty' "$situation")"
  [[ -z "$expected" || "$ran" == "$expected" ]] || printf 'the page check ran as [%s], expected [%s]\n' "$ran" "$expected"
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
    change_working_copy "$work" &&
    write_settings_file "$work"
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
  [[ "$IS_REAL_SERVER" == false ]] || push_server_state "$work" || { log "FAIL  $name: could not set the server up"; return 1; }
  run_deploy "$work"
  status=$?
  [[ "$IS_REAL_SERVER" == false ]] || pull_server_state "$work" || { log "FAIL  $name: could not read the server back"; return 1; }
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

# --real-server: the situations in scenarios-real-server/, against the throwaway server that
# tests/scenario/generic/dev-deploy-server.sh runs, with the real rsync and ssh; it names the
# server's container and the SSH settings file reaching it in REAL_SERVER_CONTAINER and
# REAL_SERVER_SSH_CONFIG.
read_mode() {
  [[ "${1:-}" == --real-server ]] || return 0
  [[ -n "${REAL_SERVER_CONTAINER:-}" && -f "${REAL_SERVER_SSH_CONFIG:-}" ]] ||
    { log "--real-server needs REAL_SERVER_CONTAINER and REAL_SERVER_SSH_CONFIG (dev-deploy-server.sh sets them)"; exit 1; }
  IS_REAL_SERVER=true
  SCENARIOS_DIR="$HERE/scenarios-real-server"
}

main() {
  local scenario failed=0 count=0
  read_mode "$@"
  TEST_ROOT="$(mktemp -d)"
  trap remove_test_root EXIT
  trap 'exit 130' INT TERM
  for scenario in "$SCENARIOS_DIR"/*.json; do
    [[ -f "$scenario" ]] || continue
    count=$((count + 1))
    test_scenario "$scenario" || failed=1
  done
  ((count > 0)) || { log "no situations found in $SCENARIOS_DIR/"; return 1; }
  return "$failed"
}

main "$@"
