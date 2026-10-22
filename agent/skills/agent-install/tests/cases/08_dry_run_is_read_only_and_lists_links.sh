#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FAKE_HOME="$(new_fake_home)"
trap 'rm -rf "$FAKE_HOME"' EXIT
OUT_FILE="$FAKE_HOME/out.txt"
run_agent_install "$FAKE_HOME" --scope=k --agents=cursor --dry-run >"$OUT_FILE" 2>&1
assert_dir_not_exists "$FAKE_HOME/.agents"
assert_dir_not_exists "$FAKE_HOME/.cursor"
assert_contains "$FAKE_HOME/.cursor/knowledge -> $FAKE_HOME/.agents/knowledge" "$OUT_FILE"
assert_contains "$FAKE_HOME/.cursor/references -> $FAKE_HOME/.agents/references" "$OUT_FILE"
pass "首次 dry-run 无写入且列出 knowledge/references 链接"
