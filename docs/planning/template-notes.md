# Template notes

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

What a template for further WordPress sites (D18) would have to set differently from this site,
and where it is set. One line per item, added by each step that touches one. Read when the
template project starts; until then, a list, not a to-do.

## The site's name and prefix

- `hbmusic-dev`, the Compose project name: `compose.dev.yaml` (`name:`), and the database volume
  name derived from it in `tools/settings.sh` (`SETTINGS_DATABASE_VOLUMES`) and
  `tests/scenario/dev-settings-guard.sh`.
- The dev site's title, test pages and admin: `bin/dev-site` (`TEST_PAGES`, the title in
  `install_wordpress`) and `.env.example` (`DEV_*`); the browser tests' list of the same pages,
  `TEST_PATHS` in `tests/e2e/specs/dev/theme.spec.ts`.
- The parent theme and its pinned fingerprint: `tools/versions.sh` (`PARENT_THEME_*`).
- `hbmusic`, the PHP prefix and text domain: `phpcs.xml.dist` (both), and every function and
  `@package` tag in the theme.
- The package names: `composer.json` (`hbmusic/site-tools`), `tests/e2e/package.json` and its
  lock file (`hbmusic-e2e`).
- The cache volumes: `tools/versions.sh` (`hbmusic_composer_cache`, `hbmusic_npm_cache`).
- The theme folder: `themes/hbmusic-child/` and its line in `.gitignore`.
- The site's design and logo: `themes/hbmusic-child/theme.json`, `parts/`, `patterns/site-logo.php`
  and `assets/images/`; the neutral test pages' layouts in `tests/dev-content/` follow them.
- The theme's header in `themes/hbmusic-child/style.css`: its name ("Howard Buie Music") and
  description; the parent, text domain, versions and licence stay.

## Plugins

- A site chooses its plugins (plan D19). Each one sits in `plugins/<name>/`, needs a line in
  `.gitignore`, a mount in `compose.dev.yaml`, its `phpcs.xml.dist` run in `bin/check`, an entry
  in `DEPLOY_TARGETS` in `bin/deploy-staging`, and a destination in the server's rsync settings.

- The booking form: `config/booking-form.txt`, `config/booking-form-mail.json` and `config/booking-form-messages.json` (its "sending failed" text points to the contact links below the form on this site's Book page), and `CONTACT_FORM_7_VERSION` in `tools/versions.sh`.

- Site mail: a mail service through FluentSMTP (plan D24), set up per site with its own account, DNS records and retention rule; it works before a site is live, unlike Gmail through Google's API.
- Backups (plan D27): the host's own backups plus content exported by hand into the site's data folder. Fine for one site; with several, each site's export habit multiplies, which is the trigger to move every site to an encrypted, automatic tool (UpdraftPlus Premium, or Duplicator) at once.

## Settings

- The ports (the 101xx block): `.env.example` (`DEV_SITE_PORT`) and the project's `CLAUDE.md`. Each
  project takes its own block.
- The time zone used by the time report: `~/.claude/TIME_TRACKING.md` (the user's, not the site's).

## Belongs to a site moved from an old host

- The local copy of an old site (`compose.yaml`, `bin/local-import`, its tests) was removed at plan
  step 5a-2 (D20); it remains in this repository's history, if a moved site ever needs one. A
  template needs only the fresh-install path: `bin/dev-site` with `compose.dev.yaml`.
- Plan step 0 (securing an old live site) and the step 2 inventory are a moving-site checklist,
  a possible part of the template's plan for sites that are moved rather than new.

## Generic already, kept as they are

- `bin/check`, `bin/test`, `bin/tools-update`, `tools/versions.sh` (apart from the names above),
  `.github/workflows/check.yml`, `.github/dependabot.yml`, the allow-list `.gitignore`.
- `plugins/site-hardening/` (plan D26) as it is; each site adds its own outside sources, with
  their reasons, through the `sitehardening_csp_sources` filter in its theme. The theme's
  `functions.php` switching off WordPress's emoji script.
- `docs/SITE_CHECKLIST.md`, on its way to a shared `~/.claude/WORDPRESS_STANDARDS.md` (D16).
- The old-address redirects (plan D22, 8h): the function in the theme's `functions.php` is generic;
  the list `HBMUSIC_OLD_ADDRESSES` is the site's, empty for a new site, filled for a moved one.

## To build in

- `~/.claude/CLIENT_DATA.md` (not implemented yet): the template includes its settings block, so
  every customer project starts with it.
