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
 * visitor starts is seen from the browser's focus, not asked of YouTube (the user: no reliance on
 * YouTube's less documented reports), so any click into a player counts as moving to it. Without
 * this script everything still works; the players just do not pause by themselves.
 *
 * A script module (template plan 1.7); what changes while the page is open (the players, the one
 * the visitor is in, the focus check) is held by one OnePlayerAtATime, built with its settings.
 */

import { PLAYER_ADDED_EVENT, originOf } from '@dts-site-components/video-shared';

/**
 * @typedef {object} PauseSettings
 * @property {string} playerSelector   The frames that count as players.
 * @property {string} carouselSelector The carousels whose view decides what may keep playing.
 * @property {number} visibleShare     The share of a player its carousel must keep showing.
 * @property {number} focusCheckMs     How often to check, while the focus is in a player, whether
 *                                     it moved to another player.
 */

/** @type {Readonly<PauseSettings>} */
const SETTINGS = Object.freeze( {
	playerSelector: 'iframe[src*="youtube.com/embed/"], iframe[src*="youtube-nocookie.com/embed/"]',
	carouselSelector: '.site-carousel',
	// A carousel's neighbours peek in at much less than half.
	visibleShare: 0.5,
	// The page is told only when the focus first leaves it for a player, not when it moves on.
	focusCheckMs: 250,
} );

// YouTube's documented pause command.
const PAUSE_COMMAND = JSON.stringify( { event: 'command', func: 'pauseVideo', args: [] } );

/**
 * Whether an element is a frame (the players' selector matches frames only; this tells the
 * type checker so, and guards against a change of selector).
 *
 * @param {Element} element An element.
 * @return {element is HTMLIFrameElement} Whether it is a frame.
 */
const isFrame = ( element ) => element instanceof HTMLIFrameElement;

/**
 * Pauses a player, sending the command to its origin only. A player that has not loaded yet
 * drops it, which is right: it is not playing.
 *
 * @param {HTMLIFrameElement} player The player's frame.
 */
const pause = ( player ) => {
	const origin = originOf( player.src );
	if ( player.contentWindow && origin ) {
		player.contentWindow.postMessage( PAUSE_COMMAND, origin );
	}
};

/** Keeps the page's YouTube players to one playing at a time. */
class OnePlayerAtATime {
	/** @type {Readonly<PauseSettings>} */
	#settings;

	// The players on the page: those in its markup, and those created later.
	/** @type {HTMLIFrameElement[]} */
	#players = [];

	// The player the visitor is in: clicking or tabbing into a player moves the focus into its
	// frame, which the page sees as its active element.
	/** @type {HTMLIFrameElement | null} */
	#currentPlayer = null;

	/** @type {number} */
	#focusCheck = 0;

	// One observer per carousel, measuring against the carousel itself, not the window: moving to
	// another slide changes what the carousel shows, scrolling the page does not.
	/** @type {Map<Element, IntersectionObserver>} */
	#carouselObservers = new Map();

	/** @param {Readonly<PauseSettings>} settings What counts as a player and a carousel, and when. */
	constructor( settings ) {
		this.#settings = settings;
	}

	/** Watches the page's carousels and players, the focus, and players created later. */
	start() {
		document.querySelectorAll( this.#settings.carouselSelector ).forEach( ( carousel ) => {
			const observer = new IntersectionObserver(
				( entries ) => {
					this.#pauseMovedOut( entries );
				},
				{ root: carousel, threshold: [ this.#settings.visibleShare ] },
			);
			this.#carouselObservers.set( carousel, observer );
		} );
		document.querySelectorAll( this.#settings.playerSelector ).forEach( ( element ) => {
			if ( isFrame( element ) ) {
				this.#addPlayer( element );
			}
		} );
		window.addEventListener( 'blur', () => {
			this.#watchFocus();
		} );
		window.addEventListener( 'focus', () => {
			this.#stopWatchingFocus();
		} );
		document.addEventListener( PLAYER_ADDED_EVENT, ( event ) => {
			this.#playerAdded( event );
		} );
	}

	/**
	 * Takes a player into account: followed when the visitor enters it, and watched by its carousel.
	 *
	 * @param {HTMLIFrameElement} player The player's frame.
	 */
	#addPlayer( player ) {
		if ( this.#players.includes( player ) ) {
			return;
		}
		this.#players.push( player );
		this.#carouselObservers.forEach( ( observer, carousel ) => {
			if ( carousel.contains( player ) ) {
				observer.observe( player );
			}
		} );
	}

	/**
	 * Makes a player the one playing: every other is paused.
	 *
	 * @param {HTMLIFrameElement} player The player's frame.
	 */
	#makeCurrent( player ) {
		this.#currentPlayer = player;
		this.#players.filter( ( other ) => other !== player ).forEach( pause );
	}

	// The focus left the page, perhaps into a player: followed now and while it stays out.
	#watchFocus() {
		this.#followFocus();
		window.clearInterval( this.#focusCheck );
		this.#focusCheck = window.setInterval( () => {
			this.#followFocus();
		}, this.#settings.focusCheckMs );
	}

	#stopWatchingFocus() {
		window.clearInterval( this.#focusCheck );
		this.#currentPlayer = null;
	}

	// Entering a player other than the current one pauses the others.
	#followFocus() {
		const active = document.activeElement;
		if ( active instanceof HTMLIFrameElement && this.#players.includes( active ) && active !== this.#currentPlayer ) {
			this.#makeCurrent( active );
		}
	}

	/**
	 * Pauses the players their carousel no longer shows enough of.
	 *
	 * @param {IntersectionObserverEntry[]} entries What the carousel shows of its players.
	 */
	#pauseMovedOut( entries ) {
		entries
			.filter( ( entry ) => entry.intersectionRatio < this.#settings.visibleShare )
			.map( ( entry ) => entry.target )
			.filter( isFrame )
			.forEach( pause );
	}

	/**
	 * A video the visitor just started (video-facade.js) is the one playing: every other is paused
	 * at once, without waiting to see the focus move.
	 *
	 * @param {Event} event The announcement, its detail the new player.
	 */
	#playerAdded( event ) {
		// A CustomEvent's detail is typed any; read as unknown, it is narrowed before use.
		/** @type {unknown} */
		const player = event instanceof CustomEvent ? event.detail : null;
		if ( ! ( player instanceof HTMLIFrameElement ) || ! player.matches( this.#settings.playerSelector ) ) {
			return;
		}
		this.#addPlayer( player );
		this.#makeCurrent( player );
	}
}

new OnePlayerAtATime( SETTINGS ).start();
