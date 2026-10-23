#!/usr/bin/env bash
# lib/slot-softlink.sh — 联邦槽位软链与共用日志辅助（联邦技能共用）
# 依赖：lib/path.sh、lib/docsconfig.sh、lib/git-remote.sh；未加载时自动 source

if [[ -n "${_LIB_SLOT_SOFTLINK_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
# 不可 readonly：docs-core 换根重载时须 unset 后重新加载
_LIB_SLOT_SOFTLINK_LOADED=1

_SLOT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=bash.sh
source "${_SLOT_LIB_DIR}/bash.sh"

if ! declare -f abs_path >/dev/null 2>&1 || ! declare -f docsconfig_read_into >/dev/null 2>&1; then
  # shellcheck source=docsconfig.sh
  source "${_SLOT_LIB_DIR}/docsconfig.sh"
fi
if ! declare -f git_remote_url_prefer_origin >/dev/null 2>&1; then
  # shellcheck source=git-remote.sh
  source "${_SLOT_LIB_DIR}/git-remote.sh"
fi
unset _SLOT_LIB_DIR

# 规范化 remote URL 便于比较（去尾部 .git、统一小写 scheme/host 不做过度猜测）
slot_normalize_git_url() {
  local u="${1:-}"
  u="${u%.git}"
  u="${u%/}"
  printf '%s' "$u"
}

# path 为绝对则直接 abs；否则相对 base 再 abs。stdout 无换行。
_slot_abs_under() {
  local base="${1:?}" path="${2:?}"
  if [[ "$path" == /* ]]; then
    printf '%s' "$(strip_trailing_slash "$(abs_path "$path")")"
  else
    printf '%s' "$(strip_trailing_slash "$(abs_path "${base}/${path}")")"
  fi
}

_slot_emit_actions() {
  local -n _fed_acts="${1:?}"
  ((${#_fed_acts[@]} > 0)) || return 0
  local IFS='+'
  printf '%s' "${_fed_acts[*]}"
}

# 解析槽位软链目标：有 .docsconfig 则拼文档路径；没有文件时回退 {path}/{doc_dir}
# Usage: slot_resolve_doc_root <repo_path> <doc_dir> → stdout abs path
slot_resolve_doc_root() {
  local repo_path="${1:?}" doc_dir="${2:-}"
  local cfg t_repo_abs='' t_doc_abs='' t_doc_dir=''
  local fallback=''

  repo_path="$(strip_trailing_slash "$(abs_path "$repo_path")")"
  [[ -n "$doc_dir" ]] && fallback="$(_slot_abs_under "$repo_path" "$doc_dir")"

  cfg="${repo_path}/.docsconfig"
  if [[ -f "$cfg" ]]; then
    docsconfig_abs_for_config "$cfg" t_repo_abs t_doc_abs t_doc_dir || return 1
    printf '%s' "$t_doc_abs"
    return 0
  fi

  [[ -n "$fallback" ]] || return 1
  printf '%s' "$fallback"
}

# 兼容旧调用：不再创建 *-slots/changelogs 或 ARCHIVE-LOG（追溯各仓 Git 历史）
slot_ensure_shared_changelogs() {
  :
}

slot_migrate_real_slot_dir() {
  local slot_dir="${1:?}"
  # 兼容旧签名：忽略 shared_log_dir / slot_name
  shift || true
  [[ -d "$slot_dir" && ! -L "$slot_dir" ]] || return 0
  rm -rf "$slot_dir"
}

# 确保 slot_dir 为指向 target_abs 的绝对路径软链；真目录则先删除再建链
# stdout: action 片段（空|migrate|link-fix）
# 第 3/4 参 shared_log_dir、slot_name 保留兼容，忽略
slot_ensure_slot_symlink() {
  local slot_dir="${1:?}" target_abs="${2:?}"
  local actions=() current parent
  target_abs="$(strip_trailing_slash "$(abs_path "$target_abs")")"
  parent="$(dirname "$slot_dir")"
  mkdir -p "$parent"

  if [[ -d "$slot_dir" && ! -L "$slot_dir" ]]; then
    slot_migrate_real_slot_dir "$slot_dir"
    actions+=("migrate")
  fi

  if [[ -L "$slot_dir" ]]; then
    current="$(readlink "$slot_dir" 2>/dev/null || true)"
    if [[ "$current" == "$target_abs" ]]; then
      _slot_emit_actions actions
      return 0
    fi
    rm -f "$slot_dir"
    actions+=("link-fix")
  elif [[ -e "$slot_dir" ]]; then
    rm -rf "$slot_dir"
    actions+=("link-fix")
  fi

  ln -s "$target_abs" "$slot_dir"
  # 新建软链也记 link-fix，便于追溯
  ((${#actions[@]} > 0)) || actions+=("link-fix")
  _slot_emit_actions actions
}

slot_remove_slot_path() {
  local slot_dir="${1:?}"
  if [[ -L "$slot_dir" ]]; then
    rm -f "$slot_dir"
    return 0
  fi
  [[ -d "$slot_dir" ]] && rm -rf "$slot_dir"
}

slot_git_origin_url() {
  local repo="${1:?}"
  git_remote_url_prefer_origin "$repo" 2>/dev/null || true
}

slot_git_is_dirty() {
  local repo="${1:?}"
  [[ -n "$(git -C "$repo" status --porcelain 2>/dev/null || true)" ]]
}
