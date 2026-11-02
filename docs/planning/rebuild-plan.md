# Rebuild plan

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Rebuilding the site on a Twenty Twenty-Five child theme, then moving it to a new host. Worked
in rolling-wave mode (`~/.claude/ROLLING_WAVE_MODE.md`): near steps in detail, later ones rough,
new findings added as steps.

## Current position

- **Where the work stands:** steps 0-2 done; 3a (the local copy in Docker Compose, 7555e34)
  and 3b (local mail into Mailpit through FluentSMTP, f389f76) done. The old site is still
  live, secured.
- **Findings:** the live site's email is unreliable (step 8 brings a mail service); the login
  log shows no break-in; the live site runs PHP 8.1, without security fixes since the end of
  2025 (the new host must run a supported version); its plugins are behind (step 0f).
- **Next:** 3c, the file-permission check.
- **Order of the coming steps (D11):** 3 → 4 → 5a → the logic of 5b and 5d → 6 → 2b → the
  visible parts of 5 → 7 → 8 → 9.
- **Open decisions waiting on the user:**
  - how best practices are listed and handled, per the prompt the user is bringing from another
    project (`docs/BEST_PRACTICES.md` is a draft until then);
  - step 0f: whether to update the live site's plugins now (recommended, at least Wordfence);
  - the new host (step 8).
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
| D13 | FluentSMTP sends the site's mail, locally to Mailpit and live to the mail service of step 8; it supports plain SMTP and the main services' APIs. | Chosen by the user over WP Mail SMTP: fully free with no paid tier or upsells, and an email log included. Accepted cost: its connection settings live in the database, so the import saves them through the plugin's own code, and `bin/local-mail-check` catches a format change after an update. WP Mail SMTP would have allowed all settings in `wp-config.php` but keeps the log for its paid version. |

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
     the inactive Twenty Twenty-Five 1.2 (1.5) are behind; the former host's updater updates
     only WordPress itself. Recommended: update all in Dashboard → Updates, at least Wordfence;
     then the home and login pages are checked. Waiting for the user. `[ ]`

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
     which refuses to run outside a local environment). `bin/local-mail-check` sends a message
     with a unique marker and waits for it in Mailpit. Failures met and fixed on the way:
     `declare( strict_types=1 )` is rejected under `wp eval-file`; WP-CLI had no writable cache
     folder; the import's error message now names the failing step. The check also failed, as
     it should, while FluentSMTP had no connection. The port setting is checked to be 1-65535. Status: `[x]` f389f76
   - 3c. **File-permission check:** the rootless Docker umask bug (`DEVCONTAINER_SETUP.md` rule
     11). 3a keeps container-written files in volumes; 3c tests what still reaches the host
     (the theme, mounted later). Status: `[ ]`
   - 3d. **Code-quality tools in a container:** Composer, PHPCS with the WordPress Coding
     Standards, PHPStan with WordPress and WP-CLI stubs. Also: the editor's checks follow the
     WordPress Coding Standards (SonarLint's generic PHP rules ask for spaces and camelCase,
     which WordPress forbids), and plugin versions move from `.env` to Composer if that proves
     the better place. Status: `[ ]`
   - 3e. **Test levels:** PHPUnit (unit; integration against the database container) and
     Playwright browser tests; `.nvmrc` pins Node. Includes, as integration tests, the two
     safety stops of `local/wp-cli/configure-fluentsmtp-mailpit.php` (it refuses outside a
     local environment; it stops on a missing or invalid setting), tested by hand in 3b only
     (3b review, MEDIUM finding). Status: `[ ]`
   - 3f. **CI on every push:** waits for a remote repository and the user's best-practices
     prompt. Status: `[ ]`
4. **Child theme skeleton.** `themes/hbmusic-child/` with `style.css`, `theme.json`,
   `functions.php`, activated locally on a copy. Status: `[ ]`
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
   former host's auto-updates plugin and mu-plugin (open item 3). FluentSMTP is already chosen
   (D13); its email log holds visitors' addresses, so its retention is set here
   (`docs/BEST_PRACTICES.md` 10.2). Status: `[ ]`
7. **Staging install.** Decide whether `wordpress/staging/` is needed (open item 2).
   Status: `[ ]`
8. **Choose the new host** and how updates and backups run there, and the authenticated mail
   service with its DNS records (`docs/BEST_PRACTICES.md` 11.1, 11.2). The mail service must
   work before the request form (5b) goes live. Status: `[ ]`
9. **Migrate and go live,** without the local leftovers (open item 1); check afterwards that
   they cannot be downloaded. Also:
   - a new admin account on the new site with a login name that is not easy to guess (the old
     one is short and was in the exposed `local.sql`);
   - once the new site is live, close the former host's account: pointing the domain elsewhere
     leaves the old site, the staging install and both databases running there, unmaintained;
   - afterwards, check that the old copy is really gone, also through the host's own temporary
     address if it had one.
   Status: `[ ]`
