<?php
/**
 * The child theme's functions.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;

require_once __DIR__ . '/includes/enum-hbmusic-carousel-scan.php';

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
 * The heading tags, as WordPress's tag processor names them (upper case).
 */
const HBMUSIC_HEADING_TAGS = array( 'H1', 'H2', 'H3', 'H4', 'H5', 'H6' );

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
 * The theme's component stylesheets (assets/css/components/, plan D29), listed under the block
 * whose appearance on a page loads them. WordPress then adds a component's styles only to pages
 * that have that block, and inlines them, so a page costs no extra request. A new component is
 * one file and its name here.
 */
const HBMUSIC_COMPONENT_STYLES = array(
	'core/template-part' => array( 'site-header', 'site-footer' ),
	'core/group'         => array( 'texture', 'site-panel', 'site-hero', 'site-section', 'site-features', 'site-cta', 'site-carousel' ),
	'core/paragraph'     => array( 'site-media', 'site-lead' ),
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
 * The script that pauses embedded YouTube players so only one plays at a time (plan D29), loaded
 * only on pages whose content has one; its handle; and the addresses that count as a player.
 */
const HBMUSIC_VIDEO_PAUSE_SCRIPT   = 'assets/js/video-pause.js';
const HBMUSIC_VIDEO_PAUSE_HANDLE   = 'hbmusic-video-pause';
const HBMUSIC_YOUTUBE_PLAYER_HOSTS = array( 'www.youtube.com', 'youtube.com', 'www.youtube-nocookie.com' );

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
			'ver'    => hbmusic_asset_version( $stylesheet ),
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
	wp_enqueue_style( 'hbmusic-form', get_theme_file_uri( HBMUSIC_FORM_STYLESHEET ), array(), hbmusic_asset_version( HBMUSIC_FORM_STYLESHEET ) );
	wp_style_add_data( 'hbmusic-form', 'path', get_theme_file_path( HBMUSIC_FORM_STYLESHEET ) );
}
add_action( 'wp_enqueue_scripts', 'hbmusic_enqueue_form_style' );

/**
 * A theme asset's version for its address (stylesheets, the video script): a fingerprint of its
 * contents, so a changed file gets a new address and reaches browsers and caches that kept the old
 * one, with no version number to remember to raise. The theme's own version once labelled them all and stayed the same through
 * many changes, so the Site Editor, which loads these files by address, showed an old look until
 * the browser's copy was bypassed (the user found it, 2026-11-12). Reading a small file on each
 * request costs far less than serving a stale look; a stylesheet that cannot be read is labelled
 * with the theme's version instead.
 *
 * @param string $asset The file's path within the theme.
 * @return string The version.
 */
