#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
META="$TMP_DIR/meta"
PROJECT="$TMP_DIR/project"
mkdir -p "$META/application" "$PROJECT/docs"
git -C "$META" init -q
printf '# template\n' >"$META/application/README.md"
printf 'preserve\n' >"$PROJECT/docs/sentinel"
for flag in --dry-run --force; do
  if "$BASH" "$DOCS_INSTALL_SCRIPT" --meta "$META" --target "$PROJECT/docs" "$flag" >"$TMP_DIR/out" 2>&1; then
    fail '源仓缺 remote 必须拒绝'
  fi
  assert_contains 'remote' "$TMP_DIR/out"
  assert_file_exists "$PROJECT/docs/sentinel"
  [[ ! -e "$PROJECT/.docs-init" && ! -e "$PROJECT/.docsconfig" ]] || fail '源仓错误须在任何写入前失败'
done
git -C "$META" remote add origin https://example.com/meta.git
ln -s "$META/application" "$TMP_DIR/source-alias"
for target in "$META/application" "$META/application/nested" "$META" "$TMP_DIR/source-alias" "$TMP_DIR/source-alias/nested"; do
  if "$BASH" "$DOCS_INSTALL_SCRIPT" --meta "$META" --target "$target" --force >"$TMP_DIR/out" 2>&1; then
    fail "源与目标重叠必须拒绝: $target"
  fi
  assert_file_exists "$META/application/README.md"
  [[ ! -e "$META/.docs-init" && ! -e "$META/.docsconfig" ]] || fail '重叠检查须先于目标写入'
done
pass '缺 remote、源目标相等或祖孙重叠均在写入前拒绝'
