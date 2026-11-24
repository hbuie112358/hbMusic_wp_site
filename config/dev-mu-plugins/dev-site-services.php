<?php
/**
 * Plugin Name: Dev site services
 * Description: On the dev site only: sends mail to Mailpit, and answers for Cloudflare Turnstile and for YouTube's oEmbed service and image server.
 *
 * Mounted only by compose.dev.yaml; it is never deployed. The mail never leaves the computer, and
 * the tests need no outside service: only Cloudflare, which the project does not own, is simulated.
 * The real Turnstile is proven on staging.
 *
 * @package dev-site
 */

defined( 'ABSPATH' ) || exit;

// A second stop, should this file ever reach a real site: it would otherwise swallow all mail.
if ( 'local' !== wp_get_environment_type() ) {
	return;
}

const DEVSITE_MAIL_HOST            = 'mailpit';
const DEVSITE_MAIL_PORT            = 1025;
const DEVSITE_MAIL_SENDER          = 'wordpress@dev-site.example.test';
const DEVSITE_PASSING_TOKEN        = 'dev-pass';
const DEVSITE_TURNSTILE_VERIFY_URL = 'https://challenges.cloudflare.com/turnstile/v0/siteverify';

/**
 * Sends the site's mail to Mailpit.
 *
 * @param PHPMailer\PHPMailer\PHPMailer $mailer The mailer WordPress is about to use.
 */
function devsite_send_mail_to_mailpit( PHPMailer\PHPMailer\PHPMailer $mailer ): void {
	$mailer->isSMTP();
	$mailer->Host     = DEVSITE_MAIL_HOST; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase -- PHPMailer's own name.
	$mailer->Port     = DEVSITE_MAIL_PORT; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase -- PHPMailer's own name.
	$mailer->SMTPAuth = false; // phpcs:ignore WordPress.NamingConventions.ValidVariableName.UsedPropertyNotSnakeCase -- PHPMailer's own name.
}
add_action( 'phpmailer_init', 'devsite_send_mail_to_mailpit' );

/**
 * Gives dev site mail a valid sender: the booking form builds one from the site's domain, and
 * "localhost" has no dot, so the mailer would refuse it. Real sites have a real domain.
 *
 * @return string The sender's address.
 */
function devsite_mail_sender(): string {
	return DEVSITE_MAIL_SENDER;
}
add_filter( 'wp_mail_from', 'devsite_mail_sender' );

/**
 * Answers Turnstile's verification request as Cloudflare would: only the passing token succeeds.
 *
 * @param false|array<string, mixed>|WP_Error $preempted_response Any earlier answer to the request.
 * @param array<string, mixed>                $request            The request's arguments.
 * @param string                              $url                The request's address.
 * @return false|array<string, mixed>|WP_Error The answer; false lets the request go out.
 */
function devsite_answer_turnstile( $preempted_response, array $request, string $url ) {
	if ( DEVSITE_TURNSTILE_VERIFY_URL !== $url ) {
		return $preempted_response;
	}
	$fields = is_array( $request['body'] ?? null ) ? $request['body'] : array();

	return array(
		'response' => array( 'code' => 200 ),
		'body'     => (string) wp_json_encode( array( 'success' => DEVSITE_PASSING_TOKEN === ( $fields['response'] ?? '' ) ) ),
	);
}
add_filter( 'pre_http_request', 'devsite_answer_turnstile', 10, 3 );

// YouTube's image server, answered with a neutral test picture (fixtures/video-picture.jpg), so the
// theme's click-to-load videos (plan 9v) get their pictures without the network. One video ID
// answers "not found", so the dark box shown without a picture is tested too.
const DEVSITE_VIDEO_PICTURE_HOST    = 'i.ytimg.com';
const DEVSITE_VIDEO_PICTURE_FIXTURE = __DIR__ . '/fixtures/video-picture.jpg';
const DEVSITE_VIDEO_WITHOUT_PICTURE = 'noPicture01';

/**
 * Answers YouTube's image server as it would for a video: the picture, written where the theme
 * asked for it, or "not found" for the one video kept without a picture.
 *
 * @param false|array<string, mixed>|WP_Error $preempted_response Any earlier answer to the request.
 * @param array<string, mixed>                $request            The request's arguments.
 * @param string                              $url                The request's address.
 * @return false|array<string, mixed>|WP_Error The answer; false lets the request go out.
 */