function hbmusic_asset_version( string $asset ): string {
	$fingerprint = md5_file( get_theme_file_path( $asset ) );
	if ( false !== $fingerprint ) {
		return $fingerprint;
	}
	$theme_version = wp_get_theme()->get( 'Version' );
	return is_string( $theme_version ) ? $theme_version : '';
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
 * Makes every carousel (a group with the class site-carousel, site-carousel.css) reachable with the
 * Tab key, so a keyboard user can scroll it with the arrow keys (WCAG 2.1.1; axe's
 * scrollable-region-focusable). Added when the page is rendered, because an attribute the group
 * block does not know would make WordPress's editor flag the block as invalid.
 *
 * @param string $block_content The group's HTML.
 * @return string The HTML, with tabindex="0" on a carousel.
 */
function hbmusic_make_carousel_focusable( string $block_content ): string {
	$tags = new WP_HTML_Tag_Processor( $block_content );
	if ( $tags->next_tag() && $tags->has_class( 'site-carousel' ) && null === $tags->get_attribute( 'tabindex' ) ) {
		$tags->set_attribute( 'tabindex', '0' );
	}
	return $tags->get_updated_html();
}
add_filter( 'render_block_core/group', 'hbmusic_make_carousel_focusable' );

/**
 * Names each carousel after a heading directly above it, so screen readers announce "Rock" or
 * "Country" instead of the same "Videos" for every carousel on the page (the user: one carousel
 * needs no heading, several may each have one). The carousel is linked to the heading
 * (aria-labelledby), which takes precedence over its own label; a carousel without a heading above
 * it keeps that label. Applied to the page's content as rendered, since a block does not know its
 * neighbours.
 *
 * @param string $block_content The page content's HTML.
 * @return string The HTML, with carousels after a heading linked to it.
 */
function hbmusic_name_carousels_after_headings( string $block_content ): string {
	$tags     = new WP_HTML_Tag_Processor( $block_content );
	$position = Hbmusic_Carousel_Scan::Elsewhere;
	while ( $tags->next_tag( array( 'tag_closers' => 'visit' ) ) ) {
		$position = hbmusic_scan_for_carousel( $tags, $position );
	}
	return $tags->get_updated_html();
}
add_filter( 'render_block_core/post-content', 'hbmusic_name_carousels_after_headings' );

/**
 * Advances the scan by the tag at the processor's position, linking a carousel that directly
 * follows a heading.
 *
 * @param WP_HTML_Tag_Processor $tags     The processor, at an opening or closing tag.
 * @param Hbmusic_Carousel_Scan $position Where the scan stood before this tag.
 * @return Hbmusic_Carousel_Scan Where it stands after it.
 */
function hbmusic_scan_for_carousel( WP_HTML_Tag_Processor $tags, Hbmusic_Carousel_Scan $position ): Hbmusic_Carousel_Scan {
	if ( in_array( $tags->get_tag(), HBMUSIC_HEADING_TAGS, true ) ) {
		return hbmusic_scan_heading( $tags );
	}
	if ( Hbmusic_Carousel_Scan::InHeading === $position ) {
		return $position;
	}
	if ( Hbmusic_Carousel_Scan::AfterHeading === $position && ! $tags->is_tag_closer() && true === $tags->has_class( 'site-carousel' ) ) {
		hbmusic_link_carousel_to_heading( $tags );
	}
	return Hbmusic_Carousel_Scan::Elsewhere;
}

/**
 * At a heading's opening tag, bookmarks it and enters it; at its closing tag, the scan is directly
 * after it.
 *
 * @param WP_HTML_Tag_Processor $tags The processor, at a heading's opening or closing tag.
 * @return Hbmusic_Carousel_Scan Where the scan stands.
 */
function hbmusic_scan_heading( WP_HTML_Tag_Processor $tags ): Hbmusic_Carousel_Scan {
	if ( $tags->is_tag_closer() ) {
		return Hbmusic_Carousel_Scan::AfterHeading;
	}
	$tags->set_bookmark( 'heading' );
	return Hbmusic_Carousel_Scan::InHeading;
}

/**
 * Links the carousel at the processor's position to the heading bookmarked as "heading": gives
 * the heading an id if it has none, points the carousel's aria-labelledby at it and removes the
 * carousel's own label, which the heading replaces.
 *
 * @param WP_HTML_Tag_Processor $tags The processor, at the carousel's opening tag.
 */
function hbmusic_link_carousel_to_heading( WP_HTML_Tag_Processor $tags ): void {
	$tags->set_bookmark( 'carousel' );
	$tags->seek( 'heading' );
	$heading_id = $tags->get_attribute( 'id' );
	if ( ! is_string( $heading_id ) || '' === $heading_id ) {
		$heading_id = wp_unique_id( 'site-carousel-heading-' );
		$tags->set_attribute( 'id', $heading_id );
	}
	$tags->seek( 'carousel' );
	$tags->set_attribute( 'aria-labelledby', $heading_id );
	$tags->remove_attribute( 'aria-label' );
	$tags->release_bookmark( 'carousel' );
}

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

/**
 * Decodes an embedded video's title before WordPress escapes it for the player's title attribute,
 * which screen readers announce as the video's name (docs/SITE_CHECKLIST.md 7.4).
 *
 * WordPress 7.1 reads the title from the provider's player code still escaped (YouTube sends
 * "80&#39;s rock"), turns the apostrophe's entity into "&apos;", which its own escaping does not
 * recognise, and escapes it again (wp_filter_oembed_iframe_title_attribute()), so browsers read
 * "80&apos;s rock" (found on the Music page, 2026-11-12). Ampersands and quotation marks were not
 * affected. Decoded here, WordPress escapes the title once, as it should.
 *
 * @param string $title The title as WordPress read it from the player code.
 * @return string The title as plain text.
 */
function hbmusic_decode_embed_title( string $title ): string {
	return html_entity_decode( $title, ENT_QUOTES | ENT_HTML5, 'UTF-8' );
}
add_filter( 'oembed_iframe_title_attribute', 'hbmusic_decode_embed_title' );

/**
 * Lazy-loads every embedded player in a page's content (videos, maps), the first ones included, so
 * one hidden in a carousel or further down the page loads only as the visitor nears it
 * (docs/SITE_CHECKLIST.md 8.5). WordPress leaves the first images and embeds of a page eager,
 * assuming they show at once, which on the Music page was every video. Pictures keep WordPress's
 * own choice, so the first one, usually the largest at the top, still loads at once.
 *
 * @return string The loading value for every embedded frame.
 */
function hbmusic_lazy_load_embeds(): string {
	return 'lazy';
}
add_filter( 'wp_iframe_tag_add_loading_attr', 'hbmusic_lazy_load_embeds' );

/**
 * Leaves a heading without text out of the page. An empty heading takes up space as a blank gap
 * and is announced by screen readers as a heading with nothing in it (an accessibility error).
 * The video carousel pattern starts with an empty, optional heading (the user: invisible when
 * unused), which the editor shows only as its hint text. Removed before the page's content is
 * rendered as a whole, so a carousel below it keeps its own name.
 *
 * @param string $block_content The heading's HTML.
 * @return string The HTML, or nothing for a heading without text.
 */
function hbmusic_drop_empty_heading( string $block_content ): string {
	$text = html_entity_decode( wp_strip_all_tags( $block_content ), ENT_QUOTES | ENT_HTML5, 'UTF-8' );
	return '' === trim( $text, " \t\n\r\0\x0B\u{00A0}" ) ? '' : $block_content;
}
add_filter( 'render_block_core/heading', 'hbmusic_drop_empty_heading' );

/**
 * Describes a carousel the way the W3C's carousel pattern does (WAI-ARIA Authoring Practices), so
 * screen readers announce "Videos, carousel" and, for each slide, "slide 2 of 3" (the user asked
 * for the carousel to say what it is). Each direct child of the carousel is a slide; a slide that
 * is a bare video frame keeps its own role, since a frame cannot take another. Markup the HTML
 * processor cannot parse is left as it is.
 *
 * @param string $block_content The group's HTML.
 * @return string The HTML, with a carousel and its slides described.
 */
function hbmusic_describe_carousel( string $block_content ): string {
	$slide_count = hbmusic_count_carousel_slides( $block_content );
	if ( 0 === $slide_count ) {
		return $block_content;
	}
	$tags = WP_HTML_Processor::create_fragment( $block_content );
	if ( null === $tags || ! $tags->next_tag() ) {
		return $block_content;
	}
	/* translators: How a screen reader describes the kind of region a carousel is. */
	$tags->set_attribute( 'aria-roledescription', __( 'carousel', 'hbmusic' ) );
	$slide_depth = $tags->get_current_depth() + 1;
	$slide       = 0;
	while ( $tags->next_tag() ) {
		if ( $tags->get_current_depth() === $slide_depth ) {
			hbmusic_describe_slide( $tags, ++$slide, $slide_count );
		}
	}
	return null === $tags->get_last_error() ? $tags->get_updated_html() : $block_content;
}
add_filter( 'render_block_core/group', 'hbmusic_describe_carousel' );

/**
 * The number of slides (direct children) of the carousel that opens the given HTML, or 0 if the
 * HTML does not open with a carousel or cannot be parsed.
 *
 * @param string $block_content A group's HTML.
 * @return int The number of slides.
 */
function hbmusic_count_carousel_slides( string $block_content ): int {
	$tags = WP_HTML_Processor::create_fragment( $block_content );
	if ( null === $tags || ! $tags->next_tag() || true !== $tags->has_class( 'site-carousel' ) ) {
		return 0;
	}
	$slide_depth = $tags->get_current_depth() + 1;
	$slides      = 0;
	while ( $tags->next_tag() ) {
		$slides += $tags->get_current_depth() === $slide_depth ? 1 : 0;
	}
	return null === $tags->get_last_error() ? $slides : 0;
}

/**
 * Marks the slide at the processor's position as slide n of m.
 *
 * @param WP_HTML_Processor $tags        The processor, at a slide's opening tag.
 * @param int               $position    The slide's position, from 1.
 * @param int               $slide_count The number of slides.
 */
function hbmusic_describe_slide( WP_HTML_Processor $tags, int $position, int $slide_count ): void {
	if ( 'IFRAME' === $tags->get_tag() ) {
		return;
	}
	$tags->set_attribute( 'role', 'group' );
	/* translators: How a screen reader describes one item of a carousel. */
	$tags->set_attribute( 'aria-roledescription', __( 'slide', 'hbmusic' ) );
	/* translators: 1: the slide's position, 2: the number of slides. */
	$tags->set_attribute( 'aria-label', sprintf( __( '%1$d of %2$d', 'hbmusic' ), $position, $slide_count ) );
}

/**
 * Prepares the YouTube players in a page's content for the video script: adds YouTube's switch for
 * accepting commands from the page (enablejsapi=1) to each player's address, and loads the script
 * when there is at least one. Added when the page is rendered, so players embedded before this
 * change get it too, and the editor's content stays as WordPress saved it.
 *
 * @param string $block_content The page content's HTML.
 * @return string The HTML, with each YouTube player able to take commands.
 */
function hbmusic_prepare_youtube_players( string $block_content ): string {
	$tags       = new WP_HTML_Tag_Processor( $block_content );
	$has_player = false;
	while ( $tags->next_tag( array( 'tag_name' => 'iframe' ) ) ) {
		$address = $tags->get_attribute( 'src' );
		if ( ! is_string( $address ) || ! hbmusic_is_youtube_player( $address ) ) {
			continue;
		}
		$tags->set_attribute( 'src', add_query_arg( 'enablejsapi', '1', $address ) );
		$has_player = true;
	}
	if ( $has_player ) {
		hbmusic_enqueue_video_pause_script();
	}
	return $tags->get_updated_html();
}
add_filter( 'render_block_core/post-content', 'hbmusic_prepare_youtube_players' );

/**
 * Whether an address is a YouTube player's (an embed address on one of YouTube's hosts).
 *
 * @param string $address A frame's address.
 * @return bool Whether it is a YouTube player.
 */
function hbmusic_is_youtube_player( string $address ): bool {
	$host = wp_parse_url( $address, PHP_URL_HOST );
	$path = wp_parse_url( $address, PHP_URL_PATH );
	return in_array( $host, HBMUSIC_YOUTUBE_PLAYER_HOSTS, true ) && is_string( $path ) && str_starts_with( $path, '/embed/' );
}

/**
 * Loads the video script at the end of the page, deferred, labelled by its contents' fingerprint.
 */
function hbmusic_enqueue_video_pause_script(): void {
	wp_enqueue_script(
		HBMUSIC_VIDEO_PAUSE_HANDLE,
		get_theme_file_uri( HBMUSIC_VIDEO_PAUSE_SCRIPT ),
		array(),
		hbmusic_asset_version( HBMUSIC_VIDEO_PAUSE_SCRIPT ),
		array(
			'strategy'  => 'defer',
			'in_footer' => true,
		)
	);
}
