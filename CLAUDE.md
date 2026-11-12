# hbMusic_wp_site

What this file is: what is true of this project alone, loaded only in this repository; the
shared rules are in `~/.claude/CLAUDE.md`; "the user" is the person Claude works with.

## About

A musician's WordPress site, being rebuilt on a maintained theme (a Twenty Twenty-Five child
theme) and with booking features, to go live at its current host and move to another later.

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
- `data/`: not versioned; the site's real content and one-time data: the song list, the pages'
  wording and import file, and the photos.
- `docs/planning/rebuild-plan.md`: the active plan (rolling-wave mode); its Current position
  says where the work stands.
- `project-state.yaml`: session state for pause and resume, with the open items.
- `docs/ENVIRONMENTS.md`: the intended differences between the dev site, staging and live, each
  with its reason and where it is tested; a new difference is added there when it is introduced.
- `docs/ROUTINES.md`: the recurring care of the site (the monthly site check: a booking test and
  the content export), with what to do when the test fails.

The old site, as exported:
- Active theme: the parent `music-lite` 1.5 (unmaintained). A `music-lite-child` theme is
  installed but not active. `twentytwentyfive` 1.2 is installed.
- Plugins: `updraftplus`, `wordfence`, `wordpress-seo`, and Hostinger's auto-updates
  plugin (also as a must-use plugin in `wp-content/mu-plugins/`).
- `wordpress/staging/` is a second complete WordPress install (7.1.4) with the same themes;
  on the live server it was removed on 2026-11-02 (plan step 0g).

## Commands

The **dev site** runs in Docker Compose (`compose.dev.yaml`): a fresh WordPress with the new child
theme, the plugins and test content, with its settings in `.env` (created from `.env.example`
with random secrets; never committed). This project's ports are the **101xx** block: the dev
site on 10102, its Mailpit inbox on 10103, the rest of the block for later needs. The old site's local copy was removed at
plan step 5a-2; the real old site stays online until go-live, and the export stays in `backups/`,
`db/` and `wordpress/`.

- `bin/dev-site`: builds or rebuilds the dev site from nothing (an empty database each run):
  WordPress, the parent theme Twenty Twenty-Five at the version and SHA-256 pinned in
  `tools/versions.sh`, the child theme and the Song List plugin mounted read-only and activated,
  Contact Form 7 at the version in `tools/versions.sh`, checked against WordPress.org's checksums,
  with the real booking form from `config/booking-form.txt` and `config/booking-form-mail.json`,
  and its "sending failed" message from `config/booking-form-messages.json` (merged into Contact
  Form 7's own messages; staging and live get the same text typed in by hand),
  test pages (`tests/dev-content/`) and songs with neutral text, a stand-in Yoast organization
  (a neutral name and the theme's logo), a dev admin (`devadmin`, password
  `DEV_ADMIN_PASSWORD` in `.env`). `config/dev-mu-plugins/`, on the dev site only and never
  deployed, sends mail to Mailpit and answers for Cloudflare. Needs no backup, so CI can build it
  too.
- `bin/test`: the tests against the dev site: the scenario checks named
  `tests/scenario/dev-*.sh` (bash, sharing `lib.sh`: read-only theme and plugin mounts, an empty
  PHP debug log, the `.env` safety stop), then the browser tests in `tests/e2e/specs/dev/` in the
  official Playwright container (`--network host`, seeing only `tests/e2e/` and, read-only,
  `config/booking-form-messages.json`): child theme active,
  security headers sent, no CSP violation, no axe accessibility error at WCAG 2.2 AA, the Song
  List's page and admin form, the booking form's mail (no visitor's name in the subject), its
  message when sending fails (Mailpit made to refuse mail, in a serial group) and refusals, and its files loading only
  where it appears; the stylesheets loading only with what they style (the theme's components,
  the form's, the song table's from its plugin, plan D29), the bands' texture and the headings' even
  lines; the buttons' keyboard focus ring and
  its contrast against its band, equal sizes and equal widths in a row, no movement with reduced motion and no stuck hover
  after a tap (D29); the sticky header, a link reached with the keyboard never under it, the
  menu's current-page mark, no gap under a closing call to action, and the slimmer phone header
  (D29); the Site Hardening plugin's refusals; the old addresses' redirects; then, last, a check that the PHP debug
  log is still empty after everything (`tests/scenario/final-debug-log.sh`). If the site does not
  answer, the run fails; it is never skipped.
  Run it after `bin/dev-site` and before every commit that touches the site, the theme or a
  plugin. Every test runs even after a failure; exit status 1 if any failed.
- Dev site: http://localhost:10102 (admin `/wp-admin`); mail inbox: http://localhost:10103.
- `docker compose -f compose.dev.yaml stop` / `start`: stop and start without losing anything.
- `docker compose -f compose.dev.yaml run --rm cli wp <command>`: WP-CLI against the dev site.
- `docker compose -f compose.dev.yaml down -v` deletes the dev site's database and files (the
  volumes); Claude runs it only when the user asks. `bin/dev-site` rebuilds them.
- `bin/check`: every code check, in pinned containers (nothing installed on the host):
  Composer install from `composer.lock`, validation and security audit; PHPCS with the
  WordPress Coding Standards (`phpcs.xml.dist`); PHPStan at level max with the WordPress 7.1
  stubs (`phpstan.neon.dist`), both over `themes/` and `plugins/` (each plugin with its own PHPCS
  ruleset), and checks that plugins name nothing of this site and that each declares
  `Update URI: false`; `theme.json`'s schema matching
  the pinned WordPress; Stylelint over every CSS file in `themes/` and `plugins/` (its standard
  rules plus WordPress's formatting, `tools/css-lint/`, plan D29), with an npm audit of its
  packages; the theme's component list in `functions.php` matching the files in
  `assets/css/components/`, both ways, and every `site-…` component shown on a test page in
  `tests/dev-content/` (so the browser tests see it); ShellCheck on `bin/`; the compose file. Runs every check even
  after a failure; exit status 1 if any failed. The review gate starts with it. The tool
  containers see only the files their step needs, never `.env`, `db/`, `backups/` or
  `wordpress/`; `composer.lock` is read-only to them.
- GitHub runs `bin/check` on every push to `main` and every pull request
  (`.github/workflows/check.yml`); a pull request merges only when it passes.
- `bin/versions-check`: compares the dev site's pinned plugins and theme (`tools/versions.sh`) with
  WordPress.org and reports what is behind, changing nothing. Every Monday GitHub runs it with
  `--act` (`.github/workflows/versions.yml`, plan 8j): a plugin released at least 7 days ago gets a
  pull request raising its pin; the theme gets an issue only. The user clicks "Approve and run"
  on the pull request, which GitHub requires before testing a pull request its own token opened,
  and merges it on GitHub once its checks pass (`docs/ROUTINES.md`).
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
  comments and no PHP version header (plan D26, 8k), in a generic plugin that names nothing of this site, with its own prefix
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
  (`.github/dependabot.yml` shapes their subject line), and so do the versions check's
  (`bin/versions-check`, as GitHub Actions' bot); they are neither the user's nor Claude's work.

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
