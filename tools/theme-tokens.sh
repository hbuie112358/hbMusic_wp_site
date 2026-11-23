#!/usr/bin/env bash
# The design tokens a site's look must define (template plan 1.6b, T13): every token the component
# stylesheets, or the theme.json itself, read as var(--wp--custom--…), var(--wp--preset--color--…)
# or var(--wp--preset--shadow--…) is defined in that theme.json. CSS treats an undefined token as
# unset and says nothing, so a site's look (this site's, the starter's) missing one would quietly
# lose a color or a size. Sourced by bin/check and tested on known examples by
# tests/tools/theme-tokens/run.sh. Needs bash, grep, sed, sort, comm and jq.

readonly THEME_TOKEN_USE_PATTERN='var\(--wp--(custom|preset)--[a-z0-9-]+'
# The kinds this check knows; another preset kind (a font size, a spacing step) may come from the
# parent theme, so it is named as unknown and decided on, never passed silently.
readonly THEME_TOKEN_CHECKED_KINDS='^--wp--(custom|preset--(color|shadow))--'

# The tokens used, one per line, without the "var(" before them.
theme_tokens_used() {
  local components_dir="$1" theme_json="$2"
  grep -ohE "$THEME_TOKEN_USE_PATTERN" "$components_dir"/*.css "$theme_json" | sed 's/^var(//' | sort -u
}

# The tokens the theme.json defines, one per line, named as WordPress names them: each value of
# settings.custom by its path, a camelCase key in kebab case and the parts joined by "--" (so
# custom.callToAction.buttonText is --wp--custom--call-to-action--button-text), and each palette
# color's and shadow preset's slug. Fails when the file is not valid JSON.
#
# The kebab case follows WordPress's _wp_to_kebab_case() (wp-includes/functions.php, a port of
# lodash's kebabCase) for keys of letters and digits, checked against it on 2026-11-23: a break
# before a capital after a lower-case letter or digit (callToAction, heading2Xl), before the last
# capital of a run followed by lower case (HTMLColor is html-color), and between letters and
# digits either way (accent1 is accent-1, size2xl is size-2-xl).
theme_tokens_defined() {
  jq -r '
    def kebab: gsub("(?<a>[a-z0-9])(?<b>[A-Z])"; "\(.a)-\(.b)")
      | gsub("(?<a>[A-Z])(?<b>[A-Z][a-z])"; "\(.a)-\(.b)")
      | gsub("(?<a>[A-Za-z])(?<b>[0-9])"; "\(.a)-\(.b)")
      | gsub("(?<a>[0-9])(?<b>[A-Za-z])"; "\(.a)-\(.b)") | ascii_downcase;
    (.settings.custom // {} | paths(scalars) | map(tostring | kebab) | "--wp--custom--" + join("--")),
    (.settings.color.palette // [] | .[].slug | "--wp--preset--color--" + .),
    (.settings.shadow.presets // [] | .[].slug | "--wp--preset--shadow--" + .)
  ' "$1" | sort -u
}

# Prints one line per problem, nothing when every token used is defined: a token used but not
# defined, a token of a kind this check does not know, a missing folder or file, or a theme.json
# that is not valid JSON.
theme_token_differences() {
  local components_dir="$1" theme_json="$2" used defined
  [[ -d "$components_dir" ]] || { printf 'missing folder: %s\n' "${components_dir##*/}"; return 0; }
  [[ -f "$theme_json" ]] || { printf 'missing file: %s\n' "${theme_json##*/}"; return 0; }
  defined="$(theme_tokens_defined "$theme_json" 2>/dev/null)" || { printf 'not valid JSON: %s\n' "${theme_json##*/}"; return 0; }
  used="$(theme_tokens_used "$components_dir" "$theme_json")"
  grep -vE "$THEME_TOKEN_CHECKED_KINDS" <<<"$used" | sed '/^$/d; s/^/a kind of token this check does not know: /'
  comm -23 <(grep -E "$THEME_TOKEN_CHECKED_KINDS" <<<"$used") <(printf '%s\n' "$defined") | sed '/^$/d; s/^/used but not defined: /'
}
