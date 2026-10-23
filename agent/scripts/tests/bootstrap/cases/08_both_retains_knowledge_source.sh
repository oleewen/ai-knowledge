#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
mkdir -p "$FAKE_HOME/workspaces/app"
run_docs_bootstrap "$FAKE_HOME" --components=both \
  --doc-target "$FAKE_HOME/workspaces/app/docs" --agents=codex \
  >"$FAKE_HOME/out" 2>&1 || fail "全新环境 knowledge 安装失败：$(tail -20 "$FAKE_HOME/out")"
assert_file_exists "$FAKE_HOME/workspaces/app/.docsconfig"
assert_file_exists "$FAKE_HOME/workspaces/app/docs/knowledge-links.yaml"
assert_dir_exists "$FAKE_HOME/workspaces/ai-knowledge/.git"
assert_file_exists "$FAKE_HOME/workspaces/ai-knowledge/agent/skills/docs-install/scripts/docs-install.sh"
assert_contains '${WORK_SPACE}/ai-knowledge' "$FAKE_HOME/workspaces/app/docs/knowledge-links.yaml"
assert_contains 'type: meta' "$FAKE_HOME/workspaces/app/docs/knowledge-links.yaml"
pass "双轨 knowledge 保留工作区内可追溯元库"
