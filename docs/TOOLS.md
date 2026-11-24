# Tools

*"The user" is the person Claude works with; "Claude" is the assistant.*

What each of this project's commands and tools does, in full: moved here word for word from the
project's `CLAUDE.md` on 2026-11-24, which keeps a short entry per command and every rule, so that
this detail is read when working on a tool rather than with every message. A change to a tool
updates its entry here (and its own header comment).


The scripts below need only Docker and `jq` on this computer; every tool they use runs in a
pinned container. They read the site's facts from `site.json` and name their Docker volumes
from its `slug` (template plan 1.2d), and stop at once, naming the problem, if `site.json` breaks
its rules.

The **dev site** runs in Docker Compose (`compose.dev.yaml`): a fresh WordPress with the new child
theme, the plugins and test content, with its settings in `.env` (created from `.env.example`
with random secrets; never committed). This project's ports are the **101xx** block: the dev
site on 10102, its Mailpit inbox on 10103, the rest of the block for later needs. The old site's local copy was removed at
plan step 5a-2; the real old site stays online until go-live, and the export stays in `backups/`,
`db/` and `wordpress/`.

**Which site:** `bin/dev-site` and `bin/test` work on this repository's site unless `SITE_DIR`
names another site's folder (template plan 1.6c, T14): `SITE_DIR=starter bin/dev-site` builds the
starter's dev site (its own database, from its slug; the same port, so one dev site runs at a
time), and `SITE_DIR=starter bin/test` tests it, leaving out this site's own tests (`site/`),
those of this repository's plugins the starter does not list and the screenshots check, each
named in the output. Both refuse, naming the two sites and the command that stops the other by
name, when the port is held by another site's dev site (`tools/dev-site-guard.sh`, template plan
1.6c-2); to switch, `docker compose -p <slug>-dev stop` (its data stays), then `bin/dev-site` with
the other site's `SITE_DIR`. `bin/check` always checks this repository; `bin/deploy` and
`bin/screenshots` refuse another site. The click-to-load videos allow their own player
(`https://www.youtube-nocookie.com`) in the security policy; a site's facts add the rest.

- `bin/dev-site`: builds or rebuilds the dev site from nothing (an empty database each run),
  from the site's facts in `site.json` (its theme, title, own plugins and test pages) and its
  downloaded plugins in `site-packages/composer.lock`, all checked before anything is changed
  (template plan 1.2b, 1.2c):
  WordPress, the parent theme Twenty Twenty-Five at the version and SHA-256 pinned in
  `tools/versions.sh`, the child theme and the site's own plugins (`localPlugins`: Song List,
  Site Hardening, Editing Help) mounted read-only and activated, its downloaded plugins installed
  by Composer from `site-packages/composer.lock` (in the pinned Composer container, which sees only
  `site-packages/`), copied in and checked against WordPress.org's checksums: Contact Form 7
  with the real booking form from `config/booking-form.txt` and `config/booking-form-mail.json`,
  and its messages after sending ("sent" and "sending failed") from
  `config/booking-form-messages.json` (merged into Contact Form 7's own messages; staging and live
  get the same texts typed in by hand, in the form's Messages tab),
  and Yoast SEO, and Simple History, the activity log (template plan 1.5b; a
  scenario check, `dev-activity-log.sh`, shows it records a page edit and a plugin switched off
  and on, with addresses anonymized), test pages (`site.json`'s list, their text in `tests/dev-content/`, each with the
  page template its real page uses) and the components' example page (every component on neutral
  content, outside the menu), a stand-in Yoast organization (a neutral name and a picture
  WordPress itself ships), then the site's own steps in `tests/dev-setup.sh` (here, the Song
  List's sample songs, neutral text), a dev admin (`devadmin`, password
  `DEV_ADMIN_PASSWORD` in `.env`) and a dev Editor (`deveditor`, `DEV_EDITOR_PASSWORD`), the role
  a customer gets. To log in by hand, copy a password without showing it:
  `grep '^DEV_ADMIN_PASSWORD=' .env | cut -d= -f2- | tr -d '\n' | wl-copy`. `config/dev-mu-plugins/`, on the dev site only and never
  deployed (and mounted for WP-CLI too), notes each PHP message's origin in the debug log
  (`dev-error-origin.php`), sends mail to Mailpit and answers for Cloudflare, for YouTube's oEmbed service (so the stand-in videos are real video blocks, loading WordPress's same styles as live) and for YouTube's image server (a test picture). Needs no backup, so CI can build it
  too.
