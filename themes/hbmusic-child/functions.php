<?php
/**
 * The child theme's functions.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;

/**
 * This site's old page addresses and the pages that replaced them (plan D22): the old site's
 * Video and Audio pages became Music, its Contact page became Book. Search engines and old links
 * still point at the old addresses. A site without old addresses leaves this list empty.
 */
const HBMUSIC_OLD_ADDRESSES = array(
	'video'   => 'music',
	'audio'   => 'music',
	'contact' => 'book',
);

/**
 * The towns this site's musician travels to for events (plan D22), named in the page data for
 * search engines. The page text names the same towns.
 */
const HBMUSIC_AREAS_SERVED = array(
	'Fayetteville, North Carolina',
	'Southern Pines, North Carolina',
);

/**
 * The theme's component stylesheets (assets/css/components/, plan D29), listed under the block
 * whose appearance on a page loads them. WordPress then adds a component's styles only to pages
 * that have that block, and inlines them, so a page costs no extra request. A new component is
 * one file and its name here.
 */
const HBMUSIC_COMPONENT_STYLES = array(
	'core/template-part' => array( 'site-header', 'site-footer' ),
	'core/group'         => array( 'texture', 'site-hero', 'site-section', 'site-features', 'site-cta' ),
	'core/paragraph'     => array( 'site-media' ),
	'core/button'        => array( 'buttons' ),
	'core/heading'       => array( 'headings' ),
	'core/post-title'    => array( 'headings' ),
);

/**
 * The form stylesheet, which is loaded by page rather than by block: Contact Form 7's forms are
 * shortcodes, not blocks.
 */
const HBMUSIC_FORM_STYLESHEET = 'assets/css/components/form.css';

/**
 * Registers every component stylesheet with the block it styles.
 */
function hbmusic_register_component_styles(): void {
	foreach ( HBMUSIC_COMPONENT_STYLES as $block_name => $components ) {
		array_walk(
			$components,
			static fn ( string $component ) => hbmusic_register_component_style( $block_name, $component )
		);
	}
}

/**
 * Registers one component stylesheet with the block it styles.
 *
 * Block stylesheets print before WordPress's global styles, so a component's main selector names
 * its block too (.wp-block-group.site-section): two classes outrank WordPress's one-class layout
 * rules (.has-global-padding) wherever they print. A dependency on "global-styles" would fix the
 * order instead, but that handle is registered only after the blocks render, and WordPress logs
 * a notice for it.
 *
 * @param string $block_name The block whose appearance loads the stylesheet.
 * @param string $component  The component's name, also its file name.
 */
function hbmusic_register_component_style( string $block_name, string $component ): void {
	$stylesheet = 'assets/css/components/' . $component . '.css';
	wp_enqueue_block_style(
		$block_name,
		array(
			'handle' => 'hbmusic-' . $component,
			'src'    => get_theme_file_uri( $stylesheet ),
			'path'   => get_theme_file_path( $stylesheet ),
			'ver'    => hbmusic_theme_version(),
		)
	);
}
add_action( 'init', 'hbmusic_register_component_styles' );

/**
 * Loads the form stylesheet on pages with a form only (see hbmusic_page_has_booking_form()).
 */
function hbmusic_enqueue_form_style(): void {
	if ( ! hbmusic_page_has_booking_form() ) {
		return;
	}
	wp_enqueue_style( 'hbmusic-form', get_theme_file_uri( HBMUSIC_FORM_STYLESHEET ), array(), hbmusic_theme_version() );
	wp_style_add_data( 'hbmusic-form', 'path', get_theme_file_path( HBMUSIC_FORM_STYLESHEET ) );
}
add_action( 'wp_enqueue_scripts', 'hbmusic_enqueue_form_style' );

/**
 * The theme's version from style.css, which versions the stylesheets' addresses: a changed
 * stylesheet then reaches browsers that kept the old one.
 *
 * @return string The version.
 */
function hbmusic_theme_version(): string {
	$version = wp_get_theme()->get( 'Version' );
	return is_string( $version ) ? $version : '';
}

