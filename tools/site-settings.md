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

A short name for the site, in lower case, used to name the dev site's storage (its database and
download caches). Example: `"hbmusic"`. Changing it gives the dev site new, empty storage; the
old one stays until it is removed.

### devSiteTitle

The title of the local dev site, shown in its browser tab and admin. Example:
`"Howard Buie Music (dev)"`. Changing it changes only the dev site; the live site's title is set
in its own admin.

### theme

The folder of the site's own theme under `themes/`. Example: `"hbmusic-child"`. It must match the
folder's name exactly; the dev site activates this theme and the checks read it.

### plugins

The plugins the dev site installs and activates, in order. Each is a slug and where it comes
from. A plugin left out of this list is not installed on the dev site, so the tests do not see
it.

### plugins[].slug

The plugin's folder name, as WordPress knows it. Example: `"contact-form-7"`.

### plugins[].source

Where the plugin comes from:
- `"local"`: a folder in this repository, `plugins/<slug>/`, mounted read-only into the dev site;
- `"wordpress.org"`: downloaded from WordPress.org at the version pinned in `tools/versions.sh`,
  and checked against WordPress.org's checksums;
- `"dts"`: a pinned release of a DTS plugin, checked against its checksum (when the shared
  plugins exist).

### testPages

The pages the dev site is built with, in menu order. Their content comes from
`tests/dev-content/<address>.html`, neutral sample text; the browser tests visit each one.
Adding a page here needs its content file too.

### testPages[].title

The page's title, as the menu shows it. Example: `"Book"`.

### testPages[].address

The page's address on the site, without slashes, which is also its content file's name.
Example: `"hire-acoustic-guitarist"` for `/hire-acoustic-guitarist/`.

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

### namesPluginsMustNotUse

Words that must not appear anywhere in the plugins' code: the site's own names and its host's.
A plugin may be shared with other sites, so it must name nothing of this one. Example:
`["hbmusic", "howard", "buie", "hostinger"]`. Matched without regard to case.
