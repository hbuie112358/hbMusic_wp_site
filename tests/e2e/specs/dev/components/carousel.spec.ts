import { expect, test, type Locator, type Page } from '@playwright/test';
import { EXAMPLE_PATHS, pagesUsing } from '../helpers/test-pages';

// Protects the CSS-only carousel (plan D29, option A+), of which a page may have several: its
// slides sit side by side in one row that scrolls sideways and snaps, the first and last slides
// can sit in the middle like the others, it is a labelled region for screen readers, the native
// "next" button (Chromium, the test browser) brings the row exactly to its end and then hides (the
// user found it showing at the last video in one browser), and visitors who ask for less motion
// get no glide. Checked on every page with a carousel (template plan T10); the rules about
// several carousels and their headings hold on any such page, and the example page has every
// case: two carousels, one under a heading and one under an empty heading.
const PAGES_WITH_CAROUSELS = pagesUsing('site-carousel');
const ROW = 'section.site-carousel';
// The label the carousel pattern gives a carousel without a heading above it.
const UNNAMED_CAROUSEL_LABEL = 'Videos';
const SLIDE_SETTLE_MS = 800;
const NEXT_BUTTON_SIZE_PX = 44;
const NEXT_BUTTON_GAP_PX = 16;

async function openCarousel(page: Page, path: string): Promise<Locator> {
	await page.setViewportSize({ width: 1280, height: 900 });
	await page.goto(path);
	const row = page.locator(ROW).first();
	await row.scrollIntoViewIfNeeded();
	return row;
}

async function clickNext(page: Page, row: Locator): Promise<void> {
	const box = await row.boundingBox();
	await page.mouse.click((box?.x ?? 0) + (box?.width ?? 0) - NEXT_BUTTON_GAP_PX - NEXT_BUTTON_SIZE_PX / 2, (box?.y ?? 0) + (box?.height ?? 0) / 2);
	await page.waitForTimeout(SLIDE_SETTLE_MS);
}

