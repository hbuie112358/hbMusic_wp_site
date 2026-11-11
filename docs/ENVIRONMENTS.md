# Intended differences between the dev site, staging and live

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The three places code passes through (the project's `CLAUDE.md`, Terms) run the same code: the
child theme and the Song List from `main`, and the same plugins. They are not meant to be the
same in everything: some settings differ on purpose. Each difference is listed here with its
reason and where it is tested, so none is a surprise and none is mistaken for a fault (agreed
with the user on 2026-11-09, plan step 6).

**The rule:** what is the same everywhere (code, plugins, settings such as author archives off)
is tested on the dev site. What only one place does is tested there: on staging by hand, on live
from outside after go-live (step 9). A new difference is added here when it is introduced, or it
counts as drift.

| Setting | Dev site | Staging | Live | Why | Tested |
|---|---|---|---|---|---|
| Search engines | discouraged (`bin/dev-site`) | discouraged (3g-1) | allowed | Only the real site may appear in search results (checklist 9.5). | Dev: `seo.spec.ts`. Live: step 9. |
| Canonical link (Yoast) | none | none | on every page | Yoast writes it only on pages that may be indexed (its `canonical-presenter.php`, 28.8). | Dev: none expected, `og:url` checked instead. Live: step 9. |
| Who can reach it | this computer only (`127.0.0.1`, `compose.dev.yaml`) | anyone with the site-wide password (3g-1) | everyone | The dev site is a local trial; staging holds unfinished work. | Staging: 3g-1, from outside. |
| Mail | caught by Mailpit (`config/dev-mu-plugins/`) | Brevo through FluentSMTP, being set up (D24) | the same as staging (D24) | The dev site must never send real mail. | Dev: `booking-form.spec.ts`. Staging and live: step 8's test request. |
| Spam check (Turnstile) | stand-in keys and a simulated Cloudflare (`config/dev-mu-plugins/`) | the user's real keys, in the admin | the user's real keys, in the admin | Tests run without the network; real keys stay out of the repository. | Dev: `booking-form.spec.ts`. Staging: 5e. |
| Content | neutral test pages and three sample songs (`tests/dev-content/`) | the real pages and 108 songs, imported from `data/` | its own real content | Each site keeps its own content (`CLAUDE.md`, Terms); the repository holds no real data. | Dev: the browser tests. |
| Yoast's site details and the site icon | a stand-in Organization, "Dev site organization", with the theme's logo imported (`bin/dev-site`, 8h), so the theme's addition to it can be tested; otherwise Yoast's defaults | an Organization, "Howard Buie Music", with the logo; the sharing image; Site Title "Howard Buie Music" (step 6); the site icon (Settings → General, 5f) | the same, set at step 9 | They are real content, which the dev site does not hold; the settings that are code-like (author archives, tracking) are the same everywhere. | Staging: the page source, checked by hand (step 6). Live: step 9. |
| Admin account | `devadmin`, password in `.env` | its own admin, two-factor login required (3g-1) | its own admin, two-factor required at step 8 | The dev site is rebuilt from nothing each run. | Staging: 3g-1. Live: step 8. |
| Wordfence | not installed | installed (3g-1); security updates by Hostinger, the rest by hand (8j) | installed (D25); the same (8j) | A firewall and login limits protect sites the internet can reach. | Staging: 3g-1. |
| Updates | none: versions pinned and rebuilt (`tools/versions.sh`) | Hostinger's Smart auto-updates, set to security updates only for WordPress, themes and plugins, with WordPress's own updates turned off by its must-use plugin; the rest by hand in the monthly check (8j) | the same, by hand after staging (8j) | It belongs to the host; a release that is not a security fix is tried on staging first. | Both: the monthly check (`docs/ROUTINES.md`, step 6). |
| Backups | none: rebuilt by `bin/dev-site` | none: code from `main`, content from `data/` | Hostinger daily, plus the user's content exports into `data/` (D27) | Only live holds content that exists nowhere else. | Live: a restore at step 9 (checklist 12.3). |
| Security headers | the Site Hardening plugin (D26) | the same plugin, deployed (8a) | the same plugin, at step 9 | Same everywhere: the plugin deploys with the code. | Dev: `theme.spec.ts`. Staging: after the deploy (8a). Live: step 9. |
| Hostinger's CDN | none | off (hPanel, seen 2026-11-10) | on (hPanel, seen 2026-11-10) | Only live has visitors to speed up. Wordfence on live reads visitors' addresses from `REMOTE_ADDR`, which the server fills in behind the CDN and a visitor cannot fake (8i). It keeps no copies of pages (`DYNAMIC`), so a deploy shows at once; browsers keep static files up to 7 days, which matters only for pictures (8l). | Live: Wordfence's Diagnostics, by the user (8i). |
| A second policy from the server | none | `upgrade-insecure-requests`, added by Hostinger's server to every response (8a) | to be checked at step 9; likely the same | The host's choice; browsers apply both policies, and this one only turns `http://` addresses into `https://`, so it loosens nothing. | Staging: `curl` behind the site-wide password (8a). |
| Server rules: version files refused, no PHP in `uploads/` | none: the dev site's own Apache, never public | in `.htaccess` and `wp-content/uploads/.htaccess`, by hand (8k) | at step 9, the same by hand | Server files, not code: the deploy reaches only the theme and plugin folders. Until step 9 a temporary difference. | Staging: from outside and a test file (8k). Live: step 9. |
| Avatars | off (`bin/dev-site`) | off (set by the user, 8e) | off, at step 9 | Same everywhere; listed because the dev site's build sets it while staging and live are set by hand. | Dev: `admin-view.spec.ts`. |
| Uptime monitoring | none | none: its site-wide password answers every check with 401 | HetrixTools, every minute from 4 locations, alerts by Pushover, certificate and domain expiry (8m) | Only live has visitors to lose; staging's lock would make every check fail. | Live: a planted failure, both alerts received (8m). |
| Plugin versions | pinned in `tools/versions.sh` (Contact Form 7 6.2.4.1, Yoast SEO 28.8) | as installed and updated there | as installed and updated there | The dev site must be the same every run. | Weekly on GitHub (`bin/versions-check`, `versions.yml`, 8j): a plugin behind WordPress.org gets a tested pull request, the theme an issue. |
