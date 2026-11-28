<?php
/**
 * The problem raised when the theme's site-facts.json, or one fact in it, cannot be used (template
 * plan 2.4b-2, T31). In a file of its own: the coding standards keep one type per file.
 *
 * @package dts-theme
 */

defined( 'ABSPATH' ) || exit;

/**
 * Something in site-facts.json that the theme cannot use: the file missing or not JSON, or a fact
 * of the wrong shape. Its message is fixed text saying what is wrong; Dtstheme_Site_Facts, which
 * raises and catches it, adds the fact's name when it writes the line to the PHP error log, and then
 * leaves the fact at its default. Never shown to visitors.
 */
final class Dtstheme_Site_Facts_Error extends UnexpectedValueException {
}
