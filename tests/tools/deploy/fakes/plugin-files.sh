#!/usr/bin/env bash
# The neutral downloaded plugin of bin/deploy's tests, as its "WordPress.org release" holds it:
# the stand-in docker builds it from this, and the test writes the release's checksum file from
# the same files, so the two always agree unless a situation tampers with the build. Sourced by
# fakes/docker and run.sh, never run.

# Writes the plugin's files for a version into a folder.
write_plugin_files() {
  local plugin_dir="$1" plugin_slug="$2" version="$3"
  mkdir -p "$plugin_dir/includes"
  printf '<?php\n/**\n * Plugin Name: Example Download\n * Version: %s\n */\n' "$version" >"$plugin_dir/$plugin_slug.php"
  printf '=== Example Download ===\nStable tag: %s\n' "$version" >"$plugin_dir/readme.txt"
  printf '<?php\n// %s %s\n' "$plugin_slug" "$version" >"$plugin_dir/includes/functions.php"
}

# WordPress.org's checksum file for those files: every file's SHA-256 by its path.
write_checksum_file() {
  local plugin_dir="$1" plugin_slug="$2" version="$3" path
  (cd "$plugin_dir" && find . -type f -printf '%P\n' | sort | while IFS= read -r path; do
    jq -n --arg path "$path" --arg sha "$(sha256sum "$path" | cut -d' ' -f1)" '{($path): {sha256: $sha}}'
  done) | jq -s --arg plugin "$plugin_slug" --arg version "$version" '{plugin: $plugin, version: $version, files: add}'
}
