#!/usr/bin/env bash
# Scenario (dev site): an embedded video's title reaches browsers and screen readers as written
# (docs/SITE_CHECKLIST.md 7.4). WordPress 7.1 escaped an apostrophe twice, so "80's rock" was read
# as "80&apos;s rock"; the theme decodes the title before WordPress escapes it
# (hbmusic_decode_embed_title()). Ampersands and quotation marks were never affected; they are
# checked so that the decoding does not break them.
#
# WordPress's own title function runs on player code as YouTube sends it (the title escaped once),
# and the resulting title attribute is read back as a browser decodes it. No YouTube needed.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Each case: the title as written, then as the provider escapes it in its player code.
# In single quotes on purpose: PHP's variables are for WP-CLI, not this shell.
# shellcheck disable=SC2016
readonly CHECK_PHP='$cases = array(
	array( "80'"'"'s rock", "80&#39;s rock" ),
	array( "Rock & Roll", "Rock &amp; Roll" ),
	array( "Say \"hi\"", "Say &quot;hi&quot;" ),
);
foreach ( $cases as $case ) {
	$player = "<iframe title=\"" . $case[1] . "\" src=\"https://www.youtube.com/embed/sample\"></iframe>";
	$data   = (object) array( "type" => "video", "title" => $case[0] );
	$result = wp_filter_oembed_iframe_title_attribute( $player, $data, "https://www.youtube.com/watch?v=sample" );
	$tags   = new WP_HTML_Tag_Processor( $result );
	$tags->next_tag( array( "tag_name" => "iframe" ) );
	$read   = $tags->get_attribute( "title" );
	echo ( $read === $case[0] ? "ok" : "WRONG" ), "\t", $case[0], "\t", var_export( $read, true ), PHP_EOL;
}'

readonly EXPECTED_CASES=3

main() {
  load_settings
  run_capturing dev_compose run --rm -T cli wp eval "$CHECK_PHP"
  assert_status 0 "running WordPress's title function"
  local passed
  passed="$(grep -c '^ok	' <<<"$RUN_OUTPUT" || true)"
  [[ "$RUN_OUTPUT" != *WRONG* ]] || fail "a title is read differently from how it was written: $RUN_OUTPUT"
  ((passed == EXPECTED_CASES)) || fail "expected $EXPECTED_CASES titles read correctly, got $passed: $RUN_OUTPUT"
  log "PASSED ($passed titles read as written)"
}

main "$@"
