# Rebuild plan

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

Rebuilding the site on a Twenty Twenty-Five child theme, then moving it to a new host. Worked
in rolling-wave mode (`~/.claude/ROLLING_WAVE_MODE.md`): near steps in detail, later ones rough,
new findings added as steps.

## Current position

- **Where the work stands:** project set up (step 1, 92dd157). No theme work yet.
- **The old site is still live at the former host,** so open item 1 (leftover files that may be
  downloadable: a database dump with the admin account, and a full site zip) is urgent.
- **Admin account secured on the live site (2026-11-02):** new password, verified by logging in;
  two-factor login active; the account's email set to the user's real address (directly in the
  database, because the confirmation email did not arrive); it is the only account.
- **Finding:** the live site's email is unreliable. A confirmation sent a year earlier arrived;
  the one sent on 2026-11-02 did not. The cause is not known. Plan step 6 or 9 gives the new site
  an authenticated mail service (`docs/BEST_PRACTICES.md` 11.1).
- **Step 0 done:** the leftovers were downloadable (200) and are now deleted (404); the live
  secret keys, the same as in the exposed zip, are replaced (0d); 0e dropped.
- **2FA confirmed:** a private window asks for the code (2026-11-02).
- **Next:** the open decisions below, then step 2 (or 3, if swapped).
- **Order of the coming steps:** 2 → 3 → 4 → 5; steps 6-9 are rough and get refined on the way.
- **Open decisions waiting on the user:**
  - whether to swap steps 2 and 3 (inventory before choosing the environment);
  - adding D7 to the project's `CLAUDE.md` (loaded every session; the plan only on resume);
  - how best practices are listed and handled, per the prompt the user is bringing from another
    project (`docs/BEST_PRACTICES.md` is a draft until then);
  - the local environment (step 2); the new host (step 8).
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
2. **Local environment.** Choose how to run the site locally from `db/` and a copy of
   `wordpress/` (the database import needs the site URL replaced), and the test tools for each
   level of `TESTING_APPROACH.md`. Record them in the project's `CLAUDE.md`. Status: `[ ]`
3. **Inventory the old site.** What `music-lite` shows (pages, menus, widgets, customizer
   settings, any shortcodes) and what `music-lite-child` changes (open item 4); the result is the
   list of what the new theme must cover. Status: `[ ]`
4. **Child theme skeleton.** `themes/hbmusic-child/` with `style.css`, `theme.json`,
   `functions.php`, activated locally on a copy. Status: `[ ]`
5. **Rebuild the design and content** in the child theme from the step 3 inventory (rough;
   split into steps after step 3). Status: `[ ]`
6. **Plugins.** Keep, replace or drop `updraftplus`, `wordfence`, `wordpress-seo`; remove the
   former host's auto-updates plugin and mu-plugin (open item 3). Status: `[ ]`
7. **Staging install.** Decide whether `wordpress/staging/` is needed (open item 2).
   Status: `[ ]`
8. **Choose the new host** and how updates and backups run there. Status: `[ ]`
9. **Migrate and go live,** without the local leftovers (open item 1); check afterwards that
   they cannot be downloaded. Also:
   - a new admin account on the new site with a login name that is not easy to guess (the old
     one is short and was in the exposed `local.sql`);
   - once the new site is live, close the former host's account: pointing the domain elsewhere
     leaves the old site, the staging install and both databases running there, unmaintained;
   - afterwards, check that the old copy is really gone, also through the host's own temporary
     address if it had one.
   Status: `[ ]`
