#!/usr/bin/env bash
# Tests how the tools find the site they work on (tools/paths.sh and tools/site-settings.sh,
# template plan T19), run by the tools' self-check every time, with the tools apart from a stand-in
# site, as they are once a site installs them through Composer (T18). Copies of the real files go
# into a temporary tools folder with no site.json, beside a stand-in site; a small script there
# sources them as every tool does and prints the folders they work out. The command is always
# started from an unrelated folder holding its own starter/, so a tool that read the current folder
# would show.
#
# The one risk no code here can catch: COMPOSER_RUNTIME_BIN_DIR is Composer's, exported to whatever
# a Composer run starts. A shell started from another project's Composer run (composer exec,
# a script of that project) keeps that project's value, and a tool started from that shell works on
# the other project. The refusal below only covers a value that names no folder.
# Needs bash, cp and mktemp.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HERE
readonly REAL_TOOLS="$HERE/../../../tools"

log() { printf '%s [paths tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

WORK=""
OUTPUT=""
STATUS=0

# A tools folder holding copies of the real files and the probe; a site.json beside them when the
# second argument is "with-site-settings" (the layout before the tools move).
write_tools_folder() {
  local folder="$1" layout="$2"
  mkdir -p "$folder/tools" "$folder/config/dev-mu-plugins"
  cp "$REAL_TOOLS/paths.sh" "$REAL_TOOLS/site-settings.sh" "$folder/tools/"
  cat >"$folder/tools/probe.sh" <<'EOF'
TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$TOOLS_DIR/tools/paths.sh"
source "$TOOLS_DIR/tools/site-settings.sh"
printf '%s\n' "PROJECT_DIR=$PROJECT_DIR" "SITE_DIR=$SITE_DIR" \
  "MU_PLUGINS_MOUNT=$(compose_mount_source "$TOOLS_DIR/config/dev-mu-plugins")"
EOF
  [[ "$layout" == with-site-settings ]] && printf '{}\n' >"$folder/site.json"
  return 0
}

# The stand-in site, with the bin/ folder Composer would fill and a starter/ of its own; and the
# unrelated folder the commands are started from.
write_site_folders() {
  mkdir -p "$WORK/site/bin" "$WORK/site/starter" "$WORK/elsewhere/starter"
  printf '{}\n' >"$WORK/site/site.json"
}

# Runs the probe of the given tools folder from the unrelated folder, with only the given settings
# (NAME=value ...) of the two the tools read, never the user's own.
run_probe() {
  local tools_folder="$1"
  shift
  STATUS=0
  OUTPUT="$(cd "$WORK/elsewhere" && env -u COMPOSER_RUNTIME_BIN_DIR -u SITE_DIR "$@" \
    bash "$tools_folder/tools/probe.sh" 2>&1)" || STATUS=$?
}

expect_folders() {
  local what="$1" expected="$2"
  [[ "$STATUS" -eq 0 && "$OUTPUT" == "$expected" ]] && { log "ok    $what"; return 0; }
  log "FAIL  $what: expected
$expected
got (exit status $STATUS):
$OUTPUT"
  return 1
}

# A refusal fails and names the offending folder; its wording is not checked.
expect_refusal_naming() {
  local what="$1" named="$2"
  [[ "$STATUS" -ne 0 && "$OUTPUT" == *"$named"* && "$OUTPUT" != *PROJECT_DIR=* ]] && { log "ok    $what"; return 0; }
  log "FAIL  $what: expected a refusal naming $named, got (exit status $STATUS): $OUTPUT"
  return 1
}

examples_with_tools_apart() {
  local apart="$WORK/tools-apart" failed=0
  run_probe "$apart" COMPOSER_RUNTIME_BIN_DIR="$WORK/site/bin"
  expect_folders "the site found through Composer's bin folder, the tools mounted by their full path" \
    "PROJECT_DIR=$WORK/site
SITE_DIR=$WORK/site
MU_PLUGINS_MOUNT=$apart/config/dev-mu-plugins" || failed=1
  run_probe "$apart" COMPOSER_RUNTIME_BIN_DIR="$WORK/site/bin" SITE_DIR=starter
  expect_folders "a relative SITE_DIR read from the site, not from the current folder" \
    "PROJECT_DIR=$WORK/site
SITE_DIR=$WORK/site/starter
MU_PLUGINS_MOUNT=$apart/config/dev-mu-plugins" || failed=1
  run_probe "$apart"
  expect_refusal_naming "refused without Composer's bin folder" "$apart" || failed=1
  run_probe "$apart" COMPOSER_RUNTIME_BIN_DIR="$WORK/no-such-folder"
  expect_refusal_naming "refused when Composer's bin folder does not exist" "$WORK/no-such-folder" || failed=1
  return "$failed"
}

# Today's layout: the tools inside the site's repository, which holds site.json.
example_with_tools_in_site() {
  local together="$WORK/together"
  run_probe "$together"
  expect_folders "the tools' own folder when it holds site.json, the mount relative to it" \
    "PROJECT_DIR=$together
SITE_DIR=$together
MU_PLUGINS_MOUNT=./config/dev-mu-plugins"
}

main() {
  local failed=0
  WORK="$(mktemp -d)"
  trap 'rm -rf "$WORK"' EXIT
  write_site_folders
  write_tools_folder "$WORK/tools-apart" without-site-settings
  write_tools_folder "$WORK/together" with-site-settings
  examples_with_tools_apart || failed=1
  example_with_tools_in_site || failed=1
  return "$failed"
}

main "$@"
