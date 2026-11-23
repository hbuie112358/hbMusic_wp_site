#!/usr/bin/env bash
# Scenario (dev site): what the Site Hardening plugin refuses or removes outside the admin (plan
# step 8a, D26): xmlrpc.php is refused (docs/SITE_CHECKLIST.md 4.4), no page points to it with an
# X-Pingback header, Yoast SEO's version comment is gone, neither the pages nor the feed name
# WordPress's version, and no response names the PHP version (3.6). Also (handbook 12, 3.1 and 4.10): HSTS only on HTTPS requests, and unfiltered HTML for
# Administrators only. The headers on every page are
# checked in tests/e2e/specs/dev/generic/theme.spec.ts, Application Passwords in
# tests/e2e/specs/dev/plugins/site-hardening/hardening.spec.ts.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"

readonly XML_RPC_REFUSED_STATUS=403
readonly HSTS_HEADER='Strict-Transport-Security: max-age=31536000'
# WordPress sends X-Pingback only on a single post that allows pings (wp-includes/class-wp.php),
# and the dev site has none, so the check creates one and deletes it again however it ends. The
# unfiltered-HTML check does the same with its two drafts.
PROBE_POST_IDS=()
trap 'remove_probe_posts' EXIT

site_url() { printf 'http://localhost:%s%s' "$DEV_SITE_PORT" "$1"; }

remove_probe_posts() {
  local post_id
  for post_id in "${PROBE_POST_IDS[@]}"; do
    dev_compose run --rm -T cli wp post delete "$post_id" --force >/dev/null 2>&1 || true
  done
}

expect_xml_rpc_refused() {
  local method="$1" status
  status="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 10 -X "$method" "$(site_url /xmlrpc.php)")"
  [[ "$status" == "$XML_RPC_REFUSED_STATUS" ]] || fail "xmlrpc.php answered $method with $status, not $XML_RPC_REFUSED_STATUS"
  log "xmlrpc.php refuses $method with $status"
}

expect_no_pingback_header() {
  local address headers probe_post_id
  probe_post_id="$(dev_compose run --rm -T cli wp post create --post_type=post --post_status=publish \
    --post_title="Pingback probe" --ping_status=open --porcelain)"
  PROBE_POST_IDS+=("$probe_post_id")
  address="$(dev_compose run --rm -T cli wp post list --post__in="$probe_post_id" --post_type=post --field=url)"
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

# WordPress names its version in a generator tag in every page's head and a generator line in
# every feed (handbook 12, 3.6's reason). Each must have loaded, or a missing line proves nothing.
expect_no_wordpress_version() {
  local page feed version
  version="$(dev_compose run --rm -T cli wp core version </dev/null)"
  page="$(curl -sS --max-time 10 "$(site_url /)")"
  feed="$(curl -sS --max-time 10 "$(site_url "/?feed=rss2")")"
  [[ "$page" == *'<head'* && "$page" == *'</html>'* ]] || fail "the home page did not load"
  [[ "$feed" == *'<rss'* && "$feed" == *'</rss>'* ]] || fail "the feed did not load"
  ! grep -qi 'name="generator"[^>]*WordPress' <<<"$page" || fail "the home page names WordPress in a generator tag"
  ! grep -qi '<generator>' <<<"$feed" || fail "the feed carries a generator line"
  [[ "$page$feed" != *"?v=$version"* && "$page$feed" != *"WordPress $version"* ]] ||
    fail "the home page or the feed names WordPress $version"
  log "neither the home page nor the feed names WordPress or its version"
}

# HSTS (3.1): the dev site is plain HTTP, so the plugin's header list is asked for both kinds of
# request, and the real page must not carry the header. Whether the send path passes is_ssl()
# through is seen on staging, which runs over HTTPS (plan, item 3).
expect_hsts_only_over_https() {
  local https_headers http_headers page_headers
  https_headers="$(dev_compose run --rm -T cli wp eval 'echo implode( "\n", sitehardening_security_headers( true ) );')"
  http_headers="$(dev_compose run --rm -T cli wp eval 'echo implode( "\n", sitehardening_security_headers( false ) );')"
  grep -qxF "$HSTS_HEADER" <<<"$https_headers" || fail "an HTTPS request gets no '$HSTS_HEADER'"
  [[ "$http_headers" == *'Content-Security-Policy:'* ]] || fail "the plugin's header list is empty: $http_headers"
  ! grep -qi '^strict-transport-security:' <<<"$http_headers" || fail "a plain-HTTP request gets HSTS"
  page_headers="$(curl -sS -D - -o /dev/null --max-time 10 "$(site_url /)")"
  ! grep -qi '^strict-transport-security:' <<<"$page_headers" || fail "the plain-HTTP home page sends HSTS"
  log "HSTS for one year on HTTPS requests only, without subdomains or preload"
}

# Saves a draft as the given user through WP-CLI, which applies WordPress's kses filter as it
# would for that user in the editor, and prints what was stored.
stored_content_of_draft_by() {
  local user="$1" content="$2" post_id
  post_id="$(dev_compose run --rm -T cli wp post create --user="$user" --post_type=page --post_status=draft \
    --post_title="Unfiltered HTML probe" --post_content="$content" --porcelain)"
  PROBE_POST_IDS+=("$post_id")
  dev_compose run --rm -T cli wp post get "$post_id" --field=post_content
}

# Unfiltered HTML for Administrators only (4.10, H79): an Editor's script is removed, while the
# site's own kinds of content saved by an Editor (a video's Embed block, the form's shortcode)
# lose nothing; an Administrator's script stays, so the rule is not simply "strip everything".
expect_unfiltered_html_for_administrators_only() {
  local script='<script>document.title = "probe";</script>'
  local embed='<!-- wp:embed {"url":"https://www.youtube.com/watch?v=probe0000","type":"video","providerNameSlug":"youtube"} -->
<figure class="wp-block-embed is-type-video is-provider-youtube wp-block-embed-youtube"><div class="wp-block-embed__wrapper">
https://www.youtube.com/watch?v=probe0000
</div></figure>
<!-- /wp:embed -->'
  local shortcode='[contact-form-7 id="1" title="Booking"]'
  local editor_stored admin_stored
  editor_stored="$(stored_content_of_draft_by "$DEV_EDITOR_USER" "$embed
$shortcode
$script")"
  [[ "$editor_stored" != *'<script'* ]] || fail "an Editor's script was kept: $editor_stored"
  [[ "$editor_stored" == *"$embed"* ]] || fail "an Editor's video Embed block was changed: $editor_stored"
  [[ "$editor_stored" == *"$shortcode"* ]] || fail "an Editor's form shortcode was changed: $editor_stored"
  admin_stored="$(stored_content_of_draft_by "$DEV_ADMIN_USER" "$script")"
  [[ "$admin_stored" == *"$script"* ]] || fail "an Administrator's script was removed: $admin_stored"
  log "an Editor's script is removed, their video and form are kept; an Administrator's script stays"
}

main() {
  load_settings
  expect_xml_rpc_refused POST
  expect_xml_rpc_refused GET
  expect_no_pingback_header
  expect_no_version_comment
  expect_no_wordpress_version
  expect_no_php_version_header
  expect_hsts_only_over_https
  expect_unfiltered_html_for_administrators_only
  # Checked here as well as at the end of bin/test, so a refusal that costs a PHP notice is
  # named by this scenario.
  expect_clean_debug_log
  log "PASSED"
}

main "$@"
