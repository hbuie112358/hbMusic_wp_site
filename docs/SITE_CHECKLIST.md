# Site checklist: security, accessibility, performance and operations

*Role of this file (the user, 2026-11-02): a draft of WordPress additions, the candidates for a
shared `~/.claude/WORDPRESS_STANDARDS.md` used by every WordPress project, the way Java and Go
projects use `JAVA_STANDARDS.md` and `GO_STANDARDS.md`. Nothing moves there unless the user
asks for it; Claude proposes, the user decides each time. If it moves, this draft is trimmed
first: its own items that repeat something already in the global files are left out of the new
file, and references to this site and its plan stay behind in the project. The global files
themselves are never trimmed or changed; only additions the user approves go into them.
Until then, Claude uses it as this project's WordPress checklist.*

The standard that howardbuiemusic.com is built, deployed and run to. Every item has a check, so
compliance is shown, not claimed. An item that does not apply, or is deliberately not followed,
stays in the list with the reason next to it.

Each item is checked at the step of `docs/planning/rebuild-plan.md` that touches it, and the
whole list is checked once more before go-live (plan step 9).

Each item gives:
- **the practice**, in bold, and **why**;
- **check:** what must be true for the item to count as met;
- **kind:** *general* (any website or server: a candidate for a shared global file, each one
  proposed to the user on its own), *WordPress* (for `WORDPRESS_STANDARDS.md`), or *shop*
  (section 15);
- **status:** *done* or *in force* (with the step), *partly* (what is done and what is left),
  *planned* (with the step that does or checks it), or *not applicable* (with the reason).
  Nothing is marked done that the project has not verified.

## 1. Secrets and the repository

**1.1 No secret is ever committed: no `wp-config.php`, database dump, salt, password, API key or
token.**
- Why: a repository keeps its whole history; one committed secret is exposed for good.
- Check: the `.gitignore` allow-list is in place, the staged files are listed before every
  commit, and the history search before the first push found nothing.
- Kind: general · Status: in force since step 1; history searched before the first push (3f).

**1.2 No personal data in committed files: no home-folder paths, personal email addresses, host
account numbers or visitors' data.**
- Why: the repository is public work; personal data cannot be taken back once published.
- Check: the scan of the staged files before every commit finds none.
- Kind: general · Status: in force since step 1.

**1.3 Commits use the GitHub noreply address and follow Conventional Commits.**
- Why: keeps the personal address out of the history; readable history.
- Check: `git config user.email` shows the noreply address, and `git log` shows only
  Conventional Commits subjects.
- Kind: general · Status: in force since step 1 (D5).

**1.4 When a site is moved from another host, every credential that was there is replaced:
database password, salts and keys, admin passwords, API keys.**
- Why: copies of the old values exist in backups and on the former host.
- Check: the go-live checklist shows each credential replaced.
- Kind: general · Status: partly: the live site's salts and keys (0d) and admin password (0a)
  are replaced; the database password and any other credentials at step 9.

**1.5 Production secrets live only on the server (`wp-config.php` or environment variables) and
in the one place the user keeps passwords; deploy secrets live only in the CI's encrypted secret
store. Never in mail, chat or the repository.**
- Why: one place to rotate each secret; a copy elsewhere is a copy that can leak.
- Check: at go-live, each secret is found only in those places.
- Kind: general · Status: partly: the deploy key exists only in GitHub's secrets (3g-2); the
  rest is reviewed at step 9.

## 2. WordPress configuration (`wp-config.php` on the server)

**2.1 Fresh, unique salts and keys (from the WordPress.org secret-key service).**
- Why: old salts are in the export; new ones invalidate every old login cookie.
- Check: no salt or key matches a value in the export.
- Kind: WordPress · Status: done on the live site (0d); the new site gets its own at step 9.

**2.2 `DISALLOW_FILE_EDIT` set to `true`.**
- Why: a stolen admin login cannot then edit PHP from the dashboard.
- Check: Appearance → Theme File Editor and Plugins → Plugin File Editor are absent.
- Kind: WordPress · Status: partly: set in the local copy (3a); live and staging checked at
  step 8.

**2.3 `WP_DEBUG` off in production; if logging is needed, `WP_DEBUG_LOG` writes outside the web
root and `WP_DEBUG_DISPLAY` is off.**
- Why: error output reveals paths and code to visitors.
- Check: a missing page and every template show no PHP notice, and the debug log, if any, is
  outside the web root.
- Kind: WordPress · Status: partly: no PHP error text on the live site's public pages (0f); the
  settings themselves checked at step 8.

