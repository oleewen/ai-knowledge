#!/usr/bin/env bash
# agent-install.sh — 安装 Agent 资源与 IDE 软链；不写工程 .docsconfig。
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../scripts/lib/bash.sh
source "${SCRIPT_DIR}/../../../scripts/lib/bash.sh"
# shellcheck source=agent-config.sh
source "${SCRIPT_DIR}/agent-config.sh"

declare -A CFG=(
  [repo_root]=""
  [target_abs]=""
  [home_abs]=""
  [store_abs]=""
  [workspace]=""
  [scope]="${DEFAULT_AGENT_SCOPE}"
  [agents_opt]=""
  [dry_run]="0"
  [stamp]=""
)

# scope 展开后的开关（由 agent_scope_apply 填充）
INSTALL_RULES=0
INSTALL_SKILLS=0
INSTALL_HOOKS=0
INSTALL_SCRIPTS=0
INSTALL_KNOWLEDGE=0

declare -a ENABLED_AGENTS=() INSTALL_CATEGORIES=()

# shellcheck source=agent-cli.sh
source "${SCRIPT_DIR}/agent-cli.sh"

is_agent_readme_basename() {
  local base="${1:?}"
  [[ "$base" == 'README' || "$base" == 'README.md' || "$base" == 'readme.md' ]]
}

# 同步目录树，排除各层 README / readme.md
# 须带 --delete-excluded：否则接收端仅余被 exclude 的文件（如旧目录里的 README）时，
# rsync 无法删空父目录，会报「not empty, cannot delete」（例如 reference/ 已改名为 references/）。
sync_tree_excluding_readme() {
  local src="$1" dst="$2"
  sync_dir "$src" "$dst" \
    --delete-excluded \
    --exclude 'README' --exclude 'README.md' --exclude 'readme.md'
  if ! dry_run_enabled && ! have_cmd rsync; then
    # 共享 cp 回退不处理 exclude；本技能补齐与 rsync 相同的 README 排除。
    find "$dst" -depth \( -name README -o -name README.md -o -name readme.md \) -exec rm -rf {} +
  fi
}

copy_file_plain() {
  IO_DRY_RUN="${CFG[dry_run]:-0}"
  IO_FORCE=1
  IO_BACKUP_FN=''
  export IO_DRY_RUN IO_FORCE IO_BACKUP_FN
  io_copy_file "$1" "$2"
}

agent_store_root() {
  printf '%s\n' "${CFG[store_abs]}"
}

agent_install_root() {
  local agent="$1"
  abs_path "${CFG[target_abs]}/$(get_agent_dir "$agent")"
}

backup_existing_target_path() {
  local p="$1"
  [[ -e "$p" || -L "$p" ]] || return 0

  if [[ -L "$p" ]]; then
    local target_root existing stamp dry_run
    target_root="$(strip_trailing_slash "$(abs_path "${CFG[target_abs]}")")"
    existing="$p"
    stamp="${CFG[stamp]}"
    dry_run="${CFG[dry_run]}"

    local backup_root rel backup_target
    [[ -n "$stamp" ]] || stamp="$(date +%Y-%m-%d_%H-%M-%S)"
    backup_root="${target_root}/.docs-init/${stamp}"
    rel="$(backup_rel_under_root "$target_root" "$existing")"

    backup_target="${backup_root}/${rel}"
    if [[ -e "$backup_target" || -L "$backup_target" ]]; then
      local i=1
      while [[ -e "${backup_target}.__${i}" || -L "${backup_target}.__${i}" ]]; do (( i++ )); done
      backup_target="${backup_target}.__${i}"
    fi

    if [[ "$dry_run" == '1' ]]; then
      printf '信息: [dry-run] 将备份：%s → %s\n' "$existing" "$backup_target" >&2
      return 0
    fi

    mkdir -p "$(dirname "$backup_target")" 2>/dev/null || true
    mv "$existing" "$backup_target"
    printf '信息: 已备份：%s → %s\n' "$existing" "$backup_target" >&2
    return 0
  fi

  docs_backup_path_to_init "${CFG[target_abs]}" "$p" "${CFG[stamp]}" "${CFG[dry_run]}"
}

