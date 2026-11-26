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
- **Now: 2.1,** `dts-site-tools` (T16), in four parts agreed 2026-11-24 (T17). 2.1a done the
  same day: every tool, test and workflow sorted (`findings/step-2.1a-tools-review.md`), the two
  checks on reusable workflows answered. 2.1b's design decided (T18); 2.1b-1, the trial, done
  (`findings/step-2.1b-1-trial.md`): Composer and the reusable workflow behave as the design
  needs; Dependabot raises the tools' Composer pin but never the workflow's commit, so a tools
  command raises it in the review of Dependabot's pull request (T18, option A). **Now: 2.1b-2,**
  `REPO_ROOT` split into three (T19): **2.1b-2a done** (#111, `de724ce`, 2026-11-24:
  `tools/paths.sh` and the rename, behavior unchanged; `bin/check`, the full `bin/test` and the
  starter's tests passing); **2.1b-2b done** (#112, `39677f0`, 2026-11-24: the Compose mount, the site's own
  browser specs in `tests/browser/` mounted apart, the scenario debug-log fix, the status sheet's
  file lookup, `tests/tools/paths/`); **now: 2.1b-3** the repository, designed 2026-11-24 (T20)
  in two parts: **2.1b-3a done** (#113, `f3f4bf0`, 2026-11-24: `bin/check` split into the site's
  checks, the site's own in `tests/checks/` and the tools' self-check
  `tests/tools/check-tools.sh`, shared runner `tools/check-lib.sh`; the dev mu-plugin renamed
  `dev-site-services.php` with its own PHP checker settings in `tools/php-check/`); **2.1b-3a-2
  done** (#114, `ce4ae46`; found while drafting 3b's `composer.json`, 2026-11-24: the checks start PHPCS and
  PHPStan by their packages' own files, `PHPCS_ENTRY` and `PHPSTAN_ENTRY` in
  `tools/check-lib.sh`, since a site's `bin-dir: bin` leaves `vendor/bin/` empty); **2.1b-3b
  done** (2026-11-24: `dts-site-tools` public in the organization, `v0.1.0` on `44362f1`, its
  `check` passing on GitHub; the step entry has the settings); **2.1c built** (T22,
  2026-11-24): committed in `dts-site-tools` as `7c0225a` on `feat/site-workflows`, pushed,
  deliberately unmerged (a rebase merge would rename the commit 2.1d's first call needs); its
  proof is that first call. **Now: 2.1d,** this site switched over, the first milestone (T21),
  in eight parts (its step entry): parts 1-7 done 2026-11-24 (#116 open at `82eed0a`, both
  checks passed; `main`'s protection requires `check / check` and `check / dev-site`; the
  starter's tests passed with the installed tools); part 8, the release, step 1 done (tools #3
  merged, the tools' `main` at `18ef4c0`); step 2 done (2026-11-26: `v0.2.0` tagged on `18ef4c0`,
  annotated like `v0.1.0`, and pushed); step 3 done (this site repinned to `0.2.0`, `cf997d9`;
  #116 merged; #97 closed by Dependabot itself, its group gone); step 4 done (the user's
  `bin/deploy staging` of `ea87e75`, which also carried #117's Simple History 5.37.0: every page
  passed, no new PHP log lines; the site's own folders unchanged in content, their counts only
  new file dates). **So 2.1d is done,** the first milestone.
  **2.1e, the deploy's messages, done 2026-11-26,** so 2.1 is done; designed 2026-11-26 (T23, its step entry);
  its proof on the deploy test's throwaway server done (2026-11-26, every check passed,
  `findings/step-2.1e-1-proof.md`); parts 2 and 3 merged in `dts-site-tools` (#4, `536700b`),
  with its Dependabot #1 and #2; `v0.3.0` tagged on `2d7492c` (#5); part 4 done (this site on
  `0.3.0`, #120, `fd7f8d2`; this repository squash only); part 5 shown on staging (the user's
  deploy of `fd7f8d2`, every list "none", correctly). The user found the messages still hard to
  read, so part 6, **release 0.3.1** (T24), was built and released (tools #6, `1837f6c`,
  `v0.3.1`, 2026-11-26) and this site repinned (#121, `0903c1e`); the user deployed `0903c1e` to
  staging and live (2026-11-26, the first run of Hostinger's own rsync with `--out-format`):
  staging "no file will change", live only Simple History 5.36.0 to 5.37.0 (14 files), git
  agreeing on both, the copy matching the preview, the proof dry run empty, every page passing, no
  new PHP log lines; **both places run `0903c1e`.** **Now: 2.2,** the plugin repositories,
  designed 2026-11-26 (T25) in four parts; 2.2a, the tools' site side for DTS's
  plugins, committed on `feat/dts-plugins` in `dts-site-tools` (`093f9ba`); **now:
  2.2b** done but for Dependabot's view, checked after the merge (2026-11-26): `plugin-check.yml`
  and `bin/plugin-check` on the tools branch `feat/dts-plugins` (T26; with the dev-site fix
  `1ffdbf7`, pushed, unmerged), `dts-song-list` released as `v0.2.1`; this site switched to it on
  `feat/song-list-from-dts` (`f73cf01`, local), proven by `bin/dev-site`, `bin/check` and the
  specs. **Now: 2.2c,** together (T27): steps 1 and 2 done, `dts-editing-help` `v0.1.1` on
  `da3f399` and `dts-site-hardening` `v0.3.0` on `990361e`, each `main` protected; **next:**
  step 3, this site switched to both on the same branch (the 2.2 entry), then the tools' pull
  request and `0.4.0`, this branch repinned to it before its own pull request. **Pull requests merge by squash**
  (the global `WORKING_STYLE.md`, the user, 2026-11-26).
  2.1b-3b was
  the repository (copy from `main`'s commit, `composer.json`, `LICENSE`, `README.md`,
  `CHANGELOG.md`, its `check` workflow, branch and tag rulesets, `v0.1.0`; from the 3a review:
  the changelog also names any change to what `bin/check` provides a site's own checks;
  `composer.json` approved by the user 2026-11-24; the pace set by T21: proof at milestones,
  the three name leaks fixed in the copy). Each
  outside step (the repository in the organization, its rulesets, the tag) proposed to the user
  first. Then 2.1c the
  reusable workflows (a personal-account caller confirmed at its first call; Composer given the
  workflow's read-only token; the pin check and the `bin/tools-pin` command); 2.1d this site switched over (local
  copies removed, the plugin-dependent tests following `composer.json`, all checks and the
  starter's tests passing, a deploy showing no change).
- **For the handbook, with the user's approval:** `toolkit/github.md`'s open trap on pinning
  reusable workflows is answered (T17); its wording proposed when 2.1c is built.
- **Worth raising soon:** (1) every
  deploy's change counts equal the files' count for the site's own code (`git archive` dates
  each file with its commit), so the planned content-only count matters more than first
  thought; (2) Dependabot's 7-day wait did not hold for Contact Form 7 6.2.6 (published on
  WordPress.org 2026-11-23 02:28 GMT, #98 opened 10:17 GMT the same day and merged itself):
  cause not known yet; hypotheses, each to confirm or rule out: a security update (those skip
  the wait; the repository's Dependabot alerts would show it), or WPackagist giving Dependabot
  no usable release time (#98's details against WPackagist's listing would show it).
- **Then, in order:** 2.3 to 2.5 (stage 2, the shared repositories).
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
| T1 | (Its proof at every step relaxed for stage 2 by T21, 2026-11-24.) Two stages (the user, 2026-11-20). Stage 1, in this repository: the site tools made generic (a per-site settings file instead of this site's names in the scripts), the tests split, `bin/deploy` built generic, the records and care pieces, neutral defaults; proven by this site's `bin/check` and `bin/test` passing. Stage 2: the pieces extracted into fresh shared repositories in the organization, with no history from this project (D18), and this site switched over to them. | Making the tools generic changes this site's own scripts and is proven by this site's checks; doing it and moving it at the same time would make a failure hard to place. Working on this repository from a separate project's session would need the user's approval at every edit (the global rule on paths outside the current project). |
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
| T15 | (Its run before each commit replaced for stage 2 by T21's milestones, 2026-11-24.) (Replaces T12's weekly run and T13's and T14's starter screenshot, the user, 2026-11-24.) No scheduled job proves the starter: whenever a change touches what the starter shares (the theme's generic files, the shared tests, the tools, the plugins the starter lists), the starter's tests run before that change is committed (`SITE_DIR=starter bin/dev-site`, then `bin/test`), and the review says so; a change to this site's own files only (its site layer, its `site/` tests, its content) does not need them. The starter carries no `screenshot.png`: each new site makes its own from its Home page once its pages exist. At 2.4 the starter's repository runs the same checks every site runs, with its own values; no separate starter check. | The user: changes are tested when they are made, including the template's later changes during the second site, and the work is to finish soon, so a weekly run would only repeat that testing. The pull-request checks test this site alone, so the starter is tested by a rule instead (both earlier breaks, in 1.6a and 1.6c-2, were found by running the starter on purpose). Dependabot's plugin updates, which merge by themselves, are tested on this site; one breaking only the starter's look is judged unlikely before 2.4. A picture of placeholder pages helps no one; the starter's dev site borrows this site's picture until 2.3 moves the shared code out, on the user's computer only. The starter is laid out as a site (T14) so it needs nothing special: its own repository is a site's repository. |
| T16 | The template's destination and a leaner stage 2 (the user, 2026-11-24, after a review of the remaining plan for bloat, overkill and roundabout steps). **Destination:** a starter the user clones to create a new site. Each site has its own repository, WordPress, child theme of Twenty Twenty-Five, content and settings. A site's repository holds no copy of shared code: it only lists which shared pieces it uses and at which version. The running website installs the plugins and the parent theme at those versions (copies nobody edits, replaced by the next release); the tools (the commands that check, test and deploy a site) run on the user's computer and GitHub's, downloaded at the listed version into a folder git ignores, and are never put on the website. Each shared piece is written and fixed in one home: WordPress's shared theme code in Twenty Twenty-Five (WordPress.org); DTS's shared theme code in the components plugin (2.3, T5); the tools in `dts-site-tools` (2.1); each DTS plugin in its own repository (T2). A site's repository holds only what is its own. **Changes to the plan:** `bin/detach` and its release check are built at the first real handover, not in 2.1 (T6's two modes stay the design); the deploy test's server is not prebuilt into a container registry (1.4d-4's weekly warning stays). **Kept:** the plugins separate, as built (T2); the components plugin (T5); the tools repository with the shared workflow each site calls; this site switched over to the shared pieces; the update rules as settled (T9: WordPress.org plugins merge themselves, everything else, DTS's own plugins and tools included, waits for the user). Song List moves to its own repository in 2.2 with the other two (the user, 2026-11-24): it is already a separate plugin in its own folder, naming nothing of this site, and once 2.2 has built the fetching of a DTS plugin at a pinned version for the other two, its move is small; every DTS plugin then lives the same way. | The user wants the result lean: nothing shared kept as copies, nothing built before it is needed, nothing done the long way round, and nothing finished undone without a reason. Weighed and withdrawn: one plugin for Site Hardening, Editing Help and the components (one release instead of three), since T2's reasons hold (any plugin may later go its own way, no combined release machinery, little cost per repository with shared workflows), the three do different jobs (security, admin help, the look), and the plugins already exist separately. Weighed and withdrawn: a full starter carrying every shared piece as a copy (fixes made once per site, against H28). `bin/detach` is needed only when a customer leaves, and none is near; the shared repositories are public and pinned, so a handed-over site keeps working until it is built. A prebuilt server would add a registry, a build workflow and image pinning to replace a warning that works. Twenty Twenty-Five cannot hold DTS's code (its next update would remove it), so the components plugin is the one home for it. |
| T17 | 2.1's four parts and 2.1a's review (the user, 2026-11-24, Claude's recommendations accepted): 2.1a the review, 2.1b the repository, 2.1c the reusable workflows, 2.1d this site switched over. What moves, stays or moves later is in `findings/step-2.1a-tools-review.md`. Of the items that looked unneeded: `tools/site-theme.sh` and the starter's theme assembly are removed at 2.3, `SITE_DIR` and the dev-site guard stay; the "names nothing of this site" checks stay, in the shared repositories against a list of known site names; `bin/versions-check` moves whole; `bin/screenshots` moves. A site calls the reusable workflows pinned by commit, as its actions are. | GitHub's pinning rule covers only actions ("Reusable workflows can still be referenced by tag", checked 2026-11-24), but a tag can be moved to different code and a commit cannot, the same reason the actions are pinned. The site-name checks caught leaks in stage 1. The versions check's plugin alerts cover what Dependabot does not say (a stuck update, a release never proposed). The second site is styled from scratch, where the screenshots help. |
| T18 | 2.1b's design (the user, 2026-11-24): a site gets the tools through Composer (`dts-site-tools` from its GitHub repository by tag), installed into `vendor/` with its commands in the site's `bin/` (Composer's `bin-dir`; both ignored by git), so the commands keep their names; a fresh clone first runs one install command, the same one the reusable workflow runs. `dts-site-tools` requires PHPCS, PHPStan and their companions at exact versions, and a site's top-level `composer.json` lists only `dts-site-tools`; `site-packages/` stays apart. The tools carry the GPL-2.0-or-later license. The scripts' one `REPO_ROOT` splits into the tools' own folder and the site's. `bin/check` fails when the workflow's pinned commit differs from the commit `composer.lock` records for the tools. A new tools release (option A, the user, 2026-11-24): Dependabot proposes it through the Composer pin; that pull request fails the pin check, naming the commit; in the review, Claude runs a tools command (such as `bin/tools-pin`) on its branch, which writes the lock's commit into the workflow line; the user decides the merge (T9). 2.1b in three parts: 2.1b-1 a trial in throwaway repositories, 2.1b-2 the split of `REPO_ROOT` here, 2.1b-3 the repository. | From the trial (`findings/step-2.1b-1-trial.md`): Composer writes a proxy into `bin/` that runs the real file, so a tool finds its own folder from `BASH_SOURCE`, and exports `COMPOSER_RUNTIME_BIN_DIR`, the site's `bin/`; the current folder is wherever the user stands, so it cannot name the site. A dependency's own lock file is ignored ("The lock file has no effect on projects that depend on your library", Composer's documentation), so only exact versions let the tools' release decide the checkers' versions. A called workflow runs in the caller's context and checks out the caller's commit, so it gets the tools through the site's own install and lock, and the two pins must agree. GPL-2.0-or-later is WordPress's license; the tools ship a WordPress must-use plugin, and DTS's plugins are GPL too. |
| T19 | 2.1b-2's design (the user, 2026-11-24): the scripts' `REPO_ROOT` (224 uses) splits into three folders, and the name `REPO_ROOT` goes. **`TOOLS_DIR`**, the tools' own files (here the repository's top, after 2.1d `vendor/dts/site-tools/`), from the script's own path (`BASH_SOURCE`): `tools/`, one tool calling another, `compose.dev.yaml`, `.env.example`, `config/dev-mu-plugins/`, `tests/scenario/`, `tests/tools/`, `tests/e2e/`'s setup and shared specs. **`PROJECT_DIR`**, the site's repository: the parent of Composer's `COMPOSER_RUNTIME_BIN_DIR`; when that is unset, `TOOLS_DIR`, but only if it holds a `site.json` (this layout, and the tools' own tests' stand-in copies); otherwise the script refuses, saying to run it through the site's `bin/`. It holds `.env`, `compose.site.yaml`, `plugins/`, `config/booking-form*`, `records/`, `docs/`, `.github/`, the PHP checkers' settings, `composer.json`/`.lock`, `vendor/`, `site-packages/`, `starter/`, `data/`, `screenshots/`, and the code `bin/check` checks. **`SITE_DIR`**, unchanged: the site worked on, defaulting to `PROJECT_DIR`, a relative one read from `PROJECT_DIR`. The two new names are worked out once, in `tools/paths.sh`. Two parts: **2.1b-2a** the file and the rename, behavior unchanged; **2.1b-2b** `compose.dev.yaml`'s mu-plugins mount made absolute from `TOOLS_DIR` (Compose's project folder is the site's), the site's own browser specs (`specs/dev/site/`) mounted from the site apart from the tools' `tests/e2e`, `tests/scenario/lib.sh` reading `SITE_DIR`'s `site.json` (it read this repository's, so a PHP notice from the starter's theme was only shown, not failed; shown failing on a planted notice first), a tools test with the tools apart from a stand-in site (found through `COMPOSER_RUNTIME_BIN_DIR`, refused without it, a relative `SITE_DIR` read from the site), and (found in 2a) the status sheet's check (`tools/status-sheet.sh`) finding the files the sheet names in either folder: it looks only in the repository, but the sheet names the tools' files too (`bin/check`, the shared tests). | The next action planned two folders; reading every use found a third: while `SITE_DIR=starter`, the starter borrows this repository's `.env`, plugins, booking-form files and Compose file, so the site worked on and its repository differ. `REPO_ROOT` would name either repository once the tools have their own. The current folder cannot name the site (T18's trial), and a guess from it is what the refusal prevents. Making the moved layout work now (Compose mount, spec mounts) proves it here before anything moves (T1). |
| T20 | 2.1b-3's design (the user, 2026-11-24, Claude's recommendations accepted): two parts. **2.1b-3a, here, behavior unchanged:** `bin/check` split into the checks every site runs (Composer, `site-packages`, PHPCS and PHPStan on the site's code, `site.json`'s rules, the routines' links, the status sheet, `theme.json`'s schema, TypeScript of the site's browser specs, the theme's scripts, Stylelint, actionlint on the site's workflows, the Compose file) and the tools' self-check (every `tests/tools/*` suite and "refuses bad examples" check, `site.json`'s fields explained, Playwright versions match, ShellCheck of the tools, every script runnable), which stays in the tools' repository and is not one of a site's commands; `bin/check` also runs a site's own extra checks from a folder of the site's (given `TOOLS_DIR`, `PROJECT_DIR`, `SITE_DIR`; how they reach the shared helpers is settled while building it), where the components' checks wait until 2.3 and the starter's seven until 2.4; `hbmusic-dev-services.php` renamed for the tools; `docs/TOOLS.md` moves with the tools (missing from 2.1a's table). **Settled on reading `bin/check` (the user, 2026-11-24):** the shared runner and helpers in `tools/check-lib.sh`; the self-check is `tests/tools/check-tools.sh`, also run by `bin/check` when the tools are the site's own (`TOOLS_DIR` equal to `PROJECT_DIR`, this repository until 2.1d); a site's own checks are `tests/checks/*.sh`, each loaded by `bin/check` in name order and calling `run_check` (here `components.sh` until 2.3, `starter.sh` with six starter rules until 2.4; the seventh, the site-layer check's examples, tests a tool and joins the self-check); every file in `tools/` moves with the tools, `site-theme.sh`, `site-layer.sh` and `theme-tokens.sh` leaving at 2.3 and 2.4 as planned; ShellCheck split into the tools' scripts (self-check) and the site's own (`tests/dev-setup.sh`, `tests/checks/`); the mu-plugin becomes `dev-site-services.php` (prefix `devsite_`/`DEVSITE_`, `@package dev-site`, like `dev-error-origin.php`), checked by PHPCS and PHPStan configs of its own in the self-check, and the site's configs drop `config/dev-mu-plugins`. **"The tools name nothing of this site" stays a site check** (replacing T17's list of known site names in the shared repositories): each site checks the tools it installs against its own `site.json`, since a list of known names in a public repository would publish every customer site's name, and a leak can only come from a site whose own check catches it. **2.1b-3b, the repository:** `dts-site-tools`, public in the organization, a fresh history whose first commit names the source commit here (T4); the 3a layout copied unchanged; new: `composer.json` (`dts/site-tools`, its commands under `bin`, the PHP checkers in `require` at exact versions, T18), its `composer.lock` for its own CI, `LICENSE` (GPL-2.0-or-later), a short `README.md`, `CHANGELOG.md` (Keep a Changelog; each release names new `site.json` fields, T7); a `check` workflow running the self-check and the audits on pull requests and weekly (the reusable workflows are 2.1c); `main` protected as here (`check` required, up to date, administrators included, no force-push, rebase merges, branches deleted after merge), a ruleset keeping `v*` tags from being moved or deleted, secret scanning with push protection, Dependabot alerts, Dependabot updates for its own packages and actions waiting for review (T9); first tag `v0.1.0`. A full dev site's proof stays with the sites (this one at 2.1d; at 2.4 the tools' CI may run the starter). Between 3b and 2.1d no tools change is made here, and at 2.1d this site's copies are compared file by file with the tag before they are removed. | Copying `bin/check` as it is would ship this site's later-step checks and the tools' own tests to every site; separating them here first makes the move a plain copy proven by this site's checks (T1). A site should not re-test the tools on every change. A site's own checks are needed now (components, starter) and again at 2.4, where the starter's rules become its ordinary checks of its own files (T15); conditional checks inside the shared `bin/check` would carry one site's layout in the tools. 0.x says the interface may still change until the second site (2.5) has used it; Composer pins exactly anyway. A moved tag would make one version name two different codes. The tools' repository has no site to build a dev site from; `v0.1.0` is proven by being an exact copy of tools proven here. |
| T21 | Stage 2's pace (the user, 2026-11-24): the work behind the scenes moves quickly, and the tools may break between milestones as long as nothing is deployed. The full checks and the starter's tests run at the milestones (this site switched over, 2.1d; after 2.2 and 2.3; the starter, 2.4) and before every deploy, which stays strict (everything passing, the site looking unchanged); in between, Claude runs only what a change touches, or nothing for documents and copies. An urgent fix to live is deployed from the last good commit, never from unfinished work; GitHub's `main` still accepts only passing changes, so unfinished work waits on its branch. Relaxes T1's proof at every step and replaces T15's starter run before each commit, for stage 2 only (the project's `CLAUDE.md`, Testing). Applied first: the check that the tools name nothing of this site covers only `bin/`, `tools/`, the workflows, the Compose file, `.env.example` and the dev mu-plugins, not the tests and `docs/TOOLS.md` that also move (18 lines in 10 files name `hbmusic`); its widening is left for before 2.5, and the three real leaks (`tests/e2e/package.json`'s package name, `docs/TOOLS.md`'s deploy example, `tests/tools/dev-site-guard/`'s example names) are fixed in the copy at 2.1b-3b; the rest is the shared theme code's prefix, renamed at 2.3. | Nothing in stage 2 reaches the website without `bin/deploy`, and this repository is public already, so a name in the new public repository reveals nothing new. Proving every sub-step cost time the user would rather spend finishing. The cost, accepted: a failure found at a milestone may take longer to place. |
| T22 | 2.1c's design (the user, 2026-11-24, Claude's recommendations accepted): the three workflows become shared workflows in `dts-site-tools` (`site-check.yml` with the `check` and `dev-site` jobs, `site-versions.yml`, `site-plugin-updates.yml`), each installing the tools from the site's `composer.lock` first with one Composer command in its pinned container, written out in each workflow and the README (Composer given the run's read-only token; `--no-plugins --no-scripts` in the job that can merge). A site's three callers are **generated**: `bin/tools-pin` writes them from `tools/site-workflows/` with the lock's commit; `bin/check` (only in a site that installs the tools) fails when they differ from what it would write, catching a commit left behind and a hand edit with one rule. **Proven at the first call in 2.1d,** this site's switch-over branch calling the tools branch's commit, before `v0.2.0` is tagged; no throwaway caller repository. `bin/deploy`'s required-check names change at 2.1d, once the first call shows the names GitHub gives called jobs (expected `check / check`, `check / dev-site`, unverified), with this repository's branch protection (an outside change, proposed first). | The tools' files do not exist in a run until Composer installs them, and a called workflow does not know its own commit (2.1b-1's trial), so neither a shared install action nor a shared script can hold the install command; the self-check holds every copy to `tools/versions.sh`'s Composer image instead. Generated callers keep every site's workflows identical, so a fix reaches every site with its next tools release. A throwaway caller would prove the personal-account call and the check names a step earlier, at the cost of another outside repository; 2.1d proves both in the real setting. Changing the deploy's check names before seeing them would rewrite its 30 test scenarios on a guess. |
| T23 | 2.1e's design, the deploy's messages (the user, 2026-11-26). **The rule:** what the deploy shows before the `yes` is exactly what it will do, and what it shows after is exactly what it did; every list comes straight from git or rsync as they print it, nothing counted, translated or summarized by the deploy's code. **Before the `yes`:** (1) the tested-commit line says the commit is the pull request squash-merged (or rebase-merged) on GitHub, and that the merge made a new commit with the same files as the pull request's last commit, whose checks passed; (2) the commit list kept, one line per pull request (squash makes each line a story); (3) a git section, always shown: `git diff --name-only <the server's note commit> <the commit going out> -- <the theme and the site's own plugins>`, printed as git writes it, the command in its header, `none` when git reports nothing, and saying so when the server has no note; (4) a server section: a dry run of exactly the same copy, rsync's own list per folder, the downloaded plugins included, and the deploy's note named as a change; (5) when the two lists disagree for the theme or the site's plugins, one line says so, and both lists are shown. **After the `yes`:** the real copy's own list and one line saying it matches the preview, or the difference; then a second dry run that must list nothing, or the deploy fails. **Removed:** the per-folder change counts and the `copies, in order` line. **Changed:** the copy no longer keeps file dates (`-t`), so a file with the same content is neither sent, listed nor touched. **Proven first,** on the deploy test's throwaway server: that rsync's dry run and real run list the same files, and that without `-t` no unchanged file is listed; if either is not so, Claude tells the user instead of working around it. **In the same release:** the plugin-updates workflow merges by squash, then this repository allows squash only; the tools' README names the old committed `bin/` trap (reinstall restores the commands); `bin/tools-update`, shipped but not in the tools' `composer.json` `bin`, checked and either listed or removed. | The deploy of `ea87e75` (2026-11-26) showed `song-list: 10 change(s)` and similar for folders whose content had not changed: `--itemize-changes` lists date-only differences, and `git archive` dates every file with its commit, so every new commit "changed" every file. The user: the messages must give the confidence that only what is intended changes, be simple, exact and indisputable, and come from the source that is the truth. Git answers what changed between the commit the server last received and the one going out; rsync answers what will actually change on the server, which also shows a hand edit or a half-finished earlier deploy; the two together show both, and their disagreement means something happened outside a deploy. The note is written only after every folder is copied, so it never names a commit half there. A squash or rebase merge leaves the files of the pull request's last commit, since `main` requires a branch up to date, so the tested-commit check (T11) is unchanged. |
| T24 | 0.3.1, the deploy's messages made simple (the user, 2026-11-26, after staging's deploy of `fd7f8d2`: the lines were true but hard to read, "squash or rebase" hedged, and a git list narrowed to some folders could not show that nothing else was coming). **The tested-commit line** drops "by squash or rebase" and is otherwise kept (the user's choice): `commit <id>: pull request #<n>, merged on GitHub; the merge made a new commit with the same files as #<n>'s last commit <id>, whose checks passed`. **Sections,** each a header with its time and source, the lines under it indented: what goes out (the tested-commit line, the server's commit, the commits arriving); the downloaded plugins checked against WordPress.org; rsync before "yes"; rsync after; after the copy. Timestamps on the headers only; the site check keeps each page's line. **One rsync list,** the main answer to what changes on the server: per folder, in copy order, rsync's own lines printed with `--out-format='%i %o <folder path>/%n'` (for example `<f+++++++++ send plugins/simple-history/readme.txt`, `*deleting   del. themes/<theme>/old.php`), written by rsync itself so the deploy translates nothing (T23's rule); above it, one line naming every folder compared, the only ones copied (the commit's `site.json` theme and site plugins and its `site-packages/composer.lock` plugins, so changing the set shows in git); "no file will change" when rsync lists nothing; the deploy's note named last. **Git is a cross-check, not a list:** one line, `git agrees: no change to the site's own code since <server's commit>`, or the files git and rsync both name; when they differ, each file is named with which side has it (for example a hand edit on the server, deleted by rsync and unknown to git), before the "yes". The full `git diff` is not shown: nothing outside the copied folders can go (the user, 2026-11-26: "maybe I don't care if they can't go"). **After "yes":** the real copy's list in the same form, one line saying it matches the preview or naming the difference, then the second dry run that must list nothing. **Proven first** (`findings/step-2.1e-6-out-format-proof.md`): the format prints the same lines in the dry run and the real copy against the deploy test's server, deletions included, date-only differences not listed. **Tests:** the deploy scenarios follow the new layout, still asserting facts (which file, which side, which section), each changed one shown failing on a planted fault; then the full deploy tests and the self-check. **Release:** 0.3.1 with its changelog, tag and this site's repin, each with the user's yes. | The user: the messages must give confidence that only what is intended changes, simply. rsync performs the copy, so its list is what changes on the server; git cannot list the downloaded plugins or a hand edit, and a git list of files that cannot go is noise. A scope line makes an empty list meaningful. GitHub records no merge method (its API has `merged`, `mergedAt`, `mergedBy` and `mergeCommit`, no method; checked 2026-11-26), and the proof, the same files as the tested commit, needs none. rsync's codes kept beside the words (the user's choice): `send` alone does not tell a new file from a changed one. |
| T25 | 2.2's design (the user, 2026-11-26, Claude's recommendations accepted). **Repositories:** `dts-song-list`, `dts-site-hardening`, `dts-editing-help` in the organization, Composer names `dts/<slug>` (the folder stays the WordPress slug); set up like `dts-site-tools` (public, a fresh history whose first commit names the source commit here, T4; GPL-2.0-or-later, README, changelog; squash only, `main` protected with `check` required, tags that never move, secret scanning, Dependabot for its actions); each `composer.json` of type `wordpress-plugin`, requiring `composer/installers`, with `dts/site-tools` in `require-dev` for its checks. **Its checks:** a reusable `plugin-check.yml` in the tools (PHPCS and PHPStan with the plugin's settings, the names-nothing-of-a-site check, and on a tag the tag equal to the main file's `Version:`, which `bin/deploy` reads). **The tools learn DTS's plugins** (`dts/*` in `site-packages/composer.lock`): `bin/dev-site` and `bin/deploy` install them from the lock; **their integrity check (D1):** each `dts/*` package's `dist.url` is `https://api.github.com/repos/direct-technical-solutions/<repo>/zipball/<commit>` with that commit equal to its `source.reference`, refused otherwise, naming the package; the deploy's pins line, "never lower" check and copy cover them; a change to one waits for the user (T9, T16, already so in `site_packages_not_plugins_only`); whether Dependabot proposes their tags from `site-packages/` is checked, not assumed. **Tests (D3):** stay in the tools, run when the site lists the plugin (`localPlugins` or `dts/<slug>` in the lock); moved into the plugin repositories at 2.4 at the earliest, once the starter can host them. **Download contents (D4):** the plugins' check settings and tests are left out of the release download (`.gitattributes` `export-ignore`), so the first deploy after the moves deletes the three `phpcs.xml.dist` files on each server, expected and named. **Order (D5; changed the same day, the user, before 2.2a's build):** 2.2a the tools' site side (tools 0.4.0), proven by lock-file examples in the self-check and deploy scenarios, with `COMPOSER_AUTH` passed to `site-packages/`'s Composer runs when set and set in the `dev-site` job (GitHub's API allows 60 unauthenticated requests an hour); 2.2b Song List, with `plugin-check.yml` built beside `dts-song-list`, its first real tag the proof (no throwaway repository); 2.2c Editing Help, then Site Hardening; 2.2d the starter switched over, the project's `CLAUDE.md`'s stale `includes/site-facts.php` line fixed, the milestone proof (T21) and the deploys. | GitHub publishes no checksums for its archives and the lock's `shasum` is empty, so the counterpart of WordPress.org's download-address check is the release's address and commit, trusting GitHub as the tools already do; a `--prefer-source` checkout (verified by the commit hash) was weighed and set aside: `.git` folders and the plugins' tests in every install and an exclusion in the deploy. A plugin repository has no site to run its browser tests against. A deployed `phpcs.xml.dist` serves no visitor. Song List is the smallest and least critical plugin; Site Hardening touches every page's headers, so it goes last. |
| T26 | (Changes T25's checks, the user, 2026-11-26.) **A plugin's checks are one tools command,** `bin/plugin-check`, the same on the developer's computer and in `plugin-check.yml`, which only installs the tools from the plugin's `composer.lock` and runs it: Composer's validation and audit; the file rules (`tools/plugin-rules.sh`: Composer name `dts/<slug>` and type `wordpress-plugin`, main file `<slug>.php` with `Update URI: false` and a plain `Version:`, which `CHANGELOG.md`'s newest release must name, on every pull request); PHPCS and PHPStan with the plugin's own `phpcs.xml.dist` and a new `phpstan.neon.dist`; `.gitattributes`, `.github`, `composer.lock` and both check settings left out of the release download; actionlint; the caller pinned to the installed tools. `--tag v<version>` also checks a tag names the header's version, run before the tag is pushed and on each tag run. **The plugin's caller is generated** by `bin/tools-pin` from `tools/plugin-workflows/check.yml` (chosen by `composer.json`'s type), for T18's reason. **The names check moves to the site side:** `bin/dev-site` refuses a downloaded DTS plugin that names anything in the site's `namesSharedCodeMustNotUse` or lacks `Update URI: false`. **The tag ruleset stays without bypass** (the user, 2026-11-26): a tag is removed only by switching the ruleset off, deleting it and switching it on again, which GitHub records. | T25's names check in the plugin's repository would need a list of sites' names there, which T20 rejected (it would publish every customer site's name in a public repository); the site installing the plugin has its own names, and its copy is what is deployed. Song List had no PHPStan settings of its own (the site's `paths: plugins` analysed it). A tag that fails its check stays until its ruleset is switched off, and Dependabot or a site may already have fetched it, so the release is checked before tagging; a bypass for administrators would make deleting one command but stop no mistake made with an administrator's login. One command for both places keeps the local and the CI checks from drifting. |
| T27 | (Changes T25's order, D5, for 2.2c, the user, 2026-11-26.) Editing Help and Site Hardening move together, each to its own repository (`dts-editing-help`, `dts-site-hardening`; T2 unchanged): (1) both repositories created and each plugin's files and standard files put in, together; (2) then each finished in turn, Editing Help first: `bin/plugin-check` and its fixes, its check passing on GitHub, its first tag; (3) then this site switched to both downloads on one branch, both folders removed from `plugins/`, one proof run and one pull request; (4) the deploy as strict as ever, staging first, with Site Hardening's headers compared before and after. | Song List's move built and proved everything a move needs (2.2a, T26, the dev-site fix), so the rest is a repeated recipe; one site switch instead of two saves a lock update, a dev-site build, a full check run, a pull request and a deploy. The cost, accepted under T21: a failure is a little harder to place between two plugins. Site Hardening's risk (every page's headers) is held by the deploy, not by the order. |

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

- [x] **2.1 `dts-site-tools`** (done 2026-11-26): created in the organization, released by Git tags and pinned
  through Composer (T8), with the reusable workflows; this site switched to it. Four parts (T17):
  `[x]` 2.1a the review (2026-11-24, `findings/step-2.1a-tools-review.md`); `[x]` 2.1b the
  repository (T18): `[x]` 2.1b-1 the trial (2026-11-24, `findings/step-2.1b-1-trial.md`), `[x]`
  2.1b-2 `REPO_ROOT` split (T19: `[x]` 2.1b-2a the rename (#111, `de724ce`), `[x]` 2.1b-2b the layout fixes and
  the test (#112, `39677f0`, 2026-11-24: the dev-only mu-plugins mounted from the tools' folder through
  `compose.site.yaml`; the site's browser specs in its own `tests/browser/`, mounted into the
  tools' `specs/dev/site/`; the scenario checks' debug-log rule reading the tested site's
  `site.json`, shown failing on a notice planted in the starter's theme; the status sheet's files
  found in either folder; `tests/tools/paths/`, shown failing on two planted faults)), `[x]` 2.1b-3
  the repository (T20, 2026-11-24: `[x]` 2.1b-3a here (#113, `f3f4bf0`), `bin/check` split into site checks, the
  tools' self-check and a site's own extra checks, the mu-plugin renamed (every earlier check
  still run, compared by name; three planted faults, one per part, each failing in its part; the
  self-check passing on a copy of the tools alone, which found `bin/dev-site` telling ShellCheck
  to follow the site's `tests/dev-setup.sh`, now the site's ShellCheck's); `[x]` 2.1b-3a-2 (#114, `ce4ae46`) the
  PHP checkers started by their packages' own files, not `vendor/bin/` (a scratch install with
  the bin folder set to `bin/` left no `vendor/bin/`; the old path failed there, the new ones
  worked); `[x]` 2.1b-3b the
  repository, its checks, settings and `v0.1.0` (2026-11-24: `direct-technical-solutions/dts-site-tools`
  public, rebase merges only, branches deleted after merge; secret scanning with push protection,
  Dependabot alerts and security updates; `main` protected with `check` required, up to date,
  administrators included, linear, no force-push or deletion; the ruleset "release tags never
  move" on `v*`, no bypass; `check` passed on GitHub, then `v0.1.0` tagged on `44362f1`. T21: the three name leaks fixed in the copy; the
  name check widened to the tests and `docs/TOOLS.md` before 2.5; first commit `44362f1` made
  locally 2026-11-24, self-check 28 of 29 then the 29th passing after the change below; four
  files differ from `ce4ae46` on purpose, expected at 2.1d's file-by-file comparison:
  `tests/e2e/package.json` and its lock file's package name, `docs/TOOLS.md`'s deploy example,
  `tests/tools/dev-site-guard/run.sh`'s example names, and `tests/tools/check-tools.sh`'s Composer
  validation with `--no-check-all`, since `--strict` failed on the exact versions T18 requires)); `[x]` 2.1c the reusable workflows, called pinned by commit (T22, 2026-11-24: built
  in `dts-site-tools` on branch `feat/site-workflows`, committed as `7c0225a` and pushed, unmerged until 2.1d's first call proves it: the three `site-*.yml`
  workflows, `tools/site-workflows/` with `bin/tools-pin` and `tools/tools-pin.sh`, `bin/check`'s
  pin check for sites that install the tools, the README's install command, `docs/TOOLS.md`, the
  changelog; the self-check 29 of 29 passing with its three new checks (the pin's 14 examples,
  the install commands' Composer image, actionlint on the shared workflows and the rendered
  callers), each shown failing on a planted fault; actionlint works offline and passed a
  misspelled input in a caller calling by GitHub address, so the self-check lints the callers
  rewritten to call by local path in a copy with a `.git` folder, which caught it; found: the existing `in_composer_of` mounts no
  `bin/`, so the install command mounts the site's `bin/` itself); `[x]` 2.1d this site
  switched over (the approach agreed 2026-11-24, eight parts: install, remove the copies,
  callers and Dependabot, `.env` and local checks, the first call, the real check names, the
  milestone proof, the release; the plugin-dependent tests left to 2.4, the user. Done so far,
  branch `feat/use-site-tools`: the site requires `dts/site-tools` at `dev-feat/site-workflows`,
  the lock recording the commit (a `#commit` pin failed `composer validate --strict`); the local
  copies removed after comparing them with the tools (only the expected differences); the
  callers written by `bin/tools-pin`; `dependabot.yml` down to the tools and the plugins;
  `.env`'s `COMPOSE_FILE` pointed at the tools; `bin/check` 39 of 39 and the dev site built from
  the installed tools. Found and fixed in the tools as `d01ba99` on `feat/site-workflows`:
  `bin/tools-pin` was missing from the tools' `composer.json` `bin`, so never installed (a new
  self-check rule holds the two equal), and a new `.env` named `compose.dev.yaml` at the
  repository's top (now written for where the tools are). Found, for the user to decide later:
  the parent theme's pinned version, `PARENT_THEME_VERSION`, is in the tools' `tools/versions.sh`,
  so raising a site's parent theme takes a tools release. The first call (#116): the
  personal-account caller works; the check runs are named `check / check` and
  `check / dev-site` (from the check-runs API); `dev-site` failed in the deploy-server scenario,
  the deploy tests not clearing `COMPOSER_RUNTIME_BIN_DIR`, so `bin/deploy` worked on this
  repository: fixed in the tools with `REQUIRED_CHECKS` set to the new names (a commit tested
  only under the old names is refused), then both checks passed; `main`'s protection set to the
  new names (the user's yes). The traces' path (`vendor/dts/site-tools/tests/e2e/test-results/`)
  is unverified until a browser test fails on GitHub. The starter's tests passed (17 scenarios,
  168 browser tests). Tools #3 merged by rebase, `main` at `18ef4c0`. Then, done 2026-11-26 (the
  Current position): `v0.2.0` tagged, this site repinned to `0.2.0` and #116 merged, #97 closed,
  the user's staging deploy. From 2.1c, T22: the first call of the shared workflows from this site's branch,
  pinned to the tools branch's commit, confirming the personal-account caller, the check names
  GitHub gives called jobs and the traces' path in `vendor/`; then `bin/deploy`'s
  `REQUIRED_CHECKS` and its test scenarios, and this repository's branch protection, set to those
  names; `v0.2.0` tagged after; found in 2.1b-2b: `.env`'s `COMPOSE_FILE`, written from `.env.example`, names
  `compose.dev.yaml` relative to the site's repository, so hand-typed `docker compose` commands
  need its new place there; found in 2.1b-3a-2: Composer reads `allow-plugins` only from the
  top-level `composer.json`, so the site's own must allow
  `dealerdirect/phpcodesniffer-composer-installer`, the plugin that registers the WordPress
  standards with PHPCS; what Composer does without it is seen at 2.1d). (T16: `bin/detach`
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
- [x] **2.1e The deploy's messages** (T23, the user, 2026-11-26; done 2026-11-26), before 2.2, whose plugin move
  is the deploy where "nothing else changes" matters most. In order: (1) the proof on the deploy
  test's throwaway server (dry run and real run list the same files; no unchanged file listed
  without `-t`), reported to the user before building; **done 2026-11-26, every check passed**
  (`findings/step-2.1e-1-proof.md`); (2) the build in `dts-site-tools` on a
  branch, its deploy test scenarios covering each section (git changes and none, no note, a hand
  edit on the server shown by rsync alone with the one-line notice, the real copy matching the
  preview, the proof dry run failing on a planted difference), each shown failing on a planted
  fault; **committed 2026-11-26** in `dts-site-tools` as `ccd3b7e` on `feat/deploy-messages`,
  not pushed (57 stand-in scenarios and 6 real-server ones passing, the self-check passing; the
  stand-in now runs the real rsync between local folders, so whether GitHub's runner has rsync is
  shown by the branch's first run; found and fixed on the way: Ctrl+C's message would have gone
  into the copy's error file; left as LOW from the review: unusual file names quoted differently by
  git and rsync, the proof's refusal reusing the "mix" sentence, no rename scenario, the note's
  text shown raw); (3) the plugin-updates workflow to squash, the README's `bin/` trap, `bin/tools-update`
  settled; the tools' Dependabot #1 (PHPStan 2.3.5 to 2.3.6, this site's closed #97) and #2
  (`@stylistic/stylelint-plugin` 6.0.0 to 6.0.1, this site's #56, closed 2026-11-26 pointing
  there) reviewed by hand, lock files line by line (T9), the user deciding each; **done
  2026-11-26:** the workflow squashes, passing Dependabot's own message, bound to the checked
  head, a pull request of more than one commit waiting; `bin/tools-update` kept and fixed rather
  than removed (the user asked to look back: it is the safe way to update what Dependabot is told
  to leave alone, Playwright above all; it had refused in the tools' repository, which has no
  `site.json`), with its own test; the tools' repository set to squash only; #1 and #2 merged
  (Dependabot ignored `@dependabot rebase` on #2, cause not known; GitHub's branch update used
  instead, harmless where nothing merges itself); #4 squash-merged as `536700b`, its `check`
  passing on GitHub, so the runner has rsync; (4) `v0.3.0` tagged after the user's yes, this
  site repinned (`bin/tools-pin`, `bin/check`), then this repository set to squash merges only;
  **`v0.3.0` tagged 2026-11-26** on `2d7492c` (#5); this site repinned on `build/tools-0.3.0`
  (the lock changing only the tools and PHPStan 2.3.6; `bin/check` 39 of 39); **done** (#120,
  `fd7f8d2`; this repository squash only); (5) the user's next deploy shows the new messages:
  **shown on staging 2026-11-26** (`fd7f8d2`, every list "none", correctly: nothing differed but
  the note); the user found them still hard to read, hence (6) **0.3.1** (T24): the tested-commit
  line without "by squash or rebase", the sections, one rsync list with its scope line, git as a
  one-line cross-check; its proof done (`findings/step-2.1e-6-out-format-proof.md`); **built and
  released 2026-11-26** (the user's choices: the downloaded plugins' section says whether the pins
  changed since the place's commit, the plugins that match sharing one line; the "git agrees"
  line names the files; every page's line kept): tools #6 squash-merged as `1837f6c`, `v0.3.1`
  tagged on it; 59 stand-in deploy scenarios (two new for the pins line), 6 real-server ones and
  the self-check 31 of 31 passing, ten planted faults each caught. Found on the way: to a real
  server rsync marks a file sent with `<`, the local stand-in with `>`. Left as LOW from the
  review: the "only the lock file's other entries" pins line untested; an unreadable old lock
  reads as no pins; `bin/site-check`'s lines flush left between the indented ones; an
  interrupted folder's partial list not shown. This site repinned (#121, `0903c1e`, both
  required checks passed; `bin/check` 39 of 39 locally); the user's deploys of `0903c1e`
  (2026-11-26) showed the new layout against Hostinger's rsync: staging no file changed, live
  only Simple History 5.37.0's 14 files, git agreeing, the copy matching the preview, the proof
  dry run empty, every page passing, no new PHP log lines.
- [ ] **2.2 The plugin repositories** (Site Hardening, Editing Help, and Song List, a musician's
  plugin for any site that wants it, T16): each released by a Git tag, this site requiring them
  through Composer. Designed 2026-11-26 (T25), in four parts: `[~]` 2.2a the tools' site side
  for DTS's plugins (tools 0.4.0), proven by examples and deploy scenarios (**committed
  2026-11-26** in `dts-site-tools` as `093f9ba` on `feat/dts-plugins`, not pushed: the self-check
  31 of 31, 63 stand-in deploy scenarios with four new (60-63), seven lock-file examples, each new
  scenario failing on a planted fault; unproven on a real site and on GitHub until 2.2b; left as
  LOW from the review: the token in the whole `bin/dev-site` step, a scenario-only folder in
  `TESTS_LEFT_OUT`, the header "(git, Composer)" for a site without downloaded plugins); `[~]` 2.2b Song List
  moved, with the reusable `plugin-check.yml`, its first tag (`v0.2.1`, the header's version, the
  user) the real proof: `dts-song-list` created 2026-11-26 with `dts-site-tools`' settings
  (public, squash only, branches deleted after merge, secret scanning with push protection,
  Dependabot alerts and security updates, the ruleset "release tags never move" on `v*` without
  bypass); `bin/plugin-check`, `plugin-check.yml`, the plugin caller and the site-side names
  check built on `feat/dts-plugins` (T26, `5f3fb36`: self-check 32 of 32, the plugin rules
  test's 18 examples and the pin tests' two plugin examples, seven planted faults each caught; a
  local trial on a stand-in Song List then showed PHPStan needing `bin (?)` and the first full run
  found actionlint started without the files, fixed in `41a6155` by one shared
  `actionlint_workflows_of`; both pushed, the branch unmerged until 2.2b's proof); Song List's
  first commit `6e050c1` (from this repository's `0903c1e`, kept locally in `~/dev/dts-song-list`),
  `bin/plugin-check --tag v0.2.1` 9 of 9 locally, `check / check` passing on GitHub (the button's
  run, then the tag's), `main` protected like the tools' (`check / check` required, up to date,
  administrators included, linear, no force-push or deletion), **`v0.2.1` tagged and pushed**
  (2026-11-26); this site requires the tools branch (`41a6155`, `bin/tools-pin`) and
  `dts/song-list` 0.2.1 (locked at `6e050c1`, its download GitHub's zipball of that commit);
  `plugins/song-list/` and its `localPlugins` entry removed. The download's code files are
  identical to the removed folder; it also carries `CHANGELOG.md`, `composer.json`, `LICENSE` and
  `README.md`, so the first deploy adds those four to Song List's folder on each server besides
  deleting `phpcs.xml.dist`. The first `bin/dev-site` failed: the files volume (kept since
  2026-11-04) held the old mount point `song-list/` as an empty folder, so `docker cp` nested the
  plugin one level too deep; fixed in the tools (`1ffdbf7`, pushed: the folder deleted before
  the copy, the name checked first; no kept test, by the user's choice, the failing dev site
  itself the proof). Then `bin/dev-site` passed, the installed folder equal to the release,
  `bin/check` 38 of 38 (the Song List plugin's PHPCS check gone with its folder), the Song List
  and component styles specs 26 of 26 (2026-11-26); **next in 2.2b:** Dependabot's view of
  `dts/*`, checked after the merge from its job log ("Check for updates" on `/site-packages`); `[~]` 2.2c Editing Help and Site Hardening, together (T27): both repositories created
  2026-11-26 with `dts-song-list`'s settings (read from GitHub and compared after), each
  plugin's files unchanged from `0903c1e` with the standard files; `bin/plugin-check --tag` 9 of
  9 for each with nothing to fix, `check / check` passing on GitHub (the button's run and the
  tag's), `main` protected, **`dts-editing-help` `v0.1.1` (`da3f399`) and `dts-site-hardening`
  `v0.3.0` (`990361e`) tagged and pushed**; next: step 3, this site requiring both in
  `site-packages/`, `plugins/editing-help/` and `plugins/site-hardening/` removed with their
  allow-list lines and `localPlugins` entries, the wording elsewhere shown to the user first,
  then `bin/check`, `bin/dev-site`, Site Hardening's scenario check and both plugins' specs; `[ ]` 2.2d the
  starter switched over, the milestone proof and the deploys. Built once here: the dev site, the tests and `bin/deploy` installing a DTS
  plugin at its listed version; then each plugin's move is small. Checked by Composer's lock file,
  which records each release's exact commit (DTS's plugins have no published fingerprints like
  WordPress.org's). This site's `plugins/` folder leaves the repository; its checks and tests pass
  as before, and a deploy shows no change in the plugins' files except the three `phpcs.xml.dist`
  deleted (T25, D4) and each plugin's four release files added. The status sheet's evidence
  naming the plugins' tests (`tests/scenario/plugins/…`, now in the tools) is reworded here, once
  those tests have their final home (left from 2.1d, the user, 2026-11-24).
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
