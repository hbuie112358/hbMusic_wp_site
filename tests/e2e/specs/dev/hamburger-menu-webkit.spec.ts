import { test } from '@playwright/test';
import { expectTapBelowClosesMenu } from './hamburger-menu';

// The hamburger menu closes when the page below it is tapped, in WebKit, Safari's engine (plan 9t).
// WordPress closes the menu when the focus leaves it for nothing; Safari often moves no focus when
// a plain part of a page is tapped, so iPhones are checked here and not assumed from Chromium.
test.use({ browserName: 'webkit', hasTouch: true });

test('a tap on the page below closes the hamburger menu in WebKit', async ({ page }) => {
	await expectTapBelowClosesMenu(page);
});