**2.4 `FORCE_SSL_ADMIN` on; `siteurl` and `home` use `https://`.**
- Why: logins and cookies never travel unencrypted.
- Check: both options start with `https://`, and an `http://` request to `/wp-admin/` is
  redirected to `https://`.
- Kind: WordPress · Status: partly: `http://` is redirected on live and staging (3g-1); the
  setting and the options checked at step 8.

**2.5 The database user has rights to this site's database only, with a long random password.**
- Why: a compromise of the site does not reach other databases.
- Check: `SHOW GRANTS` for the user lists this site's database only.
- Kind: general · Status: planned: step 8 (live and staging).

**2.6 `wp-config.php` is readable only by the site's own account (mode 600 or 640).**
- Why: other accounts on the server cannot read the credentials.
- Check: `ls -l` on the server shows mode 600 or 640.
- Kind: WordPress · Status: planned: step 8 (live and staging).

**2.7 Wherever something must happen on time (scheduled emails, expiring links, a shop's
background tasks), WordPress's scheduler is run by a real server cron job (`DISABLE_WP_CRON` and
a cron job at the host), not by visits.**
- Why: WordPress's own scheduler runs only when someone visits the site; a quiet night means
  late or missed tasks.
- Check: `DISABLE_WP_CRON` is set, the host's cron job runs `wp-cron.php` every 5–15 minutes,
  and a scheduled test task runs on time.
- Kind: WordPress · Status: planned: staging when 5b's expiring links need it, live at step 8.

## 3. Server and hosting

**3.1 HTTPS everywhere, with a certificate that renews automatically; HTTP redirects to HTTPS;
HSTS once HTTPS is confirmed stable.**
- Why: encrypts all traffic; HSTS stops downgrade attacks.
- Check: SSL Labs grades the site A or better, and `curl -I` shows the redirect and the HSTS
  header.
- Kind: general · Status: partly: HTTPS with automatically renewed certificates and the redirect
  on live and staging (3g-1); no HSTS header yet (checked 2026-11-03), set at step 8 or 9.

**3.2 Security headers: a `Content-Security-Policy` that limits where code may come from and go
to: scripts, styles and frames only from the site itself and the outside sources listed in the
policy, each with its reason; `object-src 'none'`, `base-uri 'self'`, `form-action 'self'`,
`frame-ancestors 'self'`. Inline code is allowed, since WordPress core and block styles need it;
a nonce-based policy is used where a site handles payments or accounts. Also
`X-Content-Type-Options: nosniff`, `Referrer-Policy`, `Permissions-Policy`.**
- Why: blocks scripts from foreign sources, clickjacking and forms sent elsewhere, while
  WordPress updates that add inline code keep working.
- Check: the response headers carry the policy and the other headers, and the browser tests
  fail on any CSP violation, so an update that needs a new source shows up on staging first.
- Kind: general · Status: partly: the policy and the other headers are sent on visitor pages by the Site Hardening plugin (8a, D26; before, by the dev site's Apache), and the browser tests fail on a missing header, a loosened strict rule or any violation (4c, 8a; WordPress's emoji script, which the policy refused, is switched off in the theme); staging after 8a's deploy, the admin pages at step 8, live at step 9.

**3.3 A PHP version under active security support, that the WordPress version in use supports;
set per site where the host allows it, with staging on the same version as live, and a new
version tried on staging first.**
- Why: unsupported PHP gets no security fixes; a version change can break plugins, so it is
  proven on staging.
- Check: the host's PHP version is on php.net's list of supported versions, and staging and live
  run the same version.
- Kind: general · Status: done: live on 8.4.27 (0f), staging on 8.4.27 (3g-1).

**3.4 File permissions: folders 755, files 644, nothing world-writable; files owned by the site's
account.**
- Why: other processes cannot change site code.
- Check: `find` for world-writable files on the server returns nothing.
- Kind: general · Status: partly: the staging folders seen in 3g-2 are 755 and 644; the `find`
  over both sites at step 8.

**3.5 No PHP runs from `wp-content/uploads/`, and SVG uploads are allowed only through a plugin
that sanitizes them.**
- Why: an uploaded file can then never run as code; an SVG file can carry scripts.
- Check: a test `.php` file in uploads is refused, then removed; an SVG upload is refused or
  sanitized.
- Kind: WordPress · Status: planned: step 8.

**3.6 The web server refuses dotfiles (`.git`, `.env`, `.htaccess`), `.sql`, `.zip`, `.log`,
`.json` config and backup files, and the files that reveal versions: WordPress's `readme.html`
and `license.txt`, and the `readme.txt` of every plugin and theme.**
- Why: leftover files cannot be downloaded (open item 1 shows how they appear); version numbers
  tell attackers which known holes to try.
