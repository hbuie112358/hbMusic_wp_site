// The rules the theme's browser scripts are checked against (template plan 1.7;
// ~/.claude/TYPESCRIPT_STANDARDS.md, constraint 13: typescript-eslint's strict-type-checked and
// stylistic-type-checked configurations, zero findings). The scripts are plain JavaScript whose
// JSDoc comments carry the types, so the type-aware rules read them through tsconfig.json.
//
// Layout follows the WordPress JavaScript Coding Standards, as PHPCS holds the PHP's and Stylelint
// the CSS's: tabs, spaces inside parentheses and brackets, a space after "!". WordPress's own
// configuration (@wordpress/eslint-plugin) is not used for three small scripts: it brings rules
// and packages for React, tests and builds. When the first block or React work starts,
// @wordpress/scripts brings it, configured, and replaces the layout rules here
// (docs/planning/template-notes.md).

import { defineConfig } from 'eslint/config';
import stylistic from '@stylistic/eslint-plugin';
import tseslint from 'typescript-eslint';

export default defineConfig( {
	files: [ '**/*.js' ],
	extends: [ tseslint.configs.strictTypeChecked, tseslint.configs.stylisticTypeChecked ],
	languageOptions: {
		parserOptions: {
			project: './tsconfig.json',
			tsconfigRootDir: import.meta.dirname,
		},
	},
	plugins: { '@stylistic': stylistic },
	rules: {
		// Bans in TYPESCRIPT_STANDARDS.md that typescript-eslint's configurations leave to ESLint's
		// own rules: == and != (13), var and a let never reassigned (6), console.* in product
		// code (7). A planted == passed before these were added (2026-11-24).
		eqeqeq: [ 'error', 'always' ],
		'no-var': 'error',
		'prefer-const': 'error',
		'no-console': 'error',

		'@stylistic/indent': [ 'error', 'tab' ],
		'@stylistic/space-in-parens': [ 'error', 'always' ],
		// Spaces inside brackets and braces: [ a ], { a }, f( a ) (the plugin's one rule for them).
		'@stylistic/list-style': [ 'error', { singleLine: { spacing: 'always' } } ],
		'@stylistic/computed-property-spacing': [ 'error', 'always' ],
		'@stylistic/space-unary-ops': [ 'error', { overrides: { '!': true } } ],
		'@stylistic/semi': [ 'error', 'always' ],
		'@stylistic/quotes': [ 'error', 'single', { avoidEscape: true } ],
		'@stylistic/comma-dangle': [ 'error', 'always-multiline' ],
		'@stylistic/brace-style': [ 'error', '1tbs' ],
		'@stylistic/arrow-parens': [ 'error', 'always' ],
		'@stylistic/keyword-spacing': 'error',
		'@stylistic/space-before-blocks': 'error',
		'@stylistic/space-infix-ops': 'error',
		'@stylistic/comma-spacing': 'error',
		'@stylistic/key-spacing': 'error',
		'@stylistic/no-trailing-spaces': 'error',
		'@stylistic/eol-last': 'error',
	},
} );
