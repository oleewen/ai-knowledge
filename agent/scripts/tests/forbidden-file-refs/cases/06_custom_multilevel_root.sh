#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture team/manual
printf 'team/manual/superpowers/specs/%s-%s-%s-probe.md\n' 2026 01 01 > "$SCAN_REPO/README.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail "自定义多级根具名引用应退出1，实际 $SCAN_STATUS"
assert_contains '发现 1 处' "$SCAN_TMP/stderr"
pass '自定义多级根具名引用检出'
