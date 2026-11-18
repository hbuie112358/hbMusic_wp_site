import { test } from '@playwright/test';
import { expectTapOnPlainPageClosesMenu } from './hamburger-menu';

// The hamburger menu closes when plain page content beside it is tapped, in WebKit, Safari's engine
// (plan 9t-5): Safari moves no focus there, so WordPress alone left the menu open on iPhones, and
// the theme's menu-close-outside.js closes it. Checked here, not assumed from Chromium.
test.use({ browserName: 'webkit', hasTouch: true });

test('a tap on plain page content beside it closes the hamburger menu in WebKit', async ({ page }) => {
	await expectTapOnPlainPageClosesMenu(page);
});
