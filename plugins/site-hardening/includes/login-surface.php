<?php
/**
 * Smaller surfaces for attackers: Application Passwords off, and no version of WordPress or a
 * plugin in the pages or feeds.
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

// WordPress names its version in a generator tag in every page's head and a generator line in
// every feed, for the same attackers' use. Every one of these goes through the_generator(), so one
// empty filter removes them all. The "?ver=" on WordPress's own stylesheets stays: it is how
// browsers fetch the new file after an update, and stripping it would cost more than it hides.
add_filter( 'the_generator', '__return_empty_string' );
