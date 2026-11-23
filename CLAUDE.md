# hbMusic_wp_site

What this file is: what is true of this project alone, loaded only in this repository; the
shared rules are in `~/.claude/CLAUDE.md`; "the user" is the person Claude works with.

## About

A musician's WordPress site, being rebuilt on a maintained theme (a Twenty Twenty-Five child
theme) and with booking features, to go live at its current host and move to another later.

## Handbook

- Follows: the DTS Operations Handbook, version 1 (moved from version 0 by the user, 2026-11-23).
- Type: Fully managed, Brochure, hosted by the customer (the user's own site).
- Exceptions (each with its reason and date in `records/exceptions.md`; E5 in the private
  records folder, `data/records/exceptions-private.md`):
  - E1 Hosted on Hostinger, not a DTS standard host: the hosting is prepaid through 2028; the
    site moves when that plan ends.
  - E2 Keeps a staging site on the host: the user's practice ground for staging on the host,
    which Shop sites need.
  - E3 Secrets in the user's password notes until DTS's Bitwarden is set up.
  - E4 The old site's admin and themes kept until rebuild plan 9n.
  - E5 A weakness the host does not let the site close (private).
  - E6 No written agreement on who may change what: the user's own site.
  - E7 Other people's PHP notices shown, not failed, in the dev site's debug log.
- Status against the site standard (chapter 12): `records/status.md`.

## Terms

The places code passes through, in order (agreed with the user on 2026-11-04):

- **Dev site:** the local fresh WordPress (`bin/dev-site`), and its tests on every pull
  request. Where changes are tried out before they reach `main`.
- **`main`:** the repository's accepted code: every change there has passed all checks. Merging
  into `main` makes nothing public by itself.
- **Staging:** the staging site at the host, behind a site-wide password, running `main`'s code
  with test content. **Staging is where the next live deploy is staged** (the user's
  definition): set up and running on the real host before it goes out. It is not where
  changes wait to get into `main`.
- **Live:** the public site visitors see. It gets the same `main` code as staging, never a copy
  of staging's files; each site keeps its own content.

## Where things are

- `backups/`: the original host export, the site archive (`.tar.gz`) and the database dump
  (`.sql.gz`). Read-only (`chmod a-w`); never changed, moved or unpacked in place.
- `db/`: the database dump unpacked to plain `.sql` (WordPress 7.1.4, table prefix `wp_`).
- `wordpress/`: the old `public_html` exactly as exported. Kept unchanged as the reference copy
  of the old site; new work does not go here.
- `themes/hbmusic-child/`: the new Twenty Twenty-Five child theme.
- `plugins/song-list/`: the Song List plugin (plan D19), which names nothing of this site, so it
  can be shared; its own prefix `songlist`, text domain `song-list` and `phpcs.xml.dist`.
- `plugins/site-hardening/`: the Site Hardening plugin (plan D26), shared the same way; prefix
  `sitehardening`, text domain `site-hardening`.
- `plugins/editing-help/`: the Editing Help plugin (handbook H89), shared the same way; prefix
  `editinghelp`, text domain `editing-help`. It shows the content guide in the admin (a panel at
  the top of the Dashboard, and the guide's page, linked in the left menu under Dashboard), ending with the site's page templates and ready-made
  sections read from the theme; the child theme supplies its templates' descriptions and its
  link example through the plugin's filters. The guide's text is also kept in the handbook
  (`customer/content-guide.md`), with the same version number; a change goes into both.
- `data/`: not versioned; the site's real content and one-time data: the song list, the pages'
  wording and import file, and the photos.
- `docs/planning/template-plan.md`: the active plan since 2026-11-20 (rolling-wave mode), the
  brochure-site template built from this project; its Current position says where the work
  stands.
- `docs/planning/rebuild-plan.md`: this site's own plan, paused for the template; its Current
  position keeps 9u waiting.
- `site.json`: the site's facts the tools read instead of naming this site (template plan T7):
  its slug, theme, plugins, the dev site's test pages and where `bin/deploy` copies to (live and
  staging, by their short names in the user's SSH settings, template plan 1.4c); no secrets. Its fields are explained in
  `tools/site-settings.md` and their rules are in `tools/site-settings.jq`.
- `project-state.yaml`: session state for pause and resume, with the open items.
- `docs/ENVIRONMENTS.md`: the intended differences between the dev site, staging and live, each
  with its reason and where it is tested; a new difference is added there when it is introduced.
- `docs/ROUTINES.md`: the recurring care of the site (deploying, the monthly site check, what to
  do on each alert, visitors' data requests), the same for every DTS site (template plan 1.5c);
  it links each of this site's details (places, host, mail, uptime monitor, plugins and theme,
  the expected set) to its heading in `docs/SITE_SPECIFIC_ROUTINES.md`, and `bin/check` fails if
  a link finds no heading there or a heading there has no link (`tools/routines.sh`).

The old site, as exported:
- Active theme: the parent `music-lite` 1.5 (unmaintained). A `music-lite-child` theme is
  installed but not active. `twentytwentyfive` 1.2 is installed.
- Plugins: `updraftplus`, `wordfence`, `wordpress-seo`, and Hostinger's auto-updates
  plugin (also as a must-use plugin in `wp-content/mu-plugins/`).
- `wordpress/staging/` is a second complete WordPress install (7.1.4) with the same themes;
  on the live server it was removed on 2026-11-02 (plan step 0g).

## Commands

The scripts below need only Docker and `jq` on this computer; every tool they use runs in a
pinned container. They read the site's facts from `site.json` and name their Docker volumes
from its `slug` (template plan 1.2d), and stop at once, naming the problem, if `site.json` breaks
its rules.

The **dev site** runs in Docker Compose (`compose.dev.yaml`): a fresh WordPress with the new child
theme, the plugins and test content, with its settings in `.env` (created from `.env.example`
with random secrets; never committed). This project's ports are the **101xx** block: the dev
site on 10102, its Mailpit inbox on 10103, the rest of the block for later needs. The old site's local copy was removed at
plan step 5a-2; the real old site stays online until go-live, and the export stays in `backups/`,
`db/` and `wordpress/`.

- `bin/dev-site`: builds or rebuilds the dev site from nothing (an empty database each run),
  from the site's facts in `site.json` (its theme, title, own plugins and test pages) and its
  downloaded plugins in `site-packages/composer.lock`, all checked before anything is changed
  (template plan 1.2b, 1.2c):
  WordPress, the parent theme Twenty Twenty-Five at the version and SHA-256 pinned in
  `tools/versions.sh`, the child theme and the site's own plugins (`localPlugins`: Song List,
  Site Hardening, Editing Help) mounted read-only and activated, its downloaded plugins installed
  by Composer from `site-packages/composer.lock` (in the pinned Composer container, which sees only
  `site-packages/`), copied in and checked against WordPress.org's checksums: Contact Form 7
  with the real booking form from `config/booking-form.txt` and `config/booking-form-mail.json`,
  and its messages after sending ("sent" and "sending failed") from
  `config/booking-form-messages.json` (merged into Contact Form 7's own messages; staging and live
  get the same texts typed in by hand, in the form's Messages tab),
  and Yoast SEO, and Simple History, the activity log (template plan 1.5b; a
  scenario check, `dev-activity-log.sh`, shows it records a page edit and a plugin switched off
  and on, with addresses anonymized), test pages (`site.json`'s list, their text in `tests/dev-content/`, each with the
  page template its real page uses) and the components' example page (every component on neutral
  content, outside the menu), a stand-in Yoast organization (a neutral name and a picture
  WordPress itself ships), then the site's own steps in `tests/dev-setup.sh` (here, the Song
  List's sample songs, neutral text), a dev admin (`devadmin`, password
  `DEV_ADMIN_PASSWORD` in `.env`) and a dev Editor (`deveditor`, `DEV_EDITOR_PASSWORD`), the role
  a customer gets. To log in by hand, copy a password without showing it:
  `grep '^DEV_ADMIN_PASSWORD=' .env | cut -d= -f2- | tr -d '\n' | wl-copy`. `config/dev-mu-plugins/`, on the dev site only and never
  deployed (and mounted for WP-CLI too), notes each PHP message's origin in the debug log
  (`dev-error-origin.php`), sends mail to Mailpit and answers for Cloudflare, for YouTube's oEmbed service (so the stand-in videos are real video blocks, loading WordPress's same styles as live) and for YouTube's image server (a test picture). Needs no backup, so CI can build it
  too.
