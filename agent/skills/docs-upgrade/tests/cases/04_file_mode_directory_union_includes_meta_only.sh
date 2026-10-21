#!/usr/bin/env bash
# 校验 Agent 文件模式评测 fixture；此用例不替代 Agent 的预览/写盘行为评测。
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

FIXTURE_ROOT="$TMP_DIR/fixture"
"$BASH" "$TEST_DIR/../fixtures/file-mode-directory.sh" "$FIXTURE_ROOT" >/dev/null
LOCAL_ROOT="$FIXTURE_ROOT/project/docs/knowledge/business"
META_ROOT="$FIXTURE_ROOT/meta/company/knowledge/business"
(cd "$LOCAL_ROOT" && find . -type f | sort) >"$TMP_DIR/local-files"
(cd "$META_ROOT" && find . -type f | sort) >"$TMP_DIR/meta-files"
comm -12 "$TMP_DIR/local-files" "$TMP_DIR/meta-files" >"$TMP_DIR/both"
comm -23 "$TMP_DIR/local-files" "$TMP_DIR/meta-files" >"$TMP_DIR/local-only"
comm -13 "$TMP_DIR/local-files" "$TMP_DIR/meta-files" >"$TMP_DIR/meta-only"
cat "$TMP_DIR/local-files" "$TMP_DIR/meta-files" | sort -u >"$TMP_DIR/union"
[[ "$(wc -l <"$TMP_DIR/union" | tr -d ' ')" == 5 ]] || fail 'fixture 应含 5 项并集'
printf '%s\n' './README.md' >"$TMP_DIR/expected-both"
printf '%s\n' './BL/BL-RETAIL.md' >"$TMP_DIR/expected-local"
printf '%s\n' './BD/BD-EXAMPLE/BD-EXAMPLE.md' './BD/BD-EXAMPLE/index.md' './BL/BL-EXAMPLE.md' >"$TMP_DIR/expected-meta"
cmp -s "$TMP_DIR/expected-both" "$TMP_DIR/both" || fail '两侧共有 fixture 不正确'
cmp -s "$TMP_DIR/expected-local" "$TMP_DIR/local-only" || fail '本库独有 fixture 不正确'
cmp -s "$TMP_DIR/expected-meta" "$TMP_DIR/meta-only" || fail '元库独有 fixture 不正确'
assert_contains '### 能力边界' "$LOCAL_ROOT/README.md"
assert_contains '## 能力边界' "$META_ROOT/README.md"
assert_file_exists "$FIXTURE_ROOT/project/docs/knowledge/product/outside.md"
assert_contains 'version: 2026.1020.1' "$FIXTURE_ROOT/project/docs/DESIGN.md"
assert_contains 'dir: company' "$FIXTURE_ROOT/project/docs/knowledge-links.yaml"
cp "$LOCAL_ROOT/README.md" "$TMP_DIR/before-retry"
if "$BASH" "$TEST_DIR/../fixtures/file-mode-directory.sh" "$FIXTURE_ROOT" >"$TMP_DIR/retry-output" 2>&1; then
  fail 'fixture 生成器不得覆盖非空目录'
fi
cmp -s "$TMP_DIR/before-retry" "$LOCAL_ROOT/README.md" || fail '拒绝覆盖后已有文件应不变'
assert_dir_not_exists "$FIXTURE_ROOT/project/.docs-init"

pass '文件模式 fixture：5 项真实并集，含 3 项 meta-only；Agent 行为需独立评测'
