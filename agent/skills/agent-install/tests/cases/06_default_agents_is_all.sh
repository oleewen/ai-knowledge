#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

FAKE_HOME="$(new_fake_home)"
OUT_FILE="$FAKE_HOME/out.txt"
STORE="$FAKE_HOME/.agents"

cleanup() {
  rm -rf "$FAKE_HOME"
}
trap cleanup EXIT

# 不传 --agents → 默认 a（全量）
run_agent_install "$FAKE_HOME" --scope=a --dry-run >"$OUT_FILE" 2>&1 \
  || fail "默认 agents=a 应成功。输出:\n$(cat "$OUT_FILE")"

for d in cursor codex claude trae kiro; do
  assert_contains "链接 ${d}：" "$OUT_FILE"
done

pass "默认 --agents=a 链接全部 IDE"
