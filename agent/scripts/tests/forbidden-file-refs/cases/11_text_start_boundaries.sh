#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture team/manual
for prefix in '计划：' 'path=' 'path:'; do
  printf '%ssuperpowers/specs/%s-%s-%s-probe.md\n' "$prefix" 2026 01 01 > "$SCAN_REPO/README.md"
  run_scan_fixture
  [[ "$SCAN_STATUS" -eq 1 ]] || fail "文本边界 $prefix 后的具名引用应退出1，实际 $SCAN_STATUS"
  assert_contains '发现 1 处' "$SCAN_TMP/stderr"
done
pass '等号及英文、中文冒号后的具名路径检出'
