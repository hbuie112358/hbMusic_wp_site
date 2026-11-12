# Routines

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The recurring care the site needs, with what each step protects. Agreed with the user on
2026-11-10 (plan step 8). The user keeps a monthly calendar reminder: "Monthly site check, see
docs/ROUTINES.md".

## Making changes

The site lives in three places (the project's `CLAUDE.md`, Terms). In the terms of a company's
environments: the **dev site** with GitHub's checks is development and integration testing,
**staging** is pre-production, where changes are accepted, and **live** is production. Agreed with
the user on 2026-11-12 (plan D31, 9q).

**Code moves up; content is edited in production.** Code (the theme, the site's own plugins) never
changes on live: it is tried on the dev site, merged into `main`, deployed to staging by itself,
accepted there by the user, and only then deployed to live, the same code. Content (page text,
photos, videos, songs) is data, like the customer records of a business application: it is
entered straight on live and never sent up from staging. So the three kinds of change go like this:

| The change | Where | How |
|---|---|---|
| Content: a word, a paragraph, a photo, a video link, a song | live | The block editor. Revisions allow going back. After real changes, the content export (monthly check, step 4) |
| The look or behaviour: the theme, the carousel, the call to action, the site's own plugins | dev site → staging → live | In a session with Claude. Staging gets it by itself after the merge; the user looks there and approves the deploy to live |
| Updates of WordPress and other people's plugins | staging → live | The monthly check, step 6 |

A code change that needs a matching content change (such as a renamed class in the pages) is made
on staging's content to test it, and the same on live after the deploy; Claude says when this
applies. A larger rework of a page can also be built on live as a draft and seen with Preview,
without visitors seeing it.

**Staging's content drifts, and that is fine for small changes.** Before judging a major change to
the look on staging, its content is brought level with live's, so that the change is judged on
the real pages (their real lengths, blocks and pictures): see the next section.

## Refreshing staging's content from live (about 20 minutes)

When: once right after go-live (plan 9q), before a major change to the look, and whenever staging
has drifted far enough to mislead. It copies content only; staging keeps its own settings (the
site-wide password, mail, spam-protection keys, admin accounts, Wordfence). A copy of live's whole
database is deliberately not used: it would overwrite all of those and carry visitors' data into a
test site (the reasons of plan D30, the other way round).

*Provisional until plan 9q: the steps below are written from the go-live rehearsal's plan (9d)
and are confirmed or corrected with what 9d and 9q find.*

1. **Live:** Tools → Export → All content → Download Export File, into `data/exports/` named with
   the date. It counts as that month's content export (monthly check, step 4).
2. **Staging:** the pages, the songs and the menu moved to the trash, so their addresses are free
   for the imported ones.
3. **Staging:** WordPress's importer installed, Tools → Import → WordPress, live's export chosen,
   the content given to staging's admin, and "Download and import file attachments" ticked: live
   is public, so staging fetches the photos itself.
4. **Staging, checked:** each page at its own address (none ending in `-2`), with its template;
   Home as the front page (Settings → Reading); the menu; the Songs page; the booking form's Mail
   tab still sending as staging should.
5. **Staging:** the importer deleted, and the trash emptied.

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
7. **Log into HetrixTools** (the uptime monitor, plan 8m) and glance at the monitor: up, and the
   certificate and domain dates moving on after each renewal. A free account not logged into for
   90 days has its monitors stopped.

**What it protects:**
- Steps 1-2 prove the whole path a visitor's request takes (the form, FluentSMTP, Brevo, Gmail),
  which a failure alert alone cannot: a request Brevo accepts but does not deliver raises no
  alert.
- The test also uses Brevo's API key every month. The key expires after 90 days without use.
- Step 4 is the off-site copy D27 chose instead of a backup plugin: the content holds no keys or
  passwords, and the code is on GitHub.
- Step 6 keeps the site from falling behind: an old version stops getting fixes, and a later
  security fix may then come only in a newer version that "security updates only" skips.
- Step 7 keeps the uptime monitor running; without the login it stops silently after 90 days,
  apart from a warning email.

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

## When HetrixTools sends an alert

- **Site down:** open the site in a browser, on the phone's mobile data as well as at home.
  - It loads: a short blip or a problem between some networks and the site; the "back up" alert
    normally follows within minutes. If such alerts repeat, bring them to a session with Claude.
  - It does not load, or shows an error or a host's page: hPanel first (the website's status,
    and Hostinger's status page for outages), then Hostinger's support if the cause is theirs.
    If the site shows its pages but not the words "Howard Buie Music", the monitor's keyword
    failed: something replaced the page, which is looked at with Claude at once.
- **Certificate expires in 15 days:** Hostinger's automatic renewal failed. hPanel → the
  website → SSL shows the certificate's state; Hostinger's support renews it if hPanel cannot.
- **Domain expires in 15 days:** the automatic renewal failed, most often because of the payment
  card. hPanel → Domains → renew by hand, and check the card on the account.
- **Name servers changed** without the user changing them: the domain may have been taken over.
  Log into Hostinger (password changed if there is any doubt), check the domain's settings, and
  contact Hostinger's support at once.

## When GitHub proposes a new plugin version

Every Monday GitHub compares the dev site's pinned versions with WordPress.org (plan 8j). A
plugin released at least a week ago arrives as an email about a pull request, such as "raise
Contact Form 7 to 6.2.5". Nothing else is needed on the user's computer, and no session with
Claude:

1. Open the pull request from the email, or the repository's **Pull requests** tab on GitHub.
2. Click **Approve and run** on its page. GitHub holds the tests of a pull request that its own
   token opened until a person approves them (plan 8j chose this click over a stored key).
3. About 4 minutes later, **green ticks** for `check` and `dev-site`: the new version passed the
   dev site's tests.
4. **Rebase and merge**, then **Delete branch**. GitHub allows the merge only once the checks
   pass.
5. The new version reaches staging and live in the next monthly check (step 6), now as a tested
   one.

**Red crosses:** the new version breaks something the tests protect. Nothing is merged, and
staging and live stay on their version until it has been looked at with Claude.

**An issue about Twenty Twenty-Five** instead of a pull request: the theme's pin includes a
fingerprint taken by hand, so a new theme version is raised in a session with Claude. In that
session Claude also compares the new version's `templates/page.html` and
`templates/page-no-title.html` with the child theme's two "with call to action" templates (plan
D29), which add only the call-to-action part and the same bottom space, and the new version's
`templateParts` and `customTemplates` in its `theme.json` with the child's copies of those lists,
and carries any change over.

## When replacing a picture

A changed picture gets a **new file name** (for example `howard-buie-logo-2027.png`), never the old
name over the old file. Visitors' browsers keep pictures for up to 7 days (the server's
`cache-control`, plan 8l), so under the old name some visitors would still see the old picture
for a week. Pages, styles and scripts need nothing: they arrive fresh or carry a version in their
address.

Claude helps with any of these when the user brings the symptom to a session.