- Check: a request for each kind returns 403 or 404.
- Kind: WordPress · Status: partly: the live site's leftover files return 404 since they were
  deleted (0c); Yoast SEO's version comment in the pages is removed by the Site Hardening plugin
  (8a); the general rules and the version files at step 8.

**3.7 Only the site's files are in the web root: no local-development leftovers, archives, dumps
or a second install (open items 1 and 2).**
- Why: every file in the web root is reachable from the internet.
- Check: the web root's file listing matches the expected set.
- Kind: general · Status: done on the live site (leftovers 0c, the old staging copy 0g); the new
  site checked at step 9.

**3.8 The server is reached by SSH or SFTP only, never plain FTP; logins by key where the host
allows it. Where the host cannot disable password logins, the account password is long and
unique and used for nothing else, and every key is restricted to its task (13.5).**
- Why: FTP sends passwords in the clear; on shared hosting one SSH account reaches every site in
  the plan, so its password and its keys are the keys to all of them.
- Check: an FTP connection is refused or no FTP account is in use, the SSH password meets the
  rule, and `authorized_keys` holds only restricted keys.
- Kind: general · Status: partly: Hostinger cannot disable SSH password logins or limit them by
  address, so the password was made long and unique, and the only key is restricted (3g-2); FTP
  checked at step 8.

**3.9 Every copy of the site other than live (staging, previews, tests) sits behind a site-wide
password at the server, in front of WordPress, from the moment it is created; it has no second,
temporary address; it holds test data only, never a copy of live data; and it is removed when no
longer needed.**
- Why: a copy is usually less maintained than the live site, yet has the same weaknesses, and its
  login page is as good a way in; "not indexed" keeps search engines away, not attackers. Live
  data on a copy is personal data in a second, weaker place.
- Check: every path of the copy returns 401 without the password (home, login, admin, REST API,
  `xmlrpc.php`), checked from outside; the host's site list shows no temporary address; no plugin
  or must-use file adds a preview address.
- Kind: general · Status: done for the staging site (3g-1, its preview-address file removed in
  3g-2); the old, open staging copy was removed (0g).

## 4. Users and access

**4.1 Each person has their own account with the lowest role that does the job; no shared
logins; no account named `admin`.**
- Why: limits what one stolen login can do; actions can be traced.
- Check: the users list shows one account per person, each with the lowest role that does the
  job, and none named `admin`.
- Kind: WordPress · Status: done on live (one account, 0a) and staging (the installer's `admin`
  renamed, 3g-1); the new site gets a login name that is hard to guess at step 9.

**4.2 Two-factor authentication for every account that can publish or administer.**
- Why: a leaked password alone is not enough.
- Check: each such account shows two-factor login on.
- Kind: WordPress · Status: done: on for the only account on live (0a) and staging, and required
  for administrators on staging (3g-1) and on live (8i, 2026-11-09, the login tested).

