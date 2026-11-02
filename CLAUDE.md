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

The local copy of the old site runs in Docker Compose (`compose.yaml`; settings in `.env`,
created from `.env.example` with random secrets; `.env` is never committed). This project's
ports are the **101xx** block: the site on 10100, the Mailpit inbox on 10101, the rest of the
block for later needs.

- `bin/local-import`: builds or rebuilds the local copy from `wordpress/` and `db/`
  (read-only): fresh database, live addresses replaced, Wordfence and UpdraftPlus switched off,
  a local admin account (`localadmin`, password `LOCAL_ADMIN_PASSWORD` in `.env`), and
  FluentSMTP installed at a pinned version, checked against WordPress.org's checksums and
  pointed at Mailpit.
- `bin/test`: every test against the running local copy: the scenario checks in
  `tests/scenario/` (bash, sharing `lib.sh`), then the browser tests in `tests/e2e/` in the
  official Playwright container (`--network host`, seeing only `tests/e2e/`). Run it after
  `bin/local-import`, after every FluentSMTP update, and before every commit that touches the
  site. Every test runs even after a failure; exit status 1 if any failed.
- Site: http://localhost:10100 (admin `/wp-admin`); mail inbox: http://localhost:10101.
- `docker compose stop` / `docker compose start`: stop and start without losing anything.
- `docker compose run --rm cli wp <command>`: WP-CLI against the local copy.
- `docker compose down -v` deletes the local database and files (the volumes); Claude runs it
  only when the user asks. `bin/local-import` rebuilds them.
- `bin/check`: every code check, in pinned containers (nothing installed on the host):
  Composer install from `composer.lock`, validation and security audit; PHPCS with the
  WordPress Coding Standards (`phpcs.xml.dist`); PHPStan at level max with the WordPress 7.1
  stubs (`phpstan.neon.dist`); ShellCheck on `bin/`; the compose file. Runs every check even
  after a failure; exit status 1 if any failed. The review gate starts with it. The tool
  containers see only the files their step needs, never `.env`, `db/`, `backups/` or
  `wordpress/`; `composer.lock` is read-only to them.
- GitHub runs `bin/check` on every push to `main` and every pull request
  (`.github/workflows/check.yml`); a pull request merges only when it passes.
- `bin/tools-update`: the deliberate way to update the tools, `composer.lock` and
  `tests/e2e/package-lock.json`; then `bin/check`, review the lock files' diff, commit.
- `tools/versions.sh`: the one place for the images these scripts use; `bin/check` fails if the
  Playwright image and `@playwright/test` differ. npm installs run with `--ignore-scripts`.

## Testing

- **Static checks:** `bin/check` (see Commands), before every commit; it also type-checks the
  browser tests (TypeScript, strict).
- **Scenario checks** (`tests/scenario/`): WP-CLI-level behaviour against the running copy,
  such as mail delivery and the configuration script's safety stops. Plain bash: the bats
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
