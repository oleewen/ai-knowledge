#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture team/manual
for directory in foosuperpowers foo-superpowers foo_superpowers .superpowers foo+superpowers 中文superpowers @superpowers; do
  printf 'team/manual/%s/specs/%s-%s-%s-probe.md\n' "$directory" 2026 01 01 >> "$SCAN_REPO/README.md"
  printf '[plan](../%s/plans/%s-%s-%s-probe.md)\n' "$directory" 2026 01 01 >> "$SCAN_REPO/README.md"
done
run_scan_fixture
[[ "$SCAN_STATUS" -eq 0 ]] || fail '相似目录名不应误报'
assert_contains '[OK]' "$SCAN_TMP/stdout"
pass '相似目录名不误判为 superpowers 目录'
