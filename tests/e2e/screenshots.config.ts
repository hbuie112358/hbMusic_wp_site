import { defineConfig, devices } from '@playwright/test';

// The before/after screenshots of bin/screenshots (plan D29), apart from the tests: bin/test never
// runs them. Playwright's own comparison checks each page against the baseline pixel by pixel; the
// baseline, the newest screenshots and the marked differences live in SCREENSHOTS_DIR.
const baseURL = process.env.DEV_BASE_URL;
const screenshotsDir = process.env.SCREENSHOTS_DIR;
if (!baseURL || !screenshotsDir) {
	throw new Error('DEV_BASE_URL or SCREENSHOTS_DIR is not set; run the screenshots through bin/screenshots.');
}

export default defineConfig({
	testDir: './screenshots',
	fullyParallel: true,
	forbidOnly: true,
	retries: 0,
	reporter: [['list']],
	outputDir: `${screenshotsDir}/differences`,
	snapshotPathTemplate: `${screenshotsDir}/baseline/{arg}{ext}`,
	expect: {
		// Exact: within one container minutes apart, any changed pixel is a real change. Both limits
		// are needed: maxDiffPixels counts pixels, threshold is how far a pixel's colour may move
		// before it counts at all (Playwright's default 0.2 hid a subtle button gradient and glow).
		toMatchSnapshot: { maxDiffPixels: 0, threshold: 0 },
	},
	use: {
		...devices['Desktop Chrome'],
		baseURL,
	},
});
