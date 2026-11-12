#!/usr/bin/env bash
# Scenario (dev site): every stylesheet of the theme's components and of the Song List block is
# labelled with a fingerprint of its own contents (plan D29), so a changed stylesheet gets a new
# address. A fixed version once labelled them all; the Site Editor, which loads them by address,
# showed an old look from the browser's copy until it was bypassed.
#
# WordPress registers a block's stylesheets when the block is rendered, so WP-CLI renders one block
# of each kind the theme styles, then lists each registered stylesheet with its file and label.
# The fingerprints are computed here from the repository's files, independently of the theme.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# One block of each kind with component stylesheets in functions.php, and the Song List block.
# In single quotes on purpose: PHP's variables are for WP-CLI, not this shell.
# shellcheck disable=SC2016
readonly LIST_PHP='do_blocks(
	"<!-- wp:group --><div class=\"wp-block-group\"></div><!-- /wp:group -->"
	. "<!-- wp:paragraph --><p>Sample</p><!-- /wp:paragraph -->"
	. "<!-- wp:heading --><h2 class=\"wp-block-heading\">Sample</h2><!-- /wp:heading -->"
	. "<!-- wp:buttons --><div class=\"wp-block-buttons\"><!-- wp:button --><div class=\"wp-block-button\"><a class=\"wp-block-button__link wp-element-button\">Sample</a></div><!-- /wp:button --></div><!-- /wp:buttons -->"
	. "<!-- wp:template-part {\"slug\":\"footer\"} /-->"
	. "<!-- wp:songlist/song-list /-->"
);
foreach ( wp_styles()->registered as $handle => $style ) {
	if ( str_starts_with( $handle, "hbmusic-" ) || str_starts_with( $handle, "songlist-" ) ) {
		echo $handle, " ", wp_styles()->get_data( $handle, "path" ), " ", $style->ver, PHP_EOL;
	}
}'

# The theme's stylesheets registered per block in functions.php, and the Song List's one.
readonly MINIMUM_STYLESHEETS=10

# Maps a path inside the WordPress container to the repository's copy of the same file.
repository_copy() {
  local container_path="$1"
  case "$container_path" in
    */wp-content/themes/*) printf '%s/themes/%s' "$REPO_ROOT" "${container_path#*/wp-content/themes/}" ;;
    */wp-content/plugins/*) printf '%s/plugins/%s' "$REPO_ROOT" "${container_path#*/wp-content/plugins/}" ;;
    *) return 1 ;;
  esac
}

check_line() {
  local handle="$1" container_path="$2" label="$3" repository_file fingerprint
  repository_file="$(repository_copy "$container_path")" || fail "$handle points outside the theme and plugins: $container_path"
  [[ -f "$repository_file" ]] || fail "$handle's file is not in the repository: $repository_file"
  fingerprint="$(md5sum "$repository_file" | cut -d' ' -f1)"
  [[ "$label" == "$fingerprint" ]] || fail "$handle is labelled '$label', not its contents' fingerprint $fingerprint"
}

main() {
  load_settings
  run_capturing dev_compose run --rm -T cli wp eval "$LIST_PHP"
  assert_status 0 "listing the stylesheets"
  local count=0 handle container_path label
  while read -r handle container_path label; do
    [[ -n "$handle" ]] || continue
    check_line "$handle" "$container_path" "$label"
    count=$((count + 1))
  done <<<"$RUN_OUTPUT"
  ((count >= MINIMUM_STYLESHEETS)) || fail "only $count stylesheets listed, expected at least $MINIMUM_STYLESHEETS: $RUN_OUTPUT"
  log "PASSED ($count stylesheets, each labelled by its contents)"
}

main "$@"
