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

# The throwaway server of bin/deploy's test (tests/scenario/generic/dev-deploy-server.sh,
# template plan 1.4d-3): Docker's official Alpine image by digest, with OpenSSH's server and rsync
# from Alpine's own repository at exact versions, all checked by the user's rules on 2026-11-21
# (image published 2026-11-08, packages 2026-11-05 and 2026-11-07). Alpine keeps only each
# package's newest version, so these break the test's build when Alpine replaces one; the weekly
# versions check (bin/versions-check) opens an issue that day, and the pin is raised at once, with
# no wait (1.4d-4), until the image is built once and stored (2.1).
readonly DEPLOY_TEST_SERVER_BASE_IMAGE="alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf"
readonly DEPLOY_TEST_SERVER_OPENSSH_VERSION="10.3_p1-r2"
readonly DEPLOY_TEST_SERVER_RSYNC_VERSION="3.5.2-r1"

# The downloaded plugins (Contact Form 7, Yoast SEO) are pinned in site-packages/composer.json and
# its lock file, and raised by Dependabot (template plan T8).

# The download caches' volume names are built from the site's slug (load_site_volume_names in
# tools/site-settings.sh).
