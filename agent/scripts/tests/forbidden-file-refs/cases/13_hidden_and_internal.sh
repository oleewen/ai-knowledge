#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture
mkdir -p "$SCAN_REPO/.config" "$SCAN_REPO/.superpowers/specs"
printf '%s/%s\n' .superpowers sdd/run/snapshot.json > "$SCAN_REPO/.superpowers/specs/""internal.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 0 ]] || fail '隐藏会话目录内部可互引'
printf '.config/\n' > "$SCAN_REPO/.gitignore"
printf '%s/%s\n' .superpowers specs/note.md > "$SCAN_REPO/.config/notes.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail '隐藏或忽略的目录外引用不可漏检'
assert_contains '.config/notes.md:' "$SCAN_TMP/stderr"
pass '内部互引豁免，隐藏和忽略的外部正文仍检查'
