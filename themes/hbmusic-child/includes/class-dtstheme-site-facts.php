<?php
/**
 * The site's facts, read from the theme's site-facts.json (template plan 2.4b-2, T31).
 *
 * Why a settings file and not PHP: these facts (old addresses, the organization's types, the towns
 * served, the outside sources the security policy allows) are settings, not logic. A site changes
 * them by editing one JSON file every site has, next to theme.json, and the shared code here names
 * no site's values. Why JSON: PHP reads it without help (WordPress's own wp_json_file_decode()),
 * bin/check reads it with jq, and it is already the project's settings format (site.json,
 * theme.json). JSON has no comments, so the reason for each entry is a "reason" field instead,
 * which bin/check requires (the tools' tools/site-facts.jq); a comment could be left out or go
 * stale without any check noticing. The file's shape is held by bin/check before a commit; the
 * checks here only keep a damaged file from breaking the site.
 *
 * @package dts-theme
 */

defined( 'ABSPATH' ) || exit;

/**
 * The site's facts, read once per page load and then handed to the functions that use them.
 * Read-only: nothing changes them after they are read.
 */
final readonly class Dtstheme_Site_Facts {

	private const FACT_OLD_ADDRESSES      = 'oldAddresses';
	private const FACT_ORGANIZATION_TYPES = 'organizationTypes';
	private const FACT_AREAS_SERVED       = 'areasServed';
	private const FACT_OUTSIDE_SOURCES    = 'outsideSources';

	/**
	 * Yoast SEO's own type for the organization, kept when the site's list cannot be read: an empty
	 * type would make the page data invalid.
	 */
	private const DEFAULT_ORGANIZATION_TYPES = array( 'Organization' );

	/**
	 * Builds the facts from values already checked.
	 *
	 * @param array<string, string>       $old_addresses      Each old page path and the path that replaced it, both without slashes at the ends.
	 * @param array<int, string>          $organization_types The organization's schema.org types.
	 * @param array<int, string>          $areas_served       The towns served, possibly none.
	 * @param array<string, list<string>> $outside_sources    The outside sources the pages need, by policy directive.
	 */
	public function __construct(
		public array $old_addresses,
		public array $organization_types,
		public array $areas_served,
		public array $outside_sources
	) {
	}

	/**
	 * Reads the facts from a site-facts.json. A missing or broken file leaves every fact at its
	 * default, and a fact of the wrong shape leaves that fact alone at its default, each with a line
	 * in the PHP error log: the site keeps working, without the facts it could not read.
	 *
	 * @param string $path The file.
	 * @return self The facts.
	 */
	public static function from_file( string $path ): self {
		try {
			$facts = self::read_file( $path );
		} catch ( Dtstheme_Site_Facts_Error $error ) {
			self::log_problem( $error->getMessage() . '; every fact is left at its default' );
			return self::defaults();
		}
		return new self(
			self::fact_or_default( $facts, self::FACT_OLD_ADDRESSES, self::parse_old_addresses( ... ), array() ),
			self::fact_or_default( $facts, self::FACT_ORGANIZATION_TYPES, self::parse_organization_types( ... ), self::DEFAULT_ORGANIZATION_TYPES ),
			self::fact_or_default( $facts, self::FACT_AREAS_SERVED, self::parse_areas_served( ... ), array() ),
			self::fact_or_default( $facts, self::FACT_OUTSIDE_SOURCES, self::parse_outside_sources( ... ), array() )
		);
	}

	/**
	 * The facts of a site whose file cannot be read: no redirects, Yoast's own type, no towns and no
	 * outside sources.
	 *
	 * @return self The defaults.
	 */
	private static function defaults(): self {
		return new self( array(), self::DEFAULT_ORGANIZATION_TYPES, array(), array() );
	}

	/**
	 * Reads the file as a JSON object.
	 *
	 * @param string $path The file.
	 * @return array<mixed> Its fields.
	 * @throws Dtstheme_Site_Facts_Error When the file is missing, unreadable or not a JSON object.
	 */
	private static function read_file( string $path ): array {
		if ( ! is_readable( $path ) ) {
			throw new Dtstheme_Site_Facts_Error( 'is missing or cannot be read' );
		}
		$facts = wp_json_file_decode( $path, array( 'associative' => true ) );
		if ( ! is_array( $facts ) ) {
			throw new Dtstheme_Site_Facts_Error( 'is not valid JSON or not a JSON object' );
		}
		return $facts;
	}

	/**
	 * One fact, read by its parser, or its default when it is missing or of the wrong shape. The
	 * fact's name goes into the log line here: the parsers' messages are fixed text, since the
	 * WordPress standard counts any name in a raised error's message as unescaped output.
	 *
	 * @template T of array
	 * @param array<mixed>       $facts    The file's fields.
	 * @param string             $name     The fact's field name.
	 * @param callable(mixed): T $parse    Reads the fact's value, raising Dtstheme_Site_Facts_Error on a wrong shape.
	 * @param array              $fallback The fact's default.
	 * @phpstan-param T          $fallback
	 * @return T The fact.
	 */
	private static function fact_or_default( array $facts, string $name, callable $parse, array $fallback ): array {
		if ( ! array_key_exists( $name, $facts ) ) {
			self::log_problem( 'has no "' . $name . '"; it is left at its default' );
			return $fallback;
		}
		try {
			return $parse( $facts[ $name ] );
		} catch ( Dtstheme_Site_Facts_Error $error ) {
			self::log_problem( '"' . $name . '" ' . $error->getMessage() . '; it is left at its default (bin/check names the entry)' );
			return $fallback;
		}
	}

	/**
	 * The old addresses, from a list of { "from", "to", "reason" } entries.
	 *
	 * @param mixed $value The fact's value.
	 * @return array<string, string> Each old path and the path that replaced it.
	 */
	private static function parse_old_addresses( mixed $value ): array {
		$old_addresses = array();
		foreach ( self::list_of_objects( $value ) as $entry ) {
			$old_addresses[ self::text_field( $entry, 'from' ) ] = self::text_field( $entry, 'to' );
		}
		return $old_addresses;
	}

	/**
	 * The organization's types, from { "types", "reason" }; at least one.
	 *
	 * @param mixed $value The fact's value.
	 * @return list<string> The types.
	 * @throws Dtstheme_Site_Facts_Error When no type is named.
	 */
	private static function parse_organization_types( mixed $value ): array {
		$types = self::list_of_text( self::field( $value, 'types' ) );
		if ( array() === $types ) {
			throw new Dtstheme_Site_Facts_Error( 'names no type' );
		}
		return $types;
	}

	/**
	 * The towns served, from { "towns", "reason" }; possibly none.
	 *
	 * @param mixed $value The fact's value.
	 * @return list<string> The towns.
	 */
	private static function parse_areas_served( mixed $value ): array {
		return self::list_of_text( self::field( $value, 'towns' ) );
	}

	/**
	 * The outside sources, from a list of { "directive", "source", "reason" } entries, grouped by
	 * directive as the Site Hardening plugin's sitehardening_csp_sources filter takes them.
	 *
	 * @param mixed $value The fact's value.
	 * @return array<string, list<string>> The sources, by directive.
	 */
	private static function parse_outside_sources( mixed $value ): array {
		$outside_sources = array();
		foreach ( self::list_of_objects( $value ) as $entry ) {
			$outside_sources[ self::text_field( $entry, 'directive' ) ][] = self::text_field( $entry, 'source' );
		}
		return $outside_sources;
	}

	/**
	 * A fact's value as a list of JSON objects.
	 *
	 * @param mixed $value The value.
	 * @return list<array<mixed>> The objects.
	 * @throws Dtstheme_Site_Facts_Error When the value is not a list of objects.
	 */
	private static function list_of_objects( mixed $value ): array {
		if ( ! is_array( $value ) || ! array_is_list( $value ) ) {
			throw new Dtstheme_Site_Facts_Error( 'is not a list' );
		}
		$entries = array();
		foreach ( $value as $entry ) {
			if ( ! is_array( $entry ) ) {
				throw new Dtstheme_Site_Facts_Error( 'has an entry that is not an object' );
			}
			$entries[] = $entry;
		}
		return $entries;
	}

	/**
	 * A value as a list of texts.
	 *
	 * @param mixed $value The value.
	 * @return list<string> The texts.
	 * @throws Dtstheme_Site_Facts_Error When the value is not a list of non-empty texts.
	 */
	private static function list_of_text( mixed $value ): array {
		if ( ! is_array( $value ) || ! array_is_list( $value ) ) {
			throw new Dtstheme_Site_Facts_Error( 'does not hold a list' );
		}
		$texts = array();
		foreach ( $value as $text ) {
			if ( ! is_string( $text ) || '' === $text ) {
				throw new Dtstheme_Site_Facts_Error( 'has an entry that is not text' );
			}
			$texts[] = $text;
		}
		return $texts;
	}

	/**
	 * One field of a JSON object.
	 *
	 * @param mixed  $value The object.
	 * @param string $field The field's name.
	 * @return mixed The field's value.
	 * @throws Dtstheme_Site_Facts_Error When the value is not an object or has no such field.
	 */
	private static function field( mixed $value, string $field ): mixed {
		if ( ! is_array( $value ) || ! array_key_exists( $field, $value ) ) {
			throw new Dtstheme_Site_Facts_Error( 'is missing one of its fields' );
		}
		return $value[ $field ];
	}

	/**
	 * One field of a JSON object, as non-empty text.
	 *
	 * @param array<mixed> $entry The object.
	 * @param string       $field The field's name.
	 * @return string The text.
	 * @throws Dtstheme_Site_Facts_Error When the field is missing or not non-empty text.
	 */
	private static function text_field( array $entry, string $field ): string {
		$text = $entry[ $field ] ?? null;
		if ( ! is_string( $text ) || '' === $text ) {
			throw new Dtstheme_Site_Facts_Error( 'has an entry with a field that is missing or not text' );
		}
		return $text;
	}

	/**
	 * Writes a problem with the file to the PHP error log.
	 *
	 * Why the theme writes its own line: wp_json_file_decode() reports a missing or broken file
	 * through wp_trigger_error(), which does nothing unless WP_DEBUG is on (WordPress 7.1's
	 * wp-includes/functions.php). WP_DEBUG is off on staging and live (the site standard, 2.3), so
	 * there the facts would fall away without a trace: old addresses no longer redirected, and the
	 * booking form's Turnstile check blocked by the stricter policy. PHP's error log is on in both
	 * places, outside the web root, and is what bin/deploy and the monthly site check read.
	 *
	 * @param string $problem What is wrong, and what was left at its default.
	 */
	private static function log_problem( string $problem ): void {
		// phpcs:ignore WordPress.PHP.DevelopmentFunctions.error_log_error_log -- the one way to reach the log with WP_DEBUG off; see above.
		error_log( 'dts-theme: the theme\'s site-facts.json ' . $problem . '.' );
	}
}
