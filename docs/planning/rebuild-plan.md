# Rebuild plan

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Rebuilding the site on a Twenty Twenty-Five child theme, then moving it to a new host. Worked
in rolling-wave mode (`~/.claude/ROLLING_WAVE_MODE.md`): near steps in detail, later ones rough,
new findings added as steps.

## Current position

- **Where the work stands:** steps 0-2 done; 3a (the local copy in Docker Compose, 7555e34),
  3b (local mail into Mailpit through FluentSMTP, f389f76) and 3d (code checks, `bin/check`,
  14e8788) and 3e (tests, `bin/test`, 69ace60) done; 3c folded into step 4. The old site is still live, secured.
- **Findings:** the live site's email is unreliable (step 8 brings a mail service); the login
  log shows no break-in; the live site's PHP and plugins are current since step 0f
  (2026-11-02), and the old staging copy is removed (0g).
- **Hostinger plan:** expires 2028-07-16, auto-renewal off (the user, from Billing →
  Subscriptions, 2026-11-02). SSH is included (enabled to check, then off until 3g).
- **Hosting (D15):** the new site goes live at Hostinger; the move to another host is step 10.
- **Next:** Dependabot (3f follow-up), then 3g (deploy pipeline to a new staging site).
- **Order of the coming steps (D11):** 3 → 4 → 5a → the logic of 5b and 5d → 6 → 2b → the
  visible parts of 5 → 7 → 8 → 9 → 10.
- **Open decisions waiting on the user:**
  - the new host (step 10, before 2028-07-16).
- **Best practices (D16):** `docs/BEST_PRACTICES.md` is the draft of WordPress additions for a
  shared `~/.claude/WORDPRESS_STANDARDS.md`; until it moves there, it is this project's
  WordPress checklist. Uncommitted; reviewed with the user and committed before step 4.
