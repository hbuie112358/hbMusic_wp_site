import { expect, test, type Page } from '@playwright/test';

// Protects Media & Text, WordPress's picture-beside-text block (media-text.css, plan 9t-3): its
// text lines up with the page title on its outer side, on a computer and a phone, instead of
// WordPress's 8% padding pushing it in; and on a phone, with the picture on the right, the text
// comes first, in its reading order, with a gap before the picture. The stand-ins are on the dev
// site's Songs page (tests/dev-content/songlist.html): one picture on the right, one on the left.
const PAGE_WITH_BOTH = '/songlist/';
const TEXT_BESIDE_RIGHT_PICTURE = 'p.dev-media-text-right';
const TEXT_BESIDE_LEFT_PICTURE = 'p.dev-media-text-left';
const COMPUTER = { width: 1280, height: 900 };
const PHONE = { width: 390, height: 900 };
// The browser lays out in fractions of a pixel.
const ROUNDING = 1;

type Edges = { left: number; right: number; top: number; bottom: number };

async function edges(page: Page, selector: string): Promise<Edges> {
	return page.locator(selector).first().evaluate((element) => {
		const rect = element.getBoundingClientRect();
		return { left: rect.left, right: rect.right, top: rect.top, bottom: rect.bottom };
	});
}

// The picture in the same Media & Text block as the given text.
async function pictureBeside(page: Page, textSelector: string): Promise<Edges> {
	return page.locator(textSelector).first().evaluate((text) => {
		const picture = text.closest('.wp-block-media-text')?.querySelector('.wp-block-media-text__media');
		const rect = (picture ?? text).getBoundingClientRect();
		return { left: rect.left, right: rect.right, top: rect.top, bottom: rect.bottom };
	});
}

test('on a computer, text beside a picture on the right starts where the page title starts', async ({ page }) => {
	await page.setViewportSize(COMPUTER);
	await page.goto(PAGE_WITH_BOTH);
	const title = await edges(page, 'h1');
	const text = await edges(page, TEXT_BESIDE_RIGHT_PICTURE);
	expect(Math.abs(text.left - title.left), 'the text\'s left edge against the title\'s').toBeLessThanOrEqual(ROUNDING);
});

test('on a computer, text beside a picture on the left ends where its block ends', async ({ page }) => {
	await page.setViewportSize(COMPUTER);
	await page.goto(PAGE_WITH_BOTH);
	const text = await edges(page, TEXT_BESIDE_LEFT_PICTURE);
	const block = await page.locator(TEXT_BESIDE_LEFT_PICTURE).first().evaluate((element) => element.closest('.wp-block-media-text')?.getBoundingClientRect().right ?? Number.NaN);
	expect(Math.abs(text.right - block), 'the text\'s right edge against its block\'s').toBeLessThanOrEqual(ROUNDING);
});

test('on a phone, the text of both blocks starts where the page title starts', async ({ page }) => {
	await page.setViewportSize(PHONE);
	await page.goto(PAGE_WITH_BOTH);
	const title = await edges(page, 'h1');
	for (const selector of [TEXT_BESIDE_RIGHT_PICTURE, TEXT_BESIDE_LEFT_PICTURE]) {
		const text = await edges(page, selector);
		expect(Math.abs(text.left - title.left), `${selector}: its left edge against the title's`).toBeLessThanOrEqual(ROUNDING);
	}
});

test('on a phone, with the picture on the right, the text comes first, then a gap, then the picture', async ({ page }) => {
	await page.setViewportSize(PHONE);
	await page.goto(PAGE_WITH_BOTH);
	const text = await edges(page, TEXT_BESIDE_RIGHT_PICTURE);
	const picture = await pictureBeside(page, TEXT_BESIDE_RIGHT_PICTURE);
	expect(picture.top - text.bottom, 'the gap between the text and the picture below it').toBeGreaterThan(ROUNDING);
});

test('on a phone, with the picture on the left, the picture keeps coming first', async ({ page }) => {
	await page.setViewportSize(PHONE);
	await page.goto(PAGE_WITH_BOTH);
	const text = await edges(page, TEXT_BESIDE_LEFT_PICTURE);
	const picture = await pictureBeside(page, TEXT_BESIDE_LEFT_PICTURE);
	expect(text.top - picture.bottom, 'the gap between the picture and the text below it').toBeGreaterThan(ROUNDING);
});
