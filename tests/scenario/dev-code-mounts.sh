#!/usr/bin/env bash
# Scenario (dev site): the child theme and the Song List plugin reach WordPress read-only, and
# the files stay the user's (plan steps 4b and 5a, the permission check folded in from 3c):
# neither WordPress's user nor the container's root can write into their folders, and on the
# host every file there belongs to the user and none is writable by others.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Each folder under wp-content/ in the container, and under the repository on the host.
readonly CODE_FOLDERS=(themes/hbmusic-child plugins/song-list)
readonly WP_CONTENT_IN_CONTAINER="/var/www/html/wp-content"

# A write that succeeds is removed again at once, so a failing check leaves no file behind.
expect_write_refused() {
  local container_user="$1" code_folder="$2" probe="$WP_CONTENT_IN_CONTAINER/$2/write-probe-$$"
  run_capturing dev_compose exec -T --user "$container_user" wordpress sh -c "touch '$probe' && rm -f '$probe'"
  [[ "$RUN_STATUS" -ne 0 ]] || fail "user $container_user in the WordPress container could write into $code_folder"
  log "user $container_user cannot write into $code_folder"
}

expect_host_files_private() {
  local code_folder="$1" foreign writable
  foreign="$(find "$REPO_ROOT/$code_folder" ! -user "$(id -u)" -print)"
  [[ -z "$foreign" ]] || fail "files in $code_folder not owned by the user: $foreign"
  writable="$(find "$REPO_ROOT/$code_folder" -perm -o+w -print)"
  [[ -z "$writable" ]] || fail "files in $code_folder writable by others: $writable"
  log "every file in $code_folder belongs to the user, and none is writable by others"
}

main() {
  load_settings
  local code_folder
  for code_folder in "${CODE_FOLDERS[@]}"; do
    expect_write_refused www-data "$code_folder"
    expect_write_refused root "$code_folder"
    expect_host_files_private "$code_folder"
  done
}

main "$@"
