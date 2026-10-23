#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
mkdir -p "$FAKE_HOME/workspaces/app"
if SCOPE=config run_docs_bootstrap "$FAKE_HOME" --components=docs \
  --doc-target "$FAKE_HOME/workspaces/app/docs" >"$FAKE_HOME/out" 2>&1; then
  fail '缺少 Agent 前置时 docs-only 应停止'
fi
assert_contains '请先' "$FAKE_HOME/out"
if grep -q '执行 agent-install' "$FAKE_HOME/out"; then
  fail 'docs-only 不应补装 Agent'
fi
assert_file_not_exists "$FAKE_HOME/.agents"
assert_file_not_exists "$FAKE_HOME/workspaces/app/.docsconfig"
pass "docs-only 保持范围并报告 Agent 前置缺口"
