# Template notes

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

What a template for further WordPress sites (D18) would have to set differently from this site,
and where it is set. One line per item, added by each step that touches one. Read when the
template project starts; until then, a list, not a to-do.

## The site's name and prefix

- `hbmusic-dev`, the Compose project name, and the dev site's mounts of the theme and the site's
  own plugins: written from `site.json` into `compose.site.yaml` by the scripts since template plan
  1.2f (`write_site_compose_file`); `compose.dev.yaml` is the same for every site. The database
  volume's name follows from the slug too (`load_site_volume_names`, 1.2d), and the scenario check
  `dev-settings-guard.sh` uses the same function.
- The dev site's title and test pages: `site.json` (`devSiteTitle`, `testPages`, since template
  plan 1.2b), their text in `tests/dev-content/`; the dev admin and Editor in `.env.example`
  (`DEV_*`); the browser tests read the same list from `site.json` (`TEST_PATHS` in
  `tests/e2e/specs/dev/helpers/test-pages.ts`, since 1.2g). The site's own extra build
  steps (here, the Song List's sample songs) go in `tests/dev-setup.sh`.
- The parent theme and its pinned fingerprint: `tools/versions.sh` (`PARENT_THEME_*`).
- `hbmusic`, the PHP prefix and text domain: `phpcs.xml.dist` (both), and every function and
  `@package` tag in the theme.
- The package names: `composer.json` (`hbmusic/site-tools`), `tests/e2e/package.json` and its
  lock file (`hbmusic-e2e`).
- The cache volumes (`hbmusic_composer_cache`, `hbmusic_npm_cache`): built from `site.json`'s
  `slug` since template plan 1.2d (`load_site_volume_names`), for every script that uses them.
- The theme folder: `themes/hbmusic-child/` and its line in `.gitignore`.
- The site's design and logo (plan D29, the site layer): `themes/hbmusic-child/theme.json` (the
  palette, the font, the frame's width as WordPress's `settings.layout.wideSize`, which page
  content, the header, the footer and the panels follow and never repeat, and every design token
  in `settings.custom`), `parts/`, `patterns/site-logo.php`
  and `assets/images/`; the neutral test pages' layouts in `tests/dev-content/` follow them. A new
  site changes these, not the component stylesheets; `bin/check` fails if its `theme.json` lacks a
  token the components read (template plan 1.6b).
- The site's facts as settings (template plan 1.6b, 2.4b-2, T31): `themes/hbmusic-child/site-facts.json`,
  its old addresses and their redirects, the organization's schema.org types, the areas served
  and the outside sources its Content-Security-Policy allows, each with its reason; and the
  guide's link example, translated text, in `includes/site-text.php`. A new site replaces both
  files; `functions.php` names no site.
- The stylesheet handles' prefix `hbmusic-` in `functions.php`, with the PHP prefix.
- The theme's picture in Appearance → Themes, `themes/hbmusic-child/screenshot.png` (1200x900,
  WordPress's recommended size): this site's Home page, shot from its dev preview
  (`bin/screenshots previews`, `/preview-home/`) with the site's real name in the header. A new
  site makes its own the same way, from its own Home page once its pages exist; the starter
  carries none (template plan T15).
- The theme's header in `themes/hbmusic-child/style.css`: its name ("Howard Buie Music") and
  description; the parent, text domain, versions and licence stay.

## Plugins

- A site chooses its plugins (plan D19). Its downloaded ones (WordPress.org's, later DTS's own)
  are listed at exact versions in `site-packages/composer.json`, with its lock file (template plan
  T8, 1.2c); Dependabot raises them. The ones it keeps itself are listed in `site.json`
  (`localPlugins`); each sits in `plugins/<name>/`, needs a line in `.gitignore`, a mount in
  `compose.dev.yaml`, its `phpcs.xml.dist` run in `bin/check`, and a folder of its name in each
  place's rsync settings on the server, created empty there before its first deploy (`bin/deploy`
  copies every plugin `site.json` and `site-packages/` list, template plan 1.4e).

