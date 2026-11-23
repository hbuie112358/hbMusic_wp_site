# Status sheet

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The blank status sheet for a new site (template plan 1.5d-4): every item of the DTS site
standard (the handbook's chapter 12, H16, H75-H77), numbered as there, as of the handbook's
commit `8a6d69c`. A new site copies it to `records/status.md` when it starts its status sheet
(chapter 7's step 6) and answers every item: **done**, with how it was checked (an automated
check by its file, or a check by hand with who, where and when), or an **exception**, with its
reason (a recorded exception linked from `records/exceptions.md`, or "Does not apply" and why).
`bin/check` then holds the site's sheet to this list (`tools/status-sheet.sh`): every item
present and answered, nothing else, and every test file a row names still there. When the
handbook adds an item, it is added here, and each site's sheet gets its answer.

- **Open** marks an item still being checked while a sheet is first written; `bin/check` refuses
  it.
- An exception whose reason names a weakness still open is kept in the private records folder
  (`records/README.md`); the sheet then says only "see the private records".

## 1. Secrets and the repository

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 1.1 No secret committed | | | |
| 1.2 No personal data committed | | | |
| 1.3 | retired | | |
| 1.4 Credentials replaced when moved in (chapter 8) | | | |
| 1.5 Secrets only on the server and in Bitwarden; SSH keys only on their computer | | | |

## 2. WordPress configuration

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 2.1 Fresh keys and salts | | | |
| 2.2 `DISALLOW_FILE_EDIT` | | | |
| 2.3 `WP_DEBUG` off on live, nothing shown | | | |
| 2.4 `https://` addresses, `http://` redirected | | | |
| 2.5 The site's own database user | | | |
| 2.6 `wp-config.php` 600 or 640 | | | |
| 2.7 A real cron job where something is timed | | | |

## 3. Server and hosting

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 3.1 HTTPS, renewed certificates, HSTS | | | |
| 3.2 Security headers | | | |
| 3.3 A supported PHP | | | |
| 3.4 Folders 755, files 644, nothing world-writable | | | |
| 3.5 No PHP from uploads; SVG sanitized | | | |
| 3.6 Refused files | | | |
| 3.7 Only the site's files in the web root | | | |
| 3.8 No plain FTP; SSH by key | | | |
| 3.9 Copies behind a password, no second address | | | |

## 4. Users and access

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 4.1 One login per person, lowest role, no `admin` (chapter 6) | | | |
| 4.2 Two-factor login (chapter 6) | | | |
| 4.3 Wordfence's login limits and Extended Protection | | | |
| 4.4 XML-RPC refused | | | |
| 4.5 Login names not shown | | | |
| 4.6 Logins of people who leave removed (chapter 6) | | | |
| 4.7 Application Passwords off | | | |
| 4.8 Pingbacks, trackbacks, registration and comments off | | | |
| 4.9 Who may change what, in writing (chapters 9, 10) | | | |
| 4.10 Unfiltered HTML for Administrators only | | | |
| 4.11 Breached and weak passwords refused for publishers | | | |

## 5. Themes, plugins and updates

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 5.1 Only maintained themes and plugins | | | |
| 5.2 Unused themes and plugins deleted | | | |
| 5.3 Updates (chapter 2) | | | |
| 5.4 The site's changes only in its theme and plugins | | | |
| 5.5 Plugins, must-use plugins and themes match the expected set | | | |

## 6. The theme's code

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 6.1 Design from `theme.json`, templates and patterns first | | | |
| 6.2 Coding standards, PHPStan, Stylelint, type check | | | |
| 6.3 Output escaped late | | | |
| 6.4 Input validated; nonces, rights, REST permissions | | | |
| 6.5 Queries through WordPress or `prepare()` | | | |
| 6.6 Every PHP file guarded | | | |
| 6.7 Scripts only as enqueued files | | | |
| 6.8 Prefixes and text domains | | | |
| 6.9 No PHP errors, warnings or notices | | | |
| 6.10 CSS in two layers | | | |
| 6.11 The editor offers only the theme's values | | | |

## 7. Accessibility

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 7.1 WCAG 2.2 AA | | | |
| 7.2 Full keyboard use | | | |
| 7.3 Contrast | | | |
| 7.4 Alt text; captions for speech | | | |
| 7.5 Headings, landmarks, link text | | | |
| 7.6 No sound by itself | | | |
| 7.7 Reduced motion | | | |

## 8. Performance

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 8.1 Core Web Vitals good on mobile | | | |
| 8.2 Images sized, modern format, dimensions, lazy | | | |
| 8.3 Caching and compression | | | |
| 8.4 Fonts from the site; no outside fonts or blocking scripts | | | |
| 8.5 Videos load nothing until played | | | |

## 9. Search and sharing

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 9.1 One SEO plugin; one canonical and title; sitemap | | | |
| 9.2 Structured data | | | |
| 9.3 A default sharing image of 1200 px; sharing tags everywhere | | | |
| 9.4 Old addresses redirected | | | |
| 9.5 Only live indexed | | | |
| 9.6 Each page planned for search, checked after | | | |

## 10. Privacy and legal

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 10.1 The privacy policy (chapter 10) | | | |
| 10.2 Collecting the least (chapter 10) | | | |
| 10.3 Forms protected against spam (Turnstile) | | | |
| 10.4 The rights to the site's media (chapter 10) | | | |

## 11. Email and domain

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 11.1 Mail through Brevo and FluentSMTP | | | |
| 11.2 SPF, DKIM and DMARC; `p=quarantine` from the fifth week | | | |
| 11.3 The domain locked and renewed (chapters 3, 6) | | | |
| 11.4 DNSSEC where offered; CAA | | | |

## 12. Backups and recovery

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 12.1 Backups away from the server (chapter 4) | | | |
| 12.2 Encrypted (chapter 4) | | | |
| 12.3 Restores tested (chapter 4) | | | |

## 13. Deployment and migration

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 13.1 Changes checked before live; deployed from the repository (chapter 2) | | | |
| 13.2 `wp search-replace` when content changes address | | | |
| 13.3 Moving a site (chapter 8) | | | |
| 13.4 DNS time-to-live lowered first (chapter 8) | | | |
| 13.5 | retired | | |

## 14. Monitoring

| Item | Status | How it was checked | Date |
|---|---|---|---|
| 14.1 Uptime monitoring with alerts (chapters 3, 5) | | | |
| 14.2 Certificate and domain expiry warned (chapters 3, 5) | | | |
| 14.3 Wordfence scans daily and emails every severity | | | |
| 14.4 `bin/deploy` shows the PHP log's new lines | | | |
| 14.5 Site Health, no critical issue | | | |
| 14.6 An activity log, kept 30 days (chapters 3, 10) | | | |

## 15. Shop additions

For a Shop site, its items (chapter 12, section 15, a draft, H78) are added here when the first
shop is built. A brochure site writes one line saying they do not apply.
