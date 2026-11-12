#!/usr/bin/env bash
# Scenario (dev site): the theme's patterns that the editor offers are registered, and each one's
# blocks are the structure the theme's CSS expects (plan D29). A pattern is copied into a page when
# inserted, so a pattern that drifted from the CSS would put unstyled blocks on every page built
# from it after the drift.
#
# The "Video carousel" pattern (patterns/video-carousel.php): a wide section with the class
# site-carousel and a label for screen readers, whose direct children are YouTube embeds.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# In single quotes on purpose: PHP's variables are for WP-CLI, not this shell.
# shellcheck disable=SC2016
readonly CHECK_PHP='$pattern = WP_Block_Patterns_Registry::get_instance()->get_registered( "hbmusic/video-carousel" );
if ( null === $pattern ) {
	echo "missing", PHP_EOL;
	return;
}
$blocks = array_values( array_filter( parse_blocks( $pattern["content"] ), static fn ( $block ) => null !== $block["blockName"] ) );
$group  = $blocks[0] ?? array( "blockName" => null, "attrs" => array(), "innerBlocks" => array() );
$attrs  = $group["attrs"];
echo "blocks ", count( $blocks ), PHP_EOL;
echo "outer ", $group["blockName"], PHP_EOL;
echo "tag ", $attrs["tagName"] ?? "", PHP_EOL;
echo "align ", $attrs["align"] ?? "", PHP_EOL;
echo "class ", $attrs["className"] ?? "", PHP_EOL;
echo "label ", ( "" !== ( $attrs["ariaLabel"] ?? "" ) ? "set" : "missing" ), PHP_EOL;
echo "inserter ", ( false === ( $pattern["inserter"] ?? true ) ? "hidden" : "offered" ), PHP_EOL;
foreach ( $group["innerBlocks"] as $slide ) {
	echo "slide ", $slide["blockName"], " ", $slide["attrs"]["providerNameSlug"] ?? "", PHP_EOL;
}'

expect_line() {
  local line="$1"
  grep -qxF "$line" <<<"$RUN_OUTPUT" || fail "the pattern lacks \"$line\": $RUN_OUTPUT"
}

main() {
  load_settings
  run_capturing dev_compose run --rm -T cli wp eval "$CHECK_PHP"
  assert_status 0 "reading the pattern"
  expect_line "blocks 1"
  expect_line "outer core/group"
  expect_line "tag section"
  expect_line "align wide"
  expect_line "class site-carousel"
  expect_line "label set"
  expect_line "inserter offered"
  local slides
  slides="$(grep -c '^slide ' <<<"$RUN_OUTPUT" || true)"
  ((slides >= 1)) || fail "the pattern's carousel has no slides: $RUN_OUTPUT"
  [[ "$(grep -c '^slide core/embed youtube$' <<<"$RUN_OUTPUT" || true)" == "$slides" ]] \
    || fail "every slide must be a YouTube embed: $RUN_OUTPUT"
  log "PASSED (the video carousel pattern, $slides YouTube slides)"
}

main "$@"
