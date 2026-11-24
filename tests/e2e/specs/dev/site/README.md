# The site's own browser specs

This folder stays empty in the tools. `bin/test` and `bin/check`'s type check mount the site's own
specs here, read-only, from the site's `tests/browser/` (template plan T19), so they run with the
shared specs, import `@playwright/test` from this folder's packages and may use `../helpers/`.
A site without a `tests/browser/` folder has no specs of its own; `bin/test` says so.

The folder is kept so Docker mounts into a folder that exists, instead of creating one inside the
tools' files.
