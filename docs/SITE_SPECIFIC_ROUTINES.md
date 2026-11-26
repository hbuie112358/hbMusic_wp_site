# This site's routine details

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

What `docs/ROUTINES.md` leaves to each site: its places, accounts, addresses and its own
plugins and theme. `docs/ROUTINES.md` links to each heading below, and `bin/check` fails if a
link finds no heading here or a heading here has no link (template plan 1.5c). A new site starts
from a blank copy and fills in every heading. No secrets here: passwords and keys are in the
user's password notes, and the server's address is in the user's SSH settings.

## Places

- Live: `https://howardbuiemusic.com`.
- Staging: `https://staging.howardbuiemusic.com`, behind a site-wide password (the user's login
  and the page check's, `STAGING_CHECK_USER` in `.env`). Kept on the host as a recorded exception
  (the project's `CLAUDE.md`, "Handbook").

## Deploy keys

`ssh-add -q ~/.ssh/hbmusic-staging-deploy ~/.ssh/hbmusic-live-deploy`, named `hbmusic-staging`
and `hbmusic-live` in the user's SSH settings; the passphrases are in the user's password notes.

## Host

Hostinger (hPanel), prepaid through 2028 (the project's `CLAUDE.md`, "Handbook").

- **Updates:** Hostinger's Smart auto-updates install security updates only, for WordPress,
  themes and plugins, on both sites (rebuild plan 8j).
- **Backups:** daily, kept at Hostinger; 7 daily and 7 weekly copies on the Business plan, so none
  older than 60 days (Hostinger's assistant, 2026-11-15). The content export is the off-site copy
  (rebuild plan D27).
- **Browser caching:** pictures are kept by visitors' browsers for up to 7 days (the server's
  `cache-control`, rebuild plan 8l); the CDN on live keeps no copies of pages.
- **Where to look when the site is down:** hPanel, the website's status, and Hostinger's status
  page; then Hostinger's support.
- **Certificate:** hPanel → the website → SSL. **Domain:** hPanel → Domains (renewal and the
  payment card).

## Mail

- Sender: `website@howardbuiemusic.com`, through Brevo (an account of the user's) with each
  place's own API key in FluentSMTP.
- Booking requests arrive in the business Gmail inbox, filtered by
  `from:website@howardbuiemusic.com` (never spam, label "Booking requests").
- Brevo keeps its delivery record for 3 months; whether it can be deleted earlier, and where in
  Brevo, is still to be found (the handbook's chapter 10, H56, says it is deleted there).
- Brevo's Authorized IPs hold the server's IPv4 and IPv6 addresses (the settings record).

## Booking form

The Book page, `/hire-acoustic-guitarist/` (Contact Form 7).

## Uptime monitor

HetrixTools, on one account for the user's own sites, alerts by Pushover. The monitor's keyword
is "Howard Buie Music". Staging has no monitor: its site-wide password would fail every check.

## Plugins and theme

- **Delivered by `bin/deploy`** (pinned in `site-packages/composer.json`): Contact Form 7, Yoast
  SEO, Simple History; DTS's plugins (Song List, Site Hardening, Editing Help, each from its own
  repository by release tag); and the site's own child theme.
- **Updated by hand, staging first:** WordPress, Twenty Twenty-Five (tested by the dev site when
  it matches `PARENT_THEME_VERSION` in the tools' `tools/versions.sh`, in `dts-site-tools`),
  Wordfence, FluentSMTP.
- **When Twenty Twenty-Five is raised:** Claude compares its `templates/page.html` and
  `templates/page-no-title.html` with the child theme's two "with call to action" templates
  (rebuild plan D29), which add only the call-to-action part and the same bottom space, and its
  `templateParts` and `customTemplates` in `theme.json` with the child's copies, and carries any
  change over.

## Theme frame

Under Templates: the three page templates; under Patterns → Template parts: Header, Footer and
the call-to-action panel.

## Site Health

Known recommendations on live, nothing to do: inactive themes (until rebuild plan 9n removes
them); a persistent object cache and a page cache (declined, rebuild plan 0f and 8l).

## Expected set

- **Plugins, must-use files, themes and accounts:** `records/plugin-set.md` (template plan
  1.5d-2). Read with `wp plugin list` and `wp theme list` and the `wp-content/mu-plugins/`
  folder over the password login (below), or in the admin (Plugins, with its Must-Use tab;
  Appearance → Themes; Users).
- **Server SSH keys** (`~/.ssh/authorized_keys`): the two deploy keys, each forced into rsync's
  daemon mode with its own place's settings, and the backups `authorized_keys.before-1.4e` and
  `.before-step-10` beside it. Read over the user's password login, the way the user opens a
  shell on the server: `ssh -o PubkeyAuthentication=no hbmusic-live cat .ssh/authorized_keys`
  (the password from the user's password notes). Tried by the user on 2026-11-23: the two
  deploy keys' lines and nothing else.

## Monthly report

None: the user's own site, with no customer. The uptime record is HetrixTools' own history.

## Staging content refresh

The steps in `docs/ROUTINES.md` were written from the go-live rehearsal's plan (rebuild plan 9d);
they are confirmed or corrected with what rebuild plan 9q finds.

## Video pictures

The click-to-load videos (rebuild plan 9v) keep their pictures in
`wp-content/uploads/hbmusic-video-pictures/`.
