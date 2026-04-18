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
# § 日志与输出
# =============================================================================

sdx_log()   { printf '%s\n'       "$*" >&2; }
sdx_info()  { printf '信息: %s\n'  "$*" >&2; }
sdx_warn()  { printf '警告: %s\n'  "$*" >&2; }
sdx_error() { printf '错误: %s\n' "$*" >&2; exit 1; }

# =============================================================================
# § IO 与同步工具
# =============================================================================

sdx_have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# dry-run 感知的命令执行器
# 要求调用方环境中定义了 $DRY_RUN 或全局变量
sdx_run_or_dry() {
  local dry="${DRY_RUN:-${CFG[dry_run]:-0}}"
  if [[ "$dry" == '1' ]]; then
    sdx_log "[dry-run] $*"
  else
    "$@"
  fi
}

sdx_ensure_dir() { sdx_run_or_dry mkdir -p "$1"; }

# 同步目录树，允许排除文件
# 用法：sdx_sync_dir <src> <dst> [extra_rsync_args...]
sdx_sync_dir() {
  local src="$1" dst="$2"
  shift 2
  local dry="${DRY_RUN:-${CFG[dry_run]:-0}}"

  [[ -d "$src" ]] || return 0
  if [[ "$dry" == '1' ]]; then
    sdx_log "[dry-run] 同步目录: $src → $dst"
    return 0
  fi
  sdx_ensure_dir "$dst"
  if sdx_have_cmd rsync; then
    rsync -a --delete "$@" "$src"/ "$dst"/
  else
    sdx_warn "未检测到 rsync，使用 cp -R（无法完全排除或增量同步；建议安装 rsync）"
    rm -rf "$dst"
    sdx_ensure_dir "$(dirname "$dst")"
    cp -R "$src" "$dst"
  fi
}

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

# =============================================================================
# § .docs-init 备份（docs-install 清空 DOC_DIR、docs-link 注销槽位等共用）
# =============================================================================

# 将已存在的文件或目录移至 repo_root/.docs-init/<stamp>/rel，rel 规则与 docs-install 的 backup_path 一致。
# 参数：repo_root、existing、stamp（可选，空则每次调用自生成时间戳）、dry_run（可选，1 则只打印不移动）
sdx_docs_backup_path_to_init() {
  local repo_root="${1:?}" existing="${2:?}" stamp="${3:-}" dry_run="${4:-0}"
  local backup_root rel backup_target
  existing="$(abs_path "$existing")"
  repo_root="$(strip_trailing_slash "$(abs_path "$repo_root")")"
  [[ -e "$existing" ]] || return 0
  [[ -n "$stamp" ]] || stamp="$(date +%Y-%m-%d_%H-%M-%S)"
  backup_root="${repo_root}/.docs-init/${stamp}"

  if [[ "$existing" == "$repo_root"/* ]]; then
    rel="${existing#"$repo_root"/}"
  else
    rel="${existing#/}"
  fi

  backup_target="${backup_root}/${rel}"
  if [[ -e "$backup_target" ]]; then
    local i=1
    while [[ -e "${backup_target}.__${i}" ]]; do (( i++ )); done
    backup_target="${backup_target}.__${i}"
  fi

  if [[ "$dry_run" == '1' ]]; then
    printf '信息: [dry-run] 将备份：%s → %s\n' "$existing" "$backup_target" >&2
    return 0
  fi

  mkdir -p "$(dirname "$backup_target")" 2>/dev/null || true
  mv "$existing" "$backup_target"
  printf '信息: 已备份：%s → %s\n' "$existing" "$backup_target" >&2
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

# 遍历 root 下待重写路径的文件：排除常见依赖/缓存/版本库目录，避免 ~/.cursor/skills 等目录残留导致 find 极慢或“假死”
sdx_rewrite_agent_path_segment_in_tree() {
  local root="$1" agent_slash="${2:?}"
  [[ -d "$root" ]] || return 0
  sdx_info "  重写 agent/ 路径引用（跳过 node_modules/.git 等）: ${root}"
  local f
  while IFS= read -r -d '' f; do
    sdx_rewrite_agent_path_segment_in_file "$f" "$agent_slash"
  done < <(
    find "$root" \
      \( -name node_modules -o -name .git -o -name __pycache__ -o -name .venv -o -name .cache -o -name dist -o -name build -o -name target \) \
      -prune -o -type f -print0 2>/dev/null || true
  )
}
