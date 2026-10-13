#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

FAKE_HOME="$(new_fake_home)"
PROJ="$FAKE_HOME/proj"
OUT_FILE="$FAKE_HOME/out.txt"

cleanup() {
  rm -rf "$FAKE_HOME"
}
trap cleanup EXIT

mkdir -p "$PROJ"
# 有 .docsconfig 但无 AGENT_* → 必须显式 --workspace
printf 'REPO_DIR=proj\nDOC_DIR=docs\nKNOWLEDGE_TYPE=application\n' >"$PROJ/.docsconfig"
mkdir -p "$PROJ/docs"

cd "$PROJ"
set +e
run_agent_install_infer_workspace "$FAKE_HOME" --scope=a --agents=cursor --dry-run >"$OUT_FILE" 2>&1
rc=$?
set -e
[[ "$rc" -ne 0 ]] || fail "无 AGENT_* 时应失败。输出:\n$(cat "$OUT_FILE")"
assert_contains "缺少 --workspace" "$OUT_FILE"

pass "无 AGENT_ROOT/AGENT_DIR 时必须显式 --workspace"
