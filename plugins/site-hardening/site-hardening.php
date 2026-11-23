<?php
/**
 * Plugin Name:       Site Hardening
 * Description:       Sends a Content-Security-Policy and the other security headers on visitor pages (HSTS on HTTPS), refuses XML-RPC, turns Application Passwords off, hides version comments, WordPress's version and the PHP version, and keeps unfiltered HTML for Administrators only. Each site adds the outside sources its pages need.
 * Version:           0.3.0
 * Requires at least: 7.0
 * Requires PHP:      8.4
 * License:           GPL-2.0-or-later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       site-hardening
 * Update URI:        false
 *
 * "Update URI: false" keeps WordPress from offering a plugin of the same name from WordPress.org
 * as an update of this one, which would replace the site's code with a stranger's.
 *
 * @package site-hardening
 */

defined( 'ABSPATH' ) || exit;

require_once __DIR__ . '/includes/security-headers.php';
require_once __DIR__ . '/includes/xml-rpc.php';
require_once __DIR__ . '/includes/login-surface.php';
require_once __DIR__ . '/includes/php-version.php';
require_once __DIR__ . '/includes/unfiltered-html.php';
