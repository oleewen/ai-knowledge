#!/usr/bin/env bash
#
# shell-utils.sh — shell 小工具（nullglob 成对开关、符号链接目标比对）
# 供 agent-install 等 source；无 docs-core 依赖
# 幂等：可重复 source（_SDX_SHELL_UTILS_SH_LOADED）
#

if [[ -n "${_SDX_SHELL_UTILS_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _SDX_SHELL_UTILS_SH_LOADED=1

# nameref 存档约定（由 enable 写入、restore 读取）：
#   1 = 调用前 nullglob 已开 → restore 保持开
#   0 = 调用前 nullglob 关闭 → restore 关掉
readonly _SDX_NULLGLOB_WAS_ON=1
readonly _SDX_NULLGLOB_WAS_OFF=0

# 打开 nullglob，并把调用前状态写入 nameref 变量（见上约定）
sdx_nullglob_enable() {
  local -n _save_ref="${1:?save_ref is required}"
  _save_ref=$_SDX_NULLGLOB_WAS_OFF
  shopt -q nullglob && _save_ref=$_SDX_NULLGLOB_WAS_ON
  shopt -s nullglob
}

# 按 enable 时存档恢复 nullglob
sdx_nullglob_restore() {
  local -n _save_ref="${1:?save_ref is required}"
  if (( _save_ref == _SDX_NULLGLOB_WAS_ON )); then
    shopt -s nullglob
  else
    shopt -u nullglob
  fi
}

# 若 link 为符号链接且 readlink 结果精确等于 expect 则成功
sdx_symlink_points_to() {
  local link="${1:?link is required}"
  local expect="${2:?expect is required}"
  local actual

  [[ -L "$link" ]] || return 1
  actual="$(readlink "$link" 2>/dev/null || true)"
  [[ -n "$actual" && "$actual" == "$expect" ]]
}