- `bin/test`: the tests against the dev site, each in its group's folder (template plan 1.3a:
  `generic/`, `components/`, `plugins/<plugin>/` and `site/`, the site's own; the browser tests'
  shared helpers in `helpers/`), so each group can later go with its own repository: the
  scenario checks named `tests/scenario/<group>/dev-*.sh` (bash, sharing `lib.sh`: read-only theme and plugin mounts, the
  PHP debug log's rule (`tests/scenario/debug-log.sh`, template plan 1.5b: any message from the
  site's own code, and any fatal error, fails; other people's notices, warnings and deprecations
  are shown, each with its origin), the `.env` safety stop, every stylesheet of the theme and the Song List labelled
  by a fingerprint of its contents, embedded videos' titles read as written, the theme's patterns matching the structure its CSS expects, the editor offering only the theme's colors and sizes (`dev-editor-presets.sh`, handbook 12, 6.11)), then the browser tests in `tests/e2e/specs/dev/` in the
  official Playwright container (`--network host`, seeing only `tests/e2e/` and, read-only,
  `config/booking-form-messages.json`, `site.json`, whose test pages the specs that check every
  page read, and `tests/dev-content/`, where each component's tests find the pages that use it,
  the example page and every site page with the component's class, template plan T10): child theme active,
  security headers sent, no CSP violation, no axe accessibility error at WCAG 2.2 AA, the Song
  List's page and admin form, the booking form's mail (no visitor's name in the subject), its
  message when sending fails (Mailpit made to refuse mail, in a serial group) and refusals, and its files loading only
  where it appears; the stylesheets loading only with what they style (the theme's components,
  the form's, the song table's from its plugin, plan D29), the bands' texture, the call-to-action panel's green and its button standing out from it, the lead text larger than body text, the hero's text and picture centred on each other with the picture's softened bottom, the features panel's buttons lined up, and the headings' even
  lines; the buttons' keyboard focus ring and
  its contrast against its band, equal sizes and equal widths in a row, no movement with reduced motion and no stuck hover
  after a tap (D29); the video carousel's row, label, keyboard access, end, its first and last slides centred, several carousels each with their own arrows, a carousel named after a heading directly above it, described as a carousel with "n of m" slides, an empty heading above it left out, and reduced motion (D29); the click-to-load videos (nothing from YouTube before a video is played, each picture from the site in a 16:9 box, played by click or Enter in YouTube's privacy-enhanced player, a link to YouTube without JavaScript; their pictures fetched when a page is saved, `dev-video-pictures.sh`, plan 9v); the video script (one YouTube player at a time: starting one, one moved out of its carousel's view, or the visitor clicking into another, pauses the others; scrolling the page never does; loaded only where there is a video, with stand-in players instead of YouTube); one frame on every page (the header,
  footer, panels and carousel sharing the same edges on a computer and a phone, the panels at the theme's wide width on a wide screen, two panels in a row never touching, the call to action from the page template a section's spacing below the content, D29); the sticky header, a link reached with the keyboard never under it, the
  menu's current-page mark, the same space before the footer after the call to action as after text in both page templates, the slimmer phone header, and the hamburger menu on a phone as a small panel under the header at the right, as wide as its links, with every link reachable, closed by its button, Escape or a tap on plain page content beside it (the theme's `menu-close-outside.js`; also in WebKit, plan 9t); Media & Text's text lined up with the page title on a computer and a phone, its text first on a phone when the picture is on the right (plan 9t-3)
  (D29); the Site Hardening plugin's refusals; the old addresses' redirects; the Editing Help
  guide for the admin and the dev Editor (its panel first on the Dashboard, and on the Editor's first screen, headings and accessibility, the
  site's templates, sections and link example, and every editor label it names found in the real
  editor, on a draft page of its own); then, last, a check that the PHP debug
  log still holds nothing from the site's own code and no error after everything (`tests/scenario/generic/final-debug-log.sh`). If the site does not
  answer, the run fails; it is never skipped.
  Before a commit that touches the site, the theme or a plugin, Claude runs `bin/check` and the
  browser tests of the part changed (their spec files, in the Playwright container as `bin/test`
  runs them), plus any scenario check the change touches; the full `bin/test` runs on GitHub for
  every pull request (the required `dev-site` job), and Claude runs it locally only for a change
  that reaches across the site (the user, 2026-11-17: a small code change took about 15 minutes
  from ready to live, the full tests running three times). Every test runs even after a failure;
  exit status 1 if any failed.
