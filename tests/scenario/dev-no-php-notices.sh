#!/usr/bin/env bash
# Scenario (dev site): visiting every page of the dev site leaves WordPress's debug log empty:
# no PHP error, warning, notice or deprecation (plan step 4c, docs/SITE_CHECKLIST.md 6.9). The
# pages are every published page WordPress lists, the login page and a missing page (the
# theme's 404 template).
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

page_addresses() {
  local address="http://localhost:${DEV_SITE_PORT}"
  dev_compose run --rm -T cli wp post list --post_type=page --post_status=publish --field=url
  printf '%s\n' "$address/" "$address/wp-login.php" "$address/no-such-page-$$/"
}

visit_every_page() {
  local address count=0
  while IFS= read -r address; do
    [[ -n "$address" ]] || continue
    # Only that the page was produced; its content is the browser tests' concern.
    curl -sS -o /dev/null --max-time 15 "$address" || fail "the request for $address failed"
    count=$((count + 1))
  done < <(page_addresses)
  ((count >= 4)) || fail "only $count pages were visited; the test content seems to be missing (run bin/dev-site)"
  log "visited $count pages"
}

main() {
  load_settings
  visit_every_page
  expect_empty_debug_log
}

main "$@"
