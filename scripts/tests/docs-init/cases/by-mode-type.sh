#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

test_MD_N04() {
  local init code th
  th="$(mktemp -d)"
  trap 'rm -rf "$th"' EXIT
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$th" \
    bash "$init" --mode=central --scope=knowledge --force 2>&1
  code=$?
  set -e
  assert_eq 1 "$code" "MD-N04 central 无文档"
}

test_MD_APP_ID_REMOVED() {
  local init code th out
  th="$(mktemp -d)"
  trap "rm -rf \"$th\"" EXIT
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$th" \
    bash "$init" --mode=central --scope=knowledge --app-id=APP-OLD "$th/p/docs" 2>&1)"
  code=$?
  set -e
  assert_eq 1 "$code" "APP-ID 参数应失败"
  [[ "$out" == *"--app-id 已移除"* ]] || test_fail "缺少迁移提示"
}

# central + system：同步 system/ 模板，登记 system/INDEX_GUIDE，且不修改 application/INDEX_GUIDE
test_MD_DF() {
  local tmp copy init proj idx_before idx_after
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  copy="$(docs_init_test_copy_repo "$tmp/repo_md_df")"
  idx_before="$(docs_init_test_file_sha "$copy/application/INDEX_GUIDE.md")"
  proj="$tmp/tgt"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="$copy/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="$copy" HOME="${tmp}/h" \
    bash "$init" --mode=central --type=system --force "$proj/docs" 2>&1
  assert_file_exists "$proj/docs/README.md"
  idx_after="$(docs_init_test_file_sha "$copy/application/INDEX_GUIDE.md")"
  assert_eq "$idx_before" "$idx_after" "MD-DF 不应修改副本 application/INDEX_GUIDE"
}

test_MD_TP_C() {
  local tmp copy init proj
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  copy="$(docs_init_test_copy_repo "$tmp/repo_md_tp")"
  proj="$tmp/tgt"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="$copy/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="$copy" HOME="${tmp}/h" \
    bash "$init" --type=company --force "$proj/docs" 2>&1
  assert_file_exists "$proj/docs/README.md"
}

# 工程目录名 docsinit → APP-DOCSINIT；无 --app-id
test_MD_C01() {
  local tmp copy init proj idx
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  copy="$(docs_init_test_copy_repo "$tmp/repo_md_c01")"
  proj="$tmp/docsinit"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="$copy/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="$copy" HOME="${tmp}/h" \
    bash "$init" --mode=central --type=application --force "$proj/docs" 2>&1
  idx="$copy/application/INDEX_GUIDE.md"
  assert_file_contains "$idx" "| APP-DOCSINIT |"
  assert_file_exists "$copy/system/application-DOCSINIT/README.md"
}

# central + system：联邦槽位 company/system-<slug>/
test_MD_CENTRAL_SYSTEM_SLOT() {
  local tmp copy init proj
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  copy="$(docs_init_test_copy_repo "$tmp/repo_md_sys_slot")"
  proj="$tmp/platform-core"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="$copy/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="$copy" HOME="${tmp}/h" \
    bash "$init" --mode=central --type=system --scope=knowledge --force "$proj/docs" 2>&1
  assert_file_contains "$copy/system/INDEX_GUIDE.md" "| SYS-PLATFORM-CORE |"
  assert_file_exists "$copy/company/system-PLATFORM-CORE/README.md"
}
