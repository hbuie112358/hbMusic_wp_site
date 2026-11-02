<?php
/**
 * PHPStan stub: the parts of WP-CLI's API this project calls.
 *
 * Hand-written because the published php-stubs/wp-cli-stubs (2.12.0) only accepts WordPress
 * stubs up to 6.x, which would hold the WordPress 7.1 stubs back. Replace this file with that
 * package once it supports the WordPress 7 stubs. Signatures follow WP-CLI 2.12.
 *
 * @package hbmusic
 */

/**
 * WP-CLI's main class (static API).
 */
class WP_CLI {

	/**
	 * Prints an error message and, by default, exits with status 1.
	 *
	 * @param string|WP_Error|Exception $message Message to print.
	 * @param bool|int                  $exit    True or an exit code: stop after printing.
	 * @phpstan-return ($exit is false ? void : never)
	 */
	public static function error( $message, $exit = true ) {}

	/**
	 * Prints a success message.
	 *
	 * @param string $message Message to print.
	 */
	public static function success( $message ): void {}
}
