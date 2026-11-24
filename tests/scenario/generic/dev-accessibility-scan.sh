#!/usr/bin/env bash
# Scenario (dev site): the accessibility scan (bin/accessibility-scan, template plan 1.5d-3)
# against real WordPress. It passes on the dev site, having scanned every test page in site.json
# at both widths; then, with a published probe page holding an image without alt text (a real
# fault, as an editor could make one), it fails, naming that page. The probe is deleted however the
# check ends, and the scan must pass again. Scenario checks run one at a time before the browser
# tests, so the probe page disturbs no other test.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

SITE_ADDRESS=""
PROBE_PAGE_ID=""
# A picture WordPress itself ships, so the probe needs no file of its own.
readonly PROBE_IMAGE='/wp-includes/images/w-logo-blue.png'

wp_cli() { dev_compose run --rm -T cli wp --user="$DEV_ADMIN_USER" "$@" </dev/null; }

# Deleted without a user: Yoast SEO saves a "You just deleted a Page" notice for the user who
# deletes a published page and shows it on that user's next admin page, where the dev admin's
# browser tests would meet it (its icon has no alt text). With no user, it is saved for no one.
remove_probe_page() {
  [[ -n "$PROBE_PAGE_ID" ]] &&
    dev_compose run --rm -T cli wp post delete "$PROBE_PAGE_ID" --force </dev/null >/dev/null 2>&1
  return 0
}

# The front page is scanned as the site's root; every other test page at its address.
expect_every_test_page_scanned() {
  local address
  while IFS= read -r address; do
    assert_output_names "$SITE_ADDRESS/$address/ at desktop width" "the scan of the dev site"
    assert_output_names "$SITE_ADDRESS/$address/ at phone width" "the scan of the dev site"
  done < <(site_settings_query '.testPages[] | select(.isFrontPage != true) | .address')
  assert_output_names "$SITE_ADDRESS/ at phone width" "the scan of the dev site"
}

publish_probe_page() {
  local content="<!-- wp:html --><img src=\"$PROBE_IMAGE\" width=\"80\" height=\"80\"><!-- /wp:html -->"
  PROBE_PAGE_ID="$(wp_cli post create --post_type=page --post_status=publish \
    --post_title="Accessibility scan probe" --post_name="accessibility-scan-probe-$$" \
    --post_content="$content" --porcelain)"
}

main() {
  load_settings
  SITE_ADDRESS="http://localhost:${DEV_SITE_PORT}"

  run_capturing "$TOOLS_DIR/bin/accessibility-scan" "$SITE_ADDRESS"
  assert_status 0 "the accessibility scan of the dev site"
  expect_every_test_page_scanned
  log "the scan passed on every test page at both widths"

  trap remove_probe_page EXIT
  publish_probe_page
  run_capturing "$TOOLS_DIR/bin/accessibility-scan" "$SITE_ADDRESS"
  assert_status 1 "the accessibility scan with the probe page"
  assert_output_names "accessibility-scan-probe-$$" "the accessibility scan with the probe page"
  assert_output_names "image-alt" "the accessibility scan with the probe page"
  log "with an image without alt text on a page, the scan failed, naming the page and the rule"

  remove_probe_page
  PROBE_PAGE_ID=""
  run_capturing "$TOOLS_DIR/bin/accessibility-scan" "$SITE_ADDRESS"
  assert_status 0 "the accessibility scan after the probe page was deleted"
  log "the probe page is gone and the scan passes again"
}

main "$@"
