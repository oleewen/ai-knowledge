#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture team/manual
printf -v spec 'team/manual/superpowers/specs/%s-%s-%s-probe.md' 2026 01 01
printf -v plan '../superpowers/plans/%s-%s-%s-probe.md' 2026 01 01
printf '%s [plan](%s)\n' "$spec" "$plan" > "$SCAN_REPO/README.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail '同行两处自定义根/相对链接应退出1'
assert_contains '发现 2 处' "$SCAN_TMP/stderr"
pass '同行不同位置的自定义根字面路径和相对链接分别计数'
