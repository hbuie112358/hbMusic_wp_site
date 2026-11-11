import { mkdir, writeFile } from 'node:fs/promises';
import { expect, test } from '@playwright/test';
import { answerOutsideServices } from '../specs/dev/csp-violations';

// Shoots every page bin/screenshots names (SCREENSHOT_PATHS, a JSON list of addresses) at desktop
// and phone width, keeps each screenshot in SCREENSHOTS_DIR/latest/ for looking at, and compares it
// with the baseline (screenshots.config.ts).
const VIEWPORTS = [
	{ name: 'desktop', width: 1280, height: 900 },
	{ name: 'phone', width: 390, height: 844 },
] as const;

function pagePaths(): string[] {
	const listed: unknown = JSON.parse(process.env.SCREENSHOT_PATHS ?? '[]');
	if (!Array.isArray(listed) || !listed.every((path) => typeof path === 'string' && path.startsWith('/'))) {
		throw new Error('SCREENSHOT_PATHS must be a JSON list of addresses starting with "/"');
	}
	return listed;
}

// "/" is the home page; "/preview-home/" becomes "preview-home".
function screenshotName(path: string, viewport: string): string {
	return `${path.replace(/^\/|\/$/g, '') || 'home'}-${viewport}.png`;
}

for (const path of pagePaths()) {
	for (const viewport of VIEWPORTS) {
		test(`${path} at ${viewport.name} width`, async ({ page }) => {
			// Outside services (YouTube, Cloudflare) are answered locally, as in the tests: a screenshot
			// must not wait on the internet or change when a provider changes its player.
			await answerOutsideServices(page);
			await page.setViewportSize({ width: viewport.width, height: viewport.height });
			const response = await page.goto(path, { waitUntil: 'networkidle' });
			// A missing page would otherwise be shot as an error page and match an equally broken baseline.
			expect(response?.status(), `${path} answers`).toBe(200);
			const screenshot = await page.screenshot({ fullPage: true, animations: 'disabled' });
			const latestDir = `${process.env.SCREENSHOTS_DIR}/latest`;
			await mkdir(latestDir, { recursive: true });
			await writeFile(`${latestDir}/${screenshotName(path, viewport.name)}`, screenshot);
			expect(screenshot).toMatchSnapshot(screenshotName(path, viewport.name));
		});
	}
}
