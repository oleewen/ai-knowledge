#!/usr/bin/env bash
#
# bootstrap.sh — SDX 知识库初始化引导脚本
#
# 职责：
#   无需预先克隆 ai-knowledge：克隆到临时目录后，按 --components 执行
#   docs-install（知识库初始化）和/或 agent-install（Agent 安装）。
#
# 依赖：Bash 5+、Git、网络连接（可访问 GitHub；本地 GIT_REPO_URL 路径时可免网）
#
# 用法：
#   # 交互模式（推荐）
#   bash bootstrap.sh
#
#   # 全参数模式（both）
#   bash bootstrap.sh --doc-target ~/workspace/my-app/docs --agents=cursor,kiro
#
#   # 仅 Agent（任意目录 / curl）
#   bash bootstrap.sh --components=agent --agents=cursor --agent-scope=home
#
#   # curl | bash
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/bootstrap.sh | bash -s -- --doc-target ~/workspace/my-app/docs --agents=cursor,trae
#
# 参数：
#   --components=docs|agent|both  装机范围（默认 both）
#   --doc-target PATH          目标工程文档目录（components 含 docs 时必填或交互询问；仍兼容 --doc-target=PATH）
#   --agents=LIST              要安装的 Agent，/ 或 , 分隔（components 含 agent 时；缺省交互询问，默认 cursor）
#   --agent-scope=home|project Agent 安装位置（默认 home=$HOME；project 需 --doc-target 以推导工程根）
#
# 配置项（GIT_REPO_URL/GIT_REF）：agent/scripts/lib/docsconfig.sh（经 docs-core.sh 聚合）
#
set -euo pipefail

# =============================================================================
# § 1  预载共享配置（仅从已克隆仓库运行时）
# =============================================================================

_BOOTSTRAP_SCRIPT_DIR=''
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != '-' ]]; then
  _BOOTSTRAP_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || true
fi
if [[ -n "$_BOOTSTRAP_SCRIPT_DIR" && -f "${_BOOTSTRAP_SCRIPT_DIR}/agent/scripts/docs-core.sh" ]]; then
  # shellcheck source=/dev/null
  source "${_BOOTSTRAP_SCRIPT_DIR}/agent/scripts/docs-core.sh"
fi
if [[ -n "$_BOOTSTRAP_SCRIPT_DIR" && -f "${_BOOTSTRAP_SCRIPT_DIR}/agent/skills/agent-install/scripts/agent-config.sh" ]]; then
  # shellcheck source=/dev/null
  source "${_BOOTSTRAP_SCRIPT_DIR}/agent/skills/agent-install/scripts/agent-config.sh"
fi

if ! declare -F require_bash5 >/dev/null 2>&1; then
  require_bash5() {
    if (( BASH_VERSINFO[0] < 5 )); then
      printf '[FATAL] 需要 Bash %s+，当前版本: %s\n' 5 "$BASH_VERSION" >&2
      exit 1
    fi
  }
fi
if ! declare -F docsconfig_bootstrap_get_repo_url >/dev/null 2>&1; then
  _GIT_REPO_URL_FALLBACK='https://github.com/oleewen/ai-knowledge.git'
  _GIT_DEFAULT_REF_FALLBACK='HEAD'
  docsconfig_bootstrap_get_repo_url() {
    printf '%s' "${GIT_REPO_URL:-$_GIT_REPO_URL_FALLBACK}"
  }
  docsconfig_bootstrap_get_ref() {
    printf '%s' "${GIT_REF:-$_GIT_DEFAULT_REF_FALLBACK}"
  }
  docsconfig_bootstrap_get_tmpdir() {
    local tmpdir="${TMPDIR:-/tmp}"
    [[ -d "$tmpdir" ]] || tmpdir='/tmp'
    printf '%s' "$tmpdir"
  }
  docsconfig_bootstrap_gen_clone_dir() {
    printf '%s/ai-knowledge-%s' "${1:?tmpdir}" "$$"
  }
fi

