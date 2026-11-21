import { expect, test, type Page } from '@playwright/test';
import { EXAMPLE_PATHS, TEST_PATHS, pagesUsing } from '../helpers/test-pages';

// Protects the theme's video script (assets/js/video-pause.js, plan D29): only one YouTube player
// plays at a time (the user found a carousel's first video still playing after moving on). A
// player moved out of its carousel's view is paused, scrolling the page never pauses one, and
// clicking into one pauses the others. The script loads only
// where there is a video, and each player's address carries YouTube's switch for commands. Since the
// click-to-load videos (plan 9v), each player is created when the visitor plays its video, so the
// tests start the videos that way, by clicking their pictures.
//
// Checked on every page with a YouTube video (template plan T10). Each arrangement a test needs
// (two videos, a video in a carousel, a video outside one) is checked wherever a page has it and
// required on the example page, which has them all. Players are told apart by their video's ID,
// as stand-in videos can share a title.
//
// YouTube itself is not called: each player address is answered with a stand-in player that
// reports the commands it receives to the page.
const PAGES_WITH_VIDEOS = pagesUsing('wp-block-embed-youtube');
const PAGES_WITHOUT_VIDEOS = TEST_PATHS.filter((path) => !PAGES_WITH_VIDEOS.includes(path));
const FACADE = 'main a.video-facade';
const SCRIPT = 'script[src*="video-pause.js"]';
const ROW = 'section.site-carousel';
const SETTLE_MS = 800;
const SHORT_WINDOW = 300;
const TALL_WINDOW = 2400;
const NEXT_BUTTON_SIZE_PX = 44;
const NEXT_BUTTON_GAP_PX = 16;
// The players' addresses, YouTube's usual and its privacy-enhanced one, answered by the stand-in.
const YOUTUBE_PLAYER_ADDRESS = /^https:\/\/www\.youtube(-nocookie)?\.com\/embed\//;

// The stand-in player: it answers every command with a "test-command" message naming it.
const STAND_IN_PLAYER = `<!doctype html><title>Stand-in player</title><style>body { margin: 0; height: 100vh; }</style><script>
window.addEventListener('message', (event) => {
	try {
		const data = JSON.parse(event.data);
		if (data.event === 'command') {
			parent.postMessage(JSON.stringify({ event: 'test-command', func: data.func }), '*');
		}
	} catch {}
});
</script>`;

interface Command {
	player: string;
	func: string;
}

interface Video {
	id: string;
	isInCarousel: boolean;
}

async function openWithStandInPlayers(page: Page, path: string): Promise<void> {
	await page.route(YOUTUBE_PLAYER_ADDRESS, (route) => route.fulfill({ contentType: 'text/html', body: STAND_IN_PLAYER }));
	// Collects the commands each player reports, named by the ID of the player's video.
	await page.addInitScript(() => {
		const commands: Array<{ player: string; func: string }> = [];
		Object.assign(window, { playerCommands: commands });
		window.addEventListener('message', (event) => {
			try {
				const data = JSON.parse(String(event.data)) as { event?: string; func?: string };
				const frame = [...document.querySelectorAll('iframe')].find((candidate) => candidate.contentWindow === event.source);
				if (data.event === 'test-command' && frame) {
					commands.push({ player: /\/embed\/([^?/]+)/.exec(frame.src)?.[1] ?? '', func: data.func ?? '' });
				}
			} catch {
				// Not a stand-in player's message.
			}
		});
	});
	await page.setViewportSize({ width: 1280, height: 900 });
	await page.goto(path);
}

// The page's videos, in page order, each by its ID (from its link to YouTube) and whether it sits
// in a carousel.
async function videosOn(page: Page): Promise<Video[]> {
	return page.locator(FACADE).evaluateAll((links, row) => links.map((link) => ({
		id: /[?&]v=([^&]+)/.exec(link.getAttribute('href') ?? '')?.[1] ?? '',
		isInCarousel: link.closest(row) !== null,
	})), ROW);
}

// The videos the test needs: on the example page there must be at least as many as asked for; a
// site page without them reports the test as skipped, with the reason, rather than as passed.
// test.skip stops the test there, so the code after a call always has the videos it asked for.
function requireOrSkip(path: string, videos: Video[], needed: number, what: string): void {
	if (EXAMPLE_PATHS.includes(path)) {
		expect(videos.length, `${what} on the example page`).toBeGreaterThanOrEqual(needed);
	}
	test.skip(videos.length < needed, `this page has fewer than ${needed} of ${what}`);
}

function playerOf(page: Page, id: string) {
	return page.locator(`main iframe[src*="/embed/${id}"]`);
}

// Plays a video as a visitor does, by clicking its picture, and waits until its player has loaded
// (a command to a player that has not loaded is dropped). Loaded, its document is the stand-in's,
// on YouTube's origin, which the page cannot read.
async function startPlayer(page: Page, id: string): Promise<void> {
	const facade = page.locator(`${FACADE}[href$="v=${id}"]`);
	await facade.scrollIntoViewIfNeeded();
	await facade.click();
	await expect.poll(() => playerOf(page, id).evaluate((frame) => (frame as HTMLIFrameElement).contentDocument === null), { message: `the player of ${id} loaded` }).toBe(true);
}

async function pausesSince(page: Page, start: number): Promise<string[]> {
	const commands = await page.evaluate(() => (window as unknown as { playerCommands: Command[] }).playerCommands);
	return commands.slice(start).filter((command) => command.func === 'pauseVideo').map((command) => command.player);
}

async function commandCount(page: Page): Promise<number> {
	return page.evaluate(() => (window as unknown as { playerCommands: Command[] }).playerCommands.length);
}

