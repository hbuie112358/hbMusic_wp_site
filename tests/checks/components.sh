# shellcheck shell=bash
# This site's own checks of its theme's components (template plan T20), loaded by bin/check after
# its own checks. They stay with the site until the components move into their shared plugin
# (template plan 2.3), whose repository then checks them. Uses what bin/check provides to a site's
# checks: run_check and log, TOOLS_DIR, PROJECT_DIR, SITE_THEME_DIR, SITE_PHP_PREFIX and
# COMPONENT_EXAMPLES_DIR.

# shellcheck source=tools/theme-tokens.sh
source "$TOOLS_DIR/tools/theme-tokens.sh"

# The theme's component stylesheets load by name (plan D29): <PREFIX>_COMPONENT_STYLES and
# <PREFIX>_FORM_STYLESHEET in functions.php name them (the prefix: SITE_PHP_PREFIX), and WordPress
# silently loads nothing for a name without a file. So the names and the files in
# assets/css/components/ must match, both ways.
component_styles_match_files() {
  local theme_dir="$SITE_THEME_DIR" listed on_disk difference
  # The block components, the form's stylesheet (loaded by page) and the video facade's (loaded
  # with a page's videos, includes/video-facade.php).
  listed="$(sed -n "/^const ${SITE_PHP_PREFIX}_COMPONENT_STYLES/,/^);/p" "$theme_dir/functions.php" | grep -oE "'[a-z0-9-]+'" | tr -d "'"
    sed -nE "s#^const ${SITE_PHP_PREFIX}_(FORM|VIDEO_FACADE)_STYLESHEET *= 'assets/css/components/([a-z0-9-]+)\.css';#\2#p" "$theme_dir/functions.php" "$theme_dir/includes/video-facade.php")"
  on_disk="$(find "$theme_dir/assets/css/components" -maxdepth 1 -name '*.css' -printf '%f\n' | sed 's/\.css$//')"
  if [[ -z "$listed" ]]; then
    log "functions.php lists no component stylesheets; the list or this check's pattern changed"
    return 1
  fi
  difference="$(diff <(sort -u <<<"$listed") <(sort -u <<<"$on_disk"))" && return 0
  log "Component names (<) and files in assets/css/components/ (>) differ:"
  log "$difference"
  return 1
}

# Every design token the component stylesheets and theme.json read is defined in the site's
# theme.json (tools/theme-tokens.sh, template plan 1.6b): CSS treats an undefined token as unset and
# says nothing, so a look missing one would quietly lose a color or a size.
theme_defines_every_token() {
  local differences
  differences="$(theme_token_differences "$SITE_THEME_DIR/assets/css/components" "$SITE_THEME_DIR/theme.json")"
  [[ -z "$differences" ]] && return 0
  log "The theme's design tokens are incomplete:"
  printf '%s\n' "$differences" | sed 's/^/    /' >&2
  return 1
}

# Every one of the theme's own components (named site-…) appears on the components' example pages
# or in the theme's template parts, so the browser tests (accessibility, policy, debug log) see it
# on neutral content whatever the site's own pages hold (template plan T10). Components named
# after a WordPress block (buttons) are seen wherever that block is. A class counts by its prefix,
# so site-media covers site-media-placeholder and site-hero covers site-hero__photo.
components_shown_on_example_pages() {
  local theme_dir="$SITE_THEME_DIR" component missing=0
  for component in $(sed -n "/^const ${SITE_PHP_PREFIX}_COMPONENT_STYLES/,/^);/p" "$theme_dir/functions.php" | grep -oE "'site-[a-z0-9-]+'" | tr -d "'"); do
    grep -qE "class=\"[^\"]*\\b$component\\b" "$COMPONENT_EXAMPLES_DIR"/*.html "$theme_dir"/parts/*.html && continue
    log "$component appears on no component example page (${COMPONENT_EXAMPLES_DIR#"$TOOLS_DIR"/}/) or template part; add a neutral example"
    missing=1
  done
  return "$missing"
}

run_check "Component stylesheets match their list" component_styles_match_files
run_check "The theme defines every design token used" theme_defines_every_token
run_check "Components appear on the example pages" components_shown_on_example_pages