# =============================================================================
# § 2  运行时状态
# =============================================================================

BS_CLONE_DIR=''
BS_COMPONENTS='both'  # --components: docs | agent | both
BS_DOC_TARGET=''      # --doc-target
BS_AGENTS=''          # --agents（规范化后逗号分隔）
BS_AGENT_SCOPE='home' # --agent-scope: home | project
BS_AGENT_TARGET=''

bs_want_docs() {
  case "$BS_COMPONENTS" in
    docs|both) return 0 ;;
    *) return 1 ;;
  esac
}

bs_want_agent() {
  case "$BS_COMPONENTS" in
    agent|both) return 0 ;;
    *) return 1 ;;
  esac
}
if declare -p SUPPORTED_AGENTS >/dev/null 2>&1; then
  BS_AGENT_CHOICES=("${SUPPORTED_AGENTS[@]}" all)
else
  readonly -a BS_AGENT_CHOICES=(cursor trae claude kiro codex all)
fi

if ! declare -F log >/dev/null 2>&1; then
  log()   { printf '%s\n'       "$*" >&2; }
  info()  { printf '[INFO]  %s\n' "$*" >&2; }
  error() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
fi

bs_require_value() {
  local flag="${1:?flag}"
  local value="${2-}"
  [[ -n "$value" ]] || error "缺少 ${flag} 值"
}

bs_unknown_arg() {
  local arg="${1:?arg}"
  error "未知参数: ${arg}（使用 -h 查看帮助）"
}

# =============================================================================
# § 4  环境检查（Bash 版本见 docs-core.sh 之 require_bash5；预载失败时 §1 回退已定义）
# =============================================================================

bs_check_deps() {
  command -v git >/dev/null 2>&1 || error "未找到 git 命令，请先安装 Git"
}

# =============================================================================
# § 5  Git
# =============================================================================

bs_clone_repo() {
  local repo_url="$1" ref="$2" dest_dir="$3"

  if [[ -d "$dest_dir" ]]; then
    info "清理已存在的临时目录: $dest_dir"
    rm -rf "$dest_dir"
  fi

  # 本地路径：镜像工作区（含未提交文件），便于本仓测与本地 GIT_REPO_URL
  if [[ -d "$repo_url" ]]; then
    info "同步本地仓库工作区: $repo_url → $dest_dir"
    mkdir -p "$dest_dir"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --delete --exclude '.git' "${repo_url%/}/" "${dest_dir}/" \
        || error "本地同步失败: $repo_url"
    else
      cp -R "${repo_url%/}/." "$dest_dir/" || error "本地复制失败: $repo_url"
      rm -rf "${dest_dir}/.git"
    fi
    return 0
  fi

  info "克隆仓库: $repo_url → $dest_dir"

  if [[ "$ref" == 'HEAD' || -z "$ref" ]]; then
    git clone --depth 1 "$repo_url" "$dest_dir" \
      || error "克隆失败: $repo_url"
  else
    info "  分支/标签: $ref"
    git clone --depth 1 --single-branch -b "$ref" "$repo_url" "$dest_dir" \
      || error "克隆失败: $repo_url (ref: $ref)"
  fi
}

bs_cleanup() {
  if [[ -n "$BS_CLONE_DIR" && -d "$BS_CLONE_DIR" ]]; then
    info "清理临时目录: $BS_CLONE_DIR"
    rm -rf "$BS_CLONE_DIR"
  fi
}

# =============================================================================
# § 6  参数解析
# =============================================================================

