# shellcheck shell=bash
# This repository's checks of the starter (starter/, template plan 1.6b, T20), loaded by bin/check
# after its own checks: the theme a new site begins from, held to the same rules as this site's.
# Since template plan 2.4b the starter has a full child theme of its own (T29): its site layer
# (the tools' tools/site-layer-files.txt) and a copy of the shared theme files, which must stay
# identical to this site's until the starter has its own repository (2.4c), where these become its
# ordinary checks of its own files (T15) and the starter's theme the master copy. Uses what
# bin/check provides to a site's checks: run_check and log, TOOLS_DIR, PROJECT_DIR,
# SITE_THEME_DIR, the site.json readers, theme_json_schema_matches_wordpress and
# tools/theme-tokens.sh, which bin/check loads itself (a second load fails on its readonly
# settings).

# shellcheck source=tools/site-layer.sh
source "$TOOLS_DIR/tools/site-layer.sh"

readonly STARTER_DIR="$PROJECT_DIR/starter"
STARTER_THEME_DIR="$STARTER_DIR/themes/$(jq -r '.theme' "$STARTER_DIR/site.json")"
readonly STARTER_THEME_DIR
readonly SITE_LAYER_LIST="$TOOLS_DIR/tools/site-layer-files.txt"
# A picture the shared stylesheets and scripts name, such as url("../../images/grain.png").
readonly SHARED_PICTURE_REFERENCE='images/[A-Za-z0-9._-]+\.(png|jpe?g|gif|svg|webp|avif)'

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

# The starter's own site-facts.json (template plan 2.4b-2, T31), by the tools' rules
# (site_facts_problems, tools/site-facts.jq), as bin/check holds this site's.
starter_site_facts_are_valid() {
  local facts_file="$STARTER_THEME_DIR/site-facts.json" problems shown
  shown="${facts_file#"$PROJECT_DIR"/}"
  [[ -f "$facts_file" ]] || { log "$shown is missing; the starter's theme reads its facts from it"; return 1; }
  problems="$(site_facts_problems "$facts_file")" || {
    log "$shown is not valid JSON (jq's message is above)"
    return 1
  }
  [[ -z "$problems" ]] && return 0
  log "$shown does not follow the rules in the tools' tools/site-facts.jq:"
  printf '%s\n' "$problems" | sed 's/^/    /' >&2
  return 1
}

starter_theme_json_schema_matches_wordpress() {
  theme_json_schema_matches_wordpress "$STARTER_THEME_DIR/theme.json"
}

starter_defines_every_token() {
  local differences
  differences="$(theme_token_differences "$STARTER_THEME_DIR/assets/css/components" "$STARTER_THEME_DIR/theme.json")"
  [[ -z "$differences" ]] && return 0
  log "The starter's design tokens are incomplete:"
  printf '%s\n' "$differences" | sed 's/^/    /' >&2
  return 1
}

# A theme's shared files, one per line, relative to its folder: every file outside the site layer
# and outside assets/images/ (the shared pictures are found by shared_theme_pictures, since a
# site layer adds its own pictures there).
shared_theme_files() {
  local theme_dir="$1"
  (cd "$theme_dir" && find . -type f -printf '%P\n') |
    grep -vxF -f <(site_layer_listed_files "$SITE_LAYER_LIST") | grep -v '^assets/images/' | sort
}

# The pictures a theme's shared files name, one per line, relative to its folder.
shared_theme_pictures() {
  local theme_dir="$1"
  shared_theme_files "$theme_dir" |
    (cd "$theme_dir" && xargs -r -d '\n' grep -ohE "$SHARED_PICTURE_REFERENCE" --) |
    sed 's#^#assets/#' | sort -u
}

# One line when a shared file present in this site's theme is missing from or differs in the
# starter's.
shared_file_difference() {
  local path="$1"
  [[ -f "$SITE_THEME_DIR/$path" ]] || { printf "missing from this site's theme: %s\n" "$path"; return 0; }
  [[ -f "$STARTER_THEME_DIR/$path" ]] || { printf "only in this site's theme: %s\n" "$path"; return 0; }
  cmp -s "$SITE_THEME_DIR/$path" "$STARTER_THEME_DIR/$path" || printf 'differs: %s\n' "$path"
}

# One line per difference between the two themes' shared files, both ways. This site's
# screenshot.png is its own; the starter carries none (template plan T15), so one there is named.
shared_theme_differences() {
  local site_files starter_files path
  site_files="$(shared_theme_files "$SITE_THEME_DIR" | grep -vxF 'screenshot.png')"
  starter_files="$(shared_theme_files "$STARTER_THEME_DIR")"
  comm -13 <(printf '%s\n' "$site_files") <(printf '%s\n' "$starter_files") |
    sed "/^\$/d; s/^/only in the starter's theme: /"
  while IFS= read -r path; do
    shared_file_difference "$path"
  done < <({ printf '%s\n' "$site_files"; shared_theme_pictures "$SITE_THEME_DIR"; } | sed '/^$/d')
}

starter_shares_this_sites_theme_files() {
  local differences
  [[ -d "$STARTER_THEME_DIR" ]] || { log "The starter's theme folder is missing: ${STARTER_THEME_DIR#"$PROJECT_DIR"/}"; return 1; }
  differences="$(shared_theme_differences)"
  [[ -z "$differences" ]] && return 0
  log "The starter's shared theme files differ from this site's (copy the change into both, template plan T29):"
  printf '%s\n' "$differences" | sed 's/^/    /' >&2
  return 1
}

# The starter names nothing of this site, its slug included: the shared theme code's names are
# the same in every site (template plan T30), and its theme is now its own, not build output.
starter_names_nothing_of_this_site() {
  local name patterns=()
  while IFS= read -r name; do
    patterns+=(-e "$name")
  done < <(site_settings_query '.namesSharedCodeMustNotUse[]')
  ((${#patterns[@]} > 0)) || return 0
  ! grep -rniF "${patterns[@]}" "$STARTER_DIR"
}

run_check "Starter: site.json follows its rules" starter_site_json_is_valid
run_check "Starter: site-facts.json follows its rules" starter_site_facts_are_valid
run_check "Starter: theme.json schema matches WordPress" starter_theme_json_schema_matches_wordpress
run_check "Starter: defines every design token used" starter_defines_every_token
run_check "Starter: shares this site's theme files" starter_shares_this_sites_theme_files
run_check "Starter: names nothing of this site" starter_names_nothing_of_this_site
run_check "Starter: WordPress Coding Standards (PHPCS)" in_starter_analysis php "$PHPCS_ENTRY" starter
run_check "Starter: static analysis (PHPStan)" in_starter_analysis php "$PHPSTAN_ENTRY" analyse --no-progress --memory-limit=1G "starter/themes/$(basename "$STARTER_THEME_DIR")"
