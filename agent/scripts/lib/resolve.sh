#!/usr/bin/env bash
#
# lib/resolve.sh — 上溯查找与 docs-core 布局 source
# 依赖：lib/path.sh、lib/log-io.sh、lib/docsconfig.sh、lib/agents.sh、lib/agent-layout.sh
#

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=docsconfig.sh
source "${_LIB_DIR}/docsconfig.sh"
# shellcheck source=agents.sh
source "${_LIB_DIR}/agents.sh"
# shellcheck source=agent-layout.sh
source "${_LIB_DIR}/agent-layout.sh"

if [[ -n "${_LIB_RESOLVE_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_RESOLVE_LOADED=1

# 打印本机 Agent 安装树下 docs-core.sh 候选路径（与 AGENT_PROBE_DIR_NAMES 同序）
_docs_core_iter_home_script_paths() {
  local home="${1:-${HOME:-}}" name
  [[ -n "$home" ]] || return 1
  for name in "${AGENT_PROBE_DIR_NAMES[@]}"; do
    printf '%s\n' "${home}/${name}/scripts/docs-core.sh"
  done
}

# 返回首个存在文件的 abs_path；无则 1
_docs_core_first_existing_file() {
  local p
  for p in "$@"; do
    [[ -f "$p" ]] || continue
    abs_path "$p"
    return 0
  done
  return 1
}

_docs_core_first_home_script() {
  local home="${1:-${HOME:-}}" dc
  [[ -n "$home" ]] || return 1
  while IFS= read -r dc; do
    [[ -f "$dc" ]] || continue
    abs_path "$dc"
    return 0
  done < <(_docs_core_iter_home_script_paths "$home")
  return 1
}

# 自 start 目录向上找首个含 relative_path 文件的目录，打印该目录绝对路径
find_upward_with_file() {
  local relative_path="${1:?}" start d
  shift
  [[ $# -gt 0 ]] || set -- "${PWD}"
  local s
  for s in "$@"; do
    d="$(cd -P "$s" 2>/dev/null && pwd -P)" || continue
    while [[ -n "$d" && "$d" != "/" ]]; do
      [[ -f "$d/$relative_path" ]] && {
        printf '%s\n' "$d"
        return 0
      }
      d="$(dirname "$d")"
    done
  done
  return 1
}

# 解析 docs-core.sh 绝对路径（不 source）；顺序见 agent/skills/docs-push/references/parameters.md
resolve_docs_core_path() {
  local hint="${1:-${PWD}}" d found

  if [[ -n "${DOCS_CORE_SH:-}" ]]; then
    [[ -f "$DOCS_CORE_SH" ]] || return 1
    abs_path "$DOCS_CORE_SH"
    return 0
  fi

  if found="$(_docs_core_first_existing_file \
    "${hint}/../agent/scripts/docs-core.sh" \
    "${hint}/agent/scripts/docs-core.sh" \
    "${hint}/../../../scripts/docs-core.sh")"; then
    printf '%s\n' "$found"
    return 0
  fi

  if found="$(_docs_core_first_home_script)"; then
    printf '%s\n' "$found"
    return 0
  fi

  for d in \
    "$(cd -P "$hint" 2>/dev/null && pwd -P || printf '%s' "$hint")" \
    "$(pwd -P 2>/dev/null || pwd)"; do
    d="$(find_upward_with_file "agent/scripts/docs-core.sh" "$d" 2>/dev/null)" || continue
    abs_path "$d/agent/scripts/docs-core.sh"
    return 0
  done

  if [[ -n "${AIK_ROOT:-}" && -f "${AIK_ROOT}/agent/scripts/docs-core.sh" ]]; then
    abs_path "${AIK_ROOT}/agent/scripts/docs-core.sh"
    return 0
  fi
  return 1
}

# 同源（含符号链接同一 inode）则跳过；否则 unset 哨兵后 source。
_docs_core_source_if_needed() {
  local target="${1:?}"
  local already="${2:-}"
  [[ -f "$target" ]] || return 1
  if [[ -n "$already" && -e "$already" && "$target" -ef "$already" ]]; then
    return 0
  fi
  unset _AGENT_SHARED_DOCS_CONFIG_LOADED
  # shellcheck source=/dev/null
  source "$target"
}

source_docs_core_from_layout() {
  local link_config_dir="${1:?}"
  local core bootstrap_used=''

  for core in \
    "${link_config_dir}/../../../scripts/docs-core.sh" \
    "${link_config_dir}/../agent/scripts/docs-core.sh"; do
    if [[ -f "$core" ]]; then
      # shellcheck source=/dev/null
      source "$core"
      break
    fi
  done

  bootstrap_used=''
  if declare -f resolve_docs_core_path >/dev/null 2>&1; then
    bootstrap_used="$(resolve_docs_core_path "$link_config_dir" 2>/dev/null || true)"
  else
    bootstrap_used="$(_docs_core_first_home_script 2>/dev/null || true)"
  fi
  if [[ -n "$bootstrap_used" && -f "$bootstrap_used" ]]; then
    if ! declare -f abs_path >/dev/null 2>&1; then
      _docs_core_source_if_needed "$bootstrap_used"
    fi
  elif ! declare -f abs_path >/dev/null 2>&1; then
    printf '错误: 未找到中央库 %s，且未安装 Agent scripts（~/.agents/scripts/docs-core.sh）。\n' \
      "${link_config_dir}/../agent/scripts/docs-core.sh" >&2
    return 1
  fi

  local repo_root cfg
  cfg=''
  if declare -f docsconfig_find_path >/dev/null 2>&1; then
    cfg="$(docsconfig_find_path 2>/dev/null || true)"
  fi
  if [[ -n "$cfg" && -f "$cfg" ]]; then
    repo_root="$(dirname "$cfg")"
  else
    repo_root="$(cd "$(dirname "${link_config_dir}")" && pwd)"
    cfg="${repo_root}/.docsconfig"
  fi
  if [[ ! -f "$cfg" ]]; then
    printf '错误: 未找到 docs-core 布局，且当前工程无 .docsconfig（%s）。请在源 Git 仓库根执行 docs-link，或先 docs-install --scope=config 并安装 agent 脚本（含 docs-core.sh）。\n' \
      "$cfg" >&2
    return 1
  fi

  local _layout_ar='' _layout_kt='' _layout_ad='' _cfg_dr='' _cfg_rr='' _cfg_dd=''
  if declare -f docsconfig_read_into >/dev/null 2>&1; then
    docsconfig_read_into "$cfg" _cfg_dr _cfg_rr _cfg_dd _layout_ar _layout_kt _layout_ad || return 1
  else
    printf '错误: docsconfig_read_into 不可用，无法解析 %s\n' "$cfg" >&2
    return 1
  fi

  if [[ -z "$_layout_ar" ]]; then
    printf '错误: .docsconfig（%s）缺少 AGENT_ROOT。请执行 docs-install --scope=config 或补充配置。\n' "$cfg" >&2
    return 1
  fi
  if [[ -z "$_layout_ad" ]]; then
    printf '错误: .docsconfig（%s）缺少 AGENT_DIR。请补充 AGENT_DIR=.agents（或探测到的目录名，如 .cursor）。\n' "$cfg" >&2
    return 1
  fi
  if docsconfig_agent_root_looks_like_entity_tree "$_layout_ar"; then
    printf '错误: .docsconfig（%s）的 AGENT_ROOT 指向实体树。请改为家目录（如 ~）并设置 AGENT_DIR。\n' "$cfg" >&2
    return 1
  fi

  local ar_base resolved_core
  ar_base="$(abs_path "$_layout_ar")"
  resolved_core="${ar_base}/${_layout_ad}/scripts/docs-core.sh"
  if [[ -f "$resolved_core" ]]; then
    _docs_core_source_if_needed "$resolved_core" "$bootstrap_used"
    return 0
  fi

  printf '错误: .docsconfig（%s）中 AGENT_ROOT=%s AGENT_DIR=%s 下未找到 scripts/docs-core.sh（%s）。请先执行 /agent-install，或修正配置。\n' \
    "$cfg" "$_layout_ar" "$_layout_ad" "$resolved_core" >&2
  return 1
}