/**
 * Marks the menu link to the page being shown as the current page (aria-current="page"), which
 * the header underlines and screen readers announce (plan D29). WordPress marks only links that
 * point to a page by its ID; this site's menu links are addresses, so they are compared by path.
 *
 * @param string               $block_content The menu link's HTML.
 * @param array<string, mixed> $block         The menu link block, with its "url" attribute.
 * @return string The HTML, marked if the link leads to the page being shown.
 */
function hbmusic_mark_current_menu_link( string $block_content, array $block ): string {
	$attributes = is_array( $block['attrs'] ?? null ) ? $block['attrs'] : array();
	$link_url   = is_string( $attributes['url'] ?? null ) ? $attributes['url'] : '';
	$link_path  = hbmusic_site_path( $link_url );
	if ( null === $link_path || hbmusic_requested_path() !== $link_path ) {
		return $block_content;
	}
	$tags = new WP_HTML_Tag_Processor( $block_content );
	if ( $tags->next_tag( array( 'tag_name' => 'a' ) ) ) {
		$tags->set_attribute( 'aria-current', 'page' );
	}
	return $tags->get_updated_html();
}
add_filter( 'render_block_core/navigation-link', 'hbmusic_mark_current_menu_link', 10, 2 );

/**
 * A link's path within this site, without slashes at either end and in lower case ("" for the home
 * page), or null for an empty link or one to another site.
 *
 * @param string $url The link, absolute or starting with "/".
 * @return string|null The path, or null.
 */
function hbmusic_site_path( string $url ): ?string {
	if ( '' === $url ) {
		return null;
	}
	$link_host = wp_parse_url( $url, PHP_URL_HOST );
	if ( is_string( $link_host ) && wp_parse_url( home_url(), PHP_URL_HOST ) !== $link_host ) {
		return null;
	}
	$link_path = wp_parse_url( $url, PHP_URL_PATH );
	$home_path = wp_parse_url( home_url( '/' ), PHP_URL_PATH );
	$link_path = is_string( $link_path ) ? $link_path : '/';
	$home_path = is_string( $home_path ) ? $home_path : '/';
	if ( str_starts_with( $link_path, $home_path ) ) {
		$link_path = substr( $link_path, strlen( $home_path ) );
	}
	return strtolower( trim( $link_path, '/' ) );
}

/**
 * The path of the page being shown, in the same form as hbmusic_site_path().
 *
 * @return string The path ("" for the home page).
 */
function hbmusic_requested_path(): string {
	global $wp;
	return $wp instanceof WP ? strtolower( trim( $wp->request, '/' ) ) : '';
}

/**
 * Removes WordPress's emoji support: the detection script, its styles and the image swaps.
 *
 * Every current browser shows emoji itself. The detection script starts a worker from a blob:
 * address, which the site's Content-Security-Policy refuses (the Site Hardening plugin), and
 * where it decides a browser needs help it loads emoji images from WordPress.org's servers,
 * sending visitors' addresses there (docs/SITE_CHECKLIST.md 3.2, 8.4). The hooks are WordPress
 * 7.1's own (wp-includes/default-filters.php, wp-admin/includes/admin-filters.php).
 */
function hbmusic_remove_emoji_support(): void {
	remove_action( 'wp_head', 'print_emoji_detection_script', 7 );
	remove_action( 'admin_print_scripts', 'print_emoji_detection_script' );
	remove_action( 'embed_head', 'print_emoji_detection_script' );

	remove_action( 'wp_enqueue_scripts', 'wp_enqueue_emoji_styles' );
	remove_action( 'admin_enqueue_scripts', 'wp_enqueue_emoji_styles' );
	remove_action( 'enqueue_embed_scripts', 'wp_enqueue_emoji_styles' );
	remove_action( 'wp_print_styles', 'print_emoji_styles' );
	remove_action( 'admin_print_styles', 'print_emoji_styles' );

	remove_filter( 'the_content_feed', 'wp_staticize_emoji' );
	remove_filter( 'comment_text_rss', 'wp_staticize_emoji' );
	remove_filter( 'wp_mail', 'wp_staticize_emoji_for_email' );
}
add_action( 'init', 'hbmusic_remove_emoji_support' );

