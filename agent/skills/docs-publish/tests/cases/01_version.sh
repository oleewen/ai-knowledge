#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "$ROOT/agent/scripts/lib/version.sh"
source "$ROOT/agent/scripts/test-core.sh"
[[ "$(version_normalize 26.10.20)" == 2026.1020.0 ]]
[[ "$(version_normalize 2026.1020.3)" == 2026.1020.3 ]]
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
for layer in application system solution company; do
  mkdir -p "$TMP/$layer"
  printf 'version: 2026.1020.3\n' >"$TMP/$layer/DESIGN.md"
done

# 只替换被测函数的时钟输入，避免测试结果依赖执行当天。
VERSION_TEST_DAY=2026.1020
date() {
  if [[ "$#" -eq 1 && "$1" == '+%Y.%m%d' ]]; then
    printf '%s\n' "$VERSION_TEST_DAY"
  else
    command date "$@"
  fi
}
[[ "$(version_next_from_files "$TMP"/*/DESIGN.md)" == 2026.1020.4 ]]
VERSION_TEST_DAY=2026.1021
[[ "$(version_next_from_files "$TMP"/*/DESIGN.md)" == 2026.1021.0 ]]
pass '版本解析、同日 patch 递增与跨日归零'
