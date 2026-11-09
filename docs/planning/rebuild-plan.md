# Rebuild plan

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Rebuilding the site on a Twenty Twenty-Five child theme, then moving it to a new host. Worked
in rolling-wave mode (`~/.claude/ROLLING_WAVE_MODE.md`): near steps in detail, later ones rough,
new findings added as steps.

## Current position

- **Where the work stands:** steps 0-2 done; 3a (the local copy in Docker Compose, 7555e34),
  3b (local mail into Mailpit through FluentSMTP, f389f76), 3d (code checks, `bin/check`,
  14e8788), 3e (tests, `bin/test`, 69ace60) and 3f (checks in GitHub, public repository,
  branch protection, and the Dependabot follow-up) done; 3g-1 (the staging site) and 3g-2 (the
  restricted deploy key) done on 2026-11-03, with the review of `docs/SITE_CHECKLIST.md`, and
  3g-3 (the deploy to staging after every merge to `main`) on 2026-11-04;
  step 4 (the child theme, the dev site, its tests, and those tests as a required check on
  GitHub) done on 2026-11-04; 3h dropped by the user. The old site is still live, secured.
- **Findings:** the live site's email is unreliable (step 8 brings a mail service); the login
  log shows no break-in; the live site's PHP and plugins are current since step 0f
  (2026-11-02), and the old staging copy is removed (0g).
- **Hostinger plan:** expires 2028-07-16, auto-renewal off (the user, from Billing →
  Subscriptions, 2026-11-02). SSH is on since 3g-2; its only key is restricted to staging's
  theme and plugin folders, and password logins cannot be switched off (3g-2).
- **Hosting (D15):** the new site goes live at Hostinger; the move to another host is step 10.
- **Done 2026-11-07:** 5a (the song list plugin, deployed, the 108 songs imported on staging),
  5a-2 (the old-site copy removed, D20) and 2b (the pages, D22, and the look, D23).
- **Next:** step 6, the plugin set (D25): Yoast SEO on the dev site with its tests, then on
  staging. The mail service (D24, Brevo) waits on Brevo's support: the domain does not
  authenticate although all four records verify and are correct in public DNS, and transactional
  sending needs Brevo's activation (one ticket for both, opened by the user on 2026-11-09); then
  continue at "Brevo setup, where it stands" in step 8. 5f's pages are on staging; the user's video choices and wording follow.
  3i whenever the user chooses. The live deploy's design is recorded in step 9 (option B, the user's
  approval before live). The live site's text still names the old service area (D22); the user
  chose to leave it until go-live, since the site has little traffic (2026-11-07).
- **Order of the coming steps (D19, replacing D11's; 6 moved first on 2026-11-09 while Brevo's
  support answers):** 6 → the mail service (8) → the rest of 5e → the rest of 8 → 9 → 10.
- **Future, not needed for go-live (D19):** the clip request plugin (5b, 5c) and the setlist
  preferences plugin (5d). **The template (D21)** starts when a second site has a date.
- **Open decisions waiting on the user:**
  - the new host (step 10, before 2028-07-16).
- **Site checklist (D16):** `docs/SITE_CHECKLIST.md` (named `BEST_PRACTICES.md` until
  2026-11-03) is the draft of WordPress additions for a shared global file; until anything moves
  there, it is this project's checklist. Reviewed with the user on 2026-11-03 and committed: 89 items, each with
  its check, its kind (general, WordPress or shop) and its status (done, in force, partly,
  planned with its step, or not applicable); a section for shops (WooCommerce, for the template)
  and a list of practices deliberately not used.
- **Stale documents:** in `docs/SITE_CHECKLIST.md` (2.7, 6.4, 8.3, 10.1-10.3) and
  `docs/planning/findings/step-02-inventory.md` ("What the new site must cover"), references to
  5b, 5d and song years, genres and energy predate D19: the form at go-live is now 5e, and the
  rest is future work. The checklist's and earlier steps' mentions of `bin/local-import`, the
  local copy and Mailpit describe what was true before 5a-2.

## Decisions

