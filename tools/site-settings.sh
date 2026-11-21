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

# The lines a jq program prints from site.json, for lists such as the plugins' slugs.
site_settings_query() {
  local program="$1"
  jq -r "$program" "$SITE_SETTINGS_FILE"
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
