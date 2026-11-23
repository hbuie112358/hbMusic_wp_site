<?php
/**
 * Click-to-load videos (plan 9v; handbook 12, 8.5): each YouTube player in a page's content is
 * shown as a picture of the video with a play button, served from the site, and YouTube's player
 * loads only when the visitor plays it, from its privacy-enhanced address (assets/js/video-facade.js).
 *
 * Why: a YouTube player brings about half a megabyte of scripts, which made Home's main content
 * appear after 8.3 s on a phone and Music's after 14.2 s (PageSpeed, 2026-11-17), against 1.5 s on a
 * page without one; and nothing about a visitor reaches YouTube unless they press play.
 *
 * The picture is fetched once from YouTube's image server when a page is saved (the user approved
 * that outgoing request, 2026-11-17) and kept in the uploads folder; showing a page never fetches
 * anything. A video whose picture is missing shows a dark box with the play button, and plays.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;

// A YouTube video's ID: 11 letters, digits, dashes or underscores. Anything else is left alone.
const HBMUSIC_VIDEO_ID_PATTERN = '/^[A-Za-z0-9_-]{11}$/';

// Video addresses in a page's saved content, in the forms WordPress's video block and pasted
// player code use (watch?v=, youtu.be/, embed/), with the ID captured.
const HBMUSIC_VIDEO_ADDRESS_PATTERN = '#(?:youtube(?:-nocookie)?\.com/(?:watch\?v=|embed/)|youtu\.be/)([A-Za-z0-9_-]{11})#';

// YouTube's still pictures for a video, the largest first: not every video has the largest.
const HBMUSIC_VIDEO_PICTURE_SOURCES = array(
	'https://i.ytimg.com/vi/%s/maxresdefault.jpg',
	'https://i.ytimg.com/vi/%s/hqdefault.jpg',
);

// The uploads subfolder that keeps the pictures, one file per video, named by its ID.
const HBMUSIC_VIDEO_PICTURE_FOLDER = 'hbmusic-video-pictures';

// Limits on the one request per picture: a still picture is well under this size, and saving a
// page must not wait long on YouTube.
const HBMUSIC_VIDEO_PICTURE_MAX_BYTES       = 2097152;
const HBMUSIC_VIDEO_PICTURE_TIMEOUT_SECONDS = 10;

// The address a visitor without JavaScript is sent to instead: the video on YouTube.
const HBMUSIC_VIDEO_WATCH_ADDRESS = 'https://www.youtube.com/watch?v=';

// The facade's stylesheet and script, loaded only on pages that have a video.
const HBMUSIC_VIDEO_FACADE_STYLESHEET = 'assets/css/components/video-facade.css';
const HBMUSIC_VIDEO_FACADE_SCRIPT     = 'assets/js/video-facade.js';
const HBMUSIC_VIDEO_FACADE_HANDLE     = 'hbmusic-video-facade';

// The origin of the player the facade script builds (its PLAYER_ADDRESS, YouTube's
// privacy-enhanced player), which the page's Content-Security-Policy must allow as a frame.
const HBMUSIC_VIDEO_PLAYER_ORIGIN = 'https://www.youtube-nocookie.com';

/**
 * Allows the click-to-load player's frame in the Site Hardening plugin's Content-Security-Policy
 * (template plan 1.6c-2, T14): the player is this code's, so its address comes with it, and every
 * site using these videos gets it without listing it among its own facts. The header is sent
 * before the page is built, so it cannot depend on whether this page has a video; a frame from
 * this origin cannot run script in the page. Players pasted into content (youtube.com) stay a
 * site's own fact (includes/site-facts.php).
 *
 * @param array<string, list<string>> $outside_sources The sources added so far, by directive.
 * @return array<string, list<string>> The sources with the player's frame.
 */
function hbmusic_allow_video_player_frame( array $outside_sources ): array {
	$outside_sources['frame-src'] = array_merge( $outside_sources['frame-src'] ?? array(), array( HBMUSIC_VIDEO_PLAYER_ORIGIN ) );
	return $outside_sources;
}
add_filter( 'sitehardening_csp_sources', 'hbmusic_allow_video_player_frame' );

