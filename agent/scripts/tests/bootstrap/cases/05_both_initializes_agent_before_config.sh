#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
mkdir -p "$FAKE_HOME/workspaces/app"
# config 仅依赖 Agent 安装树，隔离验证双轨前置顺序。
SCOPE=config run_docs_bootstrap "$FAKE_HOME" --components=both \
  --doc-target "$FAKE_HOME/workspaces/app/docs" --agents=codex \
  >"$FAKE_HOME/out" 2>&1 || fail "全新环境双轨安装失败：$(cat "$FAKE_HOME/out")"
assert_file_exists "$FAKE_HOME/.agents/configs"
assert_file_exists "$FAKE_HOME/workspaces/app/.docsconfig"
assert_contains 'AGENT_DIR=.agents' "$FAKE_HOME/workspaces/app/.docsconfig"
assert_file_not_exists "$FAKE_HOME/workspaces/app/docs"
pass "双轨 config 在全新环境先建立 Agent 前置"
