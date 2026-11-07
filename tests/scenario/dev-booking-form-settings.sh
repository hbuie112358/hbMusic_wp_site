#!/usr/bin/env bash
# Scenario (dev site): Contact Form 7's own checker accepts the booking form's mail addresses (plan
# step 5e). The dev site replaces the sender when sending, so a sending test cannot show this; an
# invalid address once reached staging that way.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# In single quotes on purpose: PHP's variables are for WP-CLI, not this shell.
# shellcheck disable=SC2016
readonly CHECK_PHP='$form = wpcf7_get_contact_form_by_title( "Booking form" );
$validator = new WPCF7_ConfigValidator( $form );
$validator->validate();
foreach ( array( "mail.sender", "mail.recipient", "mail.additional_headers" ) as $section ) {
	if ( $validator->has_error( $section, "invalid_mailbox_syntax" ) ) {
		echo $section, PHP_EOL;
	}
}
echo "checked", PHP_EOL;'

main() {
  load_settings
  run_capturing dev_compose run --rm -T cli wp --user="$DEV_ADMIN_USER" eval "$CHECK_PHP"
  assert_status 0 "running the form's checker"
  assert_output_names "checked" "the checker's run"
  [[ "$RUN_OUTPUT" != *mail.* ]] || fail "invalid mailbox syntax in: $RUN_OUTPUT"
  log "PASSED"
}

main "$@"
