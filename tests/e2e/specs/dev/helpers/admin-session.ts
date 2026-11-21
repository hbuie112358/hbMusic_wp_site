import path from 'node:path';
import { expect, type APIRequestContext } from '@playwright/test';

// Where the login setups save the dev site's logins, for the specs that use the admin screens
// (plan step 8d): they start from one with test.use({ storageState: ... }). Outside specs/, and
// ignored by git (.gitignore), since they hold session cookies.
const AUTH_FOLDER = path.join(__dirname, '..', '..', '..', '.auth');
export const ADMIN_STORAGE_STATE = path.join(AUTH_FOLDER, 'admin.json');
// The dev Editor, the role a customer gets (handbook chapter 6).
export const EDITOR_STORAGE_STATE = path.join(AUTH_FOLDER, 'editor.json');

// WordPress answers a successful login by forwarding to the admin; a refused one shows the form again.
const LOGGED_IN_STATUS = 302;
const ADMIN_ADDRESS = /\/wp-admin\/$/;

// Logs in once and saves the login (admin.setup.ts, editor.setup.ts). The login goes by the
// names bin/test passes, so the dev site's generated passwords never appear in a test file.
//
// Once per user and run, because WordPress keeps a user's sessions as one stored list and updates
// it by reading, adding and writing back: two logins of the same user at the same moment lost one
// session, and that test found itself logged out (2026-11-09). Sent as the request WordPress's
// login form sends, not typed into the login screen, because these tests are about the admin
// pages, and typing raced with the screen's own script, which moves the cursor to the user name
// field 200 ms after the page opens (2026-11-07 and 2026-11-09 on GitHub). The request depends
// only on the form's field names.
export async function logInAndSave(
	request: APIRequestContext,
	userSetting: string,
	passwordSetting: string,
	storageState: string,
): Promise<void> {
	const user = process.env[userSetting];
	const password = process.env[passwordSetting];
	if (!user || !password) {
		throw new Error(`${userSetting} and ${passwordSetting} must be set; run through bin/test.`);
	}
	// WordPress refuses a login from a client that has not first accepted its test cookie, which
	// this page sets.
	await request.get('/wp-login.php');
	const response = await request.post('/wp-login.php', {
		form: { log: user, pwd: password, testcookie: '1' },
		maxRedirects: 0,
	});
	expect(response.status(), `the login of ${userSetting} was accepted`).toBe(LOGGED_IN_STATUS);
	expect(response.headers()['location'] ?? '', 'the login forwards to the admin').toMatch(ADMIN_ADDRESS);
	await request.storageState({ path: storageState });
}