- **Stale documents:** none.

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
| D11 | The technical groundwork comes before the content and design session (2b): the local environment, the theme skeleton, songs as data, and the logic of the requests and dials, which a visitor does not see. What a visitor sees waits for 2b. | The user prefers to have the technical parts in place first; 2b then reacts to sample pages built on the real songs and working features, and nothing visible is built twice. |
| D12 | The local copy runs in Docker Compose, set up in the repository (`compose.yaml`, `bin/local-import`), with this project's ports in the 101xx block, bound to `127.0.0.1`. | It reproduces the live database version, includes a mail catcher, can be read by a reviewer and run the same way in CI; wp-env (the WordPress project's tool) has no mail catcher, a desktop app cannot be reviewed or reproduced. The 101xx block keeps clear of the 80xx and 90xx ports other projects use. |
| D13 | FluentSMTP sends the site's mail, locally to Mailpit and live to the mail service of step 8; it supports plain SMTP and the main services' APIs. | Chosen by the user over WP Mail SMTP: fully free with no paid tier or upsells, and an email log included. Accepted cost: its connection settings live in the database, so the import saves them through the plugin's own code, and `bin/local-mail-check` catches a format change after an update. WP Mail SMTP would have allowed all settings in `wp-config.php` but keeps the log for its paid version. (The check named here became `tests/scenario/mail-delivery.sh`, run by `bin/test`, in step 3e.) |
| D14 | The deploy pipeline is built now, against a staging subdomain at the former host, and re-pointed to the new host at step 9; deploys go through GitHub (checks first, then SSH), not a host's own deploy feature. | Proves the pipeline on a real host early, so the move is routine; a staging target keeps the unfinished theme away from the live site; GitHub-based deploys work with any host offering SSH, so switching hosts means changing three secrets (address, key, folder). |
| D15 | The new site goes live at Hostinger, where the plan is already paid until 2028-07-16; the move to another host becomes step 10, before then. Supersedes the original assumption that the site leaves Hostinger before going live (D14's "re-pointed at step 9" now happens at step 10). | Avoids paying two hosts at once. Hostinger meets the conditions checked on 2026-11-02: PHP 8.2-8.5 selectable, SSH included in the plan, outgoing mail ports open; the pipeline (3g) keeps the later move routine. |
| D16 | `docs/BEST_PRACTICES.md` holds the WordPress-specific practices, as candidates for a shared `~/.claude/WORDPRESS_STANDARDS.md` (alongside the Java and Go files). A rule that seems to apply to every project is only proposed for the global files: Claude asks the user specifically each time and changes nothing there without the user's yes for that change. The first one, "secrets stay out of repositories and output", went into `WORKING_STYLE.md` on 2026-11-02 after the user approved it. | The user builds WordPress sites as a service provider, so these practices will repeat in other projects; one shared file avoids copies drifting apart. |
| D17 | The GitHub repository is public from its first push, created only after step 0f (the live site's plugins and PHP updated) and a read of the plan and findings for any weakness of the live site that is still open; branch protection then requires the checks before a merge. | Public gives free branch protection, unlimited Actions minutes and a portfolio from the start; the history search before the push found no personal data or secrets. Publishing an open weakness of the live site would hand attackers a shortcut, and a pushed history cannot be taken back, so the push waits for 0f. Excluding the planning documents instead would mean rewriting the whole history and losing the plan's versions. |

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
     security fixes since the end of 2025 and no longer selectable once changed; the version
     applies to every website on the plan, so the staging site (3g) shares it. Sequence: (1) the
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
   booking a musician needs to find fast, including the new request pages (5b clips, 5d setlist
   preferences, and how simple the 5d choices can be made). Then 2-3
   visual directions as clickable sample pages with the real content and photos, for the user to
   react to; the chosen one becomes the child theme's `theme.json`. *Why:* the user does not yet
   know what the site should look like, and choosing from real examples is easier than
   describing a look. Status: `[ ]`
3. **Local environment.** Choose how to run the site locally from `db/` and a copy of
   `wordpress/` (the database import needs the site URL replaced), and the test tools for each
   level of `TESTING_APPROACH.md`, covering what the step 2 inventory found. Includes a local
   mail catcher, so the request form's emails can be tested without sending real mail. Record
   them in the project's `CLAUDE.md`. Chosen by the user: Docker Compose (D12). Status: `[~]`
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
   - 3g. **Deploy pipeline to a staging site at Hostinger (D14, D15).** The public GitHub
     repository (D17) (the whole history searched for personal data before the first push; the
     user creates it from commands Claude gives); the checks of 3f run first; then GitHub
     packages the theme and site plugin and copies them over SSH, with a key used only for
     deploying, to a staging subdomain's folder only, checked before copying so a wrong
     setting cannot touch the live site. The old `staging/` install may become this target
     (open item 2). SSH is included in the user's plan (the user enabled it on 2026-11-02 to
     check, then turned it off until this step); Hostinger's SSH port is 65002; the pipeline
     logs in with a key, not a password. PHP comes from step 0f. The new staging site (after the
     old copy's lessons, 0g): a fresh WordPress, not a copy, with its own admin (strong
     password, two-factor login); the whole site behind a server-level password, so its login
     page is not reachable from outside (Hostinger's directory protection, to verify here);
     plugins kept as current as live; not indexed; test data from scripts, no live data.
     Status: `[ ]`
4. **Child theme skeleton.** `themes/hbmusic-child/` with `style.css`, `theme.json`,
   `functions.php`, activated locally on a copy. Includes the
   file-permission check folded in from 3c: files the user creates in the mounted theme folder
   stay owned by the user and are not world-writable (`DEVCONTAINER_SETUP.md` rule 11).
   Status: `[ ]`
5. **Rebuild the design and content** in the child theme from the step 2 inventory and the
   step 2b choices (rough; split further after 2b). Known parts:
   - 5a. **Songs as data.** A small site plugin (not the theme, so the songs survive a theme
     change) with a Song type: title, artist, release year, genre Rock/Pop or Country (D9), and
     energy 1-5 (D10). Claude suggests the release years from public release data, and the
     genres and energy ratings as labelled guesses, for the user to check and correct. The 108 songs are converted from the current Songlist page, where titles and artists
     sit in two separate lists matched only by position. The Songlist page is built from the Song entries.
     *Why:* the user adds songs in the admin instead of editing page text. Status: `[ ]`
   - 5b. **Song requests (D8).** The Songlist has a checkbox per song and "select all"; a form
     (name, email, optional event date and message) sends the selection. Each request is stored
     in the admin with its songs and notifies the user; the user clicks "Approve and send", and
     the site emails the visitor links to those songs' clips that expire after a set time. Needs
     spam protection, a privacy policy page, and checked input with protection against forged
     submissions (`docs/BEST_PRACTICES.md` 6.4, 10.1, 10.3). The form tool is chosen at this
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
     2b). Sliders work with keyboard and screen readers (`docs/BEST_PRACTICES.md` 7.2). Stored
     in the admin with the request, so the user sees what the client wants before planning the
     set. Layout worked out in step 2b. Uses the same form safeguards as 5b. *Why:* lets a client dial in
     the music they want, and gives the user the details before the conversation. Status: `[ ]`
6. **Plugins.** Keep, replace or drop `updraftplus`, `wordfence`, `wordpress-seo`; remove the
   Hostinger's auto-updates plugin and mu-plugin (open item 3), or keep them while the site is at
   Hostinger. FluentSMTP is already chosen
   (D13); its email log holds visitors' addresses, so its retention is set here
   (`docs/BEST_PRACTICES.md` 10.2). Status: `[ ]`
7. ~~**Staging install.** Decide whether `wordpress/staging/` is needed (open item 2).~~
   Settled by step 0g: the old copy was removed; the new staging site comes with 3g.
8. **Set up the site at Hostinger for go-live (D15):** how updates and backups run there (the
   Hostinger updater updates only WordPress itself, open item 3), and the authenticated mail
   service with its DNS records (`docs/BEST_PRACTICES.md` 11.1, 11.2). Outgoing ports there are
   all open except 0 and 25, so FluentSMTP can use the service's SMTP (587/465) or its API. The
   mail service must work before the request form (5b) goes live. Also to evaluate here:
   Hostinger's object cache (offered for free on 2026-11-02, declined during step 0f), tested
   on the staging site first; blocking public access to plugin and theme `readme.txt` files,
   which show the installed versions (`docs/BEST_PRACTICES.md` 3.6). Status: `[ ]`
9. **Go live on Hostinger,** without the local leftovers (open item 1); check afterwards that
   they cannot be downloaded. Also:
   - a new admin account on the new site with a login name that is not easy to guess (the old
     one is short and was in the exposed `local.sql`);
   - the deploy pipeline (3g) points at the live site, after the staging site has proven it.
   Status: `[ ]`
10. **Move to a new host before 2028-07-16** (when the Hostinger plan ends; auto-renewal off):
    choose the host (SSH access and a supported PHP version required), set it up, change the
    pipeline's address, key and folder secrets, deploy, move the database and media, point the
    domain; then close the Hostinger account (pointing the domain elsewhere leaves the old site,
    the staging install and both databases running there, unmaintained) and check that the old
    copy is really gone, also through Hostinger's own temporary address if it has one.
    Status: `[ ]`
