<?php
/**
 * The Song List block, which shows every song on a page.
 *
 * @package song-list
 */

defined( 'ABSPATH' ) || exit;

/**
 * Registers the block in PHP alone, with its stylesheet.
 *
 * The autoRegister support (WordPress 7.0) makes the editor offer a block that only has a PHP
 * render function, so the plugin needs no JavaScript or build step. The editor's half of this
 * feature still has an unstable internal name, so a browser test checks that the editor offers
 * the block.
 *
 * The stylesheet is the block's own "style", so WordPress loads it only on pages that show the
 * block, and in the editor; its "path" lets WordPress inline it, saving a request.
 */
function songlist_register_block(): void {
	$stylesheet = 'assets/song-list.css';
	wp_register_style(
		SONGLIST_STYLE_HANDLE,
		plugins_url( $stylesheet, SONGLIST_PLUGIN_FILE ),
		array(),
		SONGLIST_VERSION
	);
	wp_style_add_data( SONGLIST_STYLE_HANDLE, 'path', plugin_dir_path( SONGLIST_PLUGIN_FILE ) . $stylesheet );

	register_block_type(
		'songlist/song-list',
		array(
			'api_version'     => '3',
			'title'           => __( 'Song List', 'song-list' ),
			'description'     => __( 'Shows every song with its artist.', 'song-list' ),
			'category'        => 'widgets',
			'icon'            => 'playlist-audio',
			'supports'        => array(
				'autoRegister' => true,
				'html'         => false,
				'align'        => array( 'wide', 'full' ),
			),
			'style_handles'   => array( SONGLIST_STYLE_HANDLE ),
			'render_callback' => 'songlist_render_block',
		)
	);
}

/**
 * Renders the block for the page being shown.
 *
 * @return string The block's HTML.
 */
function songlist_render_block(): string {
	return sprintf(
		'<div %s>%s</div>',
		get_block_wrapper_attributes(),
		songlist_songs_html( songlist_all_songs() )
	);
}

/**
 * Builds the list's HTML: a table, because each song pairs a title with an artist, and a screen
 * reader then announces which column a value belongs to.
 *
 * @param Songlist_Song[] $songs The songs, in display order.
 * @return string The escaped HTML.
 */
function songlist_songs_html( array $songs ): string {
	if ( array() === $songs ) {
		return '<p>' . esc_html__( 'No songs yet.', 'song-list' ) . '</p>';
	}

	$rows = implode( '', array_map( 'songlist_song_row_html', $songs ) );

	return sprintf(
		'<table><thead><tr><th scope="col">%1$s</th><th scope="col">%2$s</th></tr></thead><tbody>%3$s</tbody></table>',
		esc_html__( 'Title', 'song-list' ),
		esc_html__( 'Artist', 'song-list' ),
		$rows
	);
}

/**
 * Builds one song's table row.
 *
 * @param Songlist_Song $song The song.
 * @return string The escaped HTML.
 */
function songlist_song_row_html( Songlist_Song $song ): string {
	return sprintf(
		'<tr><td>%1$s</td><td>%2$s</td></tr>',
		esc_html( $song->title ),
		esc_html( $song->artist )
	);
}
