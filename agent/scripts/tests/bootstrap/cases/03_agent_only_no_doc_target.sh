#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

FAKE_HOME="$(new_fake_home)"
OUT_FILE="$FAKE_HOME/out.txt"
EXPECTED_WORKSPACE="$FAKE_HOME/workspaces"
cleanup() { rm -rf "$FAKE_HOME"; }
trap cleanup EXIT

run_docs_bootstrap "$FAKE_HOME" \
  --components=agent \
  --agents=cursor \
  --agent-scope=home \
  >"$OUT_FILE" 2>&1

grep -q 'components:  agent' "$OUT_FILE" || fail "日志应含 components: agent"
grep -q '执行 docs-install' "$OUT_FILE" && fail "agent-only 不应执行 docs-install"
grep -q '执行 agent-install' "$OUT_FILE" || fail "应执行 agent-install"

assert_dir_exists "$FAKE_HOME/.agents/skills"
assert_dir_exists "$FAKE_HOME/.cursor/skills"
assert_file_exists "$FAKE_HOME/.agents/configs"
assert_contains 'WORK_SPACE=~/workspaces' "$FAKE_HOME/.agents/configs"
assert_contains "工作区:      $EXPECTED_WORKSPACE" "$OUT_FILE"

pass "components=agent 无 doc-target 可装 Agent（默认 workspace）"
