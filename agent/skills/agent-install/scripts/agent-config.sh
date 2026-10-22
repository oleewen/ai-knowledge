#!/usr/bin/env bash
# agent-config.sh — agent-install / bootstrap 共用默认值、枚举与共享库入口。
# 依赖 Bash 5+；source agent/scripts/docs-core.sh

if [[ -n "${_AGENT_CONFIG_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly _AGENT_CONFIG_SH_LOADED=1

readonly AGENT_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../scripts/lib/bash.sh
source "${AGENT_CONFIG_DIR}/../../../scripts/lib/bash.sh"
# shellcheck source=../../../scripts/docs-core.sh
source "${AGENT_CONFIG_DIR}/../../../scripts/docs-core.sh"

readonly VERSION='3.0.0'

declare -A AGENT_DIR_MAP=(
  [cursor]='.cursor'
  [trae]='.trae'
  [claude]='.claude'
  [kiro]='.kiro'
  [codex]='.codex'
)

readonly DEFAULT_AGENT_SCOPE='a'
readonly DEFAULT_AGENTS_OPT='a'

# scope=a：hooks + rules + scripts + skills + knowledge + references
# scope=k|knowledge：仅 knowledge/ + references/
agent_scope_apply() {
  local _raw="${1:?scope}"
  local -n _ref_rules="${2:?}" _ref_skills="${3:?}" _ref_hooks="${4:?}" _ref_scripts="${5:?}" _ref_knowledge="${6:?}"
  _ref_rules=0 _ref_skills=0 _ref_hooks=0 _ref_scripts=0 _ref_knowledge=0
  case "${_raw}" in
    a|A|all)
      _ref_rules=1 _ref_skills=1 _ref_hooks=1 _ref_scripts=1 _ref_knowledge=1
      ;;
    k|K|knowledge)
      _ref_knowledge=1
      ;;
    r|R) _ref_rules=1 ;;
    s|S) _ref_skills=1 ;;
    h|H) _ref_hooks=1 ;;
    sh|SH) _ref_scripts=1 ;;
    *) return 1 ;;
  esac
}

validate_agent_scope_token() {
  [[ -n "${1:-}" ]] || return 1
  local _ir _is _ih _ish _ik
  agent_scope_apply "${1:-}" _ir _is _ih _ish _ik
}

validate_agents() {
  local raw="${1:-}" agent
  local -a agents=()
  [[ "$raw" != *$'\n'* && "$raw" != *$'\r'* ]] || return 1
  IFS=', ' read -ra agents <<< "$raw"
  (( ${#agents[@]} > 0 )) || return 1
  if (( ${#agents[@]} == 1 )) && [[ "${agents[0]}" == a || "${agents[0]}" == all ]]; then
    return 0
  fi
  for agent in "${agents[@]}"; do
    [[ -n "$agent" && -n "${AGENT_DIR_MAP[$agent]:-}" ]] || return 1
  done
}

normalize_agents() {
  local -a agents=()
  IFS=', ' read -ra agents <<< "${1:-}"
  if (( ${#agents[@]} == 1 )) && [[ "${agents[0]}" == a || "${agents[0]}" == all ]]; then
    agents_normalize all
  else
    agents_normalize "${1:-}"
  fi
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
  local agent="${1:-}"
  [[ -n "$agent" && -n "${AGENT_DIR_MAP[$agent]:-}" ]] || return 1
  printf '%s' "${AGENT_DIR_MAP[$agent]}"
}
