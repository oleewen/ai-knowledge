#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
PROJECT_DIR="$TMP_DIR/project"
SOLUTION_DIR="$PROJECT_DIR/solution"
OUT_FILE="$TMP_DIR/case13.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$SOLUTION_DIR"
git -C "$PROJECT_DIR" init -q

"${BASH:-$(command -v bash)}" "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=solution --target "$SOLUTION_DIR" >"$OUT_FILE" 2>&1

assert_file_not_exists "$PROJECT_DIR/scripts/docs-link.sh"
assert_file_exists "$SOLUTION_DIR/DESIGN.md"
assert_file_exists "$SOLUTION_DIR/knowledge/application/SLN-EXAMPLE.md"
assert_file_exists "$SOLUTION_DIR/system-slots/README.md"
assert_file_exists "$SOLUTION_DIR/solutions/README.md"

DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
assert_file_exists "$DOCS_CONFIG_PATH"
assert_contains "KNOWLEDGE_TYPE=solution" "$DOCS_CONFIG_PATH"

pass "scope=knowledge + type=solution 写 KNOWLEDGE_TYPE=solution 并同步 solution/ 模板"
