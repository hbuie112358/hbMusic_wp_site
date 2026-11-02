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
- Plugins: `updraftplus`, `wordfence`, `wordpress-seo`, and the former host's auto-updates
  plugin (also as a must-use plugin in `wp-content/mu-plugins/`).
- `wordpress/staging/` is a second complete WordPress install (7.1.4) with the same themes.

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
- `bin/local-mail-check`: sends one email through WordPress and checks it arrives in Mailpit;
  run it after `bin/local-import` and after every FluentSMTP update.
- Site: http://localhost:10100 (admin `/wp-admin`); mail inbox: http://localhost:10101.
- `docker compose stop` / `docker compose start`: stop and start without losing anything.
- `docker compose run --rm cli wp <command>`: WP-CLI against the local copy.
- `docker compose down -v` deletes the local database and files (the volumes); Claude runs it
  only when the user asks. `bin/local-import` rebuilds them.

## Testing

Not set up yet. The tools for each level of the global `TESTING_APPROACH.md` are decided
together with the local environment.

## Project rules

- **Git versions only an allow-list.** `.gitignore` ignores everything and allows back only
  `CLAUDE.md`, `.gitignore`, `project-state.yaml`, `docs/` and `themes/hbmusic-child/`. A new path is
  versioned only by adding it to the allow-list, with the user's approval.
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
  *Why:* they are the only full copy of the old site now that it is off the former host.
