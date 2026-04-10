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
    bash "$init" --mode=central --scope=ck --force 2>&1
  code=$?
  set -e
  assert_eq 1 "$code" "MD-N04 central 无文档"
}

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
    bash "$init" --mode=central --force "$proj/docs" 2>&1
  assert_file_exists "$proj/docs/system/README.md"
  idx_after="$(docs_init_test_file_sha "$copy/application/INDEX_GUIDE.md")"
  assert_eq "$idx_before" "$idx_after" "MD-DF 不应修改副本 INDEX_GUIDE"
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
  assert_file_exists "$proj/docs/company/README.md"
}

test_MD_C01() {
  local tmp copy init proj idx
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  copy="$(docs_init_test_copy_repo "$tmp/repo_md_c01")"
  proj="$tmp/tgt"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="$copy/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="$copy" HOME="${tmp}/h" \
    bash "$init" --mode=central --type=application --app-id=APP-DOCSINIT --force "$proj/docs" 2>&1
  idx="$copy/application/INDEX_GUIDE.md"
  assert_file_contains "$idx" "| APP-DOCSINIT |"
  assert_file_exists "$copy/system/application-DOCSINIT/README.md"
}

#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

test_MD_N04() {
  local init code th
  th="$(mktemp -d)"
  trap "rm -rf \"$th\"" EXIT
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="$th" \
    bash "$init" --mode=central --scope=ck --force 2>&1
  code=$?
  set -e
  assert_eq 1 "$code" "MD-N04 central 无文档"
}

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
    bash "$init" --mode=central --force "$proj/docs" 2>&1
  # system/ 模板平铺至文档根（见 install_org_template_to_docs：dst = docs_abs + rel）
  assert_file_exists "$proj/docs/README.md"
  idx_after="$(docs_init_test_file_sha "$copy/application/INDEX_GUIDE.md")"
  assert_eq "$idx_before" "$idx_after" "MD-DF 不应修改副本 INDEX_GUIDE"
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

test_MD_C01() {
  local tmp copy init proj idx
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  copy="$(docs_init_test_copy_repo "$tmp/repo_md_c01")"
  proj="$tmp/tgt"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="$copy/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="$copy" HOME="${tmp}/h" \
    bash "$init" --mode=central --type=application --app-id=APP-DOCSINIT --force "$proj/docs" 2>&1
  idx="$copy/application/INDEX_GUIDE.md"
  assert_file_contains "$idx" "| APP-DOCSINIT |"
  assert_file_exists "$copy/system/application-DOCSINIT/README.md"
}
