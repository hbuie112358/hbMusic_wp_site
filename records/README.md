# The site's records

*In this file "the user" is the owner of DTS, who runs the site, and "Claude" is the assistant.*

What the DTS Operations Handbook keeps "in the site's records" (chapter 7, "A site's records";
H99): written down as the site is built and run, kept with its code so it has a history and goes
to the customer with the repository at a handover (chapter 9). No secrets (passwords, keys,
recovery codes) and no visitors' personal data are ever written here.

**Where a site's repository is public** (the user's own sites), a record that maps the site's
security or its outside accounts is kept outside the repository instead, in the site's private
records folder on the user's computer, which is backed up off the computer (chapter 4). So is an
exception or an incident note that names a weakness still open. A customer's repository is
private, so everything stays here.

| Record | File | What it holds | Handbook | Public repository |
|---|---|---|---|---|
| Status sheet | `status.md` | Every item of the site standard: done (with how it was checked) or an exception (with its reason) | chapter 12, H16, H75-H77 | here, except open weaknesses |
| Search record | `search.md` | Each page's search phrase, title and description, with the sources and the launch baseline | chapter 12, 9.6; H100 | here |
| Recorded exceptions | `exceptions.md` | Each place the site differs from the handbook on purpose, with its reason and date | H99 | here, except open weaknesses |
| Expected plugin set | `plugin-set.md` | The plugins, must-use plugins and themes the site should have, each with its reason | chapter 12, 5.5; H85 | here |
| Site sheet | `site-sheet.md` | The site's page templates and ready-made sections, one line each on when to use it, for the customer | chapter 10; H89 | here |
| Incident notes | `incidents/<date>-<what>.md` | What happened, the cause, the fix, what changes, without personal data | chapter 5 | here, once nothing is left open |
| Monthly reports | `reports/<year>-<month>.md` | The report as sent to the customer; also the site's uptime record | chapter 10, chapter 5 (H21) | here (a customer's site only) |
| Decisions the customer made | `customer-decisions.md` | Choices left to the customer (a Google Business Profile, a service needing Application Passwords), with the date | chapter 10, chapter 12, 4.7 | here |
| Starter version | `starter.md` | The `dts-site-starter` release the site was created from | template plan T4 | here |
| Settings record | `settings.md` | Settings made by hand (WordPress, the host, outside services), each with its date and reason | chapter 2 | private folder |
| Hosting record | `hosting.md` | The domain, DNS, hosting account and outside services the site uses, and their renewal dates | chapter 2 | private folder |
| Takeover record | `takeover/` | A takeover's evaluation, inventory and content list | chapter 8, H37 | private folder |
| Handover record | `handover.md` | The handover's date, its confirmation and what was handed over | chapter 9, H43 | private folder |

A record is created when the site first has something to write in it, not ahead of time.

## This site (howardbuiemusic.com)

The repository is public. Here: `search.md`, and the launch screenshots of the search panel
(`launch/yoast_screenshots/`, plan 9m). In the private records folder (`data/records/`, never
committed): `settings.md` (which also holds the hosting setup), `content-list-2026-11-17.md` (the
content at go-live), `handover-note.md` (a rehearsal, plan item 1d) and `exceptions-private.md`
(E5). Here as well: `status.md` (every item of the standard, held complete by `bin/check`),
`exceptions.md` and `plugin-set.md` (template plan 1.5d, from `docs/SITE_CHECKLIST.md` and
checks made again on 2026-11-23). There are no monthly reports (the user's own site, with no customer) and no
incidents.
