import AxeBuilder from '@axe-core/playwright';
import { expect, test } from '@playwright/test';
import { answerOutsideServices, recordCspViolations, recordedCspViolations } from './csp-violations';
import { TEST_PATHS } from './test-pages';

// Protects the child theme on the dev site (plan step 4c): every test page loads through the
// child theme, carries the security headers, causes no Content-Security-Policy violation and
// has no accessibility errors (docs/SITE_CHECKLIST.md 3.2, 6.7, 7.1).
// WordPress marks the active child theme on <body> (wp-child-theme-<folder>).
const CHILD_THEME_BODY_CLASS = /\bwp-child-theme-hbmusic-child\b/;
// The policy's rules that no outside source may loosen (checklist 3.2; the Site Hardening plugin).
const STRICT_POLICY_RULES = ["default-src 'self'", "object-src 'none'", "base-uri 'self'", "form-action 'self'", "frame-ancestors 'self'"];
// WCAG 2.2 level AA and the levels it includes (checklist 7.1).
const WCAG_TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

for (const path of TEST_PATHS) {
	test.describe(`the page ${path}`, () => {
		test.beforeEach(async ({ page }) => {
			await answerOutsideServices(page);
		});

		test('loads through the child theme', async ({ page }) => {
			const response = await page.goto(path);
			expect(response?.status(), 'status').toBe(200);
			await expect(page.locator('body'), 'the active child theme').toHaveClass(CHILD_THEME_BODY_CLASS);
		});

		// The parent theme's own footer links to a blog, shop and events this site does not have.
		test("uses the site's own header and footer", async ({ page }) => {
			await page.goto(path);
			await expect(page.locator('header.site-header'), 'the header').toHaveCount(1);
			await expect(page.locator('footer.site-footer'), 'the footer').toHaveCount(1);
			await expect(page.locator('footer a[href*="/shop"], footer a[href*="/blog"]'), "the parent's footer links").toHaveCount(0);
		});

		test('shows the logo from the theme', async ({ page }) => {
			await page.goto(path);
			const logo = page.locator('header.site-header .site-logo img');
			await expect(logo, 'the logo').toBeVisible();
			const hasLoaded = await logo.evaluate((image) => image instanceof HTMLImageElement && image.complete && image.naturalWidth > 0);
			expect(hasLoaded, 'the logo image has loaded').toBe(true);
		});

		test('links to the privacy policy from the footer', async ({ page }) => {
			await page.goto(path);
			await expect(page.locator('footer a[href="/privacy-policy/"]'), 'the footer link').toHaveCount(1);
		});

		test('has exactly one main heading', async ({ page }) => {
			await page.goto(path);
			await expect(page.locator('h1'), 'the h1 headings').toHaveCount(1);
		});

		test('carries the security headers', async ({ request }) => {
			const headers = (await request.get(path)).headers();
			// The policy must be sent at all, or the violation check below would pass on nothing; and
			// its strict rules must hold (checklist 3.2), whatever outside sources the site adds.
			const policy = headers['content-security-policy'] ?? '';
			for (const strictRule of STRICT_POLICY_RULES) {
				expect(policy, `Content-Security-Policy: ${strictRule}`).toContain(strictRule);
			}
			expect(policy, 'Content-Security-Policy: no eval, no wildcard source').not.toMatch(/'unsafe-eval'|\s\*(\s|;|$)/);
			expect(headers['x-content-type-options'], 'X-Content-Type-Options').toBe('nosniff');
			expect(headers['referrer-policy'], 'Referrer-Policy').toBeTruthy();
			expect(headers['permissions-policy'], 'Permissions-Policy').toBeTruthy();
		});

		test('causes no Content-Security-Policy violation', async ({ page }) => {
			await recordCspViolations(page);
			await page.goto(path, { waitUntil: 'networkidle' });
			expect(await recordedCspViolations(page), 'violations reported by the browser').toEqual([]);
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