/**
 * Fetches the pictures of the videos in a saved page or post that do not have one yet.
 *
 * @param int     $post_id The saved item's ID.
 * @param WP_Post $post    The saved item.
 */
function hbmusic_fetch_video_pictures_on_save( int $post_id, WP_Post $post ): void {
	if ( wp_is_post_revision( $post_id ) || wp_is_post_autosave( $post_id ) ) {
		return;
	}
	if ( 1 > preg_match_all( HBMUSIC_VIDEO_ADDRESS_PATTERN, $post->post_content, $matches ) ) {
		return;
	}
	foreach ( array_unique( $matches[1] ) as $video_id ) {
		if ( null === hbmusic_video_picture( $video_id ) ) {
			hbmusic_fetch_video_picture( $video_id );
		}
	}
}
add_action( 'save_post', 'hbmusic_fetch_video_pictures_on_save', 10, 2 );

/**
 * Fetches a video's picture from YouTube's image server into the uploads folder, trying each size
 * until one is a real image. A failed attempt leaves no file behind.
 *
 * @param string $video_id The video's ID, already checked.
 * @return bool Whether the picture is now on the site.
 */
function hbmusic_fetch_video_picture( string $video_id ): bool {
	$path = hbmusic_video_picture_path( $video_id );
	if ( null === $path || ! wp_mkdir_p( dirname( $path ) ) ) {
		return false;
	}
	foreach ( HBMUSIC_VIDEO_PICTURE_SOURCES as $source ) {
		$response = wp_safe_remote_get(
			sprintf( $source, rawurlencode( $video_id ) ),
			array(
				'timeout'             => HBMUSIC_VIDEO_PICTURE_TIMEOUT_SECONDS,
				'limit_response_size' => HBMUSIC_VIDEO_PICTURE_MAX_BYTES,
				'stream'              => true,
				'filename'            => $path,
			)
		);
		if ( ! is_wp_error( $response ) && 200 === wp_remote_retrieve_response_code( $response ) && hbmusic_is_jpeg_picture( $path ) ) {
			return true;
		}
		wp_delete_file( $path );
	}
	return false;
}

/**
 * Whether a file is a JPEG picture, read from its contents rather than trusted from the server.
 *
 * @param string $path The file.
 * @return bool Whether it is one.
 */
function hbmusic_is_jpeg_picture( string $path ): bool {
	$size = is_file( $path ) ? wp_getimagesize( $path ) : false;
	return is_array( $size ) && IMAGETYPE_JPEG === $size[2];
}

/**
 * Where a video's picture is kept, or null for an ID that is not a YouTube video's.
 *
 * @param string $video_id The video's ID.
 * @return string|null The file's path.
 */
function hbmusic_video_picture_path( string $video_id ): ?string {
	if ( 1 !== preg_match( HBMUSIC_VIDEO_ID_PATTERN, $video_id ) ) {
		return null;
	}
	$uploads = wp_upload_dir( null, false );
	return $uploads['basedir'] . '/' . HBMUSIC_VIDEO_PICTURE_FOLDER . '/' . $video_id . '.jpg';
}

/**
 * A video's picture on the site, with its size, or null if it has none.
 *
 * @param string $video_id The video's ID.
 * @return array{url: string, width: int, height: int}|null The picture.
 */
function hbmusic_video_picture( string $video_id ): ?array {
	$path = hbmusic_video_picture_path( $video_id );
	$size = null !== $path && is_file( $path ) ? wp_getimagesize( $path ) : false;
	if ( ! is_array( $size ) ) {
		return null;
	}
	$uploads = wp_upload_dir( null, false );
	return array(
		'url'    => $uploads['baseurl'] . '/' . HBMUSIC_VIDEO_PICTURE_FOLDER . '/' . $video_id . '.jpg',
		'width'  => $size[0],
		'height' => $size[1],
	);
}

/**
 * Replaces each YouTube player in a page's content with its facade, and loads the facade's files
 * and the video script when there is at least one. Done as the page is shown, so videos embedded
 * before this change get it too, and the editor's content stays as WordPress saved it.
 *
 * @param string $block_content The page content's HTML.
 * @return string The HTML, its YouTube players replaced.
 */
