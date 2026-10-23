#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture team/manual
for internal in superpowers/specs team/manual/superpowers/plans other/nested/superpowers/specs; do
  mkdir -p "$SCAN_REPO/$internal"
  named_spec_path > "$SCAN_REPO/$internal/internal.md"
  printf '\nteam/manual/superpowers/specs/%s-%s-%s-probe.md\n' 2026 01 01 >> "$SCAN_REPO/$internal/internal.md"
done
run_scan_fixture
[[ "$SCAN_STATUS" -eq 0 ]] || fail '任意层级 superpowers 内部工作稿应排除'
assert_contains '[OK]' "$SCAN_TMP/stdout"
pass '任意层级 superpowers 内部排除保留'
