#!/usr/bin/env bash
# The last check of bin/test (plan step 8c): after every scenario and browser test has run,
# WordPress's debug log is still empty. dev-no-php-notices.sh visits the visitor pages early in the
# run; this catches what the later tests cause, such as a notice in the admin screens the browser
# tests use. Named outside the dev-*.sh pattern, so bin/test runs it last, on its own.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

main() {
  load_settings
  expect_empty_debug_log
}

main "$@"
