#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

test_AG_M() {
  local tmp proj init cfg
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  proj="$tmp/p"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="${tmp}/h" \
    bash "$init" --scope=config --agents=cursor,trea --force "$proj/docs"
  cfg="$proj/.docsconfig"
  assert_file_exists "$cfg"
  assert_file_contains "$cfg" "AGENT_DIRS="
  assert_file_contains "$cfg" ".cursor"
  assert_file_contains "$cfg" ".trea"
}

