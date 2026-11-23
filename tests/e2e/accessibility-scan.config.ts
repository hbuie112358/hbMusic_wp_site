import { defineConfig, devices } from '@playwright/test';

// The accessibility scan of bin/accessibility-scan (handbook chapter 12, 7.1 and 7.4; template plan
// 1.5d-3), apart from the tests: bin/test never runs it. It scans a real site's published pages,
// the ones bin/site-check found answering, so the content people edit on live is held to the same
// rules as the dev site's test pages.
const pages = process.env.SCAN_PAGES;
if (!pages) {
	throw new Error('SCAN_PAGES is not set; run the scan through bin/accessibility-scan.');
}

// The login of a site behind a site-wide password (staging), the page check's own variables.
const user = process.env.SITE_CHECK_USER;
const password = process.env.SITE_CHECK_PASSWORD;

export default defineConfig({
	testDir: './accessibility-scan',
	fullyParallel: true,
	forbidOnly: true,
	// A scan reports what the pages hold; trying again could only hide a page that answers badly.
	retries: 0,
	reporter: [['list']],
	outputDir: '/tmp/accessibility-scan-results',
	use: {
		...devices['Desktop Chrome'],
		...(user && password ? { httpCredentials: { username: user, password } } : {}),
	},
});
