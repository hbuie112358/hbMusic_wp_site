#!/usr/bin/env bash
# Scenario: an email sent through WordPress (wp_mail, so through FluentSMTP) arrives in Mailpit
# (plan steps 3b, 3e). Fails if WordPress reports a send failure or the message does not arrive
# within the time limit.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

readonly WAIT_SECONDS=30
readonly WAIT_INTERVAL_SECONDS=1
readonly TEST_RECIPIENT="mail-check@example.test"

# A marker unique to this run, so an earlier test message can never count as this one's.
new_marker() { printf 'mail-check-%s-%s' "$(date +%s)" "$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')"; }

send_test_mail() {
  local marker="$1"
  run_capturing compose run --rm -T -e MARKER="$marker" -e RECIPIENT="$TEST_RECIPIENT" cli \
    wp eval 'echo wp_mail( getenv( "RECIPIENT" ), "Local mail check " . getenv( "MARKER" ), "Sent by the mail-delivery scenario." ) ? "sent" : "failed";'
  assert_status 0 "sending through WordPress"
  [[ "$RUN_OUTPUT" == *sent ]] || fail "WordPress reported that sending failed (wp_mail returned false). Output: $RUN_OUTPUT"
  log "WordPress sent the message ($marker)"
}

count_in_mailpit() {
  local marker="$1"
  curl -fsS --max-time 5 "http://127.0.0.1:${MAIL_UI_PORT}/api/v1/search?query=${marker}" |
    grep -oE '"messages_count":[0-9]+' | grep -oE '[0-9]+$'
}

wait_for_arrival() {
  local marker="$1" waited=0
  until [[ "$(count_in_mailpit "$marker" || echo 0)" -ge 1 ]]; do
    ((waited < WAIT_SECONDS)) || fail "the message did not arrive in Mailpit within ${WAIT_SECONDS}s"
    sleep "$WAIT_INTERVAL_SECONDS"
    waited=$((waited + WAIT_INTERVAL_SECONDS))
  done
  log "Arrived in Mailpit"
}

main() {
  load_settings
  local marker
  marker="$(new_marker)"
  send_test_mail "$marker"
  wait_for_arrival "$marker"
  log "PASSED"
}

main "$@"
