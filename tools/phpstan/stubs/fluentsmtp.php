<?php
/**
 * PHPStan stub: the one FluentSMTP class this project calls
 * (local/wp-cli/configure-fluentsmtp-mailpit.php, plan decision D13).
 *
 * FluentSMTP publishes no stubs. The signature is taken from FluentSMTP 2.4.1,
 * app/Models/Settings.php; check it again whenever FLUENT_SMTP_VERSION changes.
 *
 * @package hbmusic
 */

namespace FluentMail\App\Models;

/**
 * FluentSMTP's settings model.
 */
class Settings {

	/**
	 * Saves a connection the way FluentSMTP's settings screen does, and returns all settings.
	 *
	 * @param array{connection_key: string, valid_senders: list<string>, connection: array<string, string>} $inputs The connection to save.
	 * @return array<string, mixed>
	 */
	public function store( $inputs ) {}
}
