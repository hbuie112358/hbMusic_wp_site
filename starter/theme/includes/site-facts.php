<?php
/**
 * The site's own facts, the part of the theme's code a new site replaces (template plan 1.6b,
 * T13): the theme's functions read them from here and name no site themselves. The starter's are
 * the neutral defaults of a new site with no history; a site fills in its own.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;

/**
 * Old page addresses and the pages that replaced them, as 'old-address' => 'new-address', each
 * redirected permanently so search engines and old links reach the new page. A new site has none;
 * a site moved from an old one lists the old site's addresses here.
 */
const HBMUSIC_OLD_ADDRESSES = array();

/**
 * What the site's organization is, in schema.org's types, for Yoast SEO's page data. Yoast's own
 * Organization alone; a site adds a more exact type where one fits (such as LocalBusiness).
 */
const HBMUSIC_ORGANIZATION_TYPES = array( 'Organization' );

/**
 * The towns the site serves, named in the page data for search engines, as the page text names
 * them ('Town, State'). None until the site's own are known.
 */
const HBMUSIC_AREAS_SERVED = array();

/**
 * The outside sources the site's pages need in the Site Hardening plugin's
 * Content-Security-Policy, by directive, each with its reason:
 * - Cloudflare Turnstile's script and its widget frame protect the contact form.
 * A site with videos adds YouTube's players to frame-src (https://www.youtube.com and the
 * privacy-enhanced https://www.youtube-nocookie.com).
 */
const HBMUSIC_OUTSIDE_SOURCES = array(
	'script-src' => array( 'https://challenges.cloudflare.com' ),
	'frame-src'  => array( 'https://challenges.cloudflare.com' ),
);

/**
 * The site's example of good link text, for the Editing Help plugin's guide: a link the site really
 * has, so the guide reads as written for it. A function rather than a list, since its text is
 * translated.
 *
 * @return string The example.
 */
function hbmusic_link_example(): string {
	return __( 'Read about us', 'hbmusic' );
}
add_filter( 'editinghelp_link_example', 'hbmusic_link_example' );
