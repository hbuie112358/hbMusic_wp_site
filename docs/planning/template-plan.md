# Template plan

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The brochure-site template: the shared pieces every DTS brochure site is built on, and the
starter a new site is created from (handbook chapter 7, H28-H30), extracted from this project
and proven on it before the user's second site starts from it. Worked in rolling-wave mode
(`~/.claude/ROLLING_WAVE_MODE.md`): near steps in detail, later ones rough, new findings added as
steps. This project's own remaining work stays in `docs/planning/rebuild-plan.md`.

## Current position

- **Where the work stands:** planned 2026-11-20 (T1-T4); step 1.1 decided 2026-11-21 (T5, T6);
  `site.json` built (1.2a) and read by `bin/dev-site` (1.2b), 2026-11-21. The plan reviewed the
  same day as a whole for overkill and gaps (the user's request): pinning moves to Composer (T8);
  new sites start with fewer site tests (1.3); `bin/detach` stays, built in 2.1; a routine for a
  new site's first content and a developer guide added (2.4). The GitHub organization
  direct-technical-solutions exists and the handbook moved into it (its settings in the
  handbook's `toolkit/github.md`).
- **Next:** step 1.2d, `bin/check` reading `site.json` (1.2c, the plugins through Composer, done
  2026-11-21).
- **Then, in order:** 1.2 to 1.6 (stage 1, in this repository), then 2.1 to 2.5 (stage 2, the
  shared repositories).
- **Kept waiting, not forgotten (the user, 2026-11-20):** the rebuild plan's **9u**, the booking
  form's message when the "not a robot" check has not finished. The template came first by the
  user's choice; 9u is done at the first break in this plan's work that suits the user.
- **Waiting on the user:** deleting the trial repository once its result is in (the tools here
  cannot delete repositories).
- **Open decisions waiting on the user:** the handbook's wording for T5 (chapter 7) and T6
  (chapters 7 and 9), proposed when each is built and approved by the user before anything is
  written there; whether tools updates merge by themselves once their checks pass (GitHub's
  auto-merge, T6); the second site's facts (a new build or a takeover; the user's own or a
  customer's, which decides a public or private repository).
- **Shared with the rebuild plan:** `bin/deploy` is this plan's step 1.4 and the rebuild plan's
  item 5, done once.
- **Stale:** nothing yet.

## Decisions

| # | Decision | Why |
|---|---|---|
| T1 | Two stages (the user, 2026-11-20). Stage 1, in this repository: the site tools made generic (a per-site settings file instead of this site's names in the scripts), the tests split, `bin/deploy` built generic, the records and care pieces, neutral defaults; proven by this site's `bin/check` and `bin/test` passing. Stage 2: the pieces extracted into fresh shared repositories in the organization, with no history from this project (D18), and this site switched over to them. | Making the tools generic changes this site's own scripts and is proven by this site's checks; doing it and moving it at the same time would make a failure hard to place. Working on this repository from a separate project's session would need the user's approval at every edit (the global rule on paths outside the current project). |
| T2 | Each DTS plugin has its own repository, as H28 says (the user, 2026-11-20), with its checks and release workflow called from `dts-site-tools` as reusable workflows, so a new plugin's repository is a few lines. (2026-11-21: reusable workflows are used while DTS manages a repository; a handed-over one gets full copies, T6. A release is a Git tag, pinned by Composer, T8.) | One repository for all plugins was weighed: less setup, but a custom release workflow, a required summary check, a guard against plugins depending on each other, and no plugin could be private, sold or handed over without being split out. With reusable workflows, separate repositories lose most of their cost. Rollback is the same either way: a site lowers its pin to the old release, which is kept. |
| T3 | The template work's time is logged in this project (the user, 2026-11-20). | Stage 1 is done in this repository; the user does not need it apart. |
| T4 | The shared repositories' histories are the template's history. A site is tied to the template by its pins (tools and plugins), the starter version it was created from (in its records), and issues and pull requests in the shared repositories that name the site that prompted them. Each shared repository keeps a changelog. A template change that is really a rule goes to the handbook, with the user's approval. | So a site can tell which template it runs, and the template can tell why it changed. |
| T5 | The generic theme code lives in a shared plugin, `dts-site-components` (the user, 2026-11-21): the component stylesheets and their per-block loader, the carousels' screen-reader work, the empty-heading drop, the click-to-load videos, the video and menu scripts, the lazy-loading and embed-title fix, the current-page mark, the privacy link, the redirect function, the emoji removal and the booking form's page-only loading. Each site's child theme keeps the site layer (`theme.json`, `parts/`, the logo) and its own lists, handed to the plugin through filters (old addresses, areas served, the organization's type, the policy's outside sources). A piece goes into the plugin if almost every site would want it and it is about how pages look or behave; anything else gets a plugin of its own (D19). The plugin documents the token names its CSS needs, and `bin/check` verifies each site's `theme.json` defines them; the deploy's page check confirms the plugin is active, since a theme cannot require a plugin. Handbook chapter 7's empty starter child theme and "no shared parent theme" stay; its wording gains the plugin, with the user's approval. | A site's child theme cannot reach another site's, WordPress allows one parent and no grandchild themes, so shared code needs a home beside each site's theme: a plugin, released and pinned like the others (H28, T2). A full child theme copied into each site would drift; a shared parent theme would mean maintaining a whole standalone theme; copies locked by a check would add a copy step and files no one may edit. Checked first on the dev site (2026-11-21): a stylesheet a plugin hands to `wp_enqueue_block_style()` loads on the public page, in the page editor's canvas and in the Site Editor's canvas, as the theme's `buttons.css` does; with the probe plugin deactivated, its marker was missing in all three (the fault caught). Whether a plugin can supply the call-to-action page templates is checked when the plugin is built; until then they stay in the starter's child theme. |
| T6 | (2026-11-21: the pin, fetch script and release zips below are replaced by Composer, T8; the two modes, the reusable workflows and `bin/detach` stay.) A site has two modes (the user, 2026-11-21). **Managed by DTS (central):** the tools, the plugins and the GitHub workflows live centrally in DTS's repositories; the site's repository holds only pointers that rarely change: a pin naming the tools' release and its SHA-256, a small fetch script that downloads that release into a folder git ignores and refuses it if the checksum differs, and a workflow of a few lines calling DTS's reusable workflows pinned to the release's commit. Raising the pin updates everything; the weekly versions check proposes it. **Handed over (detached):** one command, `bin/detach`, copies the pinned tools, the plugin zips and full workflows into the site's repository, removes every reference to DTS's repositories, and runs the site's checks to prove it stands alone; then the repository is transferred (handbook chapter 9, wording with the user's approval). The tools' own release checks run `bin/detach` on a throwaway copy of a site every release, so it still works years later. The tools carry an open license, so the customer may keep and change the copy. | The user wants the simplest upkeep for managed sites (one central copy of everything) and no dependency on DTS after a handover, the GitHub workflows especially. The live website never depends on the tools (they check, test and deploy; the site runs the theme and plugins), so central tools risk only a managed site's checks, which DTS looks after. Weighed: a git submodule (easy to get wrong, pins a commit rather than a release); a copy committed into every site at all times (large diffs on each update, history piling up, files open to hand edits); thin workflows copied into every site with no reusable workflows (independent, but one more copy per site to keep in step). With the tools never reaching the live site, tools updates could merge by themselves once their checks pass (GitHub's auto-merge); whether they do is still open for the user; plugin updates, which reach the site, keep the user's yes. After a handover the customer's GitHub account's settings apply, not the organization's; what a repository transfer carries over (branch protection, required checks, settings) is not verified, and the handover checklist confirms it on the transferred repository. |
| T7 | (2026-11-21: the plugin list and the plugins' pins move to Composer, T8; `site.json` keeps the rest.) The site's facts in one committed file, `site.json`, at the repository's top level (the user, 2026-11-21): its slug, its theme folder, its plugins (each with its source: `local` for a folder in the repository, mounted read-only; `wordpress.org`, checked against WordPress.org's checksums; later `dts`, a pinned DTS release with its checksum), the dev site's title, the test pages (title, address, page template, and which is the front page, the privacy page and outside the menu), and the names the plugins must not use. Versions stay in `tools/versions.sh` until stage 2. `.env` keeps the secrets and the computer's ports; `site.json` holds no secrets. Field names describe themselves (the coding standards' rule 3). A check in `bin/check`, with `jq`, refuses a missing required field, an unknown field (a typo) and a wrong type, naming the field. A short page, `site-settings.md`, kept with the tools, explains each field under a heading of its exact name (what it is for, an example, what changes when it changes); the check compares its headings with the valid fields both ways, so a field without an explanation and an explanation of a field that no longer exists both fail. A tools release that needs a new field gives it a default where one makes sense; otherwise the tools refuse and name the field, and the release's changelog lists it. Volume and cache names are built from the slug, so this site's stay `hbmusic` and its dev site and caches are kept. A new check fails when a site's names appear in the tools, as one already does for the plugins. | So the same scripts serve any site, each site bringing its own facts, with this site's checks and tests passing unchanged as the proof. JSON over YAML: the scripts (through `jq`, already used by the versions check), the browser tests and PHP all read it with nothing new to install, and a mistake in it is an error rather than a different value; YAML would allow comments but needs `yq` and an npm package. A JSON Schema with a validator was weighed and judged more than a small file edited once per site needs; it is looked at again if the file grows large or other people edit it. The explanation page serves the user returning after months and a customer's developer after a handover; kept with the tools, it changes with them and travels with `bin/detach`. |
| T8 | Plugins, and later DTS's own plugins and the tools, are pinned with Composer (the user, 2026-11-21), not with pins, fetch scripts and release zips of DTS's own: WordPress.org plugins through WPackagist (`wpackagist-plugin/<slug>`, placed in `wp-content/plugins/` by `composer/installers`), DTS's plugins and tools from their GitHub repositories by version tag, `composer.lock` holding the exact versions and commits. `composer.json` becomes the site's one plugin list (it replaces `site.json`'s `plugins` and the plugin pins in `tools/versions.sh`). Updates come from Dependabot, which this project already runs for Composer with a 7-day wait, so the plugin part of `bin/versions-check` is retired. WordPress.org's own checksum check (`wp plugin verify-checksums`) still runs after each install, and the review gate checks that every WordPress.org plugin's download address in `composer.lock` is on `downloads.wordpress.org`. A DTS plugin release is a Git tag, so no release pipeline of zips is built; `bin/detach` (T6) can point a handed-over repository at copies of the pinned packages (Composer's `artifact` repositories). To decide in 1.2c: the parent theme, whose zip has a fingerprint pinned by hand because WordPress.org publishes no checksums for themes, and how the site's `local` plugins are listed. | From the plan's review (the user's request, 2026-11-21): the project's rule against reinventing the wheel, since the plan was building by hand what Composer, the WordPress world's standard package manager, already does, and what this project already uses for its checking tools. Checked first on a throwaway trial (2026-11-21, nothing in the repository touched): Contact Form 7 6.2.5 and Yoast 28.8 installed at their pinned versions; every file matched WordPress.org's checksum list (218 and 1,949 files, none missing, different or extra); the lock file's downloads come straight from `downloads.wordpress.org`, WPackagist giving only the list of versions; an install from the lock file worked with WPackagist made unreachable, so WPackagist is needed only when a version changes; the lock file holds no fingerprint for these zips, normal for Composer, which is why WordPress.org's checksum check stays. A throwaway public repository in the organization showed Dependabot proposing Contact Form 7 6.2.4 to 6.2.5 through WPackagist with no extra setup, both files changed correctly. WPackagist is run by WP Engine, a third party; its outage would delay updates only. Kept from T6: the two modes, the reusable workflows, `bin/detach`. |

## Steps

### Stage 1: in this repository

- [x] **1.1 Two technical decisions** (2026-11-21): (a) the shared plugin (T5); (b) central
  while managed, detached at a handover (T6). The questions as they were asked: (a) where the
  generic theme code lives: the component
  stylesheets and their loader, the carousels' screen-reader work, the click-to-load videos, the
  video and menu scripts, the current-page mark, the privacy link, the redirects function and
  the emoji removal (`docs/planning/template-notes.md`, "Generic already"). Options: a shared
  "site components" plugin, with the child theme keeping only the site layer (Claude's
  suggestion; its cost, a written contract of the token names the theme must define), or a full
  child theme in the starter that each site copies (simpler; copies drift, against H28). Either
  changes the wording of handbook chapter 7, which forbids a shared parent theme and gives the
  starter an empty child theme. (b) How a site pulls in the pinned tools: a released zip checked
  against its checksum, or a git submodule (H28 says "released and pinned per site the same way"
  as the plugins, not how the files arrive).
- [~] **1.2 A per-site settings file** (T7, designed 2026-11-21), read by the tools instead of
  naming this site (25 files outside the theme named `hbmusic` on 2026-11-20; `bin/dev-site` the
  most). In small pull requests, each with the checks and the review gate, this site's
  `bin/check` and `bin/test` passing unchanged after each:
  - [x] 1.2a `site.json`, its loader for the scripts, its check in `bin/check`, and
    `site-settings.md` with the two-way check of its headings (2026-11-21): the rules in
    `tools/site-settings.jq`, the shared functions in `tools/site-settings.sh`, three new checks
    in `bin/check` (the file, its explanation, and broken examples in
    `tests/tools/site-settings/` that must stay refused), `jq` checked at `bin/check`'s start.
    Five planted faults caught (a typo'd field, a wrong type, a missing and a stale heading, and
    the typo rule itself removed, which only the broken examples noticed); `jq` missing from the
    computer was not planted. Nothing reads `site.json` yet besides its checks.
  - [x] 1.2b `bin/dev-site` reading it (2026-11-21): the theme, the title, the plugins by their
    source and the test pages, all checked before anything is changed (the rules, each
    WordPress.org plugin's pinned version, each test page's content file, no DTS plugins yet,
    the booking form's plugin when its files exist); the booking form and Yoast's settings set up
    only when the site has them; the stand-in organization's logo a picture WordPress ships
    (the tests check only that one is there), so no new field; the Song List's sample songs
    moved to the site's own `tests/dev-setup.sh`, run last when it exists; ShellCheck now sees
    all of `tests/`. Proven unchanged: a snapshot of everything the build sets up, before and
    after, identical apart from the logo picture; it caught two bugs before any test ran (an
    empty template shifting later fields, bash merging tabs, so the fields use the ASCII unit
    separator; `isInMenu: false` read as true, jq's `//` replacing false). Full `bin/test`: all
    passed (175 browser tests). Five planted faults stopped the build at its start, naming the
    cause.
  - [x] 1.2c The site's plugins through Composer (T8), 2026-11-21. Decided first (the user): the
    parent theme stays outside Composer with its hand-pinned fingerprint, since WordPress.org
    publishes no checksums for themes; the site's own plugins stay listed in `site.json`
    (`localPlugins`, a plain list) until they get repositories of their own (2.2); the downloaded
    plugins in their own folder, `site-packages/` (`composer.json` at exact versions and its lock
    file), apart from the top-level `composer.json` of the checking tools, so `bin/check` and
    `bin/tools-update` never touch plugins (option B). Built: `bin/dev-site` installs them with
    Composer from the lock file in the pinned container, copies them in, activates them and runs
    WordPress.org's checksum check; the cleanup keeps only the site's own plugins, so a rebuild
    gets fresh copies; `tools/site-packages.sh` reads the lock file. The plugin pins and their
    lookup left `tools/versions.sh`; `bin/versions-check` checks the theme only, its plugin
    pull-request code removed, and its workflow can read the repository and open issues, no
    longer push or open pull requests; Dependabot gained the `site-packages` folder, one pull
    request per plugin with the 7-day wait. `bin/check` validates the lock file against
    `composer.json` (an out-of-date lock fails; `--no-check-all` leaves out only Composer's advice
    against exact versions) and audits it. `site.json`'s `source` field and the rules' "allowed
    values" went with it. Permanent tests for `bin/dev-site`'s refusals (decided at 1.2b's
    review): a test page without its content file, a plugin not from WordPress.org, the booking
    form without its plugin, as functions taking files, tried by `bin/check` on examples in
    `tests/tools/dev-site/`. Proven: the rebuild identical to 1.2b's snapshot; full `bin/test`
    passed (175 browser tests); four planted faults caught (three stopping `bin/dev-site` at its
    start, one, the booking refusal broken, caught only by the new examples).
  - [ ] 1.2d `bin/check` reading it (the theme folder, each plugin's coding standards, the names
    the plugins must not use), and the volume and cache names built from the slug.
    First in this step (the user, 2026-11-21, from 1.2c's review): `bin/check`'s `main` is 31
    lines, over the coding standards' 25 (1.2a took it to 28, missed at that review, and 1.2c to
    31); split it into short groups (dependency, code and project checks), the same checks in the
    same order, proven by `bin/check` running all of them.
  - [ ] 1.2e The compose file's project name and plugin mounts from it. Not verified: whether
    Docker Compose fills in a variable in `name:`; checked before this part is built, and if not,
    `bin/dev-site` passes the name on the command line.
  - [ ] 1.2f The browser tests reading the test pages from it (`theme.spec.ts`'s own list goes),
    and the new check that the tools name nothing of this site.
  Staying with the site, not in `site.json`: the test pages' content (`tests/dev-content/`),
  the coding-standards file (`phpcs.xml.dist`), and the site's own build steps
  (`tests/dev-setup.sh`).
- [ ] **1.3 The tests split** three ways: generic (headers, no CSP violation, no accessibility
  error, the debug log empty) with the tools; component tests with the components; this site's
  own (Song List, the redirects) staying here. A new site starts with the generic and component
  tests and only the site tests its own features need, not copies of this site's (the user,
  2026-11-21: fewer tests where reasonable).
- [ ] **1.4 `bin/deploy`**, generic from the start: handbook chapter 2's eight steps. The rebuild
  plan's item 5; replaces `bin/deploy-staging`, whose GitHub-based design is stale (D14).
- [ ] **1.5 The records and care pieces** the handbook expects of every site: a `records/`
  skeleton, the status sheet (chapter 12), the activity log (Simple History, H94), the routines
  file. Overlaps the rebuild plan's item 3; done there for this site, generalized here.
- [ ] **1.6 Neutral defaults for the site layer:** a placeholder palette, logo, and header,
  footer and call-to-action wording, so a new site starts from something that works rather than
  from this site's look.

### Stage 2: the shared repositories (rough)

- [ ] **2.1 `dts-site-tools`**: created in the organization, released by Git tags and pinned
  through Composer (T8), with the reusable workflows and `bin/detach` with its release check
  (T6; kept by the user, 2026-11-21, so detaching is real, not only a note); this site switched
  to it. To verify then: whether the organization's pinning rule applies to reusable
  workflows (handbook `toolkit/github.md`), and whether a repository outside the organization
  (such as this one, on the user's personal account) may call them.
- [ ] **2.2 The plugin repositories** (Site Hardening, Editing Help; Song List is a musician's
  plugin, for any site that wants it): each released by a Git tag, this site requiring them
  through Composer.
- [ ] **2.3 The generic theme code** in the home chosen at 1.1; this site switched over.
- [ ] **2.4 `dts-site-starter`** and its new-site guide, from `template-notes.md` and handbook
  chapter 7's six steps; the guide points to `site-settings.md` rather than repeating it. With
  it (from the plan's review, 2026-11-21):
  - a developer guide: how to run the site's tools, what each does, how a change goes from the
    dev site to live, for a developer other than the user;
  - a routine for a new site's first real content: where its pages and photos are built and how
    they reach live (this site used staging's export, D30; a new site on DTS hosting has the
    host preview, H102).
- [ ] **2.5 The second site** started from the starter; the template adjusted along the way
  (H29: what is truly shared is only known with a second site in view).
