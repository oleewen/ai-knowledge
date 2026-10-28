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
PADDED_SHA="$(git -C "$TMP" rev-parse HEAD)"
[[ "$(version_commit_sha "$TMP" 2026.1020.8)" == "$PADDED_SHA" ]] || fail '规范版本须定位前导零发布'
git -C "$TMP" commit --allow-empty -qm 'docs-publish: version 2026.1020.8'
STANDARD_SHA="$(git -C "$TMP" rev-parse HEAD)"
[[ "$(version_commit_sha "$TMP" 2026.1020.08)" == "$STANDARD_SHA" ]] || fail '查询前导零拼写也须选择同版本首项'
git -C "$TMP" commit --allow-empty -qm 'docs-publish: version 2026.1020.008'
NEWEST_SHA="$(git -C "$TMP" rev-parse HEAD)"
for query in 2026.1020.8 2026.1020.08; do
  [[ "$(version_commit_sha "$TMP" "$query")" == "$NEWEST_SHA" ]] || fail '不同拼写须定位同版本日志首项'
  [[ "$(version_commit_sha "$TMP" "$query" "$PADDED_SHA")" == "$PADDED_SHA" ]] || fail '查询不得越过指定 revision'
done
git -C "$TMP" commit --allow-empty -qm 'docs-publish: version 2026.1020.9'
HIGHEST_SHA="$(git -C "$TMP" rev-parse HEAD)"
git -C "$TMP" commit --allow-empty -qm 'docs-publish: version 2026.1020.7'
[[ "$(version_latest_from_log "$TMP")" == 2026.1020.9 ]] || fail '最高版本不取最后提交的版本'
[[ "$(version_commit_sha "$TMP" "$(version_latest_from_log "$TMP")")" == "$HIGHEST_SHA" ]] || fail '最高版本须定位对应快照'
for invalid in 2026.1301.0 garbage '2026.1020.9 extra'; do
  git -C "$TMP" commit --allow-empty -qm "docs-publish: version $invalid"
  if version_commit_sha "$TMP" "$invalid" >/dev/null 2>&1; then fail '非法版本不得匹配发布'; fi
done
[[ "$(version_latest_from_log "$TMP")" == 2026.1020.9 ]] || fail '非法标记不得影响最高版本'
[[ "$(version_commit_sha "$TMP" 2026.1020.9)" == "$HIGHEST_SHA" ]] || fail '查找须跳过非法发布标记'
if version_commit_sha "$TMP" 2026.1020.99 >/dev/null 2>&1; then fail '缺失版本必须返回失败'; fi
if version_commit_sha "$TMP" 2026.1020.9 "$PADDED_SHA" >/dev/null 2>&1; then fail '指定历史外的版本不得命中'; fi

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
VERSION_TEST_DAY=2026.1019
if version_next_from_files "$TMP"/*/DESIGN.md >/dev/null 2>&1; then fail '未来版本不得回退'; fi
for layer in application system solution company; do printf 'version: 99.12.31\n' > "$TMP/$layer/DESIGN.md"; done
if version_next_from_files "$TMP"/*/DESIGN.md >/dev/null 2>&1; then fail '旧格式未来版本也须核实'; fi
pass '版本解析、同日 patch 递增与跨日归零'
