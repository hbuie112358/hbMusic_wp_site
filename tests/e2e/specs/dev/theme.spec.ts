import AxeBuilder from '@axe-core/playwright';
import { expect, test, type Page } from '@playwright/test';

// Protects the child theme on the dev site (plan step 4c): every test page loads through the
// child theme, carries the security headers, causes no Content-Security-Policy violation and
// has no accessibility errors (docs/SITE_CHECKLIST.md 3.2, 6.7, 7.1).
//
// The paths of the test pages bin/dev-site creates (TEST_PAGES; "Home" is the front page).
// Fixed here, not read from the site's menu: a page missing from the menu must still fail.
const TEST_PATHS = ['/', '/about/', '/songlist/', '/video/', '/contact/'];
// WordPress marks the active child theme on <body> (wp-child-theme-<folder>).
const CHILD_THEME_BODY_CLASS = /\bwp-child-theme-hbmusic-child\b/;
// WCAG 2.2 level AA and the levels it includes (checklist 7.1).
const WCAG_TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

type CspViolation = { directive: string; blockedURI: string; sourceFile: string };

declare global {
	interface Window {
		cspViolations?: CspViolation[];
	}
}

// Registered before any of the page's own code runs, so no violation can happen unrecorded.
async function recordCspViolations(page: Page): Promise<void> {
	await page.addInitScript(() => {
		window.cspViolations = [];
		document.addEventListener('securitypolicyviolation', (event) => {
			window.cspViolations?.push({
				directive: event.effectiveDirective,
				blockedURI: event.blockedURI,
				sourceFile: event.sourceFile,
			});
		});
	});
}

for (const path of TEST_PATHS) {
	test.describe(`the page ${path}`, () => {
		test('loads through the child theme', async ({ page }) => {
			const response = await page.goto(path);
			expect(response?.status(), 'status').toBe(200);
			await expect(page.locator('body'), 'the active child theme').toHaveClass(CHILD_THEME_BODY_CLASS);
		});

		test('carries the security headers', async ({ request }) => {
			const headers = (await request.get(path)).headers();
			// The policy must be sent at all, or the violation check below would pass on nothing.
			expect(headers['content-security-policy'], 'Content-Security-Policy').toContain("object-src 'none'");
			expect(headers['x-content-type-options'], 'X-Content-Type-Options').toBe('nosniff');
			expect(headers['referrer-policy'], 'Referrer-Policy').toBeTruthy();
			expect(headers['permissions-policy'], 'Permissions-Policy').toBeTruthy();
		});

		test('causes no Content-Security-Policy violation', async ({ page }) => {
			await recordCspViolations(page);
			await page.goto(path, { waitUntil: 'networkidle' });
			const violations = await page.evaluate(() => window.cspViolations ?? []);
			expect(violations, 'violations reported by the browser').toEqual([]);
		});

		test('has no accessibility errors', async ({ page }) => {
			await page.goto(path);
			const results = await new AxeBuilder({ page }).withTags(WCAG_TAGS).analyze();
			// Each rule with the elements that break it, so a failure says where to look.
			const summary = results.violations.map(
				(violation) => `${violation.id}: ${violation.help} at ${violation.nodes.map((node) => node.target.join(' ')).join(', ')}`,
			);
			expect(summary, 'axe violations').toEqual([]);
		});
	});
}
