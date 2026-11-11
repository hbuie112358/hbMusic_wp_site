# Routines

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The recurring care the site needs, with what each step protects. Agreed with the user on
2026-11-10 (plan step 8). The user keeps a monthly calendar reminder: "Monthly site check, see
docs/ROUTINES.md".

## Monthly site check (about 10 minutes)

Until go-live, steps 1-3 run on staging; afterwards on live.

1. **Booking test:** on the Book page, send a request with the user's own name, an email address
   of the user's, and the message "monthly test".
2. **It arrives:** within a few minutes, in the business Gmail inbox, with the label "Booking
   requests". If not, see "If the test fails" below.
3. **Delete the test email.** Never click its "Unsubscribe" link or "Report spam": either one puts
   the address on Brevo's blocked list, and every booking request after that is dropped without
   any alert (plan step 8, "Brevo setup, where it stands").
4. **Content export (D27):** in the live site's admin, Tools → Export → All content → Download
   Export File. The file goes into the project's `data/exports/`, named with the date
   (for example `2026-12-01-content.xml`). The originals of new photos go into `data/photos/`.
5. **The data folder's off-computer copy** is brought up to date.
6. **Updates (plan 8j):** live's Plugins page (and Appearance → Themes, and Dashboard → Updates
   for WordPress itself). Hostinger installs only security updates; anything else waiting is
   installed by hand, **on staging first**: update there, open the pages and log in (with
   two-factor), and only then update live the same way and look at its pages. Both in the same
   sitting, and before updating live, its waiting version is checked to be the one staging just
   got: "Update now" always installs the newest release, so one published in between would reach
   live untried (it happened with Wordfence 9.1.1, plan 8j).

   **Has the dev site tested it?** The versions the dev site's tests ran are in
   [`tools/versions.sh`](https://github.com/hbuie112358/hbMusic_wp_site/blob/main/tools/versions.sh)
   (`CONTACT_FORM_7_VERSION`, `YOAST_SEO_VERSION`, `PARENT_THEME_VERSION` for Twenty Twenty-Five).
   For each update waiting on staging:
   - **The same version as there:** tested; update staging, then live.
   - **Newer than there:** not tested yet. Wait until the version there is raised and its tests
     pass, or ask Claude in a session to raise it and run the tests first.
   - **Not in that file** (Wordfence, FluentSMTP, which the dev site does not run): staging is the
     test, as above.

   A security fix Hostinger installs by itself does not wait for the dev site: closing a hole comes
   first, and the version in `tools/versions.sh` is raised to it afterwards.

**What it protects:**
- Steps 1-2 prove the whole path a visitor's request takes (the form, FluentSMTP, Brevo, Gmail),
  which a failure alert alone cannot: a request Brevo accepts but does not deliver raises no
  alert.
- The test also uses Brevo's API key every month. The key expires after 90 days without use.
- Step 4 is the off-site copy D27 chose instead of a backup plugin: the content holds no keys or
  passwords, and the code is on GitHub.
- Step 6 keeps the site from falling behind: an old version stops getting fixes, and a later
  security fix may then come only in a newer version that "security updates only" skips.

## If the test fails

- **A Pushover alert came:** sending failed. FluentSMTP → Email Logs shows the error, and the
  request can be resent from there once the cause is fixed. If Brevo refused the server's address,
  that address is authorised under Brevo's Security → Authorized IPs. The failed entry holds a
  visitor's details and is deleted once dealt with.
- **No alert and no email:** Brevo accepted the email but did not deliver it. Most likely the
  receiving address is on Brevo's blocked list for transactional email. Where Brevo lists it, to
  unblock the address, is still to be found on the real screen and written in here.
- **The email is in spam despite the filter:** it is marked "Not spam", and the Gmail filter
  (`from:website@howardbuiemusic.com`, never spam, label "Booking requests") is checked.

## When GitHub proposes a new plugin version

Every Monday GitHub compares the dev site's pinned versions with WordPress.org (plan 8j). A
plugin released at least a week ago arrives as an email about a pull request, such as "raise
Contact Form 7 to 6.2.5", and the tests run on it by themselves (a few minutes). Nothing else is
needed on the user's computer, and no session with Claude:

1. Open the pull request from the email, or the repository's **Pull requests** tab on GitHub.
2. **Green ticks** for `check` and `dev-site`: the new version passed the dev site's tests.
3. **Rebase and merge**, then **Delete branch**. GitHub allows the merge only once the checks
   pass.
4. The new version reaches staging and live in the next monthly check (step 6), now as a tested
   one.

**Red crosses:** the new version breaks something the tests protect. Nothing is merged, and
staging and live stay on their version until it has been looked at with Claude.

**An issue about Twenty Twenty-Five** instead of a pull request: the theme's pin includes a
fingerprint taken by hand, so a new theme version is raised in a session with Claude.

## When replacing a picture

A changed picture gets a **new file name** (for example `howard-buie-logo-2027.png`), never the old
name over the old file. Visitors' browsers keep pictures for up to 7 days (the server's
`cache-control`, plan 8l), so under the old name some visitors would still see the old picture
for a week. Pages, styles and scripts need nothing: they arrive fresh or carry a version in their
address.

Claude helps with any of these when the user brings the symptom to a session.
