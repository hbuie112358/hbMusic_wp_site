# Template notes

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

What a template for further WordPress sites (D18) would have to set differently from this site,
and where it is set. One line per item, added by each step that touches one. Read when the
template project starts; until then, a list, not a to-do.

## The site's name and prefix

- `hbmusic`, the Compose project name: `compose.yaml` (`name:`) and `bin/local-import`
  (`COMPOSE_PROJECT`). Set in two places; one would do.
- `hbmusic`, the PHP prefix and text domain: `phpcs.xml.dist` (both), and every function and
  `@package` tag in `local/wp-cli/` and `tools/phpstan/stubs/`.
- The package names: `composer.json` (`hbmusic/site-tools`), `tests/e2e/package.json` and its
  lock file (`hbmusic-e2e`).
- The cache volumes: `tools/versions.sh` (`hbmusic_composer_cache`, `hbmusic_npm_cache`).
- The theme folder: `themes/hbmusic-child/` and its line in `.gitignore`.

## Settings

- The ports (the 101xx block): `.env.example` (`SITE_PORT`, `MAIL_UI_PORT`) and the project's
  `CLAUDE.md`. Each project takes its own block.
- The live addresses replaced on import: `.env.example` (`LIVE_ADDRESSES`).
- The time zone used by the time report: `~/.claude/TIME_TRACKING.md` (the user's, not the site's).

## Belongs to a site moved from an old host

- `bin/local-import` builds the local copy from an old site's export (`wordpress/`, `db/`): a
  new site has none. A template needs a fresh-install path instead (WordPress and scripted test
  content), the same one the browser tests of the new theme will need in CI (step 4).
- `.env.example`: `LOCAL_DISABLED_PLUGINS` and `LOCAL_EMPTIED_TABLES` name this site's plugins
  (Wordfence, UpdraftPlus) and their tables.
- `tests/e2e/specs/local-import.spec.ts` checks facts of this site's dump (the menu, 108 songs,
  `PUBLIC_PATHS`); the template keeps the kinds of checks, not the values.
- Plan step 0 (securing an old live site) and the step 2 inventory are a moving-site checklist,
  a possible part of the template's plan for sites that are moved rather than new.

## Generic already, kept as they are

- `bin/check`, `bin/test`, `bin/tools-update`, `tools/versions.sh` (apart from the names above),
  `.github/workflows/check.yml`, `.github/dependabot.yml`, the allow-list `.gitignore`.
- Mail through FluentSMTP into Mailpit (D13), with `local/wp-cli/configure-fluentsmtp-mailpit.php`
  apart from its prefix.
- `docs/SITE_CHECKLIST.md`, on its way to a shared `~/.claude/WORDPRESS_STANDARDS.md` (D16).

## To build in

- `~/.claude/CLIENT_DATA.md` (not implemented yet): the template includes its settings block, so
  every customer project starts with it.