**4.3 Login attempts limited, and a web application firewall active (Wordfence, or the host's).**
- Why: stops password guessing and common attacks.
- Check: the firewall shows as active, and repeated failed logins are blocked after the limit.
- Kind: WordPress · Status: partly: Wordfence active on live and staging; live's firewall runs
  in Extended Protection (found already set, 8i); the test of the limit, on staging, at step 8.

**4.4 XML-RPC disabled unless a feature needs it.**
- Why: a common target for password guessing.
- Check: a request to `/xmlrpc.php` is refused.
- Kind: WordPress · Status: partly: unreachable on staging behind its password (3g-1); refused
  with 403 by the Site Hardening plugin on the dev site, tested (8a); staging after 8a's deploy,
  live at step 9.

**4.5 Usernames are not exposed: the REST `users` endpoint and `?author=` lookups do not reveal
login names to visitors.**
- Why: a known username halves the work of guessing a login.
- Check: as a visitor, `/wp-json/wp/v2/users` and `/?author=1` reveal no login name.
- Kind: WordPress · Status: done on live (404 and 401, checked 2026-11-02); the new site checked
  at step 9.

**4.6 Unused accounts are removed.**
- Why: fewer ways in.
- Check: the users list holds no unused account, checked at go-live and whenever someone stops
  working on the site.
- Kind: WordPress · Status: done on live (only account, 0a) and staging (3g-1); again at step 9.

**4.7 Application Passwords are switched off (through the security plugin's setting or a filter)
unless a feature or service needs them; then only for the account that needs them, named in the
plan.**
- Why: they allow logins to the REST API that bypass two-factor login.
- Check: the user profile shows no Application Passwords section.
- Kind: WordPress · Status: partly: switched off by the Site Hardening plugin's filter on the dev
  site, tested (8a); staging after 8a's deploy, live at step 9.

**4.8 Comments, pingbacks, trackbacks and user registration are off unless the site uses them.**
- Why: each one is a door for spam and attacks that nobody watches.
- Check: Settings → Discussion and Settings → General show them off, and a pingback to the site
  is refused.
- Kind: WordPress · Status: partly: on live, comments are closed by default and registration is
  off (step 2); pingbacks and staging checked at step 8.

**4.9 Before a site is handed over, the provider and the customer agree in writing who may change
what: content (usually the customer, with the Editor role), plugins, themes, settings and updates
(the provider while maintaining, or the customer after a full handover). At a full handover the
customer receives the checklist's state, the expected plugin and theme set, and the backup and
update arrangements. The agreement is written, not enforced: nothing checks the site against the
expected set automatically, and a deploy does not stop when the site differs from it.**
- Why: a site changed by several people without an agreement drifts: unknown plugins, theme edits
  lost at the next deploy, updates nobody applies.
- Check: the agreement exists before handover, and the users list matches it.
- Kind: general · Status: not applicable; the user owns this site.

## 5. Themes, plugins and updates

**5.1 Only maintained themes and plugins, from WordPress.org or a vendor with a security record.**
- Why: unmaintained code gets no security fixes (the reason `music-lite` is replaced).
- Check: every theme and plugin in use has been updated within the last year and is supported
  by its author.
- Kind: WordPress · Status: partly: the live site still runs the unmaintained `music-lite`, which
  the rebuild replaces (steps 4 and 9); the plugins are maintained.

**5.2 Unused themes and plugins are deleted, not just deactivated; one fallback default theme may
stay.**
- Why: inactive code can still be attacked.
- Check: the themes and plugins lists hold only what is in use, plus one default theme.
- Kind: WordPress · Status: partly: done on staging (3g-1); the live site's inactive child theme
  and themes are cleared at step 9.

**5.3 Updates are applied promptly. WordPress's automatic minor (security) releases stay on, and
the security plugin updates automatically; every other update is applied after a check on staging
where one exists. On a shop, WooCommerce and its extensions never update automatically.**
- Why: most WordPress compromises use known, already fixed holes; a shop's updates can break
  checkout, so they are proven first.
- Check: the Updates screen shows nothing pending for longer than a week, and the update log
  shows staging before live.
- Kind: WordPress · Status: partly: the live site was brought current (0f) and Wordfence updates
  itself on staging (3g-1); how updates run on live is decided at step 8.

**5.4 The site's changes live only in the child theme (or a small site plugin for features that
must survive a theme change), never in the parent theme or core.**
- Why: updates never overwrite the site's work.
- Check: `wp core verify-checksums` and `wp plugin verify-checksums --all` report no changed
  files.
- Kind: WordPress · Status: planned: the child theme at step 4, the site plugin at 5a, the
  checksums at step 8 and after go-live.

**5.5 After every new install, and whenever the host changes something, the plugins, the
must-use plugins (`wp-content/mu-plugins/`, which the plugin list does not show) and the themes
are compared with the expected set by whoever maintains the site (4.9); extras are removed unless
kept for a stated reason.**
- Why: hosts' installers often add their own plugins and must-use files; each one is code that
  can have holes, and some open a second address to the site.
- Check: the plugins, themes and must-use files match the expected set.
- Kind: WordPress · Status: done on staging (3g-1, 3g-2); on live, the one must-use file is
  Hostinger's updater, kept while the site is at Hostinger (open item 3).

## 6. Child theme code

**6.1 Design comes from `theme.json`, block templates, template parts and patterns first; PHP and
custom CSS only where these cannot do it.**
- Why: follows how block themes are meant to work; less code to maintain and secure.
- Check: code review finds no PHP or custom CSS doing what `theme.json`, templates or patterns
  could do.
- Kind: WordPress · Status: planned: step 4 onwards.

**6.2 Follows the WordPress Coding Standards for PHP, JavaScript and CSS.**
- Why: consistent, reviewable code; the standards include security rules.
- Check: PHP_CodeSniffer with WPCS passes with no errors.
- Kind: WordPress · Status: in force for the project's PHP since 3d (`bin/check`); the theme
  from step 4.

**6.3 All output is escaped late, with the function for its context (`esc_html`, `esc_attr`,
`esc_url`, `wp_kses_post`).**
- Why: prevents cross-site scripting.
- Check: the WPCS security sniffs pass, and code review finds no unescaped output.
- Kind: WordPress · Status: in force through `bin/check` (3d); the theme from step 4.

**6.4 All input is validated and sanitized; every form or action checks a nonce and the user's
capability; every REST route has a `permission_callback`.**
- Why: prevents injection, cross-site request forgery and open endpoints.
- Check: the WPCS security sniffs pass, and code review finds no route without a permission
  check.
- Kind: WordPress · Status: planned: steps 5b and 5d (the forms).

**6.5 Database queries go through WordPress APIs or `$wpdb->prepare()`.**
- Why: prevents SQL injection.
- Check: the WPCS sniffs pass, and code review finds no query built from raw input.
- Kind: WordPress · Status: planned: step 5a onwards.

**6.6 Every PHP file stops if loaded directly (`defined( 'ABSPATH' ) || exit;`).**
- Why: a file opened by URL cannot run out of context.
- Check: code review finds the guard in every PHP file of the theme and the site plugin.
- Kind: WordPress · Status: in force: the theme's `functions.php` has the guard (4c); every new PHP file from now on.

**6.7 Scripts and styles are loaded with `wp_enqueue_script` / `wp_enqueue_style`, with
versions. The child theme writes no `<script>` tags or inline event handlers (`onclick=` and
similar) in templates, patterns or PHP output; data for scripts goes through WordPress's API
(`wp_add_inline_script`) or `data-` attributes.**
- Why: correct loading order and cache busting; scripts can be cached, checked and reviewed;
  nothing of ours stands in the way of a stricter, nonce-based policy later.
- Check: code review and the page source find no script of ours outside enqueued files, and the
  browser tests' CSP check passes.
- Kind: WordPress · Status: in force: the theme writes no script of its own, and the CSP check runs on every dev-site page (4c).

**6.8 Functions, hooks and handles carry a theme prefix; all text is translatable with the
theme's text domain.**
- Why: no clashes with plugins; ready for translation.
- Check: PHPCS (with the `hbmusic` prefix and text domain) and the Theme Check plugin report no
  errors.
- Kind: WordPress · Status: in force through `bin/check` (3d); the theme from step 4.

**6.9 No PHP errors, warnings or notices with debug on.**
- Why: notices hide real problems and leak paths.
- Check: on the local site with `WP_DEBUG` on, every template visited leaves the debug log empty.
- Kind: WordPress · Status: in force on the dev site: a scenario check visits every page and fails on any debug log entry (4c); the old theme's deprecation notice (3a) goes with it at step 9.

## 7. Accessibility

**7.1 WCAG 2.2 level AA.**
- Why: usable by everyone; the common legal and professional standard.
- Check: the automated check (axe) reports no errors, and the manual checks below pass.
- Kind: general · Status: partly: axe at WCAG 2.2 AA on every dev-site page (4c); the manual checks with the visible parts after 2b.

**7.2 Full keyboard use: visible focus, logical order, a skip link, no traps (menus, players,
embeds included).**
- Why: many visitors do not use a mouse.
- Check: every page can be used with the keyboard only.
- Kind: general · Status: planned: after 2b, with the visible parts.

**7.3 Text contrast at least 4.5:1 (3:1 for large text and interface parts).**
- Why: readable in poor conditions and with low vision.
- Check: every text and interface colour pair in the `theme.json` palette meets the ratio.
- Kind: general · Status: planned: 2b (the palette).

**7.4 Every meaningful image has alt text; decorative ones have empty alt. Audio and video have
captions or transcripts where they carry speech.**
- Why: screen-reader users get the same content.
- Check: the media library and the automated check find no meaningful image without alt text,
  and no speech without captions or a transcript.
- Kind: general · Status: planned: with the content, after 2b.

**7.5 Headings in order, landmarks in place, link text that makes sense alone.**
- Why: screen-reader users navigate by them.
- Check: the automated check passes, and each page's heading outline has no skipped level.
- Kind: general · Status: partly: axe checks landmarks and list structure on every dev-site page (4c); headings and link texts with the content after 2b.

**7.6 Media never autoplays with sound.**
- Why: autoplay interferes with screen readers and surprises visitors.
- Check: no page with media starts sound by itself.
- Kind: general · Status: planned: with the visible parts of 5.

## 8. Performance

**8.1 Core Web Vitals "good" on mobile: LCP under 2.5 s, INP under 200 ms, CLS under 0.1.**
- Why: visitor experience and search ranking.
- Check: PageSpeed Insights rates the home page and each template "good" on mobile.
- Kind: general · Status: planned: after 2b, before go-live.

**8.2 Images sized for their slot, in WebP or AVIF where supported, with width and height set;
below-the-fold images lazy-loaded.**
- Why: images are most of a music site's weight.
- Check: PageSpeed Insights reports no oversized or old-format images, and the page source shows
  width, height and lazy loading where expected.
- Kind: general · Status: planned: with the content (the inventory found photos up to 12 MB and
  photos saved as PNG, step 2).

**8.3 Page caching on the server, except for pages with forms (or their nonce is refreshed when
the page loads) and, on a shop, the cart, checkout and account pages; browser caching headers on
static files; compression (Brotli or gzip).**
- Why: fast repeat visits and lower server load; a cached page carries an old nonce, and its form
  then fails a day later.
- Check: the response headers show caching on ordinary pages and none on form pages; a form
  submitted a day after its page was cached still works.
- Kind: WordPress · Status: planned: step 8 (the caching decision), with 5b's form.

**8.4 Fonts self-hosted or from the theme, limited to the weights in use; no render-blocking
third-party scripts.**
- Why: speed and privacy (no visitor data to font services).
- Check: the browser's network panel shows no font or blocking script from another domain.
- Kind: general · Status: planned: 2b (the fonts).

**8.5 Embedded players (audio, video) load only when used, where the provider allows.**
- Why: third-party embeds are heavy and set cookies.
- Check: on a page with an embed, the network panel shows no request to the provider before the
  player is started.
- Kind: general · Status: planned: with the Video page, after 2b.

## 9. Search and sharing

**9.1 One SEO plugin configured (currently `wordpress-seo`): titles, descriptions, canonical URLs
and the XML sitemap.**
- Why: clear signals to search engines; no duplicate pages.
- Check: the sitemap loads, and each page's source shows one canonical link and one title.
- Kind: WordPress · Status: partly: configured on live, with the gaps found in step 2; the new
  site's settings at steps 6 and 9.

**9.2 Structured data describes the artist (for example `MusicGroup` or `Person`) and events
where present.**
- Why: rich results in search.
- Check: Google's Rich Results Test passes for the home page.
- Kind: general · Status: planned: step 9 (the live site describes a company today, step 2).

**9.3 Social sharing tags (Open Graph and similar) with a proper image.**
- Why: links look right when shared.
- Check: a sharing-preview checker shows the title, description and image for each main page.
- Kind: general · Status: planned: 2b (the image) and step 9; the live site has no default
  sharing image (step 2).

**9.4 Old URLs keep working: permanent (301) redirects from every old URL that changes.**
- Why: keeps links and search ranking after the rebuild.
- Check: every URL of the old site (from the database) answers 200 or 301 on the new site.
- Kind: general · Status: planned: step 9.

**9.5 `robots.txt` allows the live site; staging and local copies are not indexed.**
- Why: duplicates do not compete with the real site.
- Check: the live `robots.txt` allows crawling, and every other copy has "discourage search
  engines" on.
- Kind: WordPress · Status: done for the local copy (3a) and staging (3g-1); the live site
  allows search engines (step 2).

## 10. Privacy and legal

**10.1 A privacy policy page that says what is collected (forms, comments, analytics, embeds) and
why.**
- Why: required by privacy law in many places; builds trust.
- Check: the page exists, matches what the site collects, and is linked in the footer.
- Kind: general · Status: planned: step 5b (before the request form goes live).

**10.2 Collect only what is needed; no analytics or tracking cookies without the consent the
visitors' location requires.**
- Why: privacy law (GDPR and similar).
- Check: the cookies set on a first visit, before any choice, are only the necessary ones.
- Kind: general · Status: planned: step 5b (the form) and step 6 (FluentSMTP's email log
  retention).

**10.3 Contact and sign-up forms protected against spam without hurting accessibility.**
- Why: spam floods the inbox and the database.
- Check: a test submission arrives, a scripted spam submission is stopped, and the form passes
  the accessibility checks.
- Kind: general · Status: planned: step 5b.

**10.4 Media on the site is the artist's own or licensed for this use.**
- Why: copyright.
- Check: every item in the media library is the artist's own or has its licence noted.
- Kind: general · Status: planned: with the content; the clips' licensing question is the
  user's (5c).

## 11. Email and domain

**11.1 The site sends mail through an authenticated mail service, not the server's own
`mail()`.**
- Why: server mail is often lost as spam.
- Check: a test message arrives and passes SPF and DKIM.
- Kind: WordPress · Status: partly: FluentSMTP sends through Mailpit locally (3b); the mail
  service at step 8 (the live site's mail is unreliable today).

**11.2 SPF, DKIM and DMARC records for the domain.**
- Why: stops others from sending mail as the domain.
- Check: DNS lookups show all three, and a mail-tester scores a test message 9/10 or better.
- Kind: general · Status: planned: step 8.

**11.3 Domain registration locked, auto-renew on, 2FA on the registrar and DNS accounts.**
- Why: losing the domain loses the site and its mail.
- Check: the registrar shows the lock and auto-renew on, and both accounts ask for a second
  factor at login.
- Kind: general · Status: planned: step 8.

**11.4 A CAA record naming the certificate authority in use; DNSSEC where the registrar offers it
as a setting.**
- Why: limits who can issue certificates; protects DNS answers.
- Check: DNS lookups show the CAA record (and DNSSEC where offered).
- Kind: general · Status: planned: step 8.

## 12. Backups and recovery

**12.1 Automatic backups of files and database, kept off the server (not only at the host):
weekly for a site whose content rarely changes, at least daily once it collects anything
(requests, orders), and on a shop also right before every update.**
- Why: a host failure or compromise does not take the backups too; the frequency matches how
  much would be lost.
- Check: the backup log shows the expected rhythm, and the latest backup is present in the
  off-site store.
- Kind: general · Status: deliberately not met as written for this site (plan D27): Hostinger
  backs up daily at the host, and the off-site copy is kept by hand, the content exported into
  `data/` after changes and at least monthly; revisited when several sites make that
  unmanageable.

**12.2 Backups encrypted, and access to them limited like production access.**
- Why: backups hold the same secrets as the site.
- Check: the backup tool shows encryption on, and only the user can reach the off-site store.
- Kind: general · Status: deliberately not met as written for this site (plan D27): the
  off-site copy is a content export, which holds no passwords, keys or two-factor secrets (it does
  hold the author's login name and email); it lives in `data/` on the user's computer, not
  versioned, and in the user's own backup of that folder. The free UpdraftPlus could not encrypt.

**12.3 A restore is tested before go-live, then once a year and before major changes.**
- Why: an untested backup is not a backup.
- Check: a restore onto a local or staging copy works, with its date recorded in the plan.
- Kind: general · Status: planned: step 9, both ways of D27: the latest content export imported
  into a fresh site, and a Hostinger restore tried on staging. (The local copy of 3a, rebuilt from
  the host's export by `bin/local-import`, was removed at 5a-2.)

## 13. Deployment and migration

**13.1 Changes are made and checked locally (and on staging where there is one) before
production; the theme is deployed from the repository, never edited on the server.**
- Why: production only ever runs reviewed code.
- Check: the deployed theme files match a commit on `main`.
- Kind: general · Status: planned: 3g-3 (staging), step 9 (live).

**13.2 URL changes in the database use a tool that handles serialized data (`wp search-replace`).**
- Why: a plain text replace corrupts serialized options and widgets.
- Check: after the move, the site and its widgets work and no old address is left.
- Kind: WordPress · Status: in force in `bin/local-import` (3a); the moves at steps 9 and 10.

**13.3 Migration has a written checklist, a fresh backup taken just before it, and a way back
(DNS to the previous target, or restore).**
- Why: a failed launch can be undone quickly.
- Check: the plan's checklist for the move is ticked, with the backup's date and the way back
  named.
- Kind: general · Status: planned: steps 9 and 10.

**13.4 DNS TTL lowered a day before the switch and raised again after.**
- Why: the switch takes effect quickly and can be reversed quickly.
- Check: DNS lookups show the low TTL before the switch and the normal one after.
- Kind: general · Status: planned: step 10 (the move to a new host; go-live at Hostinger needs no
  DNS change).

**13.5 A deploy key does exactly one thing: on the server it is restricted to a forced command
and one destination (for example rsync's daemon mode over SSH, or `rrsync`), with no shell; the
private key exists only in the CI's secret store; the server's identity is pinned. It is trusted
only after attempts to misuse it have failed.**
- Why: on shared hosting one SSH account reaches every site in the plan; an unrestricted key in
  CI would hand all of them to anyone who gets into the CI.
- Check: every attempt to misuse the key (a shell, another command, another path, another
  destination) is refused, and `authorized_keys` holds only the expected lines.
- Kind: general · Status: done for staging (3g-2); the live destination at step 9, proven the
  same way.

## 14. Monitoring

**14.1 Uptime monitoring with alerts.**
- Why: outages are noticed before visitors report them.
- Check: a test alert reaches the user.
- Kind: general · Status: planned: step 8.

**14.2 Alerts for certificate and domain expiry.**
- Why: expiry takes the site down without warning.
- Check: the monitor lists the certificate and the domain with their expiry dates.
- Kind: general · Status: planned: step 8.

**14.3 Security scanning (Wordfence or the host's) with alerts for changed core files and
known-vulnerable plugins.**
- Why: compromises are found early.
- Check: scans run on a schedule, the latest result is clean, and alerts go to the user's email.
- Kind: WordPress · Status: planned: step 8 (Wordfence is installed on live and staging).

**14.4 The PHP error log and the web server log are reviewed after each deployment; between
deployments, the alerts of 14.1 and 14.3 do the watching.**
- Why: problems are found before they grow, without a routine nobody keeps.
- Check: the deployment checklist shows the logs reviewed.
- Kind: general · Status: planned: 3g-3 onwards.

**14.5 Site Health (Tools → Site Health) shows no critical issues, checked at go-live and after
each deployment.**
- Why: WordPress's own check finds problems such as an outdated PHP, failed loopback requests or
  a broken scheduler.
- Check: the Site Health status shows no critical issues.
- Kind: WordPress · Status: planned: 3g-3 onwards and step 9.

## 15. If the site sells (WooCommerce)

*Not used by this site; kept for the template (D18). Sections 1–14 apply to shops as well; these
items come on top. Kind: shop · Status for each: not applicable, the site sells nothing.*

**15.1 Card data never touches the server: payments go through the provider's hosted fields or a
redirect to the provider.**
- Why: keeps the shop at the lightest card-industry security level (PCI DSS SAQ A); a server that
  never sees card numbers cannot leak them.
- Check: the checkout page's payment fields come from the provider's domain, and the server's
  logs and database hold no card numbers.

**15.2 Staging holds no real customers or orders, and its payment gateways run in test mode;
realistic data, where needed, is anonymized.**
- Why: customer data on a copy is personal data in a second, weaker place; a live gateway on
  staging takes real money.
- Check: staging's gateways show test mode, and its customer list holds only test accounts.

**15.3 WooCommerce's High-Performance Order Storage (HPOS) is on, and a real cron runs its
background queue (2.7).**
- Why: HPOS is WooCommerce's current order storage, faster and better separated; the queue sends
  order emails and updates stock.
- Check: WooCommerce → Settings → Advanced → Features shows HPOS on, and Tools → Scheduled
  Actions shows no overdue actions.

**15.4 The checkout is protected against card testing (criminals trying stolen card numbers):
limits on payment attempts per visitor and per period, and the payment provider's fraud tools
on.**
- Why: a shop used for card testing pays fees for every attempt, and the provider may close the
  account.
- Check: a burst of failed test payments is stopped after the limit, and the provider's dashboard
  shows its fraud tools on.

**15.5 A nonce-based Content Security Policy (3.2), and the cart, checkout and account pages kept
out of the page cache (8.3).**
- Why: payment pages are the most valuable target for injected scripts that read what customers
  type.
- Check: the checkout's response headers show the nonce-based policy and no caching; the browser
  tests show no CSP violations.

**15.6 Shop managers have their own accounts with the Shop Manager role, not Administrator, and
two-factor login (4.1, 4.2).**
- Why: day-to-day shop work needs no right to install plugins.
- Check: the users list shows each shop manager with that role and two-factor login on.

**15.7 WooCommerce's privacy settings keep customer data only as long as needed (guest orders,
failed and cancelled orders anonymized or removed after a set time); terms, refund, shipping and
privacy pages are published and linked at checkout.**
- Why: privacy law and consumer law; less stored data means less to lose.
- Check: WooCommerce → Settings → Accounts & Privacy shows retention periods set, and the
  checkout links the pages.

**15.8 Order emails go through the authenticated mail service (11.1) and are tested for each
order status.**
- Why: a lost order confirmation costs trust and causes support work.
- Check: a test order produces each email, and each passes SPF and DKIM.

## 16. Practices deliberately not used

Recorded so they are not added later:

- **Hiding or renaming the login address:** it hides rather than protects, breaks password
  resets and some plugins, and two-factor login with attempt limits (4.2, 4.3) does the real work.
- **Changing the database table prefix:** no real protection; any attacker who can run queries
  can read the prefix.
- **`DISALLOW_FILE_MODS`:** blocks every update from the dashboard, which conflicts with prompt
  updates (5.3). `DISALLOW_FILE_EDIT` (2.2) covers the real risk.
- **More than one security plugin:** they get in each other's way, and each adds code that can
  have holes.
