/**
 * Pauses embedded YouTube players so that only one plays at a time (plan D29; the user found a
 * carousel's first video still playing after moving to the second):
 *
 * - a player moved out of its carousel's view is paused: by the carousel's arrows, dots, swipe or
 *   keyboard;
 * - scrolling the page never pauses a player, in a carousel or not (the user: music keeps playing
 *   while the visitor reads on, down to the call to action);
 * - when the visitor clicks or tabs into a player, every other player on the page is paused, so
 *   only one ever plays.
 *
 * YouTube's player runs in its own frame, which the page cannot reach or see into; it accepts
 * commands sent as messages when its address carries enablejsapi=1 (the theme adds it), and only
 * its documented pause command is used. Players created later, when the visitor plays a
 * click-to-load video (video-facade.js, plan 9v), are announced and join in. Which player the
 * visitor starts is seen from the browser's
 * focus, not asked of YouTube (the user: no reliance on YouTube's less documented reports), so any
 * click into a player counts as moving to it. Without this script everything still works; the
 * players just do not pause by themselves.
 */
( () => {
	'use strict';

	const PLAYER_SELECTOR = 'iframe[src*="youtube.com/embed/"], iframe[src*="youtube-nocookie.com/embed/"]';
	const CAROUSEL_SELECTOR = '.site-carousel';
	// The share of a player its carousel must keep showing for it to keep playing: a carousel's
	// neighbours peek in at much less than half.
	const VISIBLE_SHARE = 0.5;
	// How often, while the focus is inside a player, the page checks whether it moved to another
	// player: the page is told only when the focus first leaves it, not when it moves on.
	const FOCUS_CHECK_MS = 250;
	// Announced by video-facade.js when a click-to-load video becomes a player.
	const PLAYER_ADDED_EVENT = 'hbmusic:player-added';

	/**
	 * Whether an element is a frame (the players' selector matches frames only; this tells the
	 * type checker so, and guards against a change of selector).
	 *
	 * @param {Element} element An element.
	 * @return {element is HTMLIFrameElement} Whether it is a frame.
	 */
	const isFrame = ( element ) => element instanceof HTMLIFrameElement;

	/**
	 * The origin a player's commands go to.
	 *
	 * @param {HTMLIFrameElement} player The player's frame.
	 * @return {string} Its origin, or '' if its address cannot be read.
	 */
	const originOf = ( player ) => {
		try {
			return new URL( player.src ).origin;
		} catch {
			return '';
		}
	};

	/**
	 * Pauses a player with YouTube's documented command, sent to its origin only. A player that has
	 * not loaded yet drops it, which is right: it is not playing.
	 *
	 * @param {HTMLIFrameElement} player The player's frame.
	 */
	const pause = ( player ) => {
		const origin = originOf( player );
		if ( player.contentWindow && origin ) {
			player.contentWindow.postMessage( JSON.stringify( { event: 'command', func: 'pauseVideo', args: [] } ), origin );
		}
	};

	// The players on the page: those in its markup, and those created later, when the visitor plays
	// a click-to-load video (video-facade.js announces each one).
	/** @type {HTMLIFrameElement[]} */
	const players = [];

	// The player the visitor is in: clicking or tabbing into a player moves the focus into its
	// frame, which the page sees as its active element. Entering one pauses the others.
	/** @type {HTMLIFrameElement|null} */
	let currentPlayer = null;
	/** @type {number} */
	let focusCheck = 0;

	const followFocus = () => {
		const active = document.activeElement;
		if ( ! ( active instanceof HTMLIFrameElement ) || ! players.includes( active ) || active === currentPlayer ) {
			return;
		}
		currentPlayer = active;
		players.filter( ( player ) => player !== active ).forEach( pause );
	};

	window.addEventListener( 'blur', () => {
		followFocus();
		window.clearInterval( focusCheck );
		focusCheck = window.setInterval( followFocus, FOCUS_CHECK_MS );
	} );
	window.addEventListener( 'focus', () => {
		window.clearInterval( focusCheck );
		currentPlayer = null;
	} );

	/**
	 * Pauses the players its carousel no longer shows enough of.
	 *
	 * @param {IntersectionObserverEntry[]} entries What the carousel shows of its players.
	 */
	const pauseMovedOut = ( entries ) => {
		entries
			.filter( ( entry ) => entry.intersectionRatio < VISIBLE_SHARE )
			.map( ( entry ) => entry.target )
			.filter( isFrame )
			.forEach( pause );
	};

	// One observer per carousel, measuring against the carousel itself, not the window: moving to
	// another slide changes what the carousel shows, scrolling the page does not.
	/** @type {Map<Element, IntersectionObserver>} */
	const carouselObservers = new Map();
	document.querySelectorAll( CAROUSEL_SELECTOR ).forEach( ( carousel ) => {
		carouselObservers.set( carousel, new IntersectionObserver( pauseMovedOut, { root: carousel, threshold: [ VISIBLE_SHARE ] } ) );
	} );

	/**
	 * Takes a player into account: followed when the visitor enters it, and watched by its carousel.
	 *
	 * @param {HTMLIFrameElement} player The player's frame.
	 */
	const addPlayer = ( player ) => {
		if ( players.includes( player ) ) {
			return;
		}
		players.push( player );
		carouselObservers.forEach( ( observer, carousel ) => {
			if ( carousel.contains( player ) ) {
				observer.observe( player );
			}
		} );
	};

	document.querySelectorAll( PLAYER_SELECTOR ).forEach( ( element ) => {
		if ( isFrame( element ) ) {
			addPlayer( element );
		}
	} );
	// A video the visitor just started (video-facade.js) is the one playing: every other is paused at
	// once, without waiting to see the focus move.
	document.addEventListener( PLAYER_ADDED_EVENT, ( event ) => {
		// A CustomEvent's detail is typed any; read as unknown, it is narrowed below before use.
		/** @type {unknown} */
		const player = event instanceof CustomEvent ? event.detail : null;
		if ( ! ( player instanceof HTMLIFrameElement ) || ! player.matches( PLAYER_SELECTOR ) ) {
			return;
		}
		addPlayer( player );
		currentPlayer = player;
		players.filter( ( other ) => other !== player ).forEach( pause );
	} );
} )();
