# Session history

*"The user" is the person Claude works with; "Claude" is the assistant.*

Moved out of the resume file (`project-state.yaml`, renamed `resume-state.yaml` the same day) on 2026-11-24, word for word, so that resume
reads only what it needs to get back to where the last pause left off (the user: that file is
only for resuming, not a project overview or handoff). Resume never reads this file; git history
and the plans hold the same work commit by commit.

## Sessions from 2026-11-02 to 2026-11-23

The resume file's `last_work`, as it stood at the pause of 2026-11-23.

2026-11-02: live site secured and current (step 0), inventory (2), local tooling (3a-3f),
public repository with branch protection, Dependabot. 2026-11-03: staging site (3g-1),
restricted deploy key (3g-2), site checklist reviewed, template decision D18. 2026-11-04: step
4 (child theme, dev site, tests, required GitHub check) and 3g-3 (deploy to staging after
every merge to main). 2026-11-07: a review of the plan (D19-D21); 5a (Song List, 108 songs on
staging), 5a-2, 2b (pages D22, look D23), 5f (pages on staging), 5e (booking form with Contact
Form 7 and Turnstile on staging; no mail delivered yet); the mail service chosen (D24, Brevo),
Brevo account and DNS records added. 2026-11-09: Brevo's domain still not authenticated after
two days although all four records verify and are correct in public DNS; the user opened one
support ticket for that and for transactional sending's activation. Step 6 done (D25): Yoast SEO
28.8 on the dev site with tests (#19) and on staging by hand (author archives off, tracking
stored off, Organization "Howard Buie Music" with a 696 logo, a 1200x675 sharing image, Site
Title fixed), docs/ENVIRONMENTS.md for intended differences between the three places. Step 8:
8a the Site Hardening plugin (D26; headers, XML-RPC refused, Application Passwords off, no
version comments), deployed through a new server destination the user added, activated and
checked on staging (#20); 8c a last debug-log check in bin/test; 8d the browser tests log in
once by request, not through the login screen (#21), which fixed a race with WordPress's login
script and a lost-session race between parallel logins, and explains the 2026-11-07 timeout; 8e
the logged-in view (icon font allowed, avatars off, a logged-in policy test) (#22); 8b
Update URI false on every plugin, enforced by bin/check (#23). Pull requests #19 to #23 merged,
each deployed to staging. Later on 2026-11-09 (after a resume): Brevo's AI support agent
answered that transactional sending is already active and to re-run the domain check, which
still failed; Claude confirmed all four records at the domain's own name servers; the user
replied to support with the DNS zone export. 8f: backups by hand (D27; the free UpdraftPlus
cannot encrypt), UpdraftPlus deleted from live with old backup files found in its folder. 8g:
Yoast's AI generator off on the dev site and staging, and the build now stops on an unknown
Yoast setting name (#24, merged and deployed). 8h: local visibility planned; Search Console set
up under the business Google account (new DNS record), baseline 84 impressions and 6 clicks in
three months, found only by a misspelling of the user's name. 8i: on live, two-factor login
required for administrators (tested), XML-RPC logins off, the firewall found in Extended
Protection. Evening of 2026-11-09: Brevo's support completed the domain's verification; the
user set up Brevo (two-factor login, sender website@howardbuiemusic.com, the Gmail sender
deleted, a restricted API key, retention 3 months with no previews, anonymous tracking) and
connected FluentSMTP on staging: a test arrived in the inbox with SPF, DKIM and DMARC passing.
Failure alerts by Pushover, proven with a planted failure (Brevo's IP blocking): the alert came,
FluentSMTP kept only the failed request, and sending was restored and checked. Recorded in plan
step 8, "Brevo setup, where it stands".
2026-11-10: the booking subject without the visitor's name and a new "sending failed" message
(config/booking-form-messages.json, Mailpit's chaos mode in a test), Brevo's IP blocking on,
the monthly site check (docs/ROUTINES.md), the privacy policy naming Brevo, the old addresses'
redirects in the child theme (8h, checked on staging), login protection read on both sites
(4.3), live's Wordfence reading REMOTE_ADDR. Staging's site-wide password stopped working:
hPanel writes SHA-512 entries the server cannot verify (Hostinger confirmed); the user's login
and github-check were remade as APR1 lines by hand (3g-1). 8k on staging: the version files
refused and no PHP in uploads/ (server rules by hand), the PHP version header removed by the
Site Hardening plugin (#27). 2026-11-11: permissions on both sites, wp-config.php 600; D28 (no
admin policy of the site's own); 8l (cache: nothing to do); 8h's structured data (MusicGroup
with the towns served, #28, checked on staging); 8j settled (Hostinger installs security
updates only; the monthly check, step 6, does the rest, staging first, versions matched and
checked against tools/versions.sh); Wordfence 9.1.1 on both sites; the weekly versions check
(bin/versions-check, .github/workflows/versions.yml; a plugin gets a pull request the user
approves with "Approve and run" and merges on GitHub, the theme an issue), proven end to end:
#35 raised Contact Form 7 to 6.2.5 on the dev site, merged by the user. Pull requests #25 to
#36 merged, each deployed to staging.
Afternoon of 2026-11-11 (after a resume): 8m's remaining checklist items (domain, CAA and
DNSSEC, certificates, wp-config and options, database, checksums, FTP, mail score 9.2/10,
Wordfence alerts); the song search moved to after go-live; uptime monitoring with HetrixTools
(free plan, one account for the user's own sites, alerts by Pushover, proven), so step 8 is
done; 5f: the site icon set on staging, WebP found not needed, the pages' wording finished and
pasted on staging (#37-#41 merged; #41's first check run was stuck at GitHub and was restarted
by closing and reopening it). Then D29, the look's subtle polish, held to the coding standards
and structured for the template, on the branch style/subtle-polish, three local commits not
yet pushed: d3710e9 Stylelint in bin/check (tools/css-lint/, the lean standard config, option B);
1a0d2f6 the CSS split into theme.json tokens and generic component stylesheets (site-hero,
site-section, site-features, site-cta, site-media, buttons, form) loaded per block, the song
table's styles moved into Song List 0.2.0, proven identical by pixel comparison apart from the
outlined button, breaking for page content (hb- classes renamed site-); 9c69c78 the type and
spacing the user approved. bin/check 20 checks, bin/test 87 browser tests, all passing.
Evening of 2026-11-11 (after a resume): bin/screenshots (generic before/after check with the real
content, by convention: data/content/pages.json, {{photo:<file>}}); the buttons (depth, hover,
focus, equal sizes and widths); the sticky header with the current-page mark; even headings; the
hero at 40-60; the stage light, grain and a cut-out photo (data/photos/make_cutout.py); the Music
videos in a CSS-only carousel (option A+, no JavaScript); a calmer green (the call to action as a
black band with a loose green fog, quiet carousel controls). Merged as #42 (d9abe45) and deployed
to staging; staging's Home content updated by the user. bin/check 20 checks, bin/test 110
browser tests, all passing on main.
2026-11-12 (after a resume): D29 finished and 5f done, pull requests #45 to #55 merged and each
deployed to staging. One frame for every page (WordPress's wide width, 1100px), panels as one
component (site-panel, the user's idea), the call to action as a template part shown by two page
templates of the theme's own ("Page with call to action", "Page No Title with call to action"),
pages naming only components (staging's pages pasted once by the user, templates chosen); the
call to action back to its original solid green with a black button (the user's choice after
trying a fog and a deep green); a larger lead size; the hero picture centred beside the text with
a 2px softened bottom; Hope Mills in the text and the page data; a features panel's buttons lined
up (the user added "Book Howard" there in the block editor). Fixes found on staging: stylesheet
addresses labelled by their contents' fingerprint (the Site Editor showed an old look); embedded
videos' apostrophes (a WordPress bug, fixed in the theme). The videos: Home's featured video and
Music's three, the user's YouTube captions unpublished; carousels as a component (several per
page, an optional name from a heading above, described for screen readers as the W3C pattern
says, a "Video carousel" pattern the user used on staging); every embedded player lazy-loaded;
the theme's first script (one video plays at a time, from the browser's focus and the carousel's
own view, never from page scrolling; the user approved JavaScript for it), with a JavaScript type
check in bin/check. D30: live gets its content from staging (option A). Dependabot's #43
(PHPStan 2.3.5) and #44 (Stylelint 18, about 85 packages fewer) reviewed and merged.
2026-11-13: step 9 paused at 9b for the DTS Operations Handbook, a separate private git
repository at ~/dev/dts-handbook (not on GitHub yet), referenced from the global CLAUDE.md, with
a permission rule in ~/.claude/settings.json asking before any edit or git command there.
Topics 1 to 7 decided and committed there (H1-H30, last commit 2a98cc0): classification (this
site: Fully managed, Brochure, hosted by the customer, with two exceptions, in the project's
CLAUDE.md); how changes reach a site (no deploy jobs on GitHub, bin/deploy from the user's
computer, monthly updates through local staging with exact versions); the standard toolkit
(webmaster address on the customer's domain, Bitwarden, Cloudflare, DTS hosting on Cloudways at
DigitalOcean pending a trial); backups (host daily for 4 weeks, monthly restic copy on an
external drive at home); when something goes wrong (incl. Simple History as activity log, a
monthly report to customers); access and roles; shared code and new sites.
Afternoon of 2026-11-13 (after a resume): handbook topic 8 (moving a site between hosts, H31-H38:
one routine, code from clean sources and only content copied; a site someone else built
evaluated by six criteria, then taken over, fixed or rebuilt; a takeover record kept while the
customer stays plus a year; testing through the hosts file; an existing domain stays where it is
unless there is a reason to move it; inherited code passes at least a basic set of checks) and
topic 9 (handover, H39-H44: written confirmation, accounts changed in a session without sending
passwords, the repository transferred, a site may stay on DTS hosting as hosting only); a review
of the whole handbook removed duplication and conflicts and added a chapter list to its README.
Handbook commits 2f522dd, ce7b29b, 1224d45 (local only).
2026-11-14 (after a resume): handbook topic 10 in three rounds (H45-H65): the service agreement
(one model checked once by a lawyer, a Site Sheet per site, the customer owning the work made
for their site, notice periods, ending with 30 days' notice, unpaid bills, liability capped at
12 months' fees, versioned agreements); visitors' personal data (the customer answers for it,
the least collected by default with comments off, a retention time per kind of data, requests
through the customer, one model privacy policy in building blocks to California's CalOPPA); the
content guide, search titles and descriptions, the monthly report (fixed order, by the 10th,
with a search line, saved as the uptime record). Model documents in the handbook's customer/:
service-agreement.md, privacy-policy.md, content-guide.md (its screen labels checked on the dev
site against WordPress 7.1.4 and Yoast 28.8), monthly-report.md (in the user's first person).
Topic 11, care plans (H66-H74): one plan per arrangement, $59 / $99 / $25 a month, $75 an hour,
one hour of content time in Fully managed, business-hours response times, an outage over an
hour told the same day (narrows H20), monthly or yearly billing, outside costs on the
customer's own card, customer/price-list.md. Topic 12, round 1 of 4 (H75-H78): the standard's
frame from this site's checklist (61 items to word, 18 pointers to earlier chapters, 1.3 and
13.5 retired, the shop items as a draft, the practices left out). Handbook commits 7d3d5e0,
bfc5824, 7004de8, c961d97, b008671, 427f6a3 (local only).
Later on 2026-11-14 (after a resume): handbook topic 12 rounds 2 to 4 (H79-H98: sections 1-14
of the site standard; unfiltered HTML only for Administrators, checked by running WordPress's
filter in memory over the real content; breached and weak passwords refused for publishers;
urgent security fixes within 2 business days; HSTS from Site Hardening; DMARC to quarantine
after 4 weeks; bin/deploy shows the PHP error log; Site Health monthly), then one read of the
whole handbook and version 1 (37c64b8: a site's records in records/ of its repository, H99;
the activity log 30 days, as Simple History's free version keeps it; American spelling
throughout). The handbook pushed to a private GitHub repository on the user's account
(hbuie112358/dts-handbook; moved to the DTS organization when it exists). Step 9 resumed with
its first item: the Editing Help plugin (H89; plugins/editing-help/, branch feat/editing-help,
8c410f3, 0a50544, 8a14023): the content guide in a panel at the top of the Dashboard and a page
under Dashboard, the site's templates (lines the user wrote), patterns and link example read
from the theme, every editor label it names checked in the real editor ("View options" found
wrong: the visible label is "View"), a dev Editor account (deveditor). The handbook's guide
matched to it (2a7839e, not pushed). The plan's Current position trimmed from 400 lines to 41
(D29's story moved to step 5g, the rest to "Earlier positions (archived)", nothing lost).
project-state.yaml given the knowledge-platform project's shape (the user chose option a).
After that pause: a cold-resume check (a fresh helper resuming read-only from the files alone)
found the push understated, stale step 9 text not marked, and a topic range off by one; fixed
(fe1f8f7, the handbook's WORKING_DRAFT.md), the old branch chore/pause-2026-11-12 deleted. The
global PAUSE_CONVENTION.md gained five rules approved by the user (uncommitted and unpushed
work from git's output; blocking decisions also in the plan; numbers from their source; stale
plan parts marked at once; a cold-resume check after a plan section is moved or trimmed).
2026-11-15 and 11-16 (after a resume): item 1, staging's Privacy Policy rewritten from the
handbook's model and pasted by the user (facts checked in FluentSMTP's and Wordfence's code;
failed emails kept 60 days; routines for visitors' requests and restores); item 1b, the footer's
privacy link from WordPress's setting, with a link test; item 1c, the search work on all six
pages on staging (records/search.md; Home and Book searched for, Songs and Music not search
targets, About carries Southern Pines, Book moved to /hire-acoustic-guitarist/ with its
call-to-action button, a test that every link between the site's pages answers); the form's
"sent" message; D32, the site treated as a standard takeover handed to a customer who edits
(Content by customer; takeover record skipped with its reason; staging a temporary preview,
removed after go-live at 9r); item 1e planned, the frame kept in the code with a lock, after
staging's saved copy of the call-to-action panel blocked the deploy (reset by the user; staging
otherwise clean); template notes for an automatic menu, editable call-to-action wording and a
"Site Manager" role. Handbook: H100 (Google's guide as the search method, a brief per page,
Yoast as the check, toolkit/yoast.md), H101 (Business Profile recommended), H102 (host preview
for a build), the restore clause and California's rule under H56, the content guide version 2.
Global: WORKING_STYLE.md gained "Checking tools measure the goal" and the merge rule (rebase by
default; GitHub deletes its branch; the local branch only after pulling and verifying); memory
gained verify-before-claiming and curiosity-questions-not-recorded. GitHub: "Automatically
delete head branches" on; a GitHub pull request incident on 2026-11-16 caused 502s on merges,
and a deleted branch closed #58 once (restored). Pull requests #57 to #60 merged.
2026-11-17 (after a resume): THE NEW SITE WENT LIVE. Before that: 1d (step 9 mapped onto the
handbook's chapters 8 and 9; chapter 9's handover rehearsed, its note and a settings record in
data/records/, outside the public repository; the user's Editor login), 1e settled without a
lock (only Administrators reach the frame; a monthly check for saved copies), item 2 skipped
(new writing is American by the global rule), item 3-1 (Wordfence's password rules, by the
user) and 3-2 (Site Hardening 0.2.0: unfiltered HTML for Administrators only, HSTS on HTTPS,
#64); the theme's picture (#63); D33 (go live first; the code uploaded by hand as zips until
bin/deploy). Go-live: 9c (staging exported, its menu's Book link fixed first), 9d (a rehearsal
import on a throwaway site), 9e (backup 06:54, live's old export), 9f (new admin with
two-factor, the user's Editor), 9g (FluentSMTP and Brevo on live; Brevo's one allowed address
is the server live and staging share), 9h (zips of 181eef0 uploaded), 9i-9k (old pages and
posts trashed, staging's content imported, the theme activated, pictures, icon, live's own
Turnstile widget, the form's From fixed, a booking request arrived), 9l (Site Hardening, avatars,
the server rules, HSTS, all checked from outside), 9m parts A and B (Yoast, Search Console).
Found and fixed: four old addresses unredirected (#65), the tagline. Found for later: 9t (the
phone menu shows only Home: the header's backdrop-filter traps it), 9u (the form's message
before the spam check), 9v (speed: Home's LCP 8.3 s from YouTube's player; Songs 1.5 s).
Global: WORKING_STYLE.md gained the nutshell rule and American spelling (the user's yes);
memory gained github-waits-in-background (with the merge-script rules after a failed merge
was taken for a success and its branch deleted, then restored). Pull requests #62 to #65 merged.
Later on 2026-11-17 (after a resume): 9m parts C, D and E done (HetrixTools up through the
switch; the launch baseline in records/launch/ and records/search.md; Site Health, the keyboard
pass, the secrets check). The Book page's search wording from "hire" to "book" and its photo.
9t, the hamburger menu: a small panel at the right under the header on phones, closed by its
button, Escape or a tap beside it (menu-close-outside.js, also in WebKit, after the iPhone failed
on live). 9t-3, Media & Text's text lined up with the page title. D34, a faster pipeline (a merge
deploys to staging without repeating the checks). One npm advisory accepted in the CSS linter
until 2026-12-17 (#67). 9v, click-to-load videos (includes/video-facade.php, video-facade.js):
nothing from YouTube until played, the pictures fetched once on save into uploads/, PageSpeed on
phones Home 1.2 s (was 8.3), Music 1.7 s (was 14.2), Songs 1.5 s, Book 2.2 s, every page good on
8.1; the privacy policy's Videos paragraph updated on live by the user (dated November 18). The
same evening a black space above each video on live: WordPress's video block stylesheet, which
the dev site's plain-HTML stand-ins never loaded, kept its spacer on; fixed by naming WordPress's
own selector chain (#74), the dev stand-ins made real video blocks with a local stand-in for
YouTube's oEmbed service, the test checking the block's height before and after playing; uploaded
by the user and measured on live (Home 192 px around a 192 px picture, was 385). Each theme change
reached live as a hand-uploaded zip (D33), the latest data/exports/live-upload-a1e5271/. Pull
requests #66 to #74 merged.
2026-11-18 to 11-20 (after a resume): a learning session at the user's request, no code or
files changed; the child theme's PHP (functions.php, includes/, patterns/) read through and
explained, and how to ask Google to show the pages' new search wording (Search Console). 9u
not started.
Later on 2026-11-20 (after a resume): the brochure-site template, to start the user's second
site from it, chosen before this site's remaining items (9u kept waiting). Talked through: a
WooCommerce template later comes from a real shop (D18); the template is three pieces (plugin
repositories, dts-site-tools, dts-site-starter, handbook chapter 7); a repository per plugin
with reusable workflows (T2, after weighing one repository for all); the site tools made
generic in place, then moved (T1); time kept in this project (T3). The GitHub organization
direct-technical-solutions created by the user (renamed to lowercase), the handbook transferred
into it and its local copy re-pointed; the handbook's toolkit/github.md records the
organization's settings (a3ab02d, pushed). docs/planning/template-plan.md written, the active
plan now. #75 (the plan and the two pause commits) first failed bin/check: GitHub withdrew the
picomatch advisory on 2026-11-18, and bin/check refuses a stale exception; the exception list
emptied (3d2ffaa). Step 1.1(a) begun: the shared dts-site-components plugin explained.
Memory gained ask-before-every-commit, after Claude committed the handbook page without asking.
2026-11-21 (after a resume): decisions T5 to T10 (the shared components plugin; managed sites
central, handed-over ones detached with bin/detach; site.json; Composer and WPackagist for the
downloaded plugins in site-packages/; Dependabot's plugin updates merging themselves, a recorded
exception to AI_SECURITY's line-by-line reading; component tests finding their pages). Step 1.2
done (#77 to #85): site.json with its rules (tools/site-settings.jq/.md/.sh), bin/dev-site and
the tests reading it, the dev site's compose recipe split (compose.site.yaml written from it),
the plugins pinned in site-packages/ (Yoast 28.9 on the dev site, #80, merged by itself after
"@dependabot rebase"), the versions check's alerts for waiting and unproposed plugin updates,
checks that the plugins and tools name nothing of this site. Step 1.3a to 1.3c done (#86 to
#89): the tests sorted into generic/, components/, plugins/<plugin>/ and site/; one components'
example page on every dev site (/component-examples/, one page instead of one per component,
the user: run time); each component's tests on every page using it (pagesUsing), 186 to 246
browser tests, about 17 s more on GitHub; the versions check's alerts tested in eleven situations
against stand-ins for gh and curl, in bin/check every time (the user's choice). Found on the real
pages and fixed in form.css (aedde5e, the user's choice): the Book page's 22px of extra space
before the footer; deployed to staging with #88, not yet to live. Pipeline timing measured: push
to main passing about 5.5 minutes. Memory gained read-before-editing (the user: context is
summarized, only the file is reliable) and pause-and-compact-between-steps (usage allowance).
Later on 2026-11-21 (after a resume, one compaction): 1.3d done (a new site's starting tests in
template-notes.md). Step 1.4 designed (T11) and built in parts, #90 to #93: 1.4a (the per-site
PHP log found on the server; log_errors switched on by the user in hPanel for live and staging),
1.4b bin/site-check (#90), 1.4c site.json's deploy section, 1.4d-1/2 bin/deploy's checks and copy
(#91), 1.4d-3 after the copy (page check, PHP log lines, one deploy at a time) and its test
against a throwaway Alpine server with the real ssh and rsync (#92, passed on GitHub too), 1.4d-4
the versions check's weekly warning when Alpine replaces a test server package, raised with no
7-day wait (the user's choice), and each part of the versions check running on its own, failed
parts named in plain words (#93). Found in the PHP logs, recorded as the rebuild plan's 9w:
Wordfence "Commands out of sync" errors on live, an Action Scheduler cron error on staging.
2026-11-22 (after a resume): 1.4e done: two deploy keys made by the user with passphrases, the
server set up by a script over the user's password login (data/records/server-setup-1.4e.sh),
probes from the user's computer, bin/deploy staging and live (91a01ff; Yoast 28.9 and the
form.css fix on live); GitHub's staging deploy, bin/deploy-staging, the old key and settings on
the server and the staging environment removed (#95); bin/deploy made executable with a bin/check
rule. Brevo's "Verify a new IP" alert traced to staging sending from the server's IPv6 address,
added to Authorized IPs by the user; the refused email resent. Handbook: H103 and chapter 2's
deploy wording (ee49e7b), H94 corrected (8a6d69c), both pushed. 1.5 split in four; 1.5a done
(records/README.md); 1.5b built (#96): Simple History 5.36.0 chosen after comparing four
activity logs, pinned in site-packages; bin/deploy shows a missing file instead of refusing
(WP-CLI's rule); the debug log rule now sorts by origin (own code and fatal errors fail, others'
messages shown); dev-activity-log.sh. Staging deployed (3afc5e0) and Simple History activated
there, after rerunning the setup script with simple-history added.
2026-11-23: Contact Form 7 6.2.6 (#98, Dependabot) and Simple History on live (bin/deploy live,
e243788); bin/deploy says "<place> now runs commit: <sha>". Step 1.5 finished: 1.5b recorded
(#99); 1.5c the routines split into docs/ROUTINES.md (every site's) and
docs/SITE_SPECIFIC_ROUTINES.md (this site's details), bin/check holding their links both ways
(#100); 1.5d the status sheet records/status.md, complete (86 items answered, 2 retired, none
open), exceptions E1-E11 in records/exceptions.md (E5 private, in data/records/), the expected
set records/plugin-set.md; the editor offers only the theme's presets (theme.json switches,
dev-editor-presets.sh) and no WordPress version in pages or feeds (Site Hardening 0.3.0),
both deployed to staging and live (e366b02, #101); bin/accessibility-scan (axe WCAG 2.2 AA and
images without alt, desktop and phone, the pages bin/site-check --print-pages finds) in the
monthly check, live 12 of 12 passing; bin/check's status-sheet check (tools/status-sheet.sh,
tools/status-sheet-blank.md); #102's first dev-site run failed once (the scan check's probe
deleted as the dev admin left Yoast's deleted-page notice for the guide's axe test), fixed by
deleting without a user (8168d9b). 9.3: the user kept Home, Book and Songs sharing their own
photos. 1.6 started (T12): 1.6a done (95351f0, not pushed), the shared tests look-independent.
Afternoon of 2026-11-23 (after a resume): #103 (1.6a and the 9.3 record) merged. The project's
CLAUDE.md gained "Coding standards by language" (#104; TypeScript strict for production code,
test code held to clarity; CSS to css-standards-notes.md; Bash ShellCheck only, a gap); the
global CLAUDE.md's resume reads a project's named language standards (the user committed it).
The review of the theme's three scripts against TYPESCRIPT_STANDARDS.md found seven items,
now step 1.7. 1.6b decided (T13) and done: 1.6b-1 (#105) the call-to-action colors spelled out
as custom.callToAction, the video icon, carousel arrow and form color scheme as tokens, the
site's facts in includes/site-facts.php, tools/theme-tokens.sh in bin/check, all 24 screenshots
identical; 1.6b-2 (#106) starter/ (light palette, contrast table, parts, logo, site facts,
pages), tools/site-layer-files.txt and tools/site-layer.sh, seven starter rules in bin/check,
.gitignore allowing starter/. 1.6c decided (T14): 1.6c-1 (#107) SITE_DIR names the site's
folder, tools/site-theme.sh assembles the starter's theme into starter/themes/ (ignored),
bin/test leaves out and names another site's tests; 1.6c-2 (#108) tools/dev-site-guard.sh (one
dev site at a time, refused by name), the video code allowing its own player in the policy,
four scenario checks fixed with the user's approval; the starter passes 16 scenario checks and
166 browser tests, this site 17 and 242. Memory: compacting only past 50% (the user).

## Facts about the sites, as last recorded

The resume file's `verification` entries other than those its drift check uses, as they stood on
2026-11-24. Each line is `name: fact`; the settings record in `data/records/settings.md` (private)
and `records/` hold the sites' settings as they are kept up to date.

```yaml
live_php: 8.4.28 (2026-11-23)
live_wp_config: mode 600 on live and staging (2026-11-11)
staging_php: 8.4.28 (2026-11-23; set per website; step 0f corrected)
status_sheet: records/status.md complete against handbook chapter 12 (version 1), held by bin/check; exceptions E1-E11; expected plugin set in records/plugin-set.md (2026-11-23)
live_plugins: wordfence 9.1.1 (by hand, 2026-11-11); since bin/deploy (1.4e) the downloaded plugins and the site's own come from main, live at e366b02 with wordpress-seo 28.9, contact-form-7 6.2.6, simple-history 5.36.0 and site-hardening 0.3.0 (2026-11-23); twentytwentyfive 1.5; UpdraftPlus deleted 2026-11-09 with its old backups and folder (D27, plan 8f); Hostinger's Smart auto-updates set to security updates only for core, themes and plugins on both sites; the rest by hand in the monthly check (8j)
live_wordfence: two-factor login required for administrators (2026-11-09, tested; recovery codes in the user's password notes), XML-RPC logins disabled, Application Passwords blocked, firewall in Extended Protection (remove before a host move, step 10); visitors' addresses read from REMOTE_ADDR behind Hostinger's CDN (8i); brute-force limits as on staging, read 2026-11-10
search_console: Domain property under the business Google account, verified 2026-11-09 by a new google-site-verification TXT record; the other owner is the user's other Google account (the older TXT record); baseline in plan 8h
live_theme: the child theme Howard Buie Music, active since 2026-11-17 (9k), first uploaded as the zip of a1e5271 and since 1.4e copied by bin/deploy, now at e366b02 (2026-11-23); music-lite and music-lite-child still installed until 9n (the way back); Home and Music saved after 9v, their four video pictures in uploads/hbmusic-video-pictures/
live_site_2026_11_17: staging's content imported (6 pages, 108 songs, Main menu, the Booking form); pictures for Home and Songs, the site icon, the sharing image and Yoast's logo uploaded by hand; old pages and posts in the trash until 9n; plugins Contact Form 7 6.2.5, Editing Help 0.1.1, FluentSMTP 2.4.5 (Brevo with live's own key, Pushover with live's own token), Site Hardening 0.2.0, Song List 0.2.1, Wordfence 9.1.1, Yoast SEO 28.8 (the importer deleted); a new admin with two-factor and the user's Editor, both tested; the old admin until 9n; live's own Turnstile widget; HSTS and the security headers, the version files 403, no PHP in uploads, all checked from outside; every old address redirected; a Hostinger backup of 06:54 before the switch; the settings in data/records/settings.md
live_backups: Hostinger backs up the live site daily (the user, 2026-11-09), kept at Hostinger; the off-site copy by hand, content exports into data/exports/ (D27), first one at go-live
staging_site: staging.howardbuiemusic.com, site-wide password (one PWPROTECTID block in .htaccess; .htpasswd holds APR1 lines made by hand for the user and github-check, since hPanel's SHA-512 entries are refused; no users added through hPanel until Hostinger fixes it), server rules for the version files (top of .htaccess) and uploads/.htaccess (8k), wp-config.php 600, Wordfence 9.1.1, Wordfence with two-factor login required for administrators, the theme with the On Stage look, Song List with the 108 songs, the five pages and the Privacy Policy, Contact Form 7 with the Booking form, Turnstile keys and its To and From set by hand; Yoast SEO 28.8 set as in plan step 6; Site Hardening active (8a); avatars off (8e); the site icon (5f, 2026-11-11); the pages' final wording pasted (5f); theme as of 84999a3 deployed (#55); its pages updated by the user on 2026-11-12 (Home, Music, Songs and About) with wide bands and the site-panel class, templates chosen (Page No Title with call to action for Home, Page with call to action for Music, Songs and About), Home's introduction naming Hope Mills, Home's featured video, a Book Howard button in Home's features panel, Music's carousel from the Video carousel pattern with three videos; Yoast AI off (8g); WordPress Importer deleted again (confirmed by the user, 2026-11-22)
staging_checked_2026_11_09: headers identical to the dev site's, xmlrpc.php 403, no Yoast comment, no policy violation of ours on Home, Music and Book logged out or logged in; the server adds a second policy, upgrade-insecure-requests; Music has no video yet, so YouTube is not yet checked on staging
staging_mail: FluentSMTP connected to Brevo (sender website@howardbuiemusic.com, log off, failed emails kept anyway); a test arrived in the inbox with SPF, DKIM and DMARC passing (2026-11-09); failure alerts by Pushover, proven with a planted failure; the 2026-11-07 mails had gone through Hostinger's relay into spam, failing DMARC; staging's admin email changed to the business Gmail address (confirmed by the user, 2026-11-22)
dns_mail_records: MX at Hostinger; SPF v=spf1 include:_spf.mail.hostinger.com ~all (unchanged); brevo-code TXT and brevo1/brevo2._domainkey CNAMEs and DMARC v=DMARC1; p=none; rua=mailto:rua@dmarc.brevo.com, all checked live again on 2026-11-09 on 1.1.1.1 and 8.8.8.8 and at the domain's own name servers (ns1/ns2.dns-parking.com); also two google-site-verification TXT records (the user's two Google accounts) and Hostinger's own hostingermail-a/b/c._domainkey CNAMEs
brevo: account under the user's Gmail address, two-factor login on; domain authenticated (support, 2026-11-09), not branded; one sender, website@howardbuiemusic.com; API key restricted to transactional email, no fixed expiry but expires after 90 days unused; retention 3 months, previews never stored, tracking anonymous; Authorized IPs holds the server's IPv4 and IPv6 addresses (IPv6 added 2026-11-22), blocking on (as the settings record says); login, API key and Pushover keys in the user's password notes
google_cloud: the project made for the Gmail attempt shut down by the user; a different Google account's project was opened by mistake and, as far as known, left unchanged
staging_2026_11_16: the Privacy Policy rewritten and its slug privacy-policy (the old draft trashed and both trashes emptied by the user); every page's Yoast phrase, title and description set (records/search.md); the Book page at /hire-acoustic-guitarist/, "Main menu" changed to it in the Site Editor; the call-to-action template part's saved copy reset by the user, and Header, Footer and the three page templates found without saved copies; the form's "sent" message typed in its Messages tab; FluentSMTP Delete Logs 60 days; Songs has a new photo (its original kept in data/photos/); theme as of #59 deployed
local_sites: dev site on 10102 (rebuilt 2026-11-16 with the Book page at /hire-acoustic-guitarist/ and the privacy page chosen in Settings; the dev Editor deveditor, password DEV_EDITOR_PASSWORD in .env; to log in by hand, copy a password with grep '^DEV_ADMIN_PASSWORD=' .env | cut -d= -f2- | tr -d '\n' | wl-copy), its Mailpit inbox on 10103; the rest of the 101xx block is free
github_organization: direct-technical-solutions (2026-11-20), holding the handbook; its settings in the handbook's toolkit/github.md; this repository stays on the user's personal account (D17)
github: the setting Automatically delete head branches on (2026-11-16); required checks check and dev-site on main (strict, also for admins); no deploy job, no environments, no server keys (since 2026-11-22, #95); workflow versions (Mondays 06:41 UTC, bin/versions-check --act); workflows may open pull requests (setting switched on 2026-11-11, default token read-only)
php_logs: per site in ~/.logs/error_log_<domain with underscores> on the server; log_errors on for live and staging since 2026-11-21 (the user, hPanel; data/records/settings.md)
bin_deploy: used for real since 2026-11-22; the server's rsync is 3.1.3 (a read-only refusal shows only as "connection unexpectedly closed", the reason in the server's rsync log)
deploy_destinations: ~/.deploy/rsyncd-hbmusic-staging.conf and -live.conf on the server (the theme, five plugins plus simple-history, deploy-note, read-only php-log), each forced on its own key in authorized_keys (backups authorized_keys.before-1.4e and .before-step-10); the keys hbmusic-staging and hbmusic-live in the user's SSH settings, passphrases in the user's password notes, unlocked with ssh-add; a shell login now needs -o PubkeyAuthentication=no
uptime: HetrixTools free plan, one account (the user's Hostinger address; two-factor login on (the user, 2026-11-12)), contact list with Pushover, monitor on https://howardbuiemusic.com/ every minute from 4 locations, keyword, certificate and domain expiry warned 15 days ahead; log in at least every 90 days (monthly check, step 7)
dependabot: weekly version updates (action, Composer, npm for the browser tests and the CSS linter, and site-packages/ with a 7-day wait); alerts and security updates on; plugin updates merge themselves once their checks pass (.github/workflows/plugin-updates.yml, T9; "Allow auto-merge" on); tools updates wait for the user, and one is open (2026-11-21, number 56)
commit_identity: GitHub noreply address, set in this repository's git config only
hostinger_plan: ends 2028-07-16, auto-renewal off; SSH on, password logins cannot be switched off; two keys, each restricted to rsync with its own place's folders
old_site_as_exported: the reference copy in wordpress/ (moved here from the project's CLAUDE.md, 2026-11-26); active theme the parent music-lite 1.5 (unmaintained), music-lite-child installed but not active, twentytwentyfive 1.2 installed; plugins updraftplus, wordfence, wordpress-seo and Hostinger's auto-updates plugin (also a must-use plugin in wp-content/mu-plugins/); wordpress/staging/ a second complete WordPress 7.1.4 install with the same themes, removed from the live server on 2026-11-02 (plan step 0g)
not_versioned: data/ holds the song list and its import file, the pages and form import file (data/content/pages-import.xml), the photos (with data/photos/web/howard-buie-logo-696.png and howard-buie-share-1200x675.png, made 2026-11-09 for Yoast) and the screenshots; only on the user's computer, needed at go-live; the user's password notes hold the Turnstile keys; tests/e2e/.auth/ holds the dev admin's saved login (ignored by git)
```

## Decisions kept for the record

- Decided 2026-11-17: the time report stays as it is (busy gaps over 10 minutes counted 0 lose about 42 minutes in the project so far).
