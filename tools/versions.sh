#!/usr/bin/env bash
# The container images, caches and downloads the project's scripts use (bin/check, bin/test,
# bin/tools-update, bin/dev-site), in one place so they cannot drift apart. Sourced, never run.
# The images in compose.dev.yaml (the dev site) are pinned there.
#
# The Playwright image's version must equal @playwright/test in tests/e2e/package.json;
# bin/check fails if they differ.
# shellcheck disable=SC2034 # each script uses only some of these

readonly COMPOSER_IMAGE="composer:2.11.1"
readonly SHELLCHECK_IMAGE="koalaman/shellcheck:v0.10.0"
readonly ACTIONLINT_IMAGE="rhysd/actionlint:1.7.12"
readonly PLAYWRIGHT_VERSION="1.64.1"
readonly PLAYWRIGHT_IMAGE="mcr.microsoft.com/playwright:v${PLAYWRIGHT_VERSION}-noble"

# The dev site's parent theme (bin/dev-site), the version live and staging run. WordPress.org
# publishes no checksums for themes, so the SHA-256 of this exact zip is pinned here, taken
# when the version was chosen and compared with WordPress.org's theme repository; the build
# refuses a download that differs (~/.claude/AI_SECURITY.md, section 4).
readonly PARENT_THEME_SLUG="twentytwentyfive"
readonly PARENT_THEME_VERSION="1.5"
readonly PARENT_THEME_SHA256="f333ce53aaa4049639298247d03480a4bd9b56fa8f0fea0440da262d7d595ba4"

# The booking form's plugin (bin/dev-site, plan step 5e), checked against WordPress.org's checksums.
readonly CONTACT_FORM_7_VERSION="6.2.5"

# The SEO plugin (bin/dev-site, plan step 6, D25), the version live runs, checked against
# WordPress.org's checksums.
readonly YOAST_SEO_VERSION="28.8"

# Download caches survive between runs in named volumes, not in the project folder.
readonly COMPOSER_CACHE_VOLUME="hbmusic_composer_cache"
readonly NPM_CACHE_VOLUME="hbmusic_npm_cache"
