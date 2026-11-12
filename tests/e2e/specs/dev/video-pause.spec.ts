import { expect, test, type Page } from '@playwright/test';

// Protects the theme's video script (assets/js/video-pause.js, plan D29): only one YouTube player
// plays at a time (the user found a carousel's first video still playing after moving on). A
// player in a carousel that leaves view is paused, one outside a carousel keeps playing while the
// visitor scrolls, and clicking into one pauses the others. The script loads only
// where there is a player, and each player's address carries YouTube's switch for commands.
//
// YouTube itself is not called: each player address is answered with a stand-in player that
// reports the commands it receives to the page.
const MUSIC_PATH = '/music/';
const HOME_PATH = '/';
const HOME_PLAYER = 'Sample featured video';
const PAGE_WITHOUT_PLAYER = '/book/';
const SCRIPT = 'script[src*="video-pause.js"]';
const ROW = 'section.site-carousel';
const SETTLE_MS = 800;
const SHORT_WINDOW = 300;
const TALL_WINDOW = 2400;
const FIRST_PLAYER = 'Sample video';
const SECOND_PLAYER = 'Sample video of the second set';

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

async function openWithStandInPlayers(page: Page, path: string): Promise<void> {
	await page.route('https://www.youtube.com/embed/**', (route) => route.fulfill({ contentType: 'text/html', body: STAND_IN_PLAYER }));
	// Collects the commands each player reports, named by the player's title.
	await page.addInitScript(() => {
		const commands: Array<{ player: string; func: string }> = [];
		Object.assign(window, { playerCommands: commands });
		window.addEventListener('message', (event) => {
			try {
				const data = JSON.parse(String(event.data)) as { event?: string; func?: string };
				const frame = [...document.querySelectorAll('iframe')].find((candidate) => candidate.contentWindow === event.source);
				if (data.event === 'test-command' && frame) {
					commands.push({ player: frame.title, func: data.func ?? '' });
				}
			} catch {
				// Not a stand-in player's message.
			}
		});
	});
	await page.setViewportSize({ width: 1280, height: 900 });
	await page.goto(path);
}

// Scrolls a player into view and waits until it has loaded (players are lazy-loaded, and a command
// to a player that has not loaded is dropped). Loaded, its document is the stand-in's, on
// YouTube's origin, which the page cannot read.
async function loadPlayer(page: Page, title: string): Promise<void> {
	const player = page.locator(`main iframe[title="${title}"]`);
	await player.scrollIntoViewIfNeeded();
	await expect.poll(() => player.evaluate((frame) => (frame as HTMLIFrameElement).contentDocument === null), { message: `"${title}" loaded` }).toBe(true);
}

async function pausesSince(page: Page, start: number): Promise<string[]> {
	const commands = await page.evaluate(() => (window as unknown as { playerCommands: Command[] }).playerCommands);
	return commands.slice(start).filter((command) => command.func === 'pauseVideo').map((command) => command.player);
}

async function commandCount(page: Page): Promise<number> {
	return page.evaluate(() => (window as unknown as { playerCommands: Command[] }).playerCommands.length);
}

test('the video script loads where there is a player, and each player can take commands', async ({ page }) => {
	await page.goto(MUSIC_PATH);
	await expect(page.locator(SCRIPT), 'the script on the Music page').toHaveCount(1);
	const addresses = await page.locator('main iframe').evaluateAll((frames) => frames.map((frame) => frame.getAttribute('src') ?? ''));
	expect(addresses.length, 'the players').toBeGreaterThanOrEqual(2);
	for (const address of addresses) {
		expect(new URL(address).searchParams.get('enablejsapi'), `the command switch in ${address}`).toBe('1');
	}
	await page.goto(PAGE_WITHOUT_PLAYER);
	await expect(page.locator(SCRIPT), 'the script on a page without a player').toHaveCount(0);
});

// Clicking into a player is seen from the browser's focus, without YouTube's help; clicking from
// one player straight into another counts too, though the page is told only when the focus first
// leaves it.
test('clicking into a player pauses the others, also when moving straight from one to another', async ({ page }) => {
	await openWithStandInPlayers(page, MUSIC_PATH);
	// Tall enough for both carousels, so no player leaves view and pausing comes from the clicks.
	await page.setViewportSize({ width: 1280, height: TALL_WINDOW });
	await loadPlayer(page, SECOND_PLAYER);
	await loadPlayer(page, FIRST_PLAYER);
	await page.waitForTimeout(SETTLE_MS);
	let start = await commandCount(page);
	await page.locator(`main iframe[title="${FIRST_PLAYER}"]`).click();
	await expect.poll(() => pausesSince(page, start), { message: 'the players paused by entering the first' }).toContain(SECOND_PLAYER);
	expect(await pausesSince(page, start), 'the entered player itself').not.toContain(FIRST_PLAYER);
	start = await commandCount(page);
	await page.locator(`main iframe[title="${SECOND_PLAYER}"]`).click();
	await expect.poll(() => pausesSince(page, start), { message: 'the players paused by moving straight to the second' }).toContain(FIRST_PLAYER);
});

test('a player moved out of view in its carousel is paused', async ({ page }) => {
	await openWithStandInPlayers(page, MUSIC_PATH);
	const row = page.locator(ROW).first();
	await loadPlayer(page, FIRST_PLAYER);
	await page.waitForTimeout(SETTLE_MS);
	const start = await commandCount(page);
	const box = await row.boundingBox();
	const buttonSize = 44;
	const gap = 16;
	await page.mouse.click((box?.x ?? 0) + (box?.width ?? 0) - gap - buttonSize / 2, (box?.y ?? 0) + (box?.height ?? 0) / 2);
	await expect.poll(() => pausesSince(page, start), { message: 'the players paused after "next"' }).toContain(FIRST_PLAYER);
});

// Home's video is music with a still picture, listened to while reading on (the user): outside a
// carousel, scrolling it out of view does not pause it.
test('a player outside a carousel keeps playing when scrolled out of view', async ({ page }) => {
	await openWithStandInPlayers(page, HOME_PATH);
	await loadPlayer(page, HOME_PLAYER);
	await page.waitForTimeout(SETTLE_MS);
	const start = await commandCount(page);
	// A short window, so the test page's end lies well below the video.
	await page.setViewportSize({ width: 1280, height: SHORT_WINDOW });
	await page.evaluate(() => window.scrollTo(0, document.documentElement.scrollHeight));
	await page.waitForTimeout(SETTLE_MS);
	const outOfView = await page.locator(`main iframe[title="${HOME_PLAYER}"]`).evaluate((frame) => frame.getBoundingClientRect().bottom < 0);
	expect(outOfView, 'the player scrolled out of view').toBe(true);
	expect(await pausesSince(page, start), 'the players paused by scrolling').not.toContain(HOME_PLAYER);
});
