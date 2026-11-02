# Rebuild plan

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Rebuilding the site on a Twenty Twenty-Five child theme, then moving it to a new host. Worked
in rolling-wave mode (`~/.claude/ROLLING_WAVE_MODE.md`): near steps in detail, later ones rough,
new findings added as steps.

## Current position

- **Where the work stands:** steps 0, 1 and 2 done. The old site is still live at the former host,
  now secured (step 0). No theme work yet.
- **Finding:** the live site's email is unreliable (a confirmation sent on 2026-11-02 never
  arrived; cause not known). The new site gets an authenticated mail service (step 8), working
  before the request form (5b) goes live.
- **Finding:** Wordfence's login log (2025-01 to 2026-10-31) shows about 1,360 failed attempts,
  155 with the real login name, and no successful login except the user's own on 2025-01-09: no
  sign of a break-in through the login.
- **Next:** step 2b, the content and design session, starting from the checklist at the end of
  [findings/step-02-inventory.md](findings/step-02-inventory.md).
- **Order of the coming steps:** 2 → 2b → 3 → 4 → 5 (5a-5c); 6-9 are rough.
- **Open decisions waiting on the user:**
  - how best practices are listed and handled, per the prompt the user is bringing from another
    project (`docs/BEST_PRACTICES.md` is a draft until then);
  - the local environment (step 3); the new host (step 8).
- **Stale documents:** none.

## Decisions

| # | Decision | Why |
|---|---|---|
| D1 | The new theme is a child theme of Twenty Twenty-Five, in `themes/hbmusic-child/`. | `music-lite` is unmaintained; Twenty Twenty-Five is a maintained default theme, and a child theme keeps the site's changes apart from its updates. |
| D2 | `backups/` and `wordpress/` are never changed; experiments run on copies. | They are the only full copy of the old site. |
| D3 | Git versions an allow-list only (see `.gitignore`). | The export holds credentials, database dumps and host account identifiers. |
| D4 | The export's local leftovers (open item 1) are not carried to the new host. | They are local development files, not part of the site. |
| D5 | Commits use the GitHub noreply address, set for this repository only. | Keeps the personal email address out of the history. |
| D6 | The site's domain may appear in notes and plans (`CLAUDE.md`, the plan, `project-state.yaml`). | The domain is public; leaving it out protects nothing. Secrets, dumps, host account numbers and server paths stay out of the repository. |
| D7 | Theme code never hardcodes the domain; it asks WordPress (`home_url()`, `get_theme_file_uri()` and similar). | The same theme then runs unchanged locally, on staging and live; a hardcoded domain breaks on every move. Server settings that name the domain live on the server, not in the repository. |
| D8 | Song clips go out only on request, approved with one click by the user (not sent automatically, not published). Fully automatic sending is a possible later change, needing an email confirmation step, limits per address and per day, and spam protection. | The user sees every request (which songs a prospective client wants), bots and forged addresses cannot make the site send mail to strangers, and clips are not handed to unknown people, which keeps the licensing question small. |

## Steps

0. **Secure the old live site** (urgent while it is online; open item 1). Status: `[x]`
   - 0a. Admin account: new password, two-factor login, real email, only account. `[x]` 2026-11-02
   - 0b. Header-only check of the leftover paths: five returned 200 (zip with 73,947,771 bytes,
     `local.sql`, `local-site.json`, `conf/`, `logs/`); `local-xdebuginfo.php` returned 500.
     `[x]` 2026-11-02
   - 0c. The user deleted the six items in the host's File Manager; the check again returned 404
     for all, with the home and login pages still 200. `[x]` 2026-11-02
   - 0d. The live secret keys and salts match the exposed zip's `wp-config.php` (five of eight
     compared, all the same; the database login differs). The user replaced all eight with new
     ones from the WordPress.org generator; home and login pages still 200. The next login asked
     for no 2FA code: Wordfence's remember-device setting (on, 30 days) uses its own key, not the
     WordPress salts, so the remembered device stayed valid. `[x]` 2026-11-02
   - 0e. ~~The host's access logs, for downloads of the leftovers.~~ Dropped by the user
     (2026-11-02): everything the leftovers exposed was already treated as known to others and
     replaced, so the logs could not change any action; they also cover only a short recent
     period of an exposure that lasted since at least 2025-01.

1. **Project setup.** Layout, the project's `CLAUDE.md`, allow-list `.gitignore`,
   `project-state.yaml`, git. Status: `[x]` 92dd157
