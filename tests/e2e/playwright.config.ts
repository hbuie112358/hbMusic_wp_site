import { defineConfig, devices } from '@playwright/test';

// Browser tests against the local copy (plan step 3e). bin/test passes the site's address
// from .env; the version of @playwright/test must equal the container image's (bin/test).
const baseURL = process.env.BASE_URL;
if (!baseURL) {
	throw new Error('BASE_URL is not set; run the tests through bin/test.');
}

export default defineConfig({
	testDir: './specs',
	// The tests only read pages, so they can run side by side.
	fullyParallel: true,
	forbidOnly: true,
	retries: 0,
	reporter: [['list']],
	use: {
		baseURL,
		trace: 'retain-on-failure',
	},
	projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
