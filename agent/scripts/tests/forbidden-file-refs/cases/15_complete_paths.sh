#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture
mkdir -p "$SCAN_REPO/.superpowers/"custom "$SCAN_REPO/docs/.superpowers"
printf 'evidence\n' > "$SCAN_REPO/docs/.superpowers/"custom
printf '[file](%s/%s)\n' docs/.superpowers custom > "$SCAN_REPO/README.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail '别处同名目录不能豁免具体文件引用'
mkdir -p "$SCAN_REPO/docs/.superpowers/"directory
printf '[directory](%s/%s)\n' docs/.superpowers directory > "$SCAN_REPO/README.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 0 ]] || fail '带完整前缀的真实目录应允许'
printf '[directory](../%s/%s)\n' .superpowers custom > "$SCAN_REPO/docs/guide.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 0 ]] || fail '相对目录应按来源解析'
for spacing in ' ' $'\n'; do
  printf '[file](%s%s/%s)\n' "$spacing" .superpowers custom > "$SCAN_REPO/docs/guide.md"
  run_scan_fixture
  [[ "$SCAN_STATUS" -eq 1 ]] || fail '链接空白和跨行目标仍按来源解析'
done
pass '完整路径和来源相对目录正确解析'
