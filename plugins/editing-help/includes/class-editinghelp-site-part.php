<?php
/**
 * One line of the guide's "Your site" lists.
 *
 * @package editing-help
 */

defined( 'ABSPATH' ) || exit;

/**
 * A page template or a ready-made section: its name as WordPress shows it in the editor, so the
 * guide and the editor match, and a line saying what it does (empty when the site gives none).
 * Immutable: the lists are read from the theme for each page view and only printed.
 */
final class EditingHelp_Site_Part {

	/**
	 * Builds a line of the list.
	 *
	 * @param string $name        The name WordPress shows for it.
	 * @param string $description What it does, or an empty string.
	 */
	public function __construct(
		public readonly string $name,
		public readonly string $description
	) {}
}
