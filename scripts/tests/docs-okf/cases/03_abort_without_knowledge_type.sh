#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$DOCS_DIR/knowledge"
git -C "$PROJECT_DIR" init -q
write_docsconfig "$PROJECT_DIR" "$DOCS_DIR" "$PROJECT_DIR" "docs"

set +e
out="$(cd "$PROJECT_DIR" && bash "$VALIDATE_SCRIPT" 2>&1)"
code=$?
set -e

[[ "$code" -ne 0 ]] || fail "无 KNOWLEDGE_TYPE 应非零退出"
printf '%s\n' "$out" | grep -Fq 'KNOWLEDGE_TYPE' || fail "stderr 应提及 KNOWLEDGE_TYPE"
printf '%s\n' "$out" | grep -Fq 'scope=knowledge' || fail "stderr 应提示 scope=knowledge"

pass "无 KNOWLEDGE_TYPE 时 okf-validate.sh 中止"
