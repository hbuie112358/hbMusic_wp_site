# shellcheck shell=bash
# This repository's checks of the starter (starter/, template plan 1.6b, T20), loaded by bin/check
# after its own checks: the site layer a new site begins from, held to the same rules as this
# site's, so it never drifts from the theme code it stands on. Its theme is checked against this
# site's component stylesheets and theme files, which it is assembled with (1.6c) until 2.3 moves
# them. They stay here until the starter has its own repository (2.4), where they become its
# ordinary checks of its own files (T15). Uses what bin/check provides to a site's checks:
# run_check and log, TOOLS_DIR, PROJECT_DIR, SITE_THEME_DIR, the site.json readers and
# theme_json_schema_matches_wordpress.

# shellcheck source=tools/theme-tokens.sh
source "$TOOLS_DIR/tools/theme-tokens.sh"
# shellcheck source=tools/site-layer.sh
source "$TOOLS_DIR/tools/site-layer.sh"

readonly STARTER_DIR="$PROJECT_DIR/starter"

# PHPCS and PHPStan on the starter's PHP with this repository's settings: the checkers, their
# settings and the starter, all read-only.
in_starter_analysis() {
  docker run --rm -w /app \
    -v "$PROJECT_DIR/vendor:/app/vendor:ro" \
    -v "$PROJECT_DIR/phpcs.xml.dist:/app/phpcs.xml.dist:ro" \
    -v "$PROJECT_DIR/phpstan.neon.dist:/app/phpstan.neon.dist:ro" \
    -v "$STARTER_DIR:/app/starter:ro" \
    "$COMPOSER_IMAGE" "$@"
}

starter_site_json_is_valid() {
  local problems
  problems="$(site_settings_problems "$STARTER_DIR/site.json")" || {
    log "starter/site.json is not valid JSON (jq's message is above)"
    return 1
  }
  problems+="$(site_settings_missing_test_pages "$STARTER_DIR/site.json" "$STARTER_DIR/tests/dev-content")"
  [[ -z "$problems" ]] && return 0
  log "starter/site.json does not follow the rules in the tools' tools/site-settings.jq, or lacks a page's content:"
  printf '%s\n' "$problems" | sed 's/^/    /' >&2
  return 1
}

starter_theme_json_schema_matches_wordpress() {
  theme_json_schema_matches_wordpress "$STARTER_DIR/theme/theme.json"
}

starter_defines_every_token() {
  local differences
  differences="$(theme_token_differences "$SITE_THEME_DIR/assets/css/components" "$STARTER_DIR/theme/theme.json")"
  [[ -z "$differences" ]] && return 0
  log "The starter's design tokens are incomplete:"
  printf '%s\n' "$differences" | sed 's/^/    /' >&2
  return 1
}

starter_holds_the_site_layer() {
  local differences
  differences="$(site_layer_differences "$TOOLS_DIR/tools/site-layer-files.txt" "$STARTER_DIR/theme" "$SITE_THEME_DIR")"
  [[ -z "$differences" ]] && return 0
  log "starter/theme/ and the tools' tools/site-layer-files.txt disagree:"
  printf '%s\n' "$differences" | sed 's/^/    /' >&2
  return 1
}

# The starter names nothing of this site but the shared theme code's prefix (the site's slug),
# which its PHP and patterns must use until template plan 2.3 renames that prefix. Its assembled
# theme (starter/themes/, build output ignored by git, template plan 1.6c) holds this site's
# shared theme files and is not the starter's own.
starter_names_nothing_of_this_site() {
  local slug name patterns=()
  slug="$(site_setting .slug)"
  while IFS= read -r name; do
    [[ "$name" == "$slug" ]] || patterns+=(-e "$name")
  done < <(site_settings_query '.namesSharedCodeMustNotUse[]')
  ((${#patterns[@]} > 0)) || return 0
  ! grep -rniF --exclude-dir=themes "${patterns[@]}" "$STARTER_DIR"
}

run_check "Starter: site.json follows its rules" starter_site_json_is_valid
run_check "Starter: theme.json schema matches WordPress" starter_theme_json_schema_matches_wordpress
run_check "Starter: defines every design token used" starter_defines_every_token
run_check "Starter: holds exactly the site layer" starter_holds_the_site_layer
run_check "Starter: names nothing of this site" starter_names_nothing_of_this_site
run_check "Starter: WordPress Coding Standards (PHPCS)" in_starter_analysis php "$PHPCS_ENTRY" starter
run_check "Starter: static analysis (PHPStan)" in_starter_analysis php "$PHPSTAN_ENTRY" analyse --no-progress --memory-limit=1G starter/theme
