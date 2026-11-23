import AxeBuilder from '@axe-core/playwright';
import { expect, test } from '@playwright/test';
import { WCAG_TAGS } from '../specs/dev/helpers/accessibility';

// Scans every page bin/accessibility-scan names (SCAN_PAGES, one address per line, from
// bin/site-check --print-pages) at desktop and phone width: no axe error at WCAG 2.2 AA, the same
// rules as the dev site's tests (WCAG_TAGS), and no image without an alt attribute, which axe
// reports only for images it judges meaningful (handbook chapter 12, 7.4).
const VIEWPORTS = [
	{ name: 'desktop', width: 1280, height: 900 },
	{ name: 'phone', width: 390, height: 844 },
] as const;

// After its own load, a page is scanned once its network goes quiet, so content scripts add after
// the load (a spam check's frame) is scanned too. A page with an outside service that keeps
// talking (the form's spam check) never goes quiet, so the wait ends at this limit and the page is
// scanned as it is then; reaching the limit is expected there, not a failure.
const QUIET_NETWORK_LIMIT_MILLISECONDS = 5000;

function pageAddresses(): string[] {
	const addresses = (process.env.SCAN_PAGES ?? '').split('\n').filter((line) => line.trim() !== '');
	if (addresses.length === 0 || !addresses.every((address) => /^https?:\/\/[^/\s]+\/\S*$/.test(address))) {
		throw new Error('SCAN_PAGES must name at least one page, one full address per line');
	}
	return addresses;
}

for (const address of pageAddresses()) {
	for (const viewport of VIEWPORTS) {
		test(`${address} at ${viewport.name} width`, async ({ page }) => {
			await page.setViewportSize({ width: viewport.width, height: viewport.height });
			const response = await page.goto(address, { waitUntil: 'load' });
			expect(response?.status(), `${address} answered`).toBe(200);
			await page
				.waitForLoadState('networkidle', { timeout: QUIET_NETWORK_LIMIT_MILLISECONDS })
				.catch((error: unknown) => {
					if (!(error instanceof Error && error.name === 'TimeoutError')) {
						throw error;
					}
				});

			const results = await new AxeBuilder({ page }).withTags([...WCAG_TAGS]).analyze();
			const errors = results.violations.map(
				(violation) => `${violation.id}: ${violation.help} (${violation.nodes.map((node) => node.target.join(' ')).join(', ')})`,
			);
			expect(errors, `accessibility errors on ${address}`).toEqual([]);

			const imagesWithoutAlt = await page.locator('img:not([alt])').evaluateAll((images) =>
				images.map((image) => (image as HTMLImageElement).currentSrc || (image as HTMLImageElement).src),
			);
			expect(imagesWithoutAlt, `images without alt text on ${address}`).toEqual([]);
		});
	}
}
