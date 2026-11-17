import { expect, type Locator, type Page } from '@playwright/test';

// The hamburger menu on a phone (plan 9t), shared by header.spec.ts and
// hamburger-menu-webkit.spec.ts: where its parts are, and how a test opens it.
const HEADER = 'header.wp-block-template-part';
export const PHONE = { width: 390, height: 800 };
export const OPEN_MENU_PANEL = `${HEADER} .wp-block-navigation__responsive-container.is-menu-open`;
export const OPEN_MENU_BUTTON = `${HEADER} .wp-block-navigation__responsive-container-open`;
export const CLOSE_MENU_BUTTON = `${OPEN_MENU_PANEL} .wp-block-navigation__responsive-container-close`;
// Where a tap lands on the page below the open panel, in pixels below its bottom edge.
export const TAP_BELOW_PANEL = 150;

export async function openPhoneMenu(page: Page): Promise<Locator> {
	await page.setViewportSize(PHONE);
	await page.goto('/');
	await page.locator(OPEN_MENU_BUTTON).click();
	const panel = page.locator(OPEN_MENU_PANEL);
	await expect(panel, 'the open menu panel').toBeVisible();
	return panel;
}

// The menu's links a tap would not reach: outside the window, or covered by something else.
export async function unreachableLinks(panel: Locator): Promise<string[]> {
	return panel.locator('.wp-block-navigation-item__content').evaluateAll((elements) =>
		elements
			.filter((link) => {
				const rect = link.getBoundingClientRect();
				const centre = document.elementFromPoint(rect.left + rect.width / 2, rect.top + rect.height / 2);
				const isInWindow = rect.top >= 0 && rect.bottom <= window.innerHeight && rect.width > 0;
				return !isInWindow || !(centre !== null && link.contains(centre));
			})
			.map((link) => link.textContent?.trim() ?? '(no text)'),
	);
}


// Taps the page below the open panel, as a visitor's thumb would, and expects the menu closed.
export async function expectTapBelowClosesMenu(page: Page): Promise<void> {
	const panel = await openPhoneMenu(page);
	const box = await panel.boundingBox();
	const tapY = Math.round((box?.y ?? 0) + (box?.height ?? 0)) + TAP_BELOW_PANEL;
	// A tap off the window's edge would prove nothing: Chromium counts it as focus leaving too.
	expect(tapY, 'the tap lands on the page, inside the window').toBeLessThan(PHONE.height);
	await page.touchscreen.tap(PHONE.width / 2, tapY);
	await expect(page.locator(OPEN_MENU_PANEL), 'the open menu panel').toHaveCount(0);
}
