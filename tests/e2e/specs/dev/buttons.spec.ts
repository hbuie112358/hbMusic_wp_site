import { expect, test, type Locator, type Page } from '@playwright/test';

// Protects how buttons respond, which axe does not see because it checks the page at rest
// (plan D29; docs/SITE_CHECKLIST.md 7.2): keyboard focus always shows a ring that stands out from
// the band the button sits on, and visitors who ask for less motion get no movement on hover.
const HOME_PATH = '/';
const BUTTON_AREAS = [
	{ name: 'the opening band', selector: '.site-hero' },
	{ name: 'the call-to-action band', selector: '.site-cta' },
];
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

for (const area of BUTTON_AREAS) {
	test(`keyboard focus shows a clear ring on buttons in ${area.name}`, async ({ page }) => {
		await page.goto(HOME_PATH);
		const band = page.locator(area.selector).first();
		const bandBackground = await band.evaluate((element) => getComputedStyle(element).backgroundColor);
		const pageBackground = await page.evaluate(() => getComputedStyle(document.body).backgroundColor);
		const background = bandBackground === 'rgba(0, 0, 0, 0)' ? pageBackground : bandBackground;
		const button = band.locator('.wp-block-button__link').first();
		await tabTo(page, button);
		const ring = await button.evaluate((element) => {
			const style = getComputedStyle(element);
			return { style: style.outlineStyle, width: parseFloat(style.outlineWidth), colour: style.outlineColor };
		});
		expect(ring.style, 'the ring is drawn').not.toBe('none');
		expect(ring.width, 'the ring is at least 2px').toBeGreaterThanOrEqual(MINIMUM_RING_WIDTH_PX);
		expect(contrast(ring.colour, background), `the ring (${ring.colour}) against ${background}`).toBeGreaterThanOrEqual(MINIMUM_RING_CONTRAST);
	});
}

// The user noticed the outlined button was larger than the main one beside it: its border added
// to its size. Buttons side by side must match.
test('a main button and an outlined button side by side are the same height', async ({ page }) => {
	await page.goto(HOME_PATH);
	const pair = page.locator('.site-hero .wp-block-buttons').first();
	const main = await pair.locator('.wp-block-button:not(.is-style-outline) .wp-block-button__link').boundingBox();
	const outlined = await pair.locator('.wp-block-button.is-style-outline .wp-block-button__link').boundingBox();
	expect(main, 'the main button').not.toBeNull();
	expect(outlined, 'the outlined button').not.toBeNull();
	expect(outlined?.height, 'the outlined button\'s height').toBe(main?.height);
});

async function transformWhilePointedAt(page: Page): Promise<string> {
	await page.goto(HOME_PATH);
	const button = page.locator('.site-hero .wp-block-button__link').first();
	await button.hover();
	// Past the transition, so the end state is read.
	await page.waitForFunction((element) => element !== null && element.getAnimations().length === 0, await button.elementHandle());
	return button.evaluate((element) => getComputedStyle(element).transform);
}

test('a button pointed at lifts', async ({ page }) => {
	expect(await transformWhilePointedAt(page), 'the transform while pointed at').not.toBe('none');
});

// A touch screen keeps the hover state after a tap, which would leave a tapped button lifted.
test.describe('on a touch screen', () => {
	test.use({ hasTouch: true, isMobile: true });

	test('a tapped button does not stay lifted', async ({ page }) => {
		await page.goto(HOME_PATH);
		const button = page.locator('.site-hero .wp-block-button__link').first();
		await button.evaluate((element) => element.addEventListener('click', (event) => event.preventDefault()));
		await button.tap();
		expect(await button.evaluate((element) => getComputedStyle(element).transform), 'the transform after a tap').toBe('none');
	});
});

test('a button pointed at does not move for visitors who ask for less motion', async ({ page }) => {
	await page.emulateMedia({ reducedMotion: 'reduce' });
	expect(await transformWhilePointedAt(page), 'the transform while pointed at').toBe('none');
});
