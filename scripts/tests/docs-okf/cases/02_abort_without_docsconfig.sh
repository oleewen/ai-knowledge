#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$PROJECT_DIR"
git -C "$PROJECT_DIR" init -q

set +e
out="$(cd "$PROJECT_DIR" && bash "$VALIDATE_SCRIPT" 2>&1)"
code=$?
set -e

[[ "$code" -ne 0 ]] || fail "无 .docsconfig 应非零退出"
printf '%s\n' "$out" | grep -Fq '.docsconfig' || fail "stderr 应提及 .docsconfig"
printf '%s\n' "$out" | grep -Fq 'docs-install' || fail "stderr 应提示 docs-install"

pass "无 .docsconfig 时 validate-okf.sh 中止"
