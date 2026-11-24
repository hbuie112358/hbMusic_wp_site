/**
 * Turns a click-to-load video into YouTube's player when the visitor plays it (plan 9v; the
 * facades are drawn by includes/video-facade.php). Until then the page loads nothing from YouTube.
 *
 * The player comes from YouTube's privacy-enhanced address, set to start playing, since the visitor
 * just asked for it, and to accept the video script's pause command (enablejsapi=1). It takes the
 * facade's place, holds the keyboard focus when played with the keyboard, and is announced to the
 * video script (video-pause.js), which then pauses any other video that is playing.
 *
 * Each facade is a link to the video on YouTube: without this script, or for a facade it cannot
 * turn into a named player (no valid video ID, no title, no valid player origin), following the
 * link plays the video there. A script module (template plan 1.7).
 */

import { PLAYER_ADDED_EVENT, originOf } from '@dts-site-components/video-shared';

const FACADE_SELECTOR = 'a.video-facade[data-video-id]';
// The player's origin comes from the facade (data-player-origin), written from PHP's
// HBMUSIC_VIDEO_PLAYER_ORIGIN, its one home, which the security policy also allows as a frame;
// only https origins are used.
const SECURE_ORIGIN_START = 'https://';
const PLAYER_PATH = '/embed/';
const PLAYER_SETTINGS = '?autoplay=1&enablejsapi=1';
// What the player may use, as WordPress's own video block allows it.
const PLAYER_PERMISSIONS = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share';
const VIDEO_ID_PATTERN = /^[A-Za-z0-9_-]{11}$/;

/**
 * The player a facade asks for, or null when it cannot be a named player: the facade then stays
 * a link to YouTube, never a player without a name for screen readers.
 *
 * @param {HTMLAnchorElement} facade The facade.
 * @return {{ address: string, title: string } | null} The player's address and title.
 */
function playerFor( facade ) {
	const videoId = facade.dataset.videoId ?? '';
	const title = facade.dataset.videoTitle ?? '';
	const origin = facade.dataset.playerOrigin ?? '';
	const isSecureOrigin = origin.startsWith( SECURE_ORIGIN_START ) && originOf( origin ) === origin;
	if ( ! VIDEO_ID_PATTERN.test( videoId ) || title === '' || ! isSecureOrigin ) {
		return null;
	}
	return { address: origin + PLAYER_PATH + videoId + PLAYER_SETTINGS, title };
}

/**
 * Replaces the facade the visitor activated with the video's player.
 *
 * @param {MouseEvent} event The click, or the Enter key on the focused link.
 */
function playVideo( event ) {
	const facade = event.target instanceof Element ? event.target.closest( FACADE_SELECTOR ) : null;
	const wanted = facade instanceof HTMLAnchorElement ? playerFor( facade ) : null;
	if ( ! facade || ! wanted ) {
		return;
	}
	event.preventDefault();
	const player = document.createElement( 'iframe' );
	player.className = 'video-facade__player';
	player.src = wanted.address;
	player.title = wanted.title;
	player.allow = PLAYER_PERMISSIONS;
	player.allowFullscreen = true;
	player.referrerPolicy = 'strict-origin-when-cross-origin';
	facade.replaceWith( player );
	// The video script pauses any other video as soon as it hears of this one.
	document.dispatchEvent( new CustomEvent( PLAYER_ADDED_EVENT, { detail: player } ) );
	// A keyboard user's Enter arrives as a click without a pointer (detail 0): the focus follows
	// into the player, so the keyboard keeps working in it. A pointer's click leaves the focus
	// alone: moved by script into a player, Chromium then missed the visitor clicking from it
	// into another player (seen in the tests, 2026-11-17), and a pointer user clicks into the
	// player anyway.
	if ( event.detail === 0 ) {
		player.focus();
	}
}

document.addEventListener( 'click', playVideo );
