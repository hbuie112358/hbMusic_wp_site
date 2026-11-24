/**
 * What the theme's two video scripts share (template plan 1.7), in one home that both import:
 * the event the click-to-load videos announce a new player with (video-facade.js to
 * video-pause.js), and reading an address's origin. Loaded by WordPress as the script module
 * "@dts-site-components/video-shared" (functions.php), whose import map gives it its versioned address.
 */

/**
 * The event video-facade.js sends on the document when a click-to-load video becomes a player;
 * its detail is the player's frame.
 */
export const PLAYER_ADDED_EVENT = 'hbmusic:player-added';

/**
 * The origin of an address: where a player's commands may go, or whether a player's origin is
 * written as one.
 *
 * @param {string} address An address.
 * @return {string} Its origin, or '' if it cannot be read as an address.
 */
export const originOf = ( address ) => {
	try {
		return new URL( address ).origin;
	} catch ( error ) {
		// The URL constructor raises a TypeError for an address it cannot read; anything else is
		// not this function's to hide.
		if ( error instanceof TypeError ) {
			return '';
		}
		throw error;
	}
};
