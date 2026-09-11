#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

FAKE_HOME="$(new_fake_home)"
OUT_FILE="$FAKE_HOME/out.txt"
cleanup() { rm -rf "$FAKE_HOME"; }
trap cleanup EXIT

set +e
run_docs_bootstrap "$FAKE_HOME" --components=nope --agents=cursor --agent-scope=home >"$OUT_FILE" 2>&1
rc=$?
set -e

[[ "$rc" -ne 0 ]] || fail "无效 --components 应非零退出"
grep -q '无效 --components' "$OUT_FILE" || fail "应报无效 --components"

pass "拒绝无效 --components"
