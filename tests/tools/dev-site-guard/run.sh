#!/usr/bin/env bash
# Tests the dev-site guard (tools/dev-site-guard.sh, template plan 1.6c-2) on known examples, run by
# bin/check every time, with a stand-in for docker that answers what the example sets: a free port
# and the expected site's own dev site pass; another site's dev site is refused, naming both sites
# and the command to stop the other by name. Needs bash, sed, sort and paste.
set -Euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HERE
# shellcheck source=tools/dev-site-guard.sh
source "$HERE/../../../tools/dev-site-guard.sh"

log() { printf '%s [dev-site guard tests] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }

STAND_IN_DIR=""

# The stand-in prints the projects in RUNNING_PROJECTS, one per line, for "docker ps", and records
# the port it was asked about, so the examples can check the guard asked for the right one.
write_stand_in() {
  cat >"$STAND_IN_DIR/docker" <<'EOF'
#!/usr/bin/env bash
[[ "$1" == ps ]] || exit 3
printf '%s\n' "$*" >"$STAND_IN_DIR/asked"
printf '%b' "${RUNNING_PROJECTS:-}"
EOF
  chmod +x "$STAND_IN_DIR/docker"
}

# expected problem (empty: passes) ## what the example is ## projects docker reports
readonly EXAMPLES=(
  " ## a free port ## "
  " ## the expected site's own dev site ## dts-starter-dev\n"
  "port 10102 is held by the dev site hbmusic-dev, not dts-starter-dev; stop that one first: docker compose -p hbmusic-dev stop ## another site's dev site ## hbmusic-dev\n"
  "port 10102 is held by the dev site hbmusic-dev, not dts-starter-dev; stop that one first: docker compose -p hbmusic-dev stop ## another site's dev site, one container per line ## hbmusic-dev\nhbmusic-dev\n"
)

expect_example() {
  local expected="$1" what="$2" projects="$3" problem
  problem="$(RUNNING_PROJECTS="$projects" STAND_IN_DIR="$STAND_IN_DIR" running_dev_site_problem 10102 dts-starter-dev)"
  [[ "$problem" == "$expected" ]] || { log "FAIL  $what: expected \"$expected\", got \"$problem\""; return 1; }
  grep -qF -- '--filter publish=10102' "$STAND_IN_DIR/asked" || { log "FAIL  $what: docker was not asked about port 10102"; return 1; }
  log "ok    $what"
}

main() {
  local entry expected what projects failed=0
  STAND_IN_DIR="$(mktemp -d)"
  trap 'rm -rf "$STAND_IN_DIR"' EXIT
  export STAND_IN_DIR
  write_stand_in
  PATH="$STAND_IN_DIR:$PATH"
  for entry in "${EXAMPLES[@]}"; do
    expected="${entry%% ## *}"
    expected="${expected% }"
    expected="${expected# }"
    what="${entry#* ## }"
    projects="${what#* ## }"
    what="${what%% ## *}"
    expect_example "$expected" "$what" "$projects" || failed=1
  done
  return "$failed"
}

main "$@"
