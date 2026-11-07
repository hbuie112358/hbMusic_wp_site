<?php
/**
 * The Song content type and how songs are read.
 *
 * @package song-list
 */

defined( 'ABSPATH' ) || exit;

/**
 * Registers the Song type and its artist field.
 *
 * A song has no page of its own: it appears only in the list, so search engines do not index
 * a hundred thin pages. Without REST, WordPress edits it on the classic screen, whose PHP form
 * needs no JavaScript build.
 */
function songlist_register_song_type(): void {
	register_post_type(
		SONGLIST_POST_TYPE,
		array(
			'labels'       => songlist_song_type_labels(),
			'public'       => false,
			'show_ui'      => true,
			'show_in_rest' => false,
			'menu_icon'    => 'dashicons-playlist-audio',
			'supports'     => array( 'title' ),
			'rewrite'      => false,
			'query_var'    => false,
		)
	);

	register_post_meta(
		SONGLIST_POST_TYPE,
		SONGLIST_ARTIST_META_KEY,
		array(
			'type'              => 'string',
			'single'            => true,
			'sanitize_callback' => 'sanitize_text_field',
			'show_in_rest'      => false,
		)
	);
}

/**
 * The admin wording of the Song type.
 *
 * @return array<string, string>
 */
function songlist_song_type_labels(): array {
	return array(
		'name'               => __( 'Songs', 'song-list' ),
		'singular_name'      => __( 'Song', 'song-list' ),
		'add_new_item'       => __( 'Add New Song', 'song-list' ),
		'edit_item'          => __( 'Edit Song', 'song-list' ),
		'new_item'           => __( 'New Song', 'song-list' ),
		'search_items'       => __( 'Search Songs', 'song-list' ),
		'not_found'          => __( 'No songs found.', 'song-list' ),
		'not_found_in_trash' => __( 'No songs found in Trash.', 'song-list' ),
		'all_items'          => __( 'All Songs', 'song-list' ),
	);
}

/**
 * Reads one song's artist.
 *
 * @param int $song_id The song's post ID.
 * @return string The artist; empty when none is stored.
 */
function songlist_artist_of( int $song_id ): string {
	$artist = get_post_meta( $song_id, SONGLIST_ARTIST_META_KEY, true );

	return is_string( $artist ) ? $artist : '';
}

/**
 * Reads every published song, sorted by title.
 *
 * @return Songlist_Song[]
 */
function songlist_all_songs(): array {
	$song_posts = get_posts(
		array(
			'post_type'              => SONGLIST_POST_TYPE,
			'post_status'            => 'publish',
			// The list exists to show every song, and a repertoire is at most a few hundred.
			'numberposts'            => -1,
			'orderby'                => 'title',
			'order'                  => 'ASC',
			// Songs have no terms, so that query would be wasted on every page view.
			'update_post_term_cache' => false,
		)
	);

	return array_map(
		static fn ( WP_Post $song_post ): Songlist_Song => new Songlist_Song(
			get_the_title( $song_post ),
			songlist_artist_of( $song_post->ID )
		),
		$song_posts
	);
}
