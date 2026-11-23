<?php
/**
 * This site's own facts, the part of the theme's code a new site replaces (template plan 1.6b,
 * T13): the theme's functions read them from here and name no site themselves. A site without old
 * addresses or areas served leaves those lists empty.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;

/**
 * This site's old page addresses and the pages that replaced them (plan D22): the old site's
 * Video and Audio pages became Music, its Contact page became Book, whose address is
 * /hire-acoustic-guitarist/ (plan 1c). Search engines and old links still point at the old
 * addresses. Book's earlier address on staging, /book/, gets no redirect: it was never live, so
 * nothing outside the site knows it. Also from live's export (plan 9e): the empty "Audio and
 * Video" page and three old video posts, whose videos are on Music now.
 */
const HBMUSIC_OLD_ADDRESSES = array(
	'video'           => 'music',
	'audio'           => 'music',
	'audio-and-video' => 'music',
	'video-01'        => 'music',
	'video-02'        => 'music',
	'video-03'        => 'music',
	'contact'         => 'hire-acoustic-guitarist',
);

/**
 * What the site's organization is, in schema.org's types, for Yoast SEO's page data: a musician
 * (MusicGroup, which also covers a solo musician) as well as Yoast's own Organization (plan 8h).
 */
const HBMUSIC_ORGANIZATION_TYPES = array( 'Organization', 'MusicGroup' );

/**
 * The towns this site's musician travels to for events (plan D22), named in the page data for
 * search engines. The page text names the same towns.
 */
const HBMUSIC_AREAS_SERVED = array(
	'Fayetteville, North Carolina',
	'Hope Mills, North Carolina',
	'Southern Pines, North Carolina',
);

/**
 * The outside sources this site's pages need in the Site Hardening plugin's
 * Content-Security-Policy (plan D26; docs/SITE_CHECKLIST.md 3.2), by directive, each with its
 * reason:
 * - Cloudflare Turnstile's script and its widget frame protect the booking form (plan 5e);
 * - the site's videos always play from YouTube (plan D19): a player pasted into a page's content
 *   uses youtube.com. (The click-to-load player's youtube-nocookie.com is allowed by the video
 *   code itself, includes/video-facade.php.)
 */
const HBMUSIC_OUTSIDE_SOURCES = array(
	'script-src' => array( 'https://challenges.cloudflare.com' ),
	'frame-src'  => array( 'https://www.youtube.com', 'https://challenges.cloudflare.com' ),
);

/**
 * This site's example of good link text, for the Editing Help plugin's guide: a link the site
 * really has, so the guide reads as written for it (the user, 2026-11-14). A function rather than
 * a list, since its text is translated.
 *
 * @return string The example.
 */
function hbmusic_link_example(): string {
	return __( 'See the song list', 'hbmusic' );
}
add_filter( 'editinghelp_link_example', 'hbmusic_link_example' );
