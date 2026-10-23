#!/usr/bin/env bash
#
# lib/agents.sh — Agent 枚举规范化与校验
# 依赖：同目录 bash.sh（版本守卫）
#

if [[ -n "${_LIB_AGENTS_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_AGENTS_LOADED=1

# shellcheck source=bash.sh
source "${BASH_SOURCE[0]%/*}/bash.sh"

# 与 agent-layout 探测 IDE 段顺序一致（.agents 另列）
SUPPORTED_AGENTS=(cursor codex claude trae kiro)

agents_normalize() {
  local agents_str="${1:-}"
  case "$agents_str" in
    a|all)
      printf '%s' "${SUPPORTED_AGENTS[*]}"
      return 0
      ;;
  esac
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

agents_validate() {
  local agents_str="${1:-}"
  local -a agents
  IFS=', ' read -ra agents <<< "$agents_str"
  local agent
  for agent in "${agents[@]}"; do
    [[ -z "$agent" ]] && continue
    case "$agent" in
      a|all) return 0 ;;
    esac
    [[ " ${SUPPORTED_AGENTS[*]} " == *" $agent "* ]] || return 1
  done
  return 0
}
