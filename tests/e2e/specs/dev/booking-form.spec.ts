import AxeBuilder from '@axe-core/playwright';
import { expect, test, type APIRequestContext, type Page } from '@playwright/test';
import { readFileSync } from 'node:fs';

// Protects the booking form (plan step 5e): a visitor's request reaches the site owner's inbox
// (Mailpit here) with the visitor as the reply address and without the visitor's name in the
// subject; when sending fails, the visitor sees the site's own message; invalid input and failed
// spam checks send nothing; and its files and Cloudflare's script load only on the page with the form. The site's
// own configuration runs for real; only Cloudflare is simulated (config/dev-mu-plugins/). The
// real Turnstile is proven on staging.
const BOOK_PATH = '/book/';
const PAGE_WITHOUT_FORM = '/about/';
const TURNSTILE_SCRIPT = /challenges\.cloudflare\.com\/turnstile/;
const FORM_PLUGIN_FILES = /\/plugins\/contact-form-7\//;
const PASSING_TOKEN = 'dev-pass';
const FAILING_TOKEN = 'dev-fail';
const SENT_FORM = 'form.wpcf7-form.sent';
const FIELD_ERROR = '.wpcf7-not-valid-tip';
const SPAM_FORM = 'form.wpcf7-form.spam';
const FAILED_FORM = 'form.wpcf7-form.failed';
const RESPONSE_OUTPUT = 'form.wpcf7-form .wpcf7-response-output';
// "Requested action aborted", the code mail servers give for a temporary refusal.
const MAILPIT_REFUSAL_CODE = 451;

type MailpitAddress = { Address: string };
type MailpitSummary = { ID: string; To: MailpitAddress[]; ReplyTo: MailpitAddress[]; Subject: string };

// Stands in for Cloudflare's widget, which would put its token in the form. No token: as a bot.
async function simulateTurnstile(page: Page, token: string): Promise<void> {
	// Cloudflare's script loads in the page's head, before the form exists, so it waits for the page.
	const addToken = token
		? `document.addEventListener('DOMContentLoaded', () => {
				document.querySelectorAll('.wpcf7-turnstile').forEach((widget) => {
					const field = document.createElement('input');
					field.type = 'hidden';
					field.name = '_wpcf7_turnstile_response';
					field.value = '${token}';
					widget.append(field);
				});
			});`
		: '';
	await page.route(TURNSTILE_SCRIPT, (route) =>
		route.fulfill({ contentType: 'text/javascript', body: `window.turnstile = { reset() {} };${addToken}` }),
	);
}

async function fillForm(page: Page, marker: string, email: string): Promise<void> {
	await page.goto(BOOK_PATH, { waitUntil: 'networkidle' });
	await page.getByLabel('Your name').fill(`Visitor ${marker}`);
	await page.getByLabel('Your email').fill(email);
	await page.getByLabel('Event date').fill('2030-06-15');
	await page.getByLabel('About your event').fill(`A sample event, ${marker}`);
}

async function mailsWith(request: APIRequestContext, marker: string): Promise<MailpitSummary[]> {
	const response = await request.get(`${process.env.DEV_MAIL_URL}/api/v1/search?query=${marker}`);
	expect(response.ok(), 'Mailpit answers').toBe(true);
	return (await response.json()).messages as MailpitSummary[];
}

async function mailText(request: APIRequestContext, mailId: string): Promise<string> {
	const response = await request.get(`${process.env.DEV_MAIL_URL}/api/v1/message/${mailId}`);
	expect(response.ok(), 'Mailpit answers').toBe(true);
	return (await response.json()).Text as string;
}

// Makes Mailpit refuse every recipient, as a mail service does when it will not take the site's
// mail; the site then sees the failure, as with Brevo (plan step 8). Needs MP_ENABLE_CHAOS.
async function setMailpitRefusal(request: APIRequestContext, isRefusing: boolean): Promise<void> {
	const response = await request.put(`${process.env.DEV_MAIL_URL}/api/v1/chaos`, {
		data: { Recipient: { ErrorCode: MAILPIT_REFUSAL_CODE, Probability: isRefusing ? 100 : 0 } },
	});
	expect(response.ok(), 'Mailpit takes the setting').toBe(true);
}

// The messages the build sets on the form (config/booking-form-messages.json, mounted by bin/test).
function configuredMessage(name: string): string {
	const messagesFile = process.env.BOOKING_FORM_MESSAGES;
	if (!messagesFile) {
		throw new Error('BOOKING_FORM_MESSAGES is not set; run the tests through bin/test.');
	}
	const messages = JSON.parse(readFileSync(messagesFile, 'utf8')) as Record<string, string>;
	const message = messages[name];
	if (message === undefined) {
		throw new Error(`${messagesFile} has no message ${name}`);
	}
	return message;
}

// A unique word for each test, so tests running side by side cannot see each other's mail.
function uniqueMarker(): string {
	return `marker${test.info().testId}${Date.now()}`.replace(/\W/g, '');
}