ensure_symlink() {
  local src="$1" dst="$2"

  # IDE 根或分类目录可能已链接到实体树；不能搬走同一实体再创建自循环链接。
  # 路径比较也覆盖 dry-run 中尚未复制、但父目录已指向同一位置的条目。
  if [[ "$src" -ef "$dst" ]] || [[ "$(abs_path "$src")" == "$(abs_path "$dst")" ]]; then
    return 0
  fi

  if symlink_points_to "$dst" "$src"; then
    return 0
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    backup_existing_target_path "$dst"
  fi

  if [[ "${CFG[dry_run]}" == '1' ]]; then
    log "[dry-run] 链接: $dst -> $src"
    return 0
  fi
  ensure_dir "$(dirname "$dst")"
  ln -s "$src" "$dst"
}

link_store_into_agent_root() {
  local agent="$1" store agent_dir category item base source_dir
  store="$(agent_store_root)"
  agent_dir="$(agent_install_root "$agent")"
  info ">>> 链接 ${agent}：${store} -> ${agent_dir}"
  ensure_dir "$agent_dir"

  local nullglob_was_set=1
  nullglob_enable nullglob_was_set
  for category in "${INSTALL_CATEGORIES[@]}"; do
    case "$category" in
      knowledge|references)
        ensure_symlink "$store/$category" "$agent_dir/$category"
        continue
        ;;
    esac
    ensure_dir "$agent_dir/$category"
    source_dir="${CFG[repo_root]}/agent/$category"
    local -A seen=()
    local -a items=("$source_dir"/*)
    # 顶层非元库条目被保留；hooks 整目录同步会删除旧条目。
    [[ "$category" == hooks ]] || items+=("$store/$category"/*)
    for item in "${items[@]}"; do
      base="${item##*/}"
      is_agent_readme_basename "$base" && continue
      [[ -n "${seen[$base]:-}" ]] && continue
      seen[$base]=1
      ensure_symlink "$store/$category/$base" "$agent_dir/$category/$base"
    done
  done
  if (( INSTALL_HOOKS == 1 )) && [[ -f "${CFG[repo_root]}/agent/hooks.json" ]]; then
    ensure_symlink "$store/hooks.json" "$agent_dir/hooks.json"
  fi
  nullglob_restore nullglob_was_set
}

install_agent_resource() {
  local label="$1" src_rel="$2" dst_rel="$3"
  local src_root="${CFG[repo_root]}/${src_rel}"
  local item base dst_dir

  dst_dir="$(agent_store_root)/${dst_rel}"
  info ">>> 安装：${label}"
  ensure_dir "$dst_dir"
  info "  同步 ${label}：${src_root} → ${dst_dir}"

  local _nullglob_was_set=1
  nullglob_enable _nullglob_was_set
  for item in "$src_root"/*; do
    base="${item##*/}"
    is_agent_readme_basename "$base" && continue

    if [[ -d "$item" ]]; then
      sync_tree_excluding_readme "$item" "$dst_dir/$base"
    else
      copy_file_plain "$item" "$dst_dir/$base"
    fi
  done
  nullglob_restore _nullglob_was_set
}

agent_install_install() {
  local category
  for category in "${INSTALL_CATEGORIES[@]}"; do
    if [[ "$category" == hooks ]]; then
      sync_tree_excluding_readme "${CFG[repo_root]}/agent/hooks" "$(agent_store_root)/hooks"
    else
      install_agent_resource "$category" "agent/$category" "$category"
    fi
  done
  if (( INSTALL_HOOKS == 1 )) && [[ -f "${CFG[repo_root]}/agent/hooks.json" ]]; then
    copy_file_plain "${CFG[repo_root]}/agent/hooks.json" "$(agent_store_root)/hooks.json"
  fi
  local agent
  for agent in "${ENABLED_AGENTS[@]}"; do
    link_store_into_agent_root "$agent"
  done
}

agent_install_main() {
  agent_install_parse_args "$@"
  # 共享库也读这两个变量；预览与实跑统一以本次 CLI 为准。
  DRY_RUN="${CFG[dry_run]}"
  IO_DRY_RUN="${CFG[dry_run]}"
  agent_install_prepare
  ensure_dir "$(agent_store_root)"
  docsconfig_write_workspace "$(agent_store_root)" "${CFG[workspace]}" "${CFG[dry_run]}"
  agent_install_install
  if [[ "${CFG[dry_run]}" == 1 ]]; then
    info "预览完成：agent-install（未写入）"
  else
    info "完成：agent-install"
  fi
}

agent_install_main "$@"
