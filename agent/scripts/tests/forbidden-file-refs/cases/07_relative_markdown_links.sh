#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture team/manual
for prefix in superpowers ../superpowers ../../team/manual/superpowers; do
  printf '[plan](%s/plans/%s-%s-%s-probe.md)\n' "$prefix" 2026 01 01 > "$SCAN_REPO/team/manual/README.md"
  run_scan_fixture
  [[ "$SCAN_STATUS" -eq 1 ]] || fail "相对链接 $prefix 应退出1，实际 $SCAN_STATUS"
  assert_contains '发现 1 处' "$SCAN_TMP/stderr"
done
pass '当前目录和多级相对 Markdown 链接检出且不重复计数'
