#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
INSTALLED="$HOME/.agents/skills/docs-install"
mkdir -p "$INSTALLED" "$TMP_DIR/project/docs"
cp -R "$ROOT_DIR/agent/skills/docs-install/scripts" "$INSTALLED/scripts"
cp -R "$ROOT_DIR/agent/scripts/." "$HOME/.agents/scripts/"
"$BASH" "$INSTALLED/scripts/docs-install.sh" --scope=config --meta "$TMP_DIR/no-source" --target "$TMP_DIR/project/docs" --dry-run >"$TMP_DIR/config.out" 2>&1 \
  || { cat "$TMP_DIR/config.out" >&2; fail '安装副本的 config 不应依赖模板源'; }
assert_contains 'DOC_DIR=docs' "$TMP_DIR/config.out"
if "$BASH" "$INSTALLED/scripts/docs-install.sh" --target "$TMP_DIR/project/docs" --dry-run >"$TMP_DIR/out" 2>&1; then
  fail '安装副本的 knowledge 须明确指定 --meta'
fi
grep -Fq -- '--meta' "$TMP_DIR/out" || fail '安装副本应提示显式 --meta'
"$BASH" "$INSTALLED/scripts/docs-install.sh" --meta "$ROOT_DIR" --target "$TMP_DIR/project/docs" --dry-run >"$TMP_DIR/explicit.out" 2>&1
assert_contains 'DOC_DIR=docs' "$TMP_DIR/explicit.out"
pass '安装副本 config 无模板依赖，knowledge 显式 --meta 可用'
