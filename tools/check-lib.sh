#!/usr/bin/env bash
# What a site's checks (bin/check) and the tools' self-check (tests/tools/check-tools.sh) share
# (template plan T20): the runner that keeps going after a failure and reports at the end, and the
# checks both run on packages they both use (Composer, npm). Sourced, never run; the sourcing
# script defines TOOLS_DIR, CHECK_LOG_NAME (the name its log lines carry) and, before using the
# containers, COMPOSER_CACHE_VOLUME and NPM_CACHE_VOLUME, and sources tools/versions.sh. A site's own checks
# (tests/checks/*.sh) may use run_check, log, PHPCS_ENTRY and PHPSTAN_ENTRY.

FAILED_CHECKS=()

# The PHP checkers are started by their packages' own files, relative to the folder holding
# vendor/, never by Composer's launchers in vendor/bin/: a site installs the tools with its
# bin-dir set to bin/ (template plan T18), which puts every package's launchers there and leaves
# vendor/bin/ empty. The packages' own files stay in vendor/ whatever the bin-dir.
readonly PHPCS_ENTRY="vendor/squizlabs/php_codesniffer/bin/phpcs"
readonly PHPSTAN_ENTRY="vendor/phpstan/phpstan/phpstan"

log() { printf '%s [%s] %s\n' "$(date +%H:%M:%S)" "${CHECK_LOG_NAME:-check}" "$*" >&2; }

# Runs one check by name; a failure is recorded and the next check still runs, so one run shows
# everything.
run_check() {
  local name="$1"
  shift
  log "--- $name"
  if "$@"; then
    log "PASS  $name"
    return
  fi
  log "FAIL  $name"
  FAILED_CHECKS+=("$name")
}

