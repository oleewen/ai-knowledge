#!/usr/bin/env bash
# agent-install.sh — 安装 Agent（scripts / rules / skills / hooks）并按需更新 .docsconfig 中的 AGENT_*
#
# 配置面：source 同目录 agent-config.sh。
#
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent-config.sh
source "${SCRIPT_DIR}/agent-config.sh"

# =============================================================================
# 全局状态
# =============================================================================

declare -A CFG=(
  [repo_root]="${REPO_ROOT:-}"
  [target_abs]=""
  [home_abs]=""
  [scope]="${SDX_DEFAULT_AGENT_SCOPE}"
  [agents_opt]=""
  [dry_run]="0"
)

# scope 展开后的开关（由 agent_scope_apply 填充）
INSTALL_RULES=0
INSTALL_SKILLS=0
INSTALL_HOOKS=0
INSTALL_SCRIPTS=0

declare -a ENABLED_AGENTS=()

have_cmd()  { sdx_have_cmd "$1"; }
have_perl() { sdx_have_perl; }

run_or_dry() { sdx_run_or_dry "$@"; }
ensure_dir() { sdx_ensure_dir "$1"; }

# 同步目录树，排除各层 README / readme.md
sync_tree_excluding_readme() {
  local src="$1" dst="$2"
  sdx_sync_dir "$src" "$dst" --exclude 'README' --exclude 'README.md' --exclude 'readme.md'
}

copy_file_plain() {
  local src="$1" dst="$2"
  if [[ "${CFG[dry_run]}" == '1' ]]; then
    sdx_log "[dry-run] 拷贝: $src → $dst"
    return 0
  fi
  sdx_ensure_dir "$(dirname "$dst")"
  cp "$src" "$dst"
}

agent_install_root() {
  local agent="$1"
  abs_path "${CFG[target_abs]}/$(get_agent_dir "$agent")"
}

# =============================================================================
# 初始化与校验
# =============================================================================

init_repo_root() {
  if [[ -z "${CFG[repo_root]}" ]]; then
    CFG[repo_root]="$(abs_path "$SCRIPT_DIR/..")"
  fi
  local rr="${CFG[repo_root]}"
  [[ -d "$rr/agent/rules"   ]] || sdx_error "未找到 agent/rules: $rr/agent/rules"
  [[ -d "$rr/agent/skills"  ]] || sdx_error "未找到 agent/skills: $rr/agent/skills"
  [[ -d "$rr/agent/hooks"   ]] || sdx_error "未找到 agent/hooks: $rr/agent/hooks"
  [[ -d "$rr/agent/scripts" ]] || sdx_error "未找到 agent/scripts: $rr/agent/scripts"
  [[ -f "$rr/agent/scripts/docs-core.sh" ]] || sdx_error "未找到 agent/scripts/docs-core.sh: $rr/agent/scripts/docs-core.sh"
}

apply_scope() {
  validate_agent_scope_token "${CFG[scope]}" \
    || sdx_error "无效 --scope: ${CFG[scope]}（支持 a|r|s|h|sh）"
  agent_scope_apply "${CFG[scope]}" INSTALL_RULES INSTALL_SKILLS INSTALL_HOOKS INSTALL_SCRIPTS \
    || sdx_error "内部错误：无法应用 scope: ${CFG[scope]}"
}

