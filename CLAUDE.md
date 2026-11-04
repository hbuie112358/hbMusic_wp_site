# hbMusic_wp_site

What this file is: what is true of this project alone, loaded only in this repository; the
shared rules are in `~/.claude/CLAUDE.md`; "the user" is the person Claude works with.

## About

A musician's WordPress site, being rebuilt on a maintained theme (a Twenty Twenty-Five child
theme) and with booking features, to go live at its current host and move to another later.

## Where things are

- `backups/`: the original host export, the site archive (`.tar.gz`) and the database dump
  (`.sql.gz`). Read-only (`chmod a-w`); never changed, moved or unpacked in place.
- `db/`: the database dump unpacked to plain `.sql` (WordPress 7.1.4, table prefix `wp_`).
- `wordpress/`: the old `public_html` exactly as exported. Kept unchanged as the reference copy
  of the old site; new work does not go here.
- `themes/hbmusic-child/`: the new Twenty Twenty-Five child theme, the only code this repository
  versions (created when the theme work starts).
- `docs/planning/rebuild-plan.md`: the active plan (rolling-wave mode); its Current position
  says where the work stands.
- `project-state.yaml`: session state for pause and resume, with the open items.

The old site, as exported:
- Active theme: the parent `music-lite` 1.5 (unmaintained). A `music-lite-child` theme is
  installed but not active. `twentytwentyfive` 1.2 is installed.
- Plugins: `updraftplus`, `wordfence`, `wordpress-seo`, and Hostinger's auto-updates
  plugin (also as a must-use plugin in `wp-content/mu-plugins/`).
- `wordpress/staging/` is a second complete WordPress install (7.1.4) with the same themes;
  on the live server it was removed on 2026-11-02 (plan step 0g).

## Commands

Two local sites run in Docker Compose, with their settings in one `.env` (created from
`.env.example` with random secrets; never committed): the **old-site copy** (`compose.yaml`,
the reference for the rebuild) and the **dev site** (`compose.dev.yaml`, a fresh WordPress
with the new child theme and test content, for building the theme). This project's ports are
the **101xx** block: the old-site copy on 10100, its Mailpit inbox on 10101, the dev site on
10102, the rest of the block for later needs.

- `bin/local-import`: builds or rebuilds the local copy from `wordpress/` and `db/`
  (read-only): fresh database, live addresses replaced, Wordfence and UpdraftPlus switched off,
  a local admin account (`localadmin`, password `LOCAL_ADMIN_PASSWORD` in `.env`), and
  FluentSMTP installed at a pinned version, checked against WordPress.org's checksums and
  pointed at Mailpit.
- `bin/dev-site`: builds or rebuilds the dev site from nothing (an empty database each run):
  WordPress, the parent theme Twenty Twenty-Five at the version and SHA-256 pinned in
  `tools/versions.sh`, the child theme mounted read-only and activated, test pages with
  neutral text, a dev admin (`devadmin`, password `DEV_ADMIN_PASSWORD` in `.env`). Needs no
  backup, so CI can build it too.
- `bin/test [local|dev]`: the tests in two groups, both without an argument. **local**, against
  the old-site copy: the scenario checks in `tests/scenario/` (bash, sharing `lib.sh`), then the
  browser tests in `tests/e2e/` in the official Playwright container (`--network host`, seeing
  only `tests/e2e/`). **dev**, against the dev site: the scenario checks named
  `tests/scenario/dev-*.sh`. A group whose site does not answer fails, never skipped. Run it
  after `bin/local-import` or `bin/dev-site`, after every FluentSMTP update, and before every
  commit that touches a site or the theme. Every test runs even after a failure; exit status 1
  if any failed.
- Old-site copy: http://localhost:10100 (admin `/wp-admin`); mail inbox: http://localhost:10101.
  Dev site: http://localhost:10102 (admin `/wp-admin`).
- `docker compose stop` / `docker compose start`: stop and start without losing anything
  (add `-f compose.dev.yaml` for the dev site, here and below).
- `docker compose run --rm cli wp <command>`: WP-CLI against the old-site copy.
- `docker compose down -v` deletes a site's database and files (the volumes); Claude runs it
  only when the user asks. `bin/local-import` or `bin/dev-site` rebuilds them.
- `bin/check`: every code check, in pinned containers (nothing installed on the host):
  Composer install from `composer.lock`, validation and security audit; PHPCS with the
  WordPress Coding Standards (`phpcs.xml.dist`); PHPStan at level max with the WordPress 7.1
  stubs (`phpstan.neon.dist`), both over `local/` and `themes/`; `theme.json`'s schema
  matching the pinned WordPress; ShellCheck on `bin/`; both compose files. Runs every check even
  after a failure; exit status 1 if any failed. The review gate starts with it. The tool
  containers see only the files their step needs, never `.env`, `db/`, `backups/` or
  `wordpress/`; `composer.lock` is read-only to them.
- GitHub runs `bin/check` on every push to `main` and every pull request
  (`.github/workflows/check.yml`); a pull request merges only when it passes.
- `bin/tools-update`: the deliberate way to update the tools, `composer.lock` and
  `tests/e2e/package-lock.json`; then `bin/check`, review the lock files' diff, commit.
- `tools/versions.sh`: the one place for the images and downloads these scripts use (the parent
  theme with its SHA-256); `bin/check` fails if the Playwright image and `@playwright/test`
  differ. npm installs run with `--ignore-scripts`. `tools/settings.sh`: the `.env` handling
  both site scripts share.

## Testing

- **Static checks:** `bin/check` (see Commands), before every commit; it also type-checks the
  browser tests (TypeScript, strict).
- **Scenario checks** (`tests/scenario/`): WP-CLI-level behaviour against the running sites,
  such as mail delivery, the configuration script's and `.env`'s safety stops, and (the
  `dev-*.sh` checks, against the dev site) the read-only theme mount. Plain bash: the bats
  framework would need the Docker socket in its container.
- **Browser tests** (`tests/e2e/`, Playwright): pages, menu and content as a visitor sees them.
  Their expected numbers are facts of the fixed dump in `db/` (plan step 2 inventory).
- **PHPUnit** (unit and integration against a separate test database) arrives at plan step 5a
  with its first real tests; **accessibility checks** (axe) arrive with the new theme at step 4.
- A new test is shown to fail on a planted fault before it counts as working.

## Framework

- WordPress: PHP follows the WordPress Coding Standards (tabs, `snake_case`, the `hbmusic`
  prefix and text domain), as `phpcs.xml.dist` enforces. Where a generic editor rule contradicts
  them, WordPress wins: SonarQube for IDE's `php:S100` (camelCase names) and `php:S105` (spaces)
  are off in the user's VS Code user settings, because that extension reads rule settings only
  there (scope `application`), never from a project's `.vscode/settings.json`. Every other rule
  stays on, and its findings are fixed or explained.
- Outside classes PHPStan cannot see are described by hand-written stubs in
  `tools/phpstan/stubs/`, each saying why it exists and when to replace it.

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
  (`.github/dependabot.yml` shapes their subject line); they are neither the user's nor
  Claude's work.

- **Git versions only an allow-list.** `.gitignore` ignores everything and allows back only
  the paths listed in it (the project's notes and plan, the tooling, the configuration, the
  local scripts, and `themes/hbmusic-child/`). A new path is versioned only by adding it to the
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
  *Why:* they are the reference copy of the old site as exported, and the source of every
  local rebuild.
