#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case01.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

bash "$KNOWLEDGE_INIT_SCRIPT" --scope=config --type=application --target="$DOCS_DIR" >"$OUT_FILE" 2>&1

DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
assert_file_exists "$DOCS_CONFIG_PATH"
assert_contains "DOC_ROOT=" "$DOCS_CONFIG_PATH"
assert_contains "REPO_ROOT=" "$DOCS_CONFIG_PATH"
assert_contains "DOC_DIR=" "$DOCS_CONFIG_PATH"
assert_contains "KNOWLEDGE_TYPE=application" "$DOCS_CONFIG_PATH"

pass "scope=config 写入 .docsconfig（当前实现基线）"
