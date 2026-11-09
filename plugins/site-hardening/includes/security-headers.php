<?php
/**
 * The security headers on visitor pages: a Content-Security-Policy, nosniff, a referrer policy and
 * a permissions policy.
 *
 * WordPress's send_headers hook runs for the pages it builds for visitors, not for the admin, the
 * login page or the REST API (which sends its own nosniff). The admin is left out on purpose: the
 * block editor uses techniques a policy can break, which needs its own testing.
 *
 * The policy: code may come only from the site itself and the outside sources the site adds
 * through the sitehardening_csp_sources filter; inline code is allowed, since WordPress core
 * prints small inline scripts and block styles arrive as inline <style>; the rules that rarely
 * change are strict.
 *
 * @package site-hardening
 */

defined( 'ABSPATH' ) || exit;

/*
 * The policy's fixed core, in the order the header lists it.
 *   default-src 'self'        anything not listed below: the site itself only
 *   script-src, style-src     the site, and inline code WordPress and block styles write
 *   img-src 'self' data:      data: for small inline images WordPress uses
 *   font-src, connect-src     the site only (fonts self-hosted; background requests to the site)
 *   frame-src 'self'          frames from the site; video players are added by the site
 *   object-src 'none'         no plugins such as Flash
 *   base-uri 'self'           the page's base address cannot be redirected
 *   form-action 'self'        forms are sent only to the site
 *   frame-ancestors 'self'    no other site may frame these pages (clickjacking)
 */
const SITEHARDENING_CSP_CORE = array(
	'default-src'     => array( "'self'" ),
	'script-src'      => array( "'self'", "'unsafe-inline'" ),
	'style-src'       => array( "'self'", "'unsafe-inline'" ),
	'img-src'         => array( "'self'", 'data:' ),
	'font-src'        => array( "'self'" ),
	'connect-src'     => array( "'self'" ),
	'frame-src'       => array( "'self'" ),
	'object-src'      => array( "'none'" ),
	'base-uri'        => array( "'self'" ),
	'form-action'     => array( "'self'" ),
	'frame-ancestors' => array( "'self'" ),
);

// The directives a site may add outside sources to. The others protect against attacks that no
// outside service needs to be let into, so they stay as the core sets them.
const SITEHARDENING_CSP_EXTENSIBLE_DIRECTIVES = array( 'script-src', 'style-src', 'img-src', 'font-src', 'connect-src', 'frame-src' );

// An outside source is an https:// host, with an optional port and path. Quotes, semicolons,
// commas and spaces cannot pass, so a source can neither end a directive and start a new one nor
// add a keyword such as 'unsafe-eval'. Wildcard hosts are refused: each service is named.
const SITEHARDENING_CSP_SOURCE_PATTERN = '#^https://[a-z0-9.-]+(:[0-9]{1,5})?(/[A-Za-z0-9._~/-]*)?$#';

/**
 * Sends the security headers.
 */
function sitehardening_send_security_headers(): void {
	header( 'Content-Security-Policy: ' . sitehardening_content_security_policy() );
	header( 'X-Content-Type-Options: nosniff' );
	header( 'Referrer-Policy: strict-origin-when-cross-origin' );
	header( 'Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=()' );
}
add_action( 'send_headers', 'sitehardening_send_security_headers' );

/**
 * Builds the policy: the core, with the outside sources the site adds.
 *
 * @return string The header's value.
 */
function sitehardening_content_security_policy(): string {
	/**
	 * Filters the outside sources the site's pages need, by directive.
	 *
	 * @param array<string, list<string>> $outside_sources For example
	 *        array( 'frame-src' => array( 'https://www.youtube.com' ) ).
	 */
	$requested_sources = apply_filters( 'sitehardening_csp_sources', array() );

	$policy = SITEHARDENING_CSP_CORE;
	foreach ( sitehardening_accepted_sources( $requested_sources ) as $directive => $sources ) {
		$policy[ $directive ] = array_values( array_unique( array_merge( $policy[ $directive ] ?? array(), $sources ) ) );
	}

	$directives = array_map(
		static fn ( string $directive, array $sources ): string => $directive . ' ' . implode( ' ', $sources ),
		array_keys( $policy ),
		$policy
	);
	return implode( '; ', $directives );
}

/**
 * Keeps the outside sources that may enter the policy, and reports the rest.
 *
 * A malformed source is left out rather than sent: the policy is then stricter than wanted, and
 * the page that needed the source shows it, instead of a header that is broken or weakened.
 *
 * @param mixed $requested_sources What the filter returned.
 * @return array<string, list<string>> The accepted sources, by directive.
 */
function sitehardening_accepted_sources( mixed $requested_sources ): array {
	if ( ! is_array( $requested_sources ) ) {
		sitehardening_report_refused( 'the filter did not return an array of directives' );
		return array();
	}

	$accepted = array();
	foreach ( $requested_sources as $directive => $sources ) {
		$accepted_for_directive = sitehardening_accepted_directive_sources( (string) $directive, $sources );
		if ( array() !== $accepted_for_directive ) {
			$accepted[ (string) $directive ] = $accepted_for_directive;
		}
	}
	return $accepted;
}

/**
 * Keeps one directive's well-formed outside sources.
 *
 * @param string $directive The directive, such as frame-src.
 * @param mixed  $sources   The sources requested for it.
 * @return list<string> The sources accepted.
 */
function sitehardening_accepted_directive_sources( string $directive, mixed $sources ): array {
	if ( ! in_array( $directive, SITEHARDENING_CSP_EXTENSIBLE_DIRECTIVES, true ) || ! is_array( $sources ) ) {
		sitehardening_report_refused( sprintf( 'outside sources cannot be added to "%s"', $directive ) );
		return array();
	}

	$accepted = array();
	foreach ( $sources as $source ) {
		if ( sitehardening_is_valid_source( $source ) ) {
			$accepted[] = $source;
		}
	}
	return $accepted;
}

/**
 * Tells whether a source is an https:// address the policy may name, and reports it if not.
 *
 * @phpstan-assert-if-true string $source
 *
 * @param mixed $source The source requested.
 * @return bool True when it may enter the policy.
 */
function sitehardening_is_valid_source( mixed $source ): bool {
	if ( is_string( $source ) && 1 === preg_match( SITEHARDENING_CSP_SOURCE_PATTERN, $source ) ) {
		return true;
	}
	// Coerced for the message only, so reporting can never fail on an odd value.
	$shown = is_scalar( $source ) ? (string) $source : gettype( $source );
	sitehardening_report_refused( sprintf( 'the outside source "%s" is not an https:// address', $shown ) );
	return false;
}

/**
 * Reports a refused source as a developer notice: in the debug log on the dev site, where the
 * tests fail on any entry, and silent on a live site, whose policy then stays stricter.
 *
 * @param string $reason What was refused.
 */
function sitehardening_report_refused( string $reason ): void {
	_doing_it_wrong(
		'sitehardening_csp_sources',
		esc_html( $reason . '; it was left out of the Content-Security-Policy.' ),
		'0.1.0'
	);
}
