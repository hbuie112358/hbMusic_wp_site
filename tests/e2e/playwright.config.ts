import { defineConfig, devices } from '@playwright/test';

// Browser tests against the dev site (plan step 4c). bin/test passes its address from .env; the
// version of @playwright/test must equal the container image's (bin/check).
const baseURL = process.env.DEV_BASE_URL;
if (!baseURL) {
	throw new Error('DEV_BASE_URL is not set; run the tests through bin/test.');
}

// The test folders another site leaves out (template plan 1.6c): bin/test names them in
// TESTS_LEFT_OUT, comma-separated and relative to specs/dev/ (such as "site,plugins/song-list"),
// and logs each, so none is skipped silently. Only letters, digits, dashes and slashes are
// accepted, so a folder name never becomes a wider pattern.
const FOLDER_NAME = /^[a-z0-9-]+(\/[a-z0-9-]+)*$/;
const foldersLeftOut = (process.env.TESTS_LEFT_OUT ?? '').split(',').filter((folder) => folder !== '');
for (const folder of foldersLeftOut) {
	if (!FOLDER_NAME.test(folder)) {
		throw new Error(`TESTS_LEFT_OUT names "${folder}", not a test folder such as plugins/song-list`);
	}
}
const testIgnore = foldersLeftOut.map((folder) => new RegExp(`/specs/dev/${folder}/`));

export default defineConfig({
	testDir: './specs/dev',
	testIgnore,
	// Almost every test only reads pages, so they can run side by side. The Song List's admin
	// tests add songs, one at a time, and remove them again; the visitor tests tolerate that.
	fullyParallel: true,
	forbidOnly: true,
	retries: 0,
	reporter: [['list']],
	use: {
		...devices['Desktop Chrome'],
		baseURL,
		trace: 'retain-on-failure',
	},
	projects: [
		// Logs in as the dev admin and the dev Editor once each and saves the logins (plan step
		// 8d), so the specs that use the admin never log in at the same moment, which made
		// WordPress lose a session.
		{ name: 'logins', testMatch: /(admin|editor)\.setup\.ts$/ },
		// Every spec; only those that ask for a saved login (test.use storageState) are logged in,
		// so the visitor tests see what a visitor sees.
		{ name: 'dev', testMatch: /\.spec\.ts$/, dependencies: ['logins'] },
	],
});
