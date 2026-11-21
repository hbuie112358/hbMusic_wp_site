import { expect, test } from '@playwright/test';
import { loadsStylesheet } from '../../helpers/stylesheets';
import { TEST_PATHS } from '../../helpers/test-pages';

// Protects how the Song List plugin's table styles load (plan D29): the plugin brings them itself,
// only where the song list appears, and they still match its own markup.
const SONG_LIST_PATH = '/songlist/';
const SONG_TABLE_STYLES = 'songlist-song-list';

test("the song table's styles load only where the song list appears", async ({ page }) => {
	for (const path of TEST_PATHS) {
		await page.goto(path);
		expect(await loadsStylesheet(page, SONG_TABLE_STYLES), `${SONG_TABLE_STYLES} on ${path}`).toBe(path === SONG_LIST_PATH);
	}
});

// Loading is not enough: the plugin's selectors must still match its own markup.
test("the song table's styles apply to the table", async ({ page }) => {
	await page.goto(SONG_LIST_PATH);
	const heading = page.locator('.wp-block-songlist-song-list th').first();
	await expect(heading, 'a column heading').toBeVisible();
	expect(await heading.evaluate((cell) => getComputedStyle(cell).borderBottomWidth), 'the line under the headings').toBe('2px');
});
