import { expect, test } from '@playwright/test';
import { ADMIN_STORAGE_STATE } from './admin-session';

// Protects what the Site Hardening plugin does in the admin (plan step 8a, D26): Application
// Passwords are off, so no program can log in to the REST API around two-factor login
// (docs/SITE_CHECKLIST.md 4.7). The headers are checked on every page in theme.spec.ts; XML-RPC,
// the X-Pingback header, the version comments and the PHP version header in
// tests/scenario/dev-site-hardening.sh.
// WordPress's own id for the section on the profile page (wp-admin/user-edit.php, 7.1).
const APPLICATION_PASSWORDS_SECTION = '#application-passwords-section';

// Starts with the dev admin's login, saved once per run by admin.setup.ts.
test.use({ storageState: ADMIN_STORAGE_STATE });

test('the profile page offers no Application Passwords', async ({ page }) => {
	await page.goto('/wp-admin/profile.php');
	// The page itself must have loaded, or the missing section would prove nothing.
	await expect(page.locator('#your-profile'), 'the profile form').toBeVisible();
	await expect(page.locator(APPLICATION_PASSWORDS_SECTION), 'the Application Passwords section').toHaveCount(0);
});
