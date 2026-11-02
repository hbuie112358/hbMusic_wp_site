<?php
/**
 * WP-CLI script (run with `wp eval-file`), for the local copy only: points FluentSMTP at the
 * Mailpit container, so every email the site sends lands in the local inbox (plan step 3b, D13).
 *
 * It saves through FluentSMTP's own code (FluentMail\App\Models\Settings::store, the same code
 * the settings screen calls), so the stored format and the handling of secrets stay the
 * plugin's concern. If an update changes that code, the mail-delivery scenario check
 * (tests/scenario/mail-delivery.sh, run by bin/test) fails and says so.
 *
 * Settings come from the container's environment (compose.yaml and .env).
 *
 * No declare( strict_types=1 ): `wp eval-file` evaluates the file's text with eval(), where
 * PHP rejects that declaration; the function signatures carry the types instead.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;

/**
 * Reads one required setting from the environment, stopping WP-CLI with its name if missing.
 *
 * @param string $name The environment variable.
 * @return string Its value.
 */
function hbmusic_local_required_setting( string $name ): string {
	$value = getenv( $name );
	if ( false === $value || '' === $value ) {
		WP_CLI::error( sprintf( 'The setting %s is missing; it comes from compose.yaml and .env.', $name ) );
	}
	return $value;
}

/**
 * Reads a required TCP port from the environment, stopping WP-CLI unless it is 1-65535.
 *
 * @param string $name The environment variable.
 * @return string The port, as FluentSMTP stores it.
 */
function hbmusic_local_required_port( string $name ): string {
	$value = hbmusic_local_required_setting( $name );
	$port  = filter_var(
		$value,
		FILTER_VALIDATE_INT,
		array(
			'options' => array(
				'min_range' => 1,
				'max_range' => 65535,
			),
		)
	);
	if ( false === $port ) {
		WP_CLI::error( sprintf( 'The setting %s must be a port number from 1 to 65535, not "%s".', $name, $value ) );
	}
	return (string) $port;
}

/**
 * The SMTP connection to Mailpit, in the shape FluentSMTP's settings screen submits.
 *
 * Mailpit accepts mail without authentication or encryption; it never forwards anything.
 *
 * @return array<string, string> The connection's provider settings.
 */
function hbmusic_local_mailpit_connection(): array {
	return array(
		'provider'         => 'smtp',
		'sender_name'      => hbmusic_local_required_setting( 'LOCAL_MAIL_FROM_NAME' ),
		'sender_email'     => hbmusic_local_required_setting( 'LOCAL_MAIL_FROM' ),
		'force_from_name'  => 'no',
		'force_from_email' => 'yes',
		'return_path'      => 'yes',
		'host'             => hbmusic_local_required_setting( 'LOCAL_SMTP_HOST' ),
		'port'             => hbmusic_local_required_port( 'LOCAL_SMTP_PORT' ),
		'auth'             => 'no',
		'username'         => '',
		'password'         => '',
		'auto_tls'         => 'no',
		'encryption'       => 'none',
		'key_store'        => 'db',
	);
}

/**
 * Saves the Mailpit connection as FluentSMTP's default connection.
 */
function hbmusic_local_configure_fluentsmtp(): void {
	if ( 'local' !== wp_get_environment_type() ) {
		WP_CLI::error( 'Refusing to run: this script only configures a local copy (WP_ENVIRONMENT_TYPE is not "local").' );
	}
	if ( ! class_exists( \FluentMail\App\Models\Settings::class ) ) {
		WP_CLI::error( 'FluentSMTP is not active, so its settings cannot be saved.' );
	}
	$connection = hbmusic_local_mailpit_connection();
	( new \FluentMail\App\Models\Settings() )->store(
		array(
			'connection_key' => '',
			'valid_senders'  => array(),
			'connection'     => $connection,
		)
	);
	WP_CLI::success( sprintf( 'FluentSMTP sends to Mailpit at %s:%s.', $connection['host'], $connection['port'] ) );
}

hbmusic_local_configure_fluentsmtp();
