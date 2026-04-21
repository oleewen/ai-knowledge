#!/usr/bin/env bash
#
# docs-bootstrap.sh — SDX 知识库初始化引导脚本
#
# 职责：
#   无需预先克隆 ai-knowledge：克隆到临时目录后，交互引导用户完成
#   docs-install（知识库初始化）和 agent-install（Agent 安装）。
#
# 依赖：Bash 5+、Git、网络连接（可访问 GitHub）
#
# 用法：
#   # 交互模式（推荐）
#   bash docs-bootstrap.sh
#
#   # 全参数模式
#   bash docs-bootstrap.sh --doc-target=~/workspace/my-app/docs --agents=cursor,kiro
#
#   # curl | bash
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh \
#     | bash -s -- --doc-target=~/workspace/my-app/docs --agents=cursor,kiro
#
# 参数：
#   --doc-target=PATH          目标工程文档目录（必填，或交互询问）
#   --agents=LIST              要安装的 Agent，/ 或 , 分隔（缺省交互询问，默认 cursor）
#   --agent-scope=home|project Agent 安装位置（默认 home=$HOME）
#
# 配置项（GIT_REPO_URL/GIT_REF）：agent/scripts/docs-core.sh
#
set -euo pipefail

# =============================================================================
# § 1  预载共享配置（仅从已克隆仓库运行时）
# =============================================================================

_BOOTSTRAP_SCRIPT_DIR=''
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != '-' ]]; then
  _BOOTSTRAP_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || true
fi
if [[ -n "$_BOOTSTRAP_SCRIPT_DIR" && -f "${_BOOTSTRAP_SCRIPT_DIR}/../agent/scripts/docs-core.sh" ]]; then
  # shellcheck source=/dev/null
  source "${_BOOTSTRAP_SCRIPT_DIR}/../agent/scripts/docs-core.sh"
fi

if ! declare -F require_bash5 >/dev/null 2>&1; then
  require_bash5() {
    if (( BASH_VERSINFO[0] < 5 )); then
      printf '[FATAL] 需要 Bash %s+，当前版本: %s\n' 5 "$BASH_VERSION" >&2
      exit 1
    fi
  }
fi
if ! declare -F sdx_docs_bootstrap_get_repo_url >/dev/null 2>&1; then
  _SDX_GIT_REPO_URL_FALLBACK='https://github.com/oleewen/ai-knowledge.git'
  _SDX_GIT_DEFAULT_REF_FALLBACK='HEAD'
  sdx_docs_bootstrap_get_repo_url() {
    printf '%s' "${GIT_REPO_URL:-$_SDX_GIT_REPO_URL_FALLBACK}"
  }
  sdx_docs_bootstrap_get_ref() {
    printf '%s' "${GIT_REF:-$_SDX_GIT_DEFAULT_REF_FALLBACK}"
  }
  sdx_docs_bootstrap_get_tmpdir() {
    local tmpdir="${TMPDIR:-/tmp}"
    [[ -d "$tmpdir" ]] || tmpdir='/tmp'
    printf '%s' "$tmpdir"
  }
  sdx_docs_bootstrap_gen_clone_dir() {
    printf '%s/ai-knowledge-%s' "${1:?tmpdir}" "$$"
  }
fi

# =============================================================================
# § 2  运行时状态
# =============================================================================

SDX_BS_CLONE_DIR=''
SDX_BS_DOC_TARGET=''      # --doc-target
SDX_BS_AGENTS=''          # --agents（规范化后逗号分隔）
SDX_BS_AGENT_SCOPE='home' # --agent-scope: home | project
SDX_BS_AGENT_TARGET=''    # 推导结果：$HOME 或 dirname(doc-target)

# =============================================================================
# § 3  日志与错误处理（回退逻辑以支持 standalone curl | bash）
# =============================================================================

if ! declare -F sdx_log >/dev/null 2>&1; then
  sdx_log()   { printf '%s\n'       "$*" >&2; }
  sdx_info()  { printf '[INFO]  %s\n' "$*" >&2; }
  sdx_error() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
fi

sdx_bs_die() {
  sdx_error "$1"
}

# =============================================================================
# § 4  环境检查（Bash 版本见 docs-core.sh 之 require_bash5；预载失败时 §1 回退已定义）
# =============================================================================

sdx_bs_has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

