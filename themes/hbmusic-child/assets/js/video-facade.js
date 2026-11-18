/**
 * Turns a click-to-load video into YouTube's player when the visitor plays it (plan 9v; the
 * facades are drawn by includes/video-facade.php). Until then the page loads nothing from YouTube.
 *
 * The player comes from YouTube's privacy-enhanced address, set to start playing, since the visitor
 * just asked for it, and to accept the video script's pause command (enablejsapi=1). It takes the
 * facade's place, holds the keyboard focus when played with the keyboard, and is announced to the
 * video script (video-pause.js), which then pauses any other video that is playing.
 *
 * Each facade is a link to the video on YouTube: without this script, or for an ID it does not
 * recognize, following the link plays the video there.
 */
( () => {
	'use strict';

	const FACADE_SELECTOR = 'a.video-facade[data-video-id]';
	const PLAYER_ADDRESS = 'https://www.youtube-nocookie.com/embed/';
	const PLAYER_SETTINGS = '?autoplay=1&enablejsapi=1';
	// What the player may use, as WordPress's own video block allows it.
	const PLAYER_PERMISSIONS = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share';
	const VIDEO_ID_PATTERN = /^[A-Za-z0-9_-]{11}$/;
	const PLAYER_ADDED_EVENT = 'hbmusic:player-added';

	/**
	 * Replaces the facade the visitor activated with the video's player.
	 *
	 * @param {MouseEvent} event The click, or the Enter key on the focused link.
	 */
	function playVideo( event ) {
		const facade = event.target instanceof Element ? event.target.closest( FACADE_SELECTOR ) : null;
		const videoId = facade instanceof HTMLAnchorElement ? facade.dataset.videoId ?? '' : '';
		if ( ! ( facade instanceof HTMLAnchorElement ) || ! VIDEO_ID_PATTERN.test( videoId ) ) {
			return;
		}
		event.preventDefault();
		const player = document.createElement( 'iframe' );
		player.className = 'video-facade__player';
		player.src = PLAYER_ADDRESS + videoId + PLAYER_SETTINGS;
		player.title = facade.dataset.videoTitle ?? '';
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
} )();
