<?php
/**
 * Hands the site's facts to the functions that use them, each hooked where WordPress, Yoast SEO and
 * the Site Hardening plugin ask for it (template plan 2.4b-2, T31). In a file of its own: the
 * coding standards keep one type per file.
 *
 * @package dts-theme
 */

defined( 'ABSPATH' ) || exit;

/**
 * The theme's hooks that need the site's facts. The facts are passed in when it is built and never
 * change, so the functions it calls read no file and name no site, and the tools' tests can call
 * those functions with stand-in facts. A class with one method per hook rather than closures:
 * PHPStan gives a closure passed to add_filter() the filter's untyped value whatever its own type
 * notes say (checked on a scratch file, 2026-11-27), while a method's type notes hold.
 */
final readonly class Dtstheme_Site_Facts_Hooks {

	/**
	 * Builds the hooks around the site's facts.
	 *
	 * @param Dtstheme_Site_Facts $site_facts The site's facts.
	 */
	public function __construct( private Dtstheme_Site_Facts $site_facts ) {
	}

	/**
	 * Adds each hook.
	 */
	public function register(): void {
		add_filter( 'sitehardening_csp_sources', array( $this, 'add_outside_sources' ) );
		add_action( 'template_redirect', array( $this, 'redirect_old_address' ), 1 );
		add_filter( 'wpseo_schema_organization', array( $this, 'describe_organization' ) );
	}

	/**
	 * Adds the site's outside sources to the Site Hardening plugin's policy
	 * (dtstheme_add_outside_sources()).
	 *
	 * @param array<string, list<string>> $outside_sources The sources added so far, by directive.
	 * @return array<string, list<string>> The sources with the site's.
	 */
	public function add_outside_sources( array $outside_sources ): array {
		return dtstheme_add_outside_sources( $outside_sources, $this->site_facts->outside_sources );
	}

	/**
	 * Forwards an old page address to its new page (dtstheme_redirect_old_address()). Runs at
	 * priority 1, ahead of WordPress's own redirects; its function says why.
	 */
	public function redirect_old_address(): void {
		dtstheme_redirect_old_address( $this->site_facts->old_addresses );
	}

	/**
	 * Describes the site's organization in Yoast SEO's page data (dtstheme_describe_organization()).
	 *
	 * @param array<string, mixed> $organization Yoast's Organization piece.
	 * @return array<string, mixed> The piece with the site's types and areas served.
	 */
	public function describe_organization( array $organization ): array {
		return dtstheme_describe_organization( $organization, $this->site_facts );
	}
}
