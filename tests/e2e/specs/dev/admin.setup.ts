import { expect, test as setup } from '@playwright/test';
import { ADMIN_STORAGE_STATE } from './admin-session';

// Logs in as the dev admin once per run, before the browser tests, and saves the login for the
// specs that use the admin screens (plan step 8d). The login goes by the names bin/test passes,
// so the dev site's generated password never appears in a test file.
//
// Once, because WordPress keeps a user's sessions as one stored list and updates it by reading,
// adding and writing back: two logins at the same moment lost one session, and that test found
// itself logged out (2026-11-09). Sent as the request WordPress's login form sends, not typed into
// the login screen, because these tests are about the admin pages, and typing raced with the
// screen's own script, which moves the cursor to the user name field 200 ms after the page opens
// (2026-11-07 and 2026-11-09 on GitHub). The request depends only on the form's field names.

// WordPress answers a successful login by forwarding to the admin; a refused one shows the form again.
const LOGGED_IN_STATUS = 302;
const ADMIN_ADDRESS = /\/wp-admin\/$/;

setup('log in as the dev admin', async ({ request }) => {
	const user = process.env.DEV_ADMIN_USER;
	const password = process.env.DEV_ADMIN_PASSWORD;
	if (!user || !password) {
		throw new Error('DEV_ADMIN_USER and DEV_ADMIN_PASSWORD must be set; run through bin/test.');
	}
	// WordPress refuses a login from a client that has not first accepted its test cookie, which
	// this page sets.
	await request.get('/wp-login.php');
	const response = await request.post('/wp-login.php', {
		form: { log: user, pwd: password, testcookie: '1' },
		maxRedirects: 0,
	});
	expect(response.status(), 'the login was accepted').toBe(LOGGED_IN_STATUS);
	expect(response.headers()['location'] ?? '', 'the login forwards to the admin').toMatch(ADMIN_ADDRESS);
	await request.storageState({ path: ADMIN_STORAGE_STATE });
});
