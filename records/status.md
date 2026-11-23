# Status sheet

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Every item of the DTS site standard (the handbook's chapter 12, H16, H75-H77), for
howardbuiemusic.com: **done**, with how it was checked, or an **exception**, with its reason (the
reasons in [`exceptions.md`](exceptions.md)). Checked against chapter 12 as of the handbook's
commit `8a6d69c`; when the handbook adds an item, it is added here with its status.

- **How it was checked:** an automated check names its file (it runs on every pull request, so a
  break fails the tests, not this sheet), or a check by hand names who did it, where (live,
  staging, from outside) and when. "From outside" means a request to the public site from the
  user's computer, as any visitor could make it.
- **Pointer items** (a rule decided in another chapter) name that chapter, and their status is
  this site's.
- **Open** marks an item still being checked while this sheet is built (template plan 1.5d); it
  is not a status the sheet may keep.
- An exception whose reason names a weakness still open is kept in the private records folder
  (`records/README.md`); this sheet then says only "see the private records".

## 1. Secrets and the repository

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 1.1 No secret committed | done | The `.gitignore` allow-list; the staged files listed before every commit (the project's `CLAUDE.md`); Claude searched the whole history (239 commits) for private keys, API keys and tokens, WordPress salts, database passwords and Turnstile secrets: none | 2026-11-23 |
| 1.2 No personal data committed | done | The staged files scanned before every commit; Claude searched the whole history for email addresses, home-folder paths, host account numbers and IP addresses: only stand-in `example.test` addresses, the site's own sender, and two package authors' public addresses inside lock files | 2026-11-23 |
| 1.3 | retired | | |
| 1.4 Credentials replaced when moved in (chapter 8) | done | The site was rebuilt on its own host, not moved in; the old site's exposed salts and keys and its database password were replaced (rebuild plan 0d), the admin password (0a), and go-live made a new admin with two-factor login and the site's own Brevo and Turnstile keys (9f, 9g, 9i) | 2026-11-17 |
| 1.5 Secrets only on the server and in Bitwarden; SSH keys only on their computer | exception | [E3](exceptions.md#e3): the user's password notes instead of Bitwarden, until Bitwarden is set up. The deploy keys exist only on the user's computer (template plan 1.4e); GitHub's old deploy key and secret were removed (#95) | 2026-11-23 |

## 2. WordPress configuration

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 2.1 Fresh keys and salts | done | Live's keys and salts replaced after the exposed copy was found (rebuild plan 0d); staging's made by its installer (3g-1) | 2026-11-02 |
| 2.2 `DISALLOW_FILE_EDIT` | done | `true` on staging and live, set with WP-CLI by the user over SSH, and live refusing `theme-editor.php` (rebuild plan 8m); on the dev site, `compose.dev.yaml` | 2026-11-11 |
| 2.3 `WP_DEBUG` off on live, nothing shown | done | `WP_DEBUG` off on both (8m); from outside, a missing page answers 404 with no PHP text and `debug.log` and `error_log` are unreachable; on the server (the user's read-only command), no debug log in either web root. The PHP log is outside the web root, `~/.logs/` (template plan 1.4a) | 2026-11-23 |
| 2.4 `https://` addresses, `http://` redirected | done | From outside: the REST index gives `home` and `url` as `https://`; `http://` for `/` and `/wp-admin/` answers 301 to `https://` | 2026-11-23 |
| 2.5 The site's own database user | done | Each site's database has its own user, granted that database only (hPanel, the user, 8m); live's password replaced (0d) | 2026-11-11 |
| 2.6 `wp-config.php` 600 or 640 | done | 600 on live and staging (the user's read-only command) | 2026-11-23 |
| 2.7 A real cron job where something is timed | done | Nothing on the site must run at a set time (the booking form sends at once; the activity log's and the mail log's clean-ups only need to run eventually), so WordPress's own scheduler is kept | 2026-11-23 |

## 3. Server and hosting

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 3.1 HTTPS, renewed certificates, HSTS | done | SSL Labs: A+ for every server address (the user). From outside: `strict-transport-security: max-age=31536000` (no subdomains, no preload); Let's Encrypt certificate valid until 2027-01-03, renewed by Hostinger | 2026-11-23 |
| 3.2 Security headers | done | From outside on Home: the policy with `object-src 'none'`, `base-uri 'self'`, `form-action 'self'`, `frame-ancestors 'self'`, and its outside sources (Turnstile, YouTube's players); `X-Content-Type-Options: nosniff`, `Referrer-Policy`, `Permissions-Policy`. On every pull request: `tests/e2e/specs/dev/generic/theme.spec.ts` (the headers) and the policy recorder (any violation fails) | 2026-11-23 |
| 3.3 A supported PHP | done | Live and staging 8.4.28 (Site Health, the user); 8.4 under active support until 2026-12-31 and security fixes until 2028-12-31 (php.net). No local staging (H7): staging on the host plays its part ([E2](exceptions.md#e2)) | 2026-11-23 |
| 3.4 Folders 755, files 644, nothing world-writable | done | On live and staging (the user's read-only command): nothing world-writable or owned by another account, every folder 755, every file 644 except `wp-config.php` and Wordfence's `wflogs/` files at 600 | 2026-11-23 |
| 3.5 No PHP from uploads; SVG sanitized | done | On live, a test `.php` file in `uploads/` answered 403 and was removed (the user's command). On the dev site, an SVG holding a script refused for the dev admin and the dev Editor ("not allowed to upload this file type", WP-CLI, by Claude); no plugin on live allows SVG (`records/plugin-set.md`, 1.5d-2) | 2026-11-23 |
| 3.6 Refused files | done | From outside on live: `readme.html`, `license.txt`, every installed plugin's and theme's `readme.txt`, `.htaccess`, `.git/HEAD`, `.env` and `wp-config.php` backups answer 403; no `.sql`, `.zip`, `.log` or `.json` file is in the web root (3.7's listing) | 2026-11-23 |
| 3.7 Only the site's files in the web root | done | The web root's listing on live and staging (the user's command): WordPress's own files, `.htaccess`, `wp-config.php`, and on live Wordfence's `wordfence-waf.php`, on staging `.htpasswd` (its site-wide password). Removed by the user: Hostinger's `default.php` placeholder on both (public on live, now 404 from outside), and on staging `.htaccess.bk` (a backup from the password's setup, 2026-11-03) and `llms.txt` (a leftover of its installation, listing only WordPress's sample post). Kept on staging by the user's choice: Hostinger's `.private` folder (its own plugins' update addresses, no secret, `Deny from all`) | 2026-11-23 |
| 3.8 No plain FTP; SSH by key | exception | No FTP account in use: only Hostinger's main account, which cannot be removed and is not used (8m). Deploys by key. See the private records for the rest | 2026-11-11 |
| 3.9 Copies behind a password, no second address | done | From outside, staging without the password: home, `wp-login.php`, `/wp-admin/`, the REST API and `xmlrpc.php` all answer 401; no temporary address (rebuild plan 3g-2). Staging is kept on the host as [E2](exceptions.md#e2), with test content | 2026-11-23 |

## 4. Users and access

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 4.1 One login per person, lowest role, no `admin` (chapter 6) | exception | [E4](exceptions.md#e4): live has two Administrators, both the user's, the old one kept until rebuild plan 9n; and one Editor, the user's; none named `admin` (Users, the user) | 2026-11-23 |
| 4.2 Two-factor login (chapter 6) | done | Required for Administrators on live and staging, the login tested (rebuild plan 8i, 3g-1) | 2026-11-09 |
| 4.3 Wordfence's login limits and Extended Protection | done | Live: firewall in Extended Protection, login limits at Wordfence's defaults (8i, read by the user). Staging runs Wordfence's basic protection behind its site-wide password (`docs/ENVIRONMENTS.md`) | 2026-11-10 |
| 4.4 XML-RPC refused | done | From outside on live: `xmlrpc.php` answers 403. On every pull request: `tests/scenario/plugins/site-hardening/dev-site-hardening.sh` | 2026-11-23 |
| 4.5 Login names not shown | done | From outside on live: the users endpoint (`/wp-json/` and `?rest_route=`) answers 403 or 404, `?author=1` and `?author=2` answer 404, oEmbed names no author, and there is no author sitemap | 2026-11-23 |
| 4.6 Logins of people who leave removed (chapter 6) | done | Nobody has left; the accounts are the user's (4.1) | 2026-11-23 |
| 4.7 Application Passwords off | done | On live the profile shows Application Passwords disabled (Wordfence's notice; Site Hardening switches them off too), the user. On every pull request: `tests/e2e/specs/dev/plugins/site-hardening/hardening.spec.ts` (no section) | 2026-11-23 |
| 4.8 Pingbacks, trackbacks, registration and comments off | done | Registration off, new posts get no comments or pingbacks, the site sends none, on staging and live (8m); from outside on live, a pingback request answers 403 | 2026-11-23 |
| 4.9 Who may change what, in writing (chapters 9, 10) | exception | [E6](exceptions.md#e6): the user's own site, with no customer | 2026-11-23 |
| 4.10 Unfiltered HTML for Administrators only | done | On every pull request: `tests/scenario/plugins/site-hardening/dev-site-hardening.sh` (an Editor's script removed, the site's own content kept); Site Hardening 0.2.0 active on live (rebuild plan 9l) | 2026-11-17 |
| 4.11 Breached and weak passwords refused for publishers | done | Wordfence's settings on live, set and read by the user (rebuild plan item 3-1) | 2026-11-17 |
