import { expect, test } from '@playwright/test';

// Protects the click-to-load videos (includes/video-facade.php, assets/js/video-facade.js, plan 9v;
// handbook 12, 8.5): a page with videos loads nothing from YouTube until the visitor plays one, each
// video showing its picture from the site itself and a play button named after the video; playing
// it, by click or Enter, puts YouTube's privacy-enhanced player in its place, set to play and ready
// for the video script's commands, holding the keyboard focus after Enter; without JavaScript the picture is a
// link to the video on YouTube. Replaces the earlier check that every player was lazy-loaded.
const PAGES_WITH_VIDEOS = ['/', '/music/'];
const MUSIC_PATH = '/music/';
const FIRST_VIDEO = 'Sample video';
const FIRST_VIDEO_ID = 'sampleVid01';
const FACADE = 'main a.video-facade';
const YOUTUBE_REQUEST = /(^|\.)(youtube\.com|youtube-nocookie\.com|ytimg\.com|googlevideo\.com)$/;
const PLAYER_ADDRESS = /^https:\/\/www\.youtube-nocookie\.com\/embed\//;
const WATCH_ADDRESS = `https://www.youtube.com/watch?v=${FIRST_VIDEO_ID}`;
const STAND_IN_PLAYER = '<!doctype html><title>Stand-in player</title>';

for (const path of PAGES_WITH_VIDEOS) {
	test(`${path} loads nothing from YouTube before a video is played, its pictures from the site`, async ({ page, baseURL }) => {
		const youtubeRequests: string[] = [];
		page.on('request', (request) => {
			if (YOUTUBE_REQUEST.test(new URL(request.url()).hostname)) {
				youtubeRequests.push(request.url());
			}
		});
		await page.goto(path, { waitUntil: 'networkidle' });
		await page.evaluate(() => window.scrollTo(0, document.documentElement.scrollHeight));
		await page.waitForLoadState('networkidle');

		const facades = await page.locator(FACADE).evaluateAll((links) => links.map((link) => ({
			name: link.getAttribute('aria-label') ?? '',
			href: link.getAttribute('href') ?? '',
			picture: link.querySelector('img')?.src ?? '',
		})));
		expect(facades.length, `the videos on ${path}`).toBeGreaterThanOrEqual(1);
		for (const facade of facades) {
			expect(facade.name, 'the play button\'s name').toMatch(/^Play video: \S/);
			expect(facade.href, 'the link without JavaScript').toMatch(/^https:\/\/www\.youtube\.com\/watch\?v=[A-Za-z0-9_-]{11}$/);
			expect(new URL(facade.picture).origin, `the picture of "${facade.name}"`).toBe(new URL(baseURL ?? '').origin);
		}
		await expect(page.locator('main iframe'), 'players before any video is played').toHaveCount(0);
		expect(youtubeRequests, 'requests to YouTube before any video is played').toEqual([]);
	});
}

// Each picture keeps the video's 16:9 box, inside WordPress's video block (Music) and on its own
// (Home): relying on the block's own spacer once stretched it to the whole carousel.
const WIDESCREEN = 16 / 9;
const SHAPE_TOLERANCE = 0.02;
for (const path of PAGES_WITH_VIDEOS) {
	test(`every video's picture on ${path} keeps a 16:9 box`, async ({ page }) => {
		await page.setViewportSize({ width: 1280, height: 900 });
		await page.goto(path);
		const shapes = await page.locator(FACADE).evaluateAll((links) => links.map((link) => {
			const box = link.getBoundingClientRect();
			return { name: link.getAttribute('aria-label') ?? '', ratio: box.width / box.height };
		}));
		for (const shape of shapes) {
			expect(Math.abs(shape.ratio - WIDESCREEN), `the shape of "${shape.name}"`).toBeLessThanOrEqual(SHAPE_TOLERANCE);
		}
	});
}

for (const [way, play] of [
	['a click', async (facade: import('@playwright/test').Locator) => facade.click()],
	['Enter', async (facade: import('@playwright/test').Locator) => { await facade.focus(); await facade.press('Enter'); }],
] as const) {
	test(`${way} on a video's picture plays it in YouTube's privacy-enhanced player`, async ({ page }) => {
		await page.route(PLAYER_ADDRESS, (route) => route.fulfill({ contentType: 'text/html', body: STAND_IN_PLAYER }));
		await page.goto(MUSIC_PATH);
		const facade = page.locator(`${FACADE}[aria-label="Play video: ${FIRST_VIDEO}"]`);
		await play(facade);

		const player = page.locator(`main iframe[title="${FIRST_VIDEO}"]`);
		await expect(player, 'the player').toHaveCount(1);
		await expect(facade, 'the picture, replaced').toHaveCount(0);
		const address = new URL((await player.getAttribute('src')) ?? '');
		expect(address.origin + address.pathname, 'the player\'s address').toBe(`https://www.youtube-nocookie.com/embed/${FIRST_VIDEO_ID}`);
		expect(address.searchParams.get('autoplay'), 'set to play').toBe('1');
		expect(address.searchParams.get('enablejsapi'), 'ready for the video script\'s commands').toBe('1');
		// The keyboard focus follows into the player only when played with the keyboard.
		expect(await player.evaluate((frame) => frame === document.activeElement), 'the keyboard focus in the player').toBe(way === 'Enter');
	});
}

test.describe('without JavaScript', () => {
	test.use({ javaScriptEnabled: false });

	test('a video\'s picture is a link to the video on YouTube', async ({ page }) => {
		await page.route(/^https:\/\/www\.youtube\.com\/watch/, (route) => route.fulfill({ contentType: 'text/html', body: '<title>YouTube</title>' }));
		await page.goto(MUSIC_PATH);
		await page.locator(`${FACADE}[aria-label="Play video: ${FIRST_VIDEO}"]`).click();
		await expect(page, 'the page opened').toHaveURL(WATCH_ADDRESS);
	});
});
