import { expect, test, type Locator, type Page } from '@playwright/test';
import { TEST_PATHS, pagesUsing } from '../helpers/test-pages';

// Protects how buttons respond, which axe does not see because it checks the page at rest
// (plan D29; docs/SITE_CHECKLIST.md 7.2): keyboard focus always shows a ring that stands out from
// the band the button sits on, and visitors who ask for less motion get no movement on hover.
// Checked on every page with buttons in an opening band (template plan T10), and in the call to
// action on every page whose template adds one.
const PAGES_WITH_HERO_BUTTONS = pagesUsing('site-hero', 'wp-block-button');
const HERO = '.site-hero';
const CALL_TO_ACTION = '.site-cta';
// WCAG 2.2: a focus indicator needs 3:1 against what is next to it, and a ring at least 2px thick.
const MINIMUM_RING_CONTRAST = 3;
const MINIMUM_RING_WIDTH_PX = 2;
const MAXIMUM_TABS = 40;

// Moves the keyboard focus to the target the way a visitor does, so :focus-visible applies.
async function tabTo(page: Page, target: Locator): Promise<void> {
	for (let tab = 0; tab < MAXIMUM_TABS; tab++) {
		await page.keyboard.press('Tab');
		if (await target.evaluate((element) => element === document.activeElement)) {
			return;
		}
	}
	throw new Error(`the button was not reached within ${MAXIMUM_TABS} presses of Tab`);
}

function relativeLuminance(colour: string): number {
	const channels = (colour.match(/[\d.]+/g) ?? []).slice(0, 3).map((value) => Number(value) / 255);
	const [red = 0, green = 0, blue = 0] = channels.map((value) =>
		value <= 0.03928 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4,
	);
	return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
}

function contrast(first: string, second: string): number {
	const [lighter, darker] = [relativeLuminance(first), relativeLuminance(second)].sort((a, b) => b - a);
	return ((lighter ?? 0) + 0.05) / ((darker ?? 0) + 0.05);
}

// The ring on the first button in the band, measured against the band's background (or the
// page's, where the band has none of its own).
async function expectClearRing(page: Page, bandSelector: string, where: string): Promise<void> {
	const band = page.locator(bandSelector).first();
	const bandBackground = await band.evaluate((element) => getComputedStyle(element).backgroundColor);
	const pageBackground = await page.evaluate(() => getComputedStyle(document.body).backgroundColor);
	const background = bandBackground === 'rgba(0, 0, 0, 0)' ? pageBackground : bandBackground;
	const button = band.locator('.wp-block-button__link').first();
	await tabTo(page, button);
	const ring = await button.evaluate((element) => {
		const style = getComputedStyle(element);
		return { style: style.outlineStyle, width: parseFloat(style.outlineWidth), colour: style.outlineColor };
	});
	expect(ring.style, `the ring is drawn, ${where}`).not.toBe('none');
	expect(ring.width, `the ring is at least 2px, ${where}`).toBeGreaterThanOrEqual(MINIMUM_RING_WIDTH_PX);
	expect(contrast(ring.colour, background), `the ring (${ring.colour}) against ${background}, ${where}`).toBeGreaterThanOrEqual(MINIMUM_RING_CONTRAST);
}

// The call to action comes from the page template, which no page file shows, so every page is
// opened and each one that has it is checked; none at all fails, rather than checking nothing.
test('keyboard focus shows a clear ring on buttons in the call-to-action band, on every page with one', async ({ page }) => {
	const checked: string[] = [];
	for (const path of TEST_PATHS) {
		await page.goto(path);
		if ((await page.locator(CALL_TO_ACTION).count()) === 0) {
			continue;
		}
		await expectClearRing(page, CALL_TO_ACTION, `on ${path}`);
		checked.push(path);
	}
	expect(checked.length, 'the pages with a call to action').toBeGreaterThan(0);
});

async function transformWhilePointedAt(page: Page, path: string): Promise<string> {
	await page.goto(path);
	const button = page.locator(`${HERO} .wp-block-button__link`).first();
	await button.hover();
	// Past the transition, so the end state is read.
	await page.waitForFunction((element) => element !== null && element.getAnimations().length === 0, await button.elementHandle());
	return button.evaluate((element) => getComputedStyle(element).transform);
}

for (const path of PAGES_WITH_HERO_BUTTONS) {
	test.describe(`on ${path}`, () => {
		test('keyboard focus shows a clear ring on buttons in the opening band', async ({ page }) => {
			await page.goto(path);
			await expectClearRing(page, HERO, 'in the opening band');
		});

		// The user noticed the outlined button was larger than the main one beside it: its border
		// added to its size. Buttons side by side must match.
		test('a main button and an outlined button side by side are the same height', async ({ page }) => {
			await page.goto(path);
			const pair = page.locator(`${HERO} .wp-block-buttons`).first();
			const main = await pair.locator('.wp-block-button:not(.is-style-outline) .wp-block-button__link').boundingBox();
			const outlined = await pair.locator('.wp-block-button.is-style-outline .wp-block-button__link').boundingBox();
			expect(main, 'the main button').not.toBeNull();
			expect(outlined, 'the outlined button').not.toBeNull();
			expect(outlined?.height, 'the outlined button\'s height').toBe(main?.height);
		});

		// The user once saw two buttons in a row stacked at different widths. Whether buttons stack
		// depends on the column, not on one screen width, so the pair is measured at widths where
		// they sit side by side and where they stack.
		for (const width of [1280, 900, 600, 390]) {
			test(`two buttons in a row are the same width at ${width}px`, async ({ page }) => {
				await page.setViewportSize({ width, height: 900 });
				await page.goto(path);
				const widths = await page
					.locator(`${HERO} .wp-block-buttons`)
					.first()
					.locator('.wp-block-button__link')
					.evaluateAll((links) => links.map((link) => Math.round(link.getBoundingClientRect().width)));
				expect(widths.length, 'the buttons in the row').toBeGreaterThanOrEqual(2);
				expect(new Set(widths).size, `the buttons' widths ${widths.join(', ')}`).toBe(1);
			});
		}

		test('a button pointed at lifts', async ({ page }) => {
			expect(await transformWhilePointedAt(page, path), 'the transform while pointed at').not.toBe('none');
		});

		// A touch screen keeps the hover state after a tap, which would leave a tapped button lifted.
		test.describe('on a touch screen', () => {
			test.use({ hasTouch: true, isMobile: true });

			test('a tapped button does not stay lifted', async ({ page }) => {
				await page.goto(path);
				const button = page.locator(`${HERO} .wp-block-button__link`).first();
				await button.evaluate((element) => element.addEventListener('click', (event) => event.preventDefault()));
				await button.tap();
				expect(await button.evaluate((element) => getComputedStyle(element).transform), 'the transform after a tap').toBe('none');
			});
		});

		test('a button pointed at does not move for visitors who ask for less motion', async ({ page }) => {
			await page.emulateMedia({ reducedMotion: 'reduce' });
			expect(await transformWhilePointedAt(page, path), 'the transform while pointed at').toBe('none');
		});
	});
}
