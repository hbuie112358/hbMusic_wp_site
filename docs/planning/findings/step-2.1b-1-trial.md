# Step 2.1b-1: the tools trial

*In this file "the user" is the person Claude works with, and "Claude" is the assistant.*

A throwaway public repository in the organization, `trial-tools-2026-11-24` (the user's yes,
2026-11-24; deleted after the trial), tried how a site gets the tools through Composer and calls
their reusable workflow, before 2.1b's design was fixed. Nothing in this repository was changed.
Its branch `tools` held a tiny tools package (one bash command, one reusable workflow), tagged
`v0.1.0` and `v0.2.0`; its default branch `main` a stand-in site requiring the tools at exactly
0.1.0 (Composer's `vcs` repository, `config.bin-dir: "bin"`), calling the workflow pinned by
commit, with a Dependabot file grouping Composer and GitHub Actions. Composer ran in the pinned
`composer:2.11.1` container, without a GitHub token.

## Composer

- **No token needed** for a public repository: the install from the tag worked without one.
- **The lock records the tag's exact commit** (`source.reference` and `dist.reference`, the
  commit of `v0.1.0`), with an empty `shasum`, as for WordPress.org's zips (T8): the commit is
  the fingerprint.
- **The download address is `api.github.com`'s zipball,** where GitHub limits requests without a
  login. Not a problem measured; the reusable workflow can pass its own read-only token to
  Composer (2.1c).
- **The installed copy is the release's files only** (no `.git`), in `vendor/<vendor>/<name>/`.
- **`bin/` gets a proxy script, not a link.** Composer writes a small `sh` script per command into
  the bin folder, which `exec`s the real file. So inside the tool, `BASH_SOURCE[0]` is the real
  path in `vendor/`: the tool finds its own folder from it, as the scripts do now.
- **The current folder is wherever the user ran the command** (run from a subfolder, it was the
  subfolder), so the tools cannot take it as the site's folder.
- **The proxy exports `COMPOSER_RUNTIME_BIN_DIR`, the site's `bin/` folder;** its parent is the
  site's folder. So a tool run through the proxy knows both its own folder and the site's.

## The reusable workflow

- **It runs in the caller's context:** `github.repository`, `github.workflow_ref` and
  `github.workflow_sha` all named the caller (`caller.yml` at the stand-in site's commit).
  `github.job_workflow_sha` was empty.
- **Nothing is on disk before a checkout, and the default checkout is the caller's commit,** not
  the tools'. So the called workflow cannot read its own scripts without a second checkout, and
  does not know its own commit to check out.
- **Consequence for the design:** the reusable workflow checks out the site and runs the site's
  Composer install, which brings exactly the tools release the site's `composer.lock` records.
  The workflow's own pin then decides only the workflow's steps; a check that both pins name the
  same commit covers the rest.
- Caveat: the trial's caller and workflow were in one repository (on different branches); the
  context and checkout named the caller's branch and commit, not the tools', so the result does
  not depend on that. A caller on the user's personal account is confirmed at 2.1c's first call.

## Dependabot

- **It starts when its file changes on the default branch.** The file arrived on `main` before
  `main` was made the default branch, and nothing ran for 15 minutes; a one-line change to the
  file on the default branch started it at once.
- **The multi-ecosystem group works as a mechanism:** both jobs (Composer and GitHub Actions) ran
  under the one group, `site-tools`, the job definition showing `"multi-ecosystem-update":true`.
- **Not settled, because of the trial's own shortcut:** the Composer job failed ("Your
  requirements could not be resolved to an installable set of packages"), and the Actions job
  found "Latest version is 0.1.0" although `v0.2.0` was on GitHub (`git ls-remote`). Hypothesis,
  not confirmed: the site and the tools shared one repository, so Composer also saw the
  repository's `main` as a package named like the site itself, and Dependabot may treat a workflow
  of the same repository differently. A fair test needs the site and the tools in two
  repositories.

**Second round, the site in a repository of its own** (`trial-site-2026-11-24`, the user's yes;
the tools' repository left with only its `tools` branch and tags):

- **Composer side: works.** One grouped pull request ("Bump the "site-tools" group with 1 update
  across multiple ecosystems") raised `dts/trial-tools` from 0.1.0 to 0.2.0 in `composer.json`
  and `composer.lock`, the lock recording `v0.2.0`'s exact commit. Dependabot's Composer (2.10.3)
  also lowered the lock's `plugin-api-version` from 2.11.0 to 2.9.0, harmless.
- **Actions side: the reusable workflow pinned by commit was never raised,** in three runs:
  with bare tags ("Latest version is 0.1.0", `v0.2.0` on GitHub); with GitHub Releases for both
  tags (the same); with 1.x tags on the same commits and the comment naming `v1.0.0` ("Latest
  version is 1.0.0", `v1.1.0` on GitHub). Ruled out: missing GitHub Releases, 0.x versions.
  Exact cause not known; what was observed is that Dependabot does not move a reusable workflow
  pinned by commit here, although the documentation says it keeps reusable workflows up to date.
- **Consequence for the design:** Dependabot can propose a tools release through the Composer
  pin, but the workflow's commit has to be raised by something else; `bin/check`'s check that both
  pins name the same commit fails on such a pull request until it is.

The trial's two repositories are deleted by the user (Claude's GitHub login lacks the
`delete_repo` permission).
