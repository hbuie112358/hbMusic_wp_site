<?php
/**
 * The child theme's functions.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;

/**
 * Removes WordPress's emoji support: the detection script, its styles and the image swaps.
 *
 * Every current browser shows emoji itself. The detection script starts a worker from a blob:
 * address, which the site's Content-Security-Policy refuses (the Site Hardening plugin), and
 * where it decides a browser needs help it loads emoji images from WordPress.org's servers,
 * sending visitors' addresses there (docs/SITE_CHECKLIST.md 3.2, 8.4). The hooks are WordPress
 * 7.1's own (wp-includes/default-filters.php, wp-admin/includes/admin-filters.php).
 */
function hbmusic_remove_emoji_support(): void {
	remove_action( 'wp_head', 'print_emoji_detection_script', 7 );
	remove_action( 'admin_print_scripts', 'print_emoji_detection_script' );
	remove_action( 'embed_head', 'print_emoji_detection_script' );

	remove_action( 'wp_enqueue_scripts', 'wp_enqueue_emoji_styles' );
	remove_action( 'admin_enqueue_scripts', 'wp_enqueue_emoji_styles' );
	remove_action( 'enqueue_embed_scripts', 'wp_enqueue_emoji_styles' );
	remove_action( 'wp_print_styles', 'print_emoji_styles' );
	remove_action( 'admin_print_styles', 'print_emoji_styles' );

	remove_filter( 'the_content_feed', 'wp_staticize_emoji' );
	remove_filter( 'comment_text_rss', 'wp_staticize_emoji' );
	remove_filter( 'wp_mail', 'wp_staticize_emoji_for_email' );
}
add_action( 'init', 'hbmusic_remove_emoji_support' );

/**
 * Adds the outside sources this site's pages need to the Site Hardening plugin's
 * Content-Security-Policy (plan D26; docs/SITE_CHECKLIST.md 3.2), each with its reason:
 * - Cloudflare Turnstile's script and its widget frame protect the booking form (plan 5e);
 * - the site's videos always play from YouTube (plan D19): WordPress's embeds use youtube.com,
 *   the privacy-enhanced player youtube-nocookie.com.
 *
 * @param array<string, list<string>> $outside_sources The sources added so far, by directive.
 * @return array<string, list<string>> The sources with this site's.
 */
function hbmusic_add_outside_sources( array $outside_sources ): array {
	$outside_sources['script-src'] = array_merge(
		$outside_sources['script-src'] ?? array(),
		array( 'https://challenges.cloudflare.com' )
	);
	$outside_sources['frame-src']  = array_merge(
		$outside_sources['frame-src'] ?? array(),
		array( 'https://www.youtube.com', 'https://www.youtube-nocookie.com', 'https://challenges.cloudflare.com' )
	);
	return $outside_sources;
}
add_filter( 'sitehardening_csp_sources', 'hbmusic_add_outside_sources' );

/**
 * Tells whether the page being shown has the booking form.
 *
 * Contact Form 7 and Cloudflare's script otherwise load on every page, which slows pages without a
 * form and sends visitors who never see one to Cloudflare (docs/SITE_CHECKLIST.md 8.4, 10.2).
 *
 * @return bool True on a page with the form.
 */
function hbmusic_page_has_booking_form(): bool {
	return is_singular() && has_shortcode( (string) get_post_field( 'post_content' ), 'contact-form-7' );
}
add_filter( 'wpcf7_load_js', 'hbmusic_page_has_booking_form' );
add_filter( 'wpcf7_load_css', 'hbmusic_page_has_booking_form' );

/**
 * Removes Cloudflare's script from pages without the booking form.
 *
 * Contact Form 7's own loading filters do not cover this script. It runs at priority 11 because the
 * plugin adds the script at the default 10.
 */
function hbmusic_remove_turnstile_script_without_form(): void {
	if ( ! hbmusic_page_has_booking_form() ) {
		wp_dequeue_script( 'cloudflare-turnstile' );
	}
}
add_action( 'wp_enqueue_scripts', 'hbmusic_remove_turnstile_script_without_form', 11 );
