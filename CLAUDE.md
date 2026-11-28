# hbMusic_wp_site

What this file is: what is true of this project alone, loaded only in this repository; the
shared rules are in `~/.claude/CLAUDE.md`; "the user" is the person Claude works with.
Belongs here: rules, how the user and Claude work in this project, and a short entry per
command. Not here: how a tool works inside (its own header comment, or `docs/TOOLS.md`),
history, or anything already in a plan or record. Claude checks this before adding to the file.

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
  - E8 Contrast checked by the color pairs in use, not every pair the palette allows.
  - E9 No captions or transcript for the videos' brief spoken introductions.
  - E10 Backups by D27 (host backups and monthly content exports), not chapter 4's two layers.
  - E11 No DNSSEC and no CAA record at Hostinger's DNS.
- Status against the site standard (chapter 12): `records/status.md`, held complete by
  `bin/check`; the expected plugin set: `records/plugin-set.md`.

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

- **The tools** (`dts-site-tools`, template plan 2.1d): installed by Composer from
  `composer.lock` into `vendor/dts/site-tools/`, their commands into `bin/` (both ignored by
  git; the install command is in the tools' `README.md`, and runs after a fresh clone and after
  each change to `composer.lock`). Paths such as `tools/…`, `tests/e2e/`, `tests/scenario/`,
  `compose.dev.yaml` and `docs/TOOLS.md` in this file and the site's documents name files
  there. A change to them is made in `~/dev/dts-site-tools` (its own repository), never in
  `vendor/`. The site's own tests and checks stay here: `tests/browser/`, `tests/checks/`,
  `tests/dev-content/`, `tests/dev-setup.sh`.
- `backups/`: the original host export, the site archive (`.tar.gz`) and the database dump
  (`.sql.gz`). Read-only (`chmod a-w`); never changed, moved or unpacked in place.
- `db/`: the database dump unpacked to plain `.sql` (WordPress 7.1.4, table prefix `wp_`).
- `wordpress/`: the old `public_html` exactly as exported. Kept unchanged as the reference copy
  of the old site; new work does not go here.
- `themes/hbmusic-child/`: the new Twenty Twenty-Five child theme.
- Song List (plan D19): not in this repository since template plan 2.2b; its own repository
  `direct-technical-solutions/dts-song-list`, installed by Composer from
  `site-packages/composer.lock` at its release tag (`dts/song-list`); its prefix `songlist` and
  text domain `song-list`. A change to it is made in its repository (locally
  `~/dev/dts-song-list`) and reaches this site by a new tag and a raised pin, never by editing
  `site-packages/`.
- Site Hardening (plan D26) and Editing Help (handbook H89): not in this repository since
  template plan 2.2c; their own repositories `direct-technical-solutions/dts-site-hardening` and
  `dts-editing-help`, installed by Composer from `site-packages/composer.lock` at their release
  tags (`dts/site-hardening`, `dts/editing-help`). Site Hardening: the security headers and other
  hardening; the policy's outside sources handed in by the child theme through the plugin's
  `sitehardening_csp_sources` filter (listed, each with its reason, in the theme's `site-facts.json`;
  the shared video code adds its own player); prefix `sitehardening`, text domain
  `site-hardening`. Editing Help: the content guide in the admin, fed by the child theme through
  the plugin's filters; prefix `editinghelp`, text domain `editing-help`; the guide's text is also
  kept in the handbook (`customer/content-guide.md`), with the same version number, and a change
  goes into both. A change to either is made in its repository (locally `~/dev/dts-site-hardening`,
  `~/dev/dts-editing-help`) and reaches this site by a new tag and a raised pin, never by
  editing `site-packages/`.
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
- `starter/`: the starter, the neutral site a new site begins from (template plan 1.6, T13),
  moving to `dts-site-starter` at 2.4c: its own `site.json`, its own downloaded plugins in
  `site-packages/` (template plan T28; Song List not among them), its full child theme in
  `themes/dts-starter/` (2.4b, T29: its own site layer, `tools/site-layer-files.txt`, and the
  shared theme files, which `bin/check` holds identical to this site's, so a change to one is
  made in both), neutral pages in `tests/dev-content/`, and its `README.md` with the palette's
  contrast. Never deployed; `bin/check` holds it. Laid out as a site, so the tools work on it
  with `SITE_DIR=starter` (template plan 1.6c, T14).
- `resume-state.yaml`: only what resume needs to get back to where the last pause left off,
  with the open items; each pause replaces it, never appends. Past sessions and the sites' facts
  once kept there: `docs/session-history.md`, not read at resume.
- `docs/ENVIRONMENTS.md`: the intended differences between the dev site, staging and live, each
  with its reason and where it is tested; a new difference is added there when it is introduced.
