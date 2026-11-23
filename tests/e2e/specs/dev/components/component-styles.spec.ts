import { expect, test, type Page } from '@playwright/test';
import { loadsStylesheet } from '../helpers/stylesheets';
import { TEST_PATHS, pagesUsing } from '../helpers/test-pages';

// Protects how the theme's stylesheets load (plan D29): the component styles come with the blocks
// they style, the form's only to pages with a form. The Song List's table styles are checked with
// the plugin (plugins/song-list/song-list-styles.spec.ts). Each look is checked on every page
// with its component (template plan T10); the call to action's on every page whose template adds
// it, which no page file shows.
const EVERY_PAGE_STYLES = ['hbmusic-site-header', 'hbmusic-site-footer'];
const FORM_STYLES = 'hbmusic-form';
// Contact Form 7's own wrapper; the form comes from a shortcode, so no page file shows its class.
const FORM = '.wpcf7';
const CALL_TO_ACTION = '.site-cta';
const PAGES_WITH_HEADINGS = pagesUsing('wp-block-heading');
const PAGES_WITH_A_HERO = pagesUsing('site-hero');
const PAGES_WITH_FEATURES = pagesUsing('site-features');
const PAGES_WITH_LEAD_AND_FEATURES = pagesUsing('site-lead', 'site-features');

// The panel's colour token as WordPress names it from theme.json, and how a browser reports no
// background colour at all.
const CALL_TO_ACTION_COLOUR_TOKEN = '--wp--custom--call-to-action--background';
const TRANSPARENT = 'rgba(0, 0, 0, 0)';

// Opens every page and calls check on each one that has a call to action; none at all fails.
async function onEveryPageWithCallToAction(page: Page, check: (path: string) => Promise<void>): Promise<void> {
	const checked: string[] = [];
	for (const path of TEST_PATHS) {
		await page.goto(path);
		if ((await page.locator(CALL_TO_ACTION).count()) === 0) {
			continue;
		}
		await check(path);
		checked.push(path);
	}
	expect(checked.length, 'the pages with a call to action').toBeGreaterThan(0);
}

test('the header and footer styles load on every page', async ({ page }) => {
	for (const path of TEST_PATHS) {
		await page.goto(path);
		for (const handle of EVERY_PAGE_STYLES) {
			expect(await loadsStylesheet(page, handle), `${handle} on ${path}`).toBe(true);
		}
	}
});

test("the form's styles load exactly on the pages with a form", async ({ page }) => {
	let pagesWithForm = 0;
	for (const path of TEST_PATHS) {
		await page.goto(path);
		const hasForm = (await page.locator(FORM).count()) > 0;
		pagesWithForm += hasForm ? 1 : 0;
		expect(await loadsStylesheet(page, FORM_STYLES), `${FORM_STYLES} on ${path}, which ${hasForm ? 'has' : 'has no'} form`).toBe(hasForm);
	}
	expect(pagesWithForm, 'the pages with a form').toBeGreaterThan(0);
});

// Loading is not enough: WordPress's own "text-wrap: pretty" on headings once won over the theme's
// rule, so the headings' wrapping is read from the browser.
for (const path of PAGES_WITH_HEADINGS) {
	test(`${path}: the main and section headings wrap in lines of even length`, async ({ page }) => {
		await page.goto(path);
		const wrappings = await page.locator('main :is(h1, h2):is(.wp-block-heading, .wp-block-post-title)').evaluateAll((headings) =>
			headings.map((heading) => `${heading.tagName}: ${getComputedStyle(heading).textWrapStyle}`));
		expect(wrappings.length, 'the headings').toBeGreaterThan(0);
		for (const wrapping of wrappings) {
			expect(wrapping, 'the wrapping').toMatch(/: balance$/);
		}
	});
}

// The bands with their own background carry the grain (texture.css), the hero also its stage
// light, and the grain's image loads; a broken address or a lost layer would leave them flat.
for (const path of PAGES_WITH_A_HERO) {
	test(`${path}: the hero and features bands carry their texture`, async ({ page, request }) => {
		await page.goto(path);
		for (const band of ['.site-hero', '.site-features']) {
			for (const element of await page.locator(band).all()) {
				expect(await element.evaluate((target) => getComputedStyle(target).backgroundImage), `the background of ${band}`).toContain('grain.png');
			}
		}
		const heroLayers = await page.locator('.site-hero').first().evaluate((element) => getComputedStyle(element).backgroundImage);
		expect(heroLayers, 'the hero\'s stage light').toContain('radial-gradient');
		const grainAddress = /url\("([^"]+grain\.png)"\)/.exec(heroLayers)?.[1] ?? '';
		expect((await request.get(grainAddress)).status(), `the grain image at ${grainAddress}`).toBe(200);
	});
}

