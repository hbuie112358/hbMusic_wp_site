import { readFileSync } from 'node:fs';

// The site's facts the specs need from site.json (template plan T7), which bin/test mounts and
// names in SITE_SETTINGS: the child theme's folder and the test pages. Read once, when a spec
// first imports this file; a missing or broken field fails at once, naming the file, so no test
// runs against a site it cannot name.
export type TestPage = { title: string; address: string; isFrontPage?: boolean; isInMenu?: boolean };
type SiteSettings = { theme: string; testPages: TestPage[] };

function readSiteSettings(): SiteSettings {
	const settingsFile = process.env.SITE_SETTINGS;
	if (!settingsFile) {
		throw new Error('SITE_SETTINGS is not set; run the tests through bin/test.');
	}
	const settings = JSON.parse(readFileSync(settingsFile, 'utf8')) as Partial<SiteSettings>;
	if (typeof settings.theme !== 'string' || settings.theme === '') {
		throw new Error(`${settingsFile} names no theme`);
	}
	if (!Array.isArray(settings.testPages) || settings.testPages.length === 0) {
		throw new Error(`${settingsFile} lists no testPages`);
	}
	return { theme: settings.theme, testPages: settings.testPages };
}

export const SITE_SETTINGS = readSiteSettings();
