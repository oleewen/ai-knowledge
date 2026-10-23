#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
# 每组从清洁严格 shell 开始；错误不得被 if/|| 的 errexit 例外掩盖。
rc=0
"$BASH" -u -c 'unset CFG DRY_RUN IO_DRY_RUN; source "$1"; dry_run_enabled' clean-dry-run "$SCRIPTS_ROOT/lib/log-io.sh" >"$TMP_DIR/out" 2>"$TMP_DIR/err" || rc=$?
[[ "$rc" -eq 1 ]] || fail "无 dry-run 设置应返回 1，实际 $rc"
[[ ! -s "$TMP_DIR/out" && ! -s "$TMP_DIR/err" ]] || fail '未声明 CFG 时出现额外输出或未绑定错误'
"$BASH" -eu -c 'unset CFG DRY_RUN IO_DRY_RUN; source "$1"; IO_DRY_RUN=1; dry_run_enabled' clean-io-dry "$SCRIPTS_ROOT/lib/log-io.sh"
# 缺失、标量、索引数组 CFG 都不是合法关联配置，不按表达式读取 dry_run。
"$BASH" -eu -c 'unset DRY_RUN IO_DRY_RUN; source "$1"; CFG=scalar; IO_DRY_RUN=1; dry_run_enabled' scalar-cfg "$SCRIPTS_ROOT/lib/log-io.sh"
"$BASH" -eu -c 'unset DRY_RUN IO_DRY_RUN; source "$1"; declare -a CFG=(value); IO_DRY_RUN=1; dry_run_enabled' indexed-cfg "$SCRIPTS_ROOT/lib/log-io.sh"
"$BASH" -eu -c '
  source "$1"
  unset DRY_RUN IO_DRY_RUN
  declare -A CFG=([dry_run]=1)
  dry_run_enabled
  DRY_RUN=0
  rc=0; dry_run_enabled || rc=$?
  [[ "$rc" -eq 1 ]]
  DRY_RUN=""
  dry_run_enabled
  DRY_RUN=1; CFG[dry_run]=0
  dry_run_enabled
  DRY_RUN=0; IO_DRY_RUN=1
  dry_run_enabled
' priority-cfg "$SCRIPTS_ROOT/lib/log-io.sh"
pass '清洁严格 shell 可判断 dry-run，显式变量和 CFG 优先级保持'
