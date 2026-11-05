#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture
for root in .superpowers docs/superpowers; do
  for leaf in specs/note.md plans/plan.md sdd/run/log.txt sdd/run/snapshot.json sdd/run/review.diff sdd/run/plan-path README; do
    printf '[evidence](%s/%s)\n' "$root" "$leaf" > "$SCAN_REPO/README.md"
    run_scan_fixture
    [[ "$SCAN_STATUS" -eq 1 ]] || fail "任意会话文件 $root/$leaf 应被拒绝，实际 $SCAN_STATUS"
    assert_contains '发现 1 处' "$SCAN_TMP/stderr"
  done
done
pass '新旧会话目录的无日期、无扩展名和证据文件均隔离'
