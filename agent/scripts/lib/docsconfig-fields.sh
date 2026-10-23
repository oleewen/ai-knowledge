#!/usr/bin/env bash
# lib/docsconfig-fields.sh — 配置字段编解码与值校验
# 由 docsconfig.sh 加载；不设独立哨兵，随聚合入口换根刷新。

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

# 正文键序：AGENT_ROOT、AGENT_DIR、REPO_DIR、DOC_DIR、KNOWLEDGE_TYPE。
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
