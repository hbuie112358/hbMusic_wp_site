#!/usr/bin/env bash
# Assembles a site's full child theme from its site layer (template plan 1.6c, T14): the shared
# theme code is this repository's theme, so the full theme is that theme's files, each site-layer
# file (tools/site-layer-files.txt) replaced by the layer's own, and the layer's pictures added.
# It stands in for template plan 2.4's starter theme until 2.3 moves the shared code into its
# plugin. The result is build output, ignored by git and made again on every build, so it never
# goes stale. Sourced by bin/dev-site and tested on known examples by
# tests/tools/site-theme/run.sh. Needs bash, cp, find, rm, mv and sed; the layer is checked against
# the list first (tools/site-layer.sh).

# Writes the full theme into the output folder, replacing whatever was there, in a sibling folder
# first and moved into place at the end, so a failed copy never leaves half a theme. Prints the
# problems instead and fails when the layer does not match the list.
assemble_site_theme() {
  local list_file="$1" layer_dir="$2" shared_theme_dir="$3" output_dir="$4" problems
  problems="$(site_layer_differences "$list_file" "$layer_dir" "$shared_theme_dir")"
  [[ -z "$problems" ]] || { printf '%s\n' "$problems"; return 1; }
  # Chained, not left to set -e, which a caller testing this function's result switches off.
  rm -rf "$output_dir.new" && mkdir -p "$(dirname "$output_dir")" &&
    cp -a "$shared_theme_dir" "$output_dir.new" && cp -a "$layer_dir/." "$output_dir.new/" &&
    rm -rf "$output_dir" && mv "$output_dir.new" "$output_dir" && return 0
  printf 'could not write the theme into %s\n' "$output_dir"
  return 1
}
