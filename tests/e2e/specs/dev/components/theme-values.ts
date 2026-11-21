import type { Page } from '@playwright/test';

// Reads a length the theme sets (a theme.json token such as var(--wp--custom--spacing--section)),
// in whole pixels, from the page itself, so the specs compare against the theme's current value
// instead of repeating it. A probe element takes the length as its width and is removed again.
export async function themeLength(page: Page, cssLength: string): Promise<number> {
	return page.evaluate((length) => {
		const probe = document.createElement('div');
		probe.style.width = length;
		document.body.append(probe);
		const width = probe.getBoundingClientRect().width;
		probe.remove();
		return Math.round(width);
	}, cssLength);
}
