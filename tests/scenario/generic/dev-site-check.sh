#!/usr/bin/env bash
# Scenario (dev site): the page check (bin/site-check, template plan 1.4b) against real WordPress.
# It passes on the dev site, having checked every test page in site.json; then, with the parent
# theme switched on in place of the site's child theme (a real fault, not a stand-in), it fails,
# naming the child theme's class. The child theme is switched back on however the check ends, and
# the page check must pass again. tests/tools/site-check/ covers the other failures with a
# stand-in site. Scenario checks run one at a time before the browser tests, so the theme switch
# disturbs no other test.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"
# shellcheck source=tools/versions.sh
source "$TOOLS_DIR/tools/versions.sh"

SITE_ADDRESS=""
CHILD_THEME=""

wp_cli() { dev_compose run --rm -T cli wp --user="$DEV_ADMIN_USER" "$@"; }

restore_child_theme() {
  [[ -n "$CHILD_THEME" ]] && wp_cli theme activate "$CHILD_THEME" >/dev/null 2>&1
  return 0
}

# The front page's link is the site's root; every other test page is at its address.
expect_every_test_page_checked() {
  local address
  while IFS= read -r address; do
    assert_output_names "$SITE_ADDRESS/$address/" "the page check's run"
  done < <(site_settings_query '.testPages[] | select(.isFrontPage != true) | .address')
  # The root alone on its line, since every other page's address also starts with it.
  assert_output_names "$SITE_ADDRESS/"$'\n' "the page check's run"
}

main() {
  load_settings
  SITE_ADDRESS="http://localhost:${DEV_SITE_PORT}"
  CHILD_THEME="$(site_setting .theme)"

  run_capturing "$TOOLS_DIR/bin/site-check" --deadline 0 "$SITE_ADDRESS"
  assert_status 0 "the page check on the dev site"
  expect_every_test_page_checked
  log "the page check passed on every test page"

  trap restore_child_theme EXIT
  wp_cli theme activate "$PARENT_THEME_SLUG" >/dev/null
  run_capturing "$TOOLS_DIR/bin/site-check" --deadline 0 "$SITE_ADDRESS"
  assert_status 1 "the page check with the parent theme active"
  assert_output_names "wp-child-theme-$CHILD_THEME" "the page check with the parent theme active"
  log "with the parent theme active, the page check failed, naming the child theme"

  restore_child_theme
  run_capturing "$TOOLS_DIR/bin/site-check" --deadline 0 "$SITE_ADDRESS"
  assert_status 0 "the page check after the child theme was switched back on"
  log "the child theme is active again and the page check passes"
}

main "$@"
