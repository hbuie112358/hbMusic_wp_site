import { type Page } from '@playwright/test';

// Records the Content-Security-Policy violations the browser reports on a page, shared by the
// specs that check them (docs/SITE_CHECKLIST.md 3.2).

type CspViolation = { directive: string; blockedURI: string; sourceFile: string };

declare global {
	interface Window {
		cspViolations?: CspViolation[];
	}
}

// Registered before any of the page's own code runs, so no violation can happen unrecorded.
export async function recordCspViolations(page: Page): Promise<void> {
	await page.addInitScript(() => {
		window.cspViolations = [];
		document.addEventListener('securitypolicyviolation', (event) => {
			window.cspViolations?.push({
				directive: event.effectiveDirective,
				blockedURI: event.blockedURI,
				sourceFile: event.sourceFile,
			});
		});
	});
}

export async function recordedCspViolations(page: Page): Promise<CspViolation[]> {
	return page.evaluate(() => window.cspViolations ?? []);
}

// The Music page plays a video from YouTube, and the Book page loads Cloudflare's script. Answered
// by the test, so it needs no network and no outside site, while the browser still applies the
// policy to both.
export async function answerOutsideServices(page: Page): Promise<void> {
	await page.route(/youtube\.com\/embed/, (route) => route.fulfill({ contentType: 'text/html', body: '<title>video</title>' }));
	await page.route(/challenges\.cloudflare\.com/, (route) => route.fulfill({ contentType: 'text/javascript', body: '' }));
}
