<?php
/**
 * Plugin Name: Dev site services
 * Description: On the dev site only: sends mail to Mailpit, and answers for Cloudflare Turnstile.
 *
 * Mounted only by compose.dev.yaml; it is never deployed. The mail never leaves the computer, and
 * the tests need no outside service: only Cloudflare, which the project does not own, is simulated.
 * The real Turnstile is proven on staging.
 *
 * @package hbmusic
 */

defined( 'ABSPATH' ) || exit;

// A second stop, should this file ever reach a real site: it would otherwise swallow all mail.
if ( 'local' !== wp_get_environment_type() ) {
	return;
}

const HBMUSIC_DEV_MAIL_HOST        = 'mailpit';
const HBMUSIC_DEV_MAIL_PORT        = 1025;
const HBMUSIC_DEV_MAIL_SENDER      = 'wordpress@dev-site.example.test';
const HBMUSIC_DEV_PASSING_TOKEN    = 'dev-pass';
const HBMUSIC_TURNSTILE_VERIFY_URL = 'https://challenges.cloudflare.com/turnstile/v0/siteverify';

/**
 * Sends the site's mail to Mailpit.
 *
 * @param PHPMailer\PHPMailer\PHPMailer $mailer The mailer WordPress is about to use.
 */
function hbmusic_dev_send_mail_to_mailpit( PHPMailer\PHPMailer\PHPMailer $mailer ): void {
	$mailer->isSMTP();
	$mailer->Host     = HBMUSIC_DEV_MAIL_HOST; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase -- PHPMailer's own name.
	$mailer->Port     = HBMUSIC_DEV_MAIL_PORT; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase -- PHPMailer's own name.
	$mailer->SMTPAuth = false; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase -- PHPMailer's own name.
}
add_action( 'phpmailer_init', 'hbmusic_dev_send_mail_to_mailpit' );

/**
 * Gives dev site mail a valid sender: the booking form builds one from the site's domain, and
 * "localhost" has no dot, so the mailer would refuse it. Real sites have a real domain.
 *
 * @return string The sender's address.
 */
function hbmusic_dev_mail_sender(): string {
	return HBMUSIC_DEV_MAIL_SENDER;
}
add_filter( 'wp_mail_from', 'hbmusic_dev_mail_sender' );

/**
 * Answers Turnstile's verification request as Cloudflare would: only the passing token succeeds.
 *
 * @param false|array<string, mixed>|WP_Error $preempted_response Any earlier answer to the request.
 * @param array<string, mixed>                $request            The request's arguments.
 * @param string                              $url                The request's address.
 * @return false|array<string, mixed>|WP_Error The answer; false lets the request go out.
 */
function hbmusic_dev_answer_turnstile( $preempted_response, array $request, string $url ) {
	if ( HBMUSIC_TURNSTILE_VERIFY_URL !== $url ) {
		return $preempted_response;
	}
	$fields = is_array( $request['body'] ?? null ) ? $request['body'] : array();

	return array(
		'response' => array( 'code' => 200 ),
		'body'     => (string) wp_json_encode( array( 'success' => HBMUSIC_DEV_PASSING_TOKEN === ( $fields['response'] ?? '' ) ) ),
	);
}
add_filter( 'pre_http_request', 'hbmusic_dev_answer_turnstile', 10, 3 );
