#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture
mkdir -p "$SCAN_TMP/bin"
cat > "$SCAN_TMP/bin/rg" <<'STUB'
#!/usr/bin/env bash
printf 'injected scan failure\n' >&2
exit 2
STUB
chmod +x "$SCAN_TMP/bin/rg"
PATH="$SCAN_TMP/bin:$PATH" run_scan_fixture
[[ "$SCAN_STATUS" -eq 2 ]] || fail "扫描错误应退出2，实际 $SCAN_STATUS"
assert_not_contains '[OK]' "$SCAN_TMP/stdout"
assert_contains 'injected scan failure' "$SCAN_TMP/stderr"
assert_contains '[ERROR]' "$SCAN_TMP/stderr"
pass '扫描工具失败独立报错，不得假绿'
