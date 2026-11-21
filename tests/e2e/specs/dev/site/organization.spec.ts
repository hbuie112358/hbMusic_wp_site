import { expect, test } from '@playwright/test';

// Protects this site's own page data, read from the HTML the server sends (as in
// generic/seo.spec.ts, which checks what Yoast SEO does on every site).

// Yoast's page data: one JSON-LD script holding a graph of pieces.
const SCHEMA_GRAPH = /<script\b[^>]*\bclass=["']yoast-schema-graph["'][^>]*>([\s\S]*?)<\/script>/i;
const ORGANIZATION_ID_SUFFIX = '#organization';

type SchemaPiece = { '@id'?: string; '@type'?: string | string[]; [property: string]: unknown };

function schemaPieces(html: string): SchemaPiece[] {
	const script = SCHEMA_GRAPH.exec(html)?.[1];
	if (script === undefined) {
		throw new Error("the page has no Yoast page data (no script with class yoast-schema-graph)");
	}
	return (JSON.parse(script) as { '@graph': SchemaPiece[] })['@graph'];
}

// Protects the child theme's addition to Yoast's Organization (plan 8h): a musician, with the
// towns served, while Yoast's own logo stays. The towns themselves are the site's content, so the
// test checks their shape, not their names.
test("the page data describes the organization as a musician, with the towns it serves", async ({ request }) => {
	const response = await request.get('/');
	expect(response.status(), 'status').toBe(200);
	const organizations = schemaPieces(await response.text()).filter((piece) => piece['@id']?.endsWith(ORGANIZATION_ID_SUFFIX));
	expect(organizations, 'Organization pieces').toHaveLength(1);
	const [organization] = organizations;
	expect(organization?.['@type'], 'its types').toEqual(['Organization', 'MusicGroup']);
	expect(organization?.['logo'], "Yoast's logo, kept").toBeTruthy();

	const areas = organization?.['areaServed'];
	expect(Array.isArray(areas) && areas.length > 0, 'areas served, at least one').toBe(true);
	for (const area of areas as unknown[]) {
		expect(area, 'each area a named town').toEqual({ '@type': 'City', name: expect.stringMatching(/\S/) });
	}
});
