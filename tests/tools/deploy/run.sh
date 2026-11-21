#!/usr/bin/env bash
# Tests bin/deploy's checks before a copy (template plan 1.4d-1) on known situations, run by
# bin/check every time: for each situation in scenarios/, its exit status and what its output
# names. The real script runs in a throwaway Git repository of its own, with the files it reads
# and the neutral valid site.json example, cloned from a throwaway "GitHub" (a bare repository);
# GitHub's answers and the servers are stand-ins (fakes/), first on the search path, checked
# before each run. Nothing goes over the network, and the stand-in rsync refuses any copy to a
# server. Needs bash, git and jq.
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
# for the situation's folder);
# expectStatus; expectOutputNaming.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"
readonly HERE REPO_ROOT
readonly VALID_SITE_SETTINGS="$REPO_ROOT/tests/tools/site-settings/valid.json"
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
  cp "$REPO_ROOT/tools/site-settings.sh" "$REPO_ROOT/tools/site-settings.jq" "$work/repo/tools/"
  site_settings_for "$scenario" >"$work/repo/site.json"
  in_git -C "$work/repo" add -A && in_git -C "$work/repo" commit -qm "A: the site"
  printf 'a change\n' >"$work/repo/change.txt"
  in_git -C "$work/repo" add -A && in_git -C "$work/repo" commit -qm "B: a change"
  in_git -C "$work/repo" remote add origin "$work/origin.git"
  in_git -C "$work/repo" push -q origin main
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

write_servers() {
  local work="$1" ssh_host note
  local situation="$work/situation.json"
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
  for tool in gh rsync; do
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
