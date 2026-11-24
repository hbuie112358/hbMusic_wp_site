#!/usr/bin/env bash
# Scenario (dev site): the child theme and the project's plugins reach WordPress read-only, and
# the files stay the user's (plan steps 4b and 5a, the permission check folded in from 3c):
# neither WordPress's user nor the container's root can write into their folders, and on the
# host every file there belongs to the user and none is writable by others.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

readonly WP_CONTENT_IN_CONTAINER="/var/www/html/wp-content"

# Each folder under wp-content/ in the container, and under the repository on the host: the child
# theme and every plugin in plugins/, found rather than listed, so a new plugin cannot be left out
# (the Editing Help plugin was, until this check found its folders by itself). The theme's folder
# is the one site.json names, read once at the start (a plain assignment, so a failed read stops
# the check under set -e, which a read inside printf's arguments would not).
CHILD_THEME="$(site_setting .theme)"
readonly CHILD_THEME
code_folders() {
  printf 'themes/%s\n' "$CHILD_THEME"
  local plugin_folder
  for plugin_folder in "$PROJECT_DIR"/plugins/*/; do
    printf 'plugins/%s\n' "$(basename "$plugin_folder")"
  done
}

# A write that succeeds is removed again at once, so a failing check leaves no file behind.
expect_write_refused() {
  local container_user="$1" code_folder="$2" probe="$WP_CONTENT_IN_CONTAINER/$2/write-probe-$$"
  run_capturing dev_compose exec -T --user "$container_user" wordpress sh -c "touch '$probe' && rm -f '$probe'"
  [[ "$RUN_STATUS" -ne 0 ]] || fail "user $container_user in the WordPress container could write into $code_folder"
  log "user $container_user cannot write into $code_folder"
}

# Where a folder under wp-content/ comes from on the host: the theme from the site's themes folder
# (this repository's, or the site SITE_DIR names, template plan 1.6c), the plugins from plugins/.
host_folder() {
  local code_folder="$1"
  case "$code_folder" in
    themes/*) printf '%s/%s\n' "$SITE_THEMES_DIR" "${code_folder#themes/}" ;;
    *) printf '%s/%s\n' "$PROJECT_DIR" "$code_folder" ;;
  esac
}

expect_host_files_private() {
  local code_folder="$1" host_path foreign writable
  host_path="$(host_folder "$code_folder")"
  foreign="$(find "$host_path" ! -user "$(id -u)" -print)"
  [[ -z "$foreign" ]] || fail "files in $code_folder not owned by the user: $foreign"
  writable="$(find "$host_path" -perm -o+w -print)"
  [[ -z "$writable" ]] || fail "files in $code_folder writable by others: $writable"
  log "every file in $code_folder belongs to the user, and none is writable by others"
}

main() {
  load_settings
  local code_folder
  for code_folder in $(code_folders); do
    expect_write_refused www-data "$code_folder"
    expect_write_refused root "$code_folder"
    expect_host_files_private "$code_folder"
  done
}

main "$@"