bs_usage() {
  cat >&2 <<'EOF'
用法
  bootstrap.sh [选项]

选项
  --components=docs|agent|both  装机范围（默认 both）
                             docs  → 仅 docs-install
                             agent → 仅 agent-install
                             both  → 二者依次执行
  --doc-target PATH          目标工程文档目录（components 含 docs 时必填，或交互询问；
                             agent-scope=project 时亦需，用于推导工程根；仍兼容 --doc-target=PATH）
  --agents=LIST              要安装的 Agent，支持 / 或 , 分隔
EOF
  (
    printf '                             合法值：'
    IFS=' '
    printf '%s' "${BS_AGENT_CHOICES[*]}"
    printf '\n'
  ) >&2
  cat >&2 <<'EOF'
                             （components 含 agent 且缺省时交互询问，默认 cursor）
  --agent-scope=home|project Agent 安装位置（默认 home）
                             home    → 安装到 $HOME
                             project → 安装到 dirname(--doc-target)
  -h, --help                 显示此帮助

环境变量
  GIT_REPO_URL   覆盖中央库 Git 地址（可为本地路径）
  GIT_REF        覆盖克隆分支/标签

示例
  # 交互模式
  bash bootstrap.sh

  # both
  bash bootstrap.sh --doc-target ~/workspace/my-app/docs --agents=cursor,kiro

  # 仅 Agent（任意目录）
  bash bootstrap.sh --components=agent --agents=cursor --agent-scope=home

  # curl | bash
  curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/bootstrap.sh \
    | bash -s -- --doc-target ~/workspace/my-app/docs --agents=cursor,kiro
EOF
}

bs_normalize_agents() {
  local raw="${1:-}"
  raw="$(printf '%s' "$raw" | tr '/' ',')"
  if declare -f agents_normalize >/dev/null; then
    agents_normalize "$raw"
  else
    printf '%s' "$raw" | tr -s ',' | sed 's/^,//;s/,$//'
  fi
}

bs_validate_agents() {
  local agents_csv="${1:-}" agent
  if declare -f agents_validate >/dev/null; then
    IFS=',' read -ra parts <<< "$agents_csv"
    for agent in "${parts[@]}"; do
      agent="${agent// /}"
      [[ -z "$agent" ]] && continue
      agents_validate "$agent" || error "无效 agent: ${agent}"
    done
    return 0
  fi
  local ok v legal
  legal="$(IFS=' '; printf '%s' "${BS_AGENT_CHOICES[*]}")"
  IFS=',' read -ra parts <<< "$agents_csv"
  for agent in "${parts[@]}"; do
    agent="${agent// /}"
    [[ -z "$agent" ]] && continue
    ok=0
    for v in "${BS_AGENT_CHOICES[@]}"; do
      [[ "$agent" == "$v" ]] && { ok=1; break; }
    done
    [[ $ok -eq 1 ]] || error "无效 agent: ${agent}（合法值：${legal}）"
  done
}

bs_parse_args() {
  while (( $# > 0 )); do
    case "$1" in
      --components=*)
        BS_COMPONENTS="${1#*=}"
        shift
        ;;
      --components)
        shift
        bs_require_value "--components" "${1:-}"
        BS_COMPONENTS="$1"
        shift
        ;;
      --doc-target=*)
        BS_DOC_TARGET="${1#*=}"
        shift
        ;;
      --doc-target)
        shift
        bs_require_value "--doc-target" "${1:-}"
        BS_DOC_TARGET="$1"
        shift
        ;;
      --agents=*)
        BS_AGENTS="$(bs_normalize_agents "${1#*=}")"
        shift
        ;;
      --agents)
        shift
        bs_require_value "--agents" "${1:-}"
        BS_AGENTS="$(bs_normalize_agents "$1")"
        shift
        ;;
      --agent-scope=*)
        BS_AGENT_SCOPE="${1#*=}"
        shift
        ;;
      --agent-scope)
        shift
        bs_require_value "--agent-scope" "${1:-}"
        BS_AGENT_SCOPE="$1"
        shift
        ;;
      -h|--help)
        bs_usage
        exit 0
        ;;
      *)
        bs_unknown_arg "$1"
        ;;
    esac
  done

  case "$BS_COMPONENTS" in
    docs|agent|both) ;;
    *) error "无效 --components: ${BS_COMPONENTS}（合法值：docs agent both）" ;;
  esac

  # 校验 --agent-scope
  case "$BS_AGENT_SCOPE" in
    home|project) ;;
    *) error "无效 --agent-scope: ${BS_AGENT_SCOPE}（合法值：home project）" ;;
  esac

  # 若已传 --agents，立即校验
  [[ -z "$BS_AGENTS" ]] || bs_validate_agents "$BS_AGENTS"
}

