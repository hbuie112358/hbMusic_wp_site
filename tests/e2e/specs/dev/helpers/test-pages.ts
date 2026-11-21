import { readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';

// The paths of every page bin/dev-site creates, shared by the specs that check every page.
//
// The site's test pages: read from site.json's testPages (mounted by bin/test, template plan
// 1.2g), the front page as "/" and every other page at its address. Not read from the site's
// menu: a page missing from the menu must still fail.
//
// Then the components' example pages (template plan T10), one per file in components/pages/,
// at the file's name, as bin/dev-site creates them; so the checks of every page (headers, policy,
// accessibility, links) also see each component on neutral content. The scripts name this folder
// in tools/site-settings.sh (COMPONENT_EXAMPLES_DIR), which the test container cannot read; a
// difference fails loudly, as a page that is not there or a folder that is not found.
type TestPage = { address: string; isFrontPage?: boolean };

const COMPONENT_EXAMPLES_FOLDER = path.join(__dirname, '..', 'components', 'pages');
const EXAMPLE_PAGE_FILE = /\.html$/;

function sitePagePaths(): string[] {
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

function componentExamplePaths(): string[] {
	return readdirSync(COMPONENT_EXAMPLES_FOLDER)
		.filter((file) => EXAMPLE_PAGE_FILE.test(file))
		.sort()
		.map((file) => `/${file.replace(EXAMPLE_PAGE_FILE, '')}/`);
}

export const TEST_PATHS = [...sitePagePaths(), ...componentExamplePaths()];
