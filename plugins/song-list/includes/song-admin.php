<?php
/**
 * The admin screens for songs: the artist field and the list's Artist column.
 *
 * @package song-list
 */

defined( 'ABSPATH' ) || exit;

const SONGLIST_ARTIST_FIELD = 'songlist-artist';
const SONGLIST_NONCE_FIELD  = 'songlist-artist-nonce';
const SONGLIST_NONCE_ACTION = 'songlist_save_artist';
const SONGLIST_COLUMN       = 'songlist-artist';

/**
 * Adds the artist box to the song screen.
 */
function songlist_add_artist_box(): void {
	add_meta_box(
		'songlist-artist-box',
		__( 'Artist', 'song-list' ),
		'songlist_print_artist_box',
		SONGLIST_POST_TYPE,
		'normal',
		'high'
	);
}

/**
 * Prints the artist field.
 *
 * @param WP_Post $song_post The song being edited.
 */
function songlist_print_artist_box( WP_Post $song_post ): void {
	wp_nonce_field( SONGLIST_NONCE_ACTION, SONGLIST_NONCE_FIELD );
	printf(
		'<label class="screen-reader-text" for="%1$s">%2$s</label><input type="text" class="widefat" id="%1$s" name="%1$s" value="%3$s">',
		esc_attr( SONGLIST_ARTIST_FIELD ),
		esc_html__( 'Artist', 'song-list' ),
		esc_attr( songlist_artist_of( $song_post->ID ) )
	);
}

/**
 * Saves the artist field; an empty field removes the stored artist.
 *
 * WordPress also fires this hook for saves without the form (Quick Edit, imports). They carry
 * no nonce and are left alone, so they can never erase an artist.
 *
 * @param int $song_id The song's post ID.
 */
function songlist_save_artist( int $song_id ): void {
	if ( ! wp_verify_nonce( songlist_posted_text( SONGLIST_NONCE_FIELD ), SONGLIST_NONCE_ACTION ) ) {
		return;
	}
	if ( ! current_user_can( 'edit_post', $song_id ) ) {
		return;
	}

	$artist = songlist_posted_text( SONGLIST_ARTIST_FIELD );
	if ( '' === $artist ) {
		delete_post_meta( $song_id, SONGLIST_ARTIST_META_KEY );
		return;
	}
	update_post_meta( $song_id, SONGLIST_ARTIST_META_KEY, $artist );
}

/**
 * Reads one submitted text field, cleaned; empty when it is missing or not text.
 *
 * @param string $field_name The form field's name.
 * @return string The cleaned value.
 */
function songlist_posted_text( string $field_name ): string {
	// phpcs:ignore WordPress.Security.NonceVerification.Missing, WordPress.Security.ValidatedSanitizedInput.MissingUnslash, WordPress.Security.ValidatedSanitizedInput.InputNotSanitized -- The caller verifies the nonce, which is itself read here; the value is cleaned below, once it is known to be text.
	$posted_value = $_POST[ $field_name ] ?? '';

	return is_string( $posted_value ) ? sanitize_text_field( wp_unslash( $posted_value ) ) : '';
}

/**
 * Adds the Artist column after the title in the admin's list of songs.
 *
 * @param array<string, string> $columns The columns, by name.
 * @return array<string, string>
 */
function songlist_add_artist_column( array $columns ): array {
	$with_artist = array();
	foreach ( $columns as $column_name => $column_label ) {
		$with_artist[ $column_name ] = $column_label;
		if ( 'title' === $column_name ) {
			$with_artist[ SONGLIST_COLUMN ] = __( 'Artist', 'song-list' );
		}
	}

	return $with_artist;
}

/**
 * Prints one song's artist in the Artist column.
 *
 * @param string $column_name The column being printed.
 * @param int    $song_id     The song's post ID.
 */
function songlist_print_artist_column( string $column_name, int $song_id ): void {
	if ( SONGLIST_COLUMN === $column_name ) {
		echo esc_html( songlist_artist_of( $song_id ) );
	}
}
