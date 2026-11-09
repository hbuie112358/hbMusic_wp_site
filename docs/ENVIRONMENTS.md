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
| Yoast's site details | none: Yoast's defaults | an Organization, "Howard Buie Music", with the logo; the sharing image; Site Title "Howard Buie Music" (step 6) | the same, set at step 9 | They are real content, which the dev site does not hold; the settings that are code-like (author archives, tracking) are the same everywhere. | Staging: the page source, checked by hand (step 6). Live: step 9. |
| Admin account | `devadmin`, password in `.env` | its own admin, two-factor login required (3g-1) | its own admin, two-factor required at step 8 | The dev site is rebuilt from nothing each run. | Staging: 3g-1. Live: step 8. |
| Wordfence | not installed | installed, auto-updates on (3g-1) | installed (D25) | A firewall and login limits protect sites the internet can reach. | Staging: 3g-1. |
| Hostinger's auto-updates plugin | not installed | installed (mu-plugin, 3g-2) | installed (D15) | It belongs to the host. | |
| Backups | none: rebuilt by `bin/dev-site` | none: code from `main`, content from `data/` | Hostinger daily, plus UpdraftPlus off-site (D25, step 8) | Only live holds content that exists nowhere else. | Live: a restore at step 9 (checklist 12.3). |
| Security headers | `config/security-headers.conf`, read by the dev site's Apache | not recorded; checked at step 8 | the same lines, at step 8 | One file for every site. | Dev: `theme.spec.ts`. Live: step 8. |
| Plugin versions | pinned in `tools/versions.sh` (Contact Form 7 6.2.4.1, Yoast SEO 28.8) | as installed and updated there | as installed and updated there | The dev site must be the same every run. | Open: how the pins follow live's updates is decided with updates at step 8. |
