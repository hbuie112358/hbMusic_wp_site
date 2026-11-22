#!/usr/bin/env bash
# Scenario (dev site): the click-to-load videos' server side (includes/video-facade.php, plan 9v).
# Saving a page with a YouTube video fetches its picture once into the uploads folder, a real JPEG;
# a video YouTube has no picture for gets none, and shows the play button on a dark box instead;
# other frames and malformed video addresses are left as they are. YouTube's image server is the
# dev site's stand-in (config/dev-mu-plugins/), which answers "not found" for noPicture01.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

readonly VIDEO_WITH_PICTURE='pictureTst1'
readonly VIDEO_WITHOUT_PICTURE='noPicture01'
# Both drafts are deleted however the check ends, and the picture it fetched with them.
PROBE_POST_IDS=()
trap 'remove_probes' EXIT

wp_cli() { dev_compose run --rm -T cli wp "$@"; }

remove_probes() {
  local post_id
  for post_id in "${PROBE_POST_IDS[@]}"; do
    wp_cli post delete "$post_id" --force >/dev/null 2>&1 || true
  done
  wp_cli eval "wp_delete_file( (string) hbmusic_video_picture_path( '$VIDEO_WITH_PICTURE' ) );" >/dev/null 2>&1 || true
}

# Saves a draft holding a video, as WordPress's video block saves it, which runs the fetch.
save_draft_with_video() {
  local video_id="$1" content post_id
  content="<!-- wp:embed {\"url\":\"https://www.youtube.com/watch?v=$video_id\",\"type\":\"video\",\"providerNameSlug\":\"youtube\"} -->
<figure class=\"wp-block-embed is-type-video is-provider-youtube wp-block-embed-youtube\"><div class=\"wp-block-embed__wrapper\">
https://www.youtube.com/watch?v=$video_id
</div></figure>
<!-- /wp:embed -->"
  post_id="$(wp_cli post create --post_type=page --post_status=draft --post_title="Video picture probe" --post_content="$content" --porcelain)"
  PROBE_POST_IDS+=("$post_id")
}

has_picture() {
  wp_cli eval "echo null === hbmusic_video_picture( '$1' ) ? 'no' : 'yes';"
}

expect_picture_fetched_on_save() {
  [[ "$(has_picture "$VIDEO_WITH_PICTURE")" == no ]] || fail "$VIDEO_WITH_PICTURE had a picture before its page was saved"
  save_draft_with_video "$VIDEO_WITH_PICTURE"
  [[ "$(has_picture "$VIDEO_WITH_PICTURE")" == yes ]] || fail "saving a page did not fetch $VIDEO_WITH_PICTURE's picture"
  [[ "$(wp_cli eval "echo hbmusic_is_jpeg_picture( (string) hbmusic_video_picture_path( '$VIDEO_WITH_PICTURE' ) ) ? 'jpeg' : 'other';")" == jpeg ]] \
    || fail "the fetched picture is not a JPEG"
  log "saving a page with a video fetched its picture, a JPEG, into the uploads folder"
}

expect_no_picture_when_youtube_has_none() {
  local facade
  save_draft_with_video "$VIDEO_WITHOUT_PICTURE"
  [[ "$(has_picture "$VIDEO_WITHOUT_PICTURE")" == no ]] || fail "a picture was kept for $VIDEO_WITHOUT_PICTURE, which YouTube does not have"
  facade="$(wp_cli eval "echo hbmusic_video_facade_html( '$VIDEO_WITHOUT_PICTURE', 'Probe' );")"
  [[ "$facade" == *'class="video-facade"'* && "$facade" == *'video-facade__play'* ]] || fail "no facade without a picture: $facade"
  [[ "$facade" != *'<img'* ]] || fail "a facade without a picture shows an image: $facade"
  log "a video without a picture keeps no file and shows the play button on a dark box"
}

# Frames that are not a YouTube video with a proper ID are returned exactly as they were.
expect_other_frames_untouched() {
  local frame result
  for frame in '<iframe src="https://player.vimeo.com/video/1"></iframe>' '<iframe src="https://www.youtube.com/embed/short"></iframe>'; do
    result="$(wp_cli eval "echo hbmusic_replace_youtube_players( '$frame' );")"
    [[ "$result" == "$frame" ]] || fail "a frame was changed: $frame became $result"
  done
  log "other frames and malformed video addresses are left as they are"
}

main() {
  load_settings
  expect_picture_fetched_on_save
  expect_no_picture_when_youtube_has_none
  expect_other_frames_untouched
  expect_clean_debug_log
  log "PASSED"
}

main "$@"
