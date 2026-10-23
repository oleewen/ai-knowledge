#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture solution
printf 'solution/superpowers/plans/%s-%s-%s-probe.md\n' 2026 01 01 > "$SCAN_REPO/README.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail 'solution 根下的具名引用应退出1'
assert_contains '发现 1 处' "$SCAN_TMP/stderr"
pass 'solution 根具名引用检出'
