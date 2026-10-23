#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture
named_spec_path > "$SCAN_REPO/violation.txt"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail "字面违规应退出1，实际 $SCAN_STATUS"
assert_contains '[FAIL]' "$SCAN_TMP/stderr"
assert_contains 'violation.txt:' "$SCAN_TMP/stderr"
assert_not_contains '[OK]' "$SCAN_TMP/stdout"
pass '隔离消费仓检出字面违规'
