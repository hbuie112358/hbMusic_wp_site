<?php
/**
 * Dev site only, never deployed: writes each PHP notice, warning and deprecation into the debug
 * log with its origin, the first file under wp-content/ on the call path (template plan 1.5b).
 *
 * The log line PHP writes names the file where the message arose, which is often WordPress's own
 * even when a plugin or the theme caused it (a null passed to a WordPress function, a function
 * "called incorrectly"). The scenario checks (tests/scenario/debug-log.sh) sort by this origin:
 * the site's own code must stay silent, while other people's notices, warnings and deprecations
 * are shown, not failed. A message with no file under wp-content/ on its path is WordPress's own
 * (origin "WordPress"). Fatal errors cannot be caught here; PHP writes them itself, and the checks always fail on them,
 * as on any line written without an origin.
 *
 * @package dev-site
 */

// phpcs:ignore WordPress.PHP.DevelopmentFunctions.error_log_set_error_handler -- the dev site's debug log is this file's purpose; never deployed.
set_error_handler(
	static function ( int $level, string $message, string $file = '', int $line = 0 ): bool {
		// A message silenced with @ is left to PHP, which does not log it either.
		// phpcs:ignore WordPress.PHP.DevelopmentFunctions.prevent_path_disclosure_error_reporting, WordPress.PHP.DiscouragedPHPFunctions.runtime_configuration_error_reporting -- read only, never changed.
		if ( 0 === ( error_reporting() & $level ) ) {
			return false;
		}
		$level_names = array(
			E_WARNING         => 'Warning',
			E_USER_WARNING    => 'Warning',
			E_NOTICE          => 'Notice',
			E_USER_NOTICE     => 'Notice',
			E_DEPRECATED      => 'Deprecated',
			E_USER_DEPRECATED => 'Deprecated',
		);
		$content_dir = WP_CONTENT_DIR . '/';
		$origin      = 'WordPress';
		$places      = array(
			array(
				'file' => $file,
				'line' => $line,
			),
		);
		// The frames from the caller outward; the handler's own frame is skipped.
		// phpcs:ignore WordPress.PHP.DevelopmentFunctions.error_log_debug_backtrace -- the origin is this file's purpose; never deployed.
		foreach ( array_slice( debug_backtrace( DEBUG_BACKTRACE_IGNORE_ARGS ), 1 ) as $frame ) {
			$places[] = array(
				'file' => $frame['file'] ?? '',
				'line' => $frame['line'] ?? 0,
			);
		}
		foreach ( $places as $place ) {
			if ( str_starts_with( $place['file'], $content_dir ) && __FILE__ !== $place['file'] ) {
				$origin = substr( $place['file'], strlen( $content_dir ) ) . ':' . $place['line'];
				break;
			}
		}
		// One line per message, so a multi-line message cannot pass for an origin's line.
		$one_line = str_replace( array( "\r", "\n" ), ' ', $message );
		// phpcs:ignore WordPress.PHP.DevelopmentFunctions.error_log_error_log -- the dev site's debug log is this file's purpose.
		error_log( sprintf( 'DEV ORIGIN %s %s | %s in %s on line %d', $level_names[ $level ] ?? 'Error', $origin, $one_line, $file, $line ) );
		// PHP's own line for it is not written: this one replaces it.
		return true;
	}
);
