import { expect, test } from '@playwright/test';

// Protects bin/local-import (plan step 3a): after an import, the local copy shows the old
// site's content, served from the local address only. The expected numbers are facts of the
// fixed database dump in db/ (plan step 2 inventory), not of the live site.
const MENU_ENTRIES = 6;
const SONGS = 108;
// Every published page and post (plan step 2 inventory). Fixed here, not read from the menu:
// a page missing from the menu must still be checked.
const PUBLIC_PATHS = [
	'/',
	'/about/',
	'/contact/',
	'/songlist/',
	'/video/',
	'/audio/',
	'/video-01/',
	'/video-02/',
	'/video-03/',
];

// Every form of the live address, from .env (LIVE_ADDRESSES), passed in by bin/test.
const liveAddresses = (process.env.LIVE_ADDRESSES ?? '').split(/\s+/).filter(Boolean);

test.beforeAll(() => {
	expect(liveAddresses.length, 'LIVE_ADDRESSES must be set; run through bin/test').toBeGreaterThan(0);
});

test('the main menu has its entries, and each page loads', async ({ page, request }) => {
	await page.goto('/');
	const menuLinks = page.locator('#menu-main-menu > li > a');
	await expect(menuLinks).toHaveCount(MENU_ENTRIES);

	for (const href of await menuLinks.evaluateAll((links) => links.map((link) => (link instanceof HTMLAnchorElement ? link.href : '')))) {
		const response = await request.get(href);
		expect(response.status(), `menu page ${href}`).toBe(200);
	}
});

test('no page refers to the live site', async ({ page }) => {
	for (const path of PUBLIC_PATHS) {
		const response = await page.goto(path);
		expect(response?.status(), `page ${path}`).toBe(200);
		const html = await page.content();
		for (const liveAddress of liveAddresses) {
			expect(html.includes(liveAddress), `${path} contains ${liveAddress}`).toBe(false);
		}
	}
});

test('the songlist shows every song with its artist', async ({ page }) => {
	await page.goto('/songlist/');
	const songs = page.locator('ul.songlist_songs > li');
	const artists = page.locator('ul.songlist_artists_list > li');
	await expect(songs).toHaveCount(SONGS);
	await expect(artists).toHaveCount(SONGS);
	// An empty entry would mean a song lost its title or artist in the import.
	for (const list of [songs, artists]) {
		const texts = await list.allTextContents();
		expect(texts.filter((text) => text.trim() === '')).toHaveLength(0);
	}
});
