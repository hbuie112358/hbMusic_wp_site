#!/usr/bin/env bash
# Scenario (dev site): what the Site Hardening plugin refuses or removes outside the admin (plan
# step 8a, D26): xmlrpc.php is refused (docs/SITE_CHECKLIST.md 4.4), no page points to it with an
# X-Pingback header, Yoast SEO's version comment is gone, and no response names the PHP version
# (3.6). The headers on every page are
# checked in tests/e2e/specs/dev/theme.spec.ts, Application Passwords in hardening.spec.ts.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

readonly XML_RPC_REFUSED_STATUS=403
# WordPress sends X-Pingback only on a single post that allows pings (wp-includes/class-wp.php),
# and the dev site has none, so the check creates one and deletes it again however it ends.
PROBE_POST_ID=""
trap 'remove_probe_post' EXIT

site_url() { printf 'http://localhost:%s%s' "$DEV_SITE_PORT" "$1"; }

remove_probe_post() {
  [[ -n "$PROBE_POST_ID" ]] || return 0
  dev_compose run --rm -T cli wp post delete "$PROBE_POST_ID" --force >/dev/null 2>&1 || true
}

expect_xml_rpc_refused() {
  local method="$1" status
  status="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 10 -X "$method" "$(site_url /xmlrpc.php)")"
  [[ "$status" == "$XML_RPC_REFUSED_STATUS" ]] || fail "xmlrpc.php answered $method with $status, not $XML_RPC_REFUSED_STATUS"
  log "xmlrpc.php refuses $method with $status"
}

expect_no_pingback_header() {
  local address headers
  PROBE_POST_ID="$(dev_compose run --rm -T cli wp post create --post_type=post --post_status=publish \
    --post_title="Pingback probe" --ping_status=open --porcelain)"
  address="$(dev_compose run --rm -T cli wp post list --post__in="$PROBE_POST_ID" --post_type=post --field=url)"
  headers="$(curl -sS -D - -o /dev/null --max-time 10 "$address")"
  [[ "$headers" == *" 200"* ]] || fail "the probe post did not load: $headers"
  ! grep -qi '^x-pingback:' <<<"$headers" || fail "a post that allows pings sends X-Pingback"
  log "a post that allows pings sends no X-Pingback header"
}

# Every kind of response WordPress builds with PHP: a page, the login page, the admin (which
# forwards to the login), the REST API, AJAX, the feed and XML-RPC's refusal. Each must answer,
# or a missing header would prove nothing.
readonly PHP_RESPONSE_PATHS=(/ /wp-login.php /wp-admin/ /wp-json/ /wp-admin/admin-ajax.php "/?feed=rss2" /xmlrpc.php)

expect_no_php_version_header() {
  local path headers
  for path in "${PHP_RESPONSE_PATHS[@]}"; do
    headers="$(curl -sS -D - -o /dev/null --max-time 10 "$(site_url "$path")")"
    [[ "$headers" == HTTP/* ]] || fail "$path did not answer: $headers"
    ! grep -qi '^x-powered-by:' <<<"$headers" || fail "$path names the PHP version in X-Powered-By"
  done
  log "no response names the PHP version (${#PHP_RESPONSE_PATHS[@]} kinds checked)"
}

# Yoast's other tags must still be there, or a missing comment would prove nothing.
expect_no_version_comment() {
  local page
  page="$(curl -sS --max-time 10 "$(site_url /)")"
  [[ "$page" == *'property="og:url"'* ]] || fail "Yoast SEO's tags are missing from the home page"
  [[ "$page" != *'Yoast SEO plugin'* ]] || fail "the home page names Yoast SEO in a comment"
  log "Yoast SEO's tags are there, its version comment is not"
}

main() {
  load_settings
  expect_xml_rpc_refused POST
  expect_xml_rpc_refused GET
  expect_no_pingback_header
  expect_no_version_comment
  expect_no_php_version_header
  # Checked here as well as at the end of bin/test, so a refusal that costs a PHP notice is
  # named by this scenario.
  expect_empty_debug_log
  log "PASSED"
}

main "$@"
