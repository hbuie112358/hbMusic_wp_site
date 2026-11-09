import { expect, test, type APIRequestContext } from '@playwright/test';
import { TEST_PATHS } from './test-pages';

// Protects what Yoast SEO is set to do on the dev site (plan step 6, D25): every page asks search
// engines not to index it, as every copy but live must (docs/SITE_CHECKLIST.md 9.5), so it names
// no canonical address, while Yoast's own address for it (og:url) is its own; and author archives
// cannot be used to learn the admin's login name (4.5). Yoast writes the canonical link only on
// pages that may be indexed, so only live has one; it is checked there at step 9. The pages'
// security policy and accessibility, with Yoast's output in them, are checked with every other
// page in theme.spec.ts.
//
// The tags are read from the HTML the server sends, without a browser: Yoast writes them on the
// server, and the pages' video and Cloudflare frames then need no stand-ins.
const ROBOTS_META = /<meta\b[^>]*\bname=["']robots["'][^>]*>/gi;
const CANONICAL_LINK = /<link\b[^>]*\brel=["']canonical["'][^>]*>/gi;
const OG_URL_META = /<meta\b[^>]*\bproperty=["']og:url["'][^>]*>/gi;
const HREF_ATTRIBUTE = /\bhref=["']([^"']*)["']/i;
const CONTENT_ATTRIBUTE = /\bcontent=["']([^"']*)["']/i;
// A normal lookup takes a few forwards; more than this means a loop.
const MAX_REDIRECTS = 5;
// The dev admin is the first account bin/dev-site creates, so its user ID is 1.
const ADMIN_USER_ID = 1;

type Hop = { url: string; status: number; location: string };
type Lookup = { hops: Hop[]; finalUrl: string; body: string };

function adminLoginName(): string {
	const user = process.env.DEV_ADMIN_USER;
	if (!user) {
		throw new Error('DEV_ADMIN_USER must be set; run through bin/test.');
	}
	return user;
}

// The given attribute of every tag the pattern finds; a tag without it gives ''.
function attributeValues(html: string, tag: RegExp, attribute: RegExp): string[] {
	return Array.from(html.matchAll(tag), ([element]) => attribute.exec(element)?.[1] ?? '');
}

// Each forward is recorded rather than followed silently: WordPress's own forward from
// /?author=1 puts the login name in the Location header, even if the page it leads to does not.
// Playwright's response.url() is always a full address, so finalUrl can be parsed on its own.
async function followRedirects(request: APIRequestContext, path: string): Promise<Lookup> {
	const hops: Hop[] = [];
	let url = path;
	for (let redirect = 0; redirect <= MAX_REDIRECTS; redirect++) {
		const response = await request.get(url, { maxRedirects: 0 });
		const location = response.headers()['location'] ?? '';
		hops.push({ url: response.url(), status: response.status(), location });
		if (response.status() < 300 || response.status() >= 400 || !location) {
			return { hops, finalUrl: response.url(), body: await response.text() };
		}
		url = location;
	}
	throw new Error(`more than ${MAX_REDIRECTS} forwards from ${path}: ${hops.map((hop) => hop.url).join(' -> ')}`);
}

for (const path of TEST_PATHS) {
	test(`the page ${path} is not indexed, names no canonical address and gives its own address`, async ({ request, baseURL }) => {
		const response = await request.get(path);
		expect(response.status(), 'status').toBe(200);
		const html = await response.text();
		const robots = attributeValues(html, ROBOTS_META, CONTENT_ATTRIBUTE);
		expect(robots, 'robots tags').toHaveLength(1);
		expect(robots[0], 'the robots tag').toMatch(/\bnoindex\b/);
		expect(attributeValues(html, CANONICAL_LINK, HREF_ATTRIBUTE), 'canonical links').toEqual([]);
		expect(attributeValues(html, OG_URL_META, CONTENT_ATTRIBUTE), 'og:url').toEqual([new URL(path, baseURL).href]);
	});
}

for (const lookup of [`/?author=${ADMIN_USER_ID}`, `/author/${adminLoginName()}/`]) {
	test(`the author lookup ${lookup} does not reveal the login name`, async ({ request }) => {
		const login = adminLoginName().toLowerCase();
		const { hops, finalUrl, body } = await followRedirects(request, lookup);
		// Forwards after the request itself, which names the login in one of the two lookups.
		const forwards = hops.flatMap((hop) => (hop.location ? [hop.location.toLowerCase()] : []));
		expect(forwards.filter((location) => location.includes(login)), 'forwards naming the login').toEqual([]);
		expect(new URL(finalUrl).pathname, 'the page reached').not.toMatch(/^\/author\//);
		expect(body.toLowerCase().includes(`/author/${login}`), 'a link to the author archive').toBe(false);
	});
}
