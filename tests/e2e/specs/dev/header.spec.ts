import AxeBuilder from '@axe-core/playwright';
import { expect, test, type Locator, type Page } from '@playwright/test';
import { WCAG_TAGS } from './accessibility';
import { CLOSE_MENU_BUTTON, OPEN_MENU_BUTTON, OPEN_MENU_PANEL, PHONE, TAP_BELOW_PANEL, expectTapBelowClosesMenu, openPhoneMenu, unreachableLinks } from './hamburger-menu';

// Protects the sticky header and the menu (plan D29): the header stays at the top while the page
// scrolls, a link reached with the keyboard is never hidden under it (WCAG 2.2, 2.4.11), the menu
// marks the page being shown, the header is slimmer on phones, a page that ends with a panel has
// the same space before the footer as a page that ends with text, and the hamburger menu on a
// phone opens over the whole window with the header still frosted (plan 9t).
const HEADER = 'header.wp-block-template-part';
const ABOUT_PATH = '/about/';
// Ends with a paragraph (tests/dev-content/privacy-policy.html).
const PAGE_ENDING_WITH_TEXT = '/privacy-policy/';
// Home uses the "Page No Title" template, About the default "Page" template (bin/dev-site).
const PAGES_ENDING_WITH_A_PANEL = ['/', ABOUT_PATH];
const MAXIMUM_TABS = 40;

async function scrollToBottom(page: Page): Promise<void> {
	await page.evaluate(() => window.scrollTo(0, document.documentElement.scrollHeight));
	await page.waitForFunction(() => window.scrollY > 0);
}

// Moves the keyboard focus backwards, the way a visitor does, until the target has it.
async function shiftTabTo(page: Page, target: Locator): Promise<void> {
	for (let tab = 0; tab < MAXIMUM_TABS; tab++) {
		await page.keyboard.press('Shift+Tab');
		if (await target.evaluate((element) => element === document.activeElement)) {
			return;
		}
	}
	throw new Error(`the target was not reached within ${MAXIMUM_TABS} presses of Shift+Tab`);
}

test('the header stays at the top while the page scrolls', async ({ page }) => {
	await page.setViewportSize({ width: 1280, height: 600 });
	await page.goto('/');
	await scrollToBottom(page);
	const header = await page.locator(HEADER).boundingBox();
	expect(header?.y, 'the header\'s distance from the top of the window').toBe(0);
});

test('a link reached with the keyboard is not hidden under the header', async ({ page }) => {
	await page.setViewportSize({ width: 1280, height: 600 });
	await page.goto('/');
	await page.locator('footer a').last().focus();
	await scrollToBottom(page);
	const target = page.locator('.site-hero .wp-block-button__link').first();
	await shiftTabTo(page, target);
	const header = await page.locator(HEADER).boundingBox();
	const focused = await target.boundingBox();
	expect(focused?.y, 'the focused button\'s top').toBeGreaterThanOrEqual((header?.y ?? 0) + (header?.height ?? 0));
});

for (const [path, label] of [
	[ABOUT_PATH, 'About'],
	['/music/', 'Music'],
] as const) {
	test(`the menu marks ${label} as the page being shown, and nothing else`, async ({ page }) => {
		await page.setViewportSize({ width: 1280, height: 800 });
		await page.goto(path);
		const marked = page.locator(`${HEADER} .wp-block-navigation-item__content[aria-current="page"]`);
		await expect(marked, 'the marked menu links').toHaveCount(1);
		await expect(marked, 'the marked link').toHaveText(label);
	});
}

// The space between the page's last block (from its content or its template) and the footer, in
// whole pixels.
async function spaceBeforeFooter(page: Page, path: string): Promise<number> {
	await page.goto(path);
	return page.evaluate(() => {
		const blocks = [...document.querySelectorAll('main .wp-block-post-content > *, main .wp-block-template-part')];
		const footer = document.querySelector('footer.wp-block-template-part');
		if (blocks.length === 0 || !footer) {
			return Number.NaN;
		}
		const lastBottom = Math.max(...blocks.map((block) => block.getBoundingClientRect().bottom));
		return Math.round(footer.getBoundingClientRect().top - lastBottom);
	});
}

// A page ending with the call-to-action panel (from its "with call to action" template) keeps the
// template's own space before the footer, the same as a page ending with text, in both templates
// the pages use: no strip added (the full-width band once had one) and no rule of ours.
for (const path of PAGES_ENDING_WITH_A_PANEL) {
	test(`${path} ends with the call-to-action panel and has the same space before the footer as a page that ends with text`, async ({ page }) => {
		await page.goto(path);
		await expect(page.locator('main .wp-block-template-part > .site-cta.site-panel'), `the panel ending ${path}`).toHaveCount(1);
		const afterPanel = await spaceBeforeFooter(page, path);
		const afterText = await spaceBeforeFooter(page, PAGE_ENDING_WITH_TEXT);
		expect(afterText, 'the space after text').toBeGreaterThan(0);
		expect(afterPanel, 'the space after the panel').toBe(afterText);
	});
}

