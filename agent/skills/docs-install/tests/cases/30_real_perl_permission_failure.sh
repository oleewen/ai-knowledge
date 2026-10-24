#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'chmod u+w "$TMP_DIR/docs"; rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/docs"
printf '[rule](agent/rules/example.md)\n' >"$TMP_DIR/docs/example.md"
cp "$TMP_DIR/docs/example.md" "$TMP_DIR/before"
chmod 500 "$TMP_DIR/docs"
if [[ -w "$TMP_DIR/docs" ]]; then
  printf '[SKIP] 当前用户可绕过目录写权限，无法验证真实 Perl 原地编辑失败\n'
  exit 0
fi
if "$BASH" -c 'source "$1"; rewrite_docs_agent_paths "$2"' _ \
  "$ROOT_DIR/agent/scripts/docs-core.sh" "$TMP_DIR/docs" >"$TMP_DIR/out" 2>&1; then
  fail '真实 Perl 无法创建临时文件时不得返回成功'
fi
cmp -s "$TMP_DIR/before" "$TMP_DIR/docs/example.md" || fail '失败后原文被破坏'
assert_contains 'example.md' "$TMP_DIR/out"
pass '真实 Perl 原地编辑权限失败返回非零，并保留原文'
