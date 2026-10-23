#!/usr/bin/env bash
# lib/file-io.sh — dry-run、目录同步、覆盖决策与文件拷贝。
# 依赖由 log-io.sh 提供；不设置独立加载哨兵，支持换根重载。

# 与 run_or_dry / sync_dir / io_* 一致：DRY_RUN、CFG[dry_run] 或 IO_DRY_RUN
dry_run_enabled() {
  local configured_dry_run=0 cfg_declaration
  if [[ -n "${DRY_RUN:-}" ]]; then
    configured_dry_run="$DRY_RUN"
  elif cfg_declaration="$(declare -p CFG 2>/dev/null)" && [[ "$cfg_declaration" =~ ^declare\ -[^[:space:]]*A ]]; then
    # CFG 未声明或不是关联数组时，避免 Bash 将 dry_run 当算术变量求值。
    configured_dry_run="${CFG[dry_run]:-0}"
  fi
  [[ "$configured_dry_run" == '1' || "${IO_DRY_RUN:-0}" == '1' ]]
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
  if [[ -e "$dst" || -L "$dst" ]]; then
    local overwrite_status=0
    io_should_overwrite "$dst" || overwrite_status=$?
    case "$overwrite_status" in
      0) ;;
      1) log "[skip] $dst"; return 1 ;;
      2) exit 130 ;;
      *) return "$overwrite_status" ;;
    esac
  fi
  ensure_dir "$dst"
  if have_cmd rsync; then
    local rsync_options=(-a --delete)
    if rsync --version 2>/dev/null | head -1 | grep -qi 'openrsync'; then
      # openrsync 2.6.9 兼容层的 size/time 快速检查会漏更新小文件。
      rsync_options+=(--checksum)
    fi
    rsync "${rsync_options[@]}" "$@" "$src"/ "$dst"/
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
  if [[ ! -t 0 ]]; then
    warn "未授权覆盖已有目标: ${target}（须设置 IO_FORCE=1 或 IO_CONFLICT_MODE=overwrite_all）"
    return 3
  fi
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
  if [[ -e "$dst" || -L "$dst" ]]; then
    local _ow=0
    io_should_overwrite "$dst" || _ow=$?
    [[ "$_ow" -eq 2 ]] && exit 130
    [[ "$_ow" -eq 1 ]] && { log "[skip] $dst"; return 1; }
    [[ "$_ow" -eq 0 ]] || return "$_ow"
    if [[ -n "${IO_BACKUP_FN:-}" ]] && declare -f "$IO_BACKUP_FN" >/dev/null; then
      "$IO_BACKUP_FN" "$dst"
    fi
  fi
  ensure_dir "$(dirname "$dst")"
  cp "$src" "$dst"
}
