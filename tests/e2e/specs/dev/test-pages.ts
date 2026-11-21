import { readFileSync } from 'node:fs';

// The paths of the test pages bin/dev-site creates, shared by the specs that check every page:
// read from site.json's testPages (mounted by bin/test, template plan 1.2g), the front page as "/"
// and every other page at its address. Not read from the site's menu: a page missing from the menu
// must still fail.
type TestPage = { address: string; isFrontPage?: boolean };

function testPaths(): string[] {
	const settingsFile = process.env.SITE_SETTINGS;
	if (!settingsFile) {
		throw new Error('SITE_SETTINGS is not set; run the tests through bin/test.');
	}
	const pages = (JSON.parse(readFileSync(settingsFile, 'utf8')) as { testPages?: TestPage[] }).testPages;
	if (!Array.isArray(pages) || pages.length === 0) {
		throw new Error(`${settingsFile} lists no testPages`);
	}
	return pages.map((page) => (page.isFrontPage === true ? '/' : `/${page.address}/`));
}

export const TEST_PATHS = testPaths();