- `bin/test`: the tests against the dev site, each in its group's folder (template plan 1.3a:
  `generic/`, `components/`, `plugins/<plugin>/` and `site/`, the site's own; the browser tests'
  shared helpers in `helpers/`), so each group can later go with its own repository: the
  scenario checks named `tests/scenario/<group>/dev-*.sh` (bash, sharing `lib.sh`: read-only theme and plugin mounts, the
  PHP debug log's rule (`tests/scenario/debug-log.sh`, template plan 1.5b: any message from the
  site's own code, and any fatal error, fails; other people's notices, warnings and deprecations
  are shown, each with its origin), the `.env` safety stop, every stylesheet of the theme and the Song List labelled
  by a fingerprint of its contents, embedded videos' titles read as written, the theme's patterns matching the structure its CSS expects, the editor offering only the theme's colors and sizes (`dev-editor-presets.sh`, handbook 12, 6.11)), then the browser tests in `tests/e2e/specs/dev/` in the
  official Playwright container (`--network host`, seeing only `tests/e2e/` and, read-only,
  `config/booking-form-messages.json`, `site.json`, whose test pages the specs that check every
  page read, and `tests/dev-content/`, where each component's tests find the pages that use it,
  the example page and every site page with the component's class, template plan T10): child theme active,
  security headers sent, no CSP violation, no axe accessibility error at WCAG 2.2 AA, the Song
  List's page and admin form, the booking form's mail (no visitor's name in the subject), its
  message when sending fails (Mailpit made to refuse mail, in a serial group) and refusals, and its files loading only
  where it appears; the stylesheets loading only with what they style (the theme's components,
  the form's, the song table's from its plugin, plan D29), the bands' texture, the call-to-action panel's green and its button standing out from it, the lead text larger than body text, the hero's text and picture centred on each other with the picture's softened bottom, the features panel's buttons lined up, and the headings' even
  lines; the buttons' keyboard focus ring and
  its contrast against its band, equal sizes and equal widths in a row, no movement with reduced motion and no stuck hover
  after a tap (D29); the video carousel's row, label, keyboard access, end, its first and last slides centred, several carousels each with their own arrows, a carousel named after a heading directly above it, described as a carousel with "n of m" slides, an empty heading above it left out, and reduced motion (D29); the click-to-load videos (nothing from YouTube before a video is played, each picture from the site in a 16:9 box, played by click or Enter in YouTube's privacy-enhanced player, a link to YouTube without JavaScript; their pictures fetched when a page is saved, `dev-video-pictures.sh`, plan 9v); the video script (one YouTube player at a time: starting one, one moved out of its carousel's view, or the visitor clicking into another, pauses the others; scrolling the page never does; loaded only where there is a video, with stand-in players instead of YouTube); one frame on every page (the header,
  footer, panels and carousel sharing the same edges on a computer and a phone, the panels at the theme's wide width on a wide screen, two panels in a row never touching, the call to action from the page template a section's spacing below the content, D29); the sticky header, a link reached with the keyboard never under it, the
  menu's current-page mark, the same space before the footer after the call to action as after text in both page templates, the slimmer phone header, and the hamburger menu on a phone as a small panel under the header at the right, as wide as its links, with every link reachable, closed by its button, Escape or a tap on plain page content beside it (the theme's `menu-close-outside.js`; also in WebKit, plan 9t); Media & Text's text lined up with the page title on a computer and a phone, its text first on a phone when the picture is on the right (plan 9t-3)
  (D29); the Site Hardening plugin's refusals; the old addresses' redirects; the Editing Help
  guide for the admin and the dev Editor (its panel first on the Dashboard, and on the Editor's first screen, headings and accessibility, the
  site's templates, sections and link example, and every editor label it names found in the real
  editor, on a draft page of its own); then, last, a check that the PHP debug
  log still holds nothing from the site's own code and no error after everything (`tests/scenario/generic/final-debug-log.sh`). If the site does not
  answer, the run fails; it is never skipped.
  Before a commit that touches the site, the theme or a plugin, Claude runs `bin/check` and the
  browser tests of the part changed (their spec files, in the Playwright container as `bin/test`
  runs them), plus any scenario check the change touches; the full `bin/test` runs on GitHub for
  every pull request (the required `dev-site` job), and Claude runs it locally only for a change
  that reaches across the site (the user, 2026-11-17: a small code change took about 15 minutes
  from ready to live, the full tests running three times). Every test runs even after a failure;
  exit status 1 if any failed.
