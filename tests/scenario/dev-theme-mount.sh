#!/usr/bin/env bash
# Scenario (dev site): the child theme reaches WordPress read-only, and the files stay the
# user's (plan step 4b, the permission check folded in from 3c): neither WordPress's user nor
# the container's root can write into themes/hbmusic-child/, and on the host every file there
# belongs to the user and none is writable by others.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

readonly THEME_IN_CONTAINER="/var/www/html/wp-content/themes/hbmusic-child"
readonly THEME_ON_HOST="$REPO_ROOT/themes/hbmusic-child"

# A write that succeeds is removed again at once, so a failing check leaves no file behind.
expect_write_refused() {
  local container_user="$1" probe="$THEME_IN_CONTAINER/write-probe-$$"
  run_capturing dev_compose exec -T --user "$container_user" wordpress sh -c "touch '$probe' && rm -f '$probe'"
  [[ "$RUN_STATUS" -ne 0 ]] || fail "user $container_user in the WordPress container could write into the theme folder"
  log "user $container_user cannot write into the theme folder"
}

expect_host_files_private() {
  local foreign writable
  foreign="$(find "$THEME_ON_HOST" ! -user "$(id -u)" -print)"
  [[ -z "$foreign" ]] || fail "files in the theme folder not owned by the user: $foreign"
  writable="$(find "$THEME_ON_HOST" -perm -o+w -print)"
  [[ -z "$writable" ]] || fail "files in the theme folder writable by others: $writable"
  log "every file in the theme folder belongs to the user, and none is writable by others"
}

main() {
  load_settings
  expect_write_refused www-data
  expect_write_refused root
  expect_host_files_private
}

main "$@"
