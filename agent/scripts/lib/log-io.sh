#!/usr/bin/env bash
#
# lib/log-io.sh — 日志、dry-run、目录同步与文件拷贝、CLI 参数校验
# 依赖：lib/path.sh（abs_path / strip_trailing_slash）
#

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=path.sh
source "${_LIB_DIR}/path.sh"

if [[ -n "${_LIB_LOG_IO_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
# 不可 readonly：docs-core 换根重载时须 unset 后重新加载
_LIB_LOG_IO_LOADED=1

# 不可 readonly：换根重 source 时会再次赋值
MIN_BASH_VERSION=5

require_bash5() {
  if (( BASH_VERSINFO[0] < MIN_BASH_VERSION )); then
    printf '[FATAL] 需要 Bash %s+，当前版本: %s\n' "$MIN_BASH_VERSION" "$BASH_VERSION" >&2
    exit 1
  fi
}
require_bash5

log()   { printf '%s\n'       "$*" >&2; }
info()  { printf '信息: %s\n'  "$*" >&2; }
warn()  { printf '警告: %s\n'  "$*" >&2; }
error() { printf '错误: %s\n' "$*" >&2; exit 1; }

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

have_perl() {
  have_cmd perl
}

# 与 run_or_dry / sync_dir / io_* 一致：DRY_RUN、CFG[dry_run] 或 IO_DRY_RUN
dry_run_enabled() {
  [[ "${DRY_RUN:-${CFG[dry_run]:-0}}" == '1' || "${IO_DRY_RUN:-0}" == '1' ]]
}

run_or_dry() {
  if dry_run_enabled; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

ensure_dir() { run_or_dry mkdir -p "$1"; }

sync_dir() {
  local src="$1" dst="$2"
  shift 2

  [[ -d "$src" ]] || return 0
  if dry_run_enabled; then
    log "[dry-run] 同步目录: $src → $dst"
    return 0
  fi
  ensure_dir "$dst"
  if have_cmd rsync; then
    rsync -a --delete "$@" "$src"/ "$dst"/
  else
    warn "未检测到 rsync，使用 cp -R（无法完全排除或增量同步；建议安装 rsync）"
    [[ -n "$dst" && "$dst" != '/' ]] || {
      error "sync_dir 目标目录非法: '$dst'"
    }
    rm -rf "$dst"
    ensure_dir "$(dirname "$dst")"
    cp -R "$src" "$dst"
  fi
}

io_should_overwrite() {
  local target="$1"
  dry_run_enabled && return 0
  [[ "${IO_FORCE:-0}" == '1' ]] && return 0
  case "${IO_CONFLICT_MODE:-}" in
    overwrite_all) return 0 ;;
    skip_all)      return 1 ;;
  esac
  [[ ! -t 0 ]] && return 0
  log "目标已存在：$target"
  printf '1) 覆盖 / 2) 跳过 / 3) 全部覆盖 / 4) 全部跳过 [默认 1，Esc 退出]：' >&2
  local key='' key2=''
  IFS= read -rsn1 key || { log "已取消"; return 2; }
  if [[ "$key" == $'\e' ]]; then
    if IFS= read -rsn1 -t 0.05 key2 2>/dev/null; then
      log "无效选择，默认覆盖"; return 0
    fi
    log "已取消（Esc）" >&2
    return 2
  fi
  case "$key" in
    $'\n'|$'\r'|1) return 0 ;;
    2) return 1 ;;
    3) IO_CONFLICT_MODE='overwrite_all'; return 0 ;;
    4) IO_CONFLICT_MODE='skip_all'; return 1 ;;
    *) log "无效选择，默认覆盖"; return 0 ;;
  esac
}

io_copy_file() {
  local src="$1" dst="$2"
  if dry_run_enabled; then
    log "[dry-run] 拷贝: $src → $dst"; return 0
  fi
  if [[ -e "$dst" ]]; then
    local _ow=0
    io_should_overwrite "$dst" || _ow=$?
    [[ "$_ow" -eq 2 ]] && exit 130
    [[ "$_ow" -eq 1 ]] && { log "[skip] $dst"; return 1; }
    if [[ -n "${IO_BACKUP_FN:-}" ]] && declare -f "$IO_BACKUP_FN" >/dev/null; then
      "$IO_BACKUP_FN" "$dst"
    fi
  fi
  ensure_dir "$(dirname "$dst")"
  cp "$src" "$dst"
}

backup_rel_under_root() {
  local repo_root="${1:?}" existing="${2:?}"
  existing="$(abs_path "$existing")"
  repo_root="$(strip_trailing_slash "$(abs_path "$repo_root")")"
  if [[ "$existing" == "$repo_root"/* ]]; then
    printf '%s' "${existing#"$repo_root"/}"
  else
    printf '%s' "${existing#/}"
  fi
}

# 校验 flag 后的值非空；空则 error 退出
cli_require_value() {
  local flag="${1:?flag is required}"
  local value="${2-}"
  [[ -n "$value" ]] || error "缺少 ${flag} 值"
}

# 拒绝未知参数；hint 默认指向 -h/--help
cli_unknown_arg() {
  local arg="${1:?arg is required}"
  local hint="${2:-使用 -h 或 --help 查看帮助}"
  error "未知参数: ${arg}（${hint}）"
}
