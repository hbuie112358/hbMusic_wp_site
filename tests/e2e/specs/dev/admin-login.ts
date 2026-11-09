import { type Page } from '@playwright/test';

// Logs in as the dev admin, shared by the specs that use the admin screens. The login goes by the
// names bin/test passes, so the dev site's generated password never appears in a test file.
export async function logIn(page: Page): Promise<void> {
	const user = process.env.DEV_ADMIN_USER;
	const password = process.env.DEV_ADMIN_PASSWORD;
	if (!user || !password) {
		throw new Error('DEV_ADMIN_USER and DEV_ADMIN_PASSWORD must be set; run through bin/test.');
	}
	await page.goto('/wp-login.php');
	await page.locator('#user_login').fill(user);
	await page.locator('#user_pass').fill(password);
	await page.locator('#wp-submit').click();
	await page.waitForURL(/\/wp-admin\//);
}