- The booking form: `config/booking-form.txt`, `config/booking-form-mail.json` and `config/booking-form-messages.json` (its "sending failed" text points to the contact links below the form on this site's Book page), and Contact Form 7 in `site-packages/composer.json`.

- Site mail: a mail service through FluentSMTP (plan D24), set up per site with its own account, DNS records and retention rule; it works before a site is live, unlike Gmail through Google's API.
- Uptime monitoring (plan 8m): one HetrixTools account for every site, a monitor per live site
  (its address, a keyword from the site's title, expiry warnings 15 days ahead), a contact list
  and a category per customer; customers' sites move the account to the paid plan. Staging copies
  behind a site-wide password are not monitored.
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

- The component stylesheets, `themes/hbmusic-child/assets/css/components/` (plan D29, the generic
  layer): named by page structure (`site-hero`, `site-section`, `site-features`, `site-cta`,
  `site-panel`, `site-lead`, `site-carousel`, `site-media-placeholder`, buttons, forms), using only the tokens, so they fit any relatively
  static site without commerce; their loader `HBMUSIC_COMPONENT_STYLES` in `functions.php` (block
  → components) and `component-styles.spec.ts`. A subject's own styles go with the feature that
  brings them (the song table's in the Song List plugin). Every `site-…` component has a neutral
  example on the dev site's test pages, which `bin/check` enforces.
- Bands and panels (plan D29): every band of a page is a wide group (WordPress's wide alignment
  is the frame) naming only its component class; the class `site-panel` next to it draws it as a
  panel (`site-panel.css`: side margins, corners, the space between panels). A new kind of panel
  needs only the class. Generic.
- The call to action (plan D29): `parts/call-to-action.html` holds this site's wording (the site
  layer, like the header and footer); the templates `templates/page-with-call-to-action.html` and
  `templates/page-no-title-with-call-to-action.html` (Twenty Twenty-Five 1.5's "Page" and "Page
  No Title" with the part under the content, and the same bottom space) are generic. When the
  parent theme updates, its two templates are compared with these (`docs/SITE_SPECIFIC_ROUTINES.md`,
  "Plugins and theme").
- `theme.json`'s `customTemplates` and `templateParts` replace the parent's lists instead of
  adding to them: a child theme repeats the parent's entries (without the header's and footer's,
  WordPress renders them as plain `div`s), and compares them when the parent updates.
- Carousels (plan D29): any number per page and any number of slides; a heading directly above
  one names it for screen readers (`hbmusic_name_carousels_after_headings()` in `functions.php`),
  and the "Video carousel" pattern adds one with an optional, empty heading (dropped from the
  page if left empty). Each carousel is described for screen readers as a carousel of "n of m"
  slides. Generic; the pattern's label "Videos" suits a site whose carousels hold videos.
- Media & Text (plan 9t-3): `media-text.css` lines the block's text up with the page's edge (no padding on its outer side, none on a phone) and, on a phone, puts the text before a picture on the right, in reading order. Generic for any site using the block.
- The menu's close-on-tap script (plan 9t-5): `assets/js/menu-close-outside.js`, loaded with the navigation block by `hbmusic_enqueue_menu_close_script()`; generic for any site using WordPress's hamburger menu, since Safari otherwise leaves it open on a tap beside it.
- Click-to-load videos (plan 9v): `includes/video-facade.php`, `assets/js/video-facade.js` and `video-facade.css` turn every YouTube player in a page's content into its picture (fetched into the uploads folder when a page is saved) and a play button, loading YouTube's privacy-enhanced player only on play; generic for any site with YouTube embeds (handbook 12, 8.5). The privacy policy uses the handbook model's `videos` block with it.
- The video script (plan D29): `assets/js/video-pause.js` with its loading and YouTube's command
  switch in `functions.php`; generic for any site with YouTube embeds. The theme's scripts are
  script modules (template plan 1.7); what the two video scripts share is
  `assets/js/video-shared.js`, the module `@dts-site-components/video-shared`, named for the
  components plugin once planned for 2.3 (not built for now, T29); the name stays.
- The carousel's slide width token (`custom.carousel.slideWidth`) is in container units (`cqi`),
  which mean the carousel's own width only inside it; it is not a general-purpose length.
- A comfortable line length for text: an inner group whose content width is the measure token,
  justified left (no CSS needed; WordPress generates the rule). The example is in
  `tests/dev-content/home.html`; in a block comment, `--` is written `--`, as WordPress's
  editor saves it.
- `bin/screenshots` (plan D29), the before/after check for restyling, generic by convention: each
  site's page builder writes one file per page into its `data/content/`, a `pages.json` listing
  them (slug, title, template, file), and photos as `{{photo:<file>}}` from `data/photos/web/`;
  the import file for the real site leaves those photos empty, to be chosen in its Media Library.
  Its parts: `tests/e2e/screenshots.config.ts`, `tests/e2e/screenshots/`, and the scenario check
  with its neutral fixture.
- The sticky header and the menu's current-page mark (plan D29): `site-header.css` and
  `hbmusic_mark_current_menu_link()` in `functions.php` are generic (any menu of addresses); the
  logo sizes and header colours are tokens in `theme.json`.
- The texture (plan D29): `texture.css` and `assets/images/grain.png` (neutral white specks) are
  generic; the stage light's colour is a token. A hero photo on a dark page works best as a
  cut-out with transparency; `make_cutout.py` (kept with this site's photos) makes one from a
  photo on pure black.
- The carousel (plan D29): `site-carousel.css` is generic; a site's content uses it as a group with
  the class `site-carousel`, as a `section` with an `aria-label` and WordPress's wide alignment,
  each direct child a slide (`carousel()` in this site's page builder).
- The CSS linter, `tools/css-lint/` (its package, lock file and `stylelint.config.mjs`, plan
  D29): it lints every theme's and plugin's CSS and names nothing of a site. The package name
  `site-css-lint` is neutral already.
- `bin/check`, `bin/test`, `bin/tools-update`, `tools/versions.sh` (apart from the names above),
  `.github/workflows/check.yml`, `.github/dependabot.yml`, the allow-list `.gitignore`.
- The plugin updates (template plan T8, T9): `site-packages/` with Dependabot's weekly group,
  `.github/workflows/plugin-updates.yml` (auto-merge for Dependabot's `site-packages/` pull
  requests that change only WordPress.org plugins; a recorded exception to the AI security rules'
  line-by-line reading of lock files, T9) and the versions check's two alerts (a waiting update, an update never proposed); the
  repository needs GitHub's "Allow auto-merge" setting on. Generic for any site.
- The weekly versions check (plan 8j): `bin/versions-check` and `.github/workflows/versions.yml` are generic;
  the list `PINS` at the top of the script names each site's pinned plugins and theme. Kept for
  many sites, where checking every site's Plugins page by eye does not scale.
- `plugins/site-hardening/` (plan D26) as it is; each site adds its own outside sources, with
  their reasons, through the `sitehardening_csp_sources` filter in its theme. WordPress's emoji
  script is switched off by Site Hardening itself since its 0.4.0 (template plan T29), no longer
  by the theme.
- `docs/SITE_CHECKLIST.md`, on its way to a shared `~/.claude/WORDPRESS_STANDARDS.md` (D16).
- The old-address redirects (plan D22, 8h): the function in the theme's `functions.php` is generic;
  the list `HBMUSIC_OLD_ADDRESSES` is the site's, empty for a new site, filled for a moved one.
- The page data's organization (8h): `hbmusic_describe_organization()` in the theme writes the
  type (`MusicGroup` here; a plumber's site would use another schema.org type) and the list
  `HBMUSIC_AREAS_SERVED`, both the site's; the dev site's stand-in organization in `bin/dev-site`
  (`DEV_ORGANIZATION_NAME`) is generic.

## A new site's records

A new site's `records/` starts with `README.md` alone (template plan 1.5a): this site's
`records/README.md` without its last section, "This site". Each record is created when the site
first has something to write in it. The settings and hosting records start in the private
records folder only where the site's repository is public.

## A new site's status sheet

A new site copies `tools/status-sheet-blank.md` to `records/status.md` when it starts its status
sheet (chapter 7's step 6, at launch), with `records/exceptions.md` and `records/plugin-set.md`
beside it; until then `bin/check` says the sheet is not started, and from then on fails on any
item unanswered (template plan 1.5d-4). Most answers come from the tests (named by their files),
the rest from checks on live from outside and the user's few admin, hPanel and server checks.

## A new site's routines

A new site gets `docs/ROUTINES.md` unchanged (template plan 1.5c) and a blank
`docs/SITE_SPECIFIC_ROUTINES.md`: this site's file with each heading kept and its text replaced
by what the heading asks for, filled in as the site is set up (chapter 7's step 6). `bin/check`
then fails on a heading removed or renamed. When `ROUTINES.md` moves into the starter (2.4), its
history references to this site's plans (rebuild plan D27, 8j, 1e, 9v) are kept as the reasons
behind each step, or moved into the handbook if they read as this site's.

## Tests a new site starts with

Decided at template plan 1.3d (2026-11-21, T10): a new site starts with the tests that come with
its pieces and writes few of its own.

- **Generic tests** (with the tools; `tests/e2e/specs/dev/generic/`, `tests/scenario/generic/`):
  every site, unchanged. They run on every page in `site.json`'s `testPages`: the security
  headers, no CSP violation, no axe error at WCAG 2.2 AA, the links between pages, the logged-in
  view, no PHP notices, the empty debug log. The booking form's and Yoast's tests come with the
  handbook's standard plugins (chapter 3); a site without one of them is the open point in
  template plan 2.1.
- **Component tests** (with the components; `components/`): every site, unchanged. They find
  their pages by the component's class and also run on the components' example page. The site's
  test pages in `tests/dev-content/` use real blocks, never stand-ins (T10), so the tests see the
  components with the site's own look around them.
- **Plugin tests** (with each plugin; `plugins/<plugin>/`): for the plugins the site uses: Site
  Hardening and Editing Help on every site (handbook chapter 3), Song List only where it is used.
- **Site tests** (browser specs in the site's own `tests/browser/`, which the tools mount beside
  the shared specs, template plan T19): none at the start. One is written only for code or settings the site
  adds itself: an old-address list (a moved site; this site's `redirects.spec.ts` is the model), an
  addition to the page data (`organization.spec.ts`), its own build steps in `tests/dev-setup.sh`.
  A site test checks facts, never the pages' wording, and is shown failing on a planted fault
  before it counts.

## To build in

- **WordPress's own JavaScript checks, with the first block or React work** (the user,
  2026-11-24): `@wordpress/scripts`, WordPress's build tool, brings `@wordpress/eslint-plugin`
  configured; it then replaces the WordPress layout rules in `tools/js-check/eslint.config.mjs`.
  Not added for the theme's three small scripts: it brings rules and packages for React, tests
  and builds.
- `~/.claude/CLIENT_DATA.md` (not implemented yet): the template includes its settings block, so
  every customer project starts with it.
- The frame in the code (plan 1e, 2026-11-16; settled 2026-11-17): the frame (header, footer,
  call-to-action panel, page templates, site-wide styles) lives in the code. No lock is built
  while only Administrators (DTS) can reach the Site Editor, which is so for Editors (no
  `edit_theme_options`); the monthly check looks for saved copies instead. **If an arrangement
  ever lets customers reach the frame** (an Administrator login, or a role with
  `edit_theme_options`), one of the two designs worked out on 2026-11-17 is built:
  - **The lock:** a separate "Frame Lock" plugin. Through `rest_endpoints`, it wraps the
    permission check of every saving method served by WordPress's template, template-autosave,
    global-styles, font-family and font-face controllers (matched by controller class, not
    address), so a save is a 403 and the REST Allow header leaves the method out. Reset (a
    template's DELETE), deleting an installed font and menus stay allowed. `edit_css` is denied
    through `map_meta_cap`. A constant in `wp-config.php` switches it off; a notice in the Site
    Editor and the page editor; a Site Health test listing saved copies; and a tripwire test
    requiring every route of those controllers to refuse saving, so a WordPress update that
    adds one fails when its pin is raised. Not capabilities alone: WordPress 7.1.4's template
    endpoints check `edit_theme_options` directly, not the post type's capabilities. To verify
    in the build: whether the Site Editor's interface honors the Allow header.
  - **Warn and log, lighter:** a confirmation in the Site Editor before a frame change is
    saved (with the reminder that fixing a broken frame is paid work, by the service
    agreement), each confirmation and save logged in the activity log, and the same Site Health
    test.
  The two features below let customers make the changes they reasonably want without reaching
  the frame:
  - **A menu built from the pages, automatically** (the user, 2026-11-16): customers who add or
    rename a page see the menu follow, with the order set in each page's settings, which Editors
    may change; pages such as the Privacy Policy left out by the theme. WordPress's own page-list
    menu does the listing; a link to something other than a page stays a request to DTS.
  - **The call-to-action panel's wording editable by customers** (the user, 2026-11-16): its
    heading, sentence and button label bound to a small settings screen that Editors may use,
    so the panel's design stays in the code. Through WordPress's block bindings (since 6.5),
    once it is confirmed they work this way in the version then in use.
  - **A "Site Manager" role** (the user, 2026-11-16, name chosen by the user: so customers need
    not ask DTS every time they add a user). The rule: everything except what changes code,
    updates or site-wide settings, which DTS looks after under "Content by customer".
    - Given: everything an Editor may do; managing users (`create_users`, `list_users`,
      `edit_users`), only Editors and Authors; exporting content (`export`); reading Site Health;
      plugins' read-only screens where a plugin allows it (checked one by one).
    - Held back: plugins and themes (install, activate, update, delete), the Site Editor and
      menus (`edit_theme_options`), WordPress updates (H10), site settings (`manage_options`),
      security settings (Wordfence), unfiltered HTML (H79), making Administrators or editing or
      deleting an Administrator's account (WordPress's `editable_roles` filter and the
      user-editing capability checks), and the booking form's and the SEO plugin's site-wide
      settings. The plugins' exact capability names are read in their code when the role is
      built, not assumed.
    - Defined in a DTS plugin, tested on the dev site with planted faults (the role trying to
      make someone an Administrator, or to reach a held-back screen, refused). A handbook
      proposal for chapter 6 (access and roles, H24) when it is built.
