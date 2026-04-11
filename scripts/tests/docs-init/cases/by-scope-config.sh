#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

_new_git_project_with_docs() {
  local tmp="$1"
  local proj="$tmp/p"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  printf '%s' "$proj"
}

test_SC_C_D() {
  local tmp proj init out code cfg
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  proj="$(_new_git_project_with_docs "$tmp")"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="${tmp}/h" \
    bash "$init" --dry-run --scope=config --force "$proj/docs" 2>&1)"
  code=$?
  set -e
  assert_eq 0 "$code" "SC-C-D"
  cfg="$proj/.docsconfig"
  [[ -f "$cfg" ]] && test_fail "SC-C-D: dry-run 不应写出真实 .docsconfig"
  assert_output_contains "$out" "Would write"
}

test_SC_C_W() {
  local tmp proj init cfg
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  proj="$(_new_git_project_with_docs "$tmp")"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="${tmp}/h" \
    bash "$init" --scope=config --force "$proj/docs"
  cfg="$proj/.docsconfig"
  assert_file_exists "$cfg"
  assert_file_contains "$cfg" "DOC_ROOT="
  assert_file_contains "$cfg" "REPO_ROOT="
  assert_file_contains "$cfg" "DOC_DIR="
}

test_SC_C_H() {
  local tmp home init out code
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  home="${tmp}/h"
  mkdir -p "$home"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$home" \
    bash "$init" --scope=config --force 2>&1)"
  code=$?
  set -e
  assert_eq 1 "$code" "SC-C-H config 无文档目录应失败"
  assert_output_contains "$out" "必须指定"
}

test_SC_C_M() {
  local tmp home init out code cfg idx_before idx_after copy proj
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  home="${tmp}/h"
  mkdir -p "$home"
  proj="$tmp/p"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  copy="$(docs_init_test_copy_repo "$tmp/central_copy")"
  idx_before="$(docs_init_test_file_sha "$copy/application/INDEX_GUIDE.md")"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  out="$(env REPO_ROOT="$copy" HOME="$home" \
    bash "$init" --scope=config --mode=central --force "$proj/docs" 2>&1)"
  code=$?
  set -e
  assert_eq 0 "$code" "SC-C-M"
  assert_output_contains "$out" "仅在 scope=knowledge 时生效"
  cfg="$proj/.docsconfig"
  assert_file_exists "$cfg"
  idx_after="$(docs_init_test_file_sha "$copy/application/INDEX_GUIDE.md")"
  assert_eq "$idx_before" "$idx_after" "SC-C-M 不应改副本 INDEX_GUIDE"
}

