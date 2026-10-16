#!/usr/bin/env bash
#
# lib/docsconfig.sh — .docsconfig 读写校验、bootstrap 注入当前 shell、Git 默认常量
# 依赖：仅 lib/path.sh（轻量；tools 可只 source 本文件，不拖入 log-io / docs-core）
# 禁止 export WORK_SPACE / REPO_DIR / DOC_DIR / AGENT_*（仅当前 shell 赋值）
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
SUPPORTED_KNOWLEDGE_TYPES=(application system solution company meta)

# 日志：聚合入口已加载 log-io 时复用 info；轻量 source 时回退 printf
_docsconfig_info() {
  if declare -F info >/dev/null 2>&1; then
    info "$@"
  else
    printf '%s\n' "$*"
  fi
}

_docsconfig_err() {
  printf '%s\n' "$*" >&2
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

docsconfig_repo_from_doc() {
  local doc_abs="${1:?doc_abs}" dr gr
  dr="$(cd -P "$doc_abs" 2>/dev/null && pwd)" || return 0
  gr="$(git -C "$dr" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -n "$gr" && "$(dirname "$dr")" == "$gr" ]]; then
    printf '%s\n' "$gr"
    return 0
  fi
  cd -P "$(dirname "$doc_abs")" 2>/dev/null && pwd || true
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

docsconfig_validate_owner_matches_repo() {
  local config_owner_root="${1:?config_owner_root}"
  local repo_abs_in="${2:?repo_abs}"
  local owner_abs repo_abs

  owner_abs="$(cd -P "$config_owner_root" 2>/dev/null && pwd)" || return 1
  repo_abs="$(cd -P "$repo_abs_in" 2>/dev/null && pwd)" || return 1
  if [[ "$owner_abs" != "$repo_abs" ]]; then
    printf '[docsconfig] 配置漂移：.docsconfig 位于 %s，但仓库路径为 %s\n' \
      "$owner_abs" "$repo_abs" >&2
    return 1
  fi
}

docsconfig_doc_dir_from_roots() {
  local repo_root="${1:?repo_root}" doc_root="${2:?doc_root}"
  local rr dr
  rr="$(cd -P "$repo_root" 2>/dev/null && pwd)" || {
    printf '[docsconfig] 无法解析仓库路径: %s\n' "$repo_root" >&2
    return 1
  }
  dr="$(cd -P "$doc_root" 2>/dev/null && pwd)" || {
    printf '[docsconfig] 无法解析文档路径: %s\n' "$doc_root" >&2
    return 1
  }
  case "$dr" in
    "$rr") printf '.\n' ;;
    "$rr"/*) printf '%s\n' "${dr#"$rr"/}" ;;
    *)
      printf '[docsconfig] 文档路径不在仓库路径下: %s vs %s\n' "$dr" "$rr" >&2
      return 1
      ;;
  esac
}

docs_backup_path_to_init() {
  local repo_root="${1:?}" existing="${2:?}" stamp="${3:-}" dry_run="${4:-0}"
  local backup_root rel backup_target
  # 软链：只搬链接本身，勿 abs_path/cd -P 跟随到实体树（否则会误迁 ~/.agents）
  if [[ -L "$existing" ]]; then
    local parent base
    parent="$(cd "$(dirname "$existing")" 2>/dev/null && pwd)" || parent="$(dirname "$existing")"
    base="$(basename "$existing")"
    existing="${parent}/${base}"
  else
    existing="$(abs_path "$existing")"
  fi
  repo_root="$(strip_trailing_slash "$(abs_path "$repo_root")")"
  [[ -e "$existing" || -L "$existing" ]] || return 0
  [[ -n "$stamp" ]] || stamp="$(date +%Y-%m-%d_%H-%M-%S)"
  backup_root="${repo_root}/.docs-init/${stamp}"

  rel="$(backup_rel_under_root "$repo_root" "$existing")"

  backup_target="${backup_root}/${rel}"
  if [[ -e "$backup_target" || -L "$backup_target" ]]; then
    local i=1
    while [[ -e "${backup_target}.__${i}" || -L "${backup_target}.__${i}" ]]; do (( i++ )); done
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
  [[ "$v" == 'application' || "$v" == 'system' || "$v" == 'solution' || "$v" == 'company' || "$v" == 'meta' ]]
}

docsconfig_validate_knowledge_type() {
  local v="${1:-}"
  docsconfig_knowledge_type_is_valid "$v" && return 0
  printf '[docsconfig] 非法 KNOWLEDGE_TYPE: %s（允许: application system solution company meta）\n' "$v" >&2
  return 1
}

docsconfig_validate_repo_dir() {
  local v="${1:-}"
  if [[ -z "$v" || "$v" == "." || "$v" == ".." || "$v" == /* || "$v" == "~" || "$v" == "~/"* || "$v" == *"/"* ]]; then
    _docsconfig_err "[docsconfig] REPO_DIR 须为单段目录名: ${v:-空}"
    return 1
  fi
}

docsconfig_validate_doc_dir() {
  local v="${1:-}" seg
  local -a segs=()
  if [[ -z "$v" || "$v" == "." || "$v" == /* || "$v" == "~" || "$v" == "~/"* ]]; then
    _docsconfig_err "[docsconfig] DOC_DIR 须为仓库下的相对子路径: ${v:-空}"
    return 1
  fi
  IFS='/' read -ra segs <<< "$v"
  for seg in "${segs[@]}"; do
    if [[ -z "$seg" || "$seg" == "." || "$seg" == ".." ]]; then
      _docsconfig_err "[docsconfig] DOC_DIR 含非法段: $v"
      return 1
    fi
  done
}

# 打印 .docsconfig 正文。键序：AGENT_ROOT、AGENT_DIR、REPO_DIR、DOC_DIR、KNOWLEDGE_TYPE
# 参数：repo_dir doc_dir knowledge_type agent_root agent_dir
docsconfig_print_kv_block() {
  local repo_dir="$1" doc_dir="$2" knowledge_type="$3" agent_root="$4" agent_dir="${5:-}"
  local ar
  if [[ -n "$agent_root" ]]; then
    ar="$(docsconfig_format_root_for_write "$agent_root")"
    printf 'AGENT_ROOT=%s\n' "$ar"
  fi
  if [[ -n "$agent_dir" ]]; then
    printf 'AGENT_DIR=%s\n' "$agent_dir"
  fi
  printf 'REPO_DIR=%s\nDOC_DIR=%s\n' "$repo_dir" "$doc_dir"
  if [[ -n "$knowledge_type" ]]; then
    printf 'KNOWLEDGE_TYPE=%s\n' "$knowledge_type"
  fi
}

# Usage: docsconfig_write <repo_root> <doc_root> <doc_dir> [dry] [agent_root] [knowledge_type] [agent_dir]
docsconfig_write() {
  local repo_root="${1:?repo_root}"
  local doc_root="${2:?doc_root}"
  local doc_dir="${3:?doc_dir}"
  local dry="${4:-0}"
  local agent_root_in="${5:-}"
  local knowledge_type_in="${6:-}"
  local agent_dir_in="${7:-}"

  # 兼容旧调用：第 5 位误传 knowledge_type、未传 agent_root
  if [[ -n "$agent_root_in" && -z "$knowledge_type_in" ]]; then
    case "$agent_root_in" in
      application|system|solution|company|meta)
        knowledge_type_in="$agent_root_in"
        agent_root_in=''
        ;;
    esac
  fi

  local out repo_dir computed_dd
  out="$(strip_trailing_slash "$(abs_path "$repo_root")")/.docsconfig"
  repo_dir="$(basename "$(strip_trailing_slash "$(abs_path "$repo_root")")")"
  docsconfig_validate_repo_dir "$repo_dir" || return 1
  docsconfig_validate_doc_dir "$doc_dir" || return 1
  computed_dd="$(docsconfig_doc_dir_from_roots "$repo_root" "$doc_root")" || return 1
  if [[ "$computed_dd" != "$doc_dir" ]]; then
    _docsconfig_err "[docsconfig] DOC_DIR 与文档路径不一致: ${doc_dir} vs ${computed_dd}"
    return 1
  fi

  if [[ -n "$knowledge_type_in" ]]; then
    docsconfig_validate_knowledge_type "$knowledge_type_in" || return 1
  fi

  if [[ -n "$agent_root_in" ]] && declare -F docsconfig_agent_root_looks_like_entity_tree >/dev/null 2>&1; then
    if docsconfig_agent_root_looks_like_entity_tree "$agent_root_in"; then
      _docsconfig_err "[docsconfig] AGENT_ROOT 不能指向实体树（当前像是 ${agent_root_in}）。请改为家目录（如 ~）并设置 AGENT_DIR=.agents（或探测到的 IDE 根名）。"
      return 1
    fi
  fi

  if [[ -n "$agent_root_in" && -z "$agent_dir_in" ]]; then
    _docsconfig_err "[docsconfig] 已设 AGENT_ROOT 但缺少 AGENT_DIR。请在 .docsconfig 补充 AGENT_DIR=.agents（或探测到的目录名）。"
    return 1
  fi

  if [[ "$dry" == '1' ]]; then
    printf 'Would write %s:\n' "$out"
    docsconfig_print_kv_block "$repo_dir" "$doc_dir" "$knowledge_type_in" "$agent_root_in" "$agent_dir_in"
    return 0
  fi

  umask 022
  {
    docsconfig_print_kv_block "$repo_dir" "$doc_dir" "$knowledge_type_in" "$agent_root_in" "$agent_dir_in"
  } >"$out"
}

# Usage: docsconfig_read_into <path> <repo_dir_var> <ddir_var> [aroot_var [ktype_var [adir_var]]]
docsconfig_read_into() {
  local path="${1:?path}"
  local repo_dir_out='' ddir_out=''
  local reset_name
  for reset_name in "${@:2}"; do
    [[ "$reset_name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 2
    eval "$reset_name"=''
  done
  [[ -f "$path" ]] || return 1

  # 局部名须避开调用方输出变量目标（如 raw_ar / AGENT_ROOT），否则 Bash 会写空调用方变量。
  local _dc_raw_rd='' _dc_raw_ddir='' _dc_raw_ar='' _dc_raw_kt='' _dc_raw_adir=''
  local line k v
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    case "$line" in
      REPO_DIR=*|DOC_DIR=*|AGENT_ROOT=*|AGENT_DIR=*|KNOWLEDGE_TYPE=*)
        k="${line%%=*}"
        v="${line#*=}"
        v="${v%$'\r'}"
        v="${v#\"}"
        v="${v%\"}"
        v="${v#\'}"
        v="${v%\'}"
        case "$k" in
          REPO_DIR) _dc_raw_rd="$v" ;;
          DOC_DIR) _dc_raw_ddir="$v" ;;
          AGENT_ROOT) _dc_raw_ar="$v" ;;
          AGENT_DIR) _dc_raw_adir="$v" ;;
          KNOWLEDGE_TYPE) _dc_raw_kt="$v" ;;
        esac
        ;;
    esac
  done <"$path"

  repo_dir_out="$_dc_raw_rd"
  ddir_out="$_dc_raw_ddir"

  if (( $# >= 4 )); then
    local aroot_out=''
    [[ -n "$_dc_raw_ar" ]] && aroot_out="$(docsconfig_normalize_root_value "$_dc_raw_ar")"
    eval "${4:?}=\$aroot_out"
  fi
  if (( $# >= 5 )); then
    eval "${5:?}=\$_dc_raw_kt"
  fi
  if (( $# >= 6 )); then
    eval "${6:?}=\$_dc_raw_adir"
  fi
  eval "${2:?}=\$repo_dir_out"
  eval "${3:?}=\$ddir_out"
  return 0
}

docsconfig_configs_file() {
  local agent_root="${1:?}" agent_dir="${2:?}"
  local root
  root="$(strip_trailing_slash "$(docsconfig_normalize_root_value "$agent_root")")"
  printf '%s/%s/configs' "$root" "$agent_dir"
}

docsconfig_read_workspace_raw() {
  local path="${1:?}" line v
  [[ -f "$path" ]] || return 1
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" == WORK_SPACE=* ]] || continue
    v="${line#*=}"
    v="${v%$'\r'}"
    v="${v#\"}"
    v="${v%\"}"
    v="${v#\'}"
    v="${v%\'}"
    printf '%s' "$v"
    return 0
  done <"$path"
  return 1
}

docsconfig_workspace_fail() {
  local msg="${1:-[config] 未找到工作区文件。}"
  printf '%s\n' "$msg" >&2
  cat >&2 <<'EOF'
[config] 请执行 /agent-install，并传入 --workspace <工作区目录>。例如：
  bash agent/skills/agent-install/scripts/agent-install.sh --workspace ~/workspaces
EOF
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 1
  fi
  return 1
}

docsconfig_load_workspace_abs() {
  local agent_root="${1:?}" agent_dir="${2:?}"
  local path raw
  path="$(docsconfig_configs_file "$agent_root" "$agent_dir")"
  if [[ ! -f "$path" ]]; then
    docsconfig_workspace_fail "[config] 未找到工作区文件: ${path}"
    return 1
  fi
  raw="$(docsconfig_read_workspace_raw "$path" || true)"
  if [[ -z "$raw" ]]; then
    docsconfig_workspace_fail "[config] 工作区文件缺少 WORK_SPACE: ${path}"
    return 1
  fi
  docsconfig_normalize_root_value "$raw"
}

docsconfig_compose_repo_abs() {
  local ws="${1:?}" repo_dir="${2:?}"
  docsconfig_normalize_root_value "${ws%/}/${repo_dir}"
}

docsconfig_compose_doc_abs() {
  local ws="${1:?}" repo_dir="${2:?}" doc_dir="${3:?}"
  local repo_abs
  repo_abs="$(docsconfig_compose_repo_abs "$ws" "$repo_dir")"
  docsconfig_normalize_root_value "${repo_abs%/}/${doc_dir}"
}

docsconfig_repo_abs() {
  docsconfig_compose_repo_abs "${WORK_SPACE:?WORK_SPACE 未注入}" "${REPO_DIR:?REPO_DIR 未注入}"
}

docsconfig_doc_abs() {
  docsconfig_compose_doc_abs "${WORK_SPACE:?WORK_SPACE 未注入}" "${REPO_DIR:?REPO_DIR 未注入}" "${DOC_DIR:?DOC_DIR 未注入}"
}

# 从一份 .docsconfig 拼出仓库路径与文档路径。不改当前 shell 的 WORK_SPACE。
# Usage: docsconfig_abs_for_config <cfg> <repo_var> <doc_var> <ddir_var> [aroot_var [ktype_var [adir_var]]]
docsconfig_abs_for_config() {
  local path="${1:?}"
  local rd='' dd='' ar='' kt='' ad=''
  local ws repo_abs doc_abs
  docsconfig_read_into "$path" rd dd ar kt ad || return 1
  if [[ -z "$rd" || -z "$dd" ]]; then
    _docsconfig_err "[config] .docsconfig 缺少 REPO_DIR 或 DOC_DIR: ${path}"
    _docsconfig_err "[config] 请重新执行 docs-install。"
    return 1
  fi
  docsconfig_validate_repo_dir "$rd" || return 1
  docsconfig_validate_doc_dir "$dd" || return 1
  if [[ -z "$ar" || -z "$ad" ]]; then
    _docsconfig_err "[config] .docsconfig 缺少 AGENT_ROOT 或 AGENT_DIR，无法定位工作区文件: ${path}"
    return 1
  fi
  ws="$(docsconfig_load_workspace_abs "$ar" "$ad")" || return 1
  repo_abs="$(docsconfig_compose_repo_abs "$ws" "$rd")"
  doc_abs="$(docsconfig_compose_doc_abs "$ws" "$rd" "$dd")"
  printf -v "${2:?}" '%s' "$repo_abs"
  printf -v "${3:?}" '%s' "$doc_abs"
  printf -v "${4:?}" '%s' "$dd"
  if (( $# >= 5 )); then printf -v "${5:?}" '%s' "$ar"; fi
  if (( $# >= 6 )); then printf -v "${6:?}" '%s' "$kt"; fi
  if (( $# >= 7 )); then printf -v "${7:?}" '%s' "$ad"; fi
}

docsconfig_write_workspace() {
  local store="${1:?}" workspace="${2:?}" dry="${3:-0}"
  local formatted path
  formatted="$(docsconfig_format_root_for_write "$workspace")"
  path="$(strip_trailing_slash "$(abs_path "$store")")/configs"
  if [[ "$dry" == '1' ]]; then
    printf 'Would write %s:\nWORK_SPACE=%s\n' "$path" "$formatted"
    return 0
  fi
  umask 022
  printf 'WORK_SPACE=%s\n' "$formatted" >"$path"
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
# 自 cwd 上溯查找 .docsconfig，注入 WORK_SPACE / REPO_DIR / DOC_DIR（及 AGENT_*、KNOWLEDGE_TYPE）。
docsconfig_bootstrap_validate() {
  local cfg_path config_owner_root repo_abs

  cfg_path="$(docsconfig_find_path)" || {
    docsconfig_bootstrap_fail "[config] 未找到当前工程的 .docsconfig。"
    return 1
  }
  config_owner_root="$(dirname "$cfg_path")"

  KNOWLEDGE_TYPE=""
  AGENT_DIR=""
  AGENT_ROOT=""
  REPO_DIR=""
  DOC_DIR=""
  WORK_SPACE=""
  DOCSCONFIG_PATH="$cfg_path"
  CONFIG_OWNER_ROOT="$config_owner_root"
  docsconfig_read_into "$cfg_path" REPO_DIR DOC_DIR AGENT_ROOT KNOWLEDGE_TYPE AGENT_DIR || {
    docsconfig_bootstrap_fail "[config] 解析 .docsconfig 失败。"
    return 1
  }

  if [[ -z "${REPO_DIR:-}" || -z "${DOC_DIR:-}" ]]; then
    docsconfig_bootstrap_fail "[config] .docsconfig 缺少必需的 REPO_DIR 或 DOC_DIR。"
    return 1
  fi
  docsconfig_validate_repo_dir "$REPO_DIR" || {
    docsconfig_bootstrap_fail "[config] REPO_DIR 非法。"
    return 1
  }
  docsconfig_validate_doc_dir "$DOC_DIR" || {
    docsconfig_bootstrap_fail "[config] DOC_DIR 非法。"
    return 1
  }

  if [[ -z "${AGENT_ROOT:-}" || -z "${AGENT_DIR:-}" ]]; then
    docsconfig_bootstrap_fail "[config] .docsconfig 缺少 AGENT_ROOT 或 AGENT_DIR，无法定位工作区文件。"
    return 1
  fi

  if declare -F docsconfig_agent_root_looks_like_entity_tree >/dev/null 2>&1; then
    if docsconfig_agent_root_looks_like_entity_tree "$AGENT_ROOT"; then
      docsconfig_bootstrap_fail "[config] AGENT_ROOT 不能指向实体树。请改为 ~（或家目录）并设置 AGENT_DIR。"
      return 1
    fi
  fi

  WORK_SPACE="$(docsconfig_load_workspace_abs "$AGENT_ROOT" "$AGENT_DIR")" || return 1
  repo_abs="$(docsconfig_repo_abs)"
  docsconfig_validate_owner_matches_repo "$config_owner_root" "$repo_abs" || {
    docsconfig_bootstrap_fail "[config] .docsconfig 与仓库路径不一致。请重新执行 docs-install。"
    return 1
  }
}

# 补齐 AGENT_ROOT/AGENT_DIR：已齐且可解析则保留；否则探测写入输出变量。
# 用法：docsconfig_fill_agent_fields <out_root> <out_dir> <old_root> <old_dir> [home]
docsconfig_fill_agent_fields() {
  local ar_out ad_out
  local old_ar="${3:-}"
  local old_ad="${4:-}"
  local home="${5:-${HOME:-}}"
  local tree=''

  ar_out=''
  ad_out=''

  if [[ -n "$old_ar" ]]; then
    if declare -F docsconfig_agent_root_looks_like_entity_tree >/dev/null 2>&1 \
      && docsconfig_agent_root_looks_like_entity_tree "$old_ar"; then
      _docsconfig_err "[docsconfig] 已有 AGENT_ROOT 指向实体树（${old_ar}）。请手改为家目录（如 ~）并设置 AGENT_DIR 后再跑。"
      return 1
    fi
  fi

  if [[ -n "$old_ar" && -n "$old_ad" ]]; then
    tree="$(strip_trailing_slash "$(abs_path "${old_ar}/${old_ad}")")"
    if declare -F agent_layout_is_install_root >/dev/null 2>&1 && agent_layout_is_install_root "$tree"; then
      ar_out="$(strip_trailing_slash "$(abs_path "$old_ar")")"
      ad_out="$old_ad"
      eval "${1:?}=\$ar_out"
      eval "${2:?}=\$ad_out"
      return 0
    fi
    _docsconfig_info "已有 AGENT_ROOT/AGENT_DIR 无法解析为安装树，将重新探测…"
  fi

  if ! declare -F probe_agent_install_root >/dev/null 2>&1; then
    # shellcheck source=agent-layout.sh
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/agent-layout.sh"
  fi
  probe_agent_install_root ar_out ad_out "$home" || return 1
  eval "${1:?}=\$ar_out"
  eval "${2:?}=\$ad_out"
  _docsconfig_info "已探测 Agent 安装根: AGENT_ROOT=${ar_out} AGENT_DIR=${ad_out}"
}
