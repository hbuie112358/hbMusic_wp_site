import { readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { SITE_SETTINGS, type TestPage } from './site-settings';

// The paths of every page bin/dev-site creates, shared by the specs that check every page, and
// the pages that use a given component, for the component tests (template plan T10).
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
type PageSource = { path: string; file: string; isExample: boolean };

const COMPONENT_EXAMPLES_FOLDER = path.join(__dirname, '..', 'components', 'pages');
const EXAMPLE_PAGE_FILE = /\.html$/;

function siteTestPages(): TestPage[] {
	return SITE_SETTINGS.testPages;
}

function sitePagePath(page: TestPage): string {
	return page.isFrontPage === true ? '/' : `/${page.address}/`;
}

function exampleFiles(): string[] {
	return readdirSync(COMPONENT_EXAMPLES_FOLDER).filter((file) => EXAMPLE_PAGE_FILE.test(file)).sort();
}

function examplePagePath(file: string): string {
	return `/${file.replace(EXAMPLE_PAGE_FILE, '')}/`;
}

// The example pages alone: a test of an arrangement (two carousels, two panels in a row) checks
// it wherever a page has it, and requires it on these, which are built to show it.
export const EXAMPLE_PATHS = exampleFiles().map(examplePagePath);
export const TEST_PATHS = [...siteTestPages().map(sitePagePath), ...EXAMPLE_PATHS];
// The site's pages in its menu, with the titles the menu shows (bin/dev-site leaves out a page
// site.json marks isInMenu false).
export const MENU_PAGES = siteTestPages()
	.filter((page) => page.isInMenu !== false)
	.map((page) => ({ path: sitePagePath(page), title: page.title }));

// The site's page files are in tests/dev-content/, which bin/test lends read-only (DEV_CONTENT);
// read only when a component test asks, so the specs of every page need only site.json.
function devContentFolder(): string {
	const folder = process.env.DEV_CONTENT;
	if (!folder) {
		throw new Error('DEV_CONTENT is not set; run the tests through bin/test.');
	}
	return folder;
}

function pageSources(): PageSource[] {
	const folder = devContentFolder();
	return [
		...siteTestPages().map((page) => ({ path: sitePagePath(page), file: path.join(folder, `${page.address}.html`), isExample: false })),
		...exampleFiles().map((file) => ({ path: examplePagePath(file), file: path.join(COMPONENT_EXAMPLES_FOLDER, file), isExample: true })),
	];
}

// The site's own test pages (not the example pages) whose content holds the text, such as a
// plugin's shortcode, and those whose content does not: so a test of something a page's content
// brings finds that page, and a page without it, on any site, without naming either. Each list
// may be empty; the test decides what it needs.
export function sitePagesSplitBy(text: string): { containing: string[]; notContaining: string[] } {
	const sources = pageSources().filter((source) => !source.isExample);
	const holdsText = (source: PageSource) => readFileSync(source.file, 'utf8').includes(text);
	return {
		containing: sources.filter(holdsText).map((source) => source.path),
		notContaining: sources.filter((source) => !holdsText(source)).map((source) => source.path),
	};
}

// Whether the page's content has an element with every one of the classes (each a whole class
// name, as the editor writes it in class="…"); not necessarily the same element.
function usesClasses(content: string, classNames: readonly string[]): boolean {
	const written = new Set(Array.from(content.matchAll(/\bclass="([^"]*)"/g), ([, list]) => (list ?? '').split(/\s+/)).flat());
	return classNames.every((className) => written.has(className));
}

// The pages whose content uses the component's classes: the example page first, then every
// site page that uses them, so a component test runs on neutral content and on the site's own.
// Read from the pages' files, since Playwright needs the list before any page is asked for. A
// component the example pages do not show fails at once rather than leaving its tests to run
// only where a site happens to use it; the example pages are the baseline that always exists.
// Not for the parts the page templates add (the header, footer, call to action): no page file
// shows them.
export function pagesUsing(...classNames: string[]): string[] {
	const matching = pageSources().filter((source) => usesClasses(readFileSync(source.file, 'utf8'), classNames));
	if (!matching.some((source) => source.isExample)) {
		throw new Error(`no component example page in ${COMPONENT_EXAMPLES_FOLDER} uses ${classNames.join(' and ')}`);
	}
	return [...matching.filter((source) => source.isExample), ...matching.filter((source) => !source.isExample)].map((source) => source.path);
}
