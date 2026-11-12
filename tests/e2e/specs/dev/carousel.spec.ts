import { expect, test, type Locator, type Page } from '@playwright/test';

// Protects the CSS-only carousel (plan D29, option A+), of which a page may have several: its
// slides sit side by side in one row that
// scrolls sideways and snaps, the first and last slides can sit in the middle like the others, it
// is a labelled region for screen readers, the native "next" button
// (Chromium, the test browser) brings the row exactly to its end and then hides (the user found it
// showing at the last video in one browser), and visitors who ask for less motion get no glide.
const MUSIC_PATH = '/music/';
const ROW = 'section.site-carousel';
const SLIDE_SETTLE_MS = 800;

async function openCarousel(page: Page): Promise<Locator> {
	await page.setViewportSize({ width: 1280, height: 900 });
	await page.goto(MUSIC_PATH);
	// The first carousel, which has no heading above it (the test page's second one has).
	const row = page.locator(ROW).first();
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

// The current video sits in the middle with equal parts of its neighbours showing (the user), the
// first and last included, which needs the spacers before and after them.
test('at the start the first slide is centred, and at the end the last one is', async ({ page }) => {
	const row = await openCarousel(page);
	for (const end of ['start', 'end'] as const) {
		const sides = await row.evaluate((element, which) => {
			element.style.scrollBehavior = 'auto';
			element.scrollLeft = which === 'start' ? 0 : element.scrollWidth - element.clientWidth;
			const slide = (which === 'start' ? element.firstElementChild : element.lastElementChild)?.getBoundingClientRect();
			const visible = element.getBoundingClientRect();
			return slide === undefined ? null : { left: slide.left - visible.left, right: visible.right - slide.right };
		}, end);
		expect(sides, `the slide at the ${end}`).not.toBeNull();
		if (sides === null) {
			return;
		}
		expect(sides.left, `the space left of the ${end}'s slide`).toBeGreaterThan(0);
		expect(Math.abs(sides.left - sides.right), `the difference between the sides at the ${end}`).toBeLessThanOrEqual(1);
	}
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

// Several carousels on one page (the user: Rock, Country, Mellow): each one's arrows act on its own
// row; they were once placed by a name all carousels shared, so they followed the last one.
test('each carousel\'s "next" button moves its own row and no other', async ({ page }) => {
	await page.setViewportSize({ width: 1280, height: 900 });
	await page.goto(MUSIC_PATH);
	const rows = page.locator(ROW);
	await expect(rows, 'the carousels on the test page').toHaveCount(2);
	for (const index of [0, 1]) {
		const row = rows.nth(index);
		await row.evaluate((element) => { element.scrollLeft = 0; });
		await row.scrollIntoViewIfNeeded();
		const box = await row.boundingBox();
		const buttonSize = 44;
		const gap = 16;
		await page.mouse.click((box?.x ?? 0) + (box?.width ?? 0) - gap - buttonSize / 2, (box?.y ?? 0) + (box?.height ?? 0) / 2);
		await page.waitForTimeout(SLIDE_SETTLE_MS);
		const positions = await rows.evaluateAll((elements) => elements.map((element) => element.scrollLeft));
		expect(positions[index], `carousel ${index + 1} after its own "next"`).toBeGreaterThan(0);
		expect(positions[1 - index], `carousel ${2 - index} after the other one's "next"`).toBe(0);
		await row.evaluate((element) => { element.style.scrollBehavior = 'auto'; element.scrollLeft = 0; });
	}
});

// A carousel directly under a heading is named after it for screen readers; one without a heading
// keeps its own label (the user: a single carousel needs no heading).
test('a carousel under a heading is named after it, one without keeps its own label', async ({ page }) => {
	await page.goto(MUSIC_PATH);
	const named = page.getByRole('region', { name: 'Sample second set' });
	await expect(named, 'the carousel under the heading').toHaveCount(1);
	await expect(named, 'the carousel under the heading').toHaveClass(/site-carousel/);
	const headingId = await page.getByRole('heading', { name: 'Sample second set' }).getAttribute('id');
	expect(headingId, 'the heading\'s id').toBeTruthy();
	await expect(named, 'its link to the heading').toHaveAttribute('aria-labelledby', headingId ?? '');
	await expect(page.getByRole('region', { name: 'Videos' }), 'the carousel without a heading').toHaveCount(1);
});
