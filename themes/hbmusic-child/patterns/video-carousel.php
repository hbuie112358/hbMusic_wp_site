<?php
/**
 * Title: Video carousel
 * Slug: hbmusic/video-carousel
 * Categories: media
 * Keywords: video, videos, carousel, youtube
 * Description: A row of videos that scrolls sideways. Paste a YouTube link into each video; add or remove videos as needed. Put a heading directly above it to name it (for example "Rock"), or leave it without one.
 *
 * The carousel (site-carousel.css) with three empty YouTube embeds, each showing the editor's box
 * for a link (plan D29; the user wanted carousels added like any block, several per page, with or
 * without a heading). Its label "Videos" names it for screen readers; a heading directly above it
 * replaces that name (hbmusic_name_carousels_after_headings()). Empty embeds show nothing on the
 * page, so unused ones do no harm.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;
?>
<!-- wp:group {"tagName":"section","ariaLabel":"Videos","align":"wide","className":"site-carousel","layout":{"type":"default"}} -->
<section class="wp-block-group alignwide site-carousel" aria-label="Videos">
	<!-- wp:embed {"providerNameSlug":"youtube","responsive":true} /-->

	<!-- wp:embed {"providerNameSlug":"youtube","responsive":true} /-->

	<!-- wp:embed {"providerNameSlug":"youtube","responsive":true} /-->
</section>
<!-- /wp:group -->
