#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
TMP_DIR="$(mktemp -d)"
TMP_DIR="$(cd "$TMP_DIR" && pwd -P)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/src"
# 仅加载授权边界函数，避免运行安装器 main 或写入真实 Agent 目录。
function_text="$(sed -n '/^sync_runtime_tree() {/,/^}/p' "$SCRIPTS_ROOT/../skills/agent-install/scripts/agent-install.sh")"
[[ -n "$function_text" ]] || fail '未找到安装器同步函数'
source /dev/stdin <<<"$function_text"
AGENT_INSTALL_EXCLUDES=()
sync_dir() {
  [[ "${IO_FORCE:-}" == 1 ]] || fail '安装器须明确授权受管资源目录同步'
  [[ "$1" == "$TMP_DIR/src" && "$2" == "$TMP_DIR/dst" ]] || fail '安装器同步参数漂移'
}
dry_run_enabled() { return 1; }
have_cmd() { return 0; }
unset IO_FORCE
sync_runtime_tree "$TMP_DIR/src" "$TMP_DIR/dst"
[[ ! -v IO_FORCE ]] || fail '安装器授权不可泄漏到未设置的调用方'
IO_FORCE=caller
sync_runtime_tree "$TMP_DIR/src" "$TMP_DIR/dst"
[[ "$IO_FORCE" == caller ]] || fail '安装器授权不可覆盖调用方的值'
pass '安装器明确授权受管目录更新，授权仅在同步函数内生效'
