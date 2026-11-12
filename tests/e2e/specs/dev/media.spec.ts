import { expect, test } from '@playwright/test';

// Protects the loading of embedded players (docs/SITE_CHECKLIST.md 8.5): every one in a page's
// content is lazy-loaded, the first ones included, so a video hidden in a carousel or further down
// loads only as the visitor nears it. WordPress left the first three images and embeds of a page
// eager, which on the Music page was every video.
const PAGES_WITH_PLAYERS = ['/', '/music/'];

for (const path of PAGES_WITH_PLAYERS) {
	test(`every embedded player on ${path} is lazy-loaded`, async ({ page }) => {
		await page.goto(path);
		const players = await page.locator('main iframe').evaluateAll((frames) => frames.map((frame) => ({
			title: frame.getAttribute('title') ?? '(untitled)',
			loading: frame.getAttribute('loading'),
		})));
		expect(players.length, `the players on ${path}`).toBeGreaterThanOrEqual(1);
		for (const player of players) {
			expect(player.loading, `the loading of "${player.title}"`).toBe('lazy');
		}
	});
}
