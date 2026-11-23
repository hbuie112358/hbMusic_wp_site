# Routines

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

The recurring care a DTS site needs, with what each step protects, the same for every site
(the handbook's chapters 2, 4, 5, 6 and 10; agreed with the user on 2026-11-10, rebuild plan step
8, and made generic at template plan 1.5c). Each site's own places, accounts, addresses, plugins
and theme are in [`SITE_SPECIFIC_ROUTINES.md`](SITE_SPECIFIC_ROUTINES.md), linked below as "site
details"; `bin/check` fails if a link finds no heading there, or a heading there has no link here.
The tools named without a link (Brevo with FluentSMTP, Contact Form 7 with Turnstile, HetrixTools,
Pushover, Wordfence) are the handbook's toolkit (chapter 3), the same on every site. The user keeps
a monthly calendar reminder: "Monthly site check, see docs/ROUTINES.md".

## Making changes

The site lives in three places (the project's `CLAUDE.md`, Terms; site details:
[Places](SITE_SPECIFIC_ROUTINES.md#places)). In the terms of a company's environments: the
**dev site** with GitHub's checks is development and integration testing, **staging** is
pre-production, where changes are accepted, and **live** is production. Agreed with the user on
2026-11-12 (rebuild plan D31, 9q).

**Code moves up; content is edited in production.** Code (the theme, the site's own plugins) never
changes on live: it is tried on the dev site, merged into `main`, deployed to staging by the
user (`bin/deploy staging`), accepted there, and only then deployed to live (`bin/deploy live`),
the same commit; `bin/deploy` refuses live any commit staging does not run. Content (page text,
photos, videos) is data, like the customer records of a business application: it is entered
straight on live and never sent up from staging. So the three kinds of change go like this:

| The change | Where | How |
|---|---|---|
| Content: a word, a paragraph, a photo, a video link | live | The block editor. Revisions allow going back. After real changes, the content export (monthly check, step 4) |
| The look or behavior: the theme, its components, the site's own plugins | dev site → staging → live | In a session with Claude. After the merge the user runs `bin/deploy staging`, looks there, then runs `bin/deploy live` (see "Deploying" below) |
| Updates of WordPress and other people's plugins | staging → live | The monthly check, step 6 |

A code change that needs a matching content change (such as a renamed class in the pages) is made
on staging's content to test it, and the same on live after the deploy; Claude says when this
applies. A larger rework of a page can also be built on live as a draft and seen with Preview,
without visitors seeing it.

**Staging's content drifts, and that is fine for small changes.** Before judging a major change to
the look on staging, its content is brought level with live's, so that the change is judged on
the real pages (their real lengths, blocks and pictures): see "Refreshing staging's content from
live" below.

## Deploying (`bin/deploy`)

From the user's computer, in the project's folder (template plan 1.4, the handbook's chapter 2).
After logging in to the computer, the deploy keys are unlocked once, with the passphrases from
the user's password notes (site details: [Deploy keys](SITE_SPECIFIC_ROUTINES.md#deploy-keys)).
Without that, `bin/deploy` stops at its first server step; it never asks for the server's password.

1. **`bin/deploy staging`.** It checks that the commit passed GitHub's checks, shows the commits
   that arrive (or are taken away), builds the downloaded plugins and checks them against
   WordPress.org, and asks. `yes` copies, then opens every page and shows any new PHP log lines.
2. **A look at staging:** the pages the change touches. A plugin it names as new is activated
   under Plugins.
3. **`bin/deploy live`:** the same, for the commit staging runs; it refuses any other.

A site without staging skips steps 1 and 2: live is deployed straight from `main`.

- **Refused before the question:** nothing changed; its last line says why.
- **A page failing after the copy:** it names the way back, `bin/deploy <place> --commit <the
  commit the place ran before>`.
- **A plugin "newer than the … pinned"** (the host installed a security release): looked at
  with Claude; normally the pin is raised, and nothing is lowered with `--allow-lower` without a
  reason.
- **Its working copy must be clean,** so a deploy waits while Claude has changes open in the
  repository.

## Refreshing staging's content from live (about 20 minutes)

When: once right after go-live, before a major change to the look, and whenever staging has
drifted far enough to mislead. It copies content only; staging keeps its own settings (the
site-wide password, mail, spam-protection keys, admin accounts, Wordfence). A copy of live's whole
database is deliberately not used: it would overwrite all of those and carry visitors' data into a
test site (the reasons of rebuild plan D30, the other way round). Site details:
[Staging content refresh](SITE_SPECIFIC_ROUTINES.md#staging-content-refresh).

1. **Live:** Tools → Export → All content → Download Export File, into `data/exports/` named with
   the date. It counts as that month's content export (monthly check, step 4).
2. **Staging:** the pages, the site's own content types and the menu moved to the trash, so their
   addresses are free for the imported ones.
3. **Staging:** WordPress's importer installed, Tools → Import → WordPress, live's export chosen,
   the content given to staging's admin, and "Download and import file attachments" ticked: live
   is public, so staging fetches the photos itself.
4. **Staging, checked:** each page at its own address (none ending in `-2`), with its template;
   the front page (Settings → Reading); the menu; the form's Mail tab still sending as staging
   should.
5. **Staging:** the importer deleted, and the trash emptied.

## Monthly site check (about 10 minutes)

Steps 1-3 run on live (on a site not yet live, on staging).

1. **Booking test:** on the site's form, send a request with the user's own name, an email
   address of the user's, and the message "monthly test" (site details:
   [Booking form](SITE_SPECIFIC_ROUTINES.md#booking-form)).
2. **It arrives:** within a few minutes, in the inbox the form sends to (site details:
   [Mail](SITE_SPECIFIC_ROUTINES.md#mail)). If not, see "If the test fails" below.
3. **Delete the test email.** Never click its "Unsubscribe" link or "Report spam": either one puts
   the address on Brevo's blocked list, and every request after that is dropped without any alert
   (rebuild plan step 8, "Brevo setup, where it stands").
4. **Content export (rebuild plan D27):** in the live site's admin, Tools → Export → All content →
   Download Export File. The file goes into the project's `data/exports/`, named with the date
   (for example `2026-12-01-content.xml`). The originals of new photos go into `data/photos/`.
5. **The data folder's off-computer copy** is brought up to date.
6. **Deploy `main`** (see "Deploying" above): `bin/deploy staging`, a look at staging, then
   `bin/deploy live`. This brings the downloaded plugins at the versions the dev site tested, and
   any code merged since the last deploy. With nothing new, it says the place already runs that
   commit; answering `no` then changes nothing. **Never "Update now" for the plugins `bin/deploy`
   delivers** (site details: [Plugins and theme](SITE_SPECIFIC_ROUTINES.md#plugins-and-theme)):
   that installs WordPress.org's newest release, untested here, and the next deploy then refuses
   to lower it until it is looked at with Claude.

   **Then the other updates (rebuild plan 8j):** live's Plugins page (and Appearance → Themes, and
   Dashboard → Updates for WordPress itself), for what `bin/deploy` does not bring. The host
   installs only security updates (site details: [Host](SITE_SPECIFIC_ROUTINES.md#host)); anything
   else waiting is installed by hand, **on staging first**: update there, open the pages and log in
   (with two-factor), and only then update live the same way and look at its pages. Both in the
   same sitting, and before updating live, its waiting version is checked to be the one staging
   just got: "Update now" always installs the newest release, so one published in between would
   reach live untried (it happened with Wordfence 9.1.1, rebuild plan 8j). A site without staging
   updates live after the dev site has run the same version, or after Claude has looked at it.

   **Has the dev site tested it?** The versions the dev site's tests ran are in
   [`site-packages/composer.json`](../site-packages/composer.json) for the downloaded plugins and
   in [`tools/versions.sh`](../tools/versions.sh) for the parent theme (`PARENT_THEME_VERSION`).
   For each update waiting on staging:
   - **A plugin `bin/deploy` delivers:** left to `bin/deploy`, as above.
   - **The parent theme, the same version as `tools/versions.sh`:** tested; update staging, then
     live. **Newer than there:** not tested yet; ask Claude in a session to raise it and run the
     tests first.
   - **Not in those files** (WordPress, and the plugins the dev site does not run): staging is the
     test, as above.

   A security fix the host installs by itself does not wait for the dev site: closing a hole comes
   first, and the version in `site-packages/composer.json` (a plugin) or `tools/versions.sh` (the
   theme) is raised to it afterwards.
7. **Log into HetrixTools** (the uptime monitor, site details:
   [Uptime monitor](SITE_SPECIFIC_ROUTINES.md#uptime-monitor)) and glance at the monitor: up, and
   the certificate and domain dates moving on after each renewal. A free account not logged into
   for 90 days has its monitors stopped.
8. **Failed emails:** in the live site's admin, FluentSMTP → Email Logs → Failed. Anything listed
   is a request (or other site email) that never arrived; see "A Pushover alert came" below,
   resend it, and delete the entry. FluentSMTP deletes failed entries by itself after 60 days (its
   Delete Logs setting), and the privacy policy says so.
9. **No saved copies of the frame (rebuild plan 1e):** in the admin, Appearance → Editor. Under
   Templates, and under Patterns → Template parts, open each one's ⋮ menu (site details:
   [Theme frame](SITE_SPECIFIC_ROUTINES.md#theme-frame)): only Edit and Duplicate is right.
   "Reset" or "Clear customizations" means a copy was saved in the Site Editor, which overrides
   the theme's file and no longer follows the code. Then ask Claude in a session to compare it
   with the theme's file and fold in any change worth keeping, and only then choose Reset.
10. **GitHub:** anything open in the repository's **Pull requests** or **Issues** tabs? A plugin
    update normally merges itself; one still open, or an issue the weekly check opened, needs a
    look (see "When GitHub proposes a new plugin version" below). A safety net in case an email
    was missed.
11. **Site Health (handbook H98):** in the live site's admin, Tools → Site Health. A critical
    issue is fixed, with Claude in a session; a recommendation already known is left (site
    details: [Site Health](SITE_SPECIFIC_ROUTINES.md#site-health)), and a new one is brought to a
    session.
12. **Nothing unknown (handbook chapter 6):** on live, Users → Administrator, Plugins (with
    Must-Use) and Appearance → Themes; and the server's SSH keys, read as the site details say.
    Anything not in the expected set (site details:
    [Expected set](SITE_SPECIFIC_ROUTINES.md#expected-set)) is handled as a possible break-in
    (handbook chapter 5): nothing is deleted, and it is looked at with Claude at once.
13. **Accessibility scan (handbook chapter 12, 7.1 and 7.4):** from the project's folder,
    `bin/accessibility-scan` with live's address (site details:
    [Places](SITE_SPECIFIC_ROUTINES.md#places)). It scans every published page at desktop and
    phone width (about a minute). A failure names the page, the width and the problem, such as an
    image added without alt text: fixed on live in the block editor, or brought to a session with
    Claude when it is not content.
14. **The monthly report (handbook chapter 10, H63-H65):** a customer's site only, by the 10th,
    after steps 1-13, from the handbook's `customer/monthly-report.md`, saved into
    `records/reports/` (site details: [Monthly report](SITE_SPECIFIC_ROUTINES.md#monthly-report)).

**What it protects:**
- Steps 1-2 prove the whole path a visitor's request takes (the form, FluentSMTP, Brevo, the
  inbox), which a failure alert alone cannot: a request Brevo accepts but does not deliver raises
  no alert.
- The test also uses Brevo's API key every month. The key expires after 90 days without use.
- Step 4 is the off-site copy rebuild plan D27 chose instead of a backup plugin: the content holds
  no keys or passwords, and the code is on GitHub.
- Step 6 keeps the site from falling behind: an old version stops getting fixes, and a later
  security fix may then come only in a newer version that "security updates only" skips.
- Step 7 keeps the uptime monitor running; without the login it stops silently after 90 days,
  apart from a warning email.
- Step 8 catches a failure whose Pushover alert was missed (the phone off, the alert dismissed,
  Pushover itself down). The failed entry is then the only copy of that request: the site does not
  store messages, and the email never arrived. Delete Logs is 60 days, not 30, so the entry is
  still there when a monthly check comes a week or two late (the user, 2026-11-15).
- Step 9 catches a copy of the frame saved by an Administrator in the Site Editor: without it, a
  later theme change deployed for that part silently does not appear, as happened with the
  call-to-action panel on staging (rebuild plan 1e, 2026-11-16).
- Step 11 catches what WordPress itself sees going wrong (an outdated PHP, a failing scheduled
  task, a missing module) before it breaks a page.
- Step 12 catches a break-in that left a way back in: an extra Administrator, plugin or key is
  what an intruder adds, and only DTS knows what the expected set is.
- Step 13 tests the content people edit on live, which the dev site's tests never see: a picture
  without its description or a heading skipped is caught within the month.
- Step 14 is what the customer pays for seeing, and the saved report is the site's uptime record.

## If the test fails

- **A Pushover alert came:** sending failed. FluentSMTP → Email Logs shows the error, and the
  request can be resent from there once the cause is fixed. If Brevo refused the server's address,
  that address is authorized under Brevo's Security → Authorized IPs (site details:
  [Mail](SITE_SPECIFIC_ROUTINES.md#mail)). The failed entry holds a visitor's details and is
  deleted once dealt with; FluentSMTP deletes it after 60 days in any case.
- **No alert and no email:** Brevo accepted the email but did not deliver it. Most likely the
  receiving address is on Brevo's blocked list for transactional email: in Brevo, Settings
  (bottom left) → Transactional emails → Blocked or Unsubscribed contacts (found by the user,
  empty, 2026-11-17). If the address is there, it is unblocked in CRM → Contacts → the contact →
  Preferences, transactional emails set to Subscribed (Brevo's help, "Blocklist, unblock, or
  resubscribe contacts"); only the user's own address, never a visitor's who asked to be
  blocked.
- **The email is in spam despite the filter:** it is marked "Not spam", and the inbox's filter is
  checked (site details: [Mail](SITE_SPECIFIC_ROUTINES.md#mail)).

## When a visitor asks to see or delete their information

The privacy policy promises a reply within 30 days, usually within a few days.

1. **Find what is held:** the emails from that address in the inbox the form sends to, and
   FluentSMTP → Email Logs, searched for the address (failed entries only, kept 60 days); Brevo's
   delivery record (site details: [Mail](SITE_SPECIFIC_ROUTINES.md#mail)). On live, Tools →
   Export Personal Data with the address: Simple History, the activity log, adds what that person
   did on the site (its own Compliance note); kept 30 days.
2. **To see it:** reply with what was found.
3. **To delete it:** delete those emails and log entries, reply that it is done, and note the
   date and the address in `data/deletion-requests.txt` (not versioned, never committed).
4. **After any restore from the host's backup** (on live): FluentSMTP → Email Logs → Failed is
   searched for each address in that note, and any entry that came back is deleted again, as the
   privacy policy promises. That is the only visitor information a backup holds: the inbox and
   Brevo are not in it, Contact Form 7 stores no messages, and Wordfence's records hold IP
   addresses only. A line in the note can be removed once the host keeps no backup older than its
   date (site details: [Host](SITE_SPECIFIC_ROUTINES.md#host)): only backups made before the
   deletion can hold the copy.

## When HetrixTools sends an alert

- **Site down:** open the site in a browser, on the phone's mobile data as well as at home.
  - It loads: a short blip or a problem between some networks and the site; the "back up" alert
    normally follows within minutes. If such alerts repeat, bring them to a session with Claude.
  - It does not load, or shows an error or a host's page: the host's panel first, then the
    host's support if the cause is theirs (site details: [Host](SITE_SPECIFIC_ROUTINES.md#host)).
    If the site shows its pages but not the monitor's keyword (site details:
    [Uptime monitor](SITE_SPECIFIC_ROUTINES.md#uptime-monitor)), something replaced the page,
    which is looked at with Claude at once.
- **Certificate expires in 15 days:** the host's automatic renewal failed. The host's panel shows
  the certificate's state; the host's support renews it if the panel cannot.
- **Domain expires in 15 days:** the automatic renewal failed, most often because of the payment
  card. Renew by hand in the domain's account, and check the card on the account.
- **Name servers changed** without the user changing them: the domain may have been taken over.
  Log into the domain's account (password changed if there is any doubt), check the domain's
  settings, and contact its support at once.

## When GitHub proposes a new plugin version

Every Monday Dependabot compares the dev site's plugins (`site-packages/composer.json`) with
WordPress.org (template plan T8, T9). Releases at least a week old arrive together in one pull
request, such as "Bump the site-plugins group in /site-packages". Only WordPress.org's plugins
merge themselves: an update to `composer/installers` (the helper that places them, and runs code
as it does) arrives in a pull request of its own and is reviewed like the tools'. **Normally nothing
is needed:** its checks run by themselves (the dev site rebuilt with the new versions, every file
checked against WordPress.org's checksums, every test), and once they pass it merges itself.
GitHub's emails about it can be read and archived.

The new versions reach staging and live only with the next deploy (the monthly check's step 6),
as tested ones.

**When it needs the user,** the weekly versions check opens an issue after 3 days, which GitHub
emails, titled "Plugin update #… is waiting: …":
- **its checks failed:** a new version breaks something the tests protect. Nothing is merged, and
  staging and live stay on their versions until it has been looked at with Claude. The failing
  check names the plugin.
- **it is behind main:** something else was merged after it was opened. On its page, write a
  comment containing only `@dependabot rebase` and send it. Dependabot redoes its branch on top of
  main within a few minutes; its checks run again and it merges itself. (Not **Update branch**:
  that adds a commit of the user's, after which Dependabot stops looking after the pull request.
  Dependabot brings its pull requests up to date by itself only when they conflict.)
- **it has not merged** for another reason: open it and read what GitHub says at the bottom.

An issue titled "Dependabot has not proposed …" means a plugin's release is 14 days old with no
update proposed: Dependabot's run may have failed. Ask Claude in a session.

**An issue about the parent theme**, from the weekly versions check (`bin/versions-check`, rebuild
plan 8j), instead of a pull request: the theme's pin includes a fingerprint taken by hand, so a
new theme version is raised in a session with Claude, who also carries over any change the child
theme depends on (site details: [Plugins and theme](SITE_SPECIFIC_ROUTINES.md#plugins-and-theme)).

## When replacing a picture

A changed picture gets a **new file name** (for example `logo-2027.png`), never the old name over
the old file. Visitors' browsers keep pictures for some days (site details:
[Host](SITE_SPECIFIC_ROUTINES.md#host)), so under the old name some visitors would still see the
old picture for that long. Pages, styles and scripts need nothing: they arrive fresh or carry a
version in their address.

Claude helps with any of these when the user brings the symptom to a session.

## When adding a video

Videos are added as a YouTube link pasted into a video block, or with the "Video carousel"
pattern. The site shows each video as its picture with a play button, and loads YouTube only when
a visitor plays it (rebuild plan 9v). The picture is fetched from YouTube's image server when the
page is saved (Update or Publish), and kept in the uploads folder (site details:
[Video pictures](SITE_SPECIFIC_ROUTINES.md#video-pictures)).

- **A video shows a dark box with the play button instead of its picture:** the fetch failed, or
  the video was added before the theme had this feature. Open the page and click **Update** once
  (nothing needs changing); the picture is fetched then. Some very new or private videos have no
  picture at YouTube; they keep the dark box and still play.
- **Changing a video's picture on YouTube** (a new thumbnail): the site keeps its first copy. To
  refresh it, ask Claude in a session; the old file is removed from the uploads folder and the
  page saved again.
