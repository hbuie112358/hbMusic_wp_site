#!/usr/bin/env bash
# Scenario (dev site): the activity log (Simple History, template plan 1.5b, handbook chapter 3's
# toolkit) records who changed what: a page's title changed, and a plugin switched off and on.
# Read back through Simple History's own WP-CLI command, by its stored facts (the logger, the
# message key, the page's ID, the plugin's slug), never by its wording. Its address is stored
# anonymized (the plugin's default, kept by the user's choice). The probe page and the probe plugin
# are the check's own, deleted however it ends, so nothing other tests use is touched.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../lib.sh"

# A throwaway plugin of the check's own, put into the dev site's plugins folder (not a mount) and
# removed again, so no plugin another test uses is ever switched off.
readonly PROBE_PLUGIN="activity-log-probe"
readonly PROBE_PLUGIN_DIR="/var/www/html/wp-content/plugins/$PROBE_PLUGIN"
# Enough of the newest entries to hold this check's own, even with the site's own writing some.
readonly ENTRIES_READ=20
# An anonymized IPv4 address ends in .x (WordPress's wp_privacy_anonymize_ip, through the plugin).
readonly ANONYMIZED_ADDRESS='^[0-9]+\.[0-9]+\.[0-9]+\.x$'
PROBE_PAGE_ID=""

# No input: inside a loop, docker compose run would otherwise read the loop's own lines.
wp_cli() { dev_compose run --rm -T cli wp "$@" </dev/null; }

clean_up() {
  [[ -n "$PROBE_PAGE_ID" ]] && wp_cli post delete "$PROBE_PAGE_ID" --force >/dev/null 2>&1
  wp_cli plugin deactivate "$PROBE_PLUGIN" >/dev/null 2>&1
  dev_compose exec -T wordpress rm -rf "$PROBE_PLUGIN_DIR" </dev/null >/dev/null 2>&1
  return 0
}
trap clean_up EXIT

# The newest entry's ID, so only entries written after it count.
newest_entry_id() {
  wp_cli simple-history event list --count=1 --format=json | jq -r '.[0].ID // 0'
}

# Every entry newer than the given ID, in full (its context included), as one JSON array.
entries_after() {
  local after="$1" entry_id entries="[]"
  while IFS= read -r entry_id; do
    entries="$(jq -c --argjson entry "$(wp_cli simple-history event get "$entry_id" --format=json)" '. + [$entry]' <<<"$entries")"
  done < <(wp_cli simple-history event list --count="$ENTRIES_READ" --format=json | jq -r --argjson after "$after" '.[] | select((.ID | tonumber) > $after) | .ID')
  printf '%s' "$entries"
}

# Fails unless one of the entries has this logger, message key and context value.
expect_entry() {
  local entries="$1" logger="$2" message_key="$3" context_field="$4" context_value="$5" what="$6"
  jq -e --arg logger "$logger" --arg key "$message_key" --arg field "$context_field" --arg value "$context_value" \
    'any(.[]; .logger == $logger and ._message_key == $key and (.context[$field] | tostring) == $value)' <<<"$entries" >/dev/null ||
    fail "the activity log has no entry for $what. The entries written: $(jq -c '[.[] | {logger, _message_key}]' <<<"$entries")"
  log "the activity log recorded $what"
}

# The probe plugin: a header and nothing else, so it runs no code.
install_probe_plugin() {
  dev_compose exec -T wordpress sh -c "mkdir -p '$PROBE_PLUGIN_DIR' &&
    printf '%s\\n' '<?php' '/* Plugin Name: Activity log probe (throwaway, dev-activity-log.sh) */' >'$PROBE_PLUGIN_DIR/$PROBE_PLUGIN.php'" </dev/null
}

main() {
  local before entries
  before="$(newest_entry_id 2>&1)" || fail "Simple History's log could not be read (is the plugin active?): $before"
  [[ "$before" =~ ^[0-9]+$ ]] || fail "Simple History's log could not be read: $before"

  PROBE_PAGE_ID="$(wp_cli post create --post_type=page --post_status=publish \
    --post_title="Activity log probe $RANDOM$RANDOM" --porcelain)"
  wp_cli post update "$PROBE_PAGE_ID" --post_title="Activity log probe, changed" >/dev/null
  install_probe_plugin
  wp_cli plugin activate "$PROBE_PLUGIN" >/dev/null
  wp_cli plugin deactivate "$PROBE_PLUGIN" >/dev/null

  entries="$(entries_after "$before")"
  expect_entry "$entries" SimplePostLogger post_updated post_id "$PROBE_PAGE_ID" "the page's changed title"
  expect_entry "$entries" SimplePluginLogger plugin_deactivated plugin_slug "$PROBE_PLUGIN" "the plugin switched off"
  expect_entry "$entries" SimplePluginLogger plugin_activated plugin_slug "$PROBE_PLUGIN" "the plugin switched on"
  jq -e --arg pattern "$ANONYMIZED_ADDRESS" 'all(.[]; (.context._server_remote_addr // "") | test($pattern))' <<<"$entries" >/dev/null ||
    fail "an entry holds an address that is not anonymized"
  log "every entry's address is anonymized"
}

main "$@"