# =============================================================================
# § 6.5  交互询问（仅对缺失参数，非交互环境直接报错）
# =============================================================================

# 检测是否为交互环境（stdin 为 tty）
bs_is_interactive() {
  [[ -t 0 ]]
}

# 询问目标工程文档目录（循环直到父目录存在）
bs_prompt_doc_target() {
  local input parent
  while true; do
    printf '请输入目标工程文档目录（如 ~/workspace/my-app/docs）：' >&2
    IFS= read -r input || error "读取输入失败"
    input="${input/#\~/$HOME}"
    parent="$(dirname "$input")"
    if [[ -d "$parent" ]]; then
      BS_DOC_TARGET="$input"
      return 0
    else
      log "父目录不存在：$parent，请重新输入。"
    fi
  done
}

# 询问要安装的 agent（展示编号列表，支持编号或名称输入）
bs_prompt_agents() {
  local -a agent_list=("${BS_AGENT_CHOICES[@]}")
  log ''
  log '请选择要安装的 Agent（输入编号，多选用 / 或 , 分隔，直接回车选 1）：'
  local i
  for (( i=0; i<${#agent_list[@]}; i++ )); do
    printf '  %d) %s\n' $(( i+1 )) "${agent_list[$i]}" >&2
  done
  printf '选择：' >&2

  local input
  IFS= read -r input || error "读取输入失败"
  [[ -z "$input" ]] && input='1'

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
        error "无效编号: ${part}（合法范围 1-${#agent_list[@]}）"
      fi
    else
      result_parts+=("$part")
    fi
  done

  local _ifs=$IFS
  IFS=','
  BS_AGENTS="${result_parts[*]}"
  IFS=$_ifs
  bs_validate_agents "$BS_AGENTS"
}

# 推导 agent-target
bs_resolve_agent_target() {
  case "$BS_AGENT_SCOPE" in
    home)
      [[ -n "${HOME:-}" ]] || error "需要 HOME 环境变量"
      BS_AGENT_TARGET="$HOME"
      ;;
    project)
      [[ -n "$BS_DOC_TARGET" ]] \
        || error "agent-scope=project 需要 --doc-target（用于 dirname 推导工程根）；或改用 --agent-scope=home"
      BS_AGENT_TARGET="$(dirname "$BS_DOC_TARGET")"
      ;;
  esac
}

# 展示汇总并请求确认
bs_confirm_plan() {
  local step=1
  log ''
  log '=========================================='
  log '即将执行以下操作：'
  if bs_want_docs; then
    log "  ${step}. docs-install  --target ${BS_DOC_TARGET}"
    step=$((step + 1))
  fi
  if bs_want_agent; then
    log "  ${step}. agent-install --agents=${BS_AGENTS} --target ${BS_AGENT_TARGET}"
  fi
  log "  components: ${BS_COMPONENTS}"
  log '=========================================='
  printf '确认执行？[Y/n]：' >&2
  local ans
  IFS= read -r ans || ans='y'
  case "$ans" in
    n|N) log '已取消。'; exit 0 ;;
  esac
}