// Mailpit's refusal holds for every mail the site sends, so the test that plants it runs one at a
// time with the test that expects mail to arrive (the project's CLAUDE.md, Testing).
test.describe('sending', () => {
	test.describe.configure({ mode: 'serial' });
	test.beforeEach(async ({ request }) => setMailpitRefusal(request, false));
	test.afterEach(async ({ request }) => setMailpitRefusal(request, false));

	test('a visitor\'s request reaches the inbox, and a reply goes to the visitor', async ({ page, request }) => {
		await simulateTurnstile(page, PASSING_TOKEN);
		const marker = uniqueMarker();
		await fillForm(page, marker, 'visitor@example.test');
		await page.getByRole('button', { name: 'Send' }).click();
		await expect(page.locator(SENT_FORM), 'the form reports it was sent').toBeVisible();

		await expect.poll(async () => (await mailsWith(request, marker)).length, 'one mail arrives').toBe(1);
		const [mail] = await mailsWith(request, marker);
		if (mail === undefined) {
			throw new Error('the mail Mailpit had just reported is gone');
		}
		expect(mail.To.map((to) => to.Address), 'sent to the site admin').toEqual([process.env.DEV_ADMIN_EMAIL]);
		expect(mail.ReplyTo.map((replyTo) => replyTo.Address), 'a reply goes to the visitor').toEqual(['visitor@example.test']);
		// The subject reaches the mail service's records and the failure alerts (plan step 8), so
		// the visitor's name is only in the body, which only the site owner reads.
		expect(mail.Subject, 'the subject does not name the visitor').not.toContain(marker);
		expect(await mailText(request, mail.ID), 'the body names the visitor').toContain(`Visitor ${marker}`);
	});

	test('when the site cannot send, the visitor is told how else to reach the owner', async ({ page, request }) => {
		await simulateTurnstile(page, PASSING_TOKEN);
		await setMailpitRefusal(request, true);
		const marker = uniqueMarker();
		await fillForm(page, marker, 'visitor@example.test');
		await page.getByRole('button', { name: 'Send' }).click();
		await expect(page.locator(FAILED_FORM), 'the form reports the failure').toBeVisible();
		await expect(page.locator(RESPONSE_OUTPUT), 'the message from config/').toHaveText(configuredMessage('mail_sent_ng'));
		expect(await mailsWith(request, marker), 'no mail').toEqual([]);
	});
});

for (const [problem, fill] of [
	['no name', async (page: Page) => page.getByLabel('Your name').fill('')],
	['an invalid email', async (page: Page) => page.getByLabel('Your email').fill('not-an-address')],
] as const) {
	test(`a request with ${problem} is refused and sends nothing`, async ({ page, request }) => {
		await simulateTurnstile(page, PASSING_TOKEN);
		const marker = uniqueMarker();
		await fillForm(page, marker, 'visitor@example.test');
		await fill(page);
		await page.getByRole('button', { name: 'Send' }).click();
		await expect(page.locator(FIELD_ERROR), 'the problem is shown at its field').toHaveCount(1);
		expect(await mailsWith(request, marker), 'no mail').toEqual([]);

		const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa']).analyze();
		expect(results.violations.map((violation) => violation.id), 'the error messages are accessible').toEqual([]);
	});
}

for (const [description, token] of [
	['with a failed spam check', FAILING_TOKEN],
	['with no spam check at all', ''],
] as const) {
	test(`a request ${description} is treated as spam and sends nothing`, async ({ page, request }) => {
		await simulateTurnstile(page, token);
		const marker = uniqueMarker();
		await fillForm(page, marker, 'visitor@example.test');
		await page.getByRole('button', { name: 'Send' }).click();
		await expect(page.locator(SPAM_FORM), 'the form reports spam').toBeVisible();
		expect(await mailsWith(request, marker), 'no mail').toEqual([]);
	});
}

// A bot skips the browser's checks and posts straight to the site, so the server must refuse too.
test('the server refuses invalid input sent past the browser, and sends nothing', async ({ page, request }) => {
	await page.goto(BOOK_PATH);
	const formId = await page.locator('input[name="_wpcf7"]').getAttribute('value');
	const marker = uniqueMarker();
	const response = await request.post(`/wp-json/contact-form-7/v1/contact-forms/${formId}/feedback`, {
		multipart: {
			_wpcf7: String(formId),
			_wpcf7_version: String(await page.locator('input[name="_wpcf7_version"]').getAttribute('value')),
			_wpcf7_locale: String(await page.locator('input[name="_wpcf7_locale"]').getAttribute('value')),
			_wpcf7_unit_tag: String(await page.locator('input[name="_wpcf7_unit_tag"]').getAttribute('value')),
			_wpcf7_container_post: String(await page.locator('input[name="_wpcf7_container_post"]').getAttribute('value')),
			_wpcf7_turnstile_response: PASSING_TOKEN,
			'your-name': `Visitor ${marker}`,
			'your-email': 'not-an-address',
		},
	});
	expect((await response.json()).status, "the server's answer").toBe('validation_failed');
	expect(await mailsWith(request, marker), 'no mail').toEqual([]);
});

test('the form\'s files and Cloudflare\'s script load only on the page with the form', async ({ page }) => {
	await simulateTurnstile(page, PASSING_TOKEN);
	const requested: string[] = [];
	page.on('request', (browserRequest) => requested.push(browserRequest.url()));

	await page.goto(PAGE_WITHOUT_FORM, { waitUntil: 'networkidle' });
	expect(requested.filter((url) => FORM_PLUGIN_FILES.test(url) || TURNSTILE_SCRIPT.test(url)), 'without a form').toEqual([]);

	await page.goto(BOOK_PATH, { waitUntil: 'networkidle' });
	expect(requested.filter((url) => FORM_PLUGIN_FILES.test(url)).length, "the form's files").toBeGreaterThan(0);
	expect(requested.filter((url) => TURNSTILE_SCRIPT.test(url)).length, "Cloudflare's script").toBeGreaterThan(0);
});
