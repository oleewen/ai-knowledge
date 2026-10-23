#!/usr/bin/env bash
# lib/backup.sh — .docs-init 备份与备份相对路径
# 独立加载只依赖 path；不设独立哨兵，随旧入口换根刷新。

# shellcheck source=path.sh
source "${BASH_SOURCE[0]%/*}/path.sh"

_backup_info() {
  if declare -F info >/dev/null 2>&1; then
    info "$@"
  else
    printf '%s\n' "$*"
  fi
}

# 保留链接末段本身；目录链接和失效链接均不能跟随实体。
_backup_path_abs() {
  local existing="${1:?}"
  if [[ -L "$existing" ]]; then
    local parent base
    parent="$(cd -P "$(dirname "$existing")" 2>/dev/null && pwd -P)" || parent="$(dirname "$existing")"
    base="$(basename "$existing")"
    printf '%s/%s\n' "$parent" "$base"
  else
    abs_path "$existing"
  fi
}

backup_rel_under_root() {
  local repo_root="${1:?}" existing="${2:?}"
  existing="$(_backup_path_abs "$existing")"
  repo_root="$(strip_trailing_slash "$(abs_path "$repo_root")")"
  if [[ "$existing" == "$repo_root"/* ]]; then
    printf '%s' "${existing#"$repo_root"/}"
  else
    printf '%s' "${existing#/}"
  fi
}

docs_backup_path_to_init() {
  local repo_root="${1:?}" existing="${2:?}" stamp="${3:-}" dry_run="${4:-0}"
  local backup_root rel backup_target
  existing="$(_backup_path_abs "$existing")"
  repo_root="$(strip_trailing_slash "$(abs_path "$repo_root")")"
  [[ -e "$existing" || -L "$existing" ]] || return 0
  [[ -n "$stamp" ]] || stamp="$(date +%Y-%m-%d_%H-%M-%S)"
  backup_root="${repo_root}/.docs-init/${stamp}"

  rel="$(backup_rel_under_root "$repo_root" "$existing")"

  backup_target="${backup_root}/${rel}"
  if [[ -e "$backup_target" || -L "$backup_target" ]]; then
    local i=1
    while [[ -e "${backup_target}.__${i}" || -L "${backup_target}.__${i}" ]]; do (( i++ )); done
    backup_target="${backup_target}.__${i}"
  fi

  if [[ "$dry_run" == '1' ]]; then
    _backup_info "[dry-run] 将备份：$existing → $backup_target"
    return 0
  fi

  mkdir -p "$(dirname "$backup_target")" 2>/dev/null || true
  mv "$existing" "$backup_target"
  _backup_info "已备份：$existing → $backup_target"
}
