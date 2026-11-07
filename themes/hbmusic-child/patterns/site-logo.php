<?php
/**
 * Title: Site logo
 * Slug: hbmusic/site-logo
 * Inserter: no
 *
 * The logo ships with the theme, so every site gets it from the deploy, with no upload and no
 * setting in the database. PHP asks WordPress for both addresses, so no domain is written here.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;
?>
<!-- wp:html -->
<a class="hb-site-logo" href="<?php echo esc_url( home_url( '/' ) ); ?>"><img src="<?php echo esc_url( get_theme_file_uri( 'assets/images/howard-buie-logo.png' ) ); ?>" width="56" height="56" alt="<?php esc_attr_e( 'Home', 'hbmusic' ); ?>"></a>
<!-- /wp:html -->
