#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
PROJECT_DIR="$TMP_DIR/project"
SYSTEM_DIR="$PROJECT_DIR/system"
OUT_FILE="$TMP_DIR/case05.out"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$SYSTEM_DIR"
git -C "$PROJECT_DIR" init -q

"${BASH:-$(command -v bash)}" "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=system --target "$SYSTEM_DIR" >"$OUT_FILE" 2>&1

# 建联改走 /docs-link；不再向目标仓落盘 docs-link 脚本
assert_file_not_exists "$PROJECT_DIR/scripts/docs-link.sh"
assert_file_not_exists "$PROJECT_DIR/scripts/link-config.sh"

DOCS_CONFIG_PATH="$PROJECT_DIR/.docsconfig"
assert_file_exists "$DOCS_CONFIG_PATH"
assert_contains "KNOWLEDGE_TYPE=system" "$DOCS_CONFIG_PATH"

# 系统交付只安装 PRD/ASD/TDD；详设由 ASD 承接表交给应用库。
PHASE_DIR="$SYSTEM_DIR/requirements/REQUIREMENT-EXAMPLE/MVP-Phase-1"
assert_file_not_exists "$PHASE_DIR/DSD-EXAMPLE-1.md"
assert_file_exists "$PHASE_DIR/PRD-EXAMPLE.md"
assert_file_exists "$PHASE_DIR/TDD-EXAMPLE.md"
assert_contains '应用承接' "$PHASE_DIR/ASD-EXAMPLE-1.md"
assert_not_contains '](DSD-EXAMPLE-1.md)' "$PHASE_DIR/index.md"

pass "系统安装写层级配置、保留 ASD 应用承接入口且不带系统 DSD 占位或 link 脚本"