// Plays the video, then scrolls the page to its end in a short window, so the video lies well
// above the view; returns the players paused meanwhile.
async function pausesFromScrollingPast(page: Page, id: string): Promise<string[]> {
	await startPlayer(page, id);
	await page.waitForTimeout(SETTLE_MS);
	const start = await commandCount(page);
	await page.setViewportSize({ width: 1280, height: SHORT_WINDOW });
	await page.evaluate(() => window.scrollTo(0, document.documentElement.scrollHeight));
	await page.waitForTimeout(SETTLE_MS);
	const outOfView = await playerOf(page, id).evaluate((frame) => frame.getBoundingClientRect().bottom < 0);
	expect(outOfView, 'the player scrolled out of view').toBe(true);
	return pausesSince(page, start);
}

test('the video script does not load on a page without a video', async ({ page }) => {
	expect(PAGES_WITHOUT_VIDEOS.length, 'the pages without a video').toBeGreaterThan(0);
	for (const path of PAGES_WITHOUT_VIDEOS) {
		await page.goto(path);
		await expect(page.locator(SCRIPT), `the script on ${path}`).toHaveCount(0);
	}
});

for (const path of PAGES_WITH_VIDEOS) {
	test.describe(`on ${path}`, () => {
		test('the video script loads, and each player can take commands', async ({ page }) => {
			await openWithStandInPlayers(page, path);
			await page.setViewportSize({ width: 1280, height: TALL_WINDOW });
			await expect(page.locator(SCRIPT), 'the script').toHaveCount(1);
			const videos = (await videosOn(page)).slice(0, 2);
			expect(videos.length, 'the videos').toBeGreaterThanOrEqual(1);
			for (const video of videos) {
				await startPlayer(page, video.id);
			}
			const addresses = await page.locator('main iframe').evaluateAll((frames) => frames.map((frame) => frame.getAttribute('src') ?? ''));
			expect(addresses.length, 'the players').toBe(videos.length);
			for (const address of addresses) {
				expect(new URL(address).searchParams.get('enablejsapi'), `the command switch in ${address}`).toBe('1');
			}
		});

		// Clicking into a player is seen from the browser's focus, without YouTube's help; clicking
		// from one player straight into another counts too, though the page is told only when the
		// focus first leaves it.
		test('clicking into a player pauses the others, also when moving straight from one to another', async ({ page }) => {
			await openWithStandInPlayers(page, path);
			// Tall enough for the videos, so no player leaves view and pausing comes from the clicks.
			await page.setViewportSize({ width: 1280, height: TALL_WINDOW });
			const videos = await videosOn(page);
			requireOrSkip(path, videos, 2, 'the videos');
			const [first, second] = videos as [Video, Video];
			await startPlayer(page, second.id);
			await page.waitForTimeout(SETTLE_MS);
			let start = await commandCount(page);
			await startPlayer(page, first.id);
			await expect.poll(() => pausesSince(page, start), { message: 'the players paused by playing the first' }).toContain(second.id);
			expect(await pausesSince(page, start), 'the entered player itself').not.toContain(first.id);
			start = await commandCount(page);
			await playerOf(page, second.id).click();
			await expect.poll(() => pausesSince(page, start), { message: 'the players paused by moving straight to the second' }).toContain(first.id);
		});

		test('a player moved out of view in its carousel is paused', async ({ page }) => {
			await openWithStandInPlayers(page, path);
			const inCarousels = (await videosOn(page)).filter((video) => video.isInCarousel);
			requireOrSkip(path, inCarousels, 1, 'the videos in a carousel');
			const [video] = inCarousels as [Video];
			await startPlayer(page, video.id);
			await page.waitForTimeout(SETTLE_MS);
			const start = await commandCount(page);
			// The carousel holding the player; the inner locator is matched inside each carousel.
			const row = page.locator(ROW).filter({ has: page.locator(`iframe[src*="/embed/${video.id}"]`) });
			const box = await row.boundingBox();
			await page.mouse.click((box?.x ?? 0) + (box?.width ?? 0) - NEXT_BUTTON_GAP_PX - NEXT_BUTTON_SIZE_PX / 2, (box?.y ?? 0) + (box?.height ?? 0) / 2);
			await expect.poll(() => pausesSince(page, start), { message: 'the players paused after "next"' }).toContain(video.id);
		});

		// A video outside a carousel is music with a still picture, listened to while reading on (the
		// user): scrolling it out of view does not pause it.
		test('a player outside a carousel keeps playing when scrolled out of view', async ({ page }) => {
			await openWithStandInPlayers(page, path);
			const onTheirOwn = (await videosOn(page)).filter((video) => !video.isInCarousel);
			requireOrSkip(path, onTheirOwn, 1, 'the videos outside a carousel');
			const [video] = onTheirOwn as [Video];
			expect(await pausesFromScrollingPast(page, video.id), 'the players paused by scrolling').not.toContain(video.id);
		});

		// Scrolling the page down to the call to action keeps a carousel's video playing (the user:
		// it pauses only when the carousel moves to another video, or when stopped).
		test('a player in a carousel keeps playing when the page is scrolled past it', async ({ page }) => {
			await openWithStandInPlayers(page, path);
			const inCarousels = (await videosOn(page)).filter((video) => video.isInCarousel);
			requireOrSkip(path, inCarousels, 1, 'the videos in a carousel');
			const [video] = inCarousels as [Video];
			expect(await pausesFromScrollingPast(page, video.id), 'the players paused by scrolling the page').not.toContain(video.id);
		});
	});
}
