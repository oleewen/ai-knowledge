#!/usr/bin/env bash
#
# docs-core.sh — 共享路径与 .docsconfig 工具（供 scripts/*-config.sh source）
#

if [[ -n "${_AGENT_SHARED_DOCS_CONFIG_LOADED:-}" ]]; then
  return 0
fi
readonly _AGENT_SHARED_DOCS_CONFIG_LOADED=1

readonly SDX_MIN_BASH_VERSION=5

require_bash5() {
  if (( BASH_VERSINFO[0] < SDX_MIN_BASH_VERSION )); then
    printf '[FATAL] 需要 Bash %s+，当前版本: %s\n' "$SDX_MIN_BASH_VERSION" "$BASH_VERSION" >&2
    exit 1
  fi
}
require_bash5

# =============================================================================
# § 中央库 Git 与 docs-bootstrap（curl | bash）克隆参数
# 环境变量 GIT_REPO_URL / GIT_REF 可覆盖；由 sdx_docs_bootstrap_get_* 读取。
# =============================================================================
readonly SDX_GIT_REPO_URL='https://github.com/oleewen/ai-knowledge.git'
readonly SDX_GIT_DEFAULT_REF='HEAD'

sdx_docs_bootstrap_get_repo_url() {
  printf '%s' "${GIT_REPO_URL:-$SDX_GIT_REPO_URL}"
}

sdx_docs_bootstrap_get_ref() {
  printf '%s' "${GIT_REF:-$SDX_GIT_DEFAULT_REF}"
}

sdx_docs_bootstrap_get_tmpdir() {
  local tmpdir="${TMPDIR:-/tmp}"
  [[ -d "$tmpdir" ]] || tmpdir='/tmp'
  printf '%s' "$tmpdir"
}

sdx_docs_bootstrap_gen_clone_dir() {
  printf '%s/ai-knowledge-%s' "${1:?tmpdir}" "$$"
}

expand_tilde() {
  local p="${1:-}"
  if [[ "$p" == '~' ]]; then
    printf '%s\n' "${HOME:-}"
  elif [[ "$p" =~ ^~/ ]]; then
    printf '%s\n' "${HOME:-}/${p:2}"
  else
    printf '%s\n' "$p"
  fi
}

