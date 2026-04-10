#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

test_SC_A_S() {
  local tmp home init out code
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  home="${tmp}/fakehome"
  mkdir -p "$home"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$home" \
    bash "$init" --scope=skills --dry-run 2>&1)"
  code=$?
  set -e
  assert_eq 0 "$code" "SC-A-S"
  assert_output_contains "$out" "dry-run"
  [[ ! -e "$home/.cursor/skills" ]] || test_fail "SC-A-S dry-run 不应在 fake HOME 落盘 skills"
}

test_SC_A_RS() {
  local tmp proj home init
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  proj="$tmp/p"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  home="${tmp}/h"
  mkdir -p "$home"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$home" \
    bash "$init" --scope=rs --dry-run --force "$proj/docs" 2>&1
}

test_SC_X_M() {
  local tmp home init out
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  home="${tmp}/h"
  mkdir -p "$home"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$home" \
    bash "$init" --scope=skills --mode=central --dry-run 2>&1 || true)"
  assert_output_contains "$out" "仅在 scope=ck、knowledge 时生效"
}

