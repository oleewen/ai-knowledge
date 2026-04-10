#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

test_XC_H() {
  local init out code
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  assert_file_exists "$init"
  set +e
  out="$(bash "$init" --help 2>&1)"
  code=$?
  set -e
  assert_eq 0 "$code" "XC-H --help"
  assert_output_contains "$out" "用法"
}

test_XC_N01() {
  local init out code
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  out="$(bash "$init" --nope 2>&1)"
  code=$?
  set -e
  assert_eq 1 "$code" "XC-N01"
  assert_output_contains "$out" "未知选项"
}

test_XC_N02() {
  local init out code tmp
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  mkdir -p "$tmp/a/docs" "$tmp/b/docs"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="${tmp}/h" \
    bash "$init" --force "$tmp/a/docs" "$tmp/b/docs" 2>&1)"
  code=$?
  set -e
  assert_eq 1 "$code" "XC-N02"
  assert_output_contains "$out" "多余的参数"
}

test_XC_R() {
  local tmp proj init
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  proj="$tmp/brand_new_proj"
  # 工程根与 docs 均不存在；-r 创建工程根
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  run_expect_exit 0 -- env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="${tmp}/h" \
    bash "$init" -r --scope=config --force "$proj/docs"
  assert_file_exists "$proj/.docsconfig"
}

#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

test_XC_H() {
  local init out code
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  assert_file_exists "$init"
  set +e
  out="$(bash "$init" --help 2>&1)"
  code=$?
  set -e
  assert_eq 0 "$code" "XC-H --help"
  assert_output_contains "$out" "用法"
}

test_XC_N01() {
  local init out code
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  out="$(bash "$init" --nope 2>&1)"
  code=$?
  set -e
  assert_eq 1 "$code" "XC-N01"
  assert_output_contains "$out" "未知选项"
}

test_XC_N02() {
  local init out code tmp
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  mkdir -p "$tmp/a/docs" "$tmp/b/docs"
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  set +e
  out="$(env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="${tmp}/h" \
    bash "$init" --force "$tmp/a/docs" "$tmp/b/docs" 2>&1)"
  code=$?
  set -e
  assert_eq 1 "$code" "XC-N02"
  assert_output_contains "$out" "多余的参数"
}

test_XC_R() {
  local tmp proj init
  tmp="$(mktemp -d)"
  trap "rm -rf \"$tmp\"" EXIT
  proj="$tmp/p"
  mkdir -p "$proj/docs"
  git -C "$proj" init -q
  init="${DOCS_INIT_TEST_REPO_ROOT}/scripts/docs-init.sh"
  # -r：工程根已存在时为 no-op；DOC_ROOT 须在 Git 工作区内（见 docs-init 校验）
  run_expect_exit 0 -- env REPO_ROOT="${DOCS_INIT_TEST_REPO_ROOT}" HOME="${tmp}/h" \
    bash "$init" -r --scope=config --force "$proj/docs"
  assert_file_exists "$proj/.docsconfig"
}