2. **Inventory the old site.** What `music-lite` shows (pages, menus, widgets, customizer
   settings, any shortcodes) and what `music-lite-child` changes (open item 4); the result is the
   list of what the new theme must cover. Needs only `db/` and `wordpress/`, no running site.
   Comes before step 3 because what it finds (plugins that must run, forms, embeds) shapes the
   environment. Findings: [findings/step-02-inventory.md](findings/step-02-inventory.md);
   `music-lite-child` is empty, so open item 4 is settled. Status: `[x]`
2b. **Content and design session.** First the content: what each page is for and what a visitor
   booking a musician needs to find fast, including the new request pages (5b clips, 5d setlist
   preferences, and how simple the 5d choices can be made). Then 2-3
   visual directions as clickable sample pages with the real content and photos, for the user to
   react to; the chosen one becomes the child theme's `theme.json`. *Why:* the user does not yet
   know what the site should look like, and choosing from real examples is easier than
   describing a look. Status: `[ ]`
3. **Local environment.** Choose how to run the site locally from `db/` and a copy of
   `wordpress/` (the database import needs the site URL replaced), and the test tools for each
   level of `TESTING_APPROACH.md`, covering what the step 2 inventory found. Includes a local
   mail catcher, so the request form's emails can be tested without sending real mail. Record
   them in the project's `CLAUDE.md`. Status: `[ ]`
4. **Child theme skeleton.** `themes/hbmusic-child/` with `style.css`, `theme.json`,
   `functions.php`, activated locally on a copy. Status: `[ ]`
5. **Rebuild the design and content** in the child theme from the step 2 inventory and the
   step 2b choices (rough; split further after 2b). Known parts:
   - 5a. **Songs as data.** A small site plugin (not the theme, so the songs survive a theme
     change) with a Song type: title, artist, genre and era (needed by 5d). Tagging the 108 songs: the era
     can be suggested from each song's release year for the user to check; the genre is the
     user's call. The 108 songs are
     converted from the current Songlist page, where titles and artists sit in two separate
     lists matched only by position. The Songlist page is built from the Song entries.
     *Why:* the user adds songs in the admin instead of editing page text. Status: `[ ]`
   - 5b. **Song requests (D8).** The Songlist has a checkbox per song and "select all"; a form
     (name, email, optional event date and message) sends the selection. Each request is stored
     in the admin with its songs and notifies the user; the user clicks "Approve and send", and
     the site emails the visitor links to those songs' clips that expire after a set time. Needs
     spam protection, a privacy policy page, and checked input with protection against forged
     submissions (`docs/BEST_PRACTICES.md` 6.4, 10.1, 10.3). The form tool is chosen at this
     step. Status: `[ ]`
   - 5c. **Private clips per song.** A short audio clip per song, stored where it cannot be
     reached by a plain URL, and served only through 5b's expiring links. Recording and the
     licensing question for cover recordings are the user's. Status: `[ ]`
   - 5d. **Setlist preferences for a gig.** A separate page from 5b, for someone booking the
     user: pick songs from the list they want played, and set the focus of the rest by genre,
     era or both (for example 40% country and 60% rock, or mostly older songs). Stored in the
     admin with the request, so the user sees what the client wants before planning the set.
     How to make it simple and self-explanatory (percentages, sliders, or a few choices) is
     worked out in step 2b. Uses the same form safeguards as 5b. *Why:* lets a client dial in
     the music they want, and gives the user the details before the conversation. Status: `[ ]`
6. **Plugins.** Keep, replace or drop `updraftplus`, `wordfence`, `wordpress-seo`; remove the
   former host's auto-updates plugin and mu-plugin (open item 3). Status: `[ ]`
7. **Staging install.** Decide whether `wordpress/staging/` is needed (open item 2).
   Status: `[ ]`
8. **Choose the new host** and how updates and backups run there, and the authenticated mail
   service with its DNS records (`docs/BEST_PRACTICES.md` 11.1, 11.2). The mail service must
   work before the request form (5b) goes live. Status: `[ ]`
9. **Migrate and go live,** without the local leftovers (open item 1); check afterwards that
   they cannot be downloaded. Also:
   - a new admin account on the new site with a login name that is not easy to guess (the old
     one is short and was in the exposed `local.sql`);
   - once the new site is live, close the former host's account: pointing the domain elsewhere
     leaves the old site, the staging install and both databases running there, unmaintained;
   - afterwards, check that the old copy is really gone, also through the host's own temporary
     address if it had one.
   Status: `[ ]`
