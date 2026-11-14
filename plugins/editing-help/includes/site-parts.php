<?php
/**
 * The site's own parts for the guide's "Your site" section: its page templates, its ready-made
 * sections and a contact line. They are read from the active theme each time the page opens,
 * rather than written into the guide, so the list can never fall behind the theme.
 *
 * Built for block themes, which every site of the company uses; a classic theme's templates are
 * not listed.
 *
 * @package editing-help
 */

defined( 'ABSPATH' ) || exit;

/**
 * The slug of WordPress's default page template (page.html), used for a page with no other
 * template chosen.
 */
const EDITINGHELP_DEFAULT_PAGE_TEMPLATE = 'page';

/**
 * The page templates a page can use: the default first, then the theme's own by name, each with
 * the line the theme gives it.
 *
 * Filter "editinghelp_template_descriptions": an array of a template's slug (the default is
 * "page") => one line saying what it does. theme.json has no place for a description, so the
 * theme supplies them here; a template without one shows its name only.
 *
 * @return list<EditingHelp_Site_Part>
 */
function editinghelp_page_templates(): array {
	$descriptions = apply_filters( 'editinghelp_template_descriptions', array() );
	$descriptions = is_array( $descriptions ) ? $descriptions : array();

	$templates = get_block_templates( array( 'post_type' => 'page' ) );
	usort(
		$templates,
		static fn( WP_Block_Template $first, WP_Block_Template $second ): int => strcasecmp( $first->title, $second->title )
	);
	$default = get_block_template( get_stylesheet() . '//' . EDITINGHELP_DEFAULT_PAGE_TEMPLATE );
	if ( $default instanceof WP_Block_Template ) {
		array_unshift( $templates, $default );
	}

	return array_map(
		static fn( WP_Block_Template $template ): EditingHelp_Site_Part => editinghelp_site_part(
			$template->title,
			$descriptions[ $template->slug ] ?? ''
		),
		$templates
	);
}

/**
 * The ready-made sections the site was built with: the patterns registered from the active
 * theme's own patterns/ folder that the editor's inserter offers, sorted by name, each with the
 * description it already carries for the editor. The parent theme's and WordPress's patterns are
 * left out, as are patterns hidden from the inserter, which an editor never sees.
 *
 * @return list<EditingHelp_Site_Part>
 */
function editinghelp_theme_patterns(): array {
	$patterns_folder = wp_normalize_path( trailingslashit( get_stylesheet_directory() ) . 'patterns/' );
	$parts           = array();
	foreach ( WP_Block_Patterns_Registry::get_instance()->get_all_registered() as $pattern ) {
		if ( editinghelp_is_offered_theme_pattern( $pattern, $patterns_folder ) ) {
			$parts[] = editinghelp_site_part( $pattern['title'] ?? '', $pattern['description'] ?? '' );
		}
	}
	usort(
		$parts,
		static fn( EditingHelp_Site_Part $first, EditingHelp_Site_Part $second ): int => strcasecmp( $first->name, $second->name )
	);
	return $parts;
}

/**
 * Whether a registered pattern comes from the theme's own patterns/ folder and is offered in the
 * inserter. WordPress records the file of every pattern it reads from a theme ("filePath").
 *
 * @param array<mixed> $pattern         A pattern as WordPress registered it.
 * @param string       $patterns_folder The theme's patterns/ folder, normalized.
 * @return bool
 */
function editinghelp_is_offered_theme_pattern( array $pattern, string $patterns_folder ): bool {
	$file = $pattern['filePath'] ?? '';
	if ( ! is_string( $file ) || '' === $file ) {
		return false;
	}
	$is_offered = false !== ( $pattern['inserter'] ?? true );
	return $is_offered && str_starts_with( wp_normalize_path( $file ), $patterns_folder );
}

/**
 * The example of good link text in the guide's "Links" section, so the guide reads as written for
 * this site: a link of the site's own, in the words it uses ("See the song list" on a musician's
 * site). A site that gives none gets a neutral example that suits any business.
 *
 * Filter "editinghelp_link_example": a short link text.
 *
 * @return string
 */
function editinghelp_link_example(): string {
	$example = apply_filters( 'editinghelp_link_example', '' );
	$example = is_string( $example ) ? trim( $example ) : '';
	return '' !== $example ? $example : __( 'See our prices', 'editing-help' );
}

/**
 * Who to ask, shown at the end of the guide; empty, and the line is left out.
 *
 * Filter "editinghelp_contact": an email address or a short line of text.
 *
 * @return string
 */
function editinghelp_contact(): string {
	$contact = apply_filters( 'editinghelp_contact', '' );
	return is_string( $contact ) ? trim( $contact ) : '';
}

/**
 * A line of the list from values a theme or WordPress supplied. Anything that is not text becomes
 * empty text, so an unexpected value from a filter shows as a missing line, not an error.
 *
 * @param mixed $name        The name WordPress shows.
 * @param mixed $description What it does.
 * @return EditingHelp_Site_Part
 */
function editinghelp_site_part( mixed $name, mixed $description ): EditingHelp_Site_Part {
	return new EditingHelp_Site_Part(
		is_string( $name ) ? trim( $name ) : '',
		is_string( $description ) ? trim( $description ) : ''
	);
}
