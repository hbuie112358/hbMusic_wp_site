import { test as setup } from '@playwright/test';
import { ADMIN_STORAGE_STATE, logInAndSave } from '../helpers/admin-session';

// Logs in as the dev admin once per run, before the browser tests, and saves the login for the
// specs that use the admin screens (plan step 8d; why once, and why by request: admin-session.ts).
setup('log in as the dev admin', async ({ request }) => {
	await logInAndSave(request, 'DEV_ADMIN_USER', 'DEV_ADMIN_PASSWORD', ADMIN_STORAGE_STATE);
});
