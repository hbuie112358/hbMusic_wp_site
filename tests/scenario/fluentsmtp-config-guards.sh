#!/usr/bin/env bash
# Scenario: local/wp-cli/configure-fluentsmtp-mailpit.php refuses to run outside a local
# environment and stops on a missing or invalid setting, each time before saving anything
# (plan step 3b's safety stops, tested here per the 3b review).
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

readonly CONFIG_SCRIPT="/local/wp-cli/configure-fluentsmtp-mailpit.php"

# The saved FluentSMTP settings, as a fingerprint: compared before and after, so the check does
# not depend on FluentSMTP's internal format.
# Stops if the settings cannot be read: two empty readings would otherwise match and pass.
settings_fingerprint() {
  local settings
  settings="$(compose run --rm -T cli wp --skip-plugins --skip-themes option get fluentmail-settings --format=json 2>/dev/null)" ||
    fail "could not read FluentSMTP's saved settings (is the local copy imported?)"
  [[ -n "$settings" ]] || fail "FluentSMTP's saved settings are empty"
  printf '%s' "$settings" | sha256sum | cut -d' ' -f1
}

# Runs the configuration script with one environment override and expects it to stop with
# status 1, naming the expected setting in its output.
expect_refusal() {
  local override="$1" named="$2" case_name="$3"
  run_capturing compose run --rm -T -e "$override" cli wp eval-file "$CONFIG_SCRIPT"
  assert_status 1 "$case_name"
  assert_output_names "$named" "$case_name"
  log "ok: $case_name"
}

main() {
  load_settings
  local before after
  before="$(settings_fingerprint)"
  # Without WORDPRESS_CONFIG_EXTRA, WP_ENVIRONMENT_TYPE is not "local".
  expect_refusal "WORDPRESS_CONFIG_EXTRA=" "WP_ENVIRONMENT_TYPE" "refuses outside a local environment"
  expect_refusal "LOCAL_SMTP_HOST=" "LOCAL_SMTP_HOST" "stops on a missing setting"
  expect_refusal "LOCAL_SMTP_PORT=abc" "LOCAL_SMTP_PORT" "stops on a port that is not a number"
  expect_refusal "LOCAL_SMTP_PORT=70000" "LOCAL_SMTP_PORT" "stops on a port above 65535"
  after="$(settings_fingerprint)"
  [[ "$before" == "$after" ]] || fail "the saved FluentSMTP settings changed during the refused runs"
  log "ok: nothing was saved by the refused runs"
  log "PASSED"
}

main "$@"
