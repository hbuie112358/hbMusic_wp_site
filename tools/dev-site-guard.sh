#!/usr/bin/env bash
# Which site's dev site is running (template plan 1.6c-2): every site's dev site uses the same port
# (.env's DEV_SITE_PORT) and the one compose.site.yaml, so only one runs at a time, and a build or
# a test run must be sure the running one is the site it was asked for (SITE_DIR). Docker labels
# each container with its Compose project, "<slug>-dev" (tools/site-settings.sh), which names the
# site. Sourced by bin/dev-site and bin/test and tested on known examples, with a stand-in for
# docker, by tests/tools/dev-site-guard/run.sh. Needs docker and sed.

# The Compose project of the container publishing the port, or nothing when none does.
running_dev_site_project() {
  local port="$1"
  docker ps --filter "publish=$port" --format '{{.Label "com.docker.compose.project"}}' | sed '/^$/d' | sort -u
}

# Prints one line when the port is held by another site's dev site, naming both and how to stop
# the other one by name (never every container); nothing when the port is free or held by the site
# expected.
running_dev_site_problem() {
  local port="$1" expected_project="$2" running_project
  running_project="$(running_dev_site_project "$port")"
  [[ -z "$running_project" || "$running_project" == "$expected_project" ]] && return 0
  printf 'port %s is held by the dev site %s, not %s; stop that one first: docker compose -p %s stop\n' \
    "$port" "$(paste -sd ',' <<<"$running_project")" "$expected_project" "$(head -n 1 <<<"$running_project")"
}
