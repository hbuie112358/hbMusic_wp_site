import { defineConfig, devices } from '@playwright/test';

// Browser tests (plan steps 3e, 4c), in two projects run by bin/test: "local" against the
// old-site copy (BASE_URL) and "dev" against the dev site (DEV_BASE_URL). bin/test passes the
// addresses from .env and names the project to run; the version of @playwright/test must equal
// the container image's (bin/check).
const sites = [
	{ name: 'local', baseURL: process.env.BASE_URL },
	{ name: 'dev', baseURL: process.env.DEV_BASE_URL },
];
const configured = sites.filter((site): site is { name: string; baseURL: string } => Boolean(site.baseURL));
if (configured.length === 0) {
	throw new Error('Neither BASE_URL nor DEV_BASE_URL is set; run the tests through bin/test.');
}

export default defineConfig({
	// The tests only read pages, so they can run side by side.
	fullyParallel: true,
	forbidOnly: true,
	retries: 0,
	reporter: [['list']],
	use: {
		trace: 'retain-on-failure',
	},
	projects: configured.map((site) => ({
		name: site.name,
		testDir: `./specs/${site.name}`,
		use: { ...devices['Desktop Chrome'], baseURL: site.baseURL },
	})),
});
