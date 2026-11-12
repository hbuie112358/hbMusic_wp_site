import { expect, test, type Page } from '@playwright/test';
import { TEST_PATHS } from './test-pages';

// Protects how the site's stylesheets load (plan D29): the theme's component styles come with the
// blocks they style, the form's only to pages with a form, and the Song List plugin brings its
// table's styles itself, only where the song list appears. WordPress inlines small stylesheets,
// so a stylesheet shows as a <style> or <link> whose id starts with its handle.
const SONG_LIST_PATH = '/songlist/';
const FORM_PATH = '/book/';
const EVERY_PAGE_STYLES = ['hbmusic-site-header', 'hbmusic-site-footer'];
const FORM_STYLES = 'hbmusic-form';
const SONG_TABLE_STYLES = 'songlist-song-list';

async function loadsStylesheet(page: Page, handle: string): Promise<boolean> {
	return (await page.locator(`style[id^="${handle}-"], link[id^="${handle}-"]`).count()) > 0;
}

test('the header and footer styles load on every page', async ({ page }) => {
	for (const path of TEST_PATHS) {
		await page.goto(path);
		for (const handle of EVERY_PAGE_STYLES) {
			expect(await loadsStylesheet(page, handle), `${handle} on ${path}`).toBe(true);
		}
	}
});

test("the form's styles load only on the page with a form", async ({ page }) => {
	for (const path of TEST_PATHS) {
		await page.goto(path);
		expect(await loadsStylesheet(page, FORM_STYLES), `${FORM_STYLES} on ${path}`).toBe(path === FORM_PATH);
	}
});

test("the song table's styles load only where the song list appears", async ({ page }) => {
	for (const path of TEST_PATHS) {
		await page.goto(path);
		expect(await loadsStylesheet(page, SONG_TABLE_STYLES), `${SONG_TABLE_STYLES} on ${path}`).toBe(path === SONG_LIST_PATH);
	}
});

// Loading is not enough: WordPress's own "text-wrap: pretty" on headings once won over the theme's
// rule, so the headings' wrapping is read from the browser.
test('headings wrap in lines of even length', async ({ page }) => {
	await page.goto('/');
	for (const selector of ['h1.wp-block-heading', 'h2.wp-block-heading']) {
		const wrapping = await page.locator(selector).first().evaluate((heading) => getComputedStyle(heading).textWrapStyle);
		expect(wrapping, `the wrapping of ${selector}`).toBe('balance');
	}
});

// The bands with their own background carry the grain (texture.css), the hero also its stage
// light, and the grain's image loads; a broken address or a lost layer would leave them flat.
test('the hero, features and call-to-action bands carry their texture', async ({ page, request }) => {
	await page.goto('/');
	for (const band of ['.site-hero', '.site-features', '.site-cta']) {
		const layers = await page.locator(band).first().evaluate((element) => getComputedStyle(element).backgroundImage);
		expect(layers, `the background of ${band}`).toContain('grain.png');
	}
	const heroLayers = await page.locator('.site-hero').evaluate((element) => getComputedStyle(element).backgroundImage);
	expect(heroLayers, 'the hero\'s stage light').toContain('radial-gradient');
	// The call-to-action panel's even green (a colour mixed in theme.json): green outweighs red and
	// blue, and it is not black, which is what a colour that fails to resolve would leave.
	const ctaColour = await page.locator('.site-cta').first().evaluate((element) => getComputedStyle(element).backgroundColor);
	const channels = (ctaColour.match(/[\d.]+/g) ?? []).slice(0, 3).map(Number);
	const scale = Math.max(...channels) <= 1 ? 255 : 1;
	const [red = 0, green = 0, blue = 0] = channels.map((channel) => channel * scale);
	expect(green, `the call-to-action panel's green in ${ctaColour}`).toBeGreaterThan(Math.max(red, blue));
	expect(green, `the call-to-action panel's green in ${ctaColour}`).toBeGreaterThan(40);
	const grainAddress = /url\("([^"]+grain\.png)"\)/.exec(heroLayers)?.[1] ?? '';
	expect((await request.get(grainAddress)).status(), `the grain image at ${grainAddress}`).toBe(200);
});

// Loading is not enough: the plugin's selectors must still match its own markup.
test("the song table's styles apply to the table", async ({ page }) => {
	await page.goto(SONG_LIST_PATH);
	const heading = page.locator('.wp-block-songlist-song-list th').first();
	await expect(heading, 'a column heading').toBeVisible();
	expect(await heading.evaluate((cell) => getComputedStyle(cell).borderBottomWidth), 'the line under the headings').toBe('2px');
});

