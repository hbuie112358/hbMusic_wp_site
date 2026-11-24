#!/usr/bin/env bash
# The tools' self-check (template plan T20): every check of the tools themselves, as opposed to the
# site they work on. The tools' own tests (tests/tools/*), the checks' refusals tried on known bad
# examples, the explanation of site.json's fields, the tools' PHP (the dev site's must-use plugins),
# their scripts (ShellCheck), their browser tests' types, and the audits of the packages they
# bring. Needs no site: it reads only the tools' own folder, so it runs in the tools' own
# repository; a site's bin/check runs it too while the tools are the site's own (this layout until
# the site installs them through Composer). Only Docker and jq are needed on the host. Every check
# runs even after a failure; the exit status is 1 if any check failed.
set -Euo pipefail

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly TOOLS_DIR
# No site is read here: the libraries below take the site's folder from PROJECT_DIR when they are
# loaded, so it names the tools' own folder, and every check passes its files explicitly.
PROJECT_DIR="$TOOLS_DIR"
readonly PROJECT_DIR
unset SITE_DIR
readonly CHECK_LOG_NAME="check-tools"
# The download caches, shared by every run of the self-check on this computer; a site's own caches
# are named from its slug (load_site_volume_names), which the tools do not have.
readonly COMPOSER_CACHE_VOLUME="site-tools_composer_cache"
readonly NPM_CACHE_VOLUME="site-tools_npm_cache"
# shellcheck source=tools/versions.sh
source "$TOOLS_DIR/tools/versions.sh"
# shellcheck source=tools/check-lib.sh
source "$TOOLS_DIR/tools/check-lib.sh"
# shellcheck source=tools/site-settings.sh
source "$TOOLS_DIR/tools/site-settings.sh"
# shellcheck source=tools/site-packages.sh
source "$TOOLS_DIR/tools/site-packages.sh"

# The broken examples the site.json checks must keep refusing (tests/tools/site-settings/), each
# with the field it breaks, which the refusal must name; the wording around it may change. So a
# check that refuses for the wrong field, or accepts everything after a later edit, fails too.
readonly SITE_SETTINGS_EXAMPLES_DIR="$TOOLS_DIR/tests/tools/site-settings"
readonly SITE_SETTINGS_BAD_EXAMPLES=(
  'missing-field.json|devSiteTitle'
  'unknown-field.json|testPages[0].adress'
  'wrong-type.json|testPages[0].isInMenu'
  'bad-slug.json|slug'
  'bad-local-plugin.json|localPlugins[0]'
  'deploy-missing-live.json|deploy.live'
  'deploy-http-address.json|deploy.live.address'
  'deploy-address-with-path.json|deploy.staging.address'
  'deploy-unknown-page-cache.json|deploy.pageCache'
  'deploy-bad-ssh-host.json|deploy.live.sshHost'
  'deploy-login-in-address.json|deploy.live.address'
  'deploy-same-ssh-host.json|deploy.staging.sshHost'
  'deploy-same-address.json|deploy.staging.address'
)
readonly SITE_SETTINGS_BAD_EXPLANATIONS=(
  'explanation-missing-field.md|theme'
  'explanation-stale-field.md|logoFile'
)
# The same for bin/dev-site's own refusals (tests/tools/dev-site/), which run before it changes
# anything: each broken example must be refused naming what it breaks, each good one accepted.
readonly DEV_SITE_EXAMPLES_DIR="$TOOLS_DIR/tests/tools/dev-site"

# The tools' PHP checkers: the installed checkers, their settings for the tools' own PHP
# (tools/php-check/) and the must-use plugins they check, all read-only.
in_tools_php_check() {
  docker run --rm -w /app \
    -v "$TOOLS_DIR/vendor:/app/vendor:ro" \
    -v "$TOOLS_DIR/tools/php-check:/app/tools/php-check:ro" \
    -v "$TOOLS_DIR/config/dev-mu-plugins:/app/config/dev-mu-plugins:ro" \
    "$COMPOSER_IMAGE" "$@"
}

