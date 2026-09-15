#!/usr/bin/env bash
#
# lib/path.sh — 路径原语 + nullglob / symlink 小工具
# 无加载哨兵：docs-core 重 source 时须刷新路径函数
#

expand_tilde() {
  local p="${1:-}"
  if [[ "$p" == '~' ]]; then
    printf '%s\n' "${HOME:-}"
  elif [[ "$p" =~ ^~/ ]]; then
    printf '%s\n' "${HOME:-}/${p:2}"
  else
    printf '%s\n' "$p"
  fi
}

abs_path() {
  local p
  p="$(expand_tilde "${1:-}")"
  [[ -n "$p" ]] || return 1
  [[ "$p" == /* ]] || p="$PWD/$p"

  if [[ -d "$p" ]]; then
    (cd -P "$p" 2>/dev/null && pwd)
  else
    local dir base
    dir="$(dirname "$p")"
    base="$(basename "$p")"
    dir="$(cd -P "$dir" 2>/dev/null && pwd || printf '%s' "$dir")"
    printf '%s/%s\n' "$dir" "$base"
  fi
}

strip_trailing_slash() {
  local p="${1:-}"
  while [[ "$p" != '/' && "$p" == */ ]]; do
    p="${p%/}"
  done
  printf '%s\n' "$p"
}

# dirname 经 pwd -P 规范化；失败时前缀为空（与 test-core 软链断言一致）
path_canonical() {
  local p="${1:?}"
  printf '%s/%s' "$(cd "$(dirname "$p")" 2>/dev/null && pwd -P)" "$(basename "$p")"
}

# nameref 存档约定（由 enable 写入、restore 读取）：
#   1 = 调用前 nullglob 已开 → restore 保持开
#   0 = 调用前 nullglob 关闭 → restore 关掉
# 不可 readonly：path 随 docs-core 重 source 会再次赋值
_NULLGLOB_WAS_ON=1
_NULLGLOB_WAS_OFF=0

nullglob_enable() {
  local -n _save_ref="${1:?save_ref is required}"
  _save_ref=$_NULLGLOB_WAS_OFF
  shopt -q nullglob && _save_ref=$_NULLGLOB_WAS_ON
  shopt -s nullglob
}

nullglob_restore() {
  local -n _save_ref="${1:?save_ref is required}"
  if (( _save_ref == _NULLGLOB_WAS_ON )); then
    shopt -s nullglob
  else
    shopt -u nullglob
  fi
}

# 若 link 为符号链接且 readlink 结果精确等于 expect 则成功
symlink_points_to() {
  local link="${1:?link is required}"
  local expect="${2:?expect is required}"
  local actual

  [[ -L "$link" ]] || return 1
  actual="$(readlink "$link" 2>/dev/null || true)"
  [[ -n "$actual" && "$actual" == "$expect" ]]
}
