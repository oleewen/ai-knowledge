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

if [[ -n "${_SDX_AGENT_CONFIG_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _SDX_AGENT_CONFIG_SH_LOADED=1

readonly AGENT_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../agent/scripts/docs-core.sh
source "${AGENT_CONFIG_DIR}/../agent/scripts/docs-core.sh"

# =============================================================================
# § 1  版本与 Agent 常量
# =============================================================================

readonly SDX_VERSION='3.0.0'

# 安装目标：多 IDE 根（cursor / trae / claude）
readonly -a SDX_SUPPORTED_AGENTS=(cursor trae claude kiro)

declare -A SDX_AGENT_DIR_MAP=(
  [cursor]='.cursor'
  [trae]='.trae'
  [claude]='.claude'
  [kiro]='.kiro'
)

# --scope：a=全部；r=rules；s=skills；h=hooks；sh=scripts
readonly SDX_DEFAULT_AGENT_SCOPE='a'

# --agents：默认仅 cursor；可 all 或多选
readonly SDX_DEFAULT_AGENTS_OPT='cursor'

# =============================================================================
# § 2  Scope 校验与展开（安装子树开关）
# =============================================================================

# 根据 scope 设置四个 nameref 开关：install_rules install_skills install_hooks install_scripts
# 用法：agent_scope_apply <scope> <nameref_rules> <nameref_skills> <nameref_hooks> <nameref_scripts>
# 注意：本函数内 nameref 局部名不得与第 2～5 参「变量名」相同，否则 Bash 会报 circular name reference
#（例如调用方传 _ir 时，不可再声明 local -n _ir="$2"）。
agent_scope_apply() {
  local _raw="${1:?scope}"
  local -n _ref_rules="${2:?}" _ref_skills="${3:?}" _ref_hooks="${4:?}" _ref_scripts="${5:?}"
  _ref_rules=0 _ref_skills=0 _ref_hooks=0 _ref_scripts=0
  case "${_raw}" in
    a|A|all)
      _ref_rules=1 _ref_skills=1 _ref_hooks=1 _ref_scripts=1
      ;;
    r|R) _ref_rules=1 ;;
    s|S) _ref_skills=1 ;;
    h|H) _ref_hooks=1 ;;
    sh|SH) _ref_scripts=1 ;;
    *) return 1 ;;
  esac
  return 0
}

validate_agent_scope_token() {
  [[ -n "${1:-}" ]] || return 1
  local _ir _is _ih _ish
  agent_scope_apply "${1:-}" _ir _is _ih _ish
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

    [[ " ${SDX_SUPPORTED_AGENTS[*]} " == *" $agent "* ]] || return 1
  done
  return 0
}

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
