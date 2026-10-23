#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
mkdir -p "$FAKE_HOME/workspaces/app"
printf 'occupied\n' >"$FAKE_HOME/.agents"
if SCOPE=config run_docs_bootstrap "$FAKE_HOME" --components=both \
  --doc-target "$FAKE_HOME/workspaces/app/docs" --agents=codex \
  >"$FAKE_HOME/out" 2>&1; then
  fail 'Agent 安装根冲突时应停止'
fi
assert_contains '执行 agent-install' "$FAKE_HOME/out"
if grep -q '执行 docs-install' "$FAKE_HOME/out"; then
  fail 'Agent 失败后不应开始知识库安装'
fi
assert_file_not_exists "$FAKE_HOME/workspaces/app/.docsconfig"
assert_file_not_exists "$FAKE_HOME/workspaces/app/docs"
assert_contains 'occupied' "$FAKE_HOME/.agents"
pass "Agent 前置失败时停止双轨后续步骤"
