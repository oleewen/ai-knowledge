#!/usr/bin/env bash
#
# lib/docsconfig.sh — .docsconfig 读写校验、bootstrap 注入当前 shell、Git 默认常量
# 依赖：仅 lib/path.sh（轻量；tools 可只 source 本文件，不拖入 log-io / docs-core）
# 禁止 export DOC_ROOT / REPO_ROOT / DOC_DIR / AGENT_*（仅当前 shell 赋值）
#

_DOCSCONFIG_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=path.sh
source "${_DOCSCONFIG_LIB_DIR}/path.sh"
unset _DOCSCONFIG_LIB_DIR

if [[ -n "${_LIB_DOCSCONFIG_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_DOCSCONFIG_LOADED=1

DEFAULT_GIT_REPO_URL='https://github.com/oleewen/ai-knowledge.git'
DEFAULT_GIT_REF='HEAD'
SUPPORTED_KNOWLEDGE_TYPES=(application system company)

# 日志：聚合入口已加载 log-io 时复用 info；轻量 source 时回退 printf
_docsconfig_info() {
  if declare -F info >/dev/null 2>&1; then
    info "$@"
  else
    printf '%s\n' "$*"
  fi
}

docsconfig_bootstrap_get_repo_url() {
  printf '%s' "${GIT_REPO_URL:-$DEFAULT_GIT_REPO_URL}"
}

docsconfig_bootstrap_get_ref() {
  printf '%s' "${GIT_REF:-$DEFAULT_GIT_REF}"
}

docsconfig_bootstrap_get_tmpdir() {
  local tmpdir="${TMPDIR:-/tmp}"
  [[ -d "$tmpdir" ]] || tmpdir='/tmp'
  printf '%s' "$tmpdir"
}

docsconfig_bootstrap_gen_clone_dir() {
  printf '%s/ai-knowledge-%s' "${1:?tmpdir}" "$$"
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
  local doc_root="${1:?doc_root}" dr gr
  dr="$(cd -P "$doc_root" 2>/dev/null && pwd)" || return 0
  gr="$(git -C "$dr" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -n "$gr" && "$(dirname "$dr")" == "$gr" ]]; then
    printf '%s\n' "$gr"
    return 0
  fi
  cd -P "$(dirname "$doc_root")" 2>/dev/null && pwd || true
}

docsconfig_find_repo_root() {
  local pwd_root d i
  pwd_root="$(git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null || true)"
  d="$(cd -P "$PWD" 2>/dev/null && pwd)" || return 1

  for ((i = 0; i < 32; i++)); do
    [[ -f "$d/.docsconfig" ]] && {
      printf '%s' "$d"
      return 0
    }
    [[ -n "$pwd_root" && "$d" == "$pwd_root" ]] && break
    [[ "$d" == "/" ]] && break
    d="$(dirname "$d")"
  done
  return 1
}

docsconfig_find_path() {
  local repo_root
  repo_root="$(docsconfig_find_repo_root)" || return 1
  printf '%s/.docsconfig' "$repo_root"
}

docsconfig_validate_owner_matches_repo_root() {
  local config_owner_root="${1:?config_owner_root}"
  local repo_root="${2:?repo_root}"
  local owner_abs repo_abs

  owner_abs="$(cd -P "$config_owner_root" 2>/dev/null && pwd)" || return 1
  repo_abs="$(cd -P "$repo_root" 2>/dev/null && pwd)" || return 1
  if [[ "$owner_abs" != "$repo_abs" ]]; then
    printf '[docsconfig] 配置漂移：.docsconfig 位于 %s，但 REPO_ROOT=%s\n' \
      "$owner_abs" "$repo_abs" >&2
    return 1
  fi
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

docs_backup_path_to_init() {
  local repo_root="${1:?}" existing="${2:?}" stamp="${3:-}" dry_run="${4:-0}"
  local backup_root rel backup_target
  existing="$(abs_path "$existing")"
  repo_root="$(strip_trailing_slash "$(abs_path "$repo_root")")"
  [[ -e "$existing" ]] || return 0
  [[ -n "$stamp" ]] || stamp="$(date +%Y-%m-%d_%H-%M-%S)"
  backup_root="${repo_root}/.docs-init/${stamp}"

  rel="$(backup_rel_under_root "$repo_root" "$existing")"

  backup_target="${backup_root}/${rel}"
  if [[ -e "$backup_target" ]]; then
    local i=1
    while [[ -e "${backup_target}.__${i}" ]]; do (( i++ )); done
    backup_target="${backup_target}.__${i}"
  fi

  if [[ "$dry_run" == '1' ]]; then
    _docsconfig_info "[dry-run] 将备份：$existing → $backup_target"
    return 0
  fi

  mkdir -p "$(dirname "$backup_target")" 2>/dev/null || true
  mv "$existing" "$backup_target"
  _docsconfig_info "已备份：$existing → $backup_target"
}

docsconfig_knowledge_type_is_valid() {
  local v="${1:-}"
  [[ "$v" == 'application' || "$v" == 'system' || "$v" == 'company' ]]
}

docsconfig_validate_knowledge_type() {
  local v="${1:-}"
  docsconfig_knowledge_type_is_valid "$v" && return 0
  printf '[docsconfig] 非法 KNOWLEDGE_TYPE: %s（允许: application system company）\n' "$v" >&2
  return 1
}

# 打印 .docsconfig 正文键值（不含文件头）；参数：dr rr doc_dir knowledge_type agent_root
docsconfig_print_kv_block() {
  local dr="$1" rr="$2" doc_dir="$3" knowledge_type="$4" agent_root="$5"
  local ar
  printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$dr" "$rr" "$doc_dir"
  [[ -n "$knowledge_type" ]] && printf 'KNOWLEDGE_TYPE=%s\n' "$knowledge_type"
  if [[ -n "$agent_root" ]]; then
    ar="$(docsconfig_format_root_for_write "$agent_root")"
    printf 'AGENT_ROOT=%s\n' "$ar"
  fi
}

# Usage: docsconfig_write <repo_root> <doc_root> <doc_dir> [dry] [agent_root] [knowledge_type]
docsconfig_write() {
  local repo_root="${1:?repo_root}"
  local doc_root="${2:?doc_root}"
  local doc_dir="${3:?doc_dir}"
  local dry="${4:-0}"
  local agent_root_in="${5:-}"
  local knowledge_type_in="${6:-}"

  # 兼容旧调用：第 5 位误传 knowledge_type、未传 agent_root
  if [[ -n "$agent_root_in" && -z "$knowledge_type_in" ]]; then
    case "$agent_root_in" in
      application|system|company)
        knowledge_type_in="$agent_root_in"
        agent_root_in=''
        ;;
    esac
  fi

  local out rr dr
  out="$(strip_trailing_slash "$(abs_path "$repo_root")")/.docsconfig"
  rr="$(docsconfig_format_root_for_write "$repo_root")"
  dr="$(docsconfig_format_root_for_write "$doc_root")"

  if [[ -n "$knowledge_type_in" ]]; then
    docsconfig_validate_knowledge_type "$knowledge_type_in" || return 1
  fi

  if [[ "$dry" == '1' ]]; then
    printf 'Would write %s:\n' "$out"
    docsconfig_print_kv_block "$dr" "$rr" "$doc_dir" "$knowledge_type_in" "$agent_root_in"
    return 0
  fi

  umask 022
  {
    docsconfig_print_kv_block "$dr" "$rr" "$doc_dir" "$knowledge_type_in" "$agent_root_in"
  } >"$out"
}

# Usage: docsconfig_read_into <path> <doc_var> <repo_var> <ddir_var> [aroot_var [ktype_var]]
docsconfig_read_into() {
  local path="${1:?path}"
  local -n _doc="${2:?}"
  local -n _repo="${3:?}"
  local -n _ddir="${4:?}"
  _doc=''; _repo=''; _ddir=''
  [[ -f "$path" ]] || return 1

  # 局部名须避开调用方 nameref 目标（如 raw_ar / AGENT_ROOT），否则 Bash 会写空调用方变量。
  local _dc_raw_doc='' _dc_raw_repo='' _dc_raw_ddir='' _dc_raw_ar='' _dc_raw_kt=''
  local line k v
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    case "$line" in
      DOC_ROOT=*|REPO_ROOT=*|DOC_DIR=*|AGENT_ROOT=*|KNOWLEDGE_TYPE=*)
        k="${line%%=*}"
        v="${line#*=}"
        v="${v%$'\r'}"
        case "$k" in
          DOC_ROOT) _dc_raw_doc="$v" ;;
          REPO_ROOT) _dc_raw_repo="$v" ;;
          DOC_DIR) _dc_raw_ddir="$v" ;;
          AGENT_ROOT) _dc_raw_ar="$v" ;;
          KNOWLEDGE_TYPE) _dc_raw_kt="$v" ;;
        esac
        ;;
    esac
  done <"$path"

  [[ -n "$_dc_raw_doc" ]] && _doc="$(docsconfig_normalize_root_value "$_dc_raw_doc")"
  [[ -n "$_dc_raw_repo" ]] && _repo="$(docsconfig_normalize_root_value "$_dc_raw_repo")"
  _ddir="$_dc_raw_ddir"

  if (( $# >= 5 )); then
    local -n _aroot="${5:?}"
    _aroot=''
    [[ -n "$_dc_raw_ar" ]] && _aroot="$(docsconfig_normalize_root_value "$_dc_raw_ar")"
  fi
  if (( $# >= 6 )); then
    local -n _ktype="${6:?}"
    _ktype="$_dc_raw_kt"
  fi
  return 0
}

docsconfig_resolve_doc_root() {
  printf '%s' "${DOC_ROOT:-}"
}

docsconfig_bootstrap_fail() {
  local msg="${1:-[config] 配置校验失败。}"
  printf '%s\n' "$msg" >&2
  cat >&2 <<'EOF'
[config] 请使用 /docs-install 或 docs-install.sh 初始化并写入 .docsconfig，例如：
  bash agent/skills/docs-install/scripts/docs-install.sh --scope=config --target <目标工程文档目录>
（在已克隆 ai-knowledge 的仓库根执行；路径请按实际工程调整）
EOF
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 1
  fi
  return 1
}

# Usage: docsconfig_bootstrap_validate
# 自 cwd 上溯查找 .docsconfig，注入 DOC_ROOT / REPO_ROOT / DOC_DIR（及可选字段）到当前 shell。
docsconfig_bootstrap_validate() {
  local cfg_path config_owner_root

  cfg_path="$(docsconfig_find_path)" || {
    docsconfig_bootstrap_fail "[config] 未找到当前工程的 .docsconfig。"
    return 1
  }
  config_owner_root="$(dirname "$cfg_path")"

  KNOWLEDGE_TYPE=""
  DOCSCONFIG_PATH="$cfg_path"
  CONFIG_OWNER_ROOT="$config_owner_root"
  docsconfig_read_into "$cfg_path" DOC_ROOT REPO_ROOT DOC_DIR AGENT_ROOT KNOWLEDGE_TYPE || {
    docsconfig_bootstrap_fail "[config] 解析 .docsconfig 失败。"
    return 1
  }

  if [[ -z "${DOC_ROOT:-}" || -z "${REPO_ROOT:-}" || -z "${DOC_DIR:-}" ]]; then
    docsconfig_bootstrap_fail "[config] .docsconfig 缺少必需的 DOC_ROOT、REPO_ROOT 或 DOC_DIR。"
    return 1
  fi

  docsconfig_validate_owner_matches_repo_root "$config_owner_root" "$REPO_ROOT" || {
    docsconfig_bootstrap_fail "[config] .docsconfig 与 REPO_ROOT 不一致。请重新执行 docs-install。"
    return 1
  }
}
