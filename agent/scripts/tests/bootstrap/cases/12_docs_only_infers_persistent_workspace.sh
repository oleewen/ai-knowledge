#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
mkdir -p "$FAKE_HOME/custom-team/app"
run_docs_bootstrap "$FAKE_HOME" --components=agent --agents=codex \
  --workspace "$FAKE_HOME/custom-team" >"$FAKE_HOME/agent-out" 2>&1 \
  || fail "Agent 准备失败：$(tail -20 "$FAKE_HOME/agent-out")"
run_docs_bootstrap "$FAKE_HOME" --components=docs \
  --doc-target "$FAKE_HOME/custom-team/app/docs" >"$FAKE_HOME/docs-out" 2>&1 \
  || fail "docs-only 工作区推断失败：$(tail -20 "$FAKE_HOME/docs-out")"
assert_file_exists "$FAKE_HOME/custom-team/app/docs/knowledge-links.yaml"
assert_dir_exists "$FAKE_HOME/custom-team/ai-knowledge/.git"
assert_not_contains '执行 agent-install' "$FAKE_HOME/docs-out"
assert_dir_not_exists "$FAKE_HOME/workspaces/ai-knowledge"
pass "docs-only 沿用 Agent 的自定义工作区保留元库"
