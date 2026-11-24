#!/usr/bin/env bash
# Scenario: bin/deploy against a real throwaway server (template plan 1.4d-3), set up like the
# host: one account reached only by keys, each key forced into rsync's daemon mode with its own
# folder settings (restrict,command="rsync --server --daemon --config=..."), a read-only log
# folder showing only the site's log. The real rsync and ssh of this computer reach it; GitHub,
# the plugin build and the page check stay stand-ins (tests/tools/deploy/, which runs its
# real-server situations against it). Then probes of the restrictions themselves: a key opens no
# shell, cannot write into the log folder, cannot climb out of its folders, and an unknown key is
# refused without any password question. Needs no dev site; the container is removed however the
# check ends.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"
# shellcheck source=tools/versions.sh
source "$TOOLS_DIR/tools/versions.sh"

readonly SERVER_DIR="$TOOLS_DIR/tests/scenario/generic/deploy-server"
readonly IMAGE_TAG="deploy-test-server:local"
readonly SSH_PORT_INSIDE=22
# A probe that hangs (a password question waiting for an answer) fails instead of blocking.
readonly PROBE_SECONDS=30
WORK=""
CONTAINER=""

cleanup() {
  [[ -n "$CONTAINER" ]] && docker rm -f "$CONTAINER" >/dev/null 2>&1
  [[ -n "$WORK" ]] && rm -rf "$WORK"
  return 0
}

build_server_image() {
  docker build -q -t "$IMAGE_TAG" \
    --build-arg "BASE_IMAGE=$DEPLOY_TEST_SERVER_BASE_IMAGE" \
    --build-arg "OPENSSH_SERVER_VERSION=$DEPLOY_TEST_SERVER_OPENSSH_VERSION" \
    --build-arg "RSYNC_VERSION=$DEPLOY_TEST_SERVER_RSYNC_VERSION" "$SERVER_DIR" >/dev/null ||
    fail "could not build the test server from the pinned image and packages (tools/versions.sh)"
}

# Fresh keys for this run: the server's identity, one key per place, one the server does not know.
make_keys() {
  local name
  for name in host staging live stranger; do
    ssh-keygen -q -t ed25519 -N "" -C "deploy test $name" -f "$WORK/$name"
  done
  for name in staging live; do
    printf 'restrict,command="rsync --server --daemon --config=/home/deploy/.deploy/rsyncd-example-%s.conf ." %s\n' \
      "$name" "$(cat "$WORK/$name.pub")"
  done >"$WORK/authorized_keys"
}

start_server() {
  CONTAINER="$(docker create -p "127.0.0.1::$SSH_PORT_INSIDE" "$IMAGE_TAG")"
  docker cp -q "$WORK/host" "$CONTAINER:/etc/ssh/ssh_host_ed25519_key"
  docker cp -q "$WORK/authorized_keys" "$CONTAINER:/home/deploy/.ssh-authorized_keys"
  docker start "$CONTAINER" >/dev/null
  docker exec "$CONTAINER" sh -c 'mkdir -p /home/deploy/.ssh && mv /home/deploy/.ssh-authorized_keys /home/deploy/.ssh/authorized_keys &&
    chmod 600 /etc/ssh/ssh_host_ed25519_key /home/deploy/.ssh/authorized_keys && chmod 700 /home/deploy/.ssh && chown -R deploy:deploy /home/deploy/.ssh'
}

# The SSH settings bin/deploy is given: each short name with its key, the server's identity
# known in advance and checked strictly.
write_ssh_settings() {
  local port name
  port="$(docker port "$CONTAINER" "$SSH_PORT_INSIDE/tcp" | head -n 1 | sed 's/.*://')"
  printf '[127.0.0.1]:%s %s\n' "$port" "$(cut -d' ' -f1-2 "$WORK/host.pub")" >"$WORK/known_hosts"
  for name in staging live stranger; do
    printf 'Host example-%s\n  HostName 127.0.0.1\n  Port %s\n  User deploy\n  IdentityFile %s/%s\n  IdentitiesOnly yes\n  StrictHostKeyChecking yes\n  UserKnownHostsFile %s/known_hosts\n\n' \
      "$name" "$port" "$WORK" "$name" "$WORK"
  done >"$WORK/ssh_config"
}

# Ready once ssh connects and the key is accepted: any status but ssh's own 255 (the forced rsync
# daemon then exits on its own, its folder settings not copied in yet).
readonly SSH_FAILED=255
readonly READY_TRIES=40
wait_for_server() {
  local try status
  for ((try = 1; try <= READY_TRIES; try++)); do
    status=0
    timeout 5 ssh -F "$WORK/ssh_config" -o BatchMode=yes example-staging true </dev/null >/dev/null 2>&1 || status=$?
    ((status == SSH_FAILED || status == 124)) || return 0
    sleep 0.5
  done
  fail "the test server did not accept the staging key after $READY_TRIES tries"
}

probe_ssh() { timeout "$PROBE_SECONDS" ssh -F "$WORK/ssh_config" -o BatchMode=yes "$@" </dev/null; }
probe_rsync() { timeout "$PROBE_SECONDS" rsync -e "ssh -F $WORK/ssh_config -o BatchMode=yes" "$@"; }

# Each key's restriction, tried directly rather than through bin/deploy.
probe_restrictions() {
  run_capturing probe_ssh example-staging 'echo shell-opened'
  [[ "$RUN_OUTPUT" != *shell-opened* ]] || fail "the staging key opened a shell"
  printf 'planted\n' >"$WORK/planted.txt"
  # Live's folder exists, so a file climbing into it would land there and be found.
  docker exec "$CONTAINER" sh -c 'mkdir -p /srv/example-live/example-child && chown -R deploy:deploy /srv/example-live'
  # The log file's own name, which the folder's filter lets through, so only "read only" stops it.
  run_capturing probe_rsync -q "$WORK/planted.txt" example-staging::php-log/error_log_example
  ((RUN_STATUS != 0)) || fail "the staging key could overwrite the log in the read-only log folder"
  run_capturing probe_rsync -q "$WORK/planted.txt" example-staging::example-child/../../example-live/example-child/planted.txt
  run_capturing docker exec "$CONTAINER" sh -c 'test ! -e /srv/example-live/example-child/planted.txt'
  assert_status 0 "the staging key reached live's folder through a path climbing out of its own"
  run_capturing probe_rsync --list-only example-stranger::deploy-note/
  ((RUN_STATUS != 0 && RUN_STATUS != 124)) || fail "a key the server does not know was not refused at once (status $RUN_STATUS)"
  log "each key opens no shell, cannot write the log or climb out of its folders; an unknown key is refused at once"
}

main() {
  WORK="$(mktemp -d)"
  trap cleanup EXIT
  build_server_image
  make_keys
  start_server
  write_ssh_settings
  wait_for_server
  # Without SITE_DIR: these are the deploy tool's own tests, against stand-in repositories, whatever
  # site's dev site this run tests (template plan 1.6c-2).
  run_capturing env -u SITE_DIR REAL_SERVER_CONTAINER="$CONTAINER" REAL_SERVER_SSH_CONFIG="$WORK/ssh_config" \
    bash "$TOOLS_DIR/tests/tools/deploy/run.sh" --real-server
  assert_status 0 "bin/deploy's situations against the real server"
  log "bin/deploy's situations against the real server passed"
  probe_restrictions
}

main "$@"
