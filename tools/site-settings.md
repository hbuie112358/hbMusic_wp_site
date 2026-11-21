# site.json: the site's facts

`site.json`, at the top of a site's repository, holds what the tools need to know about that
site: its name, its theme, its plugins and the pages its dev site is built with. The tools read
it instead of having any site's names written into them, so the same tools serve every site.

- It holds no secrets. Passwords and this computer's ports are in `.env`, which is never
  committed.
- `bin/check` refuses a `site.json` with a missing required field, a field it does not know (a
  typo) or a value of the wrong kind, and says which field. It also checks that every field is
  explained on this page, and that this page explains no field that no longer exists.
- A yes/no field that is left out means the usual case, so only the exceptions are written.
- The rules themselves are in `tools/site-settings.jq`; this page explains them.
- Steps of the dev site's build that only this site needs (sample data for one of its plugins,
  for example) are not settings: they go in `tests/dev-setup.sh`, which `bin/dev-site` runs last
  when it exists.

## The fields

### slug

A short name for the site, used to name the dev site's storage in Docker (its database and
download caches) and, from there, other names. Lower-case letters, digits and dashes only,
starting with a letter or digit, since Docker allows few characters in its names. Example:
`"my-site"`. Changing it gives the dev site new, empty storage and new caches; the old ones stay
until they are removed. The site's theme names its PHP constants after the slug too, in capitals
with dashes as underscores (`"my-site"` gives `MY_SITE_`), and `bin/check` finds the theme's
component list by that name (`MY_SITE_COMPONENT_STYLES`).

### devSiteTitle

The title of the local dev site, shown in its browser tab and admin. Example:
`"My Site (dev)"`. Changing it changes only the dev site; the live site's title is set
in its own admin.

### theme

The folder of the site's own theme under `themes/`. Example: `"my-site-child"`. It must match the
folder's name exactly, in lower-case letters, digits and dashes (a name, not a path); the dev site
activates this theme and the checks read it, and both stop at once if the folder is not there.

### localPlugins

The plugins kept in this repository, `plugins/<slug>/`, by their folder names (lower-case letters,
digits and dashes), in the order the dev site activates them. They are mounted read-only into the
dev site, so an edit shows at once: the scripts write those mounts into `compose.site.yaml` from
this list. A name without its folder stops `bin/check` and `bin/dev-site` at once.
Example: `["song-list", "site-hardening"]`; an empty list for a site with none. Downloaded
plugins (from WordPress.org, and later DTS's own) are not listed here but in
`site-packages/composer.json`, at their exact versions.

### testPages

The pages the dev site is built with, in menu order. Their content comes from
`tests/dev-content/<address>.html`, neutral sample text; the browser tests read this list and visit
each one. Adding a page here needs its content file too, or `bin/dev-site` stops at once.

### testPages[].title

The page's title, as the menu shows it. Example: `"Contact"`.

### testPages[].address

The page's address on the site, without slashes, which is also its content file's name.
Example: `"contact-us"` for `/contact-us/`.

### testPages[].pageTemplate

The page template the page uses, as the real page does, so templates are tested as the site uses
them. Left out: WordPress's default page template. Example:
`"page-with-call-to-action"`.

### testPages[].isFrontPage

`true` for the page shown at the site's home address. Left out: not the front page. One page
should have it.

### testPages[].isPrivacyPolicy

`true` for the page chosen in Settings → Privacy, which the footer's privacy link follows. Left
out: not the privacy page.

### testPages[].isInMenu

`false` for a page linked from elsewhere (the footer) but not from the menu. Left out: the page is
in the menu.

### namesSharedCodeMustNotUse

Words that must not appear in the code shared with other sites: the site's own names and its
host's. Shared code is the plugins and the tools (`bin/`, `tools/`, the GitHub workflows, the dev
site's shared recipe and settings example), which serve every site, so they must name nothing of
this one; `bin/check` searches them as plain text, without regard to case. Example:
`["my-site", "jane", "doe", "examplehost"]`.

### deploy

Where `bin/deploy` copies the site to: live, and staging where the site keeps one on its host.
Left out by a site that is not deployed yet; `bin/deploy` then refuses. It copies the downloaded
plugins (`site-packages/`), the site's own plugins (`localPlugins`) and the theme (`theme`), so
nothing here lists them. On the server, each place's SSH key may copy only into folders named
after what they hold (the theme's or plugin's folder name), plus `deploy-note` and `php-log`.
Where a site has staging, live accepts only the commit staging runs.

### deploy.pageCache

The host's page cache, which a deploy must clear so visitors get the new pages. `"none"` is the
only value for now: a host that keeps no copies of pages. A host with a cache the tools cannot
clear yet has no value, so its site is refused instead of a deploy leaving visitors the old
pages; the tools gain the value when such a site comes.

### deploy.live

The public site. Required in `deploy`.

### deploy.live.sshHost

The short name for the live server in the user's SSH settings (`~/.ssh/config`), which hold its
address, account, port and the live key; none of those is in the repository. Letters, digits,
dots, dashes and underscores. Example: `"my-site-live"`. Changing it needs the same name in the
SSH settings.

### deploy.live.address

The live site's root, which the page check opens after a deploy: `https://` and the host, nothing
after it, and never a login before it (`user:password@`): logins live in `.env`. Example:
`"https://example.com"`.

### deploy.live.isBehindPassword

`true` while the whole site is behind a password (a preview before launch); the page check then
logs in with `LIVE_CHECK_USER` and `LIVE_CHECK_PASSWORD` from `.env`. Left out: open to everyone.

### deploy.staging

The staging site on the host, where the site has one (a Shop site, or a recorded exception).
Left out: no staging; live is deployed straight from `main`.

### deploy.staging.sshHost

The short name for the staging server in the user's SSH settings, as for live, with its own key,
which can reach only staging's folders. It must differ from live's, or a deploy to staging would
land on live. Example: `"my-site-staging"`.

### deploy.staging.address

The staging site's root, as for live; it must differ from live's. Example:
`"https://staging.example.com"`.

### deploy.staging.isBehindPassword

`true` when staging is behind a site-wide password, as it usually is; the page check then logs in
with `STAGING_CHECK_USER` and `STAGING_CHECK_PASSWORD` from `.env`. Left out: open to everyone.
