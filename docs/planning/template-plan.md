# Template plan

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The brochure-site template: the shared pieces every DTS brochure site is built on, and the
starter a new site is created from (handbook chapter 7, H28-H30), extracted from this project
and proven on it before the user's second site starts from it. Worked in rolling-wave mode
(`~/.claude/ROLLING_WAVE_MODE.md`): near steps in detail, later ones rough, new findings added as
steps. This project's own remaining work stays in `docs/planning/rebuild-plan.md`.

## Current position

- **Where the work stands:** planned 2026-11-20 (T1-T4). The GitHub organization
  direct-technical-solutions exists and the handbook moved into it (2026-11-20; its settings in
  the handbook's `toolkit/github.md`). Nothing else is built.
- **Next:** step 1.2, the per-site settings file, designed 2026-11-21 (T7); its first part,
  1.2a, is next. Step 1.1 decided 2026-11-21: the shared `dts-site-components` plugin (T5, its
  first check passed on the dev site), and two modes for a site, central while DTS manages it
  and detached at a handover (T6).
- **Then, in order:** 1.2 to 1.6 (stage 1, in this repository), then 2.1 to 2.5 (stage 2, the
  shared repositories).
- **Kept waiting, not forgotten (the user, 2026-11-20):** the rebuild plan's **9u**, the booking
  form's message when the "not a robot" check has not finished. The template came first by the
  user's choice; 9u is done at the first break in this plan's work that suits the user.
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
| T2 | Each DTS plugin has its own repository, as H28 says (the user, 2026-11-20), with its checks and release workflow called from `dts-site-tools` as reusable workflows, so a new plugin's repository is a few lines. (2026-11-21: reusable workflows are used while DTS manages a repository; a handed-over one gets full copies, T6.) | One repository for all plugins was weighed: less setup, but a custom release workflow, a required summary check, a guard against plugins depending on each other, and no plugin could be private, sold or handed over without being split out. With reusable workflows, separate repositories lose most of their cost. Rollback is the same either way: a site lowers its pin to the old release, which is kept. |
| T3 | The template work's time is logged in this project (the user, 2026-11-20). | Stage 1 is done in this repository; the user does not need it apart. |
| T4 | The shared repositories' histories are the template's history. A site is tied to the template by its pins (tools and plugins), the starter version it was created from (in its records), and issues and pull requests in the shared repositories that name the site that prompted them. Each shared repository keeps a changelog. A template change that is really a rule goes to the handbook, with the user's approval. | So a site can tell which template it runs, and the template can tell why it changed. |
| T5 | The generic theme code lives in a shared plugin, `dts-site-components` (the user, 2026-11-21): the component stylesheets and their per-block loader, the carousels' screen-reader work, the empty-heading drop, the click-to-load videos, the video and menu scripts, the lazy-loading and embed-title fix, the current-page mark, the privacy link, the redirect function, the emoji removal and the booking form's page-only loading. Each site's child theme keeps the site layer (`theme.json`, `parts/`, the logo) and its own lists, handed to the plugin through filters (old addresses, areas served, the organization's type, the policy's outside sources). A piece goes into the plugin if almost every site would want it and it is about how pages look or behave; anything else gets a plugin of its own (D19). The plugin documents the token names its CSS needs, and `bin/check` verifies each site's `theme.json` defines them; the deploy's page check confirms the plugin is active, since a theme cannot require a plugin. Handbook chapter 7's empty starter child theme and "no shared parent theme" stay; its wording gains the plugin, with the user's approval. | A site's child theme cannot reach another site's, WordPress allows one parent and no grandchild themes, so shared code needs a home beside each site's theme: a plugin, released and pinned like the others (H28, T2). A full child theme copied into each site would drift; a shared parent theme would mean maintaining a whole standalone theme; copies locked by a check would add a copy step and files no one may edit. Checked first on the dev site (2026-11-21): a stylesheet a plugin hands to `wp_enqueue_block_style()` loads on the public page, in the page editor's canvas and in the Site Editor's canvas, as the theme's `buttons.css` does; with the probe plugin deactivated, its marker was missing in all three (the fault caught). Whether a plugin can supply the call-to-action page templates is checked when the plugin is built; until then they stay in the starter's child theme. |
| T6 | A site has two modes (the user, 2026-11-21). **Managed by DTS (central):** the tools, the plugins and the GitHub workflows live centrally in DTS's repositories; the site's repository holds only pointers that rarely change: a pin naming the tools' release and its SHA-256, a small fetch script that downloads that release into a folder git ignores and refuses it if the checksum differs, and a workflow of a few lines calling DTS's reusable workflows pinned to the release's commit. Raising the pin updates everything; the weekly versions check proposes it. **Handed over (detached):** one command, `bin/detach`, copies the pinned tools, the plugin zips and full workflows into the site's repository, removes every reference to DTS's repositories, and runs the site's checks to prove it stands alone; then the repository is transferred (handbook chapter 9, wording with the user's approval). The tools' own release checks run `bin/detach` on a throwaway copy of a site every release, so it still works years later. The tools carry an open license, so the customer may keep and change the copy. | The user wants the simplest upkeep for managed sites (one central copy of everything) and no dependency on DTS after a handover, the GitHub workflows especially. The live website never depends on the tools (they check, test and deploy; the site runs the theme and plugins), so central tools risk only a managed site's checks, which DTS looks after. Weighed: a git submodule (easy to get wrong, pins a commit rather than a release); a copy committed into every site at all times (large diffs on each update, history piling up, files open to hand edits); thin workflows copied into every site with no reusable workflows (independent, but one more copy per site to keep in step). With the tools never reaching the live site, tools updates could merge by themselves once their checks pass (GitHub's auto-merge); whether they do is still open for the user; plugin updates, which reach the site, keep the user's yes. After a handover the customer's GitHub account's settings apply, not the organization's; what a repository transfer carries over (branch protection, required checks, settings) is not verified, and the handover checklist confirms it on the transferred repository. |
| T7 | The site's facts in one committed file, `site.json`, at the repository's top level (the user, 2026-11-21): its slug, its theme folder, its plugins (each with its source: `local` for a folder in the repository, mounted read-only; `wordpress.org`, checked against WordPress.org's checksums; later `dts`, a pinned DTS release with its checksum), the dev site's title, the test pages (title, address, page template, and which is the front page, the privacy page and outside the menu), and the names the plugins must not use. Versions stay in `tools/versions.sh` until stage 2. `.env` keeps the secrets and the computer's ports; `site.json` holds no secrets. Field names describe themselves (the coding standards' rule 3). A check in `bin/check`, with `jq`, refuses a missing required field, an unknown field (a typo) and a wrong type, naming the field. A short page, `site-settings.md`, kept with the tools, explains each field under a heading of its exact name (what it is for, an example, what changes when it changes); the check compares its headings with the valid fields both ways, so a field without an explanation and an explanation of a field that no longer exists both fail. A tools release that needs a new field gives it a default where one makes sense; otherwise the tools refuse and name the field, and the release's changelog lists it. Volume and cache names are built from the slug, so this site's stay `hbmusic` and its dev site and caches are kept. A new check fails when a site's names appear in the tools, as one already does for the plugins. | So the same scripts serve any site, each site bringing its own facts, with this site's checks and tests passing unchanged as the proof. JSON over YAML: the scripts (through `jq`, already used by the versions check), the browser tests and PHP all read it with nothing new to install, and a mistake in it is an error rather than a different value; YAML would allow comments but needs `yq` and an npm package. A JSON Schema with a validator was weighed and judged more than a small file edited once per site needs; it is looked at again if the file grows large or other people edit it. The explanation page serves the user returning after months and a customer's developer after a handover; kept with the tools, it changes with them and travels with `bin/detach`. |

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
  - [ ] 1.2a `site.json`, its loader for the scripts, its check in `bin/check`, and
    `site-settings.md` with the two-way check of its headings.
  - [ ] 1.2b `bin/dev-site` reading it (the theme, the plugins, the test pages, the title, the
    stand-in organization's logo).
  - [ ] 1.2c `bin/check` reading it (the theme folder, each plugin's coding standards, the names
    the plugins must not use), and the volume and cache names built from the slug.
  - [ ] 1.2d The compose file's project name and plugin mounts from it. Not verified: whether
    Docker Compose fills in a variable in `name:`; checked before this part is built, and if not,
    `bin/dev-site` passes the name on the command line.
  - [ ] 1.2e The browser tests reading the test pages from it (`theme.spec.ts`'s own list goes),
    and the new check that the tools name nothing of this site.
  Staying with the site, not in `site.json`: the test pages' content (`tests/dev-content/`),
  the coding-standards file (`phpcs.xml.dist`), and the test songs, which go with Song List's
  test setup.
- [ ] **1.3 The tests split** three ways: generic (headers, no CSP violation, no accessibility
  error, the debug log empty) with the tools; component tests with the components; this site's
  own (Song List, the redirects) staying here.
- [ ] **1.4 `bin/deploy`**, generic from the start: handbook chapter 2's eight steps. The rebuild
  plan's item 5; replaces `bin/deploy-staging`, whose GitHub-based design is stale (D14).
- [ ] **1.5 The records and care pieces** the handbook expects of every site: a `records/`
  skeleton, the status sheet (chapter 12), the activity log (Simple History, H94), the routines
  file. Overlaps the rebuild plan's item 3; done there for this site, generalized here.
- [ ] **1.6 Neutral defaults for the site layer:** a placeholder palette, logo, and header,
  footer and call-to-action wording, so a new site starts from something that works rather than
  from this site's look.

### Stage 2: the shared repositories (rough)

- [ ] **2.1 `dts-site-tools`**: created in the organization, with releases, the reusable
  workflows, the fetch script and `bin/detach` with its release check (T6); this site switched
  to its pin. To verify then: whether the organization's pinning rule applies to reusable
  workflows (handbook `toolkit/github.md`), and whether a repository outside the organization
  (such as this one, on the user's personal account) may call them.
- [ ] **2.2 The plugin repositories** (Site Hardening, Editing Help; Song List is a musician's
  plugin, for any site that wants it): each released, this site pinning them.
- [ ] **2.3 The generic theme code** in the home chosen at 1.1; this site switched over.
- [ ] **2.4 `dts-site-starter`** and its new-site guide, from `template-notes.md` and handbook
  chapter 7's six steps; the guide points to `site-settings.md` rather than repeating it.
- [ ] **2.5 The second site** started from the starter; the template adjusted along the way
  (H29: what is truly shared is only known with a second site in view).
