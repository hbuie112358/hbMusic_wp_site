<?php
/**
 * Smaller surfaces for attackers: Application Passwords off, and no plugin version comments in
 * the pages.
 *
 * @package site-hardening
 */

defined( 'ABSPATH' ) || exit;

// Application Passwords let a program log in to the REST API with a password of its own, which
// bypasses two-factor login. Nothing on these sites uses them; a site that does removes this.
add_filter( 'wp_is_application_passwords_available', '__return_false' );

// Yoast SEO writes its version into every page ("optimized with the Yoast SEO plugin vX"), which
// tells attackers which known holes to try. Has no effect where Yoast is not installed.
add_filter( 'wpseo_debug_markers', '__return_false' );
