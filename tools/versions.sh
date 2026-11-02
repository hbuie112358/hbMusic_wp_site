#!/usr/bin/env bash
# The container images and caches the project's scripts use (bin/check, bin/test,
# bin/tools-update), in one place so they cannot drift apart. Sourced, never run.
# The images in compose.yaml (the local copy) are pinned there.
#
# The Playwright image's version must equal @playwright/test in tests/e2e/package.json;
# bin/check fails if they differ.
# shellcheck disable=SC2034 # each script uses only some of these

readonly COMPOSER_IMAGE="composer:2.11.1"
readonly SHELLCHECK_IMAGE="koalaman/shellcheck:v0.10.0"
readonly ACTIONLINT_IMAGE="rhysd/actionlint:1.7.12"
readonly PLAYWRIGHT_VERSION="1.64.1"
readonly PLAYWRIGHT_IMAGE="mcr.microsoft.com/playwright:v${PLAYWRIGHT_VERSION}-noble"

# Download caches survive between runs in named volumes, not in the project folder.
readonly COMPOSER_CACHE_VOLUME="hbmusic_composer_cache"
readonly NPM_CACHE_VOLUME="hbmusic_npm_cache"
