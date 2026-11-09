<?php
/**
 * XML-RPC refused: the older remote-publishing interface, a common target for password guessing
 * (one request can try hundreds of passwords) and for pingback abuse. Sites that publish through
 * the admin or the REST API do not need it.
 *
 * WordPress's own xmlrpc_enabled filter only switches off the methods that need a login; the
 * endpoint would still answer, pingbacks included. So the request is refused as a whole, as soon
 * as WordPress has loaded the plugins.
 *
 * @package site-hardening
 */

defined( 'ABSPATH' ) || exit;

/**
 * Refuses every request to xmlrpc.php.
 */
function sitehardening_refuse_xml_rpc(): void {
	if ( ! defined( 'XMLRPC_REQUEST' ) || ! XMLRPC_REQUEST ) {
		return;
	}
	status_header( 403 );
	nocache_headers();
	header( 'Content-Type: text/plain; charset=utf-8' );
	// Not translated: the answer goes to programs, and loading a translation this early (before
	// init) makes WordPress log a notice on every refused request.
	echo 'XML-RPC is turned off on this site.';
	exit;
}
add_action( 'plugins_loaded', 'sitehardening_refuse_xml_rpc' );

/**
 * Removes the X-Pingback header, which would point visitors and bots to the refused endpoint.
 * WordPress adds it on single posts that allow pings.
 *
 * @param array<string, string> $headers The headers WordPress is about to send.
 * @return array<string, string> The headers without X-Pingback.
 */
function sitehardening_remove_pingback_header( array $headers ): array {
	unset( $headers['X-Pingback'] );
	return $headers;
}
add_filter( 'wp_headers', 'sitehardening_remove_pingback_header' );
