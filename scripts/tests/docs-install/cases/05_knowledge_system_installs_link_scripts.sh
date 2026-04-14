#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
SYSTEM_DIR="$PROJECT_DIR/system"
OUT_FILE="$TMP_DIR/case05.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$SYSTEM_DIR"
git -C "$PROJECT_DIR" init -q

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=system --target="$SYSTEM_DIR" >"$OUT_FILE" 2>&1

assert_file_exists "$PROJECT_DIR/scripts/docs-link.sh"
assert_file_exists "$PROJECT_DIR/scripts/link-config.sh"

DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
assert_file_exists "$DOCS_CONFIG_PATH"
assert_contains "KNOWLEDGE_TYPE=system" "$DOCS_CONFIG_PATH"

pass "scope=knowledge + type=system 安装 link 脚本并写 KNOWLEDGE_TYPE=system"
