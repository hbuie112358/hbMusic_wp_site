<?php
/**
 * This site's own text for the shared code, the part of the theme's code a new site replaces
 * (template plan 1.6b, T13). Only translated text is here, since it needs PHP's __(); the site's
 * other facts are settings, in the theme's site-facts.json (template plan 2.4b-2, T31).
 *
 * @package dts-theme
 */

defined( 'ABSPATH' ) || exit;

/**
 * This site's example of good link text, for the Editing Help plugin's guide: a link the site
 * really has, so the guide reads as written for it (the user, 2026-11-14). A function rather than
 * a setting, since its text is translated.
 *
 * @return string The example.
 */
function dtstheme_link_example(): string {
	return __( 'See the song list', 'dts-theme' );
}
add_filter( 'editinghelp_link_example', 'dtstheme_link_example' );
