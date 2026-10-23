#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
"$BASH" -c '
  set +e +u +o pipefail
  before_flags=$- before_options=$SHELLOPTS
  source "$1"
  [[ "$-" == "$before_flags" && "$SHELLOPTS" == "$before_options" ]]
' version-source "$ROOT/agent/scripts/lib/version.sh"
source "$ROOT/agent/scripts/lib/version.sh"
source "$ROOT/agent/scripts/test-core.sh"
[[ "$(version_normalize 26.10.20)" == 2026.1020.0 ]]
[[ "$(version_normalize 2026.1020.3)" == 2026.1020.3 ]]
[[ "$(version_normalize 2026.1020.08)" == 2026.1020.8 ]]
if version_normalize 26.13.01 >/dev/null 2>&1 || version_normalize 26.02.00 >/dev/null 2>&1; then
  fail '旧格式非法月份或日期必须拒绝'
fi
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
for layer in application system solution company; do
  mkdir -p "$TMP/$layer"
  printf 'version: 2026.1020.3\n' >"$TMP/$layer/DESIGN.md"
done
git -C "$TMP" init -q -b main
git -C "$TMP" config user.email test@example.com
git -C "$TMP" config user.name 'Version Test'
git -C "$TMP" add .
git -C "$TMP" commit -qm initial
if version_commit_sha "$TMP" 2026.1020.3 >/dev/null 2>&1; then
  fail '缺失发布提交时 version_commit_sha 必须返回失败'
fi
git -C "$TMP" commit --allow-empty -qm 'docs-publish: version 2026.1020.08'
[[ "$(version_latest_from_log "$TMP")" == 2026.1020.8 ]] || fail '发布日志中的前导零 patch 应按十进制规范化'

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