sdx_bs_check_deps() {
  sdx_bs_has_cmd git || sdx_bs_die "未找到 git 命令，请先安装 Git"
}

# =============================================================================
# § 5  Git
# =============================================================================

sdx_bs_clone_repo() {
  local repo_url="$1" ref="$2" dest_dir="$3"

  if [[ -d "$dest_dir" ]]; then
    sdx_info "清理已存在的临时目录: $dest_dir"
    rm -rf "$dest_dir"
  fi

  sdx_info "克隆仓库: $repo_url → $dest_dir"

  if [[ "$ref" == 'HEAD' || -z "$ref" ]]; then
    git clone --depth 1 "$repo_url" "$dest_dir" \
      || { sdx_error "克隆失败: $repo_url"; }
  else
    sdx_info "  分支/标签: $ref"
    git clone --depth 1 --single-branch -b "$ref" "$repo_url" "$dest_dir" \
      || { sdx_error "克隆失败: $repo_url (ref: $ref)"; }
  fi
}

sdx_bs_cleanup() {
  if [[ -n "$SDX_BS_CLONE_DIR" && -d "$SDX_BS_CLONE_DIR" ]]; then
    sdx_info "清理临时目录: $SDX_BS_CLONE_DIR"
    rm -rf "$SDX_BS_CLONE_DIR"
  fi
}

# =============================================================================
# § 6  参数解析
# =============================================================================

sdx_bs_usage() {
  cat >&2 <<'EOF'
用法
  docs-bootstrap.sh [选项]

选项
  --doc-target=PATH          目标工程文档目录（必填，或交互询问）
  --agents=LIST              要安装的 Agent，支持 / 或 , 分隔
                             合法值：cursor trea claude kiro all
                             （缺省时交互询问，默认 cursor）
  --agent-scope=home|project Agent 安装位置（默认 home）
                             home    → 安装到 $HOME
                             project → 安装到 dirname(--doc-target)
  -h, --help                 显示此帮助

环境变量
  GIT_REPO_URL   覆盖中央库 Git 地址
  GIT_REF        覆盖克隆分支/标签

示例
  # 交互模式
  bash docs-bootstrap.sh

  # 全参数模式
  bash docs-bootstrap.sh --doc-target=~/workspace/my-app/docs --agents=cursor,kiro

  # curl | bash
  curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh \
    | bash -s -- --doc-target=~/workspace/my-app/docs --agents=cursor,kiro
EOF
}

# 将 / 或 , 分隔的 agents 字符串规范化为逗号分隔
sdx_bs_normalize_agents() {
  local raw="${1:-}"
  printf '%s' "$raw" | tr '/' ',' | tr -s ',' | sed 's/^,//;s/,$//'
}

# 校验 agents 字符串（逗号分隔）中每个值是否合法
sdx_bs_validate_agents() {
  local agents_csv="${1:-}"
  local -a valid=(cursor trea claude kiro all)
  local agent ok v msg
  IFS=',' read -ra parts <<< "$agents_csv"
  for agent in "${parts[@]}"; do
    agent="${agent// /}"
    [[ -z "$agent" ]] && continue
    ok=0
    for v in "${valid[@]}"; do
      [[ "$agent" == "$v" ]] && { ok=1; break; }
    done
    if [[ $ok -ne 1 ]]; then
      msg="无效 agent: ${agent}（合法值：cursor trea claude kiro all）"
      sdx_error "$msg"
    fi
  done
}

sdx_bs_parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --doc-target=*)
        SDX_BS_DOC_TARGET="${1#*=}"
        shift
        ;;
      --doc-target)
        shift
        [[ -n "${1:-}" ]] || sdx_bs_die "缺少 --doc-target 值"
        SDX_BS_DOC_TARGET="$1"
        shift
        ;;
      --agents=*)
        SDX_BS_AGENTS="$(sdx_bs_normalize_agents "${1#*=}")"
        shift
        ;;
      --agents)
        shift
        [[ -n "${1:-}" ]] || sdx_bs_die "缺少 --agents 值"
        SDX_BS_AGENTS="$(sdx_bs_normalize_agents "$1")"
        shift
        ;;
      --agent-scope=*)
        SDX_BS_AGENT_SCOPE="${1#*=}"
        shift
        ;;
      --agent-scope)
        shift
        [[ -n "${1:-}" ]] || sdx_bs_die "缺少 --agent-scope 值"
        SDX_BS_AGENT_SCOPE="$1"
        shift
        ;;
      -h|--help)
        sdx_bs_usage
        exit 0
        ;;
      *)
        sdx_bs_die "未知参数: $1（使用 -h 查看帮助）"
        ;;
    esac
  done

  # 校验 --agent-scope
  case "$SDX_BS_AGENT_SCOPE" in
    home|project) ;;
    *) sdx_bs_die "无效 --agent-scope: ${SDX_BS_AGENT_SCOPE}（合法值：home project）" ;;
  esac

  # 若已传 --agents，立即校验
  [[ -z "$SDX_BS_AGENTS" ]] || sdx_bs_validate_agents "$SDX_BS_AGENTS"
}

