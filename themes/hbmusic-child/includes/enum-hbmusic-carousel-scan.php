<?php
/**
 * The state of the scan that names carousels after headings (hbmusic_name_carousels_after_headings()
 * in functions.php). In a file of its own: the coding standards keep functions and types apart.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;

/**
 * Where a scan of the page's tags stands relative to the last heading: inside it, directly after
 * it (the next tag decides whether a carousel follows), or anywhere else.
 */
enum Hbmusic_Carousel_Scan {
	case Elsewhere;
	case InHeading;
	case AfterHeading;
}
