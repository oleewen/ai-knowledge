#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case02.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target="$DOCS_DIR" >"$OUT_FILE" 2>&1

# 新契约目标：scope=knowledge 不应写 .docsconfig。
DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
assert_file_not_exists "$DOCS_CONFIG_PATH"

pass "scope=knowledge 不写 .docsconfig（新契约）"