# Every script in bin/ can be started by its name, as the documentation shows it. A script
# committed without that permission still passes its tests, which start it with bash (bin/deploy
# was, until template plan 1.4e).
scripts_can_be_run() {
  local script missing=0
  for script in "$TOOLS_DIR"/bin/*; do
    [[ -f "$script" && ! -x "$script" ]] || continue
    log "${script#"$TOOLS_DIR"/} cannot be run by its name: it lacks the permission (chmod +x, committed)"
    missing=1
  done
  return "$missing"
}

# Every field is explained in tools/site-settings.md, and nothing else is.
site_json_fields_explained() {
  local differences
  differences="$(site_settings_explanation_differences "$SITE_SETTINGS_EXPLANATION")"
  [[ -z "$differences" ]] && return 0
  log "tools/site-settings.md and tools/site-settings.jq disagree:"
  printf '%s\n' "$differences" | sed 's/^/    /' >&2
  return 1
}

# The site.json checks, tried on known examples: the valid one accepted, text that is not JSON
# refused, and each broken one refused with the problem it was made to show.
site_json_checks_refuse_bad_examples() {
  local failed=0 example
  expect_settings_accepted "valid.json" || failed=1
  expect_settings_not_json "not-json.json" || failed=1
  for example in "${SITE_SETTINGS_BAD_EXAMPLES[@]}"; do
    expect_settings_problem "${example%%|*}" "${example#*|}" || failed=1
  done
  for example in "${SITE_SETTINGS_BAD_EXPLANATIONS[@]}"; do
    expect_explanation_difference "${example%%|*}" "${example#*|}" || failed=1
  done
  return "$failed"
}

expect_settings_accepted() {
  local example="$1" problems
  problems="$(site_settings_problems "$SITE_SETTINGS_EXAMPLES_DIR/$example")" && [[ -z "$problems" ]] && return 0
  log "the valid example $example was refused: $problems"
  return 1
}

expect_settings_not_json() {
  local example="$1"
  site_settings_problems "$SITE_SETTINGS_EXAMPLES_DIR/$example" >/dev/null 2>&1 || return 0
  log "$example is not JSON, but was read as JSON"
  return 1
}

# A problem line starts with the field it is about, then a colon; the rest is wording.
expect_settings_problem() {
  local example="$1" broken_field="$2" problems
  problems="$(site_settings_problems "$SITE_SETTINGS_EXAMPLES_DIR/$example" 2>&1)"
  cut -d: -f1 <<<"$problems" | grep -qxF -- "$broken_field" && return 0
  log "$example should be refused naming $broken_field; reported: ${problems:-(nothing)}"
  return 1
}

# A difference line ends with the field it is about, after a colon.
expect_explanation_difference() {
  local example="$1" broken_field="$2" differences
  differences="$(site_settings_explanation_differences "$SITE_SETTINGS_EXAMPLES_DIR/$example")"
  awk -F': ' '{ print $NF }' <<<"$differences" | grep -qxF -- "$broken_field" && return 0
  log "$example should show a difference naming $broken_field; reported: ${differences:-(nothing)}"
  return 1
}

# bin/dev-site's refusals, and the site packages' rules, tried on known examples
# (tests/tools/dev-site/): an update that changes more than WordPress.org plugins (it may not merge
# itself), a download from outside WordPress.org, a theme with no folder, a test page without its
# content file, a plugin it cannot install, and the booking form without its plugin are each
# refused, naming what is wrong; the good examples are accepted.
dev_site_refusals_refuse_bad_examples() {
  local failed=0
  site_folder_refusals_refuse_bad_examples || failed=1
  site_package_refusals_refuse_bad_examples || failed=1
  return "$failed"
}

# site.json's folders and pages: the theme, the site's own plugins and the test pages' content.
site_folder_refusals_refuse_bad_examples() {
  local examples="$DEV_SITE_EXAMPLES_DIR" valid="$SITE_SETTINGS_EXAMPLES_DIR/valid.json" failed=0
  expect_refusal "missing-theme.json" "theme" \
    "$(site_settings_theme_problem "$examples/missing-theme.json" "$examples/themes")" || failed=1
  expect_refusal "missing-local-plugin.json" "no-such-plugin" \
    "$(site_settings_missing_local_plugins "$examples/missing-local-plugin.json" "$examples/plugins")" || failed=1
  expect_refusal "missing-test-page.json" "no-such-page" \
    "$(site_settings_missing_test_pages "$examples/missing-test-page.json" "$examples/dev-content")" || failed=1
  expect_acceptance "the valid example's folders and pages" \
    "$(site_settings_theme_problem "$valid" "$examples/themes")$(site_settings_missing_local_plugins "$valid" "$examples/plugins")$(site_settings_missing_test_pages "$valid" "$examples/dev-content")" || failed=1
  return "$failed"
}

# site-packages/'s lock file: what may merge itself, where downloads come from, what can be installed.
site_package_refusals_refuse_bad_examples() {
  local examples="$DEV_SITE_EXAMPLES_DIR" good="$DEV_SITE_EXAMPLES_DIR/lock-with-form-plugin.json" failed=0
  expect_refusal "lock-plugin-and-tool-update.json" "composer/installers" \
    "$(site_packages_not_plugins_only "$good" "$examples/lock-plugin-and-tool-update.json")" || failed=1
  # Dependabot's own Composer drops bookkeeping such as "published-time" (seen on #80): not a change.
  expect_acceptance "lock-plugin-update.json" \
    "$(site_packages_not_plugins_only "$good" "$examples/lock-plugin-update.json")" || failed=1
  expect_refusal "lock-with-foreign-download.json" "wpackagist-plugin/example-plugin" \
    "$(site_packages_download_problems "$examples/lock-with-foreign-download.json")" || failed=1
  expect_refusal "lock-with-other-plugin.json" "example-vendor/other-plugin" \
    "$(site_packages_unsupported_plugins "$examples/lock-with-other-plugin.json")" || failed=1
  expect_refusal "lock-without-form-plugin.json" "$FORM_PLUGIN_PACKAGE" \
    "$(site_packages_booking_form_problem "$examples/booking-form.txt" "$examples/lock-without-form-plugin.json")" || failed=1
  expect_acceptance "lock-with-form-plugin.json" \
    "$(site_packages_unsupported_plugins "$good")$(site_packages_booking_form_problem "$examples/booking-form.txt" "$good")$(site_packages_download_problems "$good")" || failed=1
  return "$failed"
}

# A refusal line starts with what it is about, then a colon.
expect_refusal() {
  local example="$1" expected="$2" problems="$3"
  cut -d: -f1 <<<"$problems" | grep -qxF -- "$expected" && return 0
  log "$example should be refused naming $expected; reported: ${problems:-(nothing)}"
  return 1
}

expect_acceptance() {
  local example="$1" problems="$2"
  [[ -z "$problems" ]] && return 0
  log "$example should be accepted; reported: $problems"
  return 1
}

# The Playwright image and the @playwright/test package must be the same version, or the
# tests run against browsers the test runner was not built for.
playwright_versions_match() {
  local package_version
  package_version="$(sed -nE 's/.*"@playwright\/test": "([^"]+)".*/\1/p' "$TOOLS_DIR/tests/e2e/package.json")"
  [[ "$package_version" == "$PLAYWRIGHT_VERSION" ]] && return 0
  log "tests/e2e/package.json has @playwright/test ${package_version:-(none)}; tools/versions.sh has $PLAYWRIGHT_VERSION"
  return 1
}

