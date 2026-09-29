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
# 有 KNOWLEDGE_TYPE、无 AGENT_DIR
{
  printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=docs\nKNOWLEDGE_TYPE=application\n' \
    "$DOCS_DIR" "$PROJECT_DIR"
} >"$PROJECT_DIR/.docsconfig"

set +e
out="$(cd "$PROJECT_DIR" && "${BASH:-$(command -v bash)}" "$VALIDATE_SCRIPT" 2>&1)"
code=$?
set -e

[[ "$code" -ne 0 ]] || fail "无 AGENT_DIR 应非零退出"
printf '%s\n' "$out" | grep -Fq 'AGENT_DIR' || fail "stderr 应提及 AGENT_DIR"

pass "无 AGENT_DIR 时 okf-validate.sh 中止"
