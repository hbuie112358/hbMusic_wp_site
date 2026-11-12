// The CSS rules every theme and plugin in this repository is checked against (plan D29).
//
// Stylelint's standard configuration catches mistakes a browser would silently ignore (unknown
// properties, invalid values, duplicate or shadowed rules). The rules below add the WordPress
// CSS Coding Standards' formatting and this project's own conventions. WordPress's own
// configuration (@wordpress/stylelint-config) was not used: since mid-2026 it pulls in
// WordPress's editor packages, React included, about 180 packages for a linter (plan D29).

/** @type {import('stylelint').Config} */
export default {
	extends: [ 'stylelint-config-standard' ],
	plugins: [ '@stylistic/stylelint-plugin' ],

	// Every rule switched off in a file must say why, and only where it is needed.
	reportDescriptionlessDisables: true,
	reportInvalidScopeDisables: true,
	reportNeedlessDisables: true,

	rules: {
		// Lower-case kebab-case, with BEM's __element and --modifier, which WordPress core's own
		// classes use (wp-block-button__link) and which our selectors must be able to name.
		'selector-class-pattern': [
			'^[a-z][a-z0-9]*(-[a-z0-9]+)*(__[a-z0-9]+(-[a-z0-9]+)*)?(--[a-z0-9]+(-[a-z0-9]+)*)?$',
			{ message: 'Class names are lower-case kebab-case; BEM __element and --modifier allowed' },
		],
		// WordPress namespaces its variables with double dashes (--wp--custom--content-width).
		'custom-property-pattern': [
			'^[a-z][a-z0-9]*(-{1,2}[a-z0-9]+)*$',
			{ message: 'Custom properties are lower-case; WordPress double-dash namespacing allowed' },
		],

		// !important starts an escalation with the framework's own styles; where WordPress's
		// layout forces one, the exception is disabled in place with its reason.
		'declaration-no-important': true,
		// Colours come from the palette's tokens; named colours bypass them.
		'color-named': 'never',

		// The WordPress CSS Coding Standards' formatting.
		'@stylistic/indentation': 'tab',
		'@stylistic/string-quotes': 'double',
		'@stylistic/color-hex-case': 'lower',
		'@stylistic/number-leading-zero': 'always',
		'@stylistic/unit-case': 'lower',
		'@stylistic/property-case': 'lower',
		'@stylistic/selector-list-comma-newline-after': 'always',
		// Single-line values only: a list such as several transitions is written one item per line,
		// starting on the line after the colon, as the WordPress standards allow.
		'@stylistic/declaration-colon-space-after': 'always-single-line',
		'@stylistic/declaration-colon-space-before': 'never',
		'@stylistic/block-opening-brace-space-before': 'always',
		'@stylistic/declaration-block-trailing-semicolon': 'always',
		'@stylistic/max-empty-lines': 2,
		'@stylistic/no-eol-whitespace': true,
		'@stylistic/no-missing-end-of-source-newline': true,
	},
};
