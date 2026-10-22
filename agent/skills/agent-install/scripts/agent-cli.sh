#!/usr/bin/env bash
# agent-cli.sh — 参数解析与只读准备；由 agent-install.sh source。

agent_install_usage() {
  cat >&2 <<'EOF'
用法: agent-install.sh [选项]（Bash 5+）

将元库 agent/ 中选定资源写入 $HOME/.agents，并在 target 下链接所选 IDE。
不写工程 .docsconfig；configs/WORK_SPACE 始终写入 $HOME/.agents，且不链接到 IDE。
默认会实跑；预览须显式传 --dry-run。各层 README 不安装。

选项（同时支持 --key=value）
  --meta PATH       元库根目录；仓库内默认本仓，已安装副本必须显式传入
  --scope SCOPE     a=全部 | r=rules | s=skills | h=hooks | sh=scripts
                    k|knowledge=knowledge+references；默认 a
  --target PATH     IDE 软链父目录；默认 $HOME
  --agents LIST     cursor、codex、claude、trae、kiro；逗号或空格分隔
                    a|all 表示全部，须单独使用；默认 a
  --workspace PATH  工作区目录，写入 configs/WORK_SPACE
                    省略时从 cwd 上溯 .docsconfig 的 AGENT_ROOT/AGENT_DIR
                    读取对应 configs/WORK_SPACE；无法推断则必须显式传入
  --dry-run         只读预览
  -h, --help        显示帮助

AGENTS_OPT 是省略 --agents 时的默认值。target 与 workspace 用途不同。
工程 target 在显式提供 workspace 时不要求 .docsconfig。

示例（仓库根执行）
  bash agent/skills/agent-install/scripts/agent-install.sh --scope=a --target "$HOME" --agents=codex --workspace ~/workspaces --dry-run
EOF
}

agent_install_require_value() {
  [[ -n "${2:-}" && "$2" != -* ]] || error "缺少 $1 值（不能用下一项选项代替）"
}

