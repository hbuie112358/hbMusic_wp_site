<?php
/**
 * One song, as the list shows it.
 *
 * @package song-list
 */

defined( 'ABSPATH' ) || exit;

/**
 * The values of one song, read once and not changed afterwards.
 */
final readonly class Songlist_Song {
	/**
	 * Creates the song.
	 *
	 * @param string $title  The title, as WordPress displays it.
	 * @param string $artist The artist; empty when none is known.
	 */
	public function __construct(
		public string $title,
		public string $artist,
	) {
	}
}