| # | Decision | Why |
|---|---|---|
| D1 | The new theme is a child theme of Twenty Twenty-Five, in `themes/hbmusic-child/`. | `music-lite` is unmaintained; Twenty Twenty-Five is a maintained default theme, and a child theme keeps the site's changes apart from its updates. |
| D2 | `backups/` and `wordpress/` are never changed; experiments run on copies. | They are the only full copy of the old site. |
| D3 | Git versions an allow-list only (see `.gitignore`). | The export holds credentials, database dumps and host account identifiers. |
| D4 | The export's local leftovers (open item 1) are not carried to the new host. | They are local development files, not part of the site. |
| D5 | Commits use the GitHub noreply address, set for this repository only. | Keeps the personal email address out of the history. |
| D6 | The site's domain may appear in notes and plans (`CLAUDE.md`, the plan, `project-state.yaml`). | The domain is public; leaving it out protects nothing. Secrets, dumps, host account numbers and server paths stay out of the repository. |
| D7 | Theme code never hardcodes the domain; it asks WordPress (`home_url()`, `get_theme_file_uri()` and similar). | The same theme then runs unchanged locally, on staging and live; a hardcoded domain breaks on every move. Server settings that name the domain live on the server, not in the repository. |
| D8 | Song clips go out only on request, approved with one click by the user (not sent automatically, not published). Fully automatic sending is a possible later change, needing an email confirmation step, limits per address and per day, and spam protection. | The user sees every request (which songs a prospective client wants), bots and forged addresses cannot make the site send mail to strangers, and clips are not handed to unknown people, which keeps the licensing question small. |
| D9 | Each song stores its release year and one of two genres, Rock/Pop or Country. Decades (1970s, 1980s, ...) are worked out from the year where shown. | The user plays rock/pop and country; two genres keep tagging easy. The era dial (5d) weights songs by distance from a chosen year, which needs the year, not only the decade. The old site already grouped its videos by decade. |
| D10 | Each song also stores an energy rating from 1 (mellow) to 5 (high energy); every setlist dial (genre, era, energy) has a "no preference, the user's call" option. | The client can set the feel of the set; energy is how the song lands in the user's own acoustic version, so the user rates it (Claude's pre-filled values are labelled as guesses). Skippable dials keep the page simple and show what the client cared about. |
| D11 | The technical groundwork comes before the content and design session (2b): the local environment, the theme skeleton, songs as data, and the logic of the requests and dials, which a visitor does not see. What a visitor sees waits for 2b. | The user prefers to have the technical parts in place first; 2b then reacts to sample pages built on the real songs and working features, and nothing visible is built twice. **The order is replaced by D19's (2026-11-07):** with the clip and setlist features moved to future plugins, no logic of 5b or 5d comes before 2b. |
| D12 | The local copy runs in Docker Compose, set up in the repository (`compose.yaml`, `bin/local-import`), with this project's ports in the 101xx block, bound to `127.0.0.1`. | It reproduces the live database version, includes a mail catcher, can be read by a reviewer and run the same way in CI; wp-env (the WordPress project's tool) has no mail catcher, a desktop app cannot be reviewed or reproduced. The 101xx block keeps clear of the 80xx and 90xx ports other projects use. |
| D13 | FluentSMTP sends the site's mail, locally to Mailpit and live to the mail service of step 8; it supports plain SMTP and the main services' APIs. | Chosen by the user over WP Mail SMTP: fully free with no paid tier or upsells, and an email log included. Accepted cost: its connection settings live in the database, so the import saves them through the plugin's own code, and `bin/local-mail-check` catches a format change after an update. WP Mail SMTP would have allowed all settings in `wp-config.php` but keeps the log for its paid version. (The check named here became `tests/scenario/mail-delivery.sh`, run by `bin/test`, in step 3e.) |
| D14 | The deploy pipeline is built now, against a staging subdomain at the former host, and re-pointed to the new host at step 9; deploys go through GitHub (checks first, then SSH), not a host's own deploy feature. | Proves the pipeline on a real host early, so the move is routine; a staging target keeps the unfinished theme away from the live site; GitHub-based deploys work with any host offering SSH, so switching hosts means changing three secrets (address, key, folder). |
| D15 | The new site goes live at Hostinger, where the plan is already paid until 2028-07-16; the move to another host becomes step 10, before then. Supersedes the original assumption that the site leaves Hostinger before going live (D14's "re-pointed at step 9" now happens at step 10). | Avoids paying two hosts at once. Hostinger meets the conditions checked on 2026-11-02: PHP 8.2-8.5 selectable, SSH included in the plan, outgoing mail ports open; the pipeline (3g) keeps the later move routine. |
| D16 | `docs/BEST_PRACTICES.md` holds the WordPress-specific practices, as candidates for a shared `~/.claude/WORDPRESS_STANDARDS.md` (alongside the Java and Go files). A rule that seems to apply to every project is only proposed for the global files: Claude asks the user specifically each time and changes nothing there without the user's yes for that change. The first one, "secrets stay out of repositories and output", went into `WORKING_STYLE.md` on 2026-11-02 after the user approved it. (2026-11-03: the file was renamed `docs/SITE_CHECKLIST.md`, since "best practices" could mean coding style or design; it covers security, accessibility, performance and operations. Each item is marked general or WordPress, so if it ever moves, the WordPress items go to the WordPress file and each general item is proposed for a global file on its own. Whether `WORDPRESS_STANDARDS.md` is the right name, next to the coding-style files `JAVA_STANDARDS.md` and `GO_STANDARDS.md`, is decided then.) | The user builds WordPress sites as a service provider, so these practices will repeat in other projects; one shared file avoids copies drifting apart. |
| D17 | The GitHub repository is public from its first push, created only after step 0f (the live site's plugins and PHP updated) and a read of the plan and findings for any weakness of the live site that is still open; branch protection then requires the checks before a merge. | Public gives free branch protection, unlimited Actions minutes and a portfolio from the start; the history search before the push found no personal data or secrets. Publishing an open weakness of the live site would hand attackers a shortcut, and a pushed history cannot be taken back, so the push waits for 0f. Excluding the planning documents instead would mean rewriting the whole history and losing the plan's versions. |
| D18 | The project stays template-ready, and the template for further WordPress sites becomes a project of its own later, extracted from this one into a fresh repository (no history) and offered as a GitHub template repository. Meanwhile, each step that touches something another site would set differently adds a line to `docs/planning/template-notes.md`, and site-specific values stay in settings rather than code. Whether to start the template project is looked at again at the end of step 4. A template for WooCommerce sites comes from a real WooCommerce project, not from this one. | A template designed in advance guesses what is generic; one extracted from a working project starts out proven. Separating generic from site-specific is cheapest while each piece is written. After step 4 the generic part (tooling and theme skeleton) is complete; what follows is this site's own. This repository's history holds the plan and site details, so the template does not inherit it. WooCommerce adds payments, customer accounts and orders, with their own rules. **The timing is replaced by D21 (2026-11-07).** |
| D19 | Features become separate plugins (the user, 2026-11-07). The song list plugin (5a) is built now, with a general name and nothing specific to this site, so it can be changed on its own, added to a site or not, and shared. Clip requests with emailed clips (5b, 5c) and setlist preferences (5d) are future plugins, not needed for go-live; each needs the song list plugin and adds its own fields to songs (the clip; year, genre and energy). Video is always linked from YouTube, never stored on the site. Go-live has a plain booking form (5e). The order: 5a → 5a-2 → 2b → the visible parts of 5, with 5e → 6 → 8 → 9 → 10. | Year, energy, approval, expiring links and a real cron job existed only for those features. A site that wants only a song list never sees their fields, the plugin stays small enough to share, and the unmaintained old theme leaves the live site sooner. D8, D9 and D10 stay as the design of those future plugins. |
| D20 | The old-site copy is removed after the songs are converted (5a-2): `compose.yaml`, `bin/local-import`, the `local` test group, and what was built only for it (FluentSMTP's local setup, its script, tests and stubs). `backups/`, `db/` and `wordpress/` stay untouched. Replaces D12's old-site copy, not its Docker Compose and port choices, which the dev site keeps. FluentSMTP stays the live site's mail plugin (D13). | The copy assumed the rebuild needed the old site running locally and mail tested there. Since step 4 the new theme has its own dev site, the real old site is still online to look at, and the copy's tests check a frozen dump that no theme work can break. |
| D21 | The template project starts when a second site has a date, not now (the user, 2026-11-07). `template-notes.md` keeps collecting what it must set differently. | Built after go-live, it starts with the plugin setup, live deploy and mail already proven, without 2-3 hours of carrying them over and a second repository to keep updated. Plugins in their own folders keep separation easy later. |
| D23 | The site's look is "On Stage" (the user, 2026-11-07, chosen from three looks built on the real photo, logo and draft wording): a black page in which the photo blends, warm white text, and green from the logo for buttons and the booking band, using the parent's Manrope font. It lives in the child theme's `theme.json` and `parts/`. Wording is refined later in the admin. The current 885-pixel photo is used, without upscaling. | The user preferred it to the warm cream and black-and-white looks. Styles stay in `theme.json` (checklist 6.1), so no separate CSS file and no Stylelint yet; a CSS file would bring that up again. |
| D24 | Site mail goes through a mail service, Brevo, connected by FluentSMTP (D13), for this site and as the pattern for every site (the user, 2026-11-07). Brevo's retention rule is set to 3 months and its email previews stay off. FluentSMTP keeps copies of failed mail only; requests that arrive are kept in the user's Gmail. | Gmail through Google's API was tried first: publishing the Google app needs a public home page and privacy policy, which a site that is not yet live does not have, and a Google project per site. A mail service needs only DNS records, the same before and after launch. Brevo over SMTP2GO: its delivery records are kept as long as the retention rule says, where SMTP2GO's free plan shows 5 days. |
| D25 | The plugin set for go-live (the user, 2026-11-09): Wordfence stays; Yoast SEO stays, and also runs on staging and on the dev site (pinned and checked against WordPress.org's checksums, like Contact Form 7), with tests of what it is set to do; UpdraftPlus stays as the off-site backup, its destination, schedule and encryption set at step 8; Hostinger's auto-updates plugin and mu-plugin stay while the site is at Hostinger (D15); FluentSMTP (D13, D24), Contact Form 7 (5e) and Song List (5a) as chosen. | Wordfence alone gives two-factor login and the firewall. Keeping Yoast keeps its settings if step 9 updates the live site in place; on staging and the dev site it is checked before live, like every other plugin. Hostinger backs up the live site daily (the user, 2026-11-09), but at Hostinger, and checklist 12.1 wants a copy off the server. |
| D22 | The site is built around one visitor, someone deciding whether to hire the user for an event (the user, 2026-11-07). Five pages: Home, Music (replaces Video and the empty Audio page), Songs (the address stays `/songlist/`), About, Book (replaces Contact). `/video/`, `/audio/` and `/contact/` redirect to the new pages; the sidebar and the empty "Audio and Video" page go. The service area is now Fayetteville, North Carolina, and surrounding areas, including Southern Pines, not the Mid Ohio Valley. | Every page then helps a visitor hear the user and make contact. The live site's text, tagline and search details still name the old area, and the inventory (step 2) describes that old text. |

## Steps

0. **Secure the old live site** (urgent while it is online; open item 1). Status: `[x]`
   - 0a. Admin account: new password, two-factor login, real email, only account. `[x]` 2026-11-02
   - 0b. Header-only check of the leftover paths: five returned 200 (zip with 73,947,771 bytes,
     `local.sql`, `local-site.json`, `conf/`, `logs/`); `local-xdebuginfo.php` returned 500.
     `[x]` 2026-11-02
   - 0c. The user deleted the six items in the host's File Manager; the check again returned 404
     for all, with the home and login pages still 200. `[x]` 2026-11-02
   - 0d. The live secret keys and salts match the exposed zip's `wp-config.php` (five of eight
     compared, all the same; the database login differs). The user replaced all eight with new
     ones from the WordPress.org generator; home and login pages still 200. The next login asked
     for no 2FA code: Wordfence's remember-device setting (on, 30 days) uses its own key, not the
     WordPress salts, so the remembered device stayed valid. `[x]` 2026-11-02
   - 0e. ~~The host's access logs, for downloads of the leftovers.~~ Dropped by the user
     (2026-11-02): everything the leftovers exposed was already treated as known to others and
     replaced, so the logs could not change any action; they also cover only a short recent
     period of an exposure that lasted since at least 2025-01.
   - 0f. Plugin updates on the live site (found 2026-11-02): WordPress 7.1.4 is current, but
     Wordfence 8.0.5 (latest 9.0.2), Yoast SEO 28.1 (28.8), UpdraftPlus 1.26.13 (1.26.14) and
     the inactive Twenty Twenty-Five 1.2 (1.5) are behind; Hostinger's updater updates
     only WordPress itself. Then the PHP version: hPanel shows 8.1 (2026-11-02), without
     security fixes since the end of 2025 and no longer selectable once changed; ~~the version
     applies to every website on the plan, so the staging site (3g) shares it~~ (corrected
     2026-11-03 in 3g-1: each website has its own version; the new staging site started on 8.3
     and was set to 8.4. A PHP upgrade can therefore be tried on staging first). Sequence: (1) the
     user takes a fresh Hostinger backup (Files → Backups → Generate new backup; one per 24
     hours) and downloads it into `backups/2026-11-02/`; (2) the user updates the plugins in
     Dashboard → Updates; (3) the user selects
     PHP 8.4 in Websites → Manage site → Advanced → PHP Configuration; (4) Claude checks the
     pages and the login. A restore undoes (2) but not (3): the PHP version is not in the
     backup, so a PHP problem is fixed by choosing 8.3 or 8.2. Already tested: the local copy is the old site on PHP 8.4, all pages
     200, one deprecation notice. Done 2026-11-02: the backup (files, database) checked
     complete and containing the day's security changes, made read-only in
     `backups/2026-11-02/`; Wordfence 9.0.2, Yoast SEO 28.8, UpdraftPlus 1.26.14, Twenty
     Twenty-Five 1.5; PHP 8.4.27; all public pages, the login, the admin and the sitemap 200,
     no PHP error text, 108 songs with artists. `[x]` 2026-11-02
   - 0g. The old staging copy (`/staging/`, found during the public-repository read-through):
     its login page answered publicly, with no Wordfence or two-factor login, Yoast SEO 24.2,
     and the live login name. Its database was downloaded (read-only in `backups/2026-11-02/`),
     then the user deleted it with Hostinger's staging tool; all `/staging/` paths now 404,
     the live site unaffected; the user confirmed its database is gone too. Open item 2
     settled; step 7 no longer needed. A correction on
     the way: WordPress password hashes are salted, so comparing them cannot tell whether two
     passwords are equal; an earlier remark that the exposed `local.sql` did not reveal the live
     password was not justified (irrelevant for the live site since its password changed on
     2026-11-02; any other place using the old password needs a new one). `[x]` 2026-11-02

1. **Project setup.** Layout, the project's `CLAUDE.md`, allow-list `.gitignore`,
   `project-state.yaml`, git. Status: `[x]` 92dd157
2. **Inventory the old site.** What `music-lite` shows (pages, menus, widgets, customizer
   settings, any shortcodes) and what `music-lite-child` changes (open item 4); the result is the
   list of what the new theme must cover. Needs only `db/` and `wordpress/`, no running site.
   Comes before step 3 because what it finds (plugins that must run, forms, embeds) shapes the
   environment. Findings: [findings/step-02-inventory.md](findings/step-02-inventory.md);
   `music-lite-child` is empty, so open item 4 is settled. Status: `[x]`
2b. **Content and design session.** First the content: what each page is for and what a visitor
   booking a musician needs to find fast, including the booking form (5e); the request pages of
   5b and 5d are future work (D19). Then 2-3
   visual directions as clickable sample pages with the real content and photos, for the user to
   react to; the chosen one becomes the child theme's `theme.json`. *Why:* the user does not yet
   know what the site should look like, and choosing from real examples is easier than
   describing a look. Found in the review of 2026-11-07, for this session:
   - **What someone booking needs:** listenable music (the Audio page is empty), event types and
     service area, testimonials, a clear way to book on a phone, a Google Business Profile, and
     whether to have analytics at all.
   - **A quicker way to choose:** Twenty Twenty-Five ships 8 style variations (counted in the
     exported 1.2) that can be tried on the real content before building any sample by hand.
     Twenty Twenty-Six could not be checked then; compare it here.
   - **Design lives in files (rule for this project from here on):** edits saved in the Site Editor
     go into the database and override the theme's files, so a later deploy can seem to do nothing.
     Design changes go through the theme's files; a Site Editor trial is copied into them and reset.
   - **The user's answers (2026-11-07):** all kinds of events are welcome; the area stays as in D22;
     no testimonials for now (the user may check Facebook for some later); the user chooses the
     videos later; a newer photo is coming; the email address stays, and no phone number is shown.
     The Book page's form (5e) emails the user when a visitor sends it, beside the address and
     Facebook link.
   - **Done 2026-11-07:** the pages (D22) and the look (D23). Not versioned: web-sized images in
     `data/photos/web/`, the three looks' screenshots in `data/design-samples/`. The pages
     themselves continue in 5f.
   Status: `[x]` f47fd0d
3. **Local environment.** Choose how to run the site locally from `db/` and a copy of
   `wordpress/` (the database import needs the site URL replaced), and the test tools for each
   level of `TESTING_APPROACH.md`, covering what the step 2 inventory found. Includes a local
   mail catcher, so the request form's emails can be tested without sending real mail. Record
   them in the project's `CLAUDE.md`. Chosen by the user: Docker Compose (D12). Status: `[x]` (3c folded into 4, 3h dropped, 3i optional and open)
   - 3a. **The stack and the import.** `compose.yaml` (WordPress 7.1.4 on PHP 8.4, MariaDB
     11.8.9 as live, Mailpit, WP-CLI), ports 10100 and 10101 on `127.0.0.1` only, `.env` from
     `.env.example` with random secrets, `bin/local-import`. The old site's files go from the
     read-only `wordpress/` straight into a volume, so nothing is written into the project
     folder. Verified: all pages 200, no live-domain references, only Yoast active, no
     password in the output (a first run printed the local admin password through WP-CLI's
     `--prompt`; fixed and the password replaced). The import empties what the local copy does
     not need: Wordfence's logs and caches (visitors' IP addresses), the live login's
     two-factor secret and sessions. It checks every setting first and stops with a clear
     message when `.env` is missing but the database volume exists. One PHP deprecation notice from
     `wp-includes/formatting.php` (`ltrim()` given null), probably the old theme on PHP 8.4;
     caller not traced, not fixed (the theme is replaced). Status: `[x]` 7555e34
   - 3b. **Mail into Mailpit (D13).** The import installs FluentSMTP at a pinned version
     (`FLUENT_SMTP_VERSION`), checks it against WordPress.org's checksums, and saves a Mailpit
     connection through the plugin's own save code (`local/wp-cli/configure-fluentsmtp-mailpit.php`,
     which refuses to run outside a local environment). `bin/local-mail-check` (moved to `tests/scenario/mail-delivery.sh` in 3e) sends a message
     with a unique marker and waits for it in Mailpit. Failures met and fixed on the way:
     `declare( strict_types=1 )` is rejected under `wp eval-file`; WP-CLI had no writable cache
     folder; the import's error message now names the failing step. The check also failed, as
     it should, while FluentSMTP had no connection. The port setting is checked to be 1-65535. Status: `[x]` f389f76
   - 3c. **File-permission check:** folded into step 4 by the user (2026-11-02): the import
     keeps container-written files in volumes, so the theme folder mounted in step 4 is the
     only thing left to test, and it exists only then.
   - 3d. **Code-quality tools in a container.** `composer.json` and `composer.lock` (tools only,
     never deployed), `phpcs.xml.dist` (WordPress Coding Standards, prefix and text domain
     `hbmusic`), `phpstan.neon.dist` (level max, PHP 8.4, WordPress 7.1 stubs), `bin/check`
     (all checks in one run). The editor's SonarQube rules `php:S100` and `php:S105`, which
     contradict WordPress style, are off in the user's VS Code user settings (the extension
     ignores a project's `.vscode/settings.json` for rules; a first attempt there had no
     effect and was removed). Versions: PHPCS stays on 3.x because WPCS 3.4.1 requires it; PHPCompatibility is
     left out (its released 9.x knows PHP only up to 7.4; PHPStan's PHP 8.4 setting covers
     much of it); the WP-CLI stubs are hand-written in `tools/phpstan/stubs/`, because
     php-stubs/wp-cli-stubs 2.12.0 accepts WordPress stubs only up to 6.x (replace when it
     supports 7.x), and FluentSMTP publishes none. Verified: all checks pass; planted faults
     (unprefixed function, unescaped and unsanitised input, a type error, two shell mistakes)
     made PHPCS, PHPStan and ShellCheck fail as they should; files Composer wrote belong to the
     user and none is world-writable. Review fix (MEDIUM): each tool container sees only the
     files its step needs, never `.env`, `db/`, `backups/` or `wordpress/`, with
     `composer.lock` read-only; `bin/tools-update` is the deliberate way to update the lock.
     Proven by listing what each container sees. Accepted LOW items: hand-written stubs can
     drift (each names its source); `composer:2.11.1` is days old; PHPCompatibility waits
     for its version 10. Status: `[x]` 14e8788
   - 3e. **Test levels.** `bin/test` runs the scenario checks (`tests/scenario/`, bash with a
     shared `lib.sh`; bats was not used because its container would need the Docker socket):
     mail delivery (moved from `bin/local-mail-check`) and the configuration script's safety
     stops (not local, missing setting, invalid port, nothing saved), the MEDIUM finding
     deferred from 3b. Then the browser tests (`tests/e2e/`, Playwright 1.64.1 in its official
     container on the host network, seeing only `tests/e2e/`): menu entries and pages, no
     reference to the live site on any public page, all 108 songs with artists. `bin/check`
     gained a TypeScript check (7.0.2, strict) and an npm audit; `bin/tools-update` updates
     the npm lock too; tools are called with `npx --no-install`. Changed by the user's
     decision: PHPUnit moves to 5a with its first real tests; axe accessibility checks to step
     4. Verified by planted faults: each browser test, the guard scenario and the TypeScript
     check failed on a fault and passed after restoring. On the way: two planting commands of
     Claude's were wrong (a menu named instead of its ID; WP-CLI lists menu items only with
     the theme loaded); the live-domain test first checked only menu pages, so a page removed
     from the menu escaped it; it now checks a fixed list of all public pages. Review fixes:
     `npm ci --ignore-scripts`; the image versions in one file (`tools/versions.sh`), with a
     check that the Playwright image and package match; `instanceof` instead of casts; Compose
     output kept out of failure messages. Accepted: the Playwright container's host
     networking (needed to reach the site). Status: `[x]` 69ace60
   - 3f. **Checks in GitHub (D17).** `.github/workflows/check.yml` runs `bin/check` on every
     push to `main` and every pull request: read-only repository access, the checkout action
     pinned by commit (v7.0.1), the token not kept, a 20-minute limit, older runs cancelled.
     `bin/check` gained actionlint (1.7.12) for the workflow files; shown to fail on a planted
     typo. `bin/test` stays local until step 4 (it needs the local copy built from the backup;
     the new theme's browser tests will run on a fresh WordPress with scripted content). The
     history search before the first push (31 commits) found no personal data or secrets.
     The user's plan is GitHub Free, where branch protection exists for public repositories
     only. Review fix: a weekly scheduled run, so the audits catch new advisories without a
     code change. Follow-up after the first push: Dependabot update pull requests for the
     GitHub action, Composer and npm (the images in `tools/versions.sh` and `compose.yaml`
     stay manual). Public repository created and pushed on 2026-11-02 after step 0f and the
     read-through (D17): https://github.com/hbuie112358/hbMusic_wp_site; the first run passed
     all 11 checks in about a minute; branch protection on `main`: the `check` workflow
     required and up to date, also for administrators, no force-push or deletion, linear
     history. Status: `[x]` aa2f1f2
     - **Follow-up: Dependabot** (`.github/dependabot.yml`). Weekly, it proposes updates of the
       checkout action, the Composer tools (one grouped pull request) and the browser tests' npm
       packages (one grouped pull request), each as a pull request that runs `check` and waits for
       the user; it never merges. New releases are proposed only after 7 days (hijacked releases
       are usually pulled within days). Dependabot alerts and security updates are switched on
       in the repository settings (2026-11-02): an advisory against a pinned version raises an
       alert and a fix pull request at once, without the wait. Left out on purpose:
       PHP_CodeSniffer 4 (WPCS needs 3), minor and major updates of the WordPress stubs (they follow
       the site's WordPress version), Playwright (must match its image), and the container images
       in `tools/versions.sh` and `compose.yaml` (by hand; Dependabot cannot read the script, and
       its Docker Compose support was not taken up). Before Claude recommends a merge, it reads the
       release notes and the lock-file changes (`~/.claude/AI_SECURITY.md`, section 4).
   - 3g. **Deploy pipeline to a staging site at Hostinger (D14, D15).** The public GitHub
     repository (D17) (the whole history searched for personal data before the first push; the
     user creates it from commands Claude gives); the checks of 3f run first; then GitHub
     packages the theme and site plugin and copies them over SSH, with a key used only for
     deploying, to a staging subdomain's folder only, checked before copying so a wrong
     setting cannot touch the live site. (The old `staging/` install was removed in 0g; the
     target is a new staging site.) SSH is included in the user's plan (the user enabled it on 2026-11-02 to
     check, then turned it off until this step); Hostinger's SSH port is 65002; the pipeline
     logs in with a key, not a password. PHP comes from step 0f. The new staging site (after the
     old copy's lessons, 0g): a fresh WordPress, not a copy, with its own admin (strong
     password, two-factor login); the whole site behind a server-level password, so its login
     page is not reachable from outside (Hostinger's directory protection, to verify here);
     plugins kept as current as live; not indexed; test data from scripts, no live data.
     Split by the user's choice (2026-11-03), in the order 3g-1 → 3g-2 → the start of step 4 →
     3g-3, since the pipeline needs the theme skeleton to deploy. Found on the way: on
     Hostinger's shared hosting one SSH user owns the whole account, the live site included, so
     an unrestricted deploy key would reach the live site; and no third-party actions are needed
     (the runner has `ssh` and `rsync`). Status: `[x]` (3g-1, 3g-2, 3g-3)
     - 3g-1. **The staging site.** The user, in hPanel: a staging subdomain with a fresh
       WordPress, its own admin (strong password, two-factor login), the whole site behind a
       server-level password, not indexed; PHP 8.4 as on the live site. Claude first
       checks Hostinger's documentation for each part, then checks the result from outside.
       Checked 2026-11-03: the domain's DNS is Hostinger's (`dns-parking.com`), so the subdomain
       needs no outside DNS record; it is created with Websites → Add website as an independent
       site (Domains → Subdomains would make a folder inside the live site); WordPress with the
       site's auto-installer; the password with Password Protect Directories, folder field empty
       for the whole site. Name chosen by the user: `staging.howardbuiemusic.com` (public through
       certificate logs, so the name protects nothing; the password does). Sequence: (1) the
       site with WordPress, an admin name that is not easy to guess and not the live one, a
       strong password, the real email; (2) at once the site-wide password, then Claude checks
       401 on every path, the login page included; (3) inside, "Discourage search engines",
       two-factor login as on live, and a look at what Hostinger's installer added; (4) Claude
       checks from outside: 401 without the password, PHP, no indexing, the live site unaffected.
       Done 2026-11-03: the site was created with Websites → Add website → Build on WordPress →
       Build from scratch (no migration, no AI); the wizard's default admin name `admin` was
       changed. The site-wide password covers every path tried (home, login, admin, REST API and
       its user list, `xmlrpc.php`, `readme.html`, `wp-content/`, `wp-cron.php`: all 401, one
       realm), plain HTTP forwards to HTTPS, and the site has no second, temporary address (the
       Websites list shows only the subdomain). The browser may ask for the site-wide password
       twice, as Hostinger documents. Hostinger's installer had added Hostinger AI, Hub, Reach,
       Tools, Preview Domain (three copies), Smart Auto Updates (two copies) and LiteSpeed Cache;
       all deleted by the user (cause of the copies not known; to look at over SSH in 3g-2).
       Wordfence installed with auto-updates on; its firewall optimization skipped on staging
       (it edits `.htaccess`, which holds the site-wide password; see step 8). Two-factor login
       (Wordfence → Login Security, tab Two-Factor Authentication; the roles are on the Settings
       tab) active for the admin and required for the Administrator role; tested by logging in
       again. "Discourage search engines" on. Themes: Twenty Twenty-Five active (Twenty
       Twenty-Three and Twenty Twenty-Four to be deleted). PHP: the site started on 8.3.36, set
       to 8.4.27 like live (step 0f corrected: the version is per website). HTTPS: a Let's
       Encrypt certificate for the subdomain, valid until 2027-02-01. The live site answered as
       before throughout. Status: `[x]`
     - 3g-2. **A restricted deploy key.** The user creates the key on the user's own machine, so
       the private key never passes through Claude or the chat. Its public key is added to the
       server's `authorized_keys` limited to `rsync` into the staging site's theme and plugin
       folders (`rrsync`, if the server allows it; otherwise another safeguard before the key
       goes into GitHub). The server's identity is pinned, and a GitHub environment "staging"
       holds the secrets. Claude checks that the key cannot open a shell or reach the live
       site's folders. Done 2026-11-03, the user running every server and key command, Claude
       writing them and reading the masked output:
       - **The server:** rsync 3.1.3 and Python 3, but no `rrsync` and no Perl (rsync 3.1.3's
         `rrsync` is a Perl script). hPanel offers "Add SSH key" but no switch for SSH password
         logins and no IP allowlist, so the SSH password (shared with FTP) stays the only
         barrier to a shell on the account: it was made long and unique. The duplicate plugin
         copies of 3g-1 were gone; `.dbdumps` is empty. Staging's `mu-plugins/` held Hostinger's
         auto-updater (as on live, kept) and `hostinger-preview-domain.php` (a temporary-address
         feature, always loaded, not on live): deleted by the user, the lock and the live site
         checked afterwards.
       - **The restriction, without `rrsync`:** rsync's daemon mode over SSH. The key's line in
         `~/.ssh/authorized_keys` is `restrict,command="rsync --server --daemon
         --config=~/.deploy/rsyncd-staging.conf ."`; the settings file (outside the web folders)
         names one destination, `staging-child-theme` = staging's
         `wp-content/themes/hbmusic-child` (exactly that folder, so a deploy that tidies its
         destination cannot touch the parent theme), with `list = no`, `munge symlinks`,
         `incoming chmod` (web permissions), one connection at a time and a log. The plugin's
         destination is added at 5a. The empty `hbmusic-child` folder was created for it.
       - **Proven** with the key from the user's computer (`BatchMode`, so no password fallback):
         a shell and another command got only `@RSYNCD: 31.0`; listing destinations showed none;
         an ordinary path to the live site was refused; an unknown destination was refused;
         `../../../` was stripped (the only probe file on the account is inside
         `hbmusic-child`); a normal copy worked with web permissions. The server's log recorded
         each attempt.
       - **The key** (ed25519, no passphrase, for GitHub's unattended use) was made on the
         user's computer; a first one made by mistake on the server was deleted before use.
         It went straight from its file into GitHub's secrets and was then deleted locally; a
         lost or exposed key is replaced, not recovered.
       - **The server's identity:** fingerprint `SHA256:DYKDxoxr9b4vOhY1xphD05FKYXI03SHgfmflIpBvAQ8`,
         seen at the user's first login, at the staging subdomain's address, and again before
         it was stored; the first GitHub run checks it from GitHub's network (3g-3).
       - **GitHub:** environment `staging`, deployments only from protected branches (`main`),
         with the secrets `DEPLOY_SSH_KEY`, `DEPLOY_KNOWN_HOSTS`, `DEPLOY_SSH_USER`,
         `DEPLOY_SSH_HOST`, none at repository level. The port, 65002, is Hostinger's standard
         one and goes into the workflow file. The account's username and server address are in
         the secrets only, never in the repository.
       Status: `[x]`
     - 3g-3. **The deploy workflow.** After `check` passes on `main`, never for pull requests:
       it refuses unless the target folder holds a marker file naming it as staging, copies only
       the allow-listed folders with `rsync`, and ends with a smoke test (the staging site
       answers, behind its password). Shown to refuse on planted wrong settings. Comes after the
       child theme skeleton of step 4, which it deploys first. Built 2026-11-04, with the
       user's choices: the job `deploy-staging` in `.github/workflows/check.yml` runs after
       `check` and `dev-site` pass, only on `main`, for a push or the "Run workflow" button
       (added), never for a pull request or the weekly run, in the `staging` environment; one
       deploy at a time, never cancelled (runs on `main` are no longer cancelled by newer ones;
       pull requests still are). `bin/deploy-staging` writes the key and the pinned server
       identity to a private temporary folder (strict host checking, no password fallback),
       copies `themes/hbmusic-child/` with `rsync --delete` to the one destination the server
       allows, then checks that staging's folder matches the repository file by file
       (checksums) and that a staging page, opened with a check-only login of the site-wide
       password, shows the child theme active. The marker file was dropped: since 3g-2 the
       server decides the only destination, so no setting in GitHub can reach the live site.
       The check-only login (`github-check`, added by the user in Password Protect
       Directories; secrets `STAGING_CHECK_USER`, `STAGING_CHECK_PASSWORD`; the address as the
       environment variable `STAGING_URL`, so the workflow names no domain) passes only the
       outer lock, not WordPress's login; it lives as long as the staging site and goes with
       it (step 10), and is replaced if exposed. Proof planned without a test-only switch
       (`TESTING_APPROACH.md`): the key's restrictions were proven in 3g-2; here, the first
       deploy (its page check failing until the user activates the child theme on staging,
       then passing) and a manual run on a throwaway branch, which the environment must
       refuse. Proven on 2026-11-04: the first deploy on `main` (#12) deleted 3g-2's probe file
       and added the three theme files, the file check passed, and the page check failed as
       expected; the strict host check also passed, the server's fingerprint thus confirmed a
       third time from GitHub's network. After the user activated the child theme on staging,
       the re-run passed all checks. On a throwaway branch with the deploy job's "only on main"
       condition removed (a planted fault), a manual run was refused by the `staging`
       environment ("not allowed to deploy to staging due to environment protection rules")
       before the job got a machine, so no secret was handed out; the branch was deleted.
       Status: `[x]` 347ed5c
   - 3h. ~~**No network for the check tools while they run.** `bin/check` installs packages with
     network access, then runs PHPCS, PHPStan, TypeScript, ShellCheck and actionlint in
     containers without it (`--network none`), so a hijacked tool version that slipped past
     the wait and the checks cannot send anything out.~~ Dropped by the user (2026-11-02): on
     GitHub the run is a throwaway machine with no secrets; locally the tools are pinned,
     updates wait 7 days and are reviewed, and the containers already see no secrets, so the
     remaining risk (a hijacked tool reaching the internet or the home network) was judged too
     unlikely for the work. It is a general supply-chain defense, not an AI-specific one: the
     AI risks nearby (injected commands, invented packages, steering through tool output) are
     covered by `~/.claude/AI_SECURITY.md`, sections 1, 4 and 8, which the network setting would
     not affect. Can be taken up again, for example if a check ever handles a secret.
   - 3i. **Evaluate a behaviour-scanning service for update pull requests** (for example Socket):
     it inspects each new package version as it is published (sudden network access, install
     scripts, scrambled code, a new maintainer) and can comment on Dependabot's pull requests
     before a merge. Checked like any dependency first (`~/.claude/AI_SECURITY.md`, section 4):
     who runs it, what repository access it needs, what it costs for a public repository. The
     user decides whether to take it up. Status: `[ ]`
4. **Child theme skeleton.** `themes/hbmusic-child/` with `style.css`, `theme.json`,
   `functions.php`, activated locally on a copy. Includes the
   file-permission check folded in from 3c: files the user creates in the mounted theme folder
   stay owned by the user and are not world-writable (`DEVCONTAINER_SETUP.md` rule 11).
   The browser tests gain an accessibility check (axe) and a check that fails on any
   Content-Security-Policy violation (`docs/SITE_CHECKLIST.md` 3.2, 6.7, 7.1).
   At the end of the step: the user decides whether to start the template project now (D18,
   `template-notes.md`): decided 2026-11-04, later, after 3g-3, so the template includes the deploy pipeline. Status: `[x]` (4a 0e5ca45, 4b dd9a4da, 4c 80461f7, 4d 350c03c)
   Split by the user's choice (2026-11-04). Found first: activating the theme on the old-site
   copy would break that copy's tests (they check the old theme's menu) and lose the reference,
   so the user chose a second, fresh local site for the new theme, the old-site copy kept as
   it is; the CSP check needs a site that actually sends the policy, or it proves nothing; and
   the checks did not cover `themes/`.
   - 4a. **The theme files.** `style.css` (the header only: "Howard Buie Music", parent Twenty
     Twenty-Five, text domain `hbmusic`, PHP 8.4, WordPress 7.1, GPL-2.0-or-later, no author
     line, all by the user's choice; no domain in the description, the project rule on theme
     code) and `theme.json` (the 7.1 schema and version 3; the design comes in 2b).
     `functions.php` is left out until the theme has its first PHP to hold (loading CSS, or a
     feature): an empty file with only the load guard would be a placeholder. `bin/check`'s
     analysis container sees `themes/` read-only, and PHPCS and PHPStan check it; proven by a
     planted file (an unprefixed function, unescaped and unsanitized input, a type error) that
     made both fail, then passed after its removal. The WordPress coding standards check PHP
     only (WPCS 3.4.1 has no JavaScript or CSS sniffs): ESLint and Stylelint (`@wordpress/scripts`)
     come with the theme's first JavaScript or CSS, and a `theme.json` schema check with its
     content in 2b. Review fix (LOW, fixed at the user's request rather than deferred): a new
     `bin/check` step fails when `theme.json`'s schema version differs from the WordPress
     version pinned in `compose.yaml`, so a WordPress update cannot leave the schema behind
     (the version-free "trunk" schema was not used: it describes WordPress in development);
     proven by a 7.2 schema and a missing schema line. 12 checks now. Status: `[x]` 0e5ca45
   - 4b. **The dev site** (named by the user): a second, separate Compose project
     (`compose.dev.yaml`, `hbmusic-dev`), so it runs alone, also in CI: MariaDB 11.8.9,
     WordPress 7.1.4 on PHP 8.4, WP-CLI, on `127.0.0.1:10102`; the child theme mounted read-only
     into WordPress and WP-CLI. `bin/dev-site` rebuilds it from an empty database each run
     (`wp db reset`, no volumes deleted): WordPress installed, the parent theme Twenty
     Twenty-Five 1.5 installed only if its zip matches the SHA-256 pinned in `tools/versions.sh`
     (WordPress.org publishes no theme checksums; the fingerprint was taken from the download
     and three files compared with WordPress.org's theme repository; user's choice, so section 4
     of `AI_SECURITY.md` is met rather than excepted), the image's other themes and plugins
     deleted, the child theme activated, search engines discouraged, the live permalinks, test
     pages (the old site's page names with neutral text; Twenty Twenty-Five's navigation lists
     them), a fresh debug log, a dev admin. No mail yet (user's choice; it comes with 5b). The
     `.env` handling moved from `bin/local-import` to `tools/settings.sh`, shared by both
     scripts; its safety stop now covers both sites' databases. `bin/test` runs two groups,
     `local` and `dev` (both by default); a group whose site does not answer fails. New
     checks: `tests/scenario/dev-theme-mount.sh` (the permission check of 3c: neither
     WordPress's user nor the container's root can write into the theme folder; on the host
     every file there is the user's and none is writable by others) and
     `tests/scenario/settings-guard.sh` (the `.env` safety stop, run against a temporary path);
     `bin/check` validates both compose files. Proven: the mount made writable (root could
     write), a world-writable file, the site stopped, and the guard removed each made their
     check fail, and passed after restoring from copies; the old-site copy was rebuilt with the
     shared code and all its tests passed. Failures on the way, all in the new code: a first
     planted-fault run tested before Apache had started, so two faults failed for the wrong
     reason (redone, waiting for the site); `run_test` returned success after a failure, so a
     group did not stop when its site was down (fixed); WP-CLI could not rewrite `.htaccess`
     (not needed: the image writes it). Review fix (MEDIUM): the two compose files pin the same
     images twice, so a `bin/check` step fails when they differ (proven with the dev site on
     MariaDB 11.8.8); 13 checks now. Accepted LOW items, each with its moment: files uploaded
     on the dev site would survive a rebuild (none today; if uploads appear, `bin/dev-site`
     empties the uploads folder); `bin/dev-site` deletes every plugin on each build (at 5a, the
     mounted site plugin must be left alone, see 5a); the local admin passwords (settings in
     `.env`, readable only by the user) reach WP-CLI as command-line arguments in both site
     scripts, so they show briefly in the computer's list of running programs (accepted by the
     user: local passwords only, on a single-user computer; handing them over by name with
     `-e` would remove it). Status: `[x]` dd9a4da
   - 4c. **Tests for the dev site.** The Playwright tests run in two projects, `local`
     (`specs/local/`, the old-site copy) and `dev` (`specs/dev/`), each with its own address;
     `bin/test`'s groups run their own. For every test page the dev tests check: it loads
     through the child theme (closing 4a's MEDIUM item: the theme had not been loaded yet); the
     security headers are sent (so the next check cannot pass on nothing); the browser reports
     no Content-Security-Policy violation; axe finds no error at WCAG 2.2 AA. A scenario check
     visits every page and fails on any entry in WordPress's debug log (checklist 6.9). The
     headers live in `config/security-headers.conf` (new folder, allow-listed by the user):
     approach B of the checklist review, on visitor pages only (the admin and login at step 8,
     user's choice); the dev site's Apache reads the file read-only, its headers module switched
     on at start (`a2enmod headers`, user's choice over a custom image). New dependency,
     `@axe-core/playwright` 4.14.0 with `axe-core` 4.14.0 (user's choice), checked first per
     `AI_SECURITY.md` section 4: the exact name in the npm registry, published by Deque (axe's
     makers) since 2021, 19 and 29 days old, no install scripts; added to the lock file with npm
     alone (`bin/tools-update` would also have updated the Composer tools); the lock gained only
     these two. Findings on the way: WordPress core's emoji script starts a `blob:` worker the
     policy refuses, and loads emoji images from WordPress.org's servers; switched off in the
     theme's first `functions.php` by the user's choice (option A, rather than allowing `blob:`
     workers). The header's navigation fell back to WordPress's automatic page list, which nests
     a list in a list (an axe error), because the test content had no real menu: `bin/dev-site`
     now creates one, as the live site will have. axe's failure message now names the
     offending element. Proven by planted faults, each restored: an image without alt text
     (axe failed), an image from a foreign site (the CSP check failed), a PHP warning in
     `functions.php` (the log check failed), the policy header removed (the header test failed
     on every page while the violation test passed, showing why both exist). Checklist 3.2,
     6.6, 6.7, 6.9, 7.1 and 7.5 updated. Status: `[x]` 80461f7
   - 4d. **The dev site's tests on GitHub.** A second job, `dev-site`, in
     `.github/workflows/check.yml`, next to `check` and on the same occasions (every pull
     request, every push to `main`, weekly; the user's choice): the same pinned checkout,
     `bin/dev-site` (a fresh `.env` with new random secrets on GitHub's machine; no backup, no
     secrets), then `bin/test dev`. On a failure, Playwright's traces are kept for 7 days
     through `actions/upload-artifact`, GitHub's own action, pinned by commit (v7.0.2,
     `cf430e03`, 28 days old when chosen; the user's choice). The job becomes a required check
     in branch protection after its first green run (the user's choice). Why on GitHub and not
     only locally: GitHub enforces the gate in front of `main`, on a clean machine, and for
     pull requests that never pass through the user's computer (Dependabot's). Proven on GitHub:
     both jobs green on its pull request (#10; dev-site 1 min 50 s, the permission check also
     passing with Docker as root), `dev-site` then made a required check; a draft pull request
     with a planted fault (#11, images without alt text) turned `dev-site` red on axe's
     image-alt rule while `check` stayed green, GitHub marked it blocked, the traces were
     stored (3.6 MB, 7 days), and it was closed unmerged with its branch deleted. Status:
     `[x]` 350c03c
5. **Rebuild the design and content** in the child theme from the step 2 inventory and the
   step 2b choices (rough; split further after 2b). Known parts:
   - 5a. **The song list plugin (D19).** A plugin with a general name and nothing specific to
     this site (not the theme, so the songs survive a theme change), with a Song type: title and
     artist. The 108 songs are converted from the current Songlist page, where titles and artists
     sit in two separate lists matched only by position. The Songlist page is built from the Song entries.
     *Why:* the user adds songs in the admin instead of editing page text, and can change or
     share the plugin on its own. On the dev site
     (4b), the plugin is mounted read-only like the theme, and `bin/dev-site`'s step that
     deletes every plugin must leave it alone (a LOW item from 4b's review). Built 2026-11-07:
     `plugins/song-list/`, a block in PHP alone (`autoRegister`, WordPress 7.0), no page per song,
     its own PHPCS ruleset, and a check that it names nothing of this site. PHPUnit waits for a
     plugin with real logic. Proven by planted faults. The 108 songs are converted and the user
     checked them (`data/song-list/songs.csv`, not versioned; eight spelling fixes). Deployed with
     the server's new `staging-song-list` destination (#14), and the songs imported on staging with
     WordPress's importer from `data/song-list/songs-import.xml` (first tried on the dev site; a
     second import adds no duplicates). Status: `[x]` faec6a9
   - 5a-2. **Remove the old-site copy (D20),** after the songs are converted: `compose.yaml`,
     `bin/local-import`, `local/`, the `local` test group, the FluentSMTP tests and stubs, and
     their settings. `bin/check`'s checks that read `compose.yaml` move to `compose.dev.yaml`, or
     go where they compared the two sites. `backups/`, `db/` and `wordpress/` stay untouched. The
     `.env` safety stop stays, now against the dev site's database and also on GitHub. `bin/test`
     has no groups now. `bin/dev-site` recreates its WordPress container each run: a running one
     kept pointing at a plugin folder git had removed and recreated, and showed it empty (proven:
     0 files, 3 after a rebuild). The copy's Docker containers, volumes and settings in `.env` were
     then deleted at the user's request. Status: `[x]` b779578
   - 5f. **The five pages (D22, D23).** The real pages are content, entered through the admin: their
     wording and import file are in `data/content/` (not versioned; `build_pages.py` writes
     `pages-import.xml`, five pages and the menu), tried on the dev site, including a second import
     that adds nothing. The dates in that file must be in the past, or WordPress schedules the pages
     instead of publishing them (found in that trial). The photo goes in the Media Library, so the
     user can swap it; the logo ships with the theme (`patterns/site-logo.php`). The policy allows
     YouTube frames. The dev site has neutral pages with the same layouts
     (`tests/dev-content/`), and tests check the logo and one main heading per page; each shown to
     fail on a planted fault. Left: the import on staging, the user's video choices (Home and
     Music), the wording, and the form in place of its stand-in (5e). Status: `[~]`
   - 5e. **The booking form (D19),** with the visible parts after 2b: name, email, optional event
     date and message, sent to the user. The form tool is chosen at this step; a maintained
     ready-made plugin first. Needs spam protection, a privacy policy page and a way to test
     its mail on the dev site (`docs/SITE_CHECKLIST.md` 6.4, 10.1, 10.3). Chosen with the user
     (2026-11-07), after trying Contact Form 7 and Fluent Forms on the dev site: Contact Form 7 6.2.4.1,
     with Cloudflare Turnstile and no add-ons. It is about a twentieth of the size (2 MB against 38 MB)
     and keeps no visitor details on the site. The form and mail settings are in `config/`; the real
     keys only in each site's admin. The theme limits its files and Cloudflare's script to pages with
     the form, since by default both load everywhere. Mail goes to Mailpit on the dev site, and
     Cloudflare is simulated in the tests; the real script was proven once with Cloudflare's published
     test keys (widget and token, no policy violation). Eight planted faults were caught. Draft
     privacy policy in `data/content/`, linked from the footer, reviewed by the user. On staging
     (2026-11-07), with the user's real Turnstile keys: the widget stays hidden unless needed (the
     visible "Success" read as if the request had been sent), the spam check passed and the form
     reported the message sent, but no mail reached the user, as the server's own mail is unreliable
     (Findings). Left: real delivery, with step 8's mail service. Status: `[~]`
   - **Future plugins (D19), not needed for go-live:** 5b and 5c are one clip request plugin; 5d
     is the setlist preferences plugin. Their descriptions below are kept as their design.
     Clips would be short compressed MP3s (about 240-320 KB for 20 seconds).
   - **When release years are added (the user, 2026-11-07):** a song known in two artists' versions
     shows both years, each with its artist. Eight songs today hold two artists separated by " / "
     in the artist field, which can be split when this is built. The field and a one-time bulk
     load are small; the user checks the suggested years.
   - 5b. **Song requests (D8).** The Songlist has a checkbox per song and "select all"; a form
     (name, email, optional event date and message) sends the selection. Each request is stored
     in the admin with its songs and notifies the user; the user clicks "Approve and send", and
     the site emails the visitor links to those songs' clips that expire after a set time. Needs
     spam protection, a privacy policy page, and checked input with protection against forged
     submissions (`docs/SITE_CHECKLIST.md` 6.4, 10.1, 10.3). The form tool is chosen at this
     step. Status: `[ ]`
   - 5c. **Private clips per song.** A short audio clip per song, stored where it cannot be
     reached by a plain URL, and served only through 5b's expiring links. Recording and the
     licensing question for cover recordings are the user's. Status: `[ ]`
   - 5d. **Setlist preferences for a gig.** A separate page from 5b, for someone booking the
     user: pick songs from the list they want played, and set the focus of the rest with two
     dials:
     - **Genre dial:** one slider from Country to Rock/Pop, 0-100% (50/50, 30/70, ...).
     - **Era dial:** "All eras" (every year weighted the same), or a centre year (for example
       1979, a birth year): songs are weighted by a bell curve around that year, highest near
       it and fading smoothly with distance, clearly higher within about 15 years on either
       side; songs further out still count, less. The exact curve is tuned with the real songs.
     - **Energy dial:** from mellow to high energy, with the same moving bell curve over the
       songs' energy ratings (D10). Its wording is chosen in 2b.
     - Every dial has a "no preference, the user's call" option (D10). How the dials combine is
       tuned with the real songs, by checking that suggested sets look like real sets.
     Possible: a live preview of the songs most likely in the set as the dials move (decided in
     2b). Sliders work with keyboard and screen readers (`docs/SITE_CHECKLIST.md` 7.2). Stored
     in the admin with the request, so the user sees what the client wants before planning the
     set. Layout worked out in step 2b. Uses the same form safeguards as 5b. *Why:* lets a client dial in
     the music they want, and gives the user the details before the conversation. Status: `[ ]`
6. **Plugins.** Keep, replace or drop `updraftplus`, `wordfence`, `wordpress-seo`; remove the
   Hostinger's auto-updates plugin and mu-plugin (open item 3), or keep them while the site is at
   Hostinger. FluentSMTP is already chosen
   (D13); its email log holds visitors' addresses, so its retention is set here
   (`docs/SITE_CHECKLIST.md` 10.2). Decided 2026-11-09 (D25): every plugin above stays; Contact
   Form 7 and Song List join them; FluentSMTP keeps failed mail only (D24). Left: Yoast SEO on the
   dev site, pinned in `tools/versions.sh` and checked like Contact Form 7, with tests (author
   archives closed, checklist 4.5; one canonical address per page; no policy or accessibility
   error), each shown to fail on a planted fault; then on staging, set up as the inventory lists
   (a musician, a sharing image, author archives off).
   - **Yoast on the dev site (2026-11-09):** 28.8, checked against WordPress.org's checksums,
     author archives and usage tracking off through Yoast's own settings code (tracking is off by
     default; stored so a later default cannot switch it on). Yoast writes no canonical link on a
     page that asks not to be indexed (its `canonical-presenter.php`), and every copy but live
     does (checklist 9.5), so the planned canonical test became (the user's choice): each page is
     `noindex`, has no canonical link, and Yoast's `og:url` is its own address; the canonical
     itself is checked on live at step 9. `seo.spec.ts` also checks that `/?author=1` and
     `/author/<login>/` forward nowhere that names the login. Four planted faults caught (author
     archives on; search engines allowed; a second canonical; another host's `og:url`). The
     existing policy, accessibility and debug-log checks pass with Yoast's output in the pages.
   - **The intended differences between the dev site, staging and live** are listed in
     `docs/ENVIRONMENTS.md` (the user, 2026-11-09: not everything can or should be the same; each
     difference is deliberate, with its reason and where it is tested).
   - **Found, for step 8:** Yoast writes its version in a comment on every page ("optimized with
     the Yoast SEO plugin v28.8"), which checklist 3.6 is about; the `wpseo_debug_markers` filter
     removes it. Yoast's AI generator is on by default and contacts Yoast's service only when used
     in the editor. Both are for step 8 (the user, 2026-11-09).
   - **Yoast's outgoing requests (read in its 28.8 code, 2026-11-09; not observed as traffic):**
     none from visitor pages. Usage data to `tracking.yoast.com` only if the tracking setting is not
     `false`: stored `false`, its hooks are never registered (`admin/tracking/class-tracking.php`;
     an unset value takes another branch, which is why it is stored). `my.yoast.com` for the
     account check only when a Yoast add-on is installed (`inc/class-addon-manager.php`), and an
     admin proxy page there for its analysis worker; `ai.yoa.st` when the AI features are used; the
     help beacon on Yoast's admin pages loads `beacon-v2.helpscout.net` and, with tracking off,
     asks for consent first. The sitemap request goes to the site itself.
   Status: `[~]`
7. ~~**Staging install.** Decide whether `wordpress/staging/` is needed (open item 2).~~
   Settled by step 0g: the old copy was removed; the new staging site comes with 3g.
8. **Set up the site at Hostinger for go-live (D15):** how updates and backups run there (the
   Hostinger updater updates only WordPress itself, open item 3), and the authenticated mail
   service with its DNS records (`docs/SITE_CHECKLIST.md` 11.1, 11.2). Outgoing ports there are
   all open except 0 and 25, so FluentSMTP can use the service's SMTP (587/465) or its API. The
   mail service must work before the booking form (5e) goes live. Also to evaluate here:
   Hostinger's object cache (offered for free on 2026-11-02, declined during step 0f), tested
   on the staging site first; blocking public access to plugin and theme `readme.txt` files,
   which show the installed versions (`docs/SITE_CHECKLIST.md` 3.6). From 3g-1 (2026-11-03),
   for the live site: whether Wordfence's firewall is optimized (it edits `.htaccess`; with a
   backup, and the site checked afterwards); two-factor login required for the Administrator
   role, as on staging; and Wordfence's auto-updates, decided with the rest of the updates.
   - **The mail service, researched 2026-11-07, waiting on the user's answer:** does the user have, or
     can the user create, an address at the domain (hPanel, Emails)? If yes, SMTP2GO, which refuses
     signups from Gmail: free for 1,000 mails a month, native in FluentSMTP, three CNAME records with
     the SPF record untouched, and it survives the move at step 10. If no, or at extra cost, Brevo,
     after confirming its branding and limits, whose pricing page did not load. A Hostinger mailbox
     over SMTP needs no new account but is redone at step 10. Not yet confirmed: SMTP2GO's daily limits
     and branding, and which email the Hostinger plan includes. Public records then: MX at Hostinger,
     SPF naming only `_spf.mail.hostinger.com`, DMARC `p=none`, no DKIM under the common names checked,
     no SPF for the staging subdomain. Gmail requires SPF or DKIM, which fits the staging test mail
     not arriving (5e); that cause is still unproven until a message arrives. FluentSMTP is not yet on
     staging.
   - **The mail service, delivery records (checked 2026-11-07):** SMTP2GO's free plan shows only 5 days
     of activity, and that cannot be extended (its support pages). Brevo's pricing page and FAQ state
     unlimited log retention on all plans, with webhooks on the free plan. This reverses the
     recommendation above to Brevo, pending the user's choice. Its reported branding would reach only
     the user, since these mails go to the user, not to visitors. Whether it accepts a Gmail signup is
     unconfirmed. Long retention at Brevo means visitors' details are kept there: the privacy policy
     names the service.
   - **Limiting what Brevo keeps (checked 2026-11-07, from its help pages as shown in search results; the
     pages themselves refused the fetch):** logs and email previews are kept without limit by default.
     Settings > Transactional emails > Retention rules sets 1 to 24 months; deletion follows within 24
     to 72 hours and cannot be undone. Previews store each email's full content, are said to be off by
     default, and must stay off. An API call deletes a log entry by message or address. Whether the free
     plan has the rule is confirmed in the account. Proposed: previews off, a 3-month rule, the same
     period for FluentSMTP's log.
   - **Open source and Gmail, checked 2026-11-07 at the user's request:** self-hosted open source mail
     (Postal) needs a dedicated server with 4 GB of memory and outbound port 25, which Hostinger blocks,
     and leaves the sender reputation to the user: not a fit for a handful of mails. Hosted Plunk's plans
     conflict between sources and were not pursued. FluentSMTP (already chosen, D13) can instead send
     through the user's own Gmail with Google's API: no new mail company, no DNS records, and a record of
     each mail in Gmail's Sent folder. Chosen by the user (2026-11-07). From Google's documentation: a token in
     Testing lasts 7 days, so the app is published; it also stops working if the Google password changes,
     access is revoked, or it goes unused for six months. Whether FluentSMTP's daily connection check
     counts as use is to be observed; its alert must fire in any of these cases, proven by revoking
     access. Gmail's limit is 500 mails a day. Setup follows FluentSMTP's guide; its redirect goes through
     `fluentsmtp.com/gapi/`, the plugin vendor's page, during the one-time connection.
   - **Brevo setup, where it stands (2026-11-07, paused mid-way):** the account exists (the user's Gmail
     address; the user's password notes hold the login). Domain added manually, no branded subdomain.
     DNS at Hostinger, all checked live by Claude: added TXT `@` = `brevo-code:825b…` and CNAMEs
     `brevo1._domainkey` → `b1.howardbuiemusic-com.dkim.brevo.com`, `brevo2._domainkey` →
     `b2.howardbuiemusic-com.dkim.brevo.com`; the existing DMARC record edited (Brevo would not
     authenticate without it) to `v=DMARC1; p=none; rua=mailto:rua@dmarc.brevo.com`, one record, TTL one
     hour. SPF, MX and the Google record unchanged. Brevo showed all four records green but the domain
     still "not authenticated", most likely its one-hour cache of the old DMARC record. The Google Cloud
     project from the Gmail attempt is shut down. Remaining, in order: (1) Brevo authenticates the
     domain; (2) Brevo two-factor login on; (3) sender `website@howardbuiemusic.com`, named "Howard Buie
     Music website"; stop if Brevo wants it verified by email, as it has no mailbox; (4) an API key per
     site, named for the site, kept in the password notes; (5) FluentSMTP on staging (installed, its
     Gmail connection never completed) connected to Brevo with that key and sender, forcing the From
     address; logging failures only, with automatic deletion; failure alerts by a channel other than
     email; (6) Brevo's retention rule 3 months, previews off, confirmed on the free plan; (7) a Gmail
     filter that labels booking requests and keeps them out of spam; (8) a test request reaches the
     inbox, and a planted failure raises the alert; (9) the privacy policy names Brevo and the periods.
     Open with the user: removing the visitor's name from the subject line (Claude recommends it).
     **2026-11-09:** after more than two days, Brevo still shows "Your records don't match yet" above
     four records marked "success"; Claude checked all four on two public resolvers (1.1.1.1,
     8.8.8.8), all as Brevo wants. Brevo's help pages, as shown in search results, also say
     transactional sending needs a separate activation by its support. The user opened one ticket
     for both. Added before (3): (2a) transactional sending activated by Brevo.
   - **Knowing when a booking request goes missing (the user: among the most important points,
     2026-11-07):** today neither the user nor the visitor can tell. The setup must show it: the mail
     service's delivery record, FluentSMTP's log as a copy of each request (with a retention period, as
     it holds visitors' details, 10.2), a failure alert that does not depend on email, a Gmail rule so
     requests skip spam, and a test request on a schedule. Each is proven with a planted failure.
   Found in the review of 2026-11-07, for this step:
   - **Backups:** UpdraftPlus's free version does not encrypt database backups, so checklist 12.2
     cannot be met as written without paying or changing the item; Hostinger's own backups are
     weekly or daily depending on the plan: daily on the live site (the user, 2026-11-09), but kept
     at Hostinger, so UpdraftPlus stays for the off-site copy (12.1, D25); weekly is enough while
     the site stores no requests.
   - **Scheduled checks can stop:** GitHub disables scheduled runs on a public repository after 60
     days without activity, so the weekly audits need regular activity, such as Dependabot merges.
   - **To consider then:** plugin auto-updates instead of trying each update on staging first; no
     page cache unless the speed check (8.1) fails, since a cache needs purging after deploys;
     sending the security headers from the theme, so they deploy with the code and follow a host
     move; an uptime service whose terms are read first (sources conflicted on UptimeRobot).
   Status: `[ ]`
9. **Go live on Hostinger,** without the local leftovers (open item 1); check afterwards that
   they cannot be downloaded. Also:
   - a new admin account on the new site with a login name that is not easy to guess (the old
     one is short and was in the exposed `local.sql`);
   - how the new site reaches the live address, a gap found in the review of 2026-11-07 and not yet
     decided: updating the existing WordPress in place (keeps URLs and the Yoast and Wordfence
     settings, with old plugin tables and revisions to clean up; Claude's recommendation then) or a
     fresh install (nothing carried over, more set up again). Decided when this step is reached,
     with what the pages and staging have shown by then. New page content is ready before the
     theme is switched, and the deploy key cannot run WP-CLI, so content goes through the admin;
   - the booking form's plugin and Turnstile keys (Contact → Integration, 5e); the import file sets its
     From and To for live, and staging's were set by hand in its Mail tab;
   - from outside, after the switch: every page allows indexing and names one canonical address,
     its own, at the live domain (only live can show this, `docs/ENVIRONMENTS.md`, step 6);
   - the 108 songs imported from `data/song-list/songs-import.xml` with WordPress's importer,
     which is deleted again afterwards, as on staging (5a);
   - the deploy pipeline (3g) points at the live site, after the staging site has proven it.
     The design, chosen by the user on 2026-11-04 (option B): a merge to `main` runs the
     checks, then deploys to staging automatically and checks it, as since 3g-3; then GitHub
     asks for the user's approval ("Review deployments"), and only after it deploys the same
     `main` commit to the live site, never a copy of staging's files, with the same file and
     page checks afterwards. Staging is where the next live deploy is staged (the project's
     `CLAUDE.md`, Terms). Built as a second job in a `production` environment with the user as
     required reviewer, its own restricted key and server destination (as 3g-2). The other
     option, live deployed automatically right after staging passes (A), stays possible later,
     once changes are routine.
   Status: `[ ]`
10. **Move to a new host before 2028-07-16** (when the Hostinger plan ends; auto-renewal off):
    choose the host (SSH access and a supported PHP version required), set it up, change the
    pipeline's address, key and folder secrets, deploy, move the database and media, point the
    domain; then close the Hostinger account (pointing the domain elsewhere leaves the old site,
    the staging install and both databases running there, unmaintained) and check that the old
    copy is really gone, also through Hostinger's own temporary address if it has one.
    Status: `[ ]`
