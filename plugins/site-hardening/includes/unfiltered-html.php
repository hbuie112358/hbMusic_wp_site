<?php
/**
 * Only Administrators may post unfiltered HTML (handbook H79).
 *
 * WordPress gives Editors the unfiltered_html capability on a single site, so an Editor's page may
 * hold a <script>. Without it, WordPress's own filter (kses) strips scripts and other unsafe markup
 * when the user saves, so a stolen Editor login cannot plant a script that attacks an
 * Administrator who opens the page. Administrators keep it: they can install plugins anyway, so
 * taking it from them protects little, and it leaves a way to place an unusual embed. The site's
 * own content loses nothing: videos are Embed blocks and forms are shortcodes, which kses keeps.
 *
 * Done through WordPress's capability mapping rather than DISALLOW_UNFILTERED_HTML, which would
 * be a line typed by hand into each server's wp-config.php and would apply to Administrators too.
 *
 * @package site-hardening
 */

defined( 'ABSPATH' ) || exit;

// The one role that keeps unfiltered_html.
const SITEHARDENING_UNFILTERED_HTML_ROLE = 'administrator';

/**
 * Refuses unfiltered_html to every user who is not an Administrator.
 *
 * @param array<string> $required_capabilities The primitive capabilities WordPress requires.
 * @param string        $capability            The capability being checked.
 * @param int           $user_id               The user being checked.
 * @return array<string> The capabilities required after this rule.
 */
function sitehardening_restrict_unfiltered_html( array $required_capabilities, string $capability, int $user_id ): array {
	if ( 'unfiltered_html' !== $capability ) {
		return $required_capabilities;
	}
	$user = get_userdata( $user_id );
	if ( false === $user || ! in_array( SITEHARDENING_UNFILTERED_HTML_ROLE, $user->roles, true ) ) {
		// WordPress's own value for a capability nobody may have.
		return array( 'do_not_allow' );
	}
	return $required_capabilities;
}
add_filter( 'map_meta_cap', 'sitehardening_restrict_unfiltered_html', 10, 3 );
