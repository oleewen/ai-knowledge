#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

test_SC_K_D() {
  local tmp proj init n
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  proj="$tmp/p"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="${tmp}/h" \
    bash "$init" --dry-run --scope=knowledge --force "$proj/docs"
  n="$(count_files_under "$proj/docs")"
  assert_eq 0 "$n" "SC-K-D dry-run 不落盘"
}

test_SC_K_E() {
  local init code th
  th="$(mktemp -d)"
  trap 'rm -rf "$th"' EXIT
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$th" \
    bash "$init" --scope=knowledge --force 2>/dev/null
  code=$?
  set -e
  assert_eq 2 "$code" "SC-K-E"
}