# =============================================================================
# § 6.5  交互询问（仅对缺失参数，非交互环境直接报错）
# =============================================================================

# 检测是否为交互环境（stdin 为 tty）
sdx_bs_is_interactive() {
  [[ -t 0 ]]
}

# 询问目标工程文档目录（循环直到父目录存在）
sdx_bs_prompt_doc_target() {
  local input parent
  while true; do
    printf '请输入目标工程文档目录（如 ~/workspace/my-app/docs）：' >&2
    IFS= read -r input || sdx_bs_die "读取输入失败"
    # 展开 ~
    input="${input/#\~/$HOME}"
    parent="$(dirname "$input")"
    if [[ -d "$parent" ]]; then
      SDX_BS_DOC_TARGET="$input"
      return 0
    else
      sdx_log "父目录不存在：$parent，请重新输入。"
    fi
  done
}

# 询问要安装的 agent（展示编号列表，支持编号或名称输入）
sdx_bs_prompt_agents() {
  local -a agent_list=(cursor trea claude kiro all)
  sdx_log ''
  sdx_log '请选择要安装的 Agent（输入编号，多选用 / 或 , 分隔，直接回车选 1）：'
  local i
  for (( i=0; i<${#agent_list[@]}; i++ )); do
    printf '  %d) %s\n' $(( i+1 )) "${agent_list[$i]}" >&2
  done
  printf '选择：' >&2

  local input
  IFS= read -r input || sdx_bs_die "读取输入失败"
  [[ -z "$input" ]] && input='1'

  # 将编号转换为名称（支持 / 或 , 分隔的编号）
  local normalized
  normalized="$(printf '%s' "$input" | tr '/' ',')"
  local -a parts result_parts=()
  IFS=',' read -ra parts <<< "$normalized"
  for part in "${parts[@]}"; do
    part="${part// /}"
    [[ -z "$part" ]] && continue
    if [[ "$part" =~ ^[0-9]+$ ]]; then
      local idx=$(( part - 1 ))
      if (( idx >= 0 && idx < ${#agent_list[@]} )); then
        result_parts+=("${agent_list[$idx]}")
      else
        sdx_bs_die "无效编号: $part（合法范围 1-${#agent_list[@]}）"
      fi
    else
      result_parts+=("$part")
    fi
  done

  SDX_BS_AGENTS="$(IFS=','; printf '%s' "${result_parts[*]}")"
  sdx_bs_validate_agents "$SDX_BS_AGENTS"
}

# 推导 agent-target
sdx_bs_resolve_agent_target() {
  case "$SDX_BS_AGENT_SCOPE" in
    home)
      [[ -n "${HOME:-}" ]] || sdx_bs_die "需要 HOME 环境变量"
      SDX_BS_AGENT_TARGET="$HOME"
      ;;
    project)
      [[ -n "$SDX_BS_DOC_TARGET" ]] || sdx_bs_die "内部错误：doc-target 未就绪"
      SDX_BS_AGENT_TARGET="$(dirname "$SDX_BS_DOC_TARGET")"
      ;;
  esac
}

# 展示汇总并请求确认
sdx_bs_confirm_plan() {
  sdx_log ''
  sdx_log '=========================================='
  sdx_log '即将执行以下操作：'
  sdx_log "  1. docs-install  --target=${SDX_BS_DOC_TARGET}"
  sdx_log "  2. agent-install --agents=${SDX_BS_AGENTS} --target=${SDX_BS_AGENT_TARGET}"
  sdx_log '=========================================='
  printf '确认执行？[Y/n]：' >&2
  local ans
  IFS= read -r ans || ans='y'
  case "$ans" in
    n|N) sdx_log '已取消。'; exit 0 ;;
  esac
}

# 收集所有缺失参数（交互或报错）
sdx_bs_collect_params() {
  # doc-target
  if [[ -z "$SDX_BS_DOC_TARGET" ]]; then
    if sdx_bs_is_interactive; then
      sdx_bs_prompt_doc_target
    else
      sdx_bs_die "非交互环境：请通过 --doc-target=PATH 指定目标工程文档目录"
    fi
  else
    # 命令行传参时校验父目录
    local parent
    SDX_BS_DOC_TARGET="${SDX_BS_DOC_TARGET/#\~/$HOME}"
    parent="$(dirname "$SDX_BS_DOC_TARGET")"
    [[ -d "$parent" ]] || sdx_bs_die "父目录不存在：$parent"
  fi

  # agents
  if [[ -z "$SDX_BS_AGENTS" ]]; then
    if sdx_bs_is_interactive; then
      sdx_bs_prompt_agents
    else
      sdx_bs_die "非交互环境：请通过 --agents=LIST 指定要安装的 Agent（cursor trea claude kiro all）"
    fi
  fi

  # 推导 agent-target
  sdx_bs_resolve_agent_target

  # 汇总确认（仅交互环境）
  if sdx_bs_is_interactive; then
    sdx_bs_confirm_plan
  fi
}

# =============================================================================
# § 7  主流程
# =============================================================================

sdx_bs_main() {
  require_bash5
  sdx_bs_check_deps

  sdx_bs_parse_args "$@"
  sdx_bs_collect_params

  local repo_url ref tmpdir
  repo_url="$(sdx_docs_bootstrap_get_repo_url)"
  ref="$(sdx_docs_bootstrap_get_ref)"
  tmpdir="$(sdx_docs_bootstrap_get_tmpdir)"

  SDX_BS_CLONE_DIR="$(sdx_docs_bootstrap_gen_clone_dir "$tmpdir")"
  trap sdx_bs_cleanup EXIT

  sdx_log ''
  sdx_log '=========================================='
  sdx_log 'docs-bootstrap'
  sdx_info "仓库:        $repo_url"
  sdx_info "引用:        $ref"
  sdx_info "文档目录:    $SDX_BS_DOC_TARGET"
  sdx_info "Agents:      $SDX_BS_AGENTS"
  sdx_info "Agent 安装:  $SDX_BS_AGENT_TARGET"
  sdx_log '=========================================='
  sdx_log ''

  sdx_bs_clone_repo "$repo_url" "$ref" "$SDX_BS_CLONE_DIR" || exit 1

  local docs_install="${SDX_BS_CLONE_DIR}/scripts/docs-install.sh"
  local agent_install="${SDX_BS_CLONE_DIR}/scripts/agent-install.sh"
  local shared_config="${SDX_BS_CLONE_DIR}/agent/scripts/docs-core.sh"

  [[ -f "$docs_install"  ]] || sdx_bs_die "仓库中未找到 scripts/docs-install.sh"
  [[ -f "$agent_install" ]] || sdx_bs_die "仓库中未找到 scripts/agent-install.sh"
  [[ -f "$shared_config" ]] || sdx_bs_die "仓库中未找到 agent/scripts/docs-core.sh"

  # 克隆后统一加载 SSOT（若预载阶段已 source，此处因 _AGENT_SHARED_DOCS_CONFIG_LOADED 短路）
  # shellcheck disable=SC1090
  source "$shared_config"

  sdx_log ''
  sdx_info "已加载共享配置（agent/scripts/docs-core.sh）"

  # § 8  执行 docs-install
  sdx_log ''
  sdx_info '>>> 执行 docs-install.sh...'
  export REPO_ROOT="$SDX_BS_CLONE_DIR"
  bash "$docs_install" --target="$SDX_BS_DOC_TARGET" \
    || sdx_bs_die "docs-install 执行失败，已中止"

  # § 9  执行 agent-install
  sdx_log ''
  sdx_info '>>> 执行 agent-install.sh...'
  bash "$agent_install" --agents="$SDX_BS_AGENTS" --target="$SDX_BS_AGENT_TARGET" \
    || sdx_bs_die "agent-install 执行失败"

  sdx_log ''
  sdx_info '完成：docs-bootstrap'
}

sdx_bs_main "$@"
