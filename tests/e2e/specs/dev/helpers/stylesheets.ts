import type { Page } from '@playwright/test';

// Whether the page loads the stylesheet WordPress registered under this handle. WordPress inlines
// small stylesheets, so a stylesheet shows as a <style> or <link> whose id starts with its handle.
export async function loadsStylesheet(page: Page, handle: string): Promise<boolean> {
	return (await page.locator(`style[id^="${handle}-"], link[id^="${handle}-"]`).count()) > 0;
}