- Dev site: http://localhost:10102 (admin `/wp-admin`); mail inbox: http://localhost:10103.
- The dev site's recipe is two files (template plan 1.2f): `compose.dev.yaml`, the same for every
  site, and `compose.site.yaml`, the site's own name and mounts, written from `site.json` by
  `bin/dev-site`, `bin/check` and `bin/screenshots` (ignored by git; never edited). `.env`'s
  `COMPOSE_FILE` names both, so the commands below, typed in the repository's folder, use them.
  After changing `site.json`, run `bin/dev-site` before typing them, so the written file follows.
- `docker compose stop` / `start`: stop and start without losing anything.
- `docker compose run --rm cli wp <command>`: WP-CLI against the dev site.
- `docker compose down -v` deletes the dev site's database and files (the
  volumes); Claude runs it only when the user asks. `bin/dev-site` rebuilds them.
- `bin/check`: every code check, in pinned containers (only Docker and `jq` on the host; it
  stops at once if `jq` is missing):
  Composer install from `composer.lock`, validation and security audit; PHPCS with the
  WordPress Coding Standards (`phpcs.xml.dist`); PHPStan at level max with the WordPress 7.1
  stubs (`phpstan.neon.dist`), both over `themes/` and `plugins/` (each plugin with its own PHPCS
  ruleset), and checks that the plugins and the tools (`bin/`, `tools/`, the workflows, the shared
  compose file and settings example)
  name nothing of this site (`site.json`'s `namesSharedCodeMustNotUse`) and that each plugin declares
  `Update URI: false`; every script in `bin/` executable; `theme.json`'s schema matching
  the pinned WordPress; Stylelint over every CSS file in `themes/` and `plugins/` (its standard
  rules plus WordPress's formatting, `tools/css-lint/`, plan D29), with an npm audit of its
  packages (every advisory fails, except any the user accepted in that folder's
  `audit-exceptions.json`, each with its reason and a review-by date after which it fails again,
  and an accepted one that npm no longer reports also fails; none accepted since 2026-11-20); the theme's component list in `functions.php` matching the files in
  `assets/css/components/`, both ways; a type check of the theme's browser scripts (`assets/js/`) with
  the TypeScript compiler the browser tests install (`tools/js-check/`); and every `site-…` component shown on the components' example page
  (`tests/e2e/specs/dev/components/pages/`, built by `bin/dev-site` at `/component-examples/`,
  outside the menu, template plan T10) or in a template part (so the browser tests see it); `site.json` following the rules in
  `tools/site-settings.jq` (a missing or unknown field, or a wrong kind of value, fails and is
  named), every field explained in `tools/site-settings.md` and nothing else, and those checks
  refusing the broken examples in `tests/tools/site-settings/`; the versions check's alerts on
  known situations (`tests/tools/versions-check/`: the real script against stand-ins for GitHub
  and WordPress.org, which issues it would open, template plan 1.3c); the page check on known
  situations (`tests/tools/site-check/`: `bin/site-check` against a stand-in site, 1.4b); the
  deploy's checks on known situations (`tests/tools/deploy/`: `bin/deploy` in a throwaway Git
  repository against stand-ins for GitHub, the servers, the Composer build and WordPress.org's
  checksums, 1.4d-1, 1.4d-2); the routines' links to their site details, and that check on
  known examples (`tests/tools/routines/`, 1.5c); ShellCheck on `bin/`, the
  scenario checks and the tools' tests; the compose file. Runs every check even
  after a failure; exit status 1 if any failed. The review gate starts with it. The tool
  containers see only the files their step needs, never `.env`, `db/`, `backups/` or
  `wordpress/`; `composer.lock` is read-only to them.
- GitHub runs `bin/check` and the dev site's tests on every pull request, weekly and by the "Run
  workflow" button (`.github/workflows/check.yml`); a pull request merges only when both pass and
  it is up to date with `main`. A merge deploys nothing: the user deploys with `bin/deploy`
  (template plan 1.4e removed GitHub's staging deploy, its key and its environment).
- `site-packages/`: the downloaded plugins the site runs (template plan T8), WordPress.org's
  through WPackagist, at exact versions in `composer.json`, with `composer.lock` recording the
  download addresses (all on `downloads.wordpress.org`, which `bin/check` and `bin/dev-site`
  require). Separate from the top-level `composer.json`, which holds only the code-checking tools.
  Dependabot proposes the plugins' updates weekly, a release at least 7 days old, in one pull
  request (`.github/dependabot.yml`), which merges itself by rebase once its checks pass
  (`.github/workflows/plugin-updates.yml`, template plan T9: only Dependabot's pull requests into
  `main` changing nothing but `site-packages/`, and in its lock file nothing but WordPress.org
  plugins; it runs `main`'s own code, never the pull request's). Updates to
  `composer/installers` and to the tools wait for the user's review. A merge
  done this way starts no run on `main` (GitHub does not start workflows from its own token's
  merges); nothing needs one: `bin/deploy` accepts a commit whose pull request's last commit
  passed with the same files, and the weekly run checks `main`. Staging and live get a new
  version only when the user deploys it with `bin/deploy`, in the monthly check
  (`docs/ROUTINES.md`). WPackagist is needed only to change
  a version: installing from the lock file goes straight to WordPress.org.
- `bin/versions-check`: compares the dev site's pinned parent theme (`tools/versions.sh`) with
  WordPress.org and reports whether it is behind, changing nothing. Every Monday GitHub runs it
  with `--act` (`.github/workflows/versions.yml`, plan 8j), which opens an issue for a theme
  release at least 7 days old; its pin holds a fingerprint taken by hand, so it is raised in a
  session. It also watches the plugin updates (template plan T9): an issue for one still open
  after 3 days (its checks failed, or it fell behind `main` and waits for a comment
  `@dependabot rebase`), and
  for a plugin release 14 days old that Dependabot never proposed. And (1.4d-4) it compares the
  deploy test server's `openssh-server` and `rsync` (`tools/versions.sh`) with Alpine's package
  list for the pinned image's branch: Alpine keeps only each package's newest version, so a
  replaced one gets an issue at once, raised in a session without the 7-day wait (waiting cannot
  keep the old version; apk checks Alpine's signature on every package). GitHub emails the owner about
  new issues; one with the same title is never opened twice. The workflow can read the repository
  and its pull requests and open issues, nothing more.
- `bin/deploy staging|live [--commit <commit>] [--allow-lower <plugin>]... [--ssh-config <file>]`
  (template plan 1.4, T11; handbook chapter 2), run by the user from this computer, the way every
  change reaches staging and live since 2026-11-22 (1.4e; `docs/ROUTINES.md`, "Deploying"). It
  refuses unless the working copy is clean, the commit is on GitHub's `main`
  and its required checks (`check`, `dev-site`) passed on it or on its merged pull request's last
  commit with the same files, and on live unless staging runs that commit; it reads the place's
  note on the server and shows the commits arriving or taken away. Before asking "yes", it exports
  the commit, builds its downloaded plugins from its `composer.lock` (the pinned Composer
  container) and checks every file against WordPress.org's checksum file (a changed or added
  file refuses; one listed but missing from the download is shown, not refused, as WP-CLI's
  check on the dev site does, 1.5b), checks each folder
  exists on the server for the key, and refuses to lower a downloaded plugin the host updated
  unless `--allow-lower` names it. After "yes" it copies the downloaded plugins, the site's own
  plugins and the theme, each folder made exactly the commit's, then writes the note, and names
  any folder that was empty there (to activate by hand). Then the page check
  (`bin/site-check`; failing, it fails the deploy and names the way back, `--commit` with the
  commit the place ran before), given a place's password login from `.env`
  (`<PLACE>_CHECK_USER`, `<PLACE>_CHECK_PASSWORD`, read by exact name), and the PHP log's lines
  added since before the copy (read through the read-only `php-log` folder; shown, not failing).
  One deploy of a site at a time on the computer (a `flock` lock in its temporary folder). The
  places come from `site.json`'s `deploy` section. Its test against a real throwaway server is the
  scenario check `dev-deploy-server.sh`: an Alpine container (pinned in `tools/versions.sh`) set
  up like the host, the real `ssh` and `rsync`, and probes that each key opens no shell, cannot
  write the log or climb out of its folders, and that an unknown key is refused at once. Unlike the other scripts it uses programs on the
  user's computer besides Docker and `jq`: `git`, `gh` (logged in), `rsync`, `ssh`, `curl` and `flock`;
  `ssh` never asks for a password (`BatchMode`), so a key that does not work stops it. On the
  server, each place has its own key, made on the user's computer with a passphrase and unlocked
  with `ssh-add`, forced in `~/.ssh/authorized_keys` into rsync's daemon mode with that place's
  settings file in `~/.deploy/` (`rsyncd-hbmusic-<place>.conf`: the theme's and plugins' folders,
  the `deploy-note` folder and the read-only `php-log`), named `hbmusic-staging` and
  `hbmusic-live` in the user's SSH settings.
- `bin/site-check [--deadline <seconds>] [--retry-every <seconds>] <address>` (template plan
  1.4b, handbook chapter 2's step 7): every published page of the site at the address, from
  WordPress's page list, and the site's root, answers 200 directly, shows the child theme named
  in `site.json` active and ends with `</html>`; failing pages are tried again for up to 2
  minutes, and an unusable or empty page list fails. Only pages at that address are opened. A
  site behind a site-wide password gets its login from `SITE_CHECK_USER` and
  `SITE_CHECK_PASSWORD`, refused over plain `http://` except to this computer. Needs `curl` and
  `jq`. Run by
  `bin/deploy` after a copy (1.4d) and, against the dev site, by the scenario check
  `dev-site-check.sh` (which also switches the parent theme on and expects it to fail).
- `bin/screenshots previews | baseline | compare` (plan D29): a before/after check of the look with
  the real content, for restyling; local only, never a gate. It shows each real page from
  `data/content/` (listed in its `pages.json`; photos written `{{photo:<file>}}` from
  `data/photos/web/`) on the dev site at `/preview-<slug>/`, beside the stand-ins, shoots every
  page at desktop and phone width with Playwright's own comparison, and lists what changed
  since the baseline, with marked images in `screenshots/` (ignored by git). Outside services
  are answered locally; a page that does not answer 200 fails. Whether a change looks right is
  the user's call.
- `bin/tools-update`: the deliberate way to update the tools, `composer.lock`,
  `tests/e2e/package-lock.json` and `tools/css-lint/package-lock.json` (npm only from releases
  at least 7 days old, install scripts off); then `bin/check`, review the lock files' diff,
  commit.
- `tools/versions.sh`: the one place for the images and downloads these scripts use (the parent
  theme with its SHA-256); `bin/check` fails if the Playwright image and `@playwright/test`
  differ. npm installs run with `--ignore-scripts`. `tools/settings.sh`: the `.env` handling of
  `bin/dev-site`.
- `plugins/site-hardening/`: the security headers (Content-Security-Policy and the others,
  `docs/SITE_CHECKLIST.md` 3.2), XML-RPC refused, Application Passwords off, no version
  comments, no WordPress version in pages and feeds (0.3.0, handbook 12, 3.6) and no PHP version
  header (plan D26, 8k), HSTS for a year on HTTPS requests only and
  unfiltered HTML for Administrators only (handbook 12, 3.1 and 4.10), in a generic plugin that names nothing of this site, with its own prefix
  `sitehardening` and `phpcs.xml.dist`. It deploys like Song List. The policy's outside sources
  are this site's setting, added in the child theme's `functions.php`, each with its reason.

## Testing

- **Static checks:** `bin/check` (see Commands), before every commit; it also type-checks the
  browser tests (TypeScript, strict).
- **Scenario checks** (`tests/scenario/`): behaviour against the running dev site, such as the
  `.env` safety stop, the read-only theme and plugin mounts, and `bin/screenshots`'s previews
  (with a neutral fixture in `tests/scenario/fixtures/screenshots/`). Plain bash: the bats
  framework would need the Docker socket in its container.
- **Browser tests** (`tests/e2e/`, Playwright): the new theme on the dev site, with axe
  (`@axe-core/playwright`) for accessibility and a recorder for the browser's CSP violation
  reports, and the Song List's page and admin form, which log in with the dev admin.
- **PHPUnit** (unit and integration against a separate test database) arrives with the first
  plugin that has real logic to test; the Song List has almost none. **Accessibility checks**
  (axe) run in the dev browser tests since step 4c.
- A new test is shown to fail on a planted fault before it counts as working.
- **Tests share one dev site and run in parallel,** so each test is placed by what it changes:
  a test that only looks runs freely; a test that changes only its own uniquely named data (a
  song with a unique title, a booking request with a unique word) removes it afterwards and runs
  freely; a test that changes something shared (a setting, a plugin, the theme, the shared admin
  account, data other tests read) runs in a serial group or as a scenario check. No test logs
  out or changes the admin account, since the admin specs share one login: `admin.setup.ts` logs
  in once per run, without the login screen, and saves it to `tests/e2e/.auth/` (ignored by git),
  and only the specs that need the admin start from it (`test.use({ storageState })`).
  *Why:* WordPress loses data when two requests update the same stored value at the same moment:
  parallel logins as the same user lost a session, and that test found itself logged out (plan
  8d, 2026-11-09).

## Framework

- WordPress: PHP follows the WordPress Coding Standards (tabs, `snake_case`, the `hbmusic`
  prefix and text domain), as `phpcs.xml.dist` enforces. Where a generic editor rule contradicts
  them, WordPress wins: SonarQube for IDE's `php:S100` (camelCase names) and `php:S105` (spaces)
  are off in the user's VS Code user settings, because that extension reads rule settings only
  there (scope `application`), never from a project's `.vscode/settings.json`. Every other rule
  stays on, and its findings are fixed or explained.

## Project rules

- **Commit and push are separate decisions of the user.** "commit" means a local commit on a
  trial branch after the review gate; nothing leaves the computer. Only on "push" does Claude
  push the branch, open a pull request, wait for GitHub's `check` workflow, merge, and update
  the local `main` from GitHub. Local `main` never receives commits directly: GitHub's `main`
  is protected (the check required, also for administrators; no force-push).
  Claude suggests a push when it is a good moment (a finished step, before work that depends
  on GitHub, several commits waiting), saying what would go and why now, and pushes only after
  the user's yes for that push.
  *Why:* the user wants to commit freely and decide separately what goes public, without
  having to remember when to push.
- **Commit messages carry the description; pull requests take it from them.** Each commit
  message has a subject line and a body saying what changed and why, and ends with
  `Co-Authored-By: Claude …`. A pull request's title and description come from its commits
  (`gh pr create --fill`, or `--fill-verbose` for several commits), with no separately written
  text and no "Generated with Claude Code" line.
  *Why:* one text cannot drift from another; the commits credit both the user (author) and
  Claude (co-author), so a pull request line crediting only Claude would misstate the work.
  Exception: Dependabot's update commits keep the messages Dependabot writes
  (`.github/dependabot.yml` shapes their subject line); they are neither the user's nor Claude's
  work.

- **Git versions only an allow-list.** `.gitignore` ignores everything and allows back only
  the paths listed in it (the project's notes and plan, the tooling, the configuration, the
  local scripts, `themes/hbmusic-child/` and `plugins/song-list/`). A new path is versioned only by adding it to the
  allow-list, with the user's approval.
  *Why:* `wordpress/`, `db/` and `backups/` hold credentials (`wp-config.php`), database dumps
  with user accounts and emails, and the former host's account identifiers.
- **Before every commit, Claude lists the staged files** (`git diff --cached --name-only`) and
  checks that none is a `wp-config.php`, a `.sql`/`.sql.gz`, an archive, a log or an export.
  *Why:* one slip puts credentials into the history for good.
- **No host account identifiers, database credentials, salts or user data in committed files.**
  The export's file names contain the former host's account number; committed files name them
  by role ("the site archive", "the database dump") instead.
  *Why:* the global rule on personal data; the host account number counts as an account number.
- **Theme code never hardcodes the domain.** It asks WordPress for addresses (`home_url()`,
  `site_url()`, `get_theme_file_uri()` and similar). Server settings that name the domain
  (`wp-config.php`, the site URL in the database, security headers) live on the server, not in
  the repository. The domain may appear in notes and plans (plan decisions D6, D7).
  *Why:* the same theme must run unchanged locally, on staging and live; a hardcoded domain
  breaks on every move, and reviewers read it as careless work.
- **`backups/` and `wordpress/` are never changed.** Experiments run on copies.
  *Why:* they are the reference copy of the old site as exported.