apply_agents() {
  local ao="${CFG[agents_opt]:-}"
  [[ -n "$ao" ]] || ao="${AGENTS_OPT:-$SDX_DEFAULT_AGENTS_OPT}"
  validate_agents "$ao" \
    || sdx_error "无效 --agents: $ao（支持 cursor、trea、claude、all 及逗号或空格分隔多选）"
  read -ra ENABLED_AGENTS <<< "$(normalize_agents "$ao")"
  (( ${#ENABLED_AGENTS[@]} > 0 )) || sdx_error "未解析到任何 Agent"
}

# =============================================================================
# 安装各子树
# =============================================================================

# 通用资源安装（scripts、rules、skills）
# 用法：install_agent_subtree_generic <label> <src_rel_path> <dst_rel_path> [extra_item_logic_func]
install_agent_resource() {
  local label="$1" src_rel="$2" dst_rel="$3"
  local agent agent_dir agent_slash
  local src_root="${CFG[repo_root]}/${src_rel}"
  local item base dst_dir

  [[ -d "$src_root" ]] || { sdx_warn "未找到 ${src_root}，跳过 ${label}"; return 0; }

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"
    sdx_info ">>> 安装 ${agent}：${label}"
    dst_dir="${agent_dir}/${dst_rel}"
    ensure_dir "$dst_dir"
    sdx_info "  同步 ${label}：${src_root} → ${dst_dir}"

    shopt -s nullglob
    for item in "$src_root"/*; do
      base="$(basename "$item")"
      [[ "$base" == 'README' || "$base" == 'README.md' || "$base" == 'readme.md' ]] && continue
      # 特殊说明：docs-core.sh 在 scripts 流程中单独处理（为了明确来源）
      [[ "$label" == "scripts" && "$base" == "docs-core.sh" ]] && continue

      if [[ -d "$item" ]]; then
        sync_tree_excluding_readme "$item" "$dst_dir/$base"
      else
        copy_file_plain "$item" "$dst_dir/$base"
      fi
    done

    if [[ "${CFG[dry_run]}" == '0' ]]; then
      sdx_rewrite_agent_path_segment_in_tree "$dst_dir" "$agent_slash"
    fi
  done
}

install_agent_scripts() {
  (( INSTALL_SCRIPTS == 1 )) || return 0
  install_agent_resource "scripts" "agent/scripts" "scripts"
  
  # 补充 docs-core.sh
  local agent agent_dir src_docs_ssot="${CFG[repo_root]}/agent/scripts/docs-core.sh"
  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    copy_file_plain "$src_docs_ssot" "${agent_dir}/scripts/docs-core.sh"
  done
}

install_agent_skills() {
  (( INSTALL_SKILLS == 1 )) || return 0
  install_agent_resource "skills" "agent/skills" "skills"
}

install_agent_rules() {
  (( INSTALL_RULES == 1 )) || return 0
  install_agent_resource "rules" "agent/rules" "rules"
}

install_agent_hooks() {
  (( INSTALL_HOOKS == 1 )) || return 0
  local agent agent_dir agent_slash
  local hooks_src="${CFG[repo_root]}/agent/hooks"
  local hooks_json="${CFG[repo_root]}/agent/hooks.json"

  [[ -d "$hooks_src" || -f "$hooks_json" ]] || { sdx_warn "未找到 agent/hooks 或 agent/hooks.json"; return 0; }

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"
    sdx_info ">>> 安装 ${agent}：hooks"
    [[ -d "$hooks_src" ]] && sync_tree_excluding_readme "$hooks_src" "${agent_dir}/hooks"
    [[ -f "$hooks_json" ]] && copy_file_plain "$hooks_json" "${agent_dir}/hooks.json"

    if [[ "${CFG[dry_run]}" == '0' ]]; then
      [[ -d "${agent_dir}/hooks" ]] && sdx_rewrite_agent_path_segment_in_tree "${agent_dir}/hooks" "$agent_slash"
      if [[ -f "${agent_dir}/hooks.json" ]]; then
        if [[ "${CFG[target_abs]}" == "${CFG[home_abs]}" ]]; then
          if have_perl; then
            # 仅在 $HOME 场景下，定向处理 hooks.json 的 command 值：agent/ -> 空。
            perl -0777 -i -pe 's/("command"\s*:\s*"[^"\n]*)agent\//\1/g' "${agent_dir}/hooks.json"
          else
            sdx_warn "未检测到 perl：跳过 hooks.json command 的 agent/ 前缀去除。"
          fi
        else
          sdx_rewrite_agent_path_segment_in_file "${agent_dir}/hooks.json" "$agent_slash"
        fi
      fi
    fi
  done
}

install_agent() {
  install_agent_scripts
  install_agent_rules
  install_agent_skills
  install_agent_hooks
}

# 计算 agent-install 写回 .docsconfig 所需 AGENT_*
# 用法：install_agent_path <nameref_agent_root_out> <nameref_agent_dirs_out>
install_agent_path() {
  local -n _ar_out="${1:?}"
  local -n _ads_out="${2:?}"
  _ar_out="$(strip_trailing_slash "${CFG[target_abs]}")"
  _ads_out="$(agent_dirs_space_separated_for "${ENABLED_AGENTS[@]}")"
}

# =============================================================================
# install config：target ≠ $HOME 时更新 AGENT_ROOT / AGENT_DIRS
# =============================================================================

install_agent_config() {
  local t h
  t="$(strip_trailing_slash "${CFG[target_abs]}")"
  h="$(strip_trailing_slash "${CFG[home_abs]}")"
  [[ "$t" != "$h" ]] || return 0

  local cfg="$t/.docsconfig"
  [[ -f "$cfg" ]] \
    || sdx_error "未找到 $cfg。请先在该工程执行 docs-install（或 docs-install --scope=config <目标工程文档目录>）生成 .docsconfig。"

  local doc_root repo_root doc_dir _ar_old _ads_old kt
  docsconfig_read_into "$cfg" doc_root repo_root doc_dir _ar_old _ads_old kt \
    || sdx_error "无法解析: $cfg"

  [[ -n "$doc_root" && -n "$repo_root" && -n "$doc_dir" ]] \
    || sdx_error ".docsconfig 缺少 DOC_ROOT/REPO_ROOT/DOC_DIR，请重新执行 docs-install。"

  local ar ads
  install_agent_path ar ads

  sdx_info ">>> 更新 .docsconfig 中的 AGENT_ROOT / AGENT_DIRS（按本次参数重算）: $cfg"
  docsconfig_write "$t" "$doc_root" "$doc_dir" "${CFG[dry_run]}" "$ar" "$ads" "${kt:-}"
}

# =============================================================================
# CLI
# =============================================================================

usage() {
  cat >&2 <<'EOF'
用法
  agent-install.sh [选项]

说明
  将本仓库 agent/{scripts,rules,skills,hooks} 安装到 --target 下、按 --agents 选定的多分根：
    ${TARGET}/.{.cursor|.trea|.claude}/...
  scripts 阶段会从本仓库复制 agent/scripts/docs-core.sh 到各选中 Agent 的 scripts/docs-core.sh。
  不安装README。
  当 --target 不是 $HOME 时，更新 <target>/.docsconfig 的 AGENT_ROOT 与 AGENT_DIRS（与当前 --agents 一致）；
  若该文件不存在，请先对目标工程执行 docs-install。

选项
  --scope=SCOPE   a=全部 | r=rules | s=skills | h=hooks | sh=scripts  [默认: a]
  --target=PATH   安装根父目录，其下仅为选中的 agent 创建对应目录  [默认: $HOME]
  --agents=LIST   cursor | trea | claude | all；逗号或空格分隔多选  [默认: cursor]
  --dry-run       仅打印将执行的操作
  -h, --help      显示此帮助

环境变量
  REPO_ROOT       本仓库（中央库）根目录（默认：本脚本所在仓库根）
  AGENTS_OPT      未传 --agents 时作为默认值（否则以命令行 --agents 为准）

示例
  ./scripts/agent-install.sh
  ./scripts/agent-install.sh --agents=cursor,claude
  ./scripts/agent-install.sh --scope=sh --dry-run
  ./scripts/agent-install.sh --target ~/workspace/my-repo --agents=all
EOF
}

parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --scope=*)
        CFG[scope]="${1#*=}"
        shift
        ;;
      --scope)
        shift
        [[ -n "${1:-}" ]] || sdx_error "缺少 --scope 值"
        CFG[scope]="$1"
        shift
        ;;
      --target=*)
        CFG[target_abs]="${1#*=}"
        shift
        ;;
      --target)
        shift
        [[ -n "${1:-}" ]] || sdx_error "缺少 --target 值"
        CFG[target_abs]="$1"
        shift
        ;;
      --agents=*)
        CFG[agents_opt]="${1#*=}"
        shift
        ;;
      --agents)
        shift
        local -a parts=()
        while (( $# > 0 )); do
          case "$1" in -*) break ;; *) parts+=("$1"); shift ;; esac
        done
        (( ${#parts[@]} > 0 )) || sdx_error "缺少 --agents 值（如 cursor,trea 或 cursor trea）"
        CFG[agents_opt]="$(IFS=','; printf '%s' "${parts[*]}")"
        ;;
      --dry-run)
        CFG[dry_run]=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        sdx_error "未知或不支持的参数: $1（支持 --scope / --target / --agents / --dry-run）"
        ;;
    esac
  done
}

agent_install_run() {
  init_repo_root
  [[ -n "${HOME:-}" ]] || sdx_error "需要 HOME 环境变量"
  CFG[home_abs]="$(abs_path "$HOME")"

  if [[ -z "${CFG[target_abs]:-}" ]]; then
    CFG[target_abs]="${CFG[home_abs]}"
  else
    CFG[target_abs]="$(strip_trailing_slash "$(abs_path "${CFG[target_abs]}")")"
  fi

  apply_scope
  apply_agents

  have_perl || sdx_warn "未检测到 perl：路径替换可能被跳过，建议安装 perl。"

  install_agent
  install_agent_config

  sdx_info "完成：agent-install"
}

main() {
  parse_args "$@"
  agent_install_run
}

main "$@"
