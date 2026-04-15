#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case03.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

set +e
bash "$DOCS_INSTALL_SCRIPT" \
  --scope=knowledge \
  --mode=central \
  --type=system \
  --dry-run \
  --target="$DOCS_DIR" >"$OUT_FILE" 2>&1
CODE=$?
set -e

# 新契约目标：mode=central 仅允许 type=application。
[[ "$CODE" -ne 0 ]] || fail "应拒绝 --mode=central --type=system，但当前退出码为 0"

pass "mode=central 仅允许 type=application（新契约）"