- `docs/ROUTINES.md`: the recurring care of the site (deploying, the monthly site check, what to
  do on each alert, visitors' data requests), the same for every DTS site (template plan 1.5c);
  it links each of this site's details (places, host, mail, uptime monitor, plugins and theme,
  the expected set) to its heading in `docs/SITE_SPECIFIC_ROUTINES.md`; `bin/check` keeps the
  two in step.
- The old site's themes and plugins as exported: `docs/session-history.md`
  (`old_site_as_exported`).

## Commands

What each command checks or does, in full: `docs/TOOLS.md`, read before working on a tool or
when its details matter. The scripts need only Docker and `jq` on this computer (`bin/deploy`
also `git`, `gh`, `rsync`, `ssh`, `curl`, `flock`); they read the site's facts from `site.json`
and stop at once, naming the problem, if it breaks its rules. Ports: the **101xx** block.

- **Dev site:** http://localhost:10102 (admin `/wp-admin`); mail inbox: http://localhost:10103.
  Logins: `devadmin` and `deveditor`, passwords `DEV_ADMIN_PASSWORD` and `DEV_EDITOR_PASSWORD` in
  `.env`; to copy one without showing it:
  `grep '^DEV_ADMIN_PASSWORD=' .env | cut -d= -f2- | tr -d '\n' | wl-copy`.
- **Which site:** `bin/dev-site` and `bin/test` work on this repository's site unless `SITE_DIR`
  names another site's folder (`SITE_DIR=starter`); one dev site runs at a time, and both refuse,
  naming the command that stops the other by name (`docker compose -p <slug>-dev stop`).
  `bin/check` always checks this repository; `bin/deploy` and `bin/screenshots` refuse another site.
- `bin/dev-site`: builds the dev site from nothing (an empty database each run).
- `bin/test`: the scenario checks and the browser tests against the dev site; every test runs
  even after a failure. What Claude runs before a commit: Testing.
- `bin/check`: every static check, in pinned containers; every check runs even after a failure.
  Its parts: the site's checks, the site's own in `tests/checks/`, and that the site's workflows
  call the installed tools (`bin/tools-pin`). The tools' own self-check runs in their repository.
  The review gate starts with it.
- The tools' `compose.dev.yaml` and `compose.site.yaml` (written from `site.json`; never edited)
  are the dev site's recipe, which `.env`'s `COMPOSE_FILE` names; after changing `site.json`, run `bin/dev-site` before typing compose commands.
  `docker compose stop` / `start` keep everything; `docker compose run --rm cli wp <command>` is
  WP-CLI; `docker compose down -v` deletes the dev site's data, and Claude runs it only when the
  user asks.
- GitHub runs `bin/check` and the dev site's tests on every pull request, weekly and by the button;
  a merge deploys nothing. The site's three workflows only call the tools' shared ones, pinned to
  the commit `composer.lock` installs; `bin/tools-pin` writes them, never edited by hand.
- `site-packages/`: the downloaded plugins, pinned by Composer; Dependabot's WordPress.org plugin
  updates merge themselves (T9); updates to `composer/installers` and to the tools wait for the
  user's review.
- `bin/versions-check`: the weekly alerts for the parent theme, waiting plugin updates and the
  deploy test server's packages.
- `bin/deploy staging|live`: run by the user, the only way code reaches staging and live.
- `bin/site-check <address>`: every published page answers with the child theme active.
- `bin/accessibility-scan <address>`: axe and alt text on every page; monthly against live.
- `bin/screenshots previews | baseline | compare`: before/after pictures of the real content, local
  only, never a gate; whether a change looks right is the user's call.
- `bin/tools-pin`: writes the site's three workflows for the tools release `composer.lock`
  installs; run after each tools update, on its branch (`bin/check` fails until then).
- The tools' `tools/versions.sh`: the one place for the images and downloads the scripts use,
  the parent theme's pinned version included, so raising it takes a tools release.

## Testing

- **Static checks:** `bin/check` (see Commands), before every commit; it also type-checks the
  browser tests (TypeScript, strict).
- **Before a commit that touches the site, the theme or a plugin, Claude runs `bin/check` and
  the browser tests of the part changed** (their spec files, in the Playwright container as
  `bin/test` runs them), plus any scenario check the change touches. The full `bin/test` runs on
  GitHub for every pull request (the required `dev-site` job); Claude runs it locally only for a
  change that reaches across the site. *Why:* the user, 2026-11-17: a small code change took
  about 15 minutes from ready to live, the full tests running three times.
- **Scenario checks** (`tests/scenario/`): behaviour against the running dev site, such as the
  `.env` safety stop, the read-only theme and plugin mounts, and `bin/screenshots`'s previews
  (with a neutral fixture in `tests/scenario/fixtures/screenshots/`). Plain bash: the bats
  framework would need the Docker socket in its container.
- **Browser tests** (the tools' `tests/e2e/` and this site's `tests/browser/`, Playwright): the new theme on the dev site, with axe
  (`@axe-core/playwright`) for accessibility and a recorder for the browser's CSP violation
  reports, and the Song List's page and admin form, which log in with the dev admin.
