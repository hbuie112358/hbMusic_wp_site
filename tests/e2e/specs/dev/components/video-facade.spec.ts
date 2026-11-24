import { expect, test, type Locator, type Page } from '@playwright/test';
import { pagesUsing } from '../helpers/test-pages';

// Protects the click-to-load videos (includes/video-facade.php, assets/js/video-facade.js, plan 9v;
// handbook 12, 8.5): a page with videos loads nothing from YouTube until the visitor plays one, each
// video showing its picture from the site itself and a play button named after the video; playing
// it, by click or Enter, puts YouTube's privacy-enhanced player in its place, set to play and ready
// for the video script's commands, holding the keyboard focus after Enter; without JavaScript, or
// for a video without a title or a secure player origin, the picture is a link to the video on
// YouTube. Replaces the earlier check that every player was lazy-loaded.
// Checked on every page with a YouTube video (template plan T10), playing its first one.
const PAGES_WITH_VIDEOS = pagesUsing('wp-block-embed-youtube');
const FACADE = 'main a.video-facade';
const PLAY_LABEL = /^Play video: (.+)$/;
const WATCH_LINK = /^https:\/\/www\.youtube\.com\/watch\?v=([A-Za-z0-9_-]{11})$/;
const YOUTUBE_REQUEST = /(^|\.)(youtube\.com|youtube-nocookie\.com|ytimg\.com|googlevideo\.com)$/;
const PLAYER_ADDRESS = /^https:\/\/www\.youtube-nocookie\.com\/embed\//;
const STAND_IN_PLAYER = '<!doctype html><title>Stand-in player</title>';

type Video = { facade: Locator; title: string; id: string };

// The page's first video, as its picture names it: the title from the play button's name, the
// video's ID from its link to YouTube.
async function firstVideo(page: Page): Promise<Video> {
	const facade = page.locator(FACADE).first();
	const title = PLAY_LABEL.exec((await facade.getAttribute('aria-label')) ?? '')?.[1] ?? '';
	const id = WATCH_LINK.exec((await facade.getAttribute('href')) ?? '')?.[1] ?? '';
	expect(title, 'the first video\'s title, from its play button').not.toBe('');
	expect(id, 'the first video\'s ID, from its link').not.toBe('');
	// Found again by its link, which only it has: several stand-in videos can share a title.
	return { facade: page.locator(`${FACADE}[href="https://www.youtube.com/watch?v=${id}"]`), title, id };
}

// Each video, its picture and then its player, keeps a 16:9 box, and WordPress's video block around
// it is exactly that tall: relying on the block's own spacer once stretched the picture to the
// whole carousel, and the spacer left on above the picture doubled the block's height on live (the
// block's stylesheet outranked the theme's rule; 2026-11-17). Once played, WordPress lays the player
// over that spacer, so with the spacer off the player must keep its own height.
const WIDESCREEN = 16 / 9;
const SHAPE_TOLERANCE = 0.02;
const HEIGHT_TOLERANCE_PX = 1;
const VIDEO_BLOCK = 'figure.wp-block-embed';

type VideoBox = { name: string; ratio: number; height: number; blockHeight: number };

async function videoBoxes(page: Page, video: string): Promise<VideoBox[]> {
	return page.locator(video).evaluateAll((elements, block) => elements.map((element) => {
		const box = element.getBoundingClientRect();
		return {
			name: element.getAttribute('aria-label') ?? element.getAttribute('title') ?? '',
			ratio: box.width / box.height,
			height: box.height,
			blockHeight: (element.closest(block) ?? element).getBoundingClientRect().height,
		};
	}), VIDEO_BLOCK);
}

function expectWidescreenFilling(boxes: VideoBox[], what: string): void {
	expect(boxes.length, `the ${what}s`).toBeGreaterThanOrEqual(1);
	for (const box of boxes) {
		expect(Math.abs(box.ratio - WIDESCREEN), `the shape of the ${what} "${box.name}"`).toBeLessThanOrEqual(SHAPE_TOLERANCE);
		expect(Math.abs(box.blockHeight - box.height), `the video block's height around the ${what} "${box.name}"`).toBeLessThanOrEqual(HEIGHT_TOLERANCE_PX);
	}
}