// A lead is the larger opening statement; it was once smaller than body text without anyone
// noticing. Checked on a computer and a phone, since both sizes grow with the screen.
for (const width of [1280, 390]) {
	test(`at ${width}px the lead text is larger than body text`, async ({ page }) => {
		await page.setViewportSize({ width, height: 900 });
		await page.goto('/');
		const fontSize = (selector: string) => page.locator(selector).first().evaluate((element) => Number.parseFloat(getComputedStyle(element).fontSize));
		const lead = await fontSize('.site-lead');
		const body = await fontSize('.site-features p');
		expect(body, 'the body text\'s size').toBeGreaterThan(0);
		expect(lead, `the lead's size against body text of ${body}px`).toBeGreaterThan(body);
	});
}

// The hero's text and picture are centred on each other, as its columns are set in the editor
// (the user chose centring; the theme once overrode it with bottom alignment, which a stray rule
// could bring back), and the picture's cropped bottom is softened instead of a hard line.
test('in the hero, the text and the picture are centred on each other, and the picture\'s bottom is softened', async ({ page }) => {
	await page.setViewportSize({ width: 1280, height: 900 });
	await page.goto('/');
	const middles = await page.evaluate(() => {
		const middle = (selector: string) => {
			const box = document.querySelector(selector)?.getBoundingClientRect();
			return box === undefined ? Number.NaN : box.top + box.height / 2;
		};
		return { text: middle('.site-hero .wp-block-column:has(.wp-block-heading)'), picture: middle('.site-hero__photo img') };
	});
	expect(middles.picture, 'the picture\'s middle').not.toBeNaN();
	expect(middles.text, 'the text\'s middle').not.toBeNaN();
	expect(Math.abs(middles.text - middles.picture), 'the difference between the text\'s and the picture\'s middles').toBeLessThanOrEqual(1);
	const mask = await page.locator('.site-hero__photo img').evaluate((element) => getComputedStyle(element).maskImage);
	expect(mask, 'the picture\'s softened bottom').toContain('linear-gradient');
});

// Points side by side whose texts differ in length (the test page's do) still have their buttons
// on one line, each below its own text (the user asked for the points to look symmetrical).
test('the features panel\'s buttons line up, each below its own text', async ({ page }) => {
	await page.setViewportSize({ width: 1280, height: 900 });
	await page.goto('/');
	const points = await page.locator('.site-features .wp-block-column').evaluateAll((columns) => columns.map((column) => ({
		textBottom: column.querySelector('p')?.getBoundingClientRect().bottom ?? Number.NaN,
		buttonTop: column.querySelector('.wp-block-button__link')?.getBoundingClientRect().top ?? Number.NaN,
	})));
	expect(points.length, 'the points with buttons').toBeGreaterThanOrEqual(2);
	const tops = points.map((point) => Math.round(point.buttonTop));
	expect(new Set(tops).size, `the buttons' tops ${tops.join(', ')}`).toBe(1);
	expect(new Set(points.map((point) => Math.round(point.textBottom))).size, 'the texts\' ends, which must differ for this test to mean anything').toBeGreaterThan(1);
	for (const point of points) {
		expect(point.buttonTop, 'a button below its text').toBeGreaterThan(point.textBottom);
	}
});

// On the green call-to-action panel the page's green button would vanish, so it inverts to black;
// its edge must stand out from the panel at 3:1 or more (WCAG 2.2, 1.4.11).
test('the call-to-action button stands out from its panel', async ({ page }) => {
	await page.goto('/about/');
	const ratio = await page.locator('.site-cta').first().evaluate((panel) => {
		const channels = (colour: string) => {
			const values = (colour.match(/[\d.]+/g) ?? []).slice(0, 3).map(Number);
			const scale = Math.max(...values) <= 1 ? 255 : 1;
			return values.map((value) => value * scale);
		};
		const luminance = (colour: string) => {
			const [red = 0, green = 0, blue = 0] = channels(colour).map((value) => {
				const share = value / 255;
				return share <= 0.04045 ? share / 12.92 : ((share + 0.055) / 1.055) ** 2.4;
			});
			return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
		};
		const button = panel.querySelector('.wp-block-button__link');
		if (!button) {
			return Number.NaN;
		}
		const [lighter, darker] = [luminance(getComputedStyle(panel).backgroundColor), luminance(getComputedStyle(button).backgroundColor)].sort((a, b) => b - a);
		return ((lighter ?? 0) + 0.05) / ((darker ?? 0) + 0.05);
	});
	expect(ratio, 'the contrast between the button and the panel').toBeGreaterThanOrEqual(3);
});
