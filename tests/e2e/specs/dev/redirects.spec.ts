import { expect, test } from '@playwright/test';

// Protects the old addresses' redirects (plan D22, the child theme's HBMUSIC_OLD_ADDRESSES): each
// old address forwards permanently to the page that replaced it, which exists, and an address that
// was never a page is still "not found" rather than forwarded somewhere.
const OLD_TO_NEW: ReadonlyArray<readonly [string, string]> = [
	['/video/', '/music/'],
	['/audio/', '/music/'],
	['/contact/', '/book/'],
	['/Contact/', '/book/'],
];
const PERMANENTLY_MOVED = 301;
const NOT_FOUND = 404;

for (const [oldPath, newPath] of OLD_TO_NEW) {
	test(`${oldPath} forwards permanently to ${newPath}`, async ({ request, baseURL }) => {
		const response = await request.get(oldPath, { maxRedirects: 0 });
		expect(response.status(), 'a permanent redirect').toBe(PERMANENTLY_MOVED);
		expect(response.headers()['location'], 'to the new page on the same site').toBe(`${baseURL}${newPath}`);

		const newPage = await request.get(newPath, { maxRedirects: 0 });
		expect(newPage.ok(), 'the new page exists').toBe(true);
	});
}

test('an address that was never a page is not forwarded', async ({ request }) => {
	const response = await request.get('/never-a-page/', { maxRedirects: 0 });
	expect(response.status(), 'not found').toBe(NOT_FOUND);
});
