import AxeBuilder from '@axe-core/playwright';
import { expect, test, type APIRequestContext, type Page } from '@playwright/test';
import { WCAG_TAGS } from '../../helpers/accessibility';
import { ADMIN_STORAGE_STATE, EDITOR_STORAGE_STATE } from '../../helpers/admin-session';

// Protects the Editing Help plugin (handbook H89): the content guide in the admin, for the people
// who edit pages. Its last section lists the site's own templates and ready-made sections, read
// from the active theme; the screen labels the guide names must exist in the real editor, so an
// update that renames one fails here instead of leaving the guide wrong.
const GUIDE_PATH = '/wp-admin/index.php?page=editing-help';
const DASHBOARD_PANEL = '#editinghelp_dashboard_panel';
// The Dashboard's panels in the order they are shown, first column first.
const DASHBOARD_PANELS = '#dashboard-widgets .postbox';

// The panel must be the first one on the Dashboard: placed among WordPress's and other plugins'
// panels, it sat at the bottom of a column, and the user searched the page to find it.
async function expectPanelFirst(page: Page): Promise<void> {
	await page.goto('/wp-admin/');
	const firstPanelId = await page.locator(DASHBOARD_PANELS).first().getAttribute('id');
	expect(firstPanelId, 'the first panel on the Dashboard').toBe(DASHBOARD_PANEL.slice(1));
}
const GUIDE_CONTENT = '#wpbody-content .wrap';
// The page whose editor the label check opens: a test page with one of the theme's templates.
const PAGE_WITH_TEMPLATE = 'about';

// The rows of one of the "Your site" tables, under the third-level heading that names it. The
// level matters: the guide itself has a section with the same name as one of the tables.
async function tableRows(page: Page, heading: string): Promise<string[][]> {
	const table = page
		.getByRole('heading', { level: 3, name: heading, exact: true })
		.locator('xpath=following-sibling::table[1]');
	return table.locator('tbody tr').evaluateAll((rows) =>
		rows.map((row) => Array.from(row.querySelectorAll('td'), (cell) => (cell.textContent ?? '').trim())),
	);
}

async function expectNoAccessibilityErrors(page: Page, region: string): Promise<void> {
	const results = await new AxeBuilder({ page }).include(region).withTags(WCAG_TAGS).analyze();
	expect(results.violations.map((violation) => violation.id), `accessibility errors in ${region}`).toEqual([]);
}

// Public data, so the request needs no login.
async function pageId(request: APIRequestContext, slug: string): Promise<number> {
	const response = await request.get(`/wp-json/wp/v2/pages?slug=${slug}&_fields=id`);
	const [found] = (await response.json()) as { id: number }[];
	if (!found) {
		throw new Error(`the test page ${slug} was not found; run bin/dev-site`);
	}
	return found.id;
}

// WordPress's own client for its API, loaded on every editor screen with the user's login.
type ApiFetch = (options: { path: string; method?: string; data?: Record<string, string> }) => Promise<{ id: number }>;

async function openEditor(page: Page, postId: number): Promise<void> {
	await page.goto(`/wp-admin/post.php?post=${postId}&action=edit`);
	await page.waitForFunction(() => 'wp' in window && 'apiFetch' in (window as unknown as { wp: object }).wp);
	const welcome = page.getByRole('dialog', { name: /welcome/i });
	if (await welcome.isVisible({ timeout: 5000 }).catch(() => false)) {
		await page.keyboard.press('Escape');
	}
}

// A draft page with two earlier versions, made through WordPress's API as the logged-in user.
async function createEditedDraft(page: Page, title: string): Promise<number> {
	return page.evaluate(async (pageTitle) => {
		const { apiFetch } = (window as unknown as { wp: { apiFetch: ApiFetch } }).wp;
		const created = await apiFetch({ path: '/wp/v2/pages', method: 'POST', data: { title: pageTitle, content: 'First version.', status: 'draft' } });
		for (const content of ['Second version.', 'Third version.']) {
			await apiFetch({ path: `/wp/v2/pages/${created.id}`, method: 'POST', data: { content } });
		}
		return created.id;
	}, title);
}

async function deleteDraft(page: Page, draftId: number): Promise<void> {
	await page.evaluate(async (id) => {
		const { apiFetch } = (window as unknown as { wp: { apiFetch: ApiFetch } }).wp;
		await apiFetch({ path: `/wp/v2/pages/${id}?force=true`, method: 'DELETE' });
	}, draftId);
}

// Each label as the guide names it (templates/guide.php), found where the guide says it is.
async function expectEditorLabels(page: Page): Promise<void> {
	const topBar = page.getByRole('region', { name: 'Editor top bar' });
	await test.step('"View", then "Mobile"', async () => {
		await topBar.getByRole('button', { name: 'View', exact: true }).click();
		await expect(page.getByRole('menuitemradio', { name: /^Mobile\b/ })).toBeVisible();
		await page.keyboard.press('Escape');
	});
	await test.step('"Code editor" in the options menu', async () => {
		await topBar.getByRole('button', { name: 'Options', exact: true }).click();
		await expect(page.getByRole('menuitemradio', { name: /^Code editor\b/ })).toBeVisible();
		await page.keyboard.press('Escape');
	});
	await test.step('"Patterns" in the "+" inserter', async () => {
		await topBar.getByRole('button', { name: 'Block Inserter' }).click();
		await expect(page.getByRole('tab', { name: 'Patterns', exact: true })).toBeVisible();
		await page.keyboard.press('Escape');
	});
	await test.step('"Template" and "Revisions" in the page\'s settings', async () => {
		const settings = page.getByRole('region', { name: 'Editor settings' });
		await expect(settings.getByText('Template', { exact: true })).toBeVisible();
		await expect(settings.getByText('Revisions', { exact: true })).toBeVisible();
	});
	await test.step('"SEO title" and "Meta description" in the Yoast SEO box', async () => {
		await expect(page.getByText('SEO title', { exact: true }).first()).toBeAttached();
		await expect(page.getByText('Meta description', { exact: true }).first()).toBeAttached();
	});
}

