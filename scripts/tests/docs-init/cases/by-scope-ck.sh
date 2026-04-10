#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

test_SC_CK_D() {
  local tmp proj docs init out n
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  proj="$tmp/p"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  docs="$proj/docs"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="${tmp}/h" \
    bash "$init" --dry-run --force "$docs" 2>&1 || true)"
  assert_output_contains "$out" "[dry-run]"
  n="$(count_files_under "$docs")"
  assert_eq 0 "$n" "SC-CK-D"
}

test_SC_CK_H() {
  local tmp home init out cfg
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  home="${tmp}/h"
  mkdir -p "$home"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$home" \
    bash "$init" --force 2>&1 || true)"
  assert_output_contains "$out" "未指定工程文档目录"
  cfg="$home/.docsconfig"
  assert_file_exists "$cfg"
}

