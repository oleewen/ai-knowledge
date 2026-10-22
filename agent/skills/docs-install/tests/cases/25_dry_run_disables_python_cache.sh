#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
PROJECT="$TMP_DIR/project"
mkdir -p "$PROJECT/docs"

# 指定全新缓存位置，避免解释器复用系统缓存而掩盖 dry-run 的额外写入。
PYTHONDONTWRITEBYTECODE= PYTHONPYCACHEPREFIX="$TMP_DIR/pycache" \
  "$BASH" "$DOCS_INSTALL_SCRIPT" --target "$PROJECT/docs" --dry-run >"$TMP_DIR/out" 2>&1
[[ ! -e "$TMP_DIR/pycache" ]] || fail 'dry-run 不得让 Python 子进程创建字节码缓存'
[[ ! -e "$PROJECT/.docsconfig" ]] || fail 'dry-run 不得写入配置'
pass 'dry-run 禁止所有 Python 子进程写入字节码缓存'
