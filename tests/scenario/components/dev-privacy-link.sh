#!/usr/bin/env bash
# Scenario (dev site): the footer's Privacy Policy link follows Settings → Privacy (plan 1b; the
# theme's hbmusic_link_privacy_policy()). A fixed /privacy-policy/ once opened WordPress's old
# draft on staging. Checked: the chosen page; another page chosen instead; no page chosen, which
# leaves the link out rather than linking to nothing. A scenario check, not a browser test, since
# it changes a setting every page shares; the setting is put back however the check ends.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

readonly PRIVACY_SETTING="wp_page_for_privacy_policy"
readonly LINK_CLASS="site-privacy-link"
ORIGINAL_PRIVACY_PAGE=""
trap 'restore_privacy_setting' EXIT

site_url() { printf 'http://localhost:%s%s' "$DEV_SITE_PORT" "$1"; }
wp_cli() { dev_compose run --rm -T cli wp "$@"; }

restore_privacy_setting() {
  [[ -n "$ORIGINAL_PRIVACY_PAGE" ]] || return 0
  wp_cli option update "$PRIVACY_SETTING" "$ORIGINAL_PRIVACY_PAGE" >/dev/null 2>&1 || true
}

page_id() { wp_cli post list --post_type=page --name="$1" --field=ID; }
page_url() { wp_cli post list --post_type=page --name="$1" --field=url; }

# The address of the footer's marked link on the home page, or nothing when there is no such link.
footer_privacy_address() {
  local page
  page="$(curl -sS --max-time 10 "$(site_url /)")"
  [[ "$page" == *'site-footer'* ]] || fail "the home page has no footer: ${page:0:300}"
  grep -oE "<a [^>]*class=\"$LINK_CLASS\"[^>]*>" <<<"$page" | grep -oE 'href="[^"]*"' | cut -d'"' -f2 || true
}

expect_link_to() {
  local slug="$1" expected actual
  wp_cli option update "$PRIVACY_SETTING" "$(page_id "$slug")" >/dev/null
  expected="$(page_url "$slug")"
  actual="$(footer_privacy_address)"
  [[ "$actual" == "$expected" ]] || fail "with '$slug' chosen, the footer links to '$actual', not '$expected'"
  log "with '$slug' chosen, the footer links to it"
}

expect_no_link() {
  wp_cli option update "$PRIVACY_SETTING" 0 >/dev/null
  [[ -z "$(footer_privacy_address)" ]] || fail "with no privacy page chosen, the footer still has a privacy link"
  log "with no privacy page chosen, the footer has no privacy link"
}

main() {
  load_settings
  ORIGINAL_PRIVACY_PAGE="$(wp_cli option get "$PRIVACY_SETTING")"
  expect_link_to privacy-policy
  expect_link_to about
  expect_no_link
  # Checked here as well as at the end of bin/test, so a notice from the theme's filter is named
  # by this scenario.
  expect_clean_debug_log
  log "PASSED"
}

main "$@"
