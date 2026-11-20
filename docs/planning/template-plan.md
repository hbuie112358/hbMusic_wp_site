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
- **Next:** step 1.1, the two technical decisions, talked through one at a time: where the
  generic theme code lives, then how a site pulls in the pinned tools.
- **Then, in order:** 1.2 to 1.6 (stage 1, in this repository), then 2.1 to 2.5 (stage 2, the
  shared repositories).
- **Kept waiting, not forgotten (the user, 2026-11-20):** the rebuild plan's **9u**, the booking
  form's message when the "not a robot" check has not finished. The template came first by the
  user's choice; 9u is done at the first break in this plan's work that suits the user.
- **Open decisions waiting on the user:** the two of step 1.1; the second site's facts (a new
  build or a takeover; the user's own or a customer's, which decides a public or private
  repository).
- **Shared with the rebuild plan:** `bin/deploy` is this plan's step 1.4 and the rebuild plan's
  item 5, done once.
- **Stale:** nothing yet.

## Decisions

| # | Decision | Why |
|---|---|---|
| T1 | Two stages (the user, 2026-11-20). Stage 1, in this repository: the site tools made generic (a per-site settings file instead of this site's names in the scripts), the tests split, `bin/deploy` built generic, the records and care pieces, neutral defaults; proven by this site's `bin/check` and `bin/test` passing. Stage 2: the pieces extracted into fresh shared repositories in the organization, with no history from this project (D18), and this site switched over to them. | Making the tools generic changes this site's own scripts and is proven by this site's checks; doing it and moving it at the same time would make a failure hard to place. Working on this repository from a separate project's session would need the user's approval at every edit (the global rule on paths outside the current project). |
| T2 | Each DTS plugin has its own repository, as H28 says (the user, 2026-11-20), with its checks and release workflow called from `dts-site-tools` as reusable workflows, so a new plugin's repository is a few lines. | One repository for all plugins was weighed: less setup, but a custom release workflow, a required summary check, a guard against plugins depending on each other, and no plugin could be private, sold or handed over without being split out. With reusable workflows, separate repositories lose most of their cost. Rollback is the same either way: a site lowers its pin to the old release, which is kept. |
| T3 | The template work's time is logged in this project (the user, 2026-11-20). | Stage 1 is done in this repository; the user does not need it apart. |
| T4 | The shared repositories' histories are the template's history. A site is tied to the template by its pins (tools and plugins), the starter version it was created from (in its records), and issues and pull requests in the shared repositories that name the site that prompted them. Each shared repository keeps a changelog. A template change that is really a rule goes to the handbook, with the user's approval. | So a site can tell which template it runs, and the template can tell why it changed. |

## Steps

### Stage 1: in this repository

- [ ] **1.1 Two technical decisions.** (a) Where the generic theme code lives: the component
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
- [ ] **1.2 A per-site settings file** read by the tools, holding this site's lists: the theme
  folder, the plugins and their pins, the dev site's title and logo, the test pages, the
  volume names, the ports. `bin/check`, `bin/dev-site`, `tools/versions.sh` and
  `tools/settings.sh` read it instead of naming this site (25 files outside the theme named
  `hbmusic` on 2026-11-20; `bin/dev-site` the most).
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

- [ ] **2.1 `dts-site-tools`**: created in the organization, with releases and the reusable
  workflows; this site switched to its pin. To verify then: whether the organization's
  pinning rule applies to reusable workflows (handbook `toolkit/github.md`).
- [ ] **2.2 The plugin repositories** (Site Hardening, Editing Help; Song List is a musician's
  plugin, for any site that wants it): each released, this site pinning them.
- [ ] **2.3 The generic theme code** in the home chosen at 1.1; this site switched over.
- [ ] **2.4 `dts-site-starter`** and its new-site guide, from `template-notes.md` and handbook
  chapter 7's six steps.
- [ ] **2.5 The second site** started from the starter; the template adjusted along the way
  (H29: what is truly shared is only known with a second site in view).
