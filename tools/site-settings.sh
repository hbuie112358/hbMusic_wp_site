#!/usr/bin/env bash
# Reading and checking site.json, the site's facts (template plan T7), against the rules in
# tools/site-settings.jq and the explanation in tools/site-settings.md. Needs jq. Sourced, never
# run; the sourcing script defines REPO_ROOT.

readonly SITE_SETTINGS_FILE="$REPO_ROOT/site.json"
readonly SITE_SETTINGS_EXPLANATION="$REPO_ROOT/tools/site-settings.md"
readonly SITE_SETTINGS_RULES_DIR="$REPO_ROOT/tools"
# Written from site.json (write_site_compose_file); ignored by git, never edited by hand.
readonly SITE_COMPOSE_FILE="$REPO_ROOT/compose.site.yaml"
# The components' example pages (template plan T10): neutral content showing each component,
# which travels with the component tests; bin/dev-site builds one page per file, at the file's
# name, outside the menu, and bin/check looks there for every component. The browser tests find
# the same folder from their own (tests/e2e/specs/dev/helpers/test-pages.ts), as the test
# container cannot read this file.
readonly COMPONENT_EXAMPLES_DIR="$REPO_ROOT/tests/e2e/specs/dev/components/pages"

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

# Refuses, with a message, when jq is missing or site.json is missing or breaks its rules, so a
# script never goes on with a wrong or empty setting.
require_valid_site_settings() {
  local problems
  command -v jq >/dev/null || { printf 'jq is not installed; the tools need it to read site.json\n' >&2; return 1; }
  [[ -f "$SITE_SETTINGS_FILE" ]] || { printf 'site.json is missing; tools/site-settings.md lists its fields\n' >&2; return 1; }
  problems="$(site_settings_problems "$SITE_SETTINGS_FILE")" || { printf 'site.json is not valid JSON\n' >&2; return 1; }
  [[ -z "$problems" ]] || { printf 'site.json does not follow its rules: %s\n' "$(paste -sd ';' <<<"$problems")" >&2; return 1; }
}

# The Docker names built from the site's slug (template plan T7): the download caches, and the dev
# site's database volume, which Docker Compose names "<project>_db_data" after compose.dev.yaml's
# project, "<slug>-dev". They are the names this site always had, so no cache or database is lost.
# Sets COMPOSER_CACHE_VOLUME, NPM_CACHE_VOLUME and DEV_DATABASE_VOLUME. Refuses, with a message,
# when site.json cannot be trusted (require_valid_site_settings), rather than going on with another
# name.
load_site_volume_names() {
  local slug
  require_valid_site_settings || return 1
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

# Prints a line for each of a settings file's own plugins with no folder in the plugins folder,
# starting with its name. Docker would otherwise mount an empty folder in its place.
site_settings_missing_local_plugins() {
  local settings_file="$1" plugins_dir="$2" plugin_slug
  while IFS= read -r plugin_slug; do
    [[ -d "$plugins_dir/$plugin_slug" ]] || printf '%s: listed in localPlugins, but no folder %s/%s\n' "$plugin_slug" "${plugins_dir#"$REPO_ROOT"/}" "$plugin_slug"
  done < <(jq -r '.localPlugins[]' "$settings_file")
}

# Writes compose.site.yaml, the dev site's own part of its recipe, from site.json (template plan
# 1.2f): the project's name ("<slug>-dev", which also names the database volume) and the folders
# mounted read-only, the theme and each of the site's own plugins, for the site and for WP-CLI.
# compose.dev.yaml holds the rest, the same for every site; Docker Compose merges the two. Written
# whole by bin/dev-site, bin/check and bin/screenshots each time they start, so it follows
# site.json; replaced in one step, so a reader never sees half a file.
write_site_compose_file() {
  local slug theme plugin_slug mounts
  slug="$(site_setting .slug)"
  theme="$(site_setting .theme)"
  mounts="      - ./themes/$theme:/var/www/html/wp-content/themes/$theme:ro"$'\n'
  while IFS= read -r plugin_slug; do
    mounts+="      - ./plugins/$plugin_slug:/var/www/html/wp-content/plugins/$plugin_slug:ro"$'\n'
  done < <(site_settings_query '.localPlugins[]')
  {
    printf '# Written from site.json by tools/site-settings.sh (write_site_compose_file); do not edit:\n'
    printf '# bin/dev-site, bin/check and bin/screenshots write it again. The rest is in compose.dev.yaml.\n'
    printf 'name: %s-dev\n\nservices:\n  wordpress:\n    volumes:\n%s  cli:\n    volumes:\n%s' "$slug" "$mounts" "$mounts"
  } >"$SITE_COMPOSE_FILE.new"
  mv "$SITE_COMPOSE_FILE.new" "$SITE_COMPOSE_FILE"
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
