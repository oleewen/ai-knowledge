#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
new_scan_fixture
printf -- '--glob=!README.md\n' > "$SCAN_TMP/rg-config"
printf '%s/%s\n' .superpowers specs/note.md > "$SCAN_REPO/README.md"
RIPGREP_CONFIG_PATH="$SCAN_TMP/rg-config" run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail 'rg 个人配置不得隐藏违规'
printf '`%s/%s`\n' .superpowers 'specs/design-<topic>.md' > "$SCAN_REPO/README.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 0 ]] || fail '尖括号占位符不误报'
printf '[file](%s/%s)\n' .superpowers 'specs/file%25name.md' > "$SCAN_REPO/README.md"
run_scan_fixture
[[ "$SCAN_STATUS" -eq 1 ]] || fail '编码百分号不能绕过文件引用隔离'
pass 'rg 配置隔离、完整占位符和编码百分号文件名'
