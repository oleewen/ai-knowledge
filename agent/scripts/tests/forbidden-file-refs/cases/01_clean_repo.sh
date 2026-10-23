#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture
printf 'ordinary document\n' > "$SCAN_REPO/README.md"
mkdir -p "$SCAN_REPO/docs/superpowers/specs"
named_spec_path > "$SCAN_REPO/docs/superpowers/specs/internal.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 0 ]] || fail '清洁消费仓应通过'
assert_contains '[OK]' "$SCAN_TMP/stdout"
pass '清洁仓通过，内部工作稿排除'
