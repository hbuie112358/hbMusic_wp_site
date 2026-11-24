# Template plan

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The brochure-site template: the shared pieces every DTS brochure site is built on, and the
starter a new site is created from (handbook chapter 7, H28-H30), extracted from this project
and proven on it before the user's second site starts from it. Worked in rolling-wave mode
(`~/.claude/ROLLING_WAVE_MODE.md`): near steps in detail, later ones rough, new findings added as
steps. This project's own remaining work stays in `docs/planning/rebuild-plan.md`. The
destination (T16): a starter the user clones to create a new site; each shared piece written and
fixed in one home, a site's repository only listing which ones it uses and at which version.

## Current position

- **Where the work stands:** planned 2026-11-20 (T1-T4); step 1.1 decided 2026-11-21 (T5, T6);
  step 1.2, the per-site settings file, done (#77 to #85); 1.3a to 1.3c done (#86 to #89): the
  tests in their groups' folders, the components' example page, each component tested on every
  page using it (246 browser tests), the versions check's alerts tested, all 2026-11-21; 1.3d, the
  starting set of tests for a new site, written down in `template-notes.md` (2026-11-21), so step
  1.3 is done. The plan reviewed the
  same day as a whole for overkill and gaps (the user's request): pinning moves to Composer (T8);
  new sites start with fewer site tests (1.3); `bin/detach` stays, built in 2.1; a routine for a
  new site's first content and a developer guide added (2.4). The GitHub organization
  direct-technical-solutions exists and the handbook moved into it (its settings in the
  handbook's `toolkit/github.md`). Step 1.4, `bin/deploy`, designed 2026-11-21 (T11) in five
  parts: 1.4a done (the PHP
  error log found, `log_errors` on), 1.4b done (`bin/site-check`, the page check, #90), 1.4c done
  (`site.json`'s `deploy` section), 1.4d-1 done (`bin/deploy`'s checks before a copy), 1.4d-2
  done (the copy, #91), 1.4d-3 done (after the copy, and the test against a throwaway server,
  #92), 1.4d-4 done (the weekly warning for the test server's packages, raised with no wait);
  1.4e done (2026-11-22: the server set up, staging and live deployed with `bin/deploy`, GitHub's
  staging deploy, key and environment removed, #95; the handbook's H103), so step 1.4 is done;
  1.5 under way (split in four, 2026-11-22): 1.5a done (`records/README.md`); 1.5b done (#96;
  Simple History on staging and live, activated on both, live at e243788 on 2026-11-23 with
  Contact Form 7 6.2.6); 1.5c done (the routines split into `docs/ROUTINES.md` and
  `docs/SITE_SPECIFIC_ROUTINES.md`, 2026-11-23); 1.5d, the status sheet, split in four, 1.5d-1
  done (sections 1-4, `records/status.md`, `records/exceptions.md`); 1.5d-2 done (sections 5-6,
  `records/plugin-set.md`, its two fixes deployed); 1.5d-3 done (sections 7-9,
  `bin/accessibility-scan` in the monthly check); 1.5d-4 done (sections 10-14, the blank sheet,
  `bin/check` holding the sheet complete), so step 1.5 is done (#102, 2026-11-23). 1.6 done
  (T12-T15, 2026-11-23 and 11-24): 1.6a (#103, the shared tests no longer assume this site's
  look or names; the components' `hbmusic` prefix stays for 2.3); 1.6b (#105, #106: this site's
  code ready for another look, all 24 screenshots identical; the `starter/` folder, held by
  seven `bin/check` rules); 1.6c (#107, #108: `SITE_DIR`, the starter's dev site passing every
  shared test on its light look); 1.6c-3 settled without code (T15, the user, 2026-11-24): no
  weekly job, the starter's tests run before committing any change to what it shares (the
  project's `CLAUDE.md`, Testing), no starter screenshot. Stage 2 trimmed (T16, 2026-11-24):
  the destination written down; `bin/detach` and a prebuilt test server left out.
  1.7 done (2026-11-24), so stage 1 is done: the theme's scripts to the strict standards, in two
  parts (1.7-1 ESLint in `bin/check` with `tools/js-check/`'s own packages; 1.7-2 the scripts as
  script modules, the video script's state in a class, one home for what the two video scripts
  share and for the player's origin, a facade without a title or a secure origin staying a link).
- **Next: 2.1,** `dts-site-tools` (T16). Its parts proposed 2026-11-24, not yet agreed with the
  user: 2.1a a review table of every tool in `bin/` and `tools/`, the shared tests and the
  workflows (moves, stays with the site, or perhaps no longer needed, each for the user to decide),
  with the two checks on reusable workflows; 2.1b the repository (layout, license, changelog, its
  own checks, the first tag, how a site fetches it through Composer); 2.1c the reusable workflows;
  2.1d this site switched over (local copies removed, the plugin-dependent tests following
  `composer.json`, all checks and the starter's tests passing, a deploy showing no change).
- **Worth raising soon:** (1) every
  deploy's change counts equal the files' count for the site's own code (`git archive` dates
  each file with its commit), so the planned content-only count matters more than first
  thought; (2) Dependabot's 7-day wait did not hold for Contact Form 7 6.2.6 (published on
  WordPress.org 2026-11-23 02:28 GMT, #98 opened 10:17 GMT the same day and merged itself):
  cause not known yet; hypotheses, each to confirm or rule out: a security update (those skip
  the wait; the repository's Dependabot alerts would show it), or WPackagist giving Dependabot
  no usable release time (#98's details against WPackagist's listing would show it).
- **Then, in order:** 2.2 to 2.5 (stage 2, the shared repositories).
- **Kept waiting, not forgotten (the user, 2026-11-20):** the rebuild plan's **9u**, the booking
  form's message when the "not a robot" check has not finished. The template came first by the
  user's choice; 9u is done at the first break in this plan's work that suits the user.
- **Open decisions waiting on the user:** the handbook's wording for T5 (chapter 7) and T6
  (chapters 7 and 9), proposed when each is built and approved by the user before anything is
  written there. (The new site's repository is public for now; private is reconsidered later,
  after checking what GitHub's free plan allows private repositories, the user, 2026-11-24. Tools updates
  do not merge themselves: decided 2026-11-21, T9.)
- **Waiting on the user:** Dependabot's #56 (`@stylistic/stylelint-plugin` 6.0.0 to 6.0.1, the CSS
  linter's single-maintainer plugin, which D29 has looked at with each update): a tools update,
  reviewed by hand, later, when the user chooses (the user, 2026-11-21).
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
| T6 | (2026-11-24: `bin/detach` built at the first real handover, T16.) (2026-11-21: the pin, fetch script and release zips below are replaced by Composer, T8; the two modes, the reusable workflows and `bin/detach` stay.) A site has two modes (the user, 2026-11-21). **Managed by DTS (central):** the tools, the plugins and the GitHub workflows live centrally in DTS's repositories; the site's repository holds only pointers that rarely change: a pin naming the tools' release and its SHA-256, a small fetch script that downloads that release into a folder git ignores and refuses it if the checksum differs, and a workflow of a few lines calling DTS's reusable workflows pinned to the release's commit. Raising the pin updates everything; the weekly versions check proposes it. **Handed over (detached):** one command, `bin/detach`, copies the pinned tools, the plugin zips and full workflows into the site's repository, removes every reference to DTS's repositories, and runs the site's checks to prove it stands alone; then the repository is transferred (handbook chapter 9, wording with the user's approval). The tools' own release checks run `bin/detach` on a throwaway copy of a site every release, so it still works years later. The tools carry an open license, so the customer may keep and change the copy. | The user wants the simplest upkeep for managed sites (one central copy of everything) and no dependency on DTS after a handover, the GitHub workflows especially. The live website never depends on the tools (they check, test and deploy; the site runs the theme and plugins), so central tools risk only a managed site's checks, which DTS looks after. Weighed: a git submodule (easy to get wrong, pins a commit rather than a release); a copy committed into every site at all times (large diffs on each update, history piling up, files open to hand edits); thin workflows copied into every site with no reusable workflows (independent, but one more copy per site to keep in step). With the tools never reaching the live site, tools updates could merge by themselves once their checks pass (GitHub's auto-merge); whether they do is still open for the user; plugin updates, which reach the site, keep the user's yes. After a handover the customer's GitHub account's settings apply, not the organization's; what a repository transfer carries over (branch protection, required checks, settings) is not verified, and the handover checklist confirms it on the transferred repository. |
| T7 | (2026-11-21: the plugin list and the plugins' pins move to Composer, T8; `site.json` keeps the rest.) The site's facts in one committed file, `site.json`, at the repository's top level (the user, 2026-11-21): its slug, its theme folder, its plugins (each with its source: `local` for a folder in the repository, mounted read-only; `wordpress.org`, checked against WordPress.org's checksums; later `dts`, a pinned DTS release with its checksum), the dev site's title, the test pages (title, address, page template, and which is the front page, the privacy page and outside the menu), and the names the plugins must not use. Versions stay in `tools/versions.sh` until stage 2. `.env` keeps the secrets and the computer's ports; `site.json` holds no secrets. Field names describe themselves (the coding standards' rule 3). A check in `bin/check`, with `jq`, refuses a missing required field, an unknown field (a typo) and a wrong type, naming the field. A short page, `site-settings.md`, kept with the tools, explains each field under a heading of its exact name (what it is for, an example, what changes when it changes); the check compares its headings with the valid fields both ways, so a field without an explanation and an explanation of a field that no longer exists both fail. A tools release that needs a new field gives it a default where one makes sense; otherwise the tools refuse and name the field, and the release's changelog lists it. Volume and cache names are built from the slug, so this site's stay `hbmusic` and its dev site and caches are kept. A new check fails when a site's names appear in the tools, as one already does for the plugins. | So the same scripts serve any site, each site bringing its own facts, with this site's checks and tests passing unchanged as the proof. JSON over YAML: the scripts (through `jq`, already used by the versions check), the browser tests and PHP all read it with nothing new to install, and a mistake in it is an error rather than a different value; YAML would allow comments but needs `yq` and an npm package. A JSON Schema with a validator was weighed and judged more than a small file edited once per site needs; it is looked at again if the file grows large or other people edit it. The explanation page serves the user returning after months and a customer's developer after a handover; kept with the tools, it changes with them and travels with `bin/detach`. |
| T8 | Plugins, and later DTS's own plugins and the tools, are pinned with Composer (the user, 2026-11-21), not with pins, fetch scripts and release zips of DTS's own: WordPress.org plugins through WPackagist (`wpackagist-plugin/<slug>`, placed in `wp-content/plugins/` by `composer/installers`), DTS's plugins and tools from their GitHub repositories by version tag, `composer.lock` holding the exact versions and commits. `composer.json` becomes the site's one plugin list (it replaces `site.json`'s `plugins` and the plugin pins in `tools/versions.sh`). Updates come from Dependabot, which this project already runs for Composer with a 7-day wait, so the plugin part of `bin/versions-check` is retired. WordPress.org's own checksum check (`wp plugin verify-checksums`) still runs after each install, and the review gate checks that every WordPress.org plugin's download address in `composer.lock` is on `downloads.wordpress.org`. A DTS plugin release is a Git tag, so no release pipeline of zips is built; `bin/detach` (T6) can point a handed-over repository at copies of the pinned packages (Composer's `artifact` repositories). To decide in 1.2c: the parent theme, whose zip has a fingerprint pinned by hand because WordPress.org publishes no checksums for themes, and how the site's `local` plugins are listed. | From the plan's review (the user's request, 2026-11-21): the project's rule against reinventing the wheel, since the plan was building by hand what Composer, the WordPress world's standard package manager, already does, and what this project already uses for its checking tools. Checked first on a throwaway trial (2026-11-21, nothing in the repository touched): Contact Form 7 6.2.5 and Yoast 28.8 installed at their pinned versions; every file matched WordPress.org's checksum list (218 and 1,949 files, none missing, different or extra); the lock file's downloads come straight from `downloads.wordpress.org`, WPackagist giving only the list of versions; an install from the lock file worked with WPackagist made unreachable, so WPackagist is needed only when a version changes; the lock file holds no fingerprint for these zips, normal for Composer, which is why WordPress.org's checksum check stays. A throwaway public repository in the organization showed Dependabot proposing Contact Form 7 6.2.4 to 6.2.5 through WPackagist with no extra setup, both files changed correctly. WPackagist is run by WP Engine, a third party; its outage would delay updates only. Kept from T6: the two modes, the reusable workflows, `bin/detach`. |
| T9 | Dependabot's plugin updates merge themselves once their checks pass (the user, 2026-11-21); staging and live get a new version only when the user deploys it. One weekly pull request for all the plugins (a Dependabot group), which `.github/workflows/plugin-updates.yml` sets to merge itself by rebase, only for Dependabot's pull requests into `main` that change nothing but `site-packages/`; the required checks still decide. `bin/check` and `bin/dev-site` require every WordPress.org plugin's download address to be on `downloads.wordpress.org`, since a person no longer reads the lock file. Alerts: the weekly versions check opens an issue (GitHub emails the owner) for an update still open after 3 days, saying why, and for a release 14 days old with no update proposed; the monthly check looks at open pull requests and issues. A pull request left behind `main` waits for a comment `@dependabot rebase` (not "Update branch", which adds the user's commit and stops Dependabot looking after it; tried on #80, which then merged itself, 2026-11-21). Only WordPress.org plugins may merge themselves: the workflow compares the lock file's installed packages (version, download, source) before and after with `main`'s own code, and anything else changed (`composer/installers`, which runs code as Composer installs) waits for review; the weekly group holds only `wpackagist-plugin/*`. **A recorded exception to `~/.claude/AI_SECURITY.md`, section 4,** which has every lock-file change read line by line in a review: for these updates no one reads it, and machine checks take its place (only WordPress.org plugins changed, their download addresses on `downloads.wordpress.org`, every file checked against WordPress.org's checksums, the full tests); the global rule itself is unchanged. Tools updates (the checking tools, the browser tests', the CSS linter's, GitHub's actions) do not merge themselves (closing T6's open question, the user, 2026-11-21): they run code on the user's computer and GitHub's machines, nothing checks them automatically the way WordPress.org's checksums check plugins, and their lock files are read line by line in review. `bin/deploy` (1.4) delivers the downloaded plugins from `site-packages/` to staging and live, so the user's hands-on part is one deploy. | The user wanted the least hands-on work while keeping control of what visitors get. A merge changes nothing visitors see, and every update is tested on a fresh dev site with WordPress.org's checksums first. Checked in GitHub's documentation (2026-11-21): a workflow on a Dependabot pull request gets a read-only token unless its `permissions` raise it, and GitHub's own example switches on auto-merge with `gh pr merge --auto`; Dependabot brings a pull request up to date only on a conflict, not when it is merely behind, a known gap. Its usual workarounds need a stored personal access token in CI (against the AI security rules) or dropping "up to date with main" (which keeps the merged code the tested code, D34), so neither is used: one weekly group means two updates never leave each other behind, and the rare case waits for a comment and raises an issue. A merge by GitHub's own token starts no run on `main`, harmless since staging's deploy does not carry the downloaded plugins and the weekly run checks `main`. |
| T10 | A component's tests find the component themselves, on the site's own test pages, by its class, and run on every page that uses it; the components also bring one neutral page holding every component, each in its own block, built by every dev site outside the menu, as a baseline (changed 2026-11-21 from a page per component, the user: twelve pages more would add back run time the tests had just lost; one page costs a few seconds and keeps what the baseline is for); the generic "every page" tests (accessibility, policy, the frame, PHP notices) keep running on all the site's pages (the user, 2026-11-21). | The user: a component tested only on its own page tests the component, not the component on the page, and what matters is how it behaves on the site's pages, with the site's look, layout and content around it. Proven by this site's history: the click-to-load videos passed on the dev site's stand-in pages and showed a black space above each video on live, caused by WordPress's own video block stylesheet, which the stand-ins did not load (9v, 2026-11-17). The baseline page still matters: the shared plugin's tests must run without any one site (in its own repository), a component no site page uses yet is still tested, and a failure there points at the component. Weighed and set aside: only the component's own page (misses the site's context); `site.json` mapping pages to components (every site fills it in, and a missing entry skips a test silently); keeping this site's page names in the component tests until 2.3 (postpones the hard part). The black-space kind of bug is caught only when the site's test pages use real blocks, not stand-ins, the rule since that bug. |
| T11 | `bin/deploy staging\|live` (the user, 2026-11-21) follows handbook chapter 2's eight steps from the user's computer, each place through its own key made there and restricted on the server to rsync's daemon mode with that place's folders (no shell, never the other place), named in the user's SSH settings; GitHub's deploy job and key are removed. Its parts: (1) "tested" means the commit's files are exactly those of a commit whose required checks passed: its pull request's last commit with an identical tree, or the commit itself (the weekly run, the button); (2) it shows the commits between the server's note and the new commit and waits for "yes"; (3) live accepts only staging's commit, where the site has staging; (4) it copies the downloaded plugins (built from `site-packages/composer.lock` and checked against WordPress.org's checksums first), then the site's own plugins, then the theme, comparing by content, refuses to lower a plugin's version found on the server, and names a plugin folder new on the server, to activate by hand; (5) the commit into a note folder; (6) the page cache from `site.json` (none here); (7) `bin/site-check`; (8) the PHP error log's new lines, through a read-only folder. Three points the user agreed: the handbook's wording gains the downloaded plugins (proposed at 1.4e, approved before it is written); `bin/deploy` needs `gh` on the host, beside Docker and `jq`; the search checks in the page check are a later part.| The handbook (H8, H9) was decided after this site's GitHub-based staging deploy was built; this site has run on a recorded exception (D33) until `bin/deploy` exists. A rebase merge gives the commit on `main` a new name, so no check ran on it: checked 2026-11-21, `main`'s 488f547 has `check` and `dev-site` skipped, #89's tested 24f7c18 has both passed, and both have the tree `c664229`; only a merged pull request's last commit can therefore be deployed, which a rollback to an earlier pull request still allows. Hostinger installs security updates by itself (8j), so a plugin on the server can be newer than its pin, and a deploy that mirrors the folder would quietly put the older version back. `gh` on the host, rather than in a container with a token passed in, keeps the secret handling out of the script; the user already runs it. |
| T12 | (Its weekly run replaced by T15, 2026-11-24.) The neutral defaults (1.6) are built in this repository, in a `starter/` folder that becomes `dts-site-starter`'s site layer at 2.4, with a light placeholder look (white, dark text, one blue accent); their proof runs weekly, never on pull requests (the user, 2026-11-23). | Stage 1 proves each piece here before it moves (T1). Reading the tests first showed that the shared tests assume this site's look and names (the call-to-action panel must be green, the booking page's address is this site's), so a new site would fail them; making them look-independent is most of the work, and a look the opposite of this dark site's catches any test still relying on it. The user did not want minutes added to every pull request; the neutral layer changes rarely, and the weekly run (Mondays, already automatic, GitHub emailing a failure) shows a break within a week. |
| T13 | (Its starter screenshot replaced by T15, 2026-11-24.) 1.6b's design (the user, 2026-11-23): split in two, this site's code first (1.6b-1) and the `starter/` folder second (1.6b-2); the site's facts moved into a site-layer file now, not at 2.3; the light palette as proposed (white `#ffffff`, text `#1b1f24`, paragraphs `#3a4048`, accent `#1d5fc2`, deep accent `#163f7a`, links `#1a55ad`, raised `#f2f4f7`, lines `#dde2e8`, muted `#5b6470`, error `#b42318`), kept as long as every pair in use passes WCAG AA; this site's form settings as the starter's stand-in until 2.4; the starter's screenshot moved to 1.6c. Token names spelled out where a site's designer reads them (`custom.callToAction.…` in `theme.json`, which allows no comments); the short `site-cta` class kept, its stylesheet saying what CTA stands for. | Reading the stylesheets for a light look found more than the planned button fix: the video play triangle and the carousel arrows take the text color (dark on their dark plates in a light look) and `form.css` fixes `color-scheme: dark`; and `functions.php`'s old-address list sends `/contact/` to this site's Book page, which would take a starter's Contact page away. The class is not renamed: it is in the tests, the component list, the example page and any copy of the part saved in the Site Editor on staging or live, which would silently lose its look. Contrast computed with WCAG's formula for each pair the components use; the tightest, muted text on the placeholder, is 4.60. |
| T14 | (Its weekly job and screenshot replaced by T15, 2026-11-24.) 1.6c's design (the user, 2026-11-23): in three parts (the tools take a site folder; the starter's dev site run and fixed; the weekly job and screenshot); the site chosen by a `SITE_DIR` setting, not a flag on each command, since the scenario checks and browser tests inherit it; the starter laid out as a site (`starter/tests/dev-content/`), as `dts-site-starter` will be at 2.4; its assembled theme in `starter/themes/`, ignored by git; the shared video code adding `https://www.youtube-nocookie.com` to the policy itself. | The tools assumed this repository's layout everywhere (`site.json` at the top, `tests/dev-content/`, `themes/`); one setting naming the site's folder changes that in one place. The assembled theme stands in for 2.4's starter theme until 2.3 moves the shared code into its plugin. The video's own address belongs with the code that creates the player: every site using the shared click-to-load videos needs it, and a frame from it cannot run script in the page; `https://www.youtube.com`, for players pasted into content, stays a site's fact. Weighed: every site allowing YouTube in its facts (each site repeating what the shared code needs), or the example page without a playable video (the shared tests no longer proving the video on a neutral page). |
| T15 | (Replaces T12's weekly run and T13's and T14's starter screenshot, the user, 2026-11-24.) No scheduled job proves the starter: whenever a change touches what the starter shares (the theme's generic files, the shared tests, the tools, the plugins the starter lists), the starter's tests run before that change is committed (`SITE_DIR=starter bin/dev-site`, then `bin/test`), and the review says so; a change to this site's own files only (its site layer, its `site/` tests, its content) does not need them. The starter carries no `screenshot.png`: each new site makes its own from its Home page once its pages exist. At 2.4 the starter's repository runs the same checks every site runs, with its own values; no separate starter check. | The user: changes are tested when they are made, including the template's later changes during the second site, and the work is to finish soon, so a weekly run would only repeat that testing. The pull-request checks test this site alone, so the starter is tested by a rule instead (both earlier breaks, in 1.6a and 1.6c-2, were found by running the starter on purpose). Dependabot's plugin updates, which merge by themselves, are tested on this site; one breaking only the starter's look is judged unlikely before 2.4. A picture of placeholder pages helps no one; the starter's dev site borrows this site's picture until 2.3 moves the shared code out, on the user's computer only. The starter is laid out as a site (T14) so it needs nothing special: its own repository is a site's repository. |
| T16 | The template's destination and a leaner stage 2 (the user, 2026-11-24, after a review of the remaining plan for bloat, overkill and roundabout steps). **Destination:** a starter the user clones to create a new site. Each site has its own repository, WordPress, child theme of Twenty Twenty-Five, content and settings. A site's repository holds no copy of shared code: it only lists which shared pieces it uses and at which version. The running website installs the plugins and the parent theme at those versions (copies nobody edits, replaced by the next release); the tools (the commands that check, test and deploy a site) run on the user's computer and GitHub's, downloaded at the listed version into a folder git ignores, and are never put on the website. Each shared piece is written and fixed in one home: WordPress's shared theme code in Twenty Twenty-Five (WordPress.org); DTS's shared theme code in the components plugin (2.3, T5); the tools in `dts-site-tools` (2.1); each DTS plugin in its own repository (T2). A site's repository holds only what is its own. **Changes to the plan:** `bin/detach` and its release check are built at the first real handover, not in 2.1 (T6's two modes stay the design); the deploy test's server is not prebuilt into a container registry (1.4d-4's weekly warning stays). **Kept:** the plugins separate, as built (T2); the components plugin (T5); the tools repository with the shared workflow each site calls; this site switched over to the shared pieces; the update rules as settled (T9: WordPress.org plugins merge themselves, everything else, DTS's own plugins and tools included, waits for the user). Song List moves to its own repository in 2.2 with the other two (the user, 2026-11-24): it is already a separate plugin in its own folder, naming nothing of this site, and once 2.2 has built the fetching of a DTS plugin at a pinned version for the other two, its move is small; every DTS plugin then lives the same way. | The user wants the result lean: nothing shared kept as copies, nothing built before it is needed, nothing done the long way round, and nothing finished undone without a reason. Weighed and withdrawn: one plugin for Site Hardening, Editing Help and the components (one release instead of three), since T2's reasons hold (any plugin may later go its own way, no combined release machinery, little cost per repository with shared workflows), the three do different jobs (security, admin help, the look), and the plugins already exist separately. Weighed and withdrawn: a full starter carrying every shared piece as a copy (fixes made once per site, against H28). `bin/detach` is needed only when a customer leaves, and none is near; the shared repositories are public and pinned, so a handed-over site keeps working until it is built. A prebuilt server would add a registry, a build workflow and image pinning to replace a warning that works. Twenty Twenty-Five cannot hold DTS's code (its next update would remove it), so the components plugin is the one home for it. |

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
- [x] **1.2 A per-site settings file** (T7, designed 2026-11-21), read by the tools instead of
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
  - [x] 1.2d `bin/check` reading it (2026-11-21). First, as the user asked at 1.2c's review:
    `bin/check`'s `main` (31 lines) split into three groups of neighboring checks, the same
    checks in the same order (dependencies; coding standards and the project's rules; analysis
    and file checks), `main` now 9 lines. Then: the theme folder and the theme's PHP prefix (the
    slug in capitals) from `site.json`; one coding-standards check per `localPlugins` entry; the
    words plugins must not use from `namesPluginsMustNotUse`, matched as plain text. The cache
    and dev-database volume names built from the slug by one shared function
    (`load_site_volume_names`), used by `bin/check`, `bin/dev-site`, `bin/test`,
    `bin/screenshots`, `bin/tools-update` and the scenario check of the `.env` safety stop; the
    same names as before, so nothing was lost. `slug` gained a rule (lower-case letters, digits
    and dashes), since Docker allows few characters, with its broken example. `jq` is now needed
    by all these scripts, stated in the project's `CLAUDE.md`. Proven: `bin/check` 28 checks
    passing; planted faults caught (a slug Docker would refuse stopping `bin/check`,
    `bin/dev-site` and `bin/test` at once; a planted word in capitals; a word with a pattern
    character matched only as text); the rebuild identical to 1.2c's snapshot; full `bin/test`
    passed (175 browser tests, the safety stop's scenario check reading the shared name). At
    review, two LOW findings fixed (the user): the theme's PHP prefix convention written into
    `tools/site-settings.md`, and a `theme` naming no folder now stopping `bin/check` and
    `bin/dev-site` at once (a shared function with its broken example), `theme` limited to a
    folder name like the slug, so a path such as `../plugins` is refused.
  - [x] 1.2e Plugin updates merge themselves (T9), 2026-11-21: Dependabot's plugin updates in one
    weekly pull request (a group), which `.github/workflows/plugin-updates.yml` sets to merge
    itself by rebase once the required checks pass, only for Dependabot's pull requests into
    `main` changing nothing but `site-packages/`, running nothing from the pull request; `bin/check`
    and `bin/dev-site` require every WordPress.org plugin's download address to be on
    `downloads.wordpress.org`, with a broken example; `bin/versions-check` opens an issue for an
    update still open after 3 days (its checks failed, it fell behind `main`, or another reason)
    and for a release 14 days old Dependabot never proposed, each issue once; the monthly check
    looks at open pull requests and issues. Proven: `bin/check` 29 checks passing; planted faults
    caught (an outside download address in the real lock file, stopping `bin/check` and
    `bin/dev-site`; the download check broken, caught by its example; both alerts run in report
    mode on real data, #80 reported as behind `main`). GitHub's "Allow auto-merge" set on with the
    user's yes. First real test, 2026-11-21: #80 (Yoast 28.8 to 28.9), behind `main`, rebased by a
    comment `@dependabot rebase`, then the workflow switched on auto-merge and GitHub merged it once
    its checks passed (by github-actions); the same run left the CSS linter's #56 waiting, its
    files outside `site-packages/`. Tightened the same day (the user): only WordPress.org plugins
    in the lock file may merge themselves, the weekly group holds only them, and the exception
    to the AI security rules is recorded in T9.
  - [x] 1.2f The compose file's project name and plugin mounts from it (2026-11-21). Checked
    first: Docker Compose 5.6 fills in a variable in `name:` (Docker's documentation is silent;
    tried on a throwaway file), a second compose file adds mounts to the first, and `.env`'s
    `COMPOSE_FILE` lets a plain `docker compose` find both from the repository's folder. Weighed:
    keeping the lines in `compose.dev.yaml` with a check against `site.json` (less machinery);
    the user chose one place for the facts, since a check that only compares two copies must be
    remembered and explained. Built: `compose.dev.yaml` the same for every site; the site's name
    and read-only mounts written from `site.json` into `compose.site.yaml` (ignored by git, never
    edited) by `bin/dev-site`, `bin/check` and `bin/screenshots` (`write_site_compose_file`);
    `.env.example` gains `COMPOSE_FILE`, added to an existing `.env` by `bin/dev-site`, so the
    hand-typed commands are shorter (`docker compose run --rm cli wp …`); `localPlugins` entries
    limited to folder names, and one without its folder stops `bin/check` and `bin/dev-site` at
    once (a broken example each). Proven: Docker reads the two files exactly as the old one
    (`docker compose config`, every service, setting and mount, only the unused mount labels
    gone); the rebuild identical to 1.2d's snapshot apart from Yoast 28.9 (#80); the hand-typed
    form tried; planted faults caught (a plugin without its folder, one first missed by
    `bin/check` and fixed; a path as a plugin name; the written file deleted and written again).
  - [x] 1.2g The browser tests reading the test pages from it, and the check that the tools name
    nothing of this site (2026-11-21). `tests/e2e/specs/dev/test-pages.ts` builds its list from
    `site.json`, which `bin/test` lends read-only to the test container; without it the specs stop
    with a plain message. The words list renamed `namesSharedCodeMustNotUse` (the user), since it
    guards the tools as well as the plugins; `bin/check`'s new check searches `bin/`, `tools/`,
    the workflows, `compose.dev.yaml` and `.env.example` for them, leaving out outside code and
    `bin/deploy-staging` (replaced at 1.4). Made neutral for it: `tools/site-settings.md`'s
    examples (`my-site`, "My Site (dev)", `my-site-child`) and one comment in
    `bin/versions-check`. Other specs naming particular pages (`/music/`, the Book page) are this
    site's tests, sorted at 1.3. Proven: `bin/check` 30 checks; a planted name in a tool caught;
    the specs listed with and without `site.json` (175 tests in 20 files with it, as before; a
    plain refusal without).
  Step 1.2 done 2026-11-21 (#77 to #84 and this one): the tools read the site's facts from
  `site.json` and name nothing of it, apart from `bin/deploy-staging`, which 1.4 replaces.
  Staying with the site, not in `site.json`: the test pages' content (`tests/dev-content/`),
  the coding-standards file (`phpcs.xml.dist`), and the site's own build steps
  (`tests/dev-setup.sh`).
- [x] **1.3 The tests split** three ways (done 2026-11-21, #86 to #89 and 1.3d): generic (headers, no CSP violation, no accessibility
  error, the debug log empty) with the tools; component tests with the components; this site's
  own (Song List, the redirects) staying here. A new site starts with the generic and component
  tests and only the site tests its own features need, not copies of this site's (the user,
  2026-11-21: fewer tests where reasonable). Also here (the user, 2026-11-21, from 1.2e's
  review): permanent tests for the versions check's plugin-update alerts (why an update waits,
  and when a release counts as never proposed), shown so far only on real data in report mode.
  The inventory (2026-11-21, 20 spec files and 12 scenario checks, read from their own
  descriptions): **generic**, for the tools: `theme`, `links`, `admin-view`, `booking-form`, the
  Yoast-standard part of `seo`; scenarios `dev-code-mounts`, `dev-no-php-notices`,
  `dev-settings-guard`, `dev-screenshots-previews`, `dev-booking-form-settings`,
  `final-debug-log`. **Components**, for `dts-site-components` (2.3): `buttons`, `carousel`,
  `frame`, `header`, `hamburger-menu-webkit`, `media-text`, `video-facade`, `video-pause`, most of
  `component-styles`; scenarios `dev-embed-titles`, `dev-patterns`, `dev-privacy-link`,
  `dev-video-pictures`, `dev-stylesheet-versions`. **Plugins**, for their repositories (2.2):
  `song-list` and the song table's part of `component-styles`; `editing-help`; `hardening` and
  the scenario `dev-site-hardening`. **This site's**: `redirects`, the organization part of `seo`.
  In four parts, each its own pull request (T10):
  - [x] 1.3a The spec files and scenario checks sorted into four folders by those groups, the test
    runner set to find them there, `seo` and `component-styles` split along the lines above; the
    same tests and scenario checks run, only their places change (2026-11-21). Folders
    `generic/`, `components/`, `plugins/<plugin>/` and `site/` in `tests/e2e/specs/dev/` (the
    shared helpers in `helpers/`) and in `tests/scenario/` (no `site/` there: none of the
    scenario checks is this site's alone). The runner already searched `specs/dev/` with its
    subfolders; `bin/test` and `bin/check` now find the scenario checks in every folder, run in
    the order of their names as before, and `bin/test` fails if it finds none (from the review;
    shown on a copy pointed at a missing folder). Splits: the organization test into
    `site/organization.spec.ts`, the song table's two into
    `plugins/song-list/song-list-styles.spec.ts`, sharing `helpers/stylesheets.ts`. Shown
    unchanged: Playwright's list, 175 tests before and after (in 20 files, then 22), every project
    and test name the same; the same 12 scenario checks; `bin/check` passed; one scenario check
    from each folder depth and the changed and plugin specs (44) passed on the dev site, the logins
    saved in `tests/e2e/.auth/` as before.
  - [x] 1.3b Component tests find their pages themselves: a shared helper finds the site's test
    pages that use a component, by its class, and the component's tests run on every such page
    instead of on named pages; one neutral page holding every component, built by the dev site
    outside the menu, as the baseline (T10). Test counts change here; every change reported. In
    two pull requests (the user, 2026-11-21: A, the pages found from the page files, read when
    the tests load):
    - [x] 1.3b-1 The example page (2026-11-21): `tests/e2e/specs/dev/components/pages/`, one
      page per file at the file's name (here `component-examples`), with WordPress's default
      template, each component in its own block with a sentence naming it, the awkward
      arrangements included (two carousels, one with an empty heading, one named by the heading
      above it; a video on its own; Media & Text both ways); WordPress's own logo as the picture,
      neutral stand-in videos. `bin/dev-site` builds it after the menu and refuses a test page in
      `site.json` at its address; `TEST_PATHS` includes it, so the every-page checks run there
      too: 175 tests became 186, the 11 every-page tests on `/component-examples/`, nothing else
      changed. `bin/check`'s component check now looks at the example page and the template
      parts instead of `tests/dev-content/`. Planted faults caught: a component removed from the
      page (`site-features`; `site-lead` was rightly still found, in the call to action), and a
      test page at the example page's address.
    - [x] 1.3b-2 The component specs switched to the helper, `pagesUsing(class)`: the example
      page plus every site page whose file in `tests/dev-content/` (lent to the test container
      read-only) has the class; the counts reported spec by spec (2026-11-21). The parts a page
      template adds (header, footer, call to action) are checked on every page that has them,
      none at all failing; the header's behaviour on the front page, every site's. A test of an
      arrangement (two carousels, a carousel under a heading, two panels in a row, a video
      outside a carousel) checks it wherever a page has it and requires it on the example page;
      video-pause reports a site page without its arrangement as skipped, with the reason. No
      test names this site's pages, titles or videos any more: the menu's pages and titles come
      from `site.json`, a video's name and ID from its own picture, Media & Text's sides from
      WordPress's class (the test-only classes in the content removed). Counts (186 to 246, 4
      of them skipped): buttons 10 to 19, carousel 10 to 18, component-styles 9 to 17, frame 10
      to 19, header 15 to 17, media-text 5 to 10, video-facade 7 to 15, video-pause 5 to 16.
      Found on the site's own pages: the Book page had 22px more space before the footer (the
      form's last paragraph's margin, and Contact Form 7's rule outranking the theme's for the
      message after sending), fixed in `form.css` (the user); and the call to action's spacing
      test measured a page ending with a carousel wrongly (its dots lie below its box), fixed in
      the test. Planted faults caught: the carousels' naming switched off (on the example page
      and Music), a plain section's bottom padding left at the end of the content (Home).
  - [x] 1.3c Permanent tests for the versions check's plugin-update alerts (2026-11-21), in
    `bin/check` on every run (the user: every time; they take about a second, and a broken
    alarm stays silent): `tests/tools/versions-check/run.sh` runs the real script, copied with
    the files it reads beside a lock file of one neutral plugin, against stand-ins for `gh` and
    `curl` (`fakes/`, first on the search path, checked before each run; no GitHub login), and
    compares the issues it would open in eleven situations (`scenarios/`: an update within its
    3 days, failed, behind `main`, neither; a pull request beyond `site-packages/`; a release at
    14 and 13 days, with an update open; an issue opened before; without `--act`;
    WordPress.org not answering), dates counted back from the run. The stand-in `gh` requires
    the queries as the script sends them. Planted faults caught: the 3 days made 4, a week of
    6 days, the `site-packages/` filter removed, an issue opened again.
  - [x] 1.3d The starting set for a new site written down (the template notes and this plan): the
    generic and component tests, and only the site tests its own features need (2026-11-21).
    Written in `template-notes.md`, "Tests a new site starts with": the generic and component
    tests on every site unchanged, each plugin's tests where the plugin is used (Site Hardening
    and Editing Help on every site by handbook chapter 3, Song List only where used), and no site
    tests at the start: one is written only for code or settings the site adds itself (this
    site's `redirects` and `organization` as the models). Found on the way: the form's and Yoast's
    tests assume their plugins and never skip, a note on 2.1 (the user, 2026-11-21).
- [x] **1.4 `bin/deploy`**, generic from the start: handbook chapter 2's eight steps. The rebuild
  plan's item 5; replaces `bin/deploy-staging`, whose GitHub-based design is stale (D14). It also
  delivers the downloaded plugins at the versions `site-packages/` pins (T9), instead of updating
  them in each site's admin, so staging and live get exactly the tested versions. Designed
  2026-11-21 (T11), in five parts, each its own pull request:
  - [x] 1.4a Verified on the server, with the user in hPanel: where the PHP error log is, and
    whether an rsync daemon folder can serve it read-only. (How `gh` reads check results in a
    private repository is verified at 2.5; this repository is public.) Found 2026-11-21 (the
    user over SSH, every path and account name masked): Hostinger writes one log per site in
    `~/.logs/` (`error_log_<domain with underscores>`, beside a `mail.log`), outside the web
    folders and above what hPanel's File Manager shows; its lines start
    `[18-Nov-2026 07:05:27 UTC]`. hPanel's `log_errors` is off on live, so the log holds only what
    code writes with `error_log()` (WordPress's database errors, a cron error), never PHP's own
    warnings or fatal errors: shown on the dev site's PHP 2026-11-21, `log_errors=0` kept the
    `error_log()` line and lost an undefined variable's warning, `log_errors=1` kept both. So
    step 8 needs `log_errors` on, on live and staging (`display_errors` stays off). That it then
    writes into the same file is inferred, not seen: WordPress's `error_log()` lines arrive there,
    which means the web PHP's `error_log` setting points at it. The read-only folder: one entry
    per place in that place's rsync settings, `read only = yes`, limited by `include`/`exclude`
    to its own site's file. `~/error_log` in the home folder is the command-line PHP's (startup
    warnings, 2024 and August 2026), not the site's. Two findings for the rebuild plan (9w).
    `log_errors` switched on in hPanel by the user, 2026-11-21 (`display_errors` off).
  - [x] 1.4b `bin/site-check <address>`, the generic page check (handbook chapter 2, step 7): the
    site's published pages from WordPress's page list, each answering with the theme active and no
    critical-error page, retried up to 2 minutes; an unreachable or empty list fails. Run against
    the dev site in `bin/test`, shown failing on planted faults (a broken page, the theme not
    active, the page list unavailable). Built 2026-11-21: each page must answer 200 directly (no
    redirect followed), show `wp-child-theme-<theme>` as a whole class name and end with
    `</html>` (a PHP crash after the page has started still answers 200); only the failing pages
    are tried again (every 5 s, `--deadline`, `--retry-every`); more than 100 pages fails rather
    than checking some; a link at another address is never opened; the staging login from
    `SITE_CHECK_USER`/`SITE_CHECK_PASSWORD` through curl's configuration on standard input.
    From the review (the user's choice, the two MEDIUM and two of the three LOW findings): the
    site's root always checked as well (a front page showing the latest posts is not in the page
    list); curl and jq required at the start (without curl every page looked like a server not
    answering); a login refused over plain http:// unless the host is this computer (compared by
    host name, so `localhost.example` counts as another computer); a temporary folder that cannot
    be made stops the check. The limits stay named constants in the script (the third LOW).
    Tests: 25 situations against a stand-in for curl (`tests/tools/site-check/`, in `bin/check`,
    about 10 s; the missing-curl one with a search path of every command but curl), and
    `dev-site-check.sh` against the dev site, with the parent theme switched on as a real fault
    and the child theme always switched back. Twelve planted faults caught (each check removed in
    turn, a redirect accepted, a half login allowed, a look-alike host taken as this computer; one
    first missed, an empty list refused for the wrong reason, fixed). Passed on the dev site's 7 pages and live's 6. Found on
    the way, not caused by it: one PHP warning in the dev site's debug log from WordPress's theme
    update check failing to reach WordPress.org, most likely from a hand-typed `wp theme list`
    (WP-CLI asks WordPress.org first); not seen again in a clean run.
  - [x] 1.4c `site.json`'s `deploy` section (each place's SSH name, address and whether it is
    behind a password; live only after staging; the page cache), with its rules, explanations and
    broken examples. Built 2026-11-21: `deploy` optional (a site not deployed yet), with
    `pageCache` (required, `"none"` the only value: a cache the tools cannot clear yet is refused,
    not skipped), `live` (required) and `staging` (optional), each with `sshHost` (a short name in
    the user's SSH settings, which hold the server, account, port and key), `address` (`https://`
    and the host only) and `isBehindPassword` (its login from `.env` as
    `<PLACE>_CHECK_USER`/`_PASSWORD`). "Live only after staging" needs no field: it is the
    handbook's rule wherever staging exists. No field lists what is copied or the server's
    folders, which follow the theme's and plugins' folder names, plus `deploy-note` and
    `php-log`. The rules gained allowed values again (removed at 1.2c when unused). The two
    addresses in `site.json` approved by the user (the project rule against the domain in the
    repository covers theme code and server files). From the review (the user's choice, both
    findings): staging and live must differ in `sshHost` and `address` (a rule across fields, so
    a deploy to staging can never land on live), and an address may hold no login
    (`user:password@`). Eight broken examples refused, five planted faults in the rules caught;
    nothing reads the section until 1.4d.
  - [x] 1.4d `bin/deploy staging|live [--commit <commit>]`, with its tests: the refusals as
    functions on examples in `bin/check`, and a run from start to finish against a throwaway
    server container (sshd and rsync with the same forced-command restriction, a stand-in `gh`),
    proving that one place's key reaches neither the other place nor a shell. Decided with the
    user, 2026-11-21: (1) `bin/deploy` uses the `rsync`, `ssh` and `gh` installed on the user's
    computer, beside Docker and `jq`, since `ssh` needs the user's keys and SSH settings where
    they are; (2) a deploy that would lower a downloaded plugin's version on the server refuses
    unless it names it with `--allow-lower <plugin>` (a rollback says what it lowers); (3) `ssh`
    never asks for a password (`BatchMode`): the account's password opens a full shell, so a key
    that does not work stops the deploy instead; the keys get a passphrase, unlocked with
    `ssh-add`; (4) `--ssh-config <file>` for another SSH settings file (the tests need it); (5)
    the test server built from a pinned Alpine image with exact `openssh` and `rsync` versions,
    checked as `AI_SECURITY.md` section 4 says. In three pull requests:
    - [x] 1.4d-1 Before anything is copied (nothing on the server changes): the refusals (a
      working copy not clean, a commit not on GitHub's `main`, checks not passed on it or on its
      merged pull request's last commit with an identical tree), the server's note read, the
      commits shown and "yes" awaited, live only taking staging's commit. Built 2026-11-21.
      Checked first on the real GitHub: a rebase-merged commit links to its pull request (both
      of #90's commits name #90 and its tested last commit 2f24564); only the last one has the
      same tree. A check run again counts by its newest run. The note is one file in the
      `deploy-note` folder (first line, the commit); rsync's status 23 (no such file) means a
      first deploy, any other failure stops it, and the note is read in the script's own shell
      (found on reading back: read inside `$(…)`, a refusal would have ended only that subshell
      and the deploy gone on as a first deploy). Tests: 24 situations in a throwaway Git
      repository with a bare "GitHub", stand-ins for `gh` and `rsync` (which refuses any copy to
      a server and any `ssh` allowed to ask for a password), in `bin/check` (about 8 s). From the
      review (the user's choice): a `git status` that fails stops the deploy instead of reading
      as clean; an `--ssh-config` path with spaces or quotes is refused, since rsync splits its
      ssh command at spaces itself; left as it is, reading only a commit's first 100 check runs.
      27 situations; thirteen planted faults caught. One test bug found on the way: jq's `//`
      turning `false` into the default, as at 1.2b.
    - [x] 1.4d-2 The copy: the downloaded plugins built from `composer.lock` in the pinned
      Composer container and every file checked against WordPress.org's checksum file before
      sending; the server's plugin versions read first (never lowered without `--allow-lower`);
      the downloaded plugins, the site's own plugins, then the theme, each from `git archive` of
      the commit; a folder empty on the server named, to activate by hand; then the note. Built
      2026-11-21. Checked first on the real plugins: the strict comparison (nothing missing,
      different or extra) holds exactly for Contact Form 7 6.2.5 (218 files) and Yoast SEO 28.9
      (1,984). Every check that can refuse runs before "yes" (the build, the checksums, each
      folder existing for the key, the versions), so only a deploy that can be carried out is
      asked about; what is copied comes from the commit's own `site.json` and `composer.lock`, so
      a rollback copies what that commit had. A copy failing midway says the place may run a mix,
      and the note keeps the old commit. Shared, file-reading helpers in `tools/site-packages.sh`
      (the pinned version, the checksum comparison, a plugin's main file and version, version
      order). Tests: 39 situations (12 new), with stand-ins for the Composer build (a neutral
      `example-download` plugin, the same files the checksum file is written from) and
      WordPress.org's checksums, and the stand-in rsync now copying into stand-in server folders;
      ten more planted faults caught (the order, the working folder copied instead of the commit,
      each check skipped, the note before the copy, a copy failure ignored). The real build and
      checksums against WordPress.org are first run for real at 1.4e (a run answered "no" changes
      nothing). From the review (the user's choice): Ctrl+C or a stop during the copy now says the
      place may run a mix, as a failed copy does (situation 40, status 130). Recorded, not
      changed: (a) each plugin folder becomes exactly the release, so a plugin keeping its own
      data inside its folder would lose it at a deploy (Contact Form 7 and Yoast do not); a
      plugin added to `site-packages/` is checked for this first (for the plugin rules, H12, at
      1.4e's handbook proposal); (b) under rootful Docker the build's files belong to root, so
      the temporary folder might not be removed afterwards; `bin/dev-site` assumes the same
      rootless setup.
    - [x] 1.4d-3 After the copy: the page check, the PHP log's new lines, one deploy at a time on
      the computer; and the test from start to finish against the throwaway server. Built
      2026-11-21: the page check failing fails the deploy, naming the way back (`--commit` with
      the commit the place ran before); a place's login refused before the copy when missing
      from `.env`, and exported to the page check inside a subshell only. Stand-in situations
      41-50 (a stand-in page check recording its address and login, and writing log lines as a
      broken page would); eight planted faults caught. The throwaway server
      (`tests/scenario/generic/dev-deploy-server.sh` with `deploy-server/`, about 18 s in
      `bin/test`): fresh keys per run, the host key known in advance and checked strictly, each
      key forced into rsync's daemon mode with its own settings written from the situation;
      `tests/tools/deploy/run.sh --real-server` runs five situations over it with the real
      `rsync` and `ssh` (a first deploy, live after staging, a folder not set up, the log's
      filter, a newer plugin), reading the server back for the same expectations; then probes
      (no shell, the log not writable, no climbing into live's folder, an unknown key refused at
      once). Seen for real: a missing note is rsync's status 23, an unknown folder is refused,
      the plugin version reads over the daemon. Three weakened restrictions planted in the
      server's setup, all caught after one probe was corrected (it wrote a name the log folder's
      filter already refused, so it tested the filter, not "read only"; it now writes the log's
      own name). Decided with
      the user, 2026-11-21: the page check (`bin/site-check`) fails the deploy, a place behind a
      password giving it `<PLACE>_CHECK_USER`/`_PASSWORD`, read from `.env` by exact name alone;
      the PHP log's new lines found by position (its size before the copy), not by the lines'
      times, so a clock difference cannot hide any, shown prominently but not failing the deploy
      (visitors' requests write there too, such as 9w's Wordfence lines), a shorter log (a new
      one) shown whole, and a missing `php-log` folder refused before the copy; one deploy at a
      time by a `flock` lock in the computer's temporary folder, outside the repository. The
      throwaway server: a scenario check in `bin/test`, Alpine 3.24.4 by digest
      (`sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf`, Docker's
      official image, published 2026-11-08) with `openssh-server` 10.3_p1-r2 (2026-11-05) and
      `rsync` 3.5.2-r1 (2026-11-07) from Alpine's own `main` repository, at exact versions
      (option a; all three under a month old, reported to the user, `AI_SECURITY.md` section 4);
      real `ssh`, `rsync` and `bin/deploy`, stand-ins for GitHub and for `bin/site-check`
      (tested on its own; a real one would need a web server with a certificate in the test).
    - [x] 1.4d-4 The weekly warning for the test server's packages (the user, 2026-11-21): Alpine
      keeps only each package's newest version, so an exact pin breaks the test server's build
      the day a new one appears; `bin/versions-check` also compares the pinned `openssh-server`
      and `rsync` with Alpine's package list (`APKINDEX`, for the pinned image's branch, `main`,
      x86_64) and opens an issue (GitHub emails the owner). **No 7-day wait here** (the user,
      2026-11-21): the old version is gone from Alpine's server the day it is replaced, so waiting
      cannot keep it, and the `dev-site` check fails on every pull request until the pin is
      raised; apk checks Alpine's signature on every package against the keys in the image pinned
      by digest. The list is only read, never installed from, so its own signature is not
      checked; its versions and build times must match strict patterns, and a missing package,
      an unreadable list or no answer fails the check. Also (the user, 2026-11-21): each part of
      the check (the theme, waiting updates, unproposed plugins, the test server) runs on its own,
      so an outage in one no longer hides another's finding for a week; the check still fails at
      the end, naming the failed parts in plain words (each pinned theme by its name). Tests: 13
      new situations in `tests/tools/versions-check/` (24 in all; 9 of them check exactly which
      parts are named as failed), each package listed after a look-alike whose name begins with
      its own; 12 planted faults caught, among them running a part under `||`, which turns `set -e` off
      inside it and opened a wrong issue against an unusable pin.
  - [x] 1.4e The server set up (the user's steps: two keys made on the user's computer, their
    restrictions and folders in hPanel), the first `bin/deploy staging`, then `bin/deploy live`;
    removed: the `deploy-staging` job and the push trigger in `check.yml`, `bin/deploy-staging`,
    the GitHub environment `staging` with its secrets, and the old key on the server. Ends D33's
    exception; the rebuild plan's 9b, item 5 and D14 rewritten. The handbook's wording for the
    downloaded plugins (T11) proposed here, for the user's approval. From 1.4d-3's review: the
    test server runs rsync 3.5.2, the host 3.1.3 (3g-2), so the behaviors `bin/deploy` relies on
    (status 23 for a missing file, "Unknown module", the log folder's filter and "read only") are
    proven on the real server here, first by a run answered "no" (it reads the notes and the log
    and lists every folder, changing nothing), then by the first staging deploy.
    **Done 2026-11-22, the user running every server and key command, Claude writing them:**
    - Two ed25519 keys made on the user's computer, each with its own passphrase (in the user's
      password notes), unlocked with `ssh-add`; `hbmusic-staging` and `hbmusic-live` in the
      user's SSH settings (port 65002, `IdentitiesOnly`, strict host checking against the
      identity recorded at 3g-2). One setup script sent over the user's password login (kept in
      `data/records/server-setup-1.4e.sh`, not versioned: it names this site's folders): it
      checks both sites' folders, logs and keys before writing, backs up `authorized_keys`, and
      writes `~/.deploy/rsyncd-hbmusic-<place>.conf` (the 7 folders, `deploy-note`, the
      read-only `php-log` filtered to that site's log; 3g-2's web permissions, one connection,
      a log), the empty folders (staging's `editing-help`, both note folders) and each key's
      forced-command line; tried twice on a throwaway home first (ShellCheck caught a `local`
      ordering slip). A password login now needs `-o PubkeyAuthentication=no`, or a deploy key
      from the agent would be accepted and land in rsync.
    - Probes from the user's computer: no shell (`@RSYNCD: 31.0` only), each key sees only its
      own site's log, `../../` stripped, the old module names unknown, a write to the log
      refused. **Rsync 3.1.3 differs from the test server here:** the client sees only
      "connection unexpectedly closed", and the reason ("module is read only") is in the server's
      rsync log.
    - `bin/deploy staging` answered "no" (the tested-commit rule on real GitHub data, a missing
      note as status 23, the real build and WordPress.org's checksums, every folder listed,
      `editing-help` named new, the versions read), then "yes": 6 pages passed behind the
      site-wide password (the `github-check` login, now in `.env`), no new log lines; Editing
      Help activated by the user. `bin/deploy live` the same (Yoast 28.8 to 28.9, the form.css
      fix); the user saw the Book page right. The first deploy's large change counts (260 for an
      unchanged Contact Form 7) were the files' dates: a second staging deploy of the same commit
      showed 0 everywhere.
    - Found: `bin/deploy` committed without the executable bit (its tests start it with `bash`);
      fixed, with a `bin/check` rule that every script in `bin/` can be run, shown failing first.
    - Removed in the repository: GitHub's `deploy-staging` job and the push trigger
      (`check.yml`), `bin/deploy-staging`, the name check's exception for it. The rebuild plan's
      item 5, 9b, 9p, D14 and D33 marked done or replaced; `docs/ROUTINES.md` gained
      "Deploying", and the monthly check deploys `main` instead of updating Contact Form 7 and
      Yoast by hand.
    - After #95 merged (no run started on `main`): the user removed the old GitHub key's line,
      `rsyncd-staging.conf` with its two backup copies, its log and lock (a second script, tried
      on a throwaway home first, refusing unless both new key lines stay); both keys then read
      their place's note (91a01ff). Claude deleted GitHub's `staging` environment with its six
      secrets and one variable (`gh`, approved by the user); GitHub holds no environment or
      server key now. The handbook (`ee49e7b`, approved by the user change by change): chapter
      2's step 1 (the tested commit's files) and step 4 (what is copied, in order), each place's
      restricted key, and H103 (the downloaded plugins pinned, raised by Dependabot and delivered
      by `bin/deploy`, replacing H11 for them; a plugin keeping its data in its own folder not
      delivered by `bin/deploy`).
    - Found on the way: Brevo's "Verify a new IP" email at 10:35 UTC, two minutes after GitHub's
      old staging deploy opened a staging page (WordPress's scheduled jobs run on a page visit):
      staging's key, sent from the server's IPv6 address, which the user confirmed from the
      server and added to Brevo's Authorized IPs (`data/records/settings.md`). The email itself
      was refused (blocking is on): the user found it in staging's FluentSMTP failed emails and
      resent it successfully once the address was added.
  - Later, its own small part (found 2026-11-22): `bin/deploy`'s change count could tell
    content changes from date-only ones (rsync's itemized `c` and `t` flags), so a first deploy
    does not look larger than it is.
  - For 2.1 or a new site's routine (found 2026-11-22): 1.4e's server setup script made generic
    (the place's folders from `site.json`, the domains and log names as settings), so a new
    site's server is set up the same way.
  - Later, its own part (the user, 2026-11-21): the search checks added to the page check on
    2026-11-15 (H62's title and description limits, one main heading, picture descriptions).
- [x] **1.5 The records and care pieces** the handbook expects of every site: a `records/`
  skeleton, the status sheet (chapter 12), the activity log (Simple History, H94), the routines
  file. Overlaps the rebuild plan's item 3; done there for this site, generalized here. Split with the
  user, 2026-11-22, in four parts, each its own pull request, in this order:
  - [x] 1.5a The records skeleton: `records/README.md` names every record the handbook keeps "in
    the site's records" (chapter 7; settings, hosting, status sheet, search, exceptions, the
    expected plugin set, the site sheet, incidents, monthly reports, the customer's decisions,
    the starter version, takeover and handover), its file, the handbook section and whether it
    may sit in a public repository. Decided with the user: in a public repository (the user's own
    sites) a record mapping the site's security or outside accounts, and an exception or
    incident naming a weakness still open, stays in the private records folder (`data/records/`
    here); a customer's private repository keeps everything in `records/`. A record is created
    when there is something to write, not ahead of time. The starter's copy, without this site's
    section, is noted in `template-notes.md` for 2.4.
  - [x] 1.5b (#96; live 2026-11-23, e243788) The activity log: Simple History pinned in `site-packages/` (Dependabot, `bin/deploy`),
    checked first under the plugin rules (`AI_SECURITY.md` section 4; no data kept in its own
    folder, H103); a dev site test that it records a page edit and a plugin switched off, shown
    failing first; H94's question answered on the dev site (does it log the SEO plugin's
    fields?); deployed and activated on staging and live; the privacy policy checked for
    "logins and changes are recorded".
    **Built 2026-11-22; deployed to staging (3afc5e0, 2026-11-22) and live (e243788, 2026-11-23),
    activated by the user on both with the defaults (the settings record, `data/records/`); its
    Compliance note says it answers WordPress's Export Personal Data tool, now in
    `docs/ROUTINES.md`'s data-request routine:**
    - Simple History 5.36.0 (since 2010, about 300,000 sites, rated 98%; released in October, past
      the wait) pinned in `site-packages/`. Read before use: its outside calls only for paid
      add-ons and a GitHub readme on request, no telemetry found, data in its own tables, the file
      log and weekly email off by default, addresses anonymized (`127.0.0.x`), 30 days kept on a
      fresh install; both defaults kept (the user). Compared with Activity Log (Elementor), Stream
      and WP Activity Log (Freemius); kept by the user for its quality.
    - Its releases list `todos/` notes that WordPress.org's zip leaves out (5 of 363 files in
      5.36.0, 4 in each earlier one); every other file matches. WP-CLI's check on the dev site
      refuses a changed or added file but accepts a missing one (seen with planted faults), so
      `bin/deploy` now does the same (the user, 2026-11-22: a missing file adds no one's code):
      changed or added refuses, missing is shown. Situation 35 changed, a planted fault letting
      everything through caught by 33 and 34. A narrower exception file was designed first and
      dropped as overkill (the user's question); the author not asked to change it (the user).
    - `dev-activity-log.sh` (`tests/scenario/plugins/simple-history/`): a page's title changed and
      a plugin switched off and on, read back through Simple History's WP-CLI by logger, message
      key and ID, every address anonymized; caught with the plugin off and with anonymizing off.
      Found on the way in the check itself: `docker compose run` inside a loop read the loop's
      own input (fixed with no input).
    - The full `bin/test` then found Simple History 5.36.0 writing a deprecation (`trim()` given
      null, through WordPress's `normalize_whitespace`, from its diff drawing) whenever a screen
      shows an entry with an empty side. **The debug log rule changed** (the user, 2026-11-22):
      the site's own code (its theme, its plugins, the dev site's must-use plugins) and any fatal
      error fail; other people's notices, warnings and deprecations are shown, not failed, since
      expecting every plugin to be silent is not reasonable and the browser tests show whether
      something breaks. No list of accepted messages (it would grow). The origin comes from a
      dev-only must-use plugin (`config/dev-mu-plugins/dev-error-origin.php`, the first file
      under `wp-content/` on the call path), because the logged file is often WordPress's even
      when a plugin or the theme caused it; a line without an origin fails. The rule in
      `tests/scenario/debug-log.sh`, tested on ten sample lines in `bin/check`
      (`tests/tools/debug-log/`), and on the dev site with a planted theme warning (fails), the
      plugin's deprecation (shown) and a throwaway plugin's fatal error (fails).
    - H94's question, answered by the user saving a page's Yoast title in the dev site's editor:
      Simple History names the field (`_yoast_wpseo_title`) added or removed, with who and when,
      not its text (a change is `post_meta_changed` in its code, not seen live). The handbook's
      H94 correction proposed separately, for the user's approval.
    - The privacy policy on staging (`data/content/privacy-policy.html`) already says the
      security tools record technical details such as IP addresses; Simple History's failed
      logins (anonymized) fall under it, and only the user has a login.
  - [x] 1.5c The routines file: `docs/ROUTINES.md` split into what every site does (the monthly
    check, deploying, the alerts) and this site's own details.
    **Done 2026-11-23** (the user chose two files and the name): `docs/ROUTINES.md` is the same
    for every site, naming the handbook's toolkit (chapter 3) and linking each site detail to its
    heading in `docs/SITE_SPECIFIC_ROUTINES.md` (places, deploy keys, host, mail, booking form,
    uptime monitor, plugins and theme, theme frame, Site Health, expected set, monthly report,
    staging content refresh, video pictures). `bin/check` fails if a link finds no heading or a
    heading has no link (`tools/routines.sh`, tested on known examples in
    `tests/tools/routines/`; five planted faults caught). Three steps the handbook's monthly
    routine has were missing and were added at the end, so the old step numbers still hold: Site
    Health (H98), nothing unknown among Administrators, plugins, themes and server keys (chapter
    6), and the monthly report (chapter 10, customer sites only). A new site's blank copy is
    described in `template-notes.md`.
  - [x] 1.5d (2026-11-23) The status sheet: this site's `records/status.md` against chapter 12's items,
    each done (with how it was checked) or an exception (with its reason), from
    `docs/SITE_CHECKLIST.md` and what is verified; with the expected plugin set and the
    exceptions; and a blank sheet for new sites. Counted 2026-11-23: 88 numbers in sections
    1-14 (first miscounted as 83, missing numbers that share a pointer line), 2 retired, so 86 to
    answer; section 15 (shop) gets one line. Split with the user, 2026-11-23, in four parts; Claude checks everything it
    can reach (the repository, the tests, the dev site, live and staging from outside) and
    leaves the user one short list per part (the admin, hPanel, the server over the password
    login, outside accounts):
    - [x] 1.5d-1 (2026-11-23) Sections 1-4, the sheet's format (one table per section: item,
      status, how it was checked, date; `open` allowed only while 1.5d is built) and
      `records/exceptions.md` (E1-E6; E5 in the private records). Found and fixed on the way:
      Hostinger's `default.php` placeholder public on live and on staging, and on staging an
      old `.htaccess` backup and an installer's `llms.txt`, deleted by the user; Hostinger's
      `.private` folder on staging kept (the user). The project's `CLAUDE.md` moved to handbook
      version 1 (the user). PHP is 8.4.28 on both, under active support until 2026-12-31, then
      security fixes until 2028-12-31: moving to 8.5 (staging first) becomes due before then.
    - [x] 1.5d-2 (2026-11-23) Sections 5-6 and `records/plugin-set.md`, the expected set (5.5),
      which the monthly check's step 12 compares against. Live and staging read by the user with
      WP-CLI: the same plugins at the same versions, core and the five WordPress.org plugins
      verifying against their checksums. E4 widened to the old theme Music Lite (unmaintained,
      kept until 9n), E7 added (6.9, the debug log rule of 1.5b). Two gaps found and fixed, each
      with a check shown failing first (the user chose both, 2026-11-23): 6.11, the editor
      offered free colors and sizes (WordPress's merged settings; the child's `theme.json` now
      switches them off; `tests/scenario/generic/dev-editor-presets.sh`); and WordPress's version
      in every page's generator tag and the feed, against 3.6's reason (Site Hardening 0.3.0
      empties `the_generator`; two core stylesheets' `?ver=` kept). Both reach live with the next
      deploy, after which 6.11 is marked done.
    - Note (2026-11-23): live and staging run WordPress 7.1.5 (Hostinger's security release),
      the dev site 7.1.4. The dev site's WordPress is raised to it afterwards, as the routines
      say for a host's security fix; to do in a session soon, with its tests.
    - [x] 1.5d-3 (2026-11-23) Sections 7-9. 9.2 by the user (Google's Rich Results Test valid,
      the Schema.org validator 0 errors); 7.4 an exception, E9 (some videos carry brief spoken
      introductions; captions or transcripts left out, the user). Checked by Claude on live
      from outside: headings in order, the skip link, images, caching and compression, fonts and
      outside scripts, the search tags, the old addresses and `robots.txt`. A gap found: the
      handbook's monthly accessibility scan of the real content (7.1, 7.4) did not exist, so
      `bin/accessibility-scan` was built (the user's choice): the pages `bin/site-check
      --print-pages` finds answering (a new option, with three situations, one catching a list
      shortened by a retry), axe at WCAG 2.2 AA with the tests' own rules and images without alt,
      at both widths, in the pinned Playwright container with its own config; tested by
      `dev-accessibility-scan.sh` (a probe page with an image without alt fails it; a planted
      fault swallowing the failure caught); in the monthly check as step 13 (the report moved to
      14). Live: 12 of 12 passed. E8 added (7.3: no real palette passes "every pair it allows").
      9.3's sharing pictures: Home, Book and Songs keep their own photos (the user, 2026-11-23).
      A PR #102 run then failed once: the scan check deleted its probe as the dev admin, leaving
      Yoast's "You just deleted a Page" notice (its icon without alt) for the guide's axe test;
      fixed by deleting without a user, as `dev-activity-log.sh` already did.
    - Handbook proposals collected (each for the user's approval, later, one by one): 6.9's check
      to match E7; 7.3's check to "the pairs the theme uses and every rendered page" (E8); 3.6 to
      name the generator tag; 7.1's "monthly scan of local staging" to "of live's pages from
      outside" (`bin/accessibility-scan`); 2.7 and 3.3's "local staging" where a site keeps staging
      on its host.
    - [x] 1.5d-4 Sections 10-14, the blank sheet for new sites, and a `bin/check` rule: the
      sheet has every item number of the blank sheet, each `done` or `exception` with its
      check or reason filled in, and every test file a row names still exists. Built
      2026-11-23: `tools/status-sheet-blank.md` (made from this sheet's item column, compared
      with chapter 12's numbers both ways: 88), `tools/status-sheet.sh` (every item once,
      retired ones kept retired, a check or reason and a date, E-links reaching
      `exceptions.md`, every repository path or test file named still there), tested in
      `tests/tools/status-sheet/` (13 examples; a real bug caught there: an empty cell merged
      into the next, as a tab is whitespace to `read`; three planted faults caught). From
      outside on live: DNS mail records, no DNSSEC or CAA (E11), the domain locked to
      2027-04-16, no cookies on a first visit, a scripted spam submission refused, no page
      naming staging (only GUIDs). E10 (backups by D27). Answered by the user: the photos are
      the user's own (10.4); the off-computer copy is on an encrypted drive (12.2); Wordfence's
      test email arrived in the inbox, and its scan's one issue (X-Real-IP recommended behind the
      CDN) was ignored after the user's address showed correctly with `REMOTE_ADDR` (14.3); live's
      Live Traffic set to Wordfence's new default, logins and blocked requests only. The sheet: 86
      items answered, none open; `bin/check` holds it there.
    - Dated (2026-11-23): DMARC to `p=quarantine` from about 2026-12-15, four weeks after live
      began sending through Brevo, once Brevo's DMARC reports show only the expected senders
      (handbook H95; status sheet 11.2). A DNS change at Hostinger, by the user, with Claude.
- [x] **1.6 Neutral defaults for the site layer** (done 2026-11-24, with 1.6c-3 settled by T15): a placeholder palette, logo, and header,
  footer and call-to-action wording, so a new site starts from something that works rather than
  from this site's look (T12). In three parts:
  - [x] **1.6a** (done 2026-11-23, `95351f0`) The shared tests made look-independent: the call-to-action panel checked
    against its token and the page behind it, not as green; the booking form's page from
    `site.json`, not this site's address; this site's names out of the generic and component
    tests. Proven by this site's tests still passing.
  - [ ] **1.6b** The neutral site layer (T13), in two parts:
    - [x] **1.6b-1** (done 2026-11-23) This site's code made ready for another look, its own look and behavior
      unchanged: `theme.json` tokens for what a light look would break (the call-to-action
      colors as `custom.callToAction.background`, `text`, `buttonBackground` and `buttonText`,
      replacing `ctaBackground` and `onCta`; `custom.video.playIconColor`;
      `custom.carousel.buttonColor`; `custom.colorScheme` for `form.css`), each with this site's
      present value; `site-cta.css` opening with "CTA: call to action"; the site's facts (old
      addresses, areas served, the organization's type, the policy's outside sources, the link
      example) out of `functions.php` into the site-layer file `includes/site-facts.php`;
      `bin/check` requiring every token the component stylesheets use to be defined in each
      `theme.json`. Proven by `bin/screenshots` showing no change, the redirect, structured-data
      and policy tests, and the new check failing on a removed token.
    - [x] **1.6b-2** (done 2026-11-23; the site-layer files listed in
      `tools/site-layer-files.txt`, checked by `tools/site-layer.sh`; `bin/check` also holds the
      starter's `site.json` and pages, schema, tokens, PHPCS and PHPStan) The `starter/` folder: `README.md` (with the contrast table, each pair the
      components use, the call-to-action panel's text checked at the grain's brightest speck),
      `site.json` (Home, About, Contact, Privacy Policy; Site Hardening and Editing Help),
      `theme/` holding only the site layer (`theme.json` with the light palette, `style.css`,
      `parts/` with the call to action "Get in touch" to `/contact/`, the logo pattern and a
      placeholder SVG, `includes/site-facts.php`), `dev-content/` with neutral text, the Contact
      page holding the form's shortcode (this site's form settings in `config/` as a stand-in
      until 2.4). `bin/check`: `starter/theme/` holds exactly the site-layer files, both ways,
      and `starter/` names nothing of this site except the `hbmusic` prefix until 2.3.
  - [x] **1.6c** (done 2026-11-24; its weekly job and screenshot replaced by T15) The proof: the dev site built with the starter's layer in place of this site's
    (a theme assembled from this theme's generic files and `starter/theme/` into a folder git
    ignores, mounted read-only, standing in for 2.4's starter theme), the generic and component
    tests run on it, as a job in `check.yml` on the Monday schedule and the "Run workflow" button
    only, never on pull requests; then the starter's `screenshot.png`, shot from that dev site
    (added to `tools/site-layer-files.txt` then). Designed and decided 2026-11-23 (T14), in three
    parts:
    - [x] **1.6c-1** (done 2026-11-23) The tools take a site folder, this site's behavior unchanged: `SITE_DIR`
      (default this repository), read by `tools/site-settings.sh`, names the folder holding
      `site.json`, `tests/dev-content/`, the optional `tests/dev-setup.sh` and `themes/`; the
      plugins (`plugins/`) and the form's files (`config/`) stay this repository's.
      `starter/dev-content/` moves to `starter/tests/dev-content/`. `tools/site-theme.sh` assembles
      a site layer's full theme (this theme's files, each listed site-layer file replaced by the
      layer's, the layer's pictures added) into `starter/themes/dts-starter/`, ignored by git and
      rebuilt on every `bin/dev-site` run. For a site other than this one, `bin/test` leaves out
      `site/` and the tests of this repository's plugins the site does not list, naming each.
      `bin/check` always checks this repository; `bin/deploy` and `bin/screenshots` refuse another
      site.
    - [x] **1.6c-2** (done 2026-11-23: the starter 16 scenario checks and 166 browser tests
      passing, this site's unchanged; the guard and `bin/test`'s rewrite of `compose.site.yaml`
      built; four scenario checks that assumed this site fixed with the user's approval) The starter's dev site run locally, with its own database (its slug) and the
      same port as this site's (only one runs at a time; `bin/dev-site` refuses, naming the other,
      when the port is taken). **To do here, from 1.6c-1's review (the user, 2026-11-23):**
      `bin/test` refuses, naming both sites, when the running dev site is not the one it was
      asked to test; the two sites share `compose.site.yaml` and the port, so a plain `bin/test`
      after `SITE_DIR=starter bin/dev-site` would run this site's tests against the starter and
      fail in many confusing ways. The shared video code adds the one address its player uses
      (`https://www.youtube-nocookie.com`) to the policy itself, `https://www.youtube.com` staying
      this site's fact; any other failure of the shared tests on the light look reported to the
      user before it is fixed.
    - [x] **1.6c-3** (settled 2026-11-24 by T15, nothing built) Was: the `starter` job in
      `check.yml`, on the Monday schedule and the "Run workflow" button only; the starter's
      `screenshot.png` (1200x900, its Home), then listed in `tools/site-layer-files.txt`. Instead:
      the starter's tests run before committing any change to what it shares (the project's
      `CLAUDE.md`, Testing); a new site makes its own picture (`template-notes.md`).
- [x] **1.7 The theme's scripts to the strict standards** (done 2026-11-24, 1.7-1 and 1.7-2) (the user, 2026-11-23): the review of
  `assets/js/` against `~/.claude/TYPESCRIPT_STANDARDS.md` (production code, strictly) found
  seven items, all taken, done before 2.3 makes the scripts shared code. Their behavior is held
  by the existing browser tests (one video at a time, the click-to-load videos, the menu).
  1. ESLint with typescript-eslint's `strict-type-checked` and `stylistic-type-checked` over the
     scripts in `bin/check`, zero findings; new tools in `tools/js-check/`, pinned with a lock
     file and vetted first (`~/.claude/AI_SECURITY.md`, section 4).
  2. ES modules instead of the classic scripts' wrapper and `'use strict'`, loaded with
     WordPress's `wp_enqueue_script_module` (since 6.5). First checked on the dev site: whether
     WordPress prints an inline import map that the site's Content-Security-Policy would block.
  3. `video-pause.js`'s shared changing state (the players, the current player, the focus
     timer) held by one small class built with its settings.
  4. `video-pause.js`'s `originOf` catching only the `TypeError` an unreadable address raises.
  5. The event name `hbmusic:player-added` in one place (one module exporting it, with item 2),
     not in both `video-pause.js` and `video-facade.js`. Likewise the player's origin
     `https://www.youtube-nocookie.com` (found in 1.6c-2's review, the user, 2026-11-23): in
     `video-facade.php`'s `HBMUSIC_VIDEO_PLAYER_ORIGIN`, for the security policy, and in
     `video-facade.js`'s `PLAYER_ADDRESS`, tied only by a comment; one home, or a check that the
     two agree.
  6. `video-facade.js`: a facade without its title attribute stays a plain link to YouTube, as
     one with an invalid video ID does, never a player with an empty title.
  7. `tools/js-check/tsconfig.json` gains `exactOptionalPropertyTypes` (and
     `noImplicitOverride`, with item 3's class).

  Done in two parts (the user, 2026-11-24). **1.7-1** (items 1 and 7): ESLint 10 with the two
  configurations, ESLint's own rules for the bans they leave out (`==`, `var`, `let` never
  reassigned, `console`; a planted `==` passed without them), and WordPress's JavaScript layout
  through `@stylistic/eslint-plugin` (`@wordpress/eslint-plugin` left for `@wordpress/scripts`
  with the first block or React work, `template-notes.md`); `tools/js-check/` has its own packages
  and TypeScript 6.0.3, since typescript-eslint supports TypeScript only up to 6.0. **1.7-2**
  (items 2 to 6): the scripts are script modules, printed at the end of the page (WordPress's
  inline import map is allowed by the policy's `'unsafe-inline'` for scripts); what the two video
  scripts share is the module `@dts-site-components/video-shared` (named for the components plugin
  of 2.3, since the type check's settings in `tools/` repeat it and the tools name no site); the
  player's origin has its one home in PHP, carried to the script by each facade's
  `data-player-origin`; a facade without a title or with an origin that is not https stays a
  link, a new browser test shown failing on both.

### Stage 2: the shared repositories (rough)

- [ ] **2.1 `dts-site-tools`**: created in the organization, released by Git tags and pinned
  through Composer (T8), with the reusable workflows; this site switched to it. (T16: `bin/detach`
  and its release check are built at the first real handover, not here; T6, 2026-11-21, had kept
  them so detaching is real.) As each tool moves, Claude checks whether it is still needed
  outside this one repository (for example `bin/check`'s seven starter rules, the versions check's
  alerts that Dependabot may now cover); anything that looks unneeded goes to the user to decide
  (T16, the user, 2026-11-24). To verify then: whether the organization's pinning rule applies to reusable
  workflows (handbook `toolkit/github.md`), and whether a repository outside the organization
  (such as this one, on the user's personal account) may call them. (Dropped by T16: the deploy test's server prebuilt into the organization's container
  registry, from 1.4d-3; 1.4d-4's weekly warning stays.) Note from 1.3d (the user,
  2026-11-21): the generic tests of the booking form (`booking-form.spec.ts`, the scenario check
  `dev-booking-form-settings.sh`) and of Yoast (the Yoast part of `seo.spec.ts`) assume their
  plugin and never skip, so a site without it would fail them, and once the tests live in
  `dts-site-tools` a site cannot delete them. When they move, they follow the site's own list,
  `site-packages/composer.json`: a plugin listed means its tests run and must pass; a plugin not
  listed means `bin/test` names the tests left out and why, never skipping them silently.
- [ ] **2.2 The plugin repositories** (Site Hardening, Editing Help, and Song List, a musician's
  plugin for any site that wants it, T16): each released by a Git tag, this site requiring them
  through Composer. Built once here: the dev site, the tests and `bin/deploy` installing a DTS
  plugin at its listed version; then each plugin's move is small. Checked by Composer's lock file,
  which records each release's exact commit (DTS's plugins have no published fingerprints like
  WordPress.org's). This site's `plugins/` folder leaves the repository; its checks and tests pass
  as before, and a deploy shows no change in the plugins' files.
- [ ] **2.3 The generic theme code** in the components plugin chosen at 1.1 (T5, T16: the one
  home for DTS's shared theme code, which Twenty Twenty-Five cannot hold); this site switched over.
  Installed like 2.2's plugins, nothing new built for it. This site's child theme shrinks to its
  site layer, its look and behavior unchanged (all 24 screenshots identical, every test passing);
  the `hbmusic` prefix in the moved code and its tests renamed for the plugin; the plugin's token
  names checked by `tools/theme-tokens.sh`; the deploy's page check confirming the plugin active;
  whether a plugin can supply the call-to-action page templates checked first (T5). Deployed to
  staging before live.
- [ ] **2.4 `dts-site-starter`** and its new-site guide, from `template-notes.md` and handbook
  chapter 7's six steps; the guide points to `site-settings.md` rather than repeating it. With
  it (from the plan's review, 2026-11-21):
  - a developer guide: how to run the site's tools, what each does, how a change goes from the
    dev site to live, for a developer other than the user;
  - a routine for a new site's first real content: where its pages and photos are built and how
    they reach live (this site used staging's export, D30; a new site on DTS hosting has the
    host preview, H102);
  - the starter's repository runs the same checks every site runs, with its own values, and no
    separate starter check (T15); `bin/check`'s seven starter rules here become that
    repository's ordinary checks of its own files;
  - built from `starter/` (already proven here), plus the lists of shared pieces and their
    versions (the tools, DTS's plugins, the WordPress.org plugins every DTS site uses), an empty
    `records/` with the blank status sheet, a project `CLAUDE.md` with the handbook section to
    fill in, and the allow-list `.gitignore`; once its own checks and tests pass there,
    `starter/` leaves this repository;
  - set as a GitHub template repository, so a new site is created with "Use this template" and
    starts with a fresh history (D18) (the user, 2026-11-24);
  - the guides kept short, each pointing to what already exists (`site-settings.md`,
    `docs/ROUTINES.md`, the handbook) rather than repeating it (the user, 2026-11-24);
  - handbook chapter 7's wording on the starter and the shared pieces brought up to date,
    proposed to the user once the starter exists and written only with the user's approval.
- [ ] **2.5 The second site** started from the starter; the template adjusted along the way
  (H29: what is truly shared is only known with a second site in view).
  The second site (the user, 2026-11-21): DTS's own website, a new WordPress build, the user's own
  site (no separate type; the user is its customer). The organization's `website` repository
  holds an earlier Hugo version that is only a shell; only its logo is kept. At this step: the
  logo saved into the new site's theme (or its data folder) and checked first, then `website`
  deleted on GitHub, and the site created fresh from the starter as `dts-website` (clean history,
  the organization's lowercase naming), with the starter version it began from recorded (T4).
  Its repository is public for now, held to this repository's rules (nothing private committed,
  private records kept outside it); whether to make it private is decided later, after checking
  what GitHub's free plan allows private repositories (branch protection, required checks,
  minutes; handbook `toolkit/github.md`) (the user, 2026-11-24).
  The trial repository `composer-dependabot-trial` was deleted by the user, 2026-11-21.
