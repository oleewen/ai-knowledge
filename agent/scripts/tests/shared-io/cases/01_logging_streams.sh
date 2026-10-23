#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
source "$SCRIPTS_ROOT/lib/log-io.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

{ log 'plain'; info 'detail'; warn 'careful'; } >"$TMP_DIR/out" 2>"$TMP_DIR/err"
[[ ! -s "$TMP_DIR/out" ]] || fail '日志污染 stdout'
printf 'plain\n信息: detail\n警告: careful\n' >"$TMP_DIR/want"
cmp "$TMP_DIR/want" "$TMP_DIR/err" || fail '日志 stderr 内容漂移'
rc=0
(error 'bad') >"$TMP_DIR/out" 2>"$TMP_DIR/err" || rc=$?
[[ "$rc" -eq 1 && ! -s "$TMP_DIR/out" ]] || fail 'error 流或退出码漂移'
[[ "$(cat "$TMP_DIR/err")" == '错误: bad' ]] || fail 'error stderr 漂移'
for api in backup_rel_under_root cli_require_value cli_unknown_arg have_cmd have_perl; do
  declare -F "$api" >/dev/null || fail "log-io 缺失兼容 API: $api"
done
pass '日志使用 stderr，error 退出 1，门面 API 保留'
