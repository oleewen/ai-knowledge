#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
for scope in config knowledge; do
  project="$TMP_DIR/$scope-project"
  "$BASH" "$DOCS_INSTALL_SCRIPT" --scope="$scope" --target "$project/docs" -r --dry-run >"$TMP_DIR/$scope.out" 2>&1 \
    || { cat "$TMP_DIR/$scope.out" >&2; fail "不存在目标的 $scope dry-run 应完成"; }
  [[ ! -e "$project" ]] || fail 'dry-run 不应创建工程根或文档目录'
  assert_contains 'DOC_DIR=docs' "$TMP_DIR/$scope.out"
done
mkdir -p "$TMP_DIR/config-only"
"$BASH" "$DOCS_INSTALL_SCRIPT" --scope=config --target "$TMP_DIR/config-only/not-created" >"$TMP_DIR/config.out" 2>&1
assert_file_exists "$TMP_DIR/config-only/.docsconfig"
[[ ! -e "$TMP_DIR/config-only/not-created" ]] || fail 'scope=config 只写配置，不创建 DOC_DIR'
pass '不存在目标可完整预览且零写；config 无需创建 DOC_DIR'