agent_install_parse_args() {
  local option key value
  while (( $# > 0 )); do
    option="${1%%=*}"
    case "$option" in
      --meta) key=repo_root ;;
      --scope) key=scope ;;
      --target) key=target_abs ;;
      --agents) key=agents_opt ;;
      --workspace) key=workspace ;;
      --dry-run) [[ "$1" == --dry-run ]] || cli_unknown_arg "$1"; CFG[dry_run]=1; shift; continue ;;
      -h|--help) [[ "$1" == "$option" ]] || cli_unknown_arg "$1"; agent_install_usage; exit 0 ;;
      *) cli_unknown_arg "$1" ;;
    esac
    if [[ "$1" == *=* ]]; then
      value="${1#*=}"
      shift
    else
      shift
      agent_install_require_value "$option" "${1:-}"
      value="$1"
      shift
      if [[ "$option" == --agents ]]; then
        while (( $# > 0 )) && [[ "$1" != -* ]]; do
          value+=",$1"
          shift
        done
      fi
    fi
    agent_install_require_value "$option" "$value"
    [[ "$value" != *$'\n'* && "$value" != *$'\r'* ]] || error "$option 不支持换行"
    CFG[$key]="$value"
  done
}

agent_install_init_repo_root() {
  if [[ -z "${CFG[repo_root]}" ]]; then
    local candidate
    candidate="$(abs_path "$SCRIPT_DIR/../../../..")"
    [[ "$SCRIPT_DIR" -ef "$candidate/agent/skills/agent-install/scripts" ]] \
      || error "已安装副本须传 --meta <元库根目录>"
    CFG[repo_root]="$candidate"
  fi
  CFG[repo_root]="$(strip_trailing_slash "$(abs_path "${CFG[repo_root]}")")"
  local rr="${CFG[repo_root]}" category
  for category in rules skills hooks scripts; do
    [[ -d "$rr/agent/$category" ]] || error "未找到 agent/$category: $rr/agent/$category"
  done
  [[ -f "$rr/agent/scripts/docs-core.sh" ]] || error "未找到 agent/scripts/docs-core.sh: $rr/agent/scripts/docs-core.sh"
}

agent_install_select_resources() {
  validate_agent_scope_token "${CFG[scope]}" \
    || error "无效 --scope: ${CFG[scope]}（支持 a|r|s|h|sh|k|knowledge）"
  agent_scope_apply "${CFG[scope]}" INSTALL_RULES INSTALL_SKILLS INSTALL_HOOKS INSTALL_SCRIPTS INSTALL_KNOWLEDGE
  INSTALL_CATEGORIES=()
  (( INSTALL_SCRIPTS == 1 )) && INSTALL_CATEGORIES+=(scripts)
  (( INSTALL_RULES == 1 )) && INSTALL_CATEGORIES+=(rules)
  (( INSTALL_SKILLS == 1 )) && INSTALL_CATEGORIES+=(skills)
  (( INSTALL_HOOKS == 1 )) && INSTALL_CATEGORIES+=(hooks)
  (( INSTALL_KNOWLEDGE == 1 )) && INSTALL_CATEGORIES+=(knowledge references)
  local category
  for category in "${INSTALL_CATEGORIES[@]}"; do
    [[ -d "${CFG[repo_root]}/agent/$category" ]] || error "未找到 agent/$category"
  done
}

agent_install_apply_agents() {
  local ao="${CFG[agents_opt]:-${AGENTS_OPT:-$DEFAULT_AGENTS_OPT}}"
  validate_agents "$ao" \
    || error "无效 --agents: ${ao}（支持 cursor、codex、claude、trae、kiro；a|all 须单独使用）"
  read -ra ENABLED_AGENTS <<< "$(normalize_agents "$ao")"
}

# 未传 --workspace 时：.docsconfig 的 AGENT_ROOT/AGENT_DIR → configs → WORK_SPACE
agent_install_resolve_workspace() {
  if [[ -n "${CFG[workspace]:-}" ]]; then
    CFG[workspace]="$(strip_trailing_slash "$(abs_path "${CFG[workspace]}")")"
    return 0
  fi

  local cfg_path rd dd ar kt ad configs_path raw
  cfg_path="$(docsconfig_find_path 2>/dev/null || true)"
  if [[ -z "${cfg_path}" || ! -f "${cfg_path}" ]]; then
    error "缺少 --workspace <工作区目录>（未找到 .docsconfig，无法推断 WORK_SPACE）"
  fi

  rd='' dd='' ar='' kt='' ad=''
  docsconfig_read_into "${cfg_path}" rd dd ar kt ad || error "解析 .docsconfig 失败: ${cfg_path}"
  if [[ -z "${ar}" || -z "${ad}" ]]; then
    error "缺少 --workspace <工作区目录>（.docsconfig 无 AGENT_ROOT/AGENT_DIR: ${cfg_path}）"
  fi

  configs_path="$(docsconfig_configs_file "${ar}" "${ad}")"
  raw="$(docsconfig_read_workspace_raw "${configs_path}" 2>/dev/null || true)"
  if [[ -z "${raw}" ]]; then
    error "缺少 --workspace <工作区目录>（${configs_path} 无 WORK_SPACE）"
  fi

  CFG[workspace]="$(strip_trailing_slash "$(docsconfig_normalize_root_value "${raw}")")"
  info "未传 --workspace，沿用 ${configs_path} 的 WORK_SPACE=${CFG[workspace]}"
}

# 允许新目录；逐段解析才能检查 missing/../file，并保留已有软链后的 .. 语义。
agent_install_normalize_target() {
  local resolved=/ part candidate
  local -a parts=()
  IFS=/ read -ra parts <<< "$1"
  for part in "${parts[@]}"; do
    case "$part" in
      ''|.) continue ;;
      ..) resolved="$(dirname "$resolved")"; continue ;;
    esac
    candidate="${resolved%/}/$part"
    if [[ -d "$candidate" ]]; then
      resolved="$(cd -P "$candidate" && pwd)" || error "无法访问 --target 目录: $candidate"
    elif [[ -e "$candidate" || -L "$candidate" ]]; then
      error "--target 路径不能作为目录使用: $candidate"
    else
      resolved="$candidate"
    fi
  done
  printf '%s\n' "$resolved"
}

agent_install_prepare() {
  agent_install_init_repo_root
  agent_install_select_resources
  agent_install_apply_agents
  [[ -n "${HOME:-}" ]] || error "需要 HOME 环境变量"
  CFG[home_abs]="$(abs_path "$HOME")"
  CFG[store_abs]="$(strip_trailing_slash "$(abs_path "${CFG[home_abs]}/.agents")")"
  CFG[target_abs]="$(strip_trailing_slash "$(abs_path "${CFG[target_abs]:-${CFG[home_abs]}}")")"
  CFG[target_abs]="$(agent_install_normalize_target "${CFG[target_abs]}")"
  agent_install_resolve_workspace
  CFG[stamp]="$(date +%Y-%m-%d_%H-%M-%S)"
}