/**
 * Adds the outside sources this site's pages need to the Site Hardening plugin's
 * Content-Security-Policy (plan D26; docs/SITE_CHECKLIST.md 3.2), each with its reason:
 * - Cloudflare Turnstile's script and its widget frame protect the booking form (plan 5e);
 * - the site's videos always play from YouTube (plan D19): WordPress's embeds use youtube.com,
 *   the privacy-enhanced player youtube-nocookie.com.
 *
 * @param array<string, list<string>> $outside_sources The sources added so far, by directive.
 * @return array<string, list<string>> The sources with this site's.
 */
function hbmusic_add_outside_sources( array $outside_sources ): array {
	$outside_sources['script-src'] = array_merge(
		$outside_sources['script-src'] ?? array(),
		array( 'https://challenges.cloudflare.com' )
	);
	$outside_sources['frame-src']  = array_merge(
		$outside_sources['frame-src'] ?? array(),
		array( 'https://www.youtube.com', 'https://www.youtube-nocookie.com', 'https://challenges.cloudflare.com' )
	);
	return $outside_sources;
}
add_filter( 'sitehardening_csp_sources', 'hbmusic_add_outside_sources' );

/**
 * Tells whether the page being shown has the booking form.
 *
 * Contact Form 7 and Cloudflare's script otherwise load on every page, which slows pages without a
 * form and sends visitors who never see one to Cloudflare (docs/SITE_CHECKLIST.md 8.4, 10.2).
 *
 * @return bool True on a page with the form.
 */
function hbmusic_page_has_booking_form(): bool {
	return is_singular() && has_shortcode( (string) get_post_field( 'post_content' ), 'contact-form-7' );
}
add_filter( 'wpcf7_load_js', 'hbmusic_page_has_booking_form' );
add_filter( 'wpcf7_load_css', 'hbmusic_page_has_booking_form' );

/**
 * Removes Cloudflare's script from pages without the booking form.
 *
 * Contact Form 7's own loading filters do not cover this script. It runs at priority 11 because the
 * plugin adds the script at the default 10.
 */
function hbmusic_remove_turnstile_script_without_form(): void {
	if ( ! hbmusic_page_has_booking_form() ) {
		wp_dequeue_script( 'cloudflare-turnstile' );
	}
}
add_action( 'wp_enqueue_scripts', 'hbmusic_remove_turnstile_script_without_form', 11 );

/**
 * Forwards a request for an old page address to the page that replaced it, permanently (301), so
 * visitors arrive on the right page and search engines move the old page's standing to the new one.
 *
 * It runs before anything is shown, at priority 1, ahead of WordPress's own redirects
 * (redirect_canonical() and wp_old_slug_redirect(), both at 10 in wp-includes/default-filters.php):
 * an old page left in the database must not be shown instead. WordPress's request
 * path is relative to the site's address, and home_url() builds the target, so the theme names no
 * domain (plan D7).
 */
function hbmusic_redirect_old_address(): void {
	global $wp;
	$requested_path = $wp instanceof WP ? strtolower( $wp->request ) : '';
	$new_path       = HBMUSIC_OLD_ADDRESSES[ $requested_path ] ?? null;
	if ( null === $new_path ) {
		return;
	}
	wp_safe_redirect( home_url( '/' . $new_path . '/' ), 301 );
	exit;
}
add_action( 'template_redirect', 'hbmusic_redirect_old_address', 1 );

/**
 * Describes the site's organization in Yoast SEO's page data as a musician (schema.org's
 * MusicGroup, which also covers a solo musician) and names the towns served (plan 8h), so search
 * engines read the same facts as the page text. Yoast's Local SEO add-on would do this for a fee.
 *
 * Yoast builds the Organization only when its settings name a company with a logo; this adds to
 * that piece and keeps its name, logo and links. Its type is always "Organization" in Yoast 28.8
 * (src/generators/schema/organization.php), so the pair is written out rather than merged.
 *
 * @param array<string, mixed> $organization Yoast's Organization piece.
 * @return array<string, mixed> The piece as a musician, with the areas served.
 */
function hbmusic_describe_organization( array $organization ): array {
	$organization['@type']      = array( 'Organization', 'MusicGroup' );
	$organization['areaServed'] = array_map(
		static fn ( string $town ): array => array(
			'@type' => 'City',
			'name'  => $town,
		),
		HBMUSIC_AREAS_SERVED
	);
	return $organization;
}
add_filter( 'wpseo_schema_organization', 'hbmusic_describe_organization' );