for (const path of PAGES_WITH_VIDEOS) {
	test.describe(`on ${path}`, () => {
		test('nothing loads from YouTube before a video is played, the pictures come from the site', async ({ page, baseURL }) => {
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
			expect(facades.length, 'the videos on the page').toBeGreaterThanOrEqual(1);
			for (const facade of facades) {
				expect(facade.name, 'the play button\'s name').toMatch(/^Play video: \S/);
				expect(facade.href, 'the link without JavaScript').toMatch(WATCH_LINK);
				expect(new URL(facade.picture).origin, `the picture of "${facade.name}"`).toBe(new URL(baseURL ?? '').origin);
			}
			await expect(page.locator('main iframe'), 'players before any video is played').toHaveCount(0);
			expect(youtubeRequests, 'requests to YouTube before any video is played').toEqual([]);
		});

		test('every video keeps a 16:9 box, its video block no taller, before and after playing', async ({ page }) => {
			await page.route(PLAYER_ADDRESS, (route) => route.fulfill({ contentType: 'text/html', body: STAND_IN_PLAYER }));
			await page.setViewportSize({ width: 1280, height: 900 });
			await page.goto(path);
			expectWidescreenFilling(await videoBoxes(page, FACADE), 'picture');

			await page.locator(FACADE).first().click();
			await expect(page.locator('main iframe'), 'the player').toHaveCount(1);
			expectWidescreenFilling(await videoBoxes(page, 'main iframe'), 'player');
		});

		for (const [way, play] of [
			['a click', async (facade: Locator) => facade.click()],
			['Enter', async (facade: Locator) => { await facade.focus(); await facade.press('Enter'); }],
		] as const) {
			test(`${way} on a video's picture plays it in YouTube's privacy-enhanced player`, async ({ page }) => {
				await page.route(PLAYER_ADDRESS, (route) => route.fulfill({ contentType: 'text/html', body: STAND_IN_PLAYER }));
				await page.goto(path);
				const video = await firstVideo(page);
				await play(video.facade);

				const player = page.locator(`main iframe[title="${video.title}"][src*="/embed/${video.id}"]`);
				await expect(player, 'the player').toHaveCount(1);
				await expect(video.facade, 'the picture, replaced').toHaveCount(0);
				const address = new URL((await player.getAttribute('src')) ?? '');
				expect(address.origin + address.pathname, 'the player\'s address').toBe(`https://www.youtube-nocookie.com/embed/${video.id}`);
				expect(address.searchParams.get('autoplay'), 'set to play').toBe('1');
				expect(address.searchParams.get('enablejsapi'), 'ready for the video script\'s commands').toBe('1');
				// The keyboard focus follows into the player only when played with the keyboard.
				expect(await player.evaluate((frame) => frame === document.activeElement), 'the keyboard focus in the player').toBe(way === 'Enter');
			});
		}

		// A facade the script cannot turn into a named, secure player stays the link it is without
		// JavaScript (template plan 1.7): never a player without a name for screen readers, never one
		// from an origin that is not https. Both cases are made by changing the first facade's
		// attributes in the page, since the theme always writes them.
		for (const [what, attribute, value] of [
			['without its title', 'data-video-title', null],
			['with a player origin that is not https', 'data-player-origin', 'http://www.youtube-nocookie.com'],
		] as const) {
			test(`a video ${what} stays a link to the video on YouTube`, async ({ page }) => {
				await page.route(/^https:\/\/www\.youtube\.com\/watch/, (route) => route.fulfill({ contentType: 'text/html', body: '<title>YouTube</title>' }));
				await page.route(PLAYER_ADDRESS, (route) => route.fulfill({ contentType: 'text/html', body: STAND_IN_PLAYER }));
				await page.goto(path);
				const video = await firstVideo(page);
				await video.facade.evaluate((facade, [name, setTo]) => {
					if (setTo === null) {
						facade.removeAttribute(name);
					} else {
						facade.setAttribute(name, setTo);
					}
				}, [attribute, value] as const);
				await video.facade.click();
				await expect(page, 'the page opened').toHaveURL(`https://www.youtube.com/watch?v=${video.id}`);
			});
		}

		test.describe('without JavaScript', () => {
			test.use({ javaScriptEnabled: false });

			test('a video\'s picture is a link to the video on YouTube', async ({ page }) => {
				await page.route(/^https:\/\/www\.youtube\.com\/watch/, (route) => route.fulfill({ contentType: 'text/html', body: '<title>YouTube</title>' }));
				await page.goto(path);
				const video = await firstVideo(page);
				await video.facade.click();
				await expect(page, 'the page opened').toHaveURL(`https://www.youtube.com/watch?v=${video.id}`);
			});
		});
	});
}