# The tools' own scripts: the commands, the scenario checks (in their groups' folders, template
# plan 1.3a) and the tools' tests with their stand-in commands, which have no extension (1.3c).
# -x follows each script's `source` of the tools' libraries; the tools' folder is the source path.
shellcheck_tools_scripts() {
  local script scenario_scripts tool_test_scripts scripts=()
  mapfile -t scenario_scripts < <(find "$TOOLS_DIR/tests/scenario" -name '*.sh' -type f | sort)
  mapfile -t tool_test_scripts < <(find "$TOOLS_DIR/tests/tools" -type f \( -name '*.sh' -o -path '*/fakes/*' \) | sort)
  for script in "$TOOLS_DIR"/bin/* "${scenario_scripts[@]}" "${tool_test_scripts[@]}"; do
    scripts+=("/src/${script#"$TOOLS_DIR"/}")
  done
  docker run --rm -w /src \
    -v "$TOOLS_DIR/bin:/src/bin:ro" -v "$TOOLS_DIR/tests:/src/tests:ro" \
    -v "$TOOLS_DIR/tools:/src/tools:ro" \
    "$SHELLCHECK_IMAGE" --severity=style -x --source-path=/src "${scripts[@]}"
}

# Each of the tools' tests on known situations, against stand-ins; nothing goes over the network.
# The versions check's alerts (template plan 1.3c), the debug log rule on sample lines (1.5b), the
# routines' and status sheet's checks (1.5c, 1.5d-4), the page check (1.4b), bin/deploy's checks
# (1.4d), the design-token and site-layer checks and the theme assembly (1.6b, 1.6c), the dev-site
# guard, and how the tools find the site with the tools apart (T19).
tools_test() {
  bash "$TOOLS_DIR/tests/tools/$1/run.sh"
}

run_dependency_checks() {
  run_check "Install the PHP checkers (composer.lock)" in_composer_of "$TOOLS_DIR" composer install --no-interaction --no-progress
  run_check "Composer validation" in_composer_of "$TOOLS_DIR" composer validate --strict --no-check-publish
  run_check "Composer security audit" in_composer_of "$TOOLS_DIR" composer audit --no-interaction
  run_check "npm security audit (browser tests)" npm_audit tests/e2e
  run_check "npm security audit (CSS linter)" npm_audit tools/css-lint
  run_check "npm security audit (the scripts' checker)" npm_audit tools/js-check
}

run_rule_checks() {
  run_check "WordPress Coding Standards (the dev site's must-use plugins)" in_tools_php_check \
    php vendor/bin/phpcs --standard=tools/php-check/phpcs.xml.dist
  run_check "Static analysis (the dev site's must-use plugins)" in_tools_php_check \
    php vendor/bin/phpstan analyse -c tools/php-check/phpstan.neon.dist --no-progress --memory-limit=1G
  run_check "Every script in bin/ can be run" scripts_can_be_run
  run_check "site.json's fields are explained" site_json_fields_explained
  run_check "The site.json checks refuse bad examples" site_json_checks_refuse_bad_examples
  run_check "bin/dev-site's refusals refuse bad examples" dev_site_refusals_refuse_bad_examples
  run_check "Playwright versions match" playwright_versions_match
}

run_tools_tests() {
  run_check "The versions check's alerts" tools_test versions-check
  run_check "The debug log rule on known lines" tools_test debug-log
  run_check "The routines' link check refuses bad examples" tools_test routines
  run_check "The status sheet's check refuses bad examples" tools_test status-sheet
  run_check "The page check on known situations" tools_test site-check
  run_check "The deploy's checks on known situations" tools_test deploy
  run_check "The token check refuses bad examples" tools_test theme-tokens
  run_check "The site-layer check refuses bad examples" tools_test site-layer
  run_check "The theme assembly on known examples" tools_test site-theme
  run_check "The dev-site guard on known examples" tools_test dev-site-guard
  run_check "The tools find the site with the tools apart" tools_test paths
}

main() {
  require_jq
  run_dependency_checks
  run_rule_checks
  run_tools_tests
  run_check "TypeScript (the tools' browser tests)" typescript_check_with
  run_check "Shell scripts (the tools', ShellCheck)" shellcheck_tools_scripts
  report
}

main "$@"
