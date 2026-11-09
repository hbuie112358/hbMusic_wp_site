import path from 'node:path';

// Where admin.setup.ts saves the dev admin's login, for the specs that use the admin screens
// (plan step 8d): they start from it with test.use({ storageState: ADMIN_STORAGE_STATE }). Outside
// specs/, and ignored by git (.gitignore), since it holds session cookies.
export const ADMIN_STORAGE_STATE = path.join(__dirname, '..', '..', '.auth', 'admin.json');
