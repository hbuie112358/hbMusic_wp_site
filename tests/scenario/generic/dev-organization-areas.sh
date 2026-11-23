#!/usr/bin/env bash
# Scenario (dev site): the theme's organization data names the towns a site serves, each as a
# schema.org City, and a site that lists none (a new site, the starter) gets its organization back
# unchanged, never an empty areaServed (template plan 1.6b). Run through WordPress with the theme
# loaded, on stand-in towns, so it holds for any site's list; the site's own towns are checked on
# its pages by the site's tests.
set -Eeuo pipefail
# shellcheck source=tests/scenario/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

# The organization piece with the given towns (a JSON list), as the theme returns it.
organization_with_towns() {
  dev_compose run --rm -T cli wp eval \
    "echo wp_json_encode( hbmusic_add_areas_served( array( 'name' => 'Example' ), json_decode( '$1', true ) ) );" </dev/null
}

main() {
  local with_towns without_towns
  load_settings
  with_towns="$(organization_with_towns '["Town A, State","Town B, State"]')"
  jq -e '.name == "Example" and .areaServed == [
      {"@type": "City", "name": "Town A, State"}, {"@type": "City", "name": "Town B, State"}]' \
    <<<"$with_towns" >/dev/null ||
    fail "two towns did not become two Cities after the organization's own fields: ${with_towns:0:300}"
  without_towns="$(organization_with_towns '[]')"
  jq -e '. == {"name": "Example"}' <<<"$without_towns" >/dev/null ||
    fail "a site with no towns did not get its organization back unchanged: ${without_towns:0:300}"
  log "towns become Cities, and no towns leave the organization unchanged"
}

main "$@"
