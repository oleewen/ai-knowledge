#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture
printf '[one](%s)\n' "$(named_spec_path)" > "$SCAN_REPO/README.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail '违规应退出1'
assert_contains '发现 1 处' "$SCAN_TMP/stderr"
printf '[one](%s) [two](%s)\n' "$(named_spec_path)" "$(named_spec_path)" > "$SCAN_REPO/README.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail '同行多处违规应退出1'
assert_contains '发现 2 处' "$SCAN_TMP/stderr"
pass '同一引用不重复计数，同一行不同出现位置分别计数'
