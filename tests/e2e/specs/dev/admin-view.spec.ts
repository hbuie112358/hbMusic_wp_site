import { expect, test } from '@playwright/test';
import { ADMIN_STORAGE_STATE } from './admin-session';
import { answerOutsideServices, recordCspViolations, recordedCspViolations } from './csp-violations';
import { TEST_PATHS } from './test-pages';

// Protects what a logged-in admin sees on the site's pages (plan step 8e): WordPress then adds its
// toolbar, with an embedded icon font and, if avatars are on, a picture from Gravatar, which the
// visitor tests never see. On staging the policy blocked both (2026-11-09). The visitor's view of
// the same pages is checked in theme.spec.ts.
// WordPress's toolbar on the site's pages, shown to logged-in users.
const ADMIN_TOOLBAR = '#wpadminbar';

test.use({ storageState: ADMIN_STORAGE_STATE });

for (const path of TEST_PATHS) {
	test(`the page ${path}, viewed by the logged-in admin, causes no Content-Security-Policy violation`, async ({ page }) => {
		await answerOutsideServices(page);
		await recordCspViolations(page);
		await page.goto(path, { waitUntil: 'networkidle' });
		// The toolbar must be there, or the check would only repeat the visitor's view.
		await expect(page.locator(ADMIN_TOOLBAR), 'the admin toolbar').toBeVisible();
		expect(await recordedCspViolations(page), 'violations reported by the browser').toEqual([]);
	});
}