// The call-to-action panel carries the grain and is the colour its theme.json token names
// (custom.callToAction.background), as the browser resolves the token, set apart from the page behind
// it; whatever colour a site chooses (template plan 1.6a). A token that fails to resolve leaves
// the panel transparent, which never equals a resolved colour; a missing token leaves the probe
// transparent too, so it must hold a colour first.
test("the call-to-action panel is textured, in its token's colour, set apart from the page, on every page with one", async ({ page }) => {
	await onEveryPageWithCallToAction(page, async (path) => {
		const panel = page.locator(CALL_TO_ACTION).first();
		expect(await panel.evaluate((element) => getComputedStyle(element).backgroundImage), `the panel's texture on ${path}`).toContain('grain.png');
		const colours = await panel.evaluate((element, token) => {
			const probe = document.createElement('div');
			probe.style.backgroundColor = `var(${token})`;
			document.body.append(probe);
			const tokenColour = getComputedStyle(probe).backgroundColor;
			probe.remove();
			return { panel: getComputedStyle(element).backgroundColor, token: tokenColour, page: getComputedStyle(document.body).backgroundColor };
		}, CALL_TO_ACTION_COLOUR_TOKEN);
		expect(colours.token, `${CALL_TO_ACTION_COLOUR_TOKEN} as a colour`).not.toBe(TRANSPARENT);
		expect(colours.panel, `the panel's colour on ${path}`).toBe(colours.token);
		expect(colours.panel, `the panel's colour against the page's on ${path}`).not.toBe(colours.page);
	});
});

// A lead is the larger opening statement; it was once smaller than body text without anyone
// noticing. Checked on a computer and a phone, since both sizes grow with the screen.
for (const path of PAGES_WITH_LEAD_AND_FEATURES) {
	for (const width of [1280, 390]) {
		test(`${path} at ${width}px: the lead text is larger than body text`, async ({ page }) => {
			await page.setViewportSize({ width, height: 900 });
			await page.goto(path);
			const fontSize = (selector: string) => page.locator(selector).first().evaluate((element) => Number.parseFloat(getComputedStyle(element).fontSize));
			const lead = await fontSize('.site-lead');
			const body = await fontSize('.site-features p');
			expect(body, 'the body text\'s size').toBeGreaterThan(0);
			expect(lead, `the lead's size against body text of ${body}px`).toBeGreaterThan(body);
		});
	}
}

// The hero's text and picture are centred on each other, as its columns are set in the editor
// (the user chose centring; the theme once overrode it with bottom alignment, which a stray rule
// could bring back), and the picture's cropped bottom is softened instead of a hard line.
for (const path of PAGES_WITH_A_HERO) {
	test(`${path}: in the hero, the text and the picture are centred on each other, and the picture's bottom is softened`, async ({ page }) => {
		await page.setViewportSize({ width: 1280, height: 900 });
		await page.goto(path);
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
		const mask = await page.locator('.site-hero__photo img').first().evaluate((element) => getComputedStyle(element).maskImage);
		expect(mask, 'the picture\'s softened bottom').toContain('linear-gradient');
	});
}

// Points side by side whose texts differ in length (the test pages' do) still have their buttons
// on one line, each below its own text (the user asked for the points to look symmetrical).
for (const path of PAGES_WITH_FEATURES) {
	test(`${path}: the features panel's buttons line up, each below its own text`, async ({ page }) => {
		await page.setViewportSize({ width: 1280, height: 900 });
		await page.goto(path);
		const points = await page.locator('.site-features').first().locator('.wp-block-column').evaluateAll((columns) => columns.map((column) => ({
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
}

// A button in the page's own colours could vanish into the call-to-action panel, so site-cta.css
// gives the panel's button others; its edge must stand out from the panel at 3:1 or more
// (WCAG 2.2, 1.4.11), whatever the colours.
test('the call-to-action button stands out from its panel, on every page with one', async ({ page }) => {
	await onEveryPageWithCallToAction(page, async (path) => {
		const ratio = await page.locator(CALL_TO_ACTION).first().evaluate((panel) => {
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
		expect(ratio, `the contrast between the button and the panel on ${path}`).toBeGreaterThanOrEqual(3);
	});
});
