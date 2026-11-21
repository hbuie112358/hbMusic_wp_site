import { expect, test, type Locator, type Page } from '@playwright/test';
import { EXAMPLE_PATHS, pagesUsing } from '../helpers/test-pages';

// Protects Media & Text, WordPress's picture-beside-text block (media-text.css, plan 9t-3): its
// text lines up with the page title on its outer side, on a computer and a phone, instead of
// WordPress's 8% padding pushing it in; and on a phone, with the picture on the right, the text
// comes first, in its reading order, with a gap before the picture. Checked on every block of
// every page that has one (template plan T10), told apart by WordPress's own class for a picture
// on the right; the example page has both kinds, and must.
const PAGES_WITH_MEDIA_TEXT = pagesUsing('wp-block-media-text');
const PICTURE_ON_THE_RIGHT = '.wp-block-media-text.has-media-on-the-right';
const PICTURE_ON_THE_LEFT = '.wp-block-media-text:not(.has-media-on-the-right)';
const TEXT = '.wp-block-media-text__content > :first-child';
const PICTURE = '.wp-block-media-text__media';
const COMPUTER = { width: 1280, height: 900 };
const PHONE = { width: 390, height: 900 };
// The browser lays out in fractions of a pixel.
const ROUNDING = 1;

type Edges = { left: number; right: number; top: number; bottom: number };

async function edges(element: Locator): Promise<Edges> {
	return element.evaluate((target) => {
		const rect = target.getBoundingClientRect();
		return { left: rect.left, right: rect.right, top: rect.top, bottom: rect.bottom };
	});
}

// Every block of the kind on the page; on the example page at least one, which it is built to show.
async function blocksOf(page: Page, path: string, kind: string): Promise<Locator[]> {
	const blocks = await page.locator(kind).all();
	if (EXAMPLE_PATHS.includes(path)) {
		expect(blocks.length, `the blocks ${kind} on the example page`).toBeGreaterThanOrEqual(1);
	}
	return blocks;
}

async function openAt(page: Page, path: string, size: { width: number; height: number }): Promise<void> {
	await page.setViewportSize(size);
	await page.goto(path);
}

for (const path of PAGES_WITH_MEDIA_TEXT) {
	test.describe(`on ${path}`, () => {
		test('on a computer, text beside a picture on the right starts where the page title starts', async ({ page }) => {
			await openAt(page, path, COMPUTER);
			const title = await edges(page.locator('h1').first());
			for (const block of await blocksOf(page, path, PICTURE_ON_THE_RIGHT)) {
				const text = await edges(block.locator(TEXT));
				expect(Math.abs(text.left - title.left), 'the text\'s left edge against the title\'s').toBeLessThanOrEqual(ROUNDING);
			}
		});

		test('on a computer, text beside a picture on the left ends where its block ends', async ({ page }) => {
			await openAt(page, path, COMPUTER);
			for (const block of await blocksOf(page, path, PICTURE_ON_THE_LEFT)) {
				const text = await edges(block.locator(TEXT));
				const blockEdges = await edges(block);
				expect(Math.abs(text.right - blockEdges.right), 'the text\'s right edge against its block\'s').toBeLessThanOrEqual(ROUNDING);
			}
		});

		test('on a phone, the text of every block starts where the page title starts', async ({ page }) => {
			await openAt(page, path, PHONE);
			const title = await edges(page.locator('h1').first());
			for (const block of await blocksOf(page, path, '.wp-block-media-text')) {
				const text = await edges(block.locator(TEXT));
				expect(Math.abs(text.left - title.left), 'the text\'s left edge against the title\'s').toBeLessThanOrEqual(ROUNDING);
			}
		});

		test('on a phone, with the picture on the right, the text comes first, then a gap, then the picture', async ({ page }) => {
			await openAt(page, path, PHONE);
			for (const block of await blocksOf(page, path, PICTURE_ON_THE_RIGHT)) {
				const text = await edges(block.locator(TEXT));
				const picture = await edges(block.locator(PICTURE));
				expect(picture.top - text.bottom, 'the gap between the text and the picture below it').toBeGreaterThan(ROUNDING);
			}
		});

		test('on a phone, with the picture on the left, the picture keeps coming first', async ({ page }) => {
			await openAt(page, path, PHONE);
			for (const block of await blocksOf(page, path, PICTURE_ON_THE_LEFT)) {
				const text = await edges(block.locator(TEXT));
				const picture = await edges(block.locator(PICTURE));
				expect(text.top - picture.bottom, 'the gap between the picture and the text below it').toBeGreaterThan(ROUNDING);
			}
		});
	});
}