# 收集所有缺失参数（交互或报错）
bs_collect_params() {
  # doc-target：docs 需要；或 agent + project 需要
  local need_doc_target=0
  if bs_want_docs; then
    need_doc_target=1
  elif bs_want_agent && [[ "$BS_AGENT_SCOPE" == 'project' ]]; then
    need_doc_target=1
  fi

  if (( need_doc_target == 1 )); then
    if [[ -z "$BS_DOC_TARGET" ]]; then
      if bs_is_interactive; then
        bs_prompt_doc_target
      else
        error "非交互环境：请通过 --doc-target PATH 指定目标工程文档目录（仍兼容 --doc-target=PATH）"
      fi
    else
      local parent
      BS_DOC_TARGET="${BS_DOC_TARGET/#\~/$HOME}"
      parent="$(dirname "$BS_DOC_TARGET")"
      [[ -d "$parent" ]] || error "父目录不存在：$parent"
    fi
  fi

  # agents
  if bs_want_agent; then
    if [[ -z "$BS_AGENTS" ]]; then
      if bs_is_interactive; then
        bs_prompt_agents
      else
        error "非交互环境：请通过 --agents=LIST 指定要安装的 Agent（$(IFS=' '; printf '%s' "${BS_AGENT_CHOICES[*]}")）"
      fi
    fi
    bs_resolve_agent_target
  fi

  # 汇总确认（仅交互环境）
  if bs_is_interactive; then
    bs_confirm_plan
  fi
}

# =============================================================================
# § 7  主流程
# =============================================================================

bs_run_docs_install() {
  local docs_install="${1:?docs_install}"
  log ''
  info '>>> 执行 docs-install.sh...'
  # 仅前缀传参，不 export（与 lib/docsconfig §禁止 export 一致）
  REPO_ROOT="$BS_CLONE_DIR" bash "$docs_install" --target "$BS_DOC_TARGET" \
    || error "docs-install 执行失败，已中止"
}

bs_run_agent_install() {
  local agent_install="${1:?agent_install}"
  log ''
  info '>>> 执行 agent-install.sh...'
  bash "$agent_install" --agents="$BS_AGENTS" --target "$BS_AGENT_TARGET" \
    || error "agent-install 执行失败"
}

bs_main() {
  require_bash5
  bs_check_deps

  bs_parse_args "$@"
  bs_collect_params

  local repo_url ref tmpdir
  repo_url="$(docsconfig_bootstrap_get_repo_url)"
  ref="$(docsconfig_bootstrap_get_ref)"
  tmpdir="$(docsconfig_bootstrap_get_tmpdir)"

  BS_CLONE_DIR="$(docsconfig_bootstrap_gen_clone_dir "$tmpdir")"
  trap bs_cleanup EXIT

  log ''
  log '=========================================='
  log 'bootstrap'
  info "仓库:        $repo_url"
  info "引用:        $ref"
  info "components:  $BS_COMPONENTS"
  if bs_want_docs; then
    info "文档目录:    $BS_DOC_TARGET"
  fi
  if bs_want_agent; then
    info "Agents:      $BS_AGENTS"
    info "Agent 安装:  $BS_AGENT_TARGET"
  fi
  log '=========================================='
  log ''

  bs_clone_repo "$repo_url" "$ref" "$BS_CLONE_DIR"

  local docs_install="${BS_CLONE_DIR}/agent/skills/docs-install/scripts/docs-install.sh"
  local agent_install="${BS_CLONE_DIR}/agent/skills/agent-install/scripts/agent-install.sh"
  local shared_config="${BS_CLONE_DIR}/agent/scripts/docs-core.sh"

  if bs_want_docs; then
    [[ -f "$docs_install" ]] || error "仓库中未找到 agent/skills/docs-install/scripts/docs-install.sh"
  fi
  if bs_want_agent; then
    [[ -f "$agent_install" ]] || error "仓库中未找到 agent/skills/agent-install/scripts/agent-install.sh"
  fi
  [[ -f "$shared_config" ]] || error "仓库中未找到 agent/scripts/docs-core.sh"

  # 克隆后统一加载 SSOT（若预载阶段已 source，此处因 _AGENT_SHARED_DOCS_CONFIG_LOADED 短路）
  # shellcheck disable=SC1090
  source "$shared_config"

  log ''
  info "已加载共享配置（agent/scripts/docs-core.sh）"

  if bs_want_docs; then
    bs_run_docs_install "$docs_install"
  fi
  if bs_want_agent; then
    bs_run_agent_install "$agent_install"
  fi

  log ''
  info '完成：bootstrap'
}

bs_main "$@"
