import { expect, test, type Page } from '@playwright/test';
import { TEST_PATHS } from './test-pages';

// Protects how the site's stylesheets load (plan D29): the theme's component styles come with the
// blocks they style, the form's only to pages with a form, and the Song List plugin brings its
// table's styles itself, only where the song list appears. WordPress inlines small stylesheets,
// so a stylesheet shows as a <style> or <link> whose id starts with its handle.
const SONG_LIST_PATH = '/songlist/';
const FORM_PATH = '/book/';
const EVERY_PAGE_STYLES = ['hbmusic-site-header', 'hbmusic-site-footer'];
const FORM_STYLES = 'hbmusic-form';
const SONG_TABLE_STYLES = 'songlist-song-list';

async function loadsStylesheet(page: Page, handle: string): Promise<boolean> {
	return (await page.locator(`style[id^="${handle}-"], link[id^="${handle}-"]`).count()) > 0;
}

test('the header and footer styles load on every page', async ({ page }) => {
	for (const path of TEST_PATHS) {
		await page.goto(path);
		for (const handle of EVERY_PAGE_STYLES) {
			expect(await loadsStylesheet(page, handle), `${handle} on ${path}`).toBe(true);
		}
	}
});

test("the form's styles load only on the page with a form", async ({ page }) => {
	for (const path of TEST_PATHS) {
		await page.goto(path);
		expect(await loadsStylesheet(page, FORM_STYLES), `${FORM_STYLES} on ${path}`).toBe(path === FORM_PATH);
	}
});

test("the song table's styles load only where the song list appears", async ({ page }) => {
	for (const path of TEST_PATHS) {
		await page.goto(path);
		expect(await loadsStylesheet(page, SONG_TABLE_STYLES), `${SONG_TABLE_STYLES} on ${path}`).toBe(path === SONG_LIST_PATH);
	}
});

// Loading is not enough: WordPress's own "text-wrap: pretty" on headings once won over the theme's
// rule, so the headings' wrapping is read from the browser.
test('headings wrap in lines of even length', async ({ page }) => {
	await page.goto('/');
	for (const selector of ['h1.wp-block-heading', 'h2.wp-block-heading']) {
		const wrapping = await page.locator(selector).first().evaluate((heading) => getComputedStyle(heading).textWrapStyle);
		expect(wrapping, `the wrapping of ${selector}`).toBe('balance');
	}
});

// Loading is not enough: the plugin's selectors must still match its own markup.
test("the song table's styles apply to the table", async ({ page }) => {
	await page.goto(SONG_LIST_PATH);
	const heading = page.locator('.wp-block-songlist-song-list th').first();
	await expect(heading, 'a column heading').toBeVisible();
	expect(await heading.evaluate((cell) => getComputedStyle(cell).borderBottomWidth), 'the line under the headings').toBe('2px');
});
