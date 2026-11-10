<?php
/**
 * No response names the PHP version.
 *
 * PHP adds "X-Powered-By: PHP/<version>" to every response it builds, unless the server's
 * expose_php setting is off, which a site on shared hosting often cannot change. The version tells
 * attackers which known holes to try (docs/SITE_CHECKLIST.md 3.6).
 *
 * @package site-hardening
 */

defined( 'ABSPATH' ) || exit;

/**
 * Removes the PHP version header before WordPress sends anything.
 *
 * PHP sets the header when the request starts, and header_remove() takes it out again as long as
 * nothing has been sent. plugins_loaded is the first hook every WordPress request reaches (pages,
 * the admin, the login page, the REST API, AJAX, feeds and XML-RPC), long before any output.
 * Priority 0 puts it ahead of anything on the same hook that answers and stops the request at
 * once, such as this plugin's XML-RPC refusal (includes/xml-rpc.php, at the default 10).
 */
function sitehardening_remove_php_version_header(): void {
	header_remove( 'X-Powered-By' );
}
add_action( 'plugins_loaded', 'sitehardening_remove_php_version_header', 0 );
