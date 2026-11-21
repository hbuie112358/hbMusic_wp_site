import { expect, test, type Page } from '@playwright/test';
import { themeLength } from './theme-values';

// Protects the page's one frame (plan D29, the user): the header's and footer's content, the
// panels and the carousel share the same left and right edges on every page, on a computer and
// on a phone; on a wide screen the panels stop at the frame (the theme's wide width) instead of
// reaching the screen's edges; and two panels in a row keep a section's spacing between them.
const HEADER_ROW = '.site-header > .wp-block-group';
const FRAMED_PARTS: Record<string, string> = {
	'footer content': '.site-footer > .wp-block-group',
	'opening panel': '.site-hero',
	'features panel': '.site-features',
	'call-to-action panel': '.site-cta',
	carousel: '.site-carousel',
};
const PANEL = '.site-panel';
const PANELS_ON_HOME = 3;
// The test Home page has the features panel directly followed by the call-to-action panel.
const PAGE_WITH_PANELS_IN_A_ROW = '/';
const PAGES_WITH_FRAMED_PARTS = ['/', '/music/', '/about/'];
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
	for (const path of PAGES_WITH_FRAMED_PARTS) {
		test(`${path} at ${width}px: every part shares the header's left and right edges`, async ({ page }) => {
			await page.setViewportSize({ width, height: 900 });
			await page.goto(path);
			const frame = await edgesOf(page, HEADER_ROW);
			expect(frame, 'the header\'s content').not.toBeNull();
			let compared = 0;
			for (const [name, selector] of Object.entries(FRAMED_PARTS)) {
				const edges = await edgesOf(page, selector);
				if (edges !== null) {
					expect(edges, `the ${name}'s edges`).toEqual(frame);
					compared++;
				}
			}
			// The footer and at least one panel or carousel on each of these pages.
			expect(compared, 'the parts compared with the header').toBeGreaterThanOrEqual(2);
		});
	}
}

test('on a wide screen each panel is the frame\'s width, centred, not the screen\'s', async ({ page }) => {
	await page.setViewportSize({ width: WIDE_SCREEN, height: 900 });
	await page.goto('/');
	const frameWidth = await themeLength(page, 'var(--wp--style--global--wide-size)');
	expect(frameWidth, 'the frame\'s width').toBeGreaterThan(0);
	expect(frameWidth, 'the frame\'s width').toBeLessThan(WIDE_SCREEN);
	const panels = await page.evaluate((selector) => [...document.querySelectorAll(selector)].map((panel) => {
		const box = panel.getBoundingClientRect();
		// Named by its component class (site-hero, site-cta...), without WordPress's layout classes.
		const name = [...panel.classList].filter((name) => name.startsWith('site-') && name !== 'site-panel').join(' ');
		return { name, left: Math.round(box.left), right: Math.round(box.right) };
	}), PANEL);
	expect(panels.length, 'the panels on the test Home page (opening, features, call to action)').toBe(PANELS_ON_HOME);
	for (const { name, left, right } of panels) {
		expect(right - left, `the width of "${name}"`).toBe(frameWidth);
		expect(Math.abs(left - (WIDE_SCREEN - right)), `the difference between the side margins of "${name}"`).toBeLessThanOrEqual(1);
	}
});

// Their backgrounds would meet otherwise: a plain section's padding, which separates other
// neighbours, is not there between two panels.
test('two panels in a row keep a section\'s spacing between them', async ({ page }) => {
	await page.goto(PAGE_WITH_PANELS_IN_A_ROW);
	const sectionSpacing = await themeLength(page, 'var(--wp--custom--spacing--section)');
	const gaps = await page.evaluate(() => [...document.querySelectorAll('.site-panel + .site-panel')].map((panel) => {
		const previous = panel.previousElementSibling;
		return previous === null ? Number.NaN : Math.round(panel.getBoundingClientRect().top - previous.getBoundingClientRect().bottom);
	}));
	expect(gaps.length, 'the pairs of panels in a row').toBeGreaterThanOrEqual(1);
	expect(sectionSpacing, 'the section spacing').toBeGreaterThan(0);
	for (const gap of gaps) {
		expect(gap, 'the space between two panels').toBe(sectionSpacing);
	}
});

// The call-to-action panel from the page template stands a section's spacing below the content,
// whether the content ends with text (About) or with a plain section, whose own bottom padding
// would otherwise double the space (Home).
for (const path of ['/', '/about/']) {
	test(`${path}: the call-to-action panel stands a section's spacing below the content`, async ({ page }) => {
		await page.goto(path);
		const sectionSpacing = await themeLength(page, 'var(--wp--custom--spacing--section)');
		const gap = await page.evaluate(() => {
			const lastContent = document.querySelector('main .wp-block-post-content > :last-child');
			const panel = document.querySelector('main .wp-block-template-part > .site-cta');
			if (!lastContent || !panel) {
				return Number.NaN;
			}
			// The space a visitor sees: a block without a background of its own (not a panel) shows
			// its bottom padding as empty page, so the visible content ends above it.
			const hiddenPadding = lastContent.classList.contains('site-panel') ? 0 : Number.parseFloat(getComputedStyle(lastContent).paddingBottom);
			return Math.round(panel.getBoundingClientRect().top - (lastContent.getBoundingClientRect().bottom - hiddenPadding));
		});
		expect(sectionSpacing, 'the section spacing').toBeGreaterThan(0);
		expect(gap, 'the space above the call-to-action panel').toBe(sectionSpacing);
	});
}
