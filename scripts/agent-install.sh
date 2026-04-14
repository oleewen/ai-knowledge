#!/usr/bin/env bash
# agent-install.sh — 安装 Agent（scripts / rules / skills / hooks）并按需更新 .docsconfig 中的 AGENT_*
#
# 配置面：source 同目录 agent-config.sh。
#
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent-config.sh
source "${SCRIPT_DIR}/agent-config.sh"

log()   { printf '%s\n'       "$*" >&2; }
info()  { printf '信息: %s\n'  "$*" >&2; }
warn()  { printf '警告: %s\n'  "$*" >&2; }
error() { printf '错误: %s\n' "$*" >&2; exit 1; }

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

have_cmd()  { command -v "$1" >/dev/null 2>&1; }
have_perl() { have_cmd perl; }

is_text_file() {
  local f="$1"
  case "$f" in
    *.md|*.yaml|*.yml|*.json|*.jsonl|*.txt|*.sh|*.gitignore|*.html|*.css|*.js|*.toml)
      return 0 ;;
  esac
  if have_cmd file; then
    local mt
    mt="$(file -b --mime-type "$f" 2>/dev/null || true)"
    [[ "$mt" == text/* || "$mt" == application/json || "$mt" == *yaml* || "$mt" == *json* ]] && return 0
  fi
  return 1
}

run_or_dry() {
  if [[ "${CFG[dry_run]}" == '1' ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

ensure_dir() { run_or_dry mkdir -p "$1"; }

# 同步目录树，排除各层 README / readme.md
sync_tree_excluding_readme() {
  local src="$1" dst="$2"
  [[ -d "$src" ]] || return 0
  if [[ "${CFG[dry_run]}" == '1' ]]; then
    log "[dry-run] 同步目录: $src → $dst"
    return 0
  fi
  ensure_dir "$dst"
  if have_cmd rsync; then
    rsync -a --delete \
      --exclude 'README' --exclude 'README.md' --exclude 'readme.md' \
      "$src"/ "$dst"/
  else
    warn "未检测到 rsync，使用 cp -R（无法排除 README；建议安装 rsync）"
    rm -rf "$dst"
    ensure_dir "$(dirname "$dst")"
    cp -R "$src" "$dst"
  fi
}

copy_file_plain() {
  local src="$1" dst="$2"
  if [[ "${CFG[dry_run]}" == '1' ]]; then
    log "[dry-run] 拷贝: $src → $dst"
    return 0
  fi
  ensure_dir "$(dirname "$dst")"
  cp "$src" "$dst"
}

# 将 agent/ 前缀替换为 <agent_slash>（如 .cursor/）
rewrite_agent_file() {
  local file="$1" agent_slash="$2"
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  have_perl || return 0
  SDX_AGENT_SLASH="$agent_slash" \
    perl -CSD -i -pe 's{\bagent/}{$ENV{SDX_AGENT_SLASH}}g' \
    "$file" 2>/dev/null || true
}

rewrite_agent_tree() {
  local root="$1" agent_slash="$2"
  [[ -d "$root" ]] || return 0
  local f
  while IFS= read -r -d '' f; do
    rewrite_agent_file "$f" "$agent_slash"
  done < <(find "$root" -type f -print0 2>/dev/null || true)
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
  [[ -d "$rr/agent/rules"   ]] || error "未找到 agent/rules: $rr/agent/rules"
  [[ -d "$rr/agent/skills"  ]] || error "未找到 agent/skills: $rr/agent/skills"
  [[ -d "$rr/agent/hooks"   ]] || error "未找到 agent/hooks: $rr/agent/hooks"
  [[ -d "$rr/agent/scripts" ]] || error "未找到 agent/scripts: $rr/agent/scripts"
  [[ -f "$rr/agent/scripts/docs-core.sh" ]] || error "未找到 agent/scripts/docs-core.sh: $rr/agent/scripts/docs-core.sh"
}

apply_scope() {
  validate_agent_scope_token "${CFG[scope]}" \
    || error "无效 --scope: ${CFG[scope]}（支持 a|r|s|h|sh）"
  agent_scope_apply "${CFG[scope]}" INSTALL_RULES INSTALL_SKILLS INSTALL_HOOKS INSTALL_SCRIPTS \
    || error "内部错误：无法应用 scope: ${CFG[scope]}"
}

apply_agents() {
  local ao="${CFG[agents_opt]:-}"
  [[ -n "$ao" ]] || ao="${AGENTS_OPT:-$SDX_DEFAULT_AGENTS_OPT}"
  validate_agents "$ao" \
    || error "无效 --agents: $ao（支持 cursor、trea、claude、all 及逗号或空格分隔多选）"
  read -ra ENABLED_AGENTS <<< "$(normalize_agents "$ao")"
  (( ${#ENABLED_AGENTS[@]} > 0 )) || error "未解析到任何 Agent"
}

# =============================================================================
# 安装各子树
# =============================================================================

install_agent_scripts() {
  (( INSTALL_SCRIPTS == 1 )) || return 0
  local agent agent_dir agent_slash
  local src_scripts="${CFG[repo_root]}/agent/scripts"
  local src_docs_ssot="${CFG[repo_root]}/agent/scripts/docs-core.sh"
  local item base dst_scripts

  [[ -d "$src_scripts" ]] || { warn "未找到 agent/scripts，跳过"; return 0; }

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"
    info ">>> 安装 ${agent}：scripts"
    dst_scripts="${agent_dir}/scripts"
    ensure_dir "$dst_scripts"

    shopt -s nullglob
    for item in "$src_scripts"/*; do
      base="$(basename "$item")"
      [[ "$base" == 'README' || "$base" == 'README.md' || "$base" == 'readme.md' ]] && continue
      [[ "$base" == 'docs-core.sh' ]] && continue
      if [[ -d "$item" ]]; then
        sync_tree_excluding_readme "$item" "$dst_scripts/$base"
      else
        copy_file_plain "$item" "$dst_scripts/$base"
      fi
    done
    copy_file_plain "$src_docs_ssot" "$dst_scripts/docs-core.sh"

    if [[ "${CFG[dry_run]}" == '0' ]]; then
      rewrite_agent_tree "$dst_scripts" "$agent_slash"
    fi
  done
}

install_agent_skills() {
  (( INSTALL_SKILLS == 1 )) || return 0
  local agent agent_dir agent_slash
  local skills_root="${CFG[repo_root]}/agent/skills"
  local sd skill

  [[ -d "$skills_root" ]] || { warn "未找到 agent/skills"; return 0; }

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"
    info ">>> 安装 ${agent}：skills"
    ensure_dir "${agent_dir}/skills"

    shopt -s nullglob
    for sd in "$skills_root"/*/; do
      [[ -d "$sd" ]] || continue
      skill="$(basename "$sd")"
      sync_tree_excluding_readme "$sd" "${agent_dir}/skills/$skill"
    done

    if [[ "${CFG[dry_run]}" == '0' ]]; then
      rewrite_agent_tree "${agent_dir}/skills" "$agent_slash"
    fi
  done
}

install_agent_rules() {
  (( INSTALL_RULES == 1 )) || return 0
  local agent agent_dir agent_slash
  local rules_src="${CFG[repo_root]}/agent/rules"
  local item base

  [[ -d "$rules_src" ]] || { warn "未找到 agent/rules"; return 0; }

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"
    info ">>> 安装 ${agent}：rules"
    ensure_dir "${agent_dir}/rules"

    shopt -s nullglob
    for item in "$rules_src"/*; do
      base="$(basename "$item")"
      [[ "$base" == 'README' || "$base" == 'README.md' || "$base" == 'readme.md' ]] && continue
      if [[ -d "$item" ]]; then
        sync_tree_excluding_readme "$item" "${agent_dir}/rules/$base"
      else
        copy_file_plain "$item" "${agent_dir}/rules/$base"
      fi
    done

    if [[ "${CFG[dry_run]}" == '0' ]]; then
      rewrite_agent_tree "${agent_dir}/rules" "$agent_slash"
    fi
  done
}

install_agent_hooks() {
  (( INSTALL_HOOKS == 1 )) || return 0
  local agent agent_dir agent_slash
  local hooks_src="${CFG[repo_root]}/agent/hooks"
  local hooks_json="${CFG[repo_root]}/agent/hooks/hooks.json"

  [[ -d "$hooks_src" || -f "$hooks_json" ]] || { warn "未找到 agent/hooks 或 agent/hooks/hooks.json"; return 0; }

  for agent in "${ENABLED_AGENTS[@]}"; do
    agent_dir="$(agent_install_root "$agent")"
    agent_slash="$(get_agent_dir "$agent")/"
    info ">>> 安装 ${agent}：hooks"
    [[ -d "$hooks_src" ]] && sync_tree_excluding_readme "$hooks_src" "${agent_dir}/hooks"
    [[ -f "$hooks_json" ]] && copy_file_plain "$hooks_json" "${agent_dir}/hooks.json"

    if [[ "${CFG[dry_run]}" == '0' ]]; then
      [[ -d "${agent_dir}/hooks" ]] && rewrite_agent_tree "${agent_dir}/hooks" "$agent_slash"
      [[ -f "${agent_dir}/hooks.json" ]] && rewrite_agent_file "${agent_dir}/hooks.json" "$agent_slash"
    fi
  done
}

install_agent() {
  install_agent_scripts
  install_agent_rules
  install_agent_skills
  install_agent_hooks
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
    || error "未找到 $cfg。请先在该工程执行 docs-install（或 docs-install --scope=config <目标工程文档目录>）生成 .docsconfig。"

  local doc_root repo_root doc_dir _ar_old _ads_old kt
  docsconfig_read_into "$cfg" doc_root repo_root doc_dir _ar_old _ads_old kt \
    || error "无法解析: $cfg"

  [[ -n "$doc_root" && -n "$repo_root" && -n "$doc_dir" ]] \
    || error ".docsconfig 缺少 DOC_ROOT/REPO_ROOT/DOC_DIR，请重新执行 docs-install。"

  local ads
  ads="$(agent_dirs_space_separated_for "${ENABLED_AGENTS[@]}")"

  info ">>> 更新 .docsconfig 中的 AGENT_ROOT / AGENT_DIRS: $cfg"
  docsconfig_write "$t" "$doc_root" "$doc_dir" "${CFG[dry_run]}" "$t" "$ads" "${kt:-}"
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
        [[ -n "${1:-}" ]] || error "缺少 --scope 值"
        CFG[scope]="$1"
        shift
        ;;
      --target=*)
        CFG[target_abs]="${1#*=}"
        shift
        ;;
      --target)
        shift
        [[ -n "${1:-}" ]] || error "缺少 --target 值"
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
        (( ${#parts[@]} > 0 )) || error "缺少 --agents 值（如 cursor,trea 或 cursor trea）"
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
        error "未知或不支持的参数: $1（支持 --scope / --target / --agents / --dry-run）"
        ;;
    esac
  done
}

agent_install_run() {
  init_repo_root
  [[ -n "${HOME:-}" ]] || error "需要 HOME 环境变量"
  CFG[home_abs]="$(abs_path "$HOME")"

  if [[ -z "${CFG[target_abs]:-}" ]]; then
    CFG[target_abs]="${CFG[home_abs]}"
  else
    CFG[target_abs]="$(strip_trailing_slash "$(abs_path "${CFG[target_abs]}")")"
  fi

  apply_scope
  apply_agents

  have_perl || warn "未检测到 perl：路径替换可能被跳过，建议安装 perl。"

  install_agent
  install_agent_config

  info "完成：agent-install"
}

main() {
  parse_args "$@"
  agent_install_run
}

main "$@"
