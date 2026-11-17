import { expect, test, type Locator, type Page } from '@playwright/test';

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

// The hamburger menu on a phone (plan 9t): WordPress's menu panel is fixed to the window, and a
// backdrop-filter on any element around it makes that element the panel's frame instead (CSS
// Filter Effects), which once trapped the open panel inside the header strip with only its first
// link showing. The panel must fill the window, and each link must be the element the browser
// finds at its own centre, so a visitor's tap reaches it.
const PHONE = { width: 390, height: 800 };
const OPEN_MENU_PANEL = `${HEADER} .wp-block-navigation__responsive-container.is-menu-open`;

test('the hamburger menu opens over the whole window on a phone, every link reachable', async ({ page }) => {
	await page.setViewportSize(PHONE);
	await page.goto('/');
	await page.locator(HEADER).getByRole('button', { name: 'Open menu' }).click();
	const panel = page.locator(OPEN_MENU_PANEL);
	await expect(panel, 'the open menu panel').toBeVisible();

	// In whole pixels: the browser lays out in fractions (799.99998 for a full 800-pixel window).
	const box = await panel.boundingBox();
	expect(Math.round(box?.height ?? 0), 'the open panel\'s height, in pixels').toBeGreaterThanOrEqual(PHONE.height);
	const links = panel.locator('.wp-block-navigation-item__content');
	expect(await links.count(), 'the menu\'s links').toBeGreaterThan(1);
	const unreachable = await links.evaluateAll((elements) =>
		elements
			.filter((link) => {
				const rect = link.getBoundingClientRect();
				const centre = document.elementFromPoint(rect.left + rect.width / 2, rect.top + rect.height / 2);
				const isInWindow = rect.top >= 0 && rect.bottom <= window.innerHeight && rect.width > 0;
				return !isInWindow || !(centre !== null && link.contains(centre));
			})
			.map((link) => link.textContent?.trim() ?? '(no text)'),
	);
	expect(unreachable, 'menu links a tap would not reach').toEqual([]);
});

// The fix must keep the header's frosted look, not drop it: the blur sits on a layer behind the
// header's content (site-header.css), where it frosts the page below without framing the menu.
test('the header keeps its frosted background', async ({ page }) => {
	await page.setViewportSize(PHONE);
	await page.goto('/');
	const blur = await page.locator('.site-header').evaluate((header) => getComputedStyle(header, '::before').backdropFilter);
	expect(blur, 'the blur behind the header').toContain('blur(');
});
