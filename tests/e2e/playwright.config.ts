import { defineConfig, devices } from '@playwright/test';

// Browser tests against the dev site (plan step 4c). bin/test passes its address from .env; the
// version of @playwright/test must equal the container image's (bin/check).
const baseURL = process.env.DEV_BASE_URL;
if (!baseURL) {
	throw new Error('DEV_BASE_URL is not set; run the tests through bin/test.');
}

export default defineConfig({
	testDir: './specs/dev',
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
});