function devsite_answer_video_pictures( $preempted_response, array $request, string $url ) {
	if ( DEVSITE_VIDEO_PICTURE_HOST !== wp_parse_url( $url, PHP_URL_HOST ) ) {
		return $preempted_response;
	}
	$target = is_string( $request['filename'] ?? null ) ? $request['filename'] : '';
	if ( str_contains( $url, '/' . DEVSITE_VIDEO_WITHOUT_PICTURE . '/' ) || '' === $target || ! copy( DEVSITE_VIDEO_PICTURE_FIXTURE, $target ) ) {
		return array(
			'response' => array( 'code' => 404 ),
			'body'     => '',
		);
	}
	return array(
		'response' => array( 'code' => 200 ),
		'body'     => '',
		'filename' => $target,
	);
}
add_filter( 'pre_http_request', 'devsite_answer_video_pictures', 10, 3 );

// YouTube's oEmbed service, which WordPress asks to turn a video block's address into its player.
// Answered here with a player as YouTube writes it, so the stand-in videos are real video blocks,
// as the editor saves them, and the dev site loads the same WordPress styles as live (a fault in
// the click-to-load videos showed only there: WordPress's video block stylesheet, which plain
// HTML stand-ins never loaded). Neutral titles by video ID; any other video gets a generic one.
const DEVSITE_OEMBED_ADDRESS = 'https://www.youtube.com/oembed';
const DEVSITE_VIDEO_TITLES   = array(
	'sampleFeat1' => 'Sample featured video',
	'sampleVid01' => 'Sample video',
	'sampleVid02' => 'Sample video of the second set',
);
const DEVSITE_VIDEO_TITLE    = 'Stand-in video';
// The player's size in the answer: YouTube's own default for an embedded player.
const DEVSITE_PLAYER_WIDTH  = 560;
const DEVSITE_PLAYER_HEIGHT = 315;

/**
 * Answers YouTube's oEmbed service as it would for a video: its title and player.
 *
 * @param false|array<string, mixed>|WP_Error $preempted_response Any earlier answer to the request.
 * @param array<string, mixed>                $request            The request's arguments.
 * @param string                              $url                The request's address.
 * @return false|array<string, mixed>|WP_Error The answer; false lets the request go out.
 */
function devsite_answer_video_lookup( $preempted_response, array $request, string $url ) {
	if ( ! str_starts_with( $url, DEVSITE_OEMBED_ADDRESS . '?' ) ) {
		return $preempted_response;
	}
	$video_id = devsite_looked_up_video_id( $url );
	$title    = DEVSITE_VIDEO_TITLES[ $video_id ] ?? DEVSITE_VIDEO_TITLE;
	$player   = sprintf(
		'<iframe width="%d" height="%d" src="https://www.youtube.com/embed/%s?feature=oembed" frameborder="0" allow="autoplay; encrypted-media; picture-in-picture" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen title="%s"></iframe>',
		DEVSITE_PLAYER_WIDTH,
		DEVSITE_PLAYER_HEIGHT,
		rawurlencode( $video_id ),
		esc_attr( $title )
	);
	return array(
		'response' => array( 'code' => 200 ),
		'headers'  => array( 'content-type' => 'application/json' ),
		'body'     => (string) wp_json_encode(
			array(
				'type'          => 'video',
				'version'       => '1.0',
				'provider_name' => 'YouTube',
				'title'         => $title,
				'width'         => DEVSITE_PLAYER_WIDTH,
				'height'        => DEVSITE_PLAYER_HEIGHT,
				'html'          => $player,
			)
		),
	);
}
add_filter( 'pre_http_request', 'devsite_answer_video_lookup', 10, 3 );

/**
 * The video ID in an oEmbed request: the "v" of the watch address it asks about.
 *
 * @param string $lookup_url The oEmbed request's address.
 * @return string The video ID, or an empty string.
 */
function devsite_looked_up_video_id( string $lookup_url ): string {
	$lookup_query = (string) wp_parse_url( $lookup_url, PHP_URL_QUERY );
	wp_parse_str( $lookup_query, $lookup );
	$video_query = is_string( $lookup['url'] ?? null ) ? (string) wp_parse_url( $lookup['url'], PHP_URL_QUERY ) : '';
	wp_parse_str( $video_query, $video );
	return is_string( $video['v'] ?? null ) ? $video['v'] : '';
}