abs_path() {
  local p
  p="$(expand_tilde "${1:-}")"
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

strip_trailing_slash() {
  local p="${1:-}"
  while [[ "$p" != '/' && "$p" == */ ]]; do
    p="${p%/}"
  done
  printf '%s\n' "$p"
}

docsconfig_format_root_for_write() {
  local p home
  p="$(strip_trailing_slash "$(abs_path "${1:?}")")"
  [[ -n "${HOME:-}" ]] || { printf '%s\n' "$p"; return 0; }
  home="$(strip_trailing_slash "$(abs_path "$HOME")")"
  [[ -n "$home" ]] || { printf '%s\n' "$p"; return 0; }

  if [[ "$p" == "$home" ]]; then
    printf '~\n'
  elif [[ "$p" == "$home"/* ]]; then
    printf '~/%s\n' "${p#"$home"/}"
  else
    printf '%s\n' "$p"
  fi
}

docsconfig_normalize_root_value() {
  local v="${1:-}"
  v="${v%$'\r'}"
  printf '%s' "$(abs_path "$v")"
}

docsconfig_repo_root_from_doc_root() {
  local doc_root="${1:?doc_root}"
  local dr gr
  dr="$(cd -P "$doc_root" 2>/dev/null && pwd)" || return 0
  gr="$(git -C "$dr" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$gr" ]] || return 0
  if [[ "$(dirname "$dr")" == "$gr" ]]; then
    printf '%s\n' "$gr"
  fi
  return 0
}

docsconfig_repo_root_fallback_from_doc_root() {
  local doc_root="${1:?doc_root}"
  cd -P "$(dirname "$doc_root")" 2>/dev/null && pwd || true
}

docsconfig_doc_dir_from_roots() {
  local repo_root="${1:?repo_root}" doc_root="${2:?doc_root}"
  local rr dr
  rr="$(cd -P "$repo_root" 2>/dev/null && pwd)" || {
    printf '[docsconfig] 无法解析 REPO_ROOT: %s\n' "$repo_root" >&2
    return 1
  }
  dr="$(cd -P "$doc_root" 2>/dev/null && pwd)" || {
    printf '[docsconfig] 无法解析 DOC_ROOT: %s\n' "$doc_root" >&2
    return 1
  }
  case "$dr" in
    "$rr") printf '.\n' ;;
    "$rr"/*) printf '%s\n' "${dr#"$rr"/}" ;;
    *)
      printf '[docsconfig] DOC_ROOT 不在 REPO_ROOT 下: %s vs %s\n' "$dr" "$rr" >&2
      return 1
      ;;
  esac
}

# 静默：是否为合法 KNOWLEDGE_TYPE（与 validate_type / docsconfig_write 一致）
docsconfig_knowledge_type_is_valid() {
  local v="${1:-}"
  [[ "$v" == 'application' || "$v" == 'system' || "$v" == 'company' ]]
}

docsconfig_validate_knowledge_type() {
  local v="${1:-}"
  if docsconfig_knowledge_type_is_valid "$v"; then
    return 0
  fi
  printf '[docsconfig] 非法 KNOWLEDGE_TYPE: %s（允许: application system company）\n' "$v" >&2
  return 1
}

# 与 docsconfig_knowledge_type_is_valid 允许集合一致（供 *-config 枚举/文档对齐）
readonly -a SDX_SUPPORTED_KNOWLEDGE_TYPES=(application system company)

docsconfig_write() {
  local repo_root="${1:?repo_root}"
  local doc_root="${2:?doc_root}"
  local doc_dir="${3:?doc_dir}"
  local dry="${4:-0}"
  local agent_root_in="${5:-}"
  local agent_dirs_in="${6:-}"
  local knowledge_type_in="${7:-}"

  if [[ -n "$agent_root_in" && -z "$agent_dirs_in" && -z "$knowledge_type_in" ]]; then
    case "$agent_root_in" in
      application|system|company)
        knowledge_type_in="$agent_root_in"
        agent_root_in=''
        ;;
    esac
  fi

  local out rr dr ar
  out="$(strip_trailing_slash "$(abs_path "$repo_root")")/.docsconfig"
  rr="$(docsconfig_format_root_for_write "$repo_root")"
  dr="$(docsconfig_format_root_for_write "$doc_root")"

  if [[ -n "$knowledge_type_in" ]]; then
    docsconfig_validate_knowledge_type "$knowledge_type_in" || return 1
  fi

  if [[ "$dry" == '1' ]]; then
    printf 'Would write %s:\nDOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$out" "$dr" "$rr" "$doc_dir"
    [[ -n "$knowledge_type_in" ]] && printf 'KNOWLEDGE_TYPE=%s\n' "$knowledge_type_in"
    if [[ -n "$agent_root_in" ]]; then
      ar="$(docsconfig_format_root_for_write "$agent_root_in")"
      printf 'AGENT_ROOT=%s\nAGENT_DIRS="%s"\n' "$ar" "$agent_dirs_in"
    fi
    return 0
  fi

  umask 022
  {
    printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$dr" "$rr" "$doc_dir"
    [[ -n "$knowledge_type_in" ]] && printf 'KNOWLEDGE_TYPE=%s\n' "$knowledge_type_in"
    if [[ -n "$agent_root_in" ]]; then
      ar="$(docsconfig_format_root_for_write "$agent_root_in")"
      printf 'AGENT_ROOT=%s\nAGENT_DIRS="%s"\n' "$ar" "$agent_dirs_in"
    fi
  } >"$out"
}

docsconfig_read_into() {
  local path="${1:?path}"
  local -n _doc="${2:?}"
  local -n _repo="${3:?}"
  local -n _ddir="${4:?}"
  _doc=''; _repo=''; _ddir=''
  [[ -f "$path" ]] || return 1

  local raw_doc='' raw_repo='' raw_ddir='' raw_ar='' raw_ads='' raw_kt=''
  local line k v
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    case "$line" in
      DOC_ROOT=*|REPO_ROOT=*|DOC_DIR=*|AGENT_ROOT=*|AGENT_DIRS=*|KNOWLEDGE_TYPE=*)
        k="${line%%=*}"
        v="${line#*=}"
        v="${v%$'\r'}"
        if [[ "$k" == 'AGENT_DIRS' && ${#v} -ge 2 && "${v:0:1}" == '"' && "${v: -1}" == '"' ]]; then
          v="${v:1:${#v}-2}"
        fi
        case "$k" in
          DOC_ROOT) raw_doc="$v" ;;
          REPO_ROOT) raw_repo="$v" ;;
          DOC_DIR) raw_ddir="$v" ;;
          AGENT_ROOT) raw_ar="$v" ;;
          AGENT_DIRS) raw_ads="$v" ;;
          KNOWLEDGE_TYPE) raw_kt="$v" ;;
        esac
        ;;
    esac
  done <"$path"

  [[ -n "$raw_doc" ]] && _doc="$(docsconfig_normalize_root_value "$raw_doc")"
  [[ -n "$raw_repo" ]] && _repo="$(docsconfig_normalize_root_value "$raw_repo")"
  _ddir="$raw_ddir"

  if (( $# >= 6 )); then
    local -n _aroot="${5:?}"
    local -n _adirs="${6:?}"
    _aroot=''
    [[ -n "$raw_ar" ]] && _aroot="$(docsconfig_normalize_root_value "$raw_ar")"
    _adirs="$raw_ads"
  fi
  if (( $# >= 7 )); then
    local -n _ktype="${7:?}"
    _ktype="$raw_kt"
  elif (( $# == 5 )); then
    local -n _ktype_legacy="${5:?}"
    _ktype_legacy="$raw_kt"
  fi
  return 0
}

# =============================================================================
# § 文本文件与 agent/ 路径段重写（docs-install / agent-install 共用）
# =============================================================================

sdx_have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

sdx_is_text_file() {
  local f="$1"
  case "$f" in
    *.md|*.yaml|*.yml|*.json|*.jsonl|*.txt|*.sh|*.gitignore|*.html|*.css|*.js|*.toml)
      return 0 ;;
  esac
  if sdx_have_cmd file; then
    local mt
    mt="$(file -b --mime-type "$f" 2>/dev/null || true)"
    [[ "$mt" == text/* || "$mt" == application/json || "$mt" == *yaml* || "$mt" == *json* ]] && return 0
  fi
  return 1
}

sdx_have_perl() {
  sdx_have_cmd perl
}

# 将路径段 agent/ 替换为 agent_slash（须以 / 结尾，如 .cursor/）
sdx_rewrite_agent_path_segment_in_file() {
  local file="$1" agent_slash="${2:?}"
  [[ -f "$file" ]] && sdx_is_text_file "$file" || return 0
  sdx_have_perl || return 0
  SDX_AGENT_SLASH="$agent_slash" \
    perl -CSD -i -pe 's{\bagent/}{$ENV{SDX_AGENT_SLASH}}g' \
    "$file" 2>/dev/null || true
}

sdx_rewrite_agent_path_segment_in_tree() {
  local root="$1" agent_slash="${2:?}"
  [[ -d "$root" ]] || return 0
  local f
  while IFS= read -r -d '' f; do
    sdx_rewrite_agent_path_segment_in_file "$f" "$agent_slash"
  done < <(find "$root" -type f -print0 2>/dev/null || true)
}
