#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

test_FULL_CK() {
  local tmp copy init proj
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  copy="$(docs_init_test_copy_repo "$tmp/repo_full_ck")"
  proj="$tmp/tgt"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="$copy/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="$copy" HOME="${tmp}/h" \
    bash "$init" --force "$proj/docs" 2>&1
  assert_file_exists "$proj/docs/README.md"
  assert_file_exists "$proj/docs/INDEX_GUIDE.md"
  assert_file_not_exists "$proj/docs/DESIGN.md"
  assert_file_not_exists "$proj/docs/CONTRIBUTING.md"
}

test_FULL_CFG() {
  local tmp copy init proj idx_before idx_after
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  copy="$(docs_init_test_copy_repo "$tmp/repo_full_cfg")"
  idx_before="$(docs_init_test_file_sha "$copy/application/INDEX_GUIDE.md")"
  proj="$tmp/tgt"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="$copy/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="$copy" HOME="${tmp}/h" \
    bash "$init" --scope=config --mode=central --force "$proj/docs" 2>&1
  idx_after="$(docs_init_test_file_sha "$copy/application/INDEX_GUIDE.md")"
  assert_eq "$idx_before" "$idx_after" "FULL-CFG INDEX 不变"
  assert_file_exists "$proj/.docsconfig"
}
