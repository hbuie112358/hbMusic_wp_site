#!/usr/bin/env bash
# A site layer kept in step with the list of site-layer files (tools/site-layer-files.txt, template
# plan 1.6b): the layer (the starter's, starter/theme/) holds exactly the listed files plus its own
# pictures under assets/images/, and the full theme it replaces holds every listed file too, so
# each file a layer brings has the file it replaces. Sourced by bin/check and tested on known
# examples by tests/tools/site-layer/run.sh. Needs bash, find, grep, sed, sort and comm.

# The listed paths, one per line, without comments or blank lines.
site_layer_listed_files() {
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$1" | sort -u
}

# The layer's files, one per line, relative to its folder, without its pictures.
site_layer_files_present() {
  (cd "$1" && find . -type f -printf '%P\n') | grep -v '^assets/images/' | sort -u
}

# Prints one line per problem, nothing when the layer and the theme agree with the list: a listed
# file the layer lacks, a file in the layer that is not listed (nor a picture), a listed file the
# theme lacks, or a missing list or folder.
site_layer_differences() {
  local list_file="$1" layer_dir="$2" theme_dir="$3" listed path
  [[ -f "$list_file" ]] || { printf 'missing list: %s\n' "${list_file##*/}"; return 0; }
  [[ -d "$layer_dir" ]] || { printf 'missing folder: %s\n' "${layer_dir##*/}"; return 0; }
  [[ -d "$theme_dir" ]] || { printf 'missing folder: %s\n' "${theme_dir##*/}"; return 0; }
  listed="$(site_layer_listed_files "$list_file")"
  comm -23 <(printf '%s\n' "$listed") <(site_layer_files_present "$layer_dir") | sed '/^$/d; s/^/listed but missing from the layer: /'
  comm -13 <(printf '%s\n' "$listed") <(site_layer_files_present "$layer_dir") | sed '/^$/d; s/^/in the layer but not listed: /'
  while IFS= read -r path; do
    [[ -f "$theme_dir/$path" ]] || printf 'listed but missing from the theme: %s\n' "$path"
  done <<<"$listed"
}
