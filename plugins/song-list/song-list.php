<?php
/**
 * Plugin Name:       Song List
 * Description:       Keeps a musician's songs in the WordPress admin and shows them on a page with the Song List block.
 * Version:           0.1.0
 * Requires at least: 7.0
 * Requires PHP:      8.4
 * License:           GPL-2.0-or-later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       song-list
 * Update URI:        false
 *
 * "Update URI: false" keeps WordPress from offering a plugin of the same name from WordPress.org
 * as an update of this one, which would replace the site's code with a stranger's.
 *
 * @package song-list
 */

defined( 'ABSPATH' ) || exit;

// Prefixed, because a shared plugin may run beside others that also have a "song" type.
const SONGLIST_POST_TYPE       = 'songlist_song';
const SONGLIST_ARTIST_META_KEY = 'songlist_artist';

require_once __DIR__ . '/includes/class-songlist-song.php';
require_once __DIR__ . '/includes/song-type.php';
require_once __DIR__ . '/includes/song-admin.php';
require_once __DIR__ . '/includes/song-list-block.php';

add_action( 'init', 'songlist_register_song_type' );
add_action( 'init', 'songlist_register_block' );
add_action( 'add_meta_boxes_' . SONGLIST_POST_TYPE, 'songlist_add_artist_box' );
add_action( 'save_post_' . SONGLIST_POST_TYPE, 'songlist_save_artist' );
add_filter( 'manage_' . SONGLIST_POST_TYPE . '_posts_columns', 'songlist_add_artist_column' );
add_action( 'manage_' . SONGLIST_POST_TYPE . '_posts_custom_column', 'songlist_print_artist_column', 10, 2 );