- **PHPUnit:** none yet; added (unit, and integration against a separate test database) with
  the first plugin here that has real logic to test.
- A new test is shown to fail on a planted fault before it counts as working.
- **The starter is tested with every change to what it shares** (template plan T15, the user,
  2026-11-24): before committing a change to the theme's generic files (anything outside the
  site layer, `tools/site-layer-files.txt`), the shared tests (`generic/`, `components/`,
  `helpers/`, the plugins' tests), the tools (`bin/`, `tools/`) or a plugin the starter lists,
  Claude also runs the starter's tests: this site's dev site stopped by name
  (`docker compose -p hbmusic-dev stop`), `SITE_DIR=starter bin/dev-site`, `SITE_DIR=starter
  bin/test`, then the starter's stopped and this site's started again. The review gate reports
  the result. A change to this site's own files only (its site layer, its `tests/browser/` specs, its
  content) does not need it. *Why:* the pull-request checks test this site alone; the starter
  has no scheduled run, and both of its earlier breaks (1.6a, 1.6c-2) passed every check here.
- **During the template's stage 2, the proof waits for milestones** (template plan T21, the user,
  2026-11-24): the starter's tests and the full checks run at the template plan's milestones (T21)
  and before every deploy, which stays strict; in between, Claude runs only what a change
  touches, or nothing for documents and copies. This replaces the starter rule above until
  stage 2 is done. *Why:* nothing reaches the website without `bin/deploy`, and the user wants
  the work behind the scenes finished quickly.
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

- WordPress: PHP follows the WordPress Coding Standards (tabs, `snake_case`, the shared
  theme code's prefix `dtstheme` and text domain `dts-theme`, the same in every site, template
  plan T30), as `phpcs.xml.dist` enforces. Where a generic editor rule contradicts
  them, WordPress wins: SonarQube for IDE's `php:S100` (camelCase function names), `php:S101`
  (class names without underscores), `php:S116` (camelCase properties; the WordPress standard
  requires snake_case, 2026-11-27) and `php:S105` (spaces) are off in the user's VS Code user
  settings, because that extension reads rule settings only
  there (scope `application`), never from a project's `.vscode/settings.json`. Every other rule
  stays on, and its findings are fixed or explained.

## Coding standards by language

The standard for each language this project uses. A written standard file is imported here, so
it is loaded from the start of every session, before any code is written:

@~/.claude/TYPESCRIPT_STANDARDS.md

Production code means what runs on the site (the theme and the plugins); test code means the
tests and the tools that check the code.

- **PHP** (the theme, the plugins): the WordPress Coding Standards, as `phpcs.xml.dist` enforces
  them (see Framework).
- **TypeScript and the theme's JavaScript:** `~/.claude/TYPESCRIPT_STANDARDS.md`, strictly for
  production code (the theme's scripts in `assets/js/`, type-checked and linted
  with ESLint through `tools/js-check/`). Test code (the browser tests in `tests/e2e/`) is held to clarity instead
  (the user, 2026-11-23): every failure message names what failed and where; no silent `catch`;
  no `any`, `!` or `@ts-ignore`; clear names, helpers kept short. Plain `Error`, a cast after an
  upstream check, and the test runner's output in place of a logger are fine there.
- **CSS** (the theme, the plugins): `docs/planning/css-standards-notes.md`, read before any CSS
  or `theme.json` work (observations until a global CSS rule exists), and Stylelint in
  `bin/check`.
- **Bash** (`bin/`, `tools/`, the scenario checks): ShellCheck in `bin/check`; no written
  standard yet (written when the user chooses, proposed item by item like the CSS notes).

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
- **The pull request carries the story's message; it becomes the squash commit on `main`.**
  The squash rule of the global `PULL_REQUESTS.md` applies; in this project the pull request's
  title and description are that squash message, ending with `Co-Authored-By: Claude …` and
  with no "Generated with Claude Code" line. Commits on the branch are working notes, short, in
  the Conventional Commits form, with the same `Co-Authored-By` line.
  *Why:* the squash commit credits both the user (author) and Claude (co-author), so a pull
  request line crediting only Claude would misstate the work; one approved text is both the
  pull request's and `main`'s, so the two cannot drift.
  Exception: Dependabot's update commits keep the messages Dependabot writes
  (`.github/dependabot.yml` shapes their subject line); they are neither the user's nor Claude's
  work. The tools' plugin-updates workflow squash-merges them with that message; a pull request
  with more than one commit waits for the user.

- **Git versions only an allow-list.** `.gitignore` ignores everything and allows back only
  the paths listed in it (the project's notes and plan, the tooling, the configuration, the
  local scripts and `themes/hbmusic-child/`). A new path is versioned only by adding it to the
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