- Dev site: http://localhost:10102 (admin `/wp-admin`); mail inbox: http://localhost:10103.
- The dev site's recipe is two files (template plan 1.2f): `compose.dev.yaml`, the same for every
  site, and `compose.site.yaml`, the site's own name and mounts, written from `site.json` by
  `bin/dev-site`, `bin/check` and `bin/screenshots` (ignored by git; never edited). `.env`'s
  `COMPOSE_FILE` names both, so the commands below, typed in the repository's folder, use them.
  After changing `site.json`, run `bin/dev-site` before typing them, so the written file follows.
- `docker compose stop` / `start`: stop and start without losing anything.
- `docker compose run --rm cli wp <command>`: WP-CLI against the dev site.
- `docker compose down -v` deletes the dev site's database and files (the
  volumes); Claude runs it only when the user asks. `bin/dev-site` rebuilds them.
- `bin/check`: every code check, in pinned containers (only Docker and `jq` on the host; it
  stops at once if `jq` is missing):
  Composer install from `composer.lock`, validation and security audit; PHPCS with the
  WordPress Coding Standards (`phpcs.xml.dist`); PHPStan at level max with the WordPress 7.1
  stubs (`phpstan.neon.dist`), both over `themes/` and `plugins/` (each plugin with its own PHPCS
  ruleset), and checks that the plugins and the tools (`bin/`, `tools/`, the workflows, the shared
  compose file and settings example)
  name nothing of this site (`site.json`'s `namesSharedCodeMustNotUse`) and that each plugin declares
  `Update URI: false`; every script in `bin/` executable; `theme.json`'s schema matching
  the pinned WordPress; Stylelint over every CSS file in `themes/` and `plugins/` (its standard
  rules plus WordPress's formatting, `tools/css-lint/`, plan D29), with an npm audit of its
  packages (every advisory fails, except any the user accepted in that folder's
  `audit-exceptions.json`, each with its reason and a review-by date after which it fails again,
  and an accepted one that npm no longer reports also fails; none accepted since 2026-11-20); the theme's component list in `functions.php` matching the files in
  `assets/css/components/`, both ways; every design token the component stylesheets and
  `theme.json` read defined in `theme.json` (`tools/theme-tokens.sh`, and that check on known
  examples, `tests/tools/theme-tokens/`, template plan 1.6b); the starter (`starter/`) held to
  the same rules: its `site.json` and pages, its `theme.json` schema and tokens, exactly the
  site-layer files of `tools/site-layer-files.txt` (`tools/site-layer.sh`, with its examples in
  `tests/tools/site-layer/`), none of this site's names but the prefix, PHPCS and PHPStan; the
  theme assembly on known examples (`tools/site-theme.sh`, `tests/tools/site-theme/`); the dev-site
  guard on known examples, with a stand-in for docker (`tests/tools/dev-site-guard/`); a type check and ESLint of the theme's browser scripts (`assets/js/`), with
  `tools/js-check/`'s own packages (template plan 1.7: typescript-eslint's strict rules and
  WordPress's JavaScript layout, zero findings; its TypeScript 6, which typescript-eslint supports),
  and an npm audit of them; and every `site-…` component shown on the components' example page
  (`tests/e2e/specs/dev/components/pages/`, built by `bin/dev-site` at `/component-examples/`,
  outside the menu, template plan T10) or in a template part (so the browser tests see it); `site.json` following the rules in
  `tools/site-settings.jq` (a missing or unknown field, or a wrong kind of value, fails and is
  named), every field explained in `tools/site-settings.md` and nothing else, and those checks
  refusing the broken examples in `tests/tools/site-settings/`; the versions check's alerts on
  known situations (`tests/tools/versions-check/`: the real script against stand-ins for GitHub
  and WordPress.org, which issues it would open, template plan 1.3c); the page check on known
  situations (`tests/tools/site-check/`: `bin/site-check` against a stand-in site, 1.4b); the
  deploy's checks on known situations (`tests/tools/deploy/`: `bin/deploy` in a throwaway Git
  repository against stand-ins for GitHub, the servers, the Composer build and WordPress.org's
  checksums, 1.4d-1, 1.4d-2); the routines' links to their site details, and that check on
  known examples (`tests/tools/routines/`, 1.5c); the status sheet (`records/status.md`) answering
  every item of the blank (`tools/status-sheet-blank.md`: done or exception, with its check or
  reason and a date, its recorded exceptions there, every file it names still in the repository),
  and that check on known examples (`tests/tools/status-sheet/`, 1.5d-4); ShellCheck on `bin/`, the
  scenario checks and the tools' tests; the compose file. Runs every check even
  after a failure; exit status 1 if any failed. The review gate starts with it. The tool
  containers see only the files their step needs, never `.env`, `db/`, `backups/` or
  `wordpress/`; `composer.lock` is read-only to them.
- GitHub runs `bin/check` and the dev site's tests on every pull request, weekly and by the "Run
  workflow" button (`.github/workflows/check.yml`); a pull request merges only when both pass and
  it is up to date with `main`. A merge deploys nothing: the user deploys with `bin/deploy`
  (template plan 1.4e removed GitHub's staging deploy, its key and its environment).
- `site-packages/`: the downloaded plugins the site runs (template plan T8), WordPress.org's
  through WPackagist, at exact versions in `composer.json`, with `composer.lock` recording the
  download addresses (all on `downloads.wordpress.org`, which `bin/check` and `bin/dev-site`
  require). Separate from the top-level `composer.json`, which holds only the code-checking tools.
  Dependabot proposes the plugins' updates weekly, a release at least 7 days old, in one pull
  request (`.github/dependabot.yml`), which merges itself by rebase once its checks pass
  (`.github/workflows/plugin-updates.yml`, template plan T9: only Dependabot's pull requests into
  `main` changing nothing but `site-packages/`, and in its lock file nothing but WordPress.org
  plugins; it runs `main`'s own code, never the pull request's). Updates to
  `composer/installers` and to the tools wait for the user's review. A merge
  done this way starts no run on `main` (GitHub does not start workflows from its own token's
  merges); nothing needs one: `bin/deploy` accepts a commit whose pull request's last commit
  passed with the same files, and the weekly run checks `main`. Staging and live get a new
  version only when the user deploys it with `bin/deploy`, in the monthly check
  (`docs/ROUTINES.md`). WPackagist is needed only to change
  a version: installing from the lock file goes straight to WordPress.org.
- `bin/versions-check`: compares the dev site's pinned parent theme (`tools/versions.sh`) with
  WordPress.org and reports whether it is behind, changing nothing. Every Monday GitHub runs it
  with `--act` (`.github/workflows/versions.yml`, plan 8j), which opens an issue for a theme
  release at least 7 days old; its pin holds a fingerprint taken by hand, so it is raised in a
  session. It also watches the plugin updates (template plan T9): an issue for one still open
  after 3 days (its checks failed, or it fell behind `main` and waits for a comment
  `@dependabot rebase`), and
  for a plugin release 14 days old that Dependabot never proposed. And (1.4d-4) it compares the
  deploy test server's `openssh-server` and `rsync` (`tools/versions.sh`) with Alpine's package
  list for the pinned image's branch: Alpine keeps only each package's newest version, so a
  replaced one gets an issue at once, raised in a session without the 7-day wait (waiting cannot
  keep the old version; apk checks Alpine's signature on every package). GitHub emails the owner about
  new issues; one with the same title is never opened twice. The workflow can read the repository
  and its pull requests and open issues, nothing more.
- `bin/deploy staging|live [--commit <commit>] [--allow-lower <plugin>]... [--ssh-config <file>]`
  (template plan 1.4, T11; handbook chapter 2), run by the user from this computer, the way every
  change reaches staging and live since 2026-11-22 (1.4e; `docs/ROUTINES.md`, "Deploying"). It
  refuses unless the working copy is clean, the commit is on GitHub's `main`
  and its required checks (`check`, `dev-site`) passed on it or on its merged pull request's last
  commit with the same files, and on live unless staging runs that commit; it reads the place's
  note on the server and shows the commits arriving or taken away. Before asking "yes", it exports
  the commit, builds its downloaded plugins from its `composer.lock` (the pinned Composer
  container) and checks every file against WordPress.org's checksum file (a changed or added
  file refuses; one listed but missing from the download is shown, not refused, as WP-CLI's
  check on the dev site does, 1.5b), checks each folder
  exists on the server for the key, and refuses to lower a downloaded plugin the host updated
  unless `--allow-lower` names it. After "yes" it copies the downloaded plugins, the site's own
  plugins and the theme, each folder made exactly the commit's, then writes the note, and names
  any folder that was empty there (to activate by hand). Then the page check
  (`bin/site-check`; failing, it fails the deploy and names the way back, `--commit` with the
  commit the place ran before), given a place's password login from `.env`
  (`<PLACE>_CHECK_USER`, `<PLACE>_CHECK_PASSWORD`, read by exact name), and the PHP log's lines
  added since before the copy (read through the read-only `php-log` folder; shown, not failing).
  One deploy of a site at a time on the computer (a `flock` lock in its temporary folder). The
  places come from `site.json`'s `deploy` section. Its test against a real throwaway server is the
  scenario check `dev-deploy-server.sh`: an Alpine container (pinned in `tools/versions.sh`) set
  up like the host, the real `ssh` and `rsync`, and probes that each key opens no shell, cannot
  write the log or climb out of its folders, and that an unknown key is refused at once. Unlike the other scripts it uses programs on the
  user's computer besides Docker and `jq`: `git`, `gh` (logged in), `rsync`, `ssh`, `curl` and `flock`;
  `ssh` never asks for a password (`BatchMode`), so a key that does not work stops it. On the
  server, each place has its own key, made on the user's computer with a passphrase and unlocked
  with `ssh-add`, forced in `~/.ssh/authorized_keys` into rsync's daemon mode with that place's
  settings file in `~/.deploy/` (`rsyncd-hbmusic-<place>.conf`: the theme's and plugins' folders,
  the `deploy-note` folder and the read-only `php-log`), named `hbmusic-staging` and
  `hbmusic-live` in the user's SSH settings.
- `bin/site-check [--deadline <seconds>] [--retry-every <seconds>] [--print-pages] <address>` (template plan
  1.4b, handbook chapter 2's step 7): every published page of the site at the address, from
  WordPress's page list, and the site's root, answers 200 directly, shows the child theme named
  in `site.json` active and ends with `</html>`; failing pages are tried again for up to 2
  minutes, and an unusable or empty page list fails. Only pages at that address are opened. A
  site behind a site-wide password gets its login from `SITE_CHECK_USER` and
  `SITE_CHECK_PASSWORD`, refused over plain `http://` except to this computer. Needs `curl` and
  `jq`. Run by
  `bin/deploy` after a copy (1.4d) and, against the dev site, by the scenario check
  `dev-site-check.sh` (which also switches the parent theme on and expects it to fail).
  `--print-pages` prints the pages checked, once all passed, for `bin/accessibility-scan`.
- `bin/accessibility-scan <address>` (template plan 1.5d-3; handbook chapter 12, 7.1 and 7.4):
  every page the page check finds answering at the address, at desktop and phone width, in the
  pinned Playwright container with its own config (`tests/e2e/accessibility-scan.config.ts`,
  `tests/e2e/accessibility-scan/`; `bin/test` never runs it): no axe error at WCAG 2.2 AA (the
  tests' own `WCAG_TAGS`) and no image without alt text. Run against live in the monthly check
  (`docs/ROUTINES.md`, step 13), since the content edited there is never tested otherwise; staging
  through `SITE_CHECK_USER` and `SITE_CHECK_PASSWORD`. Its test against the dev site is the
  scenario check `dev-accessibility-scan.sh` (a published probe page with an image without alt
  text must fail it).
- `bin/screenshots previews | baseline | compare` (plan D29): a before/after check of the look with
  the real content, for restyling; local only, never a gate. It shows each real page from
  `data/content/` (listed in its `pages.json`; photos written `{{photo:<file>}}` from
  `data/photos/web/`) on the dev site at `/preview-<slug>/`, beside the stand-ins, shoots every
  page at desktop and phone width with Playwright's own comparison, and lists what changed
  since the baseline, with marked images in `screenshots/` (ignored by git). Outside services
  are answered locally; a page that does not answer 200 fails. Whether a change looks right is
  the user's call.
- `bin/tools-update`: the deliberate way to update the tools, `composer.lock`,
  `tests/e2e/package-lock.json`, `tools/css-lint/package-lock.json` and
  `tools/js-check/package-lock.json` (npm only from releases
  at least 7 days old, install scripts off); then `bin/check`, review the lock files' diff,
  commit.
- `tools/versions.sh`: the one place for the images and downloads these scripts use (the parent
  theme with its SHA-256); `bin/check` fails if the Playwright image and `@playwright/test`
  differ. npm installs run with `--ignore-scripts`. `tools/settings.sh`: the `.env` handling of
  `bin/dev-site`.
- `plugins/site-hardening/`: the security headers (Content-Security-Policy and the others,
  `docs/SITE_CHECKLIST.md` 3.2), XML-RPC refused, Application Passwords off, no version
  comments, no WordPress version in pages and feeds (0.3.0, handbook 12, 3.6) and no PHP version
  header (plan D26, 8k), HSTS for a year on HTTPS requests only and
  unfiltered HTML for Administrators only (handbook 12, 3.1 and 4.10), in a generic plugin that names nothing of this site, with its own prefix
  `sitehardening` and `phpcs.xml.dist`. It deploys like Song List. The policy's outside sources
  are this site's setting, added in the child theme's `functions.php`, each with its reason.

