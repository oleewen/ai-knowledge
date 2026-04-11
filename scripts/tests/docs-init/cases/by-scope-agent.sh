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
    bash "$init" --scope=agent --dry-run 2>&1)"
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
    bash "$init" --scope=agent --dry-run --force "$proj/docs" 2>&1
}

# --scope=agent 非 dry-run：$AGENT_HOME/scripts 含 docs-config.sh（SSOT 拷贝）与 docsconfig-bootstrap
test_SC_A_SCRIPTS_INSTALLED() {
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
    bash "$init" --scope=agent --force "$proj/docs" 2>&1
  assert_file_exists "$proj/.cursor/scripts/docs-config.sh"
  assert_file_exists "$proj/.cursor/scripts/docsconfig-bootstrap.sh"
  assert_file_contains "$proj/.cursor/scripts/docs-config.sh" "SDX_VERSION"
}

test_SC_X_M() {
  local tmp home init out
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  home="${tmp}/h"
  mkdir -p "$home"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$home" \
    bash "$init" --scope=agent --mode=central --dry-run 2>&1 || true)"
  assert_output_contains "$out" "仅在 scope=knowledge 时生效"
}

