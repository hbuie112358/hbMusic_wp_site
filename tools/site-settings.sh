#!/usr/bin/env bash
# Reading and checking site.json, the site's facts (template plan T7), against the rules in
# tools/site-settings.jq and the explanation in tools/site-settings.md. Needs jq. Sourced, never
# run; the sourcing script defines REPO_ROOT.

readonly SITE_SETTINGS_FILE="$REPO_ROOT/site.json"
readonly SITE_SETTINGS_EXPLANATION="$REPO_ROOT/tools/site-settings.md"
readonly SITE_SETTINGS_RULES_DIR="$REPO_ROOT/tools"

# The rules as a jq module, followed by a program using them.
site_settings_jq() {
  local program="$1"
  shift
  jq -L "$SITE_SETTINGS_RULES_DIR" "include \"site-settings\"; $program" "$@"
}

# Prints one line per problem in a settings file, nothing for a valid one. Fails, with jq's own
# message, when the file is not JSON at all: then there is nothing to check field by field.
site_settings_problems() {
  local settings_file="$1"
  site_settings_jq 'site_settings_problems' -r "$settings_file"
}

# One text value of site.json by its jq path, such as ".theme"; fails when it is missing or not
# text, so a script never goes on with an empty name.
site_setting() {
  local path="$1"
  jq -er "$path | strings" "$SITE_SETTINGS_FILE"
}

# The Docker names built from the site's slug (template plan T7): the download caches, and the dev
# site's database volume, which Docker Compose names "<project>_db_data" after compose.dev.yaml's
# project, "<slug>-dev". They are the names this site always had, so no cache or database is lost.
# Sets COMPOSER_CACHE_VOLUME, NPM_CACHE_VOLUME and DEV_DATABASE_VOLUME. Refuses, with a message,
# when jq is missing or site.json breaks its rules, rather than going on with another name.
load_site_volume_names() {
  local problems slug
  command -v jq >/dev/null || { printf 'jq is not installed; the tools need it to read site.json\n' >&2; return 1; }
  [[ -f "$SITE_SETTINGS_FILE" ]] || { printf 'site.json is missing; tools/site-settings.md lists its fields\n' >&2; return 1; }
  problems="$(site_settings_problems "$SITE_SETTINGS_FILE")" || { printf 'site.json is not valid JSON\n' >&2; return 1; }
  [[ -z "$problems" ]] || { printf 'site.json does not follow its rules: %s\n' "$(paste -sd ';' <<<"$problems")" >&2; return 1; }
  slug="$(site_setting .slug)"
  declare -gr COMPOSER_CACHE_VOLUME="${slug}_composer_cache"
  declare -gr NPM_CACHE_VOLUME="${slug}_npm_cache"
  declare -gr DEV_DATABASE_VOLUME="${slug}-dev_db_data"
}

# The lines a jq program prints from site.json, for lists such as the plugins' slugs.
site_settings_query() {
  local program="$1"
  jq -r "$program" "$SITE_SETTINGS_FILE"
}

# Prints a line for each test page in a settings file whose content file is missing from the
# content folder, starting with the page's address. bin/dev-site refuses to build without them.
site_settings_missing_test_pages() {
  local settings_file="$1" content_dir="$2" address
  while IFS= read -r address; do
    [[ -f "$content_dir/$address.html" ]] || printf '%s: the test page has no content file %s.html\n' "$address" "$address"
  done < <(jq -r '.testPages[].address' "$settings_file")
}

# Prints a line, starting with "theme", when a settings file's theme names no folder in the themes
# folder; nothing otherwise. Every check of the theme reads that folder.
site_settings_theme_problem() {
  local settings_file="$1" themes_dir="$2" theme
  theme="$(jq -r '.theme' "$settings_file")"
  [[ -d "$themes_dir/$theme" ]] && return 0
  printf 'theme: "%s" names no folder in %s\n' "$theme" "${themes_dir#"$REPO_ROOT"/}"
}

site_settings_field_names() {
  site_settings_jq 'site_settings_field_names' -n -r
}

# The fields an explanation page explains: each heading "### <field>", backticks allowed.
site_settings_explained_names() {
  local explanation_file="$1"
  sed -nE 's/^### `?([^`]+)`?[[:space:]]*$/\1/p' "$explanation_file"
}

# Prints a line for each field the page does not explain and each heading that names no field;
# nothing when the page and the rules agree.
site_settings_explanation_differences() {
  local explanation_file="$1" fields explained
  fields="$(site_settings_field_names | sort -u)"
  explained="$(site_settings_explained_names "$explanation_file" | sort -u)"
  comm -23 <(printf '%s\n' "$fields") <(printf '%s\n' "$explained") | sed '/^$/d; s/^/not explained: /'
  comm -13 <(printf '%s\n' "$fields") <(printf '%s\n' "$explained") | sed '/^$/d; s/^/explained but not a field: /'
}
