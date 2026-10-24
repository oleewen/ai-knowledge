#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
mkdir -p "$TMP_DIR/meta/application" "$TMP_DIR/project" "$TMP_DIR/bin"
git -C "$TMP_DIR/meta" init -q
git -C "$TMP_DIR/meta" remote add origin https://example.com/meta.git
printf '[rule](agent/rules/example.md)\n' >"$TMP_DIR/meta/application/README.md"
for tool in dirname basename python3 git tr cat awk sed grep find readlink mkdir uname date cp mv rm ln wc touch mktemp tail head xargs chmod sort uniq cut rg; do
  ln -s "$(command -v "$tool")" "$TMP_DIR/bin/$tool"
done
for mode in preview apply; do
  args=()
  [[ "$mode" != preview ]] || args+=(--dry-run)
  if PATH="$TMP_DIR/bin" "$BASH" "$DOCS_INSTALL_SCRIPT" --meta "$TMP_DIR/meta" --target "$TMP_DIR/project/docs" "${args[@]}" >"$TMP_DIR/$mode.out" 2>&1; then
    fail 'knowledge 缺 Perl 应在预检停止'
  fi
  grep -qi 'perl' "$TMP_DIR/$mode.out" || { cat "$TMP_DIR/$mode.out"; fail '未报告缺少 Perl'; }
  [[ ! -e "$TMP_DIR/project/docs" && ! -e "$TMP_DIR/project/.docsconfig" && ! -e "$TMP_DIR/project/.docs-init" ]] || fail '缺依赖仍修改目标'
done
PATH="$TMP_DIR/bin" "$BASH" "$DOCS_INSTALL_SCRIPT" --scope=config --target "$TMP_DIR/project/docs" >"$TMP_DIR/config.out" 2>&1
assert_file_exists "$TMP_DIR/project/.docsconfig"
assert_dir_not_exists "$TMP_DIR/project/docs"
pass 'knowledge 缺 Perl 预览与实跑均零写入；config 无 Perl 仍可执行'
