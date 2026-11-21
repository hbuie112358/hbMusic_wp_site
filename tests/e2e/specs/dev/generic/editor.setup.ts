import { test as setup } from '@playwright/test';
import { EDITOR_STORAGE_STATE, logInAndSave } from '../helpers/admin-session';

// Logs in as the dev Editor once per run and saves the login, for the specs that check what a
// customer sees in the admin (why once, and why by request: admin-session.ts). A different user
// from the admin, so the two logins can run at the same moment.
setup('log in as the dev Editor', async ({ request }) => {
	await logInAndSave(request, 'DEV_EDITOR_USER', 'DEV_EDITOR_PASSWORD', EDITOR_STORAGE_STATE);
});
