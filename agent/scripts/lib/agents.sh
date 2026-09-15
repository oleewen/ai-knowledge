#!/usr/bin/env bash
#
# lib/agents.sh — Agent 枚举规范化与校验
# 依赖：无硬依赖（仅用数组常量）
#

if [[ -n "${_LIB_AGENTS_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_AGENTS_LOADED=1

SUPPORTED_AGENTS=(cursor trae claude kiro codex)

agents_normalize() {
  local agents_str="${1:-}"
  if [[ "$agents_str" == 'all' ]]; then
    printf '%s' "${SUPPORTED_AGENTS[*]}"
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

agents_validate() {
  local agents_str="${1:-}"
  local -a agents
  IFS=', ' read -ra agents <<< "$agents_str"
  local agent
  for agent in "${agents[@]}"; do
    [[ -z "$agent" ]] && continue
    [[ "$agent" == 'all' ]] && return 0
    [[ " ${SUPPORTED_AGENTS[*]} " == *" $agent "* ]] || return 1
  done
  return 0
}
