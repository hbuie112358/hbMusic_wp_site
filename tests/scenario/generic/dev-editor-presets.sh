#!/usr/bin/env bash
# Scenario (dev site): the block editor offers only the theme's own colors, gradients, duotone
# filters, font sizes and spacing sizes, never free values (the handbook's chapter 12, 6.11; H25,
# H87). Read from WordPress's merged settings (WordPress's defaults, the parent theme and the
# child theme together), which is what the editor itself uses: a child theme that sets nothing
# inherits WordPress's "on", so checking the child's theme.json alone would miss it.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

# Each switch as "section.setting", every one of which must be false.
readonly FREE_VALUE_SWITCHES=(
  color.custom color.customGradient color.customDuotone
  typography.customFontSize typography.lineHeight typography.letterSpacing
  spacing.customSpacingSize
)

merged_settings() {
  dev_compose run --rm -T cli wp eval \
    'echo wp_json_encode( wp_get_global_settings( array(), array( "origin" => "theme" ) ) );' </dev/null
}

# Prints each switch that is not false, with its value.
switches_left_on() {
  local settings="$1" switch value
  for switch in "${FREE_VALUE_SWITCHES[@]}"; do
    value="$(jq -c --arg section "${switch%%.*}" --arg name "${switch#*.}" '.[$section][$name]' <<<"$settings")"
    [[ "$value" == false ]] || printf '%s = %s\n' "$switch" "$value"
  done
}

main() {
  local settings left_on
  load_settings
  settings="$(merged_settings)"
  jq -e 'type == "object" and has("color")' <<<"$settings" >/dev/null ||
    fail "WordPress's merged settings could not be read: ${settings:0:300}"
  left_on="$(switches_left_on "$settings")"
  [[ -z "$left_on" ]] || fail "the editor offers free values; set these to false in theme.json's settings:
$left_on"
  log "the editor offers only the theme's own values (${#FREE_VALUE_SWITCHES[@]} switches off)"
}

main "$@"
