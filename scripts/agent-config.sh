#!/usr/bin/env bash
#
# agent-config.sh — 仅供 agent-install.sh source：Agent 安装 CLI 的默认值、校验与 .docsconfig 工具
#
# 职责：参数默认值、合法性校验、路径与 .docsconfig 读写（与 agent/scripts/docs-core.sh 语义对齐）。
# 不 source lib/*.sh；不承载 docs-install 专用常量。
#
# 依赖：Bash 5+（关联数组、nameref）
#
# 使用方式：
#   source "$(dirname "$0")/agent-config.sh"
#

readonly AGENT_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../agent/scripts/docs-core.sh
source "${AGENT_CONFIG_DIR}/../agent/scripts/docs-core.sh"

# =============================================================================
# § 1  版本与 Agent 常量
# =============================================================================

readonly SDX_VERSION='3.0.0'

# 安装目标：多 IDE 根（cursor / trea / claude）
readonly -a SDX_SUPPORTED_AGENTS=(cursor trea claude)

declare -A SDX_AGENT_DIR_MAP=(
  [cursor]='.cursor'
  [trea]='.trea'
  [claude]='.claude'
)

# --scope：a=全部；r=rules；s=skills；h=hooks；sh=scripts
readonly SDX_DEFAULT_AGENT_SCOPE='a'

# --agents：默认仅 cursor；可 all 或多选
readonly SDX_DEFAULT_AGENTS_OPT='cursor'

# =============================================================================
# § 2  Scope 校验与展开（安装子树开关）
# =============================================================================

# 校验 scope 单 token
# 返回：0=合法
validate_agent_scope_token() {
  [[ "${1:-}" =~ ^(a|A|all|r|R|s|S|h|H|sh|SH)$ ]]
}

# 根据 scope 设置四个 nameref 开关：install_rules install_skills install_hooks install_scripts
# 用法：agent_scope_apply <scope> <nameref_rules> <nameref_skills> <nameref_hooks> <nameref_scripts>
agent_scope_apply() {
  local _raw="${1:?scope}"
  local -n _ir="${2:?}" _is="${3:?}" _ih="${4:?}" _ish="${5:?}"
  _ir=0 _is=0 _ih=0 _ish=0
  case "${_raw}" in
    a|A|all)
      _ir=1 _is=1 _ih=1 _ish=1
      ;;
    r|R) _ir=1 ;;
    s|S) _is=1 ;;
    h|H) _ih=1 ;;
    sh|SH) _ish=1 ;;
    *) return 1 ;;
  esac
  return 0
}

# 校验 --agents 列表（逗号或空格分隔；支持 all）
validate_agents() {
  local agents_str="${1:-}"
  local -a agents
  IFS=', ' read -ra agents <<< "$agents_str"

  local agent supported
  for agent in "${agents[@]}"; do
    [[ -z "$agent" ]] && continue
    [[ "$agent" == 'all' ]] && return 0

    local valid=0
    for supported in "${SDX_SUPPORTED_AGENTS[@]}"; do
      [[ "$agent" == "$supported" ]] && { valid=1; break; }
    done
    (( valid == 0 )) && return 1
  done
  return 0
}

# 规范化 --agents（展开 all、去重）；输出空格分隔的 agent 名
normalize_agents() {
  local agents_str="${1:-}"

  if [[ "$agents_str" == 'all' ]]; then
    printf '%s' "${SDX_SUPPORTED_AGENTS[*]}"
    return 0
  fi

  local -a agents normalized
  local -A seen
  IFS=', ' read -ra agents <<< "$agents_str"

  local agent
  for agent in "${agents[@]}"; do
    [[ -z "$agent" ]] && continue
    [[ -n "${seen[$agent]+x}" ]] && continue
    seen["$agent"]=1
    normalized+=("$agent")
  done

  printf '%s' "${normalized[*]}"
}

# 根据已选 agent 名输出 AGENT_DIRS（空格分隔目录名，供 .docsconfig）
agent_dirs_space_separated_for() {
  local ag d out=''
  for ag in "$@"; do
    d="$(get_agent_dir "$ag")"
    out="${out:+$out }$d"
  done
  printf '%s' "$out"
}

get_agent_dir() {
  printf '%s' "${SDX_AGENT_DIR_MAP[${1:-}]:-agent}"
}
