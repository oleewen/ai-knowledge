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
run_docs_bootstrap "$FAKE_HOME" --components=docs >"$OUT_FILE" 2>&1
rc=$?
set -e

[[ "$rc" -ne 0 ]] || fail "docs-only 缺 doc-target 应失败"
grep -q -- '--doc-target' "$OUT_FILE" || fail "应提示需要 --doc-target"

pass "components=docs 缺 doc-target 报错"
