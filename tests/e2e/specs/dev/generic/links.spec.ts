import { expect, test, type Page } from '@playwright/test';
import { TEST_PATHS } from '../helpers/test-pages';

// Protects every link between the site's own pages (plan 1c, 2026-11-16): renaming a page's
// address once left the call-to-action panel's button, which comes from the theme,
// pointing at an address that no longer existed, and nothing noticed. Each test page's links to
// this site, from the menu, the content, the call-to-action panel and the footer, must lead to a
// page that answers, following redirects as a browser would. Links into the admin and to anchors
// on the same page are left out; outside sites are not this test's business.
const LEFT_OUT_PATH_PREFIXES = ['/wp-admin', '/wp-login.php'];

async function ownLinkAddresses(page: Page, baseURL: string): Promise<string[]> {
	const addresses = await page.locator('a[href]').evaluateAll((links) => links.map((link) => (link as HTMLAnchorElement).href));
	const own = addresses
		.map((address) => new URL(address))
		.filter((url) => url.origin === new URL(baseURL).origin)
		.filter((url) => !LEFT_OUT_PATH_PREFIXES.some((prefix) => url.pathname.startsWith(prefix)))
		.map((url) => `${url.origin}${url.pathname}${url.search}`);
	return [...new Set(own)];
}

for (const path of TEST_PATHS) {
	test(`every link on ${path} to this site leads to a page that answers`, async ({ page, request, baseURL }) => {
		await page.goto(path);
		const addresses = await ownLinkAddresses(page, baseURL ?? '');
		expect(addresses.length, 'the page has links to this site (the menu at least)').toBeGreaterThan(0);
		for (const address of addresses) {
			const response = await request.get(address);
			expect(response.ok(), `${address}, linked from ${path}, answers ${response.status()}`).toBe(true);
		}
	});
}
