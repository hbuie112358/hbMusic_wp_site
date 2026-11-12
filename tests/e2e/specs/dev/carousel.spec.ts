import { expect, test, type Locator, type Page } from '@playwright/test';

// Protects the CSS-only carousel (plan D29, option A+): its slides sit side by side in one row that
// scrolls sideways and snaps, it is a labelled region for screen readers, the native "next" button
// (Chromium, the test browser) brings the row exactly to its end and then hides (the user found it
// showing at the last video in one browser), and visitors who ask for less motion get no glide.
const MUSIC_PATH = '/music/';
const ROW = 'section.site-carousel';
const SLIDE_SETTLE_MS = 800;

async function openCarousel(page: Page): Promise<Locator> {
	await page.setViewportSize({ width: 1280, height: 900 });
	await page.goto(MUSIC_PATH);
	const row = page.locator(ROW);
	await row.scrollIntoViewIfNeeded();
	return row;
}

test('the carousel\'s slides sit side by side in a row that scrolls sideways and snaps', async ({ page }) => {
	const row = await openCarousel(page);
	const layout = await row.evaluate((element) => ({
		tops: [...element.children].map((slide) => Math.round(slide.getBoundingClientRect().top)),
		overflow: element.scrollWidth - element.clientWidth,
		snap: getComputedStyle(element).scrollSnapType,
	}));
	expect(layout.tops.length, 'the slides').toBeGreaterThanOrEqual(2);
	expect(new Set(layout.tops).size, `the slides' tops ${layout.tops.join(', ')}`).toBe(1);
	expect(layout.overflow, 'the width beyond the visible row').toBeGreaterThan(0);
	expect(layout.snap, 'the snapping').toContain('mandatory');
});

test('the carousel is a labelled region for screen readers', async ({ page }) => {
	await page.goto(MUSIC_PATH);
	await expect(page.getByRole('region', { name: 'Videos' }), 'the labelled region').toHaveCount(1);
});

test('clicking "next" to the end lands exactly at the end, where "next" is hidden', async ({ page }) => {
	const row = await openCarousel(page);
	const box = await row.boundingBox();
	const buttonSize = 44;
	const gap = 16;
	for (let click = 0; click < 4; click++) {
		await page.mouse.click((box?.x ?? 0) + (box?.width ?? 0) - gap - buttonSize / 2, (box?.y ?? 0) + (box?.height ?? 0) / 2);
		await page.waitForTimeout(SLIDE_SETTLE_MS);
	}
	const end = await row.evaluate((element) => ({
		left: element.scrollLeft,
		max: element.scrollWidth - element.clientWidth,
		next: getComputedStyle(element, '::scroll-button(right)').opacity,
	}));
	expect(end.left, 'the scroll position after the clicks').toBe(end.max);
	expect(end.next, 'the "next" button\'s opacity at the end').toBe('0');
});

// axe found the row unreachable by keyboard (scrollable-region-focusable); the theme makes it
// focusable, and the arrow keys then scroll it.
test('a keyboard user reaches the carousel with Tab and scrolls it with the arrow keys', async ({ page }) => {
	const row = await openCarousel(page);
	await expect(row, 'the row\'s place in the Tab order').toHaveAttribute('tabindex', '0');
	await row.focus();
	await page.keyboard.press('ArrowRight');
	await page.waitForFunction((element) => element !== null && element.scrollLeft > 0, await row.elementHandle());
	expect(await row.evaluate((element) => element.scrollLeft), 'the scroll position after →').toBeGreaterThan(0);
});

test('the carousel jumps instead of gliding for visitors who ask for less motion', async ({ page }) => {
	await page.emulateMedia({ reducedMotion: 'reduce' });
	const row = await openCarousel(page);
	expect(await row.evaluate((element) => getComputedStyle(element).scrollBehavior), 'the scrolling').toBe('auto');
});
