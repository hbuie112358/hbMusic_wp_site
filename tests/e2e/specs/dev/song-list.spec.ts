import { expect, test, type Page } from '@playwright/test';
import { ADMIN_STORAGE_STATE } from './admin-session';

// Protects the Song List plugin (plan step 5a): the block shows songs sorted and escaped, the
// editor offers the block, and the admin form saves an artist only with a valid nonce. The
// sample songs are bin/dev-site's TEST_SONGS. The page's accessibility and security policy are
// checked with every other page in theme.spec.ts.
const SONGLIST_PATH = '/songlist/';
const ARTIST_FIELD = '#songlist-artist';
const NONCE_FIELD = '#songlist-artist-nonce';

// A unique title for each run, so a rerun cannot mistake an earlier song for this one.
async function addSong(page: Page, artist: string): Promise<string> {
	const title = `Test song ${test.info().testId} ${Date.now()}`;
	await page.goto('/wp-admin/post-new.php?post_type=songlist_song');
	await page.locator('#title').fill(title);
	await page.locator(ARTIST_FIELD).fill(artist);
	await page.locator('#publish').click();
	await expect(page.locator('#message'), 'the save notice').toBeVisible();
	return title;
}

// Trashed afterwards, so the visitor tests see only the sample songs when run side by side.
async function trashSong(page: Page): Promise<void> {
	await page.locator('.submitdelete').click();
	await page.waitForURL(/edit\.php\?post_type=songlist_song/);
}

async function artistShownFor(page: Page, title: string): Promise<string> {
	await page.goto(SONGLIST_PATH);
	return page.getByRole('row').filter({ hasText: title }).getByRole('cell').nth(1).innerText();
}

test.describe('a visitor', () => {
	test('sees the sample songs sorted by title, with their artists and escaped text', async ({ page }) => {
		await page.goto(SONGLIST_PATH);
		await expect(page.getByRole('columnheader')).toHaveText(['Title', 'Artist']);

		const rows = await page.locator('.wp-block-songlist-song-list tbody tr').evaluateAll((tableRows) =>
			tableRows.map((row) => Array.from(row.querySelectorAll('td'), (cell) => cell.textContent)),
		);
		expect(rows.filter(([title]) => title?.includes('Sample'))).toEqual([
			['Alpha Sample Song', 'Sample Artist One'],
			['Rock & Roll <em>Sample</em>', 'Sample Artist Two'],
			['Zulu Sample Song', ''],
		]);
		// The tags must arrive as text, never as an element a title could use to inject markup.
		await expect(page.locator('.wp-block-songlist-song-list em')).toHaveCount(0);
	});
});

test.describe('the admin', () => {
	test.describe.configure({ mode: 'serial' });
	// Starts with the dev admin's login, saved once per run by admin.setup.ts.
	test.use({ storageState: ADMIN_STORAGE_STATE });

	test('is offered the Song List block in the editor', async ({ page }) => {
		await page.goto('/wp-admin/post-new.php?post_type=page');
		await page.waitForFunction(() => 'wp' in window);
		await expect
			.poll(() =>
				page.evaluate(() => {
					const { wp } = window as unknown as {
						wp: { blocks: { getBlockType: (name: string) => unknown } };
					};
					return Boolean(wp.blocks.getBlockType('songlist/song-list'));
				}),
			)
			.toBe(true);
	});

	test('adds a song that then appears on the page, and an emptied artist is removed', async ({ page }) => {
		const title = await addSong(page, 'Added Artist');
		const editAddress = page.url();
		expect(await artistShownFor(page, title)).toBe('Added Artist');

		await page.goto(editAddress);
		await page.locator(ARTIST_FIELD).fill('');
		await page.locator('#publish').click();
		await expect(page.locator('#message'), 'the save notice').toBeVisible();
		expect(await artistShownFor(page, title)).toBe('');

		await page.goto(editAddress);
		await trashSong(page);
	});

	// The request fixture carries no login, so this is what a visitor or search engine gets.
	test('has songs without a page of their own', async ({ page, request }) => {
		await addSong(page, 'Any Artist');
		const editAddress = page.url();
		const songId = new URL(editAddress).searchParams.get('post');
		expect(songId, 'the song ID in the edit address').toBeTruthy();
		expect((await request.get(`/?p=${songId}`)).status(), 'the song by its ID').toBe(404);

		await trashSong(page);
	});

	test('cannot change an artist without a valid nonce', async ({ page }) => {
		const title = await addSong(page, 'Original Artist');
		const editAddress = page.url();

		await page.locator(ARTIST_FIELD).fill('Forged Artist');
		await page.locator(NONCE_FIELD).evaluate((field) => {
			if (field instanceof HTMLInputElement) {
				field.value = 'forged';
			}
		});
		await page.locator('#publish').click();
		await expect(page.locator('#message'), 'the save notice').toBeVisible();
		expect(await artistShownFor(page, title)).toBe('Original Artist');

		await page.goto(editAddress);
		await trashSong(page);
	});
});
