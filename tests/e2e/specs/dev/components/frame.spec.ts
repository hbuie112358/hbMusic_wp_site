import { expect, test, type Page } from '@playwright/test';
import { EXAMPLE_PATHS, TEST_PATHS, pagesUsing } from '../helpers/test-pages';
import { themeLength } from './theme-values';

// Protects the page's one frame (plan D29, the user): the header's and footer's content, the
// panels and the carousel share the same left and right edges on every page, on a computer and
// on a phone; on a wide screen the panels stop at the frame (the theme's wide width) instead of
// reaching the screen's edges; and two panels in a row keep a section's spacing between them.
// Checked on every page (template plan T10): the edges wherever the parts appear, the panels on
// every page with one, and two panels in a row wherever a page has them, required on the example
// page, which is built to show them.
const HEADER_ROW = '.site-header > .wp-block-group';
const FOOTER_ROW = '.site-footer > .wp-block-group';
const FRAMED_PARTS: Record<string, string> = {
	'footer content': FOOTER_ROW,
	'opening panel': '.site-hero',
	'features panel': '.site-features',
	'call-to-action panel': '.site-cta',
	carousel: '.site-carousel',
};
const PANEL = '.site-panel';
const PAGES_WITH_PANELS = pagesUsing('site-panel');
const CALL_TO_ACTION = 'main .wp-block-template-part > .site-cta';
const WIDTHS = [1280, 390];
const WIDE_SCREEN = 1920;

interface Edges {
	left: number;
	right: number;
}

async function edgesOf(page: Page, selector: string): Promise<Edges | null> {
	return page.evaluate((target) => {
		const element = document.querySelector(target);
		if (!element) {
			return null;
		}
		const box = element.getBoundingClientRect();
		return { left: Math.round(box.left), right: Math.round(box.right) };
	}, selector);
}

for (const width of WIDTHS) {
	for (const path of TEST_PATHS) {
		test(`${path} at ${width}px: every part shares the header's left and right edges`, async ({ page }) => {
			await page.setViewportSize({ width, height: 900 });
			await page.goto(path);
			const frame = await edgesOf(page, HEADER_ROW);
			expect(frame, 'the header\'s content').not.toBeNull();
			expect(await edgesOf(page, FOOTER_ROW), 'the footer\'s content, on every page').not.toBeNull();
			for (const [name, selector] of Object.entries(FRAMED_PARTS)) {
				const edges = await edgesOf(page, selector);
				if (edges !== null) {
					expect(edges, `the ${name}'s edges`).toEqual(frame);
				}
			}
		});
	}
}

for (const path of PAGES_WITH_PANELS) {
	test(`${path} on a wide screen: each panel is the frame's width, centred, not the screen's`, async ({ page }) => {
		await page.setViewportSize({ width: WIDE_SCREEN, height: 900 });
		await page.goto(path);
		const frameWidth = await themeLength(page, 'var(--wp--style--global--wide-size)');
		expect(frameWidth, 'the frame\'s width').toBeGreaterThan(0);
		expect(frameWidth, 'the frame\'s width').toBeLessThan(WIDE_SCREEN);
		const panels = await page.evaluate((selector) => [...document.querySelectorAll(selector)].map((panel) => {
			const box = panel.getBoundingClientRect();
			// Named by its component class (site-hero, site-cta...), without WordPress's layout classes.
			const name = [...panel.classList].filter((name) => name.startsWith('site-') && name !== 'site-panel').join(' ');
			return { name, left: Math.round(box.left), right: Math.round(box.right) };
		}), PANEL);
		expect(panels.length, 'the panels on the page').toBeGreaterThanOrEqual(1);
		for (const { name, left, right } of panels) {
			expect(right - left, `the width of "${name}"`).toBe(frameWidth);
			expect(Math.abs(left - (WIDE_SCREEN - right)), `the difference between the side margins of "${name}"`).toBeLessThanOrEqual(1);
		}
	});

	// Their backgrounds would meet otherwise: a plain section's padding, which separates other
	// neighbours, is not there between two panels.
	test(`${path}: two panels in a row keep a section's spacing between them`, async ({ page }) => {
		await page.goto(path);
		const sectionSpacing = await themeLength(page, 'var(--wp--custom--spacing--section)');
		const gaps = await page.evaluate(() => [...document.querySelectorAll('.site-panel + .site-panel')].map((panel) => {
			const previous = panel.previousElementSibling;
			return previous === null ? Number.NaN : Math.round(panel.getBoundingClientRect().top - previous.getBoundingClientRect().bottom);
		}));
		if (EXAMPLE_PATHS.includes(path)) {
			expect(gaps.length, 'the pairs of panels in a row on the example page').toBeGreaterThanOrEqual(1);
		}
		expect(sectionSpacing, 'the section spacing').toBeGreaterThan(0);
		for (const gap of gaps) {
			expect(gap, 'the space between two panels').toBe(sectionSpacing);
		}
	});
}

// The call-to-action panel from the page template stands a section's spacing below the content,
// whether the content ends with text (About) or with a plain section, whose own bottom padding
// would otherwise double the space (Home). The page template adds it, which no page file shows,
// so every page is opened and each one that has it is checked; none at all fails.
test('the call-to-action panel stands a section\'s spacing below the content, on every page with one', async ({ page }) => {
	const checked: string[] = [];
	for (const path of TEST_PATHS) {
		await page.goto(path);
		if ((await page.locator(CALL_TO_ACTION).count()) === 0) {
			continue;
		}
		const sectionSpacing = await themeLength(page, 'var(--wp--custom--spacing--section)');
		const gap = await page.evaluate((panelSelector) => {
			const content = document.querySelector('main .wp-block-post-content');
			const lastContent = content?.lastElementChild;
			const panel = document.querySelector(panelSelector);
			if (!content || !lastContent || !panel) {
				return Number.NaN;
			}
			// The content ends where its area ends, which can be below its last block's box: a
			// carousel's dots are drawn under the row, outside it (::scroll-marker-group).
			const contentBottom = content.getBoundingClientRect().bottom;
			// The space a visitor sees: a block without a background of its own (not a panel) shows
			// its bottom padding as empty page, so where that block ends the content, the visible
			// content ends above the padding.
			const endsTheContent = Math.round(lastContent.getBoundingClientRect().bottom) === Math.round(contentBottom);
			const hiddenPadding = endsTheContent && !lastContent.classList.contains('site-panel') ? Number.parseFloat(getComputedStyle(lastContent).paddingBottom) : 0;
			return Math.round(panel.getBoundingClientRect().top - (contentBottom - hiddenPadding));
		}, CALL_TO_ACTION);
		expect(sectionSpacing, 'the section spacing').toBeGreaterThan(0);
		// Soft, so one run names every page whose space is wrong.
		expect.soft(gap, `the space above the call-to-action panel on ${path}`).toBe(sectionSpacing);
		checked.push(path);
	}
	expect(checked.length, 'the pages with a call to action').toBeGreaterThan(0);
});
