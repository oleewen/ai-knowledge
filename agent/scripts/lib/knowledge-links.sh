#!/usr/bin/env bash
#
# lib/knowledge-links.sh — knowledge-links.yaml 读写
# 依赖：lib/path.sh、lib/log-io.sh、lib/docsconfig.sh（format_root）、lib/git-remote.sh
#

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=docsconfig.sh
source "${_LIB_DIR}/docsconfig.sh"
# shellcheck source=git-remote.sh
source "${_LIB_DIR}/git-remote.sh"

if [[ -n "${_LIB_KNOWLEDGE_LINKS_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_KNOWLEDGE_LINKS_LOADED=1

_yaml_unquote() {
  local v="${1:-}"
  v="${v#\"}"; v="${v%\"}"
  v="${v#\'}"; v="${v%\'}"
  printf '%s' "$v"
}

# 与 identity 解析一致：判定是否为 Git 远端 URL 形态（path 字段禁止写入此类串）
knowledge_link_value_looks_like_git_remote() {
  [[ "${1:-}" =~ ^(git@|ssh://|https://|http://) ]]
}

# path 字段禁止为远程 URL 形态（须写在 repository）
knowledge_links_validate_stored_path_field() {
  local p="${1:?}" src="${2:?}"
  [[ -n "$p" ]] || error "knowledge-links.yaml 条目缺少 path 或 path 为空: $src"
  if knowledge_link_value_looks_like_git_remote "$p"; then
    error "knowledge-links.yaml: path 不得为远程 URL（已废弃）。请将远端写入 repository，path 改为 ~/…、~/ 或本机绝对路径（兼容旧：无 ~ 的 \$HOME 相对片段）: $src"
  fi
}

# 将登记 path 展开为绝对路径（~/…、~、/ 绝对路径走 abs_path；否则视为相对 $HOME 的旧形态并拼 $HOME）
knowledge_link_expand_stored_path() {
  local p="${1:?}" home
  if [[ "$p" == /* || "$p" == '~' || "$p" =~ ^~/ ]]; then
    abs_path "$p"
    return 0
  fi
  home="${HOME:-}"
  [[ -n "$home" ]] || error "未设置 HOME，无法展开相对 path: $p"
  abs_path "${home%/}/$p"
}

# 本机绝对路径 → 登记 path（$HOME 下写成 ~/…）
knowledge_link_stored_path_from_absolute() {
  docsconfig_format_root_for_write "${1:?}"
}

_knowledge_link_yaml_escape_dq() {
  local s="${1-}"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

# 打印条目公共字段；first_prefix 为首行前缀（如 '  - ' 或 '    '），续行固定四空格
_knowledge_links_print_repo_path_docdir() {
  local first_prefix="${1:?}" repo="${2:?}" path="${3:?}" doc_dir="${4:-}"
  printf '%srepository: "%s"\n' "$first_prefix" "$(_knowledge_link_yaml_escape_dq "$repo")"
  printf '    path: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$path")"
  if [[ -n "$doc_dir" ]]; then
    printf '    doc_dir: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$doc_dir")"
  fi
}

_knowledge_links_print_name_label() {
  local kind="${1:?}" name="${2:?}" label="${3:?}"
  printf '    %s_name: "%s"\n' "$kind" "$(_knowledge_link_yaml_escape_dq "$name")"
  printf '    %s_label: "%s"\n' "$kind" "$(_knowledge_link_yaml_escape_dq "$label")"
}

# 覆盖写出 knowledge-links.yaml（可含 type:parent / type:meta + child）
# child_kind: sys|app；parent_kind: company|sys|none（仅 type=parent 条使用）
# type:meta：只写 repository/path/doc_dir（doc_dir=目标 KNOWLEDGE_TYPE，无 name/label）
# DRY=1 时只打印将写入条数，不落盘
knowledge_links_write_entries() {
  local f="${1:?}"
  local -n _repos="${2:?}"
  local -n _paths="${3:?}"
  local -n _dirs="${4:?}"
  local -n _apps="${5:?}"
  local -n _labels="${6:?}"
  local -n _types="${7:?}"
  local child_kind="${8:?}"
  local parent_kind="${9:?}"
  local d i n lab t name_kind
  d="$(dirname "$f")"
  n="${#_paths[@]}"
  case "$child_kind" in
    sys|app) ;;
    *) error "knowledge_links_write_entries: child_kind 须为 sys|app（收到: ${child_kind})" ;;
  esac
  case "$parent_kind" in
    company|sys|none) ;;
    *) error "knowledge_links_write_entries: parent_kind 须为 company|sys|none（收到: ${parent_kind})" ;;
  esac
  [[ "${DRY:-0}" == '1' ]] && { printf '[dry-run] 将写入 %s（%d 条 links）\n' "$f" "$n" >&2; return 0; }
  mkdir -p "$d"
  umask 022
  {
    printf '%s\n' '# 知识库建联清单（可由 docs-link.sh / docs-install.sh 维护）'
    if [[ "$n" -eq 0 ]]; then
      printf '%s\n' 'links: []'
    else
      printf '%s\n' 'links:'
      for ((i = 0; i < n; i++)); do
        [[ -n "${_repos[i]:-}" ]] || error "knowledge-links.yaml 条目缺少 repository（必填）: $f"
        [[ -n "${_paths[i]:-}" ]] || error "knowledge-links.yaml 条目缺少 path（必填）: $f"
        t="${_types[i]:-child}"
        if [[ "$t" == 'parent' ]]; then
          printf '  - type: parent\n'
          _knowledge_links_print_repo_path_docdir '    ' "${_repos[i]}" "${_paths[i]}" "${_dirs[i]:-}"
          [[ -n "${_apps[i]:-}" ]] || error "knowledge-links.yaml(parent) 条目缺少 name（必填）: $f"
          lab="${_labels[i]:-${_apps[i]}}"
          name_kind='sys'
          [[ "$parent_kind" == 'company' ]] && name_kind='company'
          _knowledge_links_print_name_label "$name_kind" "${_apps[i]}" "$lab"
        elif [[ "$t" == 'meta' ]]; then
          printf '  - type: meta\n'
          _knowledge_links_print_repo_path_docdir '    ' "${_repos[i]}" "${_paths[i]}" "${_dirs[i]:-}"
        else
          _knowledge_links_print_repo_path_docdir '  - ' "${_repos[i]}" "${_paths[i]}" "${_dirs[i]:-}"
          [[ -n "${_apps[i]:-}" ]] || error "knowledge-links.yaml(child) 条目缺少 name（必填）: $f"
          lab="${_labels[i]:-${_apps[i]}}"
          name_kind='app'
          [[ "$child_kind" == 'sys' ]] && name_kind='sys'
          _knowledge_links_print_name_label "$name_kind" "${_apps[i]}" "$lab"
        fi
      done
    fi
  } >"$f"
}

# 读入 knowledge-links.yaml 填入数组（下标对齐）；非法旧形态 path=URL 时报错退出。
# 第 7 参 types：每条 type（缺省 child）；parent / meta / child 均载入，调用方自行过滤。
knowledge_links_load_into_arrays() {
  local f="${1:?}"
  local -n _paths="${2:?}"
  local -n _repos="${3:?}"
  local -n _dirs="${4:?}"
  local -n _apps="${5:?}"
  local -n _labels="${6:?}"
  local -n _types="${7:?}"
  local line key val path="" repo="" doc_dir="" app_name="" app_label="" sys_name="" sys_label=""
  local company_name="" company_label="" entry_type=""

  _paths=()
  _repos=()
  _dirs=()
  _apps=()
  _labels=()
  _types=()

  [[ -f "$f" ]] || return 0

  flush_pending() {
    if [[ -n "$path" ]]; then
      knowledge_links_validate_stored_path_field "$path" "$f"
      _paths+=("$path")
      _repos+=("${repo:-}")
      _dirs+=("${doc_dir:-}")
      _types+=("${entry_type:-child}")
      if [[ "${entry_type:-child}" == 'parent' ]]; then
        if [[ -n "${company_name}${company_label}" ]]; then
          _apps+=("${company_name:-}")
          _labels+=("${company_label:-}")
        else
          _apps+=("${sys_name:-}")
          _labels+=("${sys_label:-}")
        fi
      elif [[ "${entry_type:-child}" == 'meta' ]]; then
        _apps+=('')
        _labels+=('')
      elif [[ -n "${sys_name}${sys_label}" ]]; then
        _apps+=("${sys_name:-}")
        _labels+=("${sys_label:-}")
      else
        _apps+=("${app_name:-}")
        _labels+=("${app_label:-}")
      fi
    elif [[ -n "$repo$doc_dir$app_name$app_label$sys_name$sys_label$company_name$company_label$entry_type" ]]; then
      error "knowledge-links.yaml 中存在未写完的条目（有字段但缺少 path）: $f"
    fi
    path='' repo='' doc_dir='' app_name='' app_label='' sys_name='' sys_label=''
    company_name='' company_label='' entry_type=''
  }

  set_kv() {
    case "${1:?}" in
      path) path="$2" ;;
      repository) repo="$2" ;;
      doc_dir) doc_dir="$2" ;;
      type) entry_type="$2" ;;
      app_name) app_name="$2" ;;
      app_label) app_label="$2" ;;
      sys_name) sys_name="$2" ;;
      sys_label) sys_label="$2" ;;
      company_name) company_name="$2" ;;
      company_label) company_label="$2" ;;
      *) ;;
    esac
  }

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+([a-z_]+):[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")"
      flush_pending
      set_kv "$key" "$val"
    elif [[ "$line" =~ ^[[:space:]]{4}([a-z_]+):[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")"
      set_kv "$key" "$val"
    fi
  done <"$f"
  flush_pending
}
