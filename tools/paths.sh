#!/usr/bin/env bash
# The folders every tool needs (template plan T19), worked out in one place. Sourced, never run:
# the sourcing script defines TOOLS_DIR, the tools' own folder, from its own path (BASH_SOURCE);
# this file then defines PROJECT_DIR, the site's repository (its .env, its records, the code
# bin/check checks). SITE_DIR, the site worked on, is read later from PROJECT_DIR
# (tools/site-settings.sh).
#
# A site gets the tools through Composer (template plan T18), which runs each command through a
# small script in the site's bin/ that exports COMPOSER_RUNTIME_BIN_DIR, that bin/ folder; its
# parent is the site's repository. The current folder is never used: it is wherever the user typed
# the command. Without Composer's variable, the tools must be the site's own (this repository
# until the tools move, and the tools' tests' stand-in copies), which a site.json beside them
# shows; anywhere else the script refuses rather than guess a site to change.
#
# Not caught here: a COMPOSER_RUNTIME_BIN_DIR left over in a shell started from another project's
# Composer run names that project's bin/, a real folder, so a tool started from that shell works on
# the other project. Tested with the tools apart in tests/tools/paths/.

# Prints the site's repository, or a message on stderr and fails when it cannot be told.
project_dir_of_tools() {
  local composer_bin_dir="${COMPOSER_RUNTIME_BIN_DIR:-}"
  if [[ -n "$composer_bin_dir" ]]; then
    [[ -d "$composer_bin_dir" ]] && { (cd "$composer_bin_dir/.." && pwd); return; }
    printf 'COMPOSER_RUNTIME_BIN_DIR names %s, which is not a folder\n' "$composer_bin_dir" >&2
    return 1
  fi
  [[ -f "$TOOLS_DIR/site.json" ]] && { printf '%s\n' "$TOOLS_DIR"; return 0; }
  printf 'cannot tell which site to work on: run the command through the site'"'"'s own bin/ folder, not from %s\n' "$TOOLS_DIR" >&2
  return 1
}

# exit, not return: a sourcing script without set -e (bin/check runs every check even after a
# failure) would otherwise go on with no PROJECT_DIR.
PROJECT_DIR="$(project_dir_of_tools)" || exit 1
readonly PROJECT_DIR
