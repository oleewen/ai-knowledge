#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case02.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target "$DOCS_DIR" >"$OUT_FILE" 2>&1

DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
assert_file_exists "$DOCS_CONFIG_PATH"
assert_contains "DOC_ROOT=" "$DOCS_CONFIG_PATH"
assert_contains "REPO_ROOT=" "$DOCS_CONFIG_PATH"
assert_contains "DOC_DIR=" "$DOCS_CONFIG_PATH"
assert_contains "KNOWLEDGE_TYPE=application" "$DOCS_CONFIG_PATH"
assert_contains "AGENT_ROOT=" "$DOCS_CONFIG_PATH"
assert_contains "AGENT_DIR=.agents" "$DOCS_CONFIG_PATH"
[[ -L "$DOCS_DIR/.agents" ]] || fail "应创建 DOC_DIR/.agents 软链"

pass "scope=knowledge 写 .docsconfig（含 KNOWLEDGE_TYPE；AGENT_ROOT=~ + AGENT_DIR=.agents）并建软链"