test.describe('the admin', () => {
	test.use({ storageState: ADMIN_STORAGE_STATE });

	test('finds the guide from the panel at the top of the Dashboard', async ({ page }) => {
		await expectPanelFirst(page);
		const panel = page.locator(DASHBOARD_PANEL);
		await expect(panel.getByRole('heading', { name: 'Editing help' })).toBeVisible();
		await expectNoAccessibilityErrors(page, DASHBOARD_PANEL);
		await panel.getByRole('link', { name: 'Read the guide' }).click();
		await expect(page).toHaveURL(/index\.php\?page=editing-help$/);
		await expect(page.locator(GUIDE_CONTENT).getByRole('heading', { level: 1 })).toHaveText('Editing help');
	});

	test('reads a guide with one main heading, sections below it, and no accessibility errors', async ({ page }) => {
		await page.goto(GUIDE_PATH);
		const content = page.locator(GUIDE_CONTENT);
		await expect(content.getByRole('heading', { level: 1 })).toHaveCount(1);
		await expect(content.getByRole('heading', { level: 2, name: 'Your site' })).toBeVisible();
		// Every h3 sits under an h2: no level is skipped.
		const levels = await content.locator('h1, h2, h3, h4').evaluateAll((headings) => headings.map((heading) => Number(heading.tagName[1])));
		levels.forEach((level, index) => expect(level - (levels[index - 1] ?? 0), `heading ${index + 1} skips no level`).toBeLessThanOrEqual(1));
		await expectNoAccessibilityErrors(page, GUIDE_CONTENT);
	});

	// The plugin's neutral example, which this site's theme replaces with one of its own links.
	test("gives the site's own example of good link text, not the plugin's neutral one", async ({ page }) => {
		await page.goto(GUIDE_PATH);
		const links = page.locator(GUIDE_CONTENT).getByRole('heading', { level: 2, name: 'Links' }).locator('xpath=following-sibling::p[1]');
		await expect(links, 'an example in quotation marks').toHaveText(/"[^"]+"/);
		await expect(links).not.toContainText('See our prices');
	});

	test("lists the site's page templates, the default first, each with what it does", async ({ page }) => {
		await page.goto(GUIDE_PATH);
		const rows = await tableRows(page, 'Page templates');
		// The default's name, then the theme's own templates by name (theme.json customTemplates).
		expect(rows.map(([name]) => name)).toEqual([
			'Pages',
			'Page No Title',
			'Page No Title with call to action',
			'Page with call to action',
		]);
		rows.forEach(([name, description]) => expect(description, `the line for ${name}`).not.toBe(''));
	});

	test("lists only the theme's own ready-made sections that the editor offers", async ({ page }) => {
		await page.goto(GUIDE_PATH);
		const rows = await tableRows(page, 'Ready-made sections');
		// The theme's patterns/ folder holds the carousel and the logo; the logo is hidden from the
		// inserter. The parent theme's many patterns are not this site's.
		expect(rows.map(([name]) => name)).toEqual(['Video carousel']);
		expect(rows[0]?.[1], 'the description it carries for the editor').toBeTruthy();
	});
});

test.describe('an Editor', () => {
	test.use({ storageState: EDITOR_STORAGE_STATE });

	// On screen without scrolling, as a customer sees it. Not checked for the admin: WordPress shows
	// administrators a large "Welcome to WordPress" banner above all panels until they dismiss it,
	// and the dev site's admin is new on every build.
	test('sees the panel at the top of the Dashboard, without scrolling, and can open the guide', async ({ page }) => {
		await expectPanelFirst(page);
		await expect(page.locator(DASHBOARD_PANEL), 'the panel on the first screen').toBeInViewport();
		const response = await page.goto(GUIDE_PATH);
		expect(response?.status(), 'the guide page').toBe(200);
		await expect(page.locator(GUIDE_CONTENT).getByRole('heading', { level: 1 })).toHaveText('Editing help');
	});

	// Works on a draft page of its own, uniquely named, which it deletes afterwards: WordPress shows
	// "Revisions" only for a page that has been edited, and editing a shared test page would change
	// what other tests see. Closing the editor's welcome guide is remembered for the dev Editor
	// only, whom no other test uses.
	test('finds every screen label the guide names in the real editor', async ({ page, request }) => {
		await openEditor(page, await pageId(request, PAGE_WITH_TEMPLATE));
		const draftId = await createEditedDraft(page, `Editing help test ${test.info().testId} ${Date.now()}`);
		try {
			await openEditor(page, draftId);
			await expectEditorLabels(page);
		} finally {
			await deleteDraft(page, draftId);
		}
	});
});