function hbmusic_replace_youtube_players( string $block_content ): string {
	$has_video = false;
	$replaced  = preg_replace_callback(
		'#<iframe\b[^>]*>\s*</iframe>#i',
		static function ( array $frame ) use ( &$has_video ): string {
			$facade    = hbmusic_video_facade_for_frame( $frame[0] );
			$has_video = $has_video || null !== $facade;
			return $facade ?? $frame[0];
		},
		$block_content
	);
	if ( $has_video ) {
		hbmusic_enqueue_video_facade();
	}
	return $replaced ?? $block_content;
}
add_filter( 'render_block_core/post-content', 'hbmusic_replace_youtube_players' );

/**
 * The facade for a player's frame, or null when the frame is not a YouTube player with a video ID.
 *
 * @param string $frame_html One iframe element.
 * @return string|null The facade's HTML.
 */
function hbmusic_video_facade_for_frame( string $frame_html ): ?string {
	$tags = new WP_HTML_Tag_Processor( $frame_html );
	if ( ! $tags->next_tag( array( 'tag_name' => 'iframe' ) ) ) {
		return null;
	}
	$address = $tags->get_attribute( 'src' );
	$title   = $tags->get_attribute( 'title' );
	if ( ! is_string( $address ) || ! hbmusic_is_youtube_player( $address ) ) {
		return null;
	}
	$path     = wp_parse_url( $address, PHP_URL_PATH );
	$video_id = is_string( $path ) ? basename( $path ) : '';
	if ( 1 !== preg_match( HBMUSIC_VIDEO_ID_PATTERN, $video_id ) ) {
		return null;
	}
	return hbmusic_video_facade_html( $video_id, is_string( $title ) ? $title : '' );
}

/**
 * The facade: a link to the video on YouTube (what a visitor without JavaScript follows), showing
 * the video's picture and a play button, which the facade script turns into the player.
 *
 * @param string $video_id The video's ID, already checked.
 * @param string $title    The video's title, as its player named it.
 * @return string The facade's HTML.
 */
function hbmusic_video_facade_html( string $video_id, string $title ): string {
	$named = '' !== $title ? $title : __( 'YouTube video', 'hbmusic' );
	/* translators: %s: the video's title. */
	$label   = sprintf( __( 'Play video: %s', 'hbmusic' ), $named );
	$picture = hbmusic_video_picture( $video_id );
	$image   = null === $picture ? '' : sprintf(
		'<img class="video-facade__picture" src="%s" alt="" width="%d" height="%d" loading="lazy" decoding="async">',
		esc_url( $picture['url'] ),
		$picture['width'],
		$picture['height']
	);
	return sprintf(
		'<a class="video-facade" href="%1$s" data-video-id="%2$s" data-video-title="%3$s" aria-label="%4$s">%5$s<span class="video-facade__play" aria-hidden="true"></span></a>',
		esc_url( HBMUSIC_VIDEO_WATCH_ADDRESS . $video_id ),
		esc_attr( $video_id ),
		esc_attr( $named ),
		esc_attr( $label ),
		$image
	);
}

/**
 * Loads the facade's stylesheet and script, and the video script that plays one video at a time.
 */
function hbmusic_enqueue_video_facade(): void {
	wp_enqueue_style( HBMUSIC_VIDEO_FACADE_HANDLE, get_theme_file_uri( HBMUSIC_VIDEO_FACADE_STYLESHEET ), array(), hbmusic_asset_version( HBMUSIC_VIDEO_FACADE_STYLESHEET ) );
	wp_style_add_data( HBMUSIC_VIDEO_FACADE_HANDLE, 'path', get_theme_file_path( HBMUSIC_VIDEO_FACADE_STYLESHEET ) );
	wp_enqueue_script(
		HBMUSIC_VIDEO_FACADE_HANDLE,
		get_theme_file_uri( HBMUSIC_VIDEO_FACADE_SCRIPT ),
		array(),
		hbmusic_asset_version( HBMUSIC_VIDEO_FACADE_SCRIPT ),
		array(
			'strategy'  => 'defer',
			'in_footer' => true,
		)
	);
	hbmusic_enqueue_video_pause_script();
}
