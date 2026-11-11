#!/usr/bin/env bash
# Scenario (dev site): bin/screenshots shows a site's real pages as previews (plan D29). With two
# neutral fixture pages and a photo (fixtures/screenshots/): both previews are created, with the
# photo's address filled in; a second run creates neither the pages nor the photo again; an unsafe
# page name is refused. The fixture's pages and photo are removed afterwards. Two pages, because
# a fault once gave only the first listed page a preview.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

readonly FIXTURE_DIR="$REPO_ROOT/tests/scenario/fixtures/screenshots"
readonly PREVIEW_SLUG="preview-screenshots-fixture"
readonly SECOND_PREVIEW_SLUG="preview-screenshots-fixture-two"
readonly PHOTO_TITLE="screenshots preview photo fixture-photo.png"
UNSAFE_DIR=""

wp_cli() { dev_compose run --rm -T cli wp "$@" </dev/null; }

previews() {
  SCREENSHOTS_CONTENT_DIR="$1" SCREENSHOTS_PHOTOS_DIR="$FIXTURE_DIR" "$REPO_ROOT/bin/screenshots" previews
}

remove_fixture_content() {
  local id
  for id in $(wp_cli post list --post_type=page --name="$PREVIEW_SLUG" --post_status=any --field=ID) \
    $(wp_cli post list --post_type=page --name="$SECOND_PREVIEW_SLUG" --post_status=any --field=ID) \
    $(wp_cli post list --post_type=attachment --title="$PHOTO_TITLE" --field=ID); do
    wp_cli post delete "$id" --force >/dev/null
  done
  [[ -z "$UNSAFE_DIR" ]] || rm -rf "$UNSAFE_DIR"
}

count_of() { wp_cli post list "$@" --format=count; }

expect_preview_with_photo() {
  local content
  content="$(wp_cli post list --post_type=page --name="$PREVIEW_SLUG" --post_status=any --field=post_content)"
  [[ "$content" == *"/wp-content/uploads/"*"fixture-photo"* ]] || fail "the preview has no uploaded photo: $content"
  [[ "$content" != *"{{photo:"* ]] || fail "the preview still holds a photo name: $content"
  log "the preview exists with the photo's address"
}

expect_each_page_once_and_one_photo() {
  local first second photos
  first="$(count_of --post_type=page --name="$PREVIEW_SLUG" --post_status=any)"
  second="$(count_of --post_type=page --name="$SECOND_PREVIEW_SLUG" --post_status=any)"
  photos="$(count_of --post_type=attachment --title="$PHOTO_TITLE")"
  [[ "$first $second $photos" == "1 1 1" ]] ||
    fail "after two runs: $first and $second preview page(s), $photos photo(s); expected 1, 1 and 1"
  log "both pages have one preview each, and the photo was uploaded once"
}

expect_unsafe_name_refused() {
  UNSAFE_DIR="$(mktemp -d)"
  printf '[{"slug": "../outside", "file": "fixture.html"}]\n' >"$UNSAFE_DIR/pages.json"
  cp "$FIXTURE_DIR/fixture.html" "$UNSAFE_DIR/"
  run_capturing previews "$UNSAFE_DIR"
  assert_status 1 "a page named ../outside"
  assert_output_names "../outside" "the refusal"
  log "an unsafe page name is refused"
}

main() {
  load_settings
  trap remove_fixture_content EXIT
  remove_fixture_content
  run_capturing previews "$FIXTURE_DIR"
  assert_status 0 "the first run"
  expect_preview_with_photo
  run_capturing previews "$FIXTURE_DIR"
  assert_status 0 "the second run"
  expect_each_page_once_and_one_photo
  expect_unsafe_name_refused
  log "PASSED"
}

main "$@"
