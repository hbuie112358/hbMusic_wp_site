#!/usr/bin/env bash
# This site's own steps in building its dev site, after bin/dev-site's own (template plan 1.2b):
# the Song List plugin's sample songs. Sourced by bin/dev-site, never run; it provides wp_cli, log
# and fail. A site without such steps has no such file.

# Sample songs as "title|artist", deliberately out of order, with an ampersand and tags to be
# shown as plain text, and one song without an artist:
# tests/e2e/specs/dev/plugins/song-list/song-list.spec.ts expects them sorted and escaped. Neutral text, no real data.
readonly TEST_SONGS=(
  'Zulu Sample Song|'
  'Rock & Roll <em>Sample</em>|Sample Artist Two'
  'Alpha Sample Song|Sample Artist One'
)

create_test_songs() {
  local song title artist
  log "Creating the Song List's sample songs"
  for song in "${TEST_SONGS[@]}"; do
    title="${song%%|*}"
    artist="${song#*|}"
    wp_cli post create --post_type=songlist_song --post_status=publish --post_title="$title" \
      --meta_input="{\"songlist_artist\":\"$artist\"}" --porcelain >/dev/null
  done
}

create_test_songs
