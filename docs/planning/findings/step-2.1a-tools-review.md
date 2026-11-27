# Step 2.1a: the tools review

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Every tool, test and workflow of this repository, sorted by where it goes in stage 2 (template
plan 2.1a, T17). Read by Claude on 2026-11-24 from the tools' header comments, `docs/TOOLS.md`,
`bin/check`'s list of checks, the three workflows and `.github/dependabot.yml`; decided by the
user the same day (Claude's recommendations accepted). Nothing was changed by the review.

## Moves to `dts-site-tools` (2.1)

| Item | Notes |
|---|---|
| `bin/dev-site`, `bin/test`, `bin/check`, `bin/deploy`, `bin/site-check`, `bin/accessibility-scan`, `bin/tools-update`, `bin/versions-check`, `bin/screenshots` | `bin/check` without the checks listed under the later steps below. `bin/versions-check` whole: the parent theme's pin (not pinned through Composer), the deploy test server's packages, and the plugin alerts (Dependabot says nothing about a stuck update; the "release never proposed" alert is the one that would explain the Contact Form 7 6.2.6 timing). `bin/screenshots` because the second site is styled from scratch. |
| `tools/settings.sh`, `site-settings.sh`, `site-settings.jq`, `site-settings.md`, `site-packages.sh`, `dev-site-guard.sh`, `routines.sh`, `status-sheet.sh`, `status-sheet-blank.md`, `versions.sh` | `dev-site-guard.sh` and `SITE_DIR` stay: one computer runs several sites' dev sites. |
| `tools/css-lint/`, `tools/js-check/`, the top-level `composer.json` and `composer.lock` (PHPCS, PHPStan, the stubs) | Their updates then come once, in the tools' repository, not once per site. |
| `compose.dev.yaml`, `.env.example`, `config/dev-mu-plugins/` | `hbmusic-dev-services.php` uses the `hbmusic` prefix throughout (constants, functions, `@package`): renamed for the tools when it moves. |
| `tests/e2e/`'s setup (`package.json`, its lock file, the three configs, `tsconfig.json`), `specs/dev/generic/`, `specs/dev/helpers/`, `accessibility-scan/`, `screenshots/` | |
| `tests/scenario/lib.sh`, `debug-log.sh`, `generic/*` (the deploy test server included), `fixtures/screenshots/` | |
| `tests/tools/*` | The tools' own tests: deploy, site-check, versions-check, site-settings, dev-site, dev-site-guard, debug-log, routines, status-sheet. |
| `.github/workflows/check.yml`, `versions.yml`, `plugin-updates.yml` | Become reusable workflows; each site keeps a few lines calling them, pinned by commit (T17). |
| `bin/check`'s two "names nothing of this site" checks | Kept (they caught leaks in stage 1); in the shared repositories they check against a list of known site names. |

## Stays with the site

| Item | Why |
|---|---|
| `site.json`, `site-packages/`, `tests/dev-content/`, `tests/dev-setup.sh`, `config/booking-form*` | This site's facts and content. |
| `tests/e2e/specs/dev/site/` | This site's own tests. |
| `phpcs.xml.dist`, `phpstan.neon.dist` | They name this site's prefix and folders; a shared base ruleset is a possible refinement in 2.1b. |
| `.github/dependabot.yml` | GitHub reads it only from the site's own repository; it shrinks to the site's plugins and the tools' pin. |

## Moves later, with another step

| Item | Step |
|---|---|
| `specs/dev/components/`, `scenario/components/`, the components' example page, `tools/theme-tokens.sh`, `bin/check`'s component-list and "components appear on the example pages" checks | 2.3, the components plugin (`theme-tokens.sh` may instead stay a tool reading the plugin's token list). |
| `specs/dev/plugins/*`, `scenario/plugins/*` | 2.2, each plugin's repository; Simple History's activity-log check (a WordPress.org plugin) stays a site test or moves to the tools, decided there. |
| `bin/check`'s seven starter checks, `tools/site-layer.sh`, `tools/site-layer-files.txt` | 2.4, the starter repository's own checks. |
| `tools/site-theme.sh` and the starter's theme assembly | Removed at 2.3, once the shared theme code has left the child theme (it is the stand-in until then). (Since T29, 2026-11-27: removed at 2.4, when the starter gets its own copy.) |

## The two checks on reusable workflows

Read in GitHub's documentation on 2026-11-24:

1. **The organization's pinning rule does not cover reusable workflows.** "When you enable
   Require actions to be pinned to a full-length commit SHA, all actions must be pinned to a
   full-length commit SHA to be used. Reusable workflows can still be referenced by tag."
   ([organization settings](https://docs.github.com/en/organizations/managing-organization-settings/disabling-or-limiting-github-actions-for-your-organization)).
   Pinned by commit anyway (T17). The handbook's open trap in `toolkit/github.md` is answered;
   its wording is proposed to the user separately.
2. **A repository on the user's personal account may call them.** A public caller can use
   reusable workflows from public repositories, and the caller's Actions settings must allow
   them ([reusable workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/reusable-workflows)).
   This repository is public with "all" actions allowed (checked with `gh api`, 2026-11-24). The
   documentation words one condition for organizations only, so the first real call (2.1c)
   confirms it.

Not settled by the documentation, so 2.1c's first trial shows them: which repository a called
workflow checks out by default, and whether it can read its own repository's scripts without a
second checkout.

## Left open for 2.1b

- How a site runs the tools: from a folder git ignores (such as `vendor/…/bin/check`) or through
  a small `bin/` wrapper in each site.
- Whether `dts-site-tools` requires PHPCS and PHPStan itself, so a site gets them with it, or each
  site keeps its own top-level `composer.json`.
- Keeping the Composer pin and the workflows' `uses:` commit on the same release; whether
  Dependabot raises both is not verified.