# The exit status of the whole run: 1 if any check failed.
report() {
  if ((${#FAILED_CHECKS[@]} == 0)); then
    log "All checks passed."
    return 0
  fi
  log "${#FAILED_CHECKS[@]} check(s) failed: ${FAILED_CHECKS[*]}"
  return 1
}

# Without jq, the npm audits and the site.json checks would fail with an unrelated-looking error.
require_jq() {
  command -v jq >/dev/null && return 0
  log "jq is not installed; the checks need it on this computer (for example: sudo apt install jq)"
  exit 1
}

# Composer's own steps for the PHP checkers' composer.json in the folder given: composer.json and
# composer.lock read-only (a check never changes the locked versions; bin/tools-update does that on
# purpose), vendor/ writable for the install. The container runs as its root, which rootless Docker
# maps to the user's own account, so vendor/ on the host belongs to the user.
in_composer_of() {
  local composer_dir="$1"
  shift
  mkdir -p "$composer_dir/vendor"
  docker run --rm -w /app \
    -v "$composer_dir/composer.json:/app/composer.json:ro" \
    -v "$composer_dir/composer.lock:/app/composer.lock:ro" \
    -v "$composer_dir/vendor:/app/vendor" \
    -v "$COMPOSER_CACHE_VOLUME:/tmp/composer-cache" -e COMPOSER_CACHE_DIR=/tmp/composer-cache \
    "$COMPOSER_IMAGE" "$@"
}

# Known vulnerabilities in one of the tools' npm packages' locked dependencies (tests/e2e,
# tools/css-lint, tools/js-check); the container sees only the two files.
# Every advisory npm knows for a package folder's locked packages fails the check, except those
# accepted in the folder's audit-exceptions.json: each names one advisory, with its reason and a
# review-by date, after which it fails again. An exception whose advisory npm no longer reports
# also fails, so the file holds only what is still accepted. An accepted risk is decided by the
# user, never added to make a check pass.
npm_audit() {
  local package_dir="$1" report reported exceptions unaccepted
  report="$(npm_audit_json "$package_dir")" || return 1
  reported="$(jq -r '[.vulnerabilities[].via[] | objects | .url | capture("(?<id>GHSA(-[0-9a-z]{4}){3})").id] | unique | .[]' <<<"$report")"
  exceptions="$(audit_exceptions "$TOOLS_DIR/$package_dir/audit-exceptions.json")" || return 1
  unaccepted="$(comm -23 <(sort -u <<<"$reported") <(sort -u <<<"$exceptions") | sed '/^$/d')"
  check_exceptions_still_reported "$reported" "$exceptions" || return 1
  if [[ -n "$unaccepted" ]]; then
    log "advisories not accepted in $package_dir/audit-exceptions.json: $(tr '\n' ' ' <<<"$unaccepted")"
    npm_audit_text "$package_dir"
    return 1
  fi
  [[ -z "$exceptions" ]] || log "accepted until their review date: $(tr '\n' ' ' <<<"$exceptions")"
}

# npm's audit of the folder's lock file, as JSON. npm exits non-zero when it finds advisories, so
# success is judged by the JSON being a report, not by npm's status.
npm_audit_json() {
  local package_dir="$1" report
  report="$(npm_audit_in_container "$package_dir" --json)" || true
  jq -e '.vulnerabilities | type == "object"' >/dev/null 2>&1 <<<"$report" || {
    log "npm audit gave no report for $package_dir"
    return 1
  }
  printf '%s' "$report"
}

# npm's own readable report, shown when an advisory is not accepted.
npm_audit_text() {
  npm_audit_in_container "$1" || true
}

npm_audit_in_container() {
  local package_dir="$1"
  shift
  docker run --rm -w /npm \
    -v "$TOOLS_DIR/$package_dir/package.json:/npm/package.json:ro" \
    -v "$TOOLS_DIR/$package_dir/package-lock.json:/npm/package-lock.json:ro" \
    "$PLAYWRIGHT_IMAGE" npm audit --package-lock-only --audit-level=low "$@"
}

# The accepted advisories' IDs, one per line; none when the file does not exist. Fails on an entry
# without an ID, a reason or a valid review date, and on one past its review date.
audit_exceptions() {
  local file="$1" shown today
  [[ -f "$file" ]] || return 0
  shown="${file#"$TOOLS_DIR"/}"
  today="$(date -u +%F)"
  jq -e 'type == "array" and all(.[]; (.advisory | test("^GHSA(-[0-9a-z]{4}){3}$")) and (.reason | type == "string" and length > 0) and (.reviewBy | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")))' "$file" >/dev/null || {
    log "$shown: each entry needs an advisory (GHSA-…), a reason and a reviewBy date (YYYY-MM-DD)"
    return 1
  }
  jq -e --arg today "$today" 'all(.[]; .reviewBy >= $today)' "$file" >/dev/null || {
    log "$shown: past its review date: $(jq -r --arg today "$today" '[.[] | select(.reviewBy < $today) | "\(.advisory) (\(.reviewBy))"] | join(", ")' "$file")"
    return 1
  }
  jq -r '.[].advisory' "$file"
}

check_exceptions_still_reported() {
  local reported="$1" exceptions="$2" stale
  stale="$(comm -13 <(sort -u <<<"$reported") <(sort -u <<<"$exceptions") | sed '/^$/d')"
  [[ -z "$stale" ]] && return 0
  log "accepted but no longer reported by npm, remove from audit-exceptions.json: $(tr '\n' ' ' <<<"$stale")"
  return 1
}

# The Playwright container type-checks the browser tests (tests/e2e/, where npm installs
# node_modules, ignored by git, from the lock file) with the extra mounts given: a site's own
# specs, read-only, where bin/test mounts them (template plan T19), or none.
typescript_check_with() {
  docker run --rm -w /e2e \
    -v "$TOOLS_DIR/tests/e2e:/e2e" "$@" \
    -v "$NPM_CACHE_VOLUME:/root/.npm" \
    "$PLAYWRIGHT_IMAGE" sh -c 'npm ci --ignore-scripts --no-audit --no-fund --loglevel=error && npx --no-install tsc -p tsconfig.json'
}