for (const path of PAGES_WITH_CAROUSELS) {
	test.describe(`on ${path}`, () => {
		test('the carousel\'s slides sit side by side in a row that scrolls sideways and snaps', async ({ page }) => {
			const row = await openCarousel(page, path);
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

		// The current video sits in the middle with equal parts of its neighbours showing (the
		// user), the first and last included, which needs the spacers before and after them.
		test('at the start the first slide is centred, and at the end the last one is', async ({ page }) => {
			const row = await openCarousel(page, path);
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

		test('clicking "next" to the end lands exactly at the end, where "next" is hidden', async ({ page }) => {
			const row = await openCarousel(page, path);
			for (let click = 0; click < 4; click++) {
				await clickNext(page, row);
			}
			const end = await row.evaluate((element) => ({
				left: element.scrollLeft,
				max: element.scrollWidth - element.clientWidth,
				next: getComputedStyle(element, '::scroll-button(right)').opacity,
			}));
			expect(end.left, 'the scroll position after the clicks').toBe(end.max);
			expect(end.next, 'the "next" button\'s opacity at the end').toBe('0');
		});

		// axe found the row unreachable by keyboard (scrollable-region-focusable); the theme makes
		// it focusable, and the arrow keys then scroll it.
		test('a keyboard user reaches the carousel with Tab and scrolls it with the arrow keys', async ({ page }) => {
			const row = await openCarousel(page, path);
			await expect(row, 'the row\'s place in the Tab order').toHaveAttribute('tabindex', '0');
			await row.focus();
			await page.keyboard.press('ArrowRight');
			await page.waitForFunction((element) => element !== null && element.scrollLeft > 0, await row.elementHandle());
			expect(await row.evaluate((element) => element.scrollLeft), 'the scroll position after →').toBeGreaterThan(0);
		});

		test('the carousel jumps instead of gliding for visitors who ask for less motion', async ({ page }) => {
			await page.emulateMedia({ reducedMotion: 'reduce' });
			const row = await openCarousel(page, path);
			expect(await row.evaluate((element) => getComputedStyle(element).scrollBehavior), 'the scrolling').toBe('auto');
		});

		// Several carousels on one page (the user: Rock, Country, Mellow): each one's arrows act on
		// its own row; they were once placed by a name all carousels shared, so they followed the
		// last one.
		test('each carousel\'s "next" button moves its own row and no other', async ({ page }) => {
			await page.setViewportSize({ width: 1280, height: 900 });
			await page.goto(path);
			const rows = page.locator(ROW);
			const count = await rows.count();
			if (EXAMPLE_PATHS.includes(path)) {
				expect(count, 'the carousels on the example page, built to show several').toBeGreaterThanOrEqual(2);
			}
			for (let index = 0; index < count; index++) {
				const row = rows.nth(index);
				await row.evaluate((element) => { element.scrollLeft = 0; });
				await row.scrollIntoViewIfNeeded();
				await clickNext(page, row);
				const positions = await rows.evaluateAll((elements) => elements.map((element) => element.scrollLeft));
				positions.forEach((position, other) => {
					const expectation = expect(position, `carousel ${other + 1} after carousel ${index + 1}'s "next"`);
					if (other === index) {
						expectation.toBeGreaterThan(0);
					} else {
						expectation.toBe(0);
					}
				});
				await row.evaluate((element) => { element.style.scrollBehavior = 'auto'; element.scrollLeft = 0; });
			}
		});

		// A carousel directly under a heading is named after it for screen readers; one without a
		// heading keeps its own label (the user: a single carousel needs no heading).
		test('each carousel is a region named after the heading directly above it, or "Videos" without one', async ({ page }) => {
			await page.goto(path);
			const kinds = { named: 0, unnamed: 0 };
			for (const row of await page.locator(ROW).all()) {
				const heading = await row.evaluate((element) => {
					const above = element.previousElementSibling;
					return above !== null && /^H[1-6]$/.test(above.tagName) && (above.textContent ?? '').trim() !== ''
						? { id: above.id, text: (above.textContent ?? '').trim() }
						: null;
				});
				if (heading === null) {
					await expect(row, 'a carousel without a heading').toHaveAttribute('aria-label', UNNAMED_CAROUSEL_LABEL);
					kinds.unnamed++;
					continue;
				}
				expect(heading.id, `the id of the heading "${heading.text}"`).toBeTruthy();
				await expect(row, `the carousel under "${heading.text}"`).toHaveAttribute('aria-labelledby', heading.id);
				await expect(page.getByRole('region', { name: heading.text }), `the region named "${heading.text}"`).toHaveCount(1);
				kinds.named++;
			}
			if (EXAMPLE_PATHS.includes(path)) {
				expect(kinds.named, 'carousels under a heading on the example page').toBeGreaterThanOrEqual(1);
				expect(kinds.unnamed, 'carousels without one on the example page').toBeGreaterThanOrEqual(1);
			}
		});

		// Described as in the W3C's carousel pattern (WAI-ARIA Authoring Practices): the carousel as
		// a carousel, each slide as "slide n of m" (the user asked for it to say what it is).
		test('a carousel is described as a carousel, and each slide as "n of m"', async ({ page }) => {
			await page.goto(path);
			for (const row of await page.locator(ROW).all()) {
				await expect(row, 'the carousel\'s description').toHaveAttribute('aria-roledescription', 'carousel');
				const slides = row.locator(':scope > *');
				const count = await slides.count();
				expect(count, 'the slides').toBeGreaterThanOrEqual(2);
				for (let index = 0; index < count; index++) {
					const slide = slides.nth(index);
					await expect(slide, `slide ${index + 1}'s role`).toHaveAttribute('role', 'group');
					await expect(slide, `slide ${index + 1}'s description`).toHaveAttribute('aria-roledescription', 'slide');
					await expect(slide, `slide ${index + 1}'s name`).toHaveAttribute('aria-label', `${index + 1} of ${count}`);
				}
			}
		});

		// The pattern's optional heading, left empty above a carousel, leaves no blank gap and
		// nothing for a screen reader to announce (the user: invisible if unused).
		test('no empty heading is left on the page', async ({ page }) => {
			await page.goto(path);
			const emptyHeadings = await page.locator('main :is(h1, h2, h3, h4, h5, h6)').evaluateAll((headings) => headings.filter((heading) => heading.textContent?.trim() === '').length);
			expect(emptyHeadings, 'the empty headings on the page').toBe(0);
		});
	});
}
