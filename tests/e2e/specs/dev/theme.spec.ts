import AxeBuilder from '@axe-core/playwright';
import { expect, test, type Page } from '@playwright/test';

// Protects the child theme on the dev site (plan step 4c): every test page loads through the
// child theme, carries the security headers, causes no Content-Security-Policy violation and
// has no accessibility errors (docs/SITE_CHECKLIST.md 3.2, 6.7, 7.1).
//
// The paths of the test pages bin/dev-site creates (TEST_PAGES; "Home" is the front page).
// Fixed here, not read from the site's menu: a page missing from the menu must still fail.
const TEST_PATHS = ['/', '/music/', '/songlist/', '/about/', '/book/', '/privacy-policy/'];
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
		// The Music page plays a video from YouTube, and the Book page loads Cloudflare's script.
		// Answered here, so the tests need no network and no outside site, while the browser still
		// applies the policy to both.
		test.beforeEach(async ({ page }) => {
			await page.route(/youtube\.com\/embed/, (route) => route.fulfill({ contentType: 'text/html', body: '<title>video</title>' }));
			await page.route(/challenges\.cloudflare\.com/, (route) => route.fulfill({ contentType: 'text/javascript', body: '' }));
		});

		test('loads through the child theme', async ({ page }) => {
			const response = await page.goto(path);
			expect(response?.status(), 'status').toBe(200);
			await expect(page.locator('body'), 'the active child theme').toHaveClass(CHILD_THEME_BODY_CLASS);
		});

		// The parent theme's own footer links to a blog, shop and events this site does not have.
		test("uses the site's own header and footer", async ({ page }) => {
			await page.goto(path);
			await expect(page.locator('header.hb-site-header'), 'the header').toHaveCount(1);
			await expect(page.locator('footer.hb-site-footer'), 'the footer').toHaveCount(1);
			await expect(page.locator('footer a[href*="/shop"], footer a[href*="/blog"]'), "the parent's footer links").toHaveCount(0);
		});

		test('shows the logo from the theme', async ({ page }) => {
			await page.goto(path);
			const logo = page.locator('header.hb-site-header .hb-site-logo img');
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
