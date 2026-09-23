#!/usr/bin/env bash
#
# lib/agent-layout.sh — 本机 Agent 安装根探测、DOC_DIR/.agents 软链
# 依赖：lib/path.sh、lib/log-io.sh（info/warn/error 可选）
#

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=path.sh
source "${_LIB_DIR}/path.sh"

if [[ -n "${_LIB_AGENT_LAYOUT_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_AGENT_LAYOUT_LOADED=1

# 探测顺序：.agents 优先，再 IDE 根（.cursor → .codex → .claude → .trae → .kiro）
AGENT_PROBE_DIR_NAMES=(.agents .cursor .codex .claude .trae .kiro)

_agent_layout_msg() {
  if declare -F info >/dev/null 2>&1; then
    info "$@"
  else
    printf '%s\n' "$*"
  fi
}

_agent_layout_warn() {
  if declare -F warn >/dev/null 2>&1; then
    warn "$@"
  else
    printf '警告: %s\n' "$*" >&2
  fi
}

_agent_layout_error_msg() {
  printf '%s\n' "$*" >&2
}

# 目录是否像已装 Agent 树（含 docs-core 入口）
agent_layout_is_install_root() {
  local root="${1:-}"
  [[ -n "$root" && -d "$root" && -f "${root}/scripts/docs-core.sh" ]]
}

# 探测本机安装根。成功：nameref 写出 agent_root_abs、agent_dir_name（如 .agents）
# 失败：1，并打印提醒先 /agent-install
# 用法：probe_agent_install_root <nameref_root> <nameref_dir> [home]
probe_agent_install_root() {
  local -n _probe_root="${1:?}"
  local -n _probe_dir="${2:?}"
  local home="${3:-${HOME:-}}"
  local name cand
  _probe_root=''
  _probe_dir=''
  [[ -n "$home" ]] || {
    _agent_layout_error_msg "错误: 无法探测 Agent 安装根：HOME 未就绪。请先执行 /agent-install。"
    return 1
  }
  home="$(strip_trailing_slash "$(abs_path "$home")")"
  for name in "${AGENT_PROBE_DIR_NAMES[@]}"; do
    cand="${home}/${name}"
    if agent_layout_is_install_root "$cand"; then
      _probe_root="$home"
      _probe_dir="$name"
      return 0
    fi
  done
  _agent_layout_error_msg "错误: 未在 ${home} 下找到 Agent 安装树（已试: ${AGENT_PROBE_DIR_NAMES[*]}）。请先执行 /agent-install（默认安装到 ~/.agents）。"
  return 1
}

# AGENT_ROOT 是否误写成实体树根（应改为家目录 + AGENT_DIR）
docsconfig_agent_root_looks_like_entity_tree() {
  local ar="${1:-}" base
  [[ -n "$ar" ]] || return 1
  ar="$(strip_trailing_slash "$(abs_path "$ar")")"
  base="$(basename "$ar")"
  case "$base" in
    .agents|.cursor|.codex|.claude|.trae|.kiro) return 0 ;;
  esac
  agent_layout_is_install_root "$ar" && return 0
  return 1
}

# 确保 DOC_DIR/.agents → abs(AGENT_ROOT/AGENT_DIR)。dry=1 只预览。
# 已是正确软链：幂等；错误软链：ln -sfn；实目录/普通文件：失败。
# 用法：ensure_docs_agents_symlink <docs_abs> <agent_root> <agent_dir> [dry]
ensure_docs_agents_symlink() {
  local docs_abs="${1:?}"
  local agent_root="${2:?}"
  local agent_dir="${3:?}"
  local dry="${4:-0}"
  local link target cur

  [[ -d "$docs_abs" ]] || {
    _agent_layout_error_msg "错误: 文档目录不存在，无法建 .agents 软链: $docs_abs"
    return 1
  }
  agent_root="$(strip_trailing_slash "$(abs_path "$agent_root")")"
  agent_dir="${agent_dir#/}"
  target="$(strip_trailing_slash "$(abs_path "${agent_root}/${agent_dir}")")"
  link="${docs_abs%/}/.agents"

  if [[ ! -d "$target" ]]; then
    _agent_layout_error_msg "错误: 软链目标不存在: $target（请先 /agent-install）"
    return 1
  fi

  if [[ -L "$link" ]]; then
    cur="$(abs_path "$link" 2>/dev/null || readlink "$link" || true)"
    cur="$(strip_trailing_slash "${cur:-}")"
    if [[ "$cur" == "$target" ]]; then
      _agent_layout_msg "  .agents 软链已正确: $link → $target"
      return 0
    fi
    if [[ "$dry" == '1' ]]; then
      _agent_layout_msg "[dry-run] 将校正软链: $link → $target（当前 → $cur）"
      return 0
    fi
    ln -sfn "$target" "$link"
    _agent_layout_msg "已校正 .agents 软链: $link → $target"
    return 0
  fi

  if [[ -e "$link" ]]; then
    _agent_layout_error_msg "错误: ${link} 已存在且不是软链（实目录或文件）。请手动处理后再跑。"
    return 1
  fi

  if [[ "$dry" == '1' ]]; then
    _agent_layout_msg "[dry-run] 将创建软链: $link → $target"
    return 0
  fi
  ln -s "$target" "$link"
  _agent_layout_msg "已创建 .agents 软链: $link → $target"
}
