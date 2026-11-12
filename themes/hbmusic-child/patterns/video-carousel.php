<?php
/**
 * Title: Video carousel
 * Slug: hbmusic/video-carousel
 * Categories: media
 * Keywords: video, videos, carousel, youtube
 * Description: A row of videos that scrolls sideways, with an optional name above it. Type a name (for example "Rock") or leave it empty, and it stays off the page. Paste a YouTube link into each video; add or remove videos as needed.
 *
 * An optional heading directly above the carousel (site-carousel.css), which holds three empty
 * YouTube embeds, each showing the editor's box for a link (plan D29; the user wanted carousels
 * added like any block, several per page, a name only when wanted). The heading starts empty, with
 * hint text in the editor only: left empty, it is dropped from the page (hbmusic_drop_empty_
 * heading()) and the carousel keeps its label "Videos"; given text, it names the carousel for
 * screen readers (hbmusic_name_carousels_after_headings()). Empty embeds show nothing on the page,
 * so unused ones do no harm.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;
?>
<!-- wp:heading {"placeholder":"Carousel name (optional)"} -->
<h2 class="wp-block-heading"></h2>
<!-- /wp:heading -->

<!-- wp:group {"tagName":"section","ariaLabel":"Videos","align":"wide","className":"site-carousel","layout":{"type":"default"}} -->
<section class="wp-block-group alignwide site-carousel" aria-label="Videos">
	<!-- wp:embed {"providerNameSlug":"youtube","responsive":true} /-->

	<!-- wp:embed {"providerNameSlug":"youtube","responsive":true} /-->

	<!-- wp:embed {"providerNameSlug":"youtube","responsive":true} /-->
</section>
<!-- /wp:group -->
