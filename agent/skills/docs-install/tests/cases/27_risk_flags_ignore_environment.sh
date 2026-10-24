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
git -C "$META" remote add origin https://example.com/meta.git
printf '# template\n' >"$META/application/README.md"
printf 'preserve\n' >"$PROJECT/docs/sentinel"
if FORCE=1 "$BASH" "$DOCS_INSTALL_SCRIPT" --meta "$META" --target "$PROJECT/docs" >"$TMP_DIR/reset.out" 2>&1; then
  fail '环境 FORCE 不能授权重装'
fi
assert_contains 'preserve' "$PROJECT/docs/sentinel"
[[ ! -e "$PROJECT/.docs-init" && ! -e "$PROJECT/.docsconfig" ]] || fail '拒绝重装后仍有写入'
FORCE=0 "$BASH" "$DOCS_INSTALL_SCRIPT" --meta "$META" --target "$PROJECT/docs" --force >"$TMP_DIR/explicit.out" 2>&1
[[ ! -e "$PROJECT/docs/sentinel" ]] || fail '显式 --force 未执行重装'
[[ -n "$(find "$PROJECT/.docs-init" -name sentinel -print)" ]] || fail '显式重装丢失备份'
for mode in preview apply; do
  args=()
  [[ "$mode" != preview ]] || args+=(--dry-run)
  if CREATE_PROJECT_ROOT=1 "$BASH" "$DOCS_INSTALL_SCRIPT" --scope=config --target "$TMP_DIR/new-project/docs" "${args[@]}" >"$TMP_DIR/create-$mode.out" 2>&1; then
    fail '环境 CREATE_PROJECT_ROOT 不能代替 -r'
  fi
  assert_dir_not_exists "$TMP_DIR/new-project"
done
CREATE_PROJECT_ROOT=0 "$BASH" "$DOCS_INSTALL_SCRIPT" --scope=config --target "$TMP_DIR/new-project/docs" -r >"$TMP_DIR/create-explicit.out" 2>&1
assert_file_exists "$TMP_DIR/new-project/.docsconfig"
assert_dir_not_exists "$TMP_DIR/new-project/docs"
pass '环境风险默认值无效，显式 --force/-r 可执行且保留备份与 config 边界'
