#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
PROJECT="$TMP_DIR/project"
mkdir -p "$PROJECT/docs"
printf 'preserve\n' >"$PROJECT/docs/sentinel"
if "$BASH" "$DOCS_INSTALL_SCRIPT" --target "$PROJECT/docs" </dev/null >"$TMP_DIR/out" 2>&1; then
  fail '非空 DOC_DIR 未传 --force 必须拒绝'
fi
assert_file_exists "$PROJECT/docs/sentinel"
grep -Fq -- '--force' "$TMP_DIR/out" || fail '拒绝重装时应提示 --force'
[[ ! -e "$PROJECT/.docs-init" && ! -e "$PROJECT/.docsconfig" ]] || fail '未授权重装不应备份或写配置'
"$BASH" "$DOCS_INSTALL_SCRIPT" --target "$PROJECT/docs" --force >"$TMP_DIR/force.out" 2>&1
[[ ! -e "$PROJECT/docs/sentinel" ]] || fail '--force 应执行重装'
[[ -n "$(find "$PROJECT/.docs-init" -name sentinel -print)" ]] || fail '--force 应备份原文件'
pass '重装非空文档目录必须显式 --force，且仍保留备份'
