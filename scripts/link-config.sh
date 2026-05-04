#!/usr/bin/env bash
#
# link-config.sh — 仅供 docs-link.sh source
#
# 职责：
# - 承载 docs-link 的默认值、参数校验、路径函数、.docsconfig 读入工具
# - 路径与 .docsconfig 工具统一复用 agent/scripts/docs-core.sh
# - 解析顺序：仓库内 ../agent/scripts/docs-core.sh（中央库布局）→ .docsconfig 之
#   AGENT_ROOT/scripts/docs-core.sh → AGENT_DIRS 中各根下 scripts/docs-core.sh（按声明顺序）
#

readonly LINK_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 以下两段在 source docs-core 之前使用，语义与 agent/scripts/docs-core.sh 对齐（bootstrap）
_link_config_expand_tilde() {
  local p="${1:-}"
  if [[ "$p" == '~' ]]; then
    printf '%s\n' "${HOME:-}"
  elif [[ "$p" =~ ^~/ ]]; then
    printf '%s\n' "${HOME:-}/${p:2}"
  else
    printf '%s\n' "$p"
  fi
}

_link_config_abs_path() {
  local p
  p="$(_link_config_expand_tilde "${1:-}")"
  [[ -n "$p" ]] || return 1
  [[ "$p" == /* ]] || p="$PWD/$p"

  if [[ -d "$p" ]]; then
    (cd -P "$p" 2>/dev/null && pwd)
  else
    local dir base
    dir="$(dirname "$p")"
    base="$(basename "$p")"
    dir="$(cd -P "$dir" 2>/dev/null && pwd || printf '%s' "$dir")"
    printf '%s/%s\n' "$dir" "$base"
  fi
}

# 解析并 source docs-core.sh（中央库或已安装至目标工程 scripts/ 时）
link_config_source_docs_core() {
  local core="${LINK_CONFIG_DIR}/../agent/scripts/docs-core.sh"
  if [[ -f "$core" ]]; then
    # shellcheck source=../agent/scripts/docs-core.sh
    source "$core"
    return 0
  fi

  local repo_root cfg raw_ar raw_ads line v
  repo_root="$(cd "$(dirname "${LINK_CONFIG_DIR}")" && pwd)"
  cfg="${repo_root}/.docsconfig"
  if [[ ! -f "$cfg" ]]; then
    printf '错误: 未找到 %s，且目标工程根无 .docsconfig（%s）。请使用中央库 clone 执行 docs-link，或在目标工程先 docs-install --scope=config 并安装 agent 脚本（含 docs-core.sh）。\n' \
      "$core" "$cfg" >&2
    return 1
  fi

  raw_ar=''
  raw_ads=''
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    case "$line" in
      AGENT_ROOT=*)
        raw_ar="${line#*=}"
        raw_ar="${raw_ar%$'\r'}"
        ;;
      AGENT_DIRS=*)
        v="${line#*=}"
        v="${v%$'\r'}"
        if [[ ${#v} -ge 2 && "${v:0:1}" == '"' && "${v: -1}" == '"' ]]; then
          v="${v:1:${#v}-2}"
        fi
        raw_ads="$v"
        ;;
    esac
  done <"$cfg"

  local ar_base=''
  if [[ -n "$raw_ar" ]]; then
    ar_base="$(_link_config_abs_path "$raw_ar")"
    core="${ar_base}/scripts/docs-core.sh"
    if [[ -f "$core" ]]; then
      # shellcheck source=/dev/null
      source "$core"
      return 0
    fi
  fi

  local d
  for d in $raw_ads; do
    [[ -z "$d" ]] && continue
    local d_base="$d"
    if [[ -n "$ar_base" && "$d_base" != /* && "$d_base" != "~"* ]]; then
      d_base="${ar_base}/${d_base}"
    fi
    core="$(_link_config_abs_path "$d_base")/scripts/docs-core.sh"
    if [[ -f "$core" ]]; then
      # shellcheck source=/dev/null
      source "$core"
      return 0
    fi
  done

  printf '错误: .docsconfig 已存在（%s），但 AGENT_ROOT/AGENT_DIRS 下均未找到 scripts/docs-core.sh。请执行 agent-install.sh --scope=sh 或等价安装。\n' "$cfg" >&2
  return 1
}

link_config_source_docs_core || exit 1
unset -f link_config_source_docs_core _link_config_abs_path _link_config_expand_tilde

# =============================================================================
# § 1  常量与校验（SDX_SUPPORTED_KNOWLEDGE_TYPES 见已 source 的 docs-core.sh）
# =============================================================================

readonly KLINK_DEFAULT_DRY_RUN='0'

validate_link_command() {
  [[ "${1:-}" =~ ^(link|unlink)$ ]]
}

normalize_target_repo_root() {
  local raw="${1:-}"
  [[ -n "$raw" ]] || return 1
  local p
  p="$(abs_path "$raw")"
  p="$(strip_trailing_slash "$p")"
  printf '%s\n' "$p"
}

