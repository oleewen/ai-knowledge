#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

FAKE_HOME="$(new_fake_home)"
OUT_FILE="$FAKE_HOME/out.txt"
WS="$FAKE_HOME/workspaces"
STORE="$FAKE_HOME/.agents"

cleanup() {
  rm -rf "$FAKE_HOME"
}
trap cleanup EXIT

mkdir -p "$STORE" "$WS"
printf 'WORK_SPACE=%s\n' "$WS" >"$STORE/configs"

# 仓根 .docsconfig 有 AGENT_ROOT=~ AGENT_DIR=.agents；HOME=FAKE_HOME 时 ~ → FAKE_HOME
cd "$ROOT_DIR"
run_agent_install_infer_workspace "$FAKE_HOME" --scope=a --agents=cursor --dry-run >"$OUT_FILE" 2>&1 \
  || fail "应能从 configs 推断 WORK_SPACE。输出:\n$(cat "$OUT_FILE")"

assert_contains "沿用" "$OUT_FILE"
assert_contains "WORK_SPACE=" "$OUT_FILE"

pass "未传 --workspace 时从 .docsconfig+configs 推断 WORK_SPACE"