test('the header is slimmer on a phone than on a computer', async ({ page }) => {
	await page.setViewportSize({ width: 1280, height: 800 });
	await page.goto('/');
	const desktop = (await page.locator(HEADER).boundingBox())?.height ?? 0;
	await page.setViewportSize({ width: 390, height: 800 });
	const phone = (await page.locator(HEADER).boundingBox())?.height ?? 0;
	expect(phone, 'the header\'s height on a phone').toBeLessThan(desktop);
});

// The hamburger menu on a phone (plan 9t). A backdrop-filter on the header once made it the frame
// of WordPress's fixed menu panel, so the open panel was trapped in the header strip. Now the panel
// drops down from under the header, only as tall as its links, with the page visible below (the
// user's choice): the close button takes the menu button's place, every link is the element the
// browser finds at its own centre (so a tap reaches it), and the close button, Escape and a tap on
// the page below each close it.
test('the hamburger menu drops down under the header on a phone, every link reachable', async ({ page }) => {
	const panel = await openPhoneMenu(page);
	const header = await page.locator(HEADER).boundingBox();
	const box = await panel.boundingBox();
	// In whole pixels: the browser lays out in fractions.
	expect(Math.round(box?.y ?? -1), 'the panel starts at the header\'s bottom').toBe(Math.round((header?.y ?? 0) + (header?.height ?? 0)));
	expect(Math.round((box?.y ?? 0) + (box?.height ?? 0)), 'the panel ends above the window\'s bottom').toBeLessThan(PHONE.height);
	expect(await panel.locator('.wp-block-navigation-item__content').count(), 'the menu\'s links').toBeGreaterThan(1);
	expect(await unreachableLinks(panel), 'menu links a tap would not reach').toEqual([]);

	const below = await page.evaluate(({ x, y }) => document.elementFromPoint(x, y)?.closest('.wp-block-navigation__responsive-container') === null, { x: PHONE.width / 2, y: Math.round((box?.y ?? 0) + (box?.height ?? 0)) + TAP_BELOW_PANEL });
	expect(below, 'the page is visible below the panel').toBe(true);
});

test('the close button takes the menu button\'s place, and the menu button steps aside', async ({ page }) => {
	await page.setViewportSize(PHONE);
	await page.goto('/');
	const openButton = await page.locator(OPEN_MENU_BUTTON).boundingBox();
	await openPhoneMenu(page);
	const closeButton = await page.locator(CLOSE_MENU_BUTTON).boundingBox();
	expect(Math.abs((closeButton?.x ?? 0) - (openButton?.x ?? 0)), 'horizontal distance, in pixels').toBeLessThanOrEqual(2);
	expect(Math.abs((closeButton?.y ?? 0) - (openButton?.y ?? 0)), 'vertical distance, in pixels').toBeLessThanOrEqual(2);
	await expect(page.locator(OPEN_MENU_BUTTON), 'the menu button while the menu is open').toBeHidden();
});

for (const [way, close] of [
	['the close button', async (page: Page) => page.locator(CLOSE_MENU_BUTTON).click()],
	['Escape', async (page: Page) => page.keyboard.press('Escape')],
] as const) {
	test(`${way} closes the hamburger menu`, async ({ page }) => {
		await openPhoneMenu(page);
		await close(page);
		await expect(page.locator(OPEN_MENU_PANEL), 'the open menu panel').toHaveCount(0);
	});
}

// A tap on the page below the panel closes it (WordPress closes the menu when the focus leaves it
// for nothing); the same test in WebKit, Safari's engine, is hamburger-menu-webkit.spec.ts.
test.describe('with a touch screen', () => {
	test.use({ hasTouch: true });

	test('a tap on the page below closes the hamburger menu', async ({ page }) => {
		await expectTapBelowClosesMenu(page);
	});
});

test.describe('with reduced motion', () => {
	test.use({ reducedMotion: 'reduce' });

	test('the hamburger menu appears without sliding', async ({ page }) => {
		const panel = await openPhoneMenu(page);
		const running = await panel.evaluate((element) => element.getAnimations({ subtree: true }).length);
		expect(running, 'animations in the open menu').toBe(0);
	});
});

test('the open hamburger menu has no accessibility errors', async ({ page }) => {
	await openPhoneMenu(page);
	const results = await new AxeBuilder({ page }).include(OPEN_MENU_PANEL).withTags(WCAG_TAGS).analyze();
	expect(results.violations.map((violation) => violation.id), 'the menu\'s accessibility').toEqual([]);
});

// The fix must keep the header's frosted look, not drop it: the blur sits on a layer behind the
// header's content (site-header.css), where it frosts the page below without framing the menu.
test('the header keeps its frosted background', async ({ page }) => {
	await page.setViewportSize(PHONE);
	await page.goto('/');
	const blur = await page.locator('.site-header').evaluate((header) => getComputedStyle(header, '::before').backdropFilter);
	expect(blur, 'the blur behind the header').toContain('blur(');
});
