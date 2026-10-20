#!/usr/bin/env bash
#
# lib/knowledge-links.sh — knowledge-links.yaml 读写
# 依赖：Python 3、lib/path.sh、lib/log-io.sh、lib/docsconfig.sh、lib/git-remote.sh
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

# shellcheck source=bash.sh
source "${_LIB_DIR}/bash.sh"

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

# 每份清单从所属库配置解析工作区；不读取环境中的 WORK_SPACE。
knowledge_links_workspace_for_file() {
  local f="${1:?}" owner cfg rd='' dd='' ar='' kt='' ad=''
  owner="$(dirname "$(abs_path "$f")")"
  while [[ ! -f "$owner/.docsconfig" ]]; do
    [[ "$owner" != / ]] || { error "knowledge-links 缺少所属库 .docsconfig: $f"; return 1; }
    owner="$(dirname "$owner")"
  done
  cfg="$owner/.docsconfig"
  docsconfig_read_into "$cfg" rd dd ar kt ad || return 1
  [[ -n "$ar" && -n "$ad" ]] || { error "knowledge-links 配置缺少 AGENT_ROOT/AGENT_DIR: $cfg"; return 1; }
  docsconfig_load_workspace_abs "$ar" "$ad"
}

# 规范化真实路径（含尚不存在的 clone 目标），校验目录边界和符号链接。
_knowledge_link_relative_to_workspace() {
  python3 - "$1" "$2" "${3:-relative}" <<'PY_PATH'
import sys
from pathlib import Path
try:
    target = Path(sys.argv[1]).expanduser().resolve()
    workspace = Path(sys.argv[2]).expanduser().resolve()
    relative = target.relative_to(workspace)
    print(target if sys.argv[3] == "absolute" else relative.as_posix())
except (ValueError, OSError, RuntimeError) as exc:
    print(f"knowledge-links: path 必须位于 WORK_SPACE 内: {sys.argv[1]} ({exc})", file=sys.stderr)
    sys.exit(1)
PY_PATH
}

knowledge_links_validate_stored_path_field() {
  local p="${1:?}" src="${2:?}"
  if knowledge_link_value_looks_like_git_remote "$p"; then
    error "knowledge-links.yaml: path 不得为远程 URL；远端请写入 repository: $src"
    return 1
  fi
  case "$p" in
    '${WORK_SPACE}'|'${WORK_SPACE}/'*) ;;
    *) error "knowledge-links.yaml: path 必须使用字面量 \${WORK_SPACE}/…，请迁移旧路径: $src"; return 1 ;;
  esac
}

knowledge_link_expand_stored_path() {
  local p="${1:?}" f="${2:?knowledge-links 文件路径必填}" ws suffix
  knowledge_links_validate_stored_path_field "$p" "$f" || return 1
  ws="$(knowledge_links_workspace_for_file "$f")" || return 1
  suffix="${p#'${WORK_SPACE}'}"
  _knowledge_link_relative_to_workspace "${ws%/}/${suffix#/}" "$ws" absolute
}

_knowledge_link_store_with_workspace() {
  local rel
  rel="$(_knowledge_link_relative_to_workspace "${1:?}" "${2:?}")" || return 1
  if [[ "$rel" == . ]]; then
    printf '%s\n' '${WORK_SPACE}'
  else
    printf '${WORK_SPACE}/%s\n' "$rel"
  fi
}

# 写入只生成 WORK_SPACE 占位符；第二参数为接收此 path 的清单。
knowledge_link_stored_path_from_absolute() {
  local ws
  ws="$(knowledge_links_workspace_for_file "${2:?knowledge-links 文件路径必填}")" || return 1
  _knowledge_link_store_with_workspace "${1:?}" "$ws"
}

_knowledge_link_yaml_escape_dq() {
  local s="${1-}"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

# 打印 repository/path/dir；first_prefix 为首行前缀，续行固定四空格。dir 空则省略。
_knowledge_links_print_repo_path_docdir() {
  local first_prefix="${1:?}" repo="${2:?}" path="${3:?}" doc_dir="${4:-}"
  printf '%srepository: "%s"\n' "$first_prefix" "$(_knowledge_link_yaml_escape_dq "$repo")"
  printf '    path: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$path")"
  if [[ -n "$doc_dir" ]]; then
    printf '    dir: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$doc_dir")"
  fi
}

_knowledge_links_print_name_label() {
  local name="${1:?}" label="${2:?}"
  printf '    name: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$name")"
  printf '    label: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$label")"
}

# 覆盖写出 knowledge-links.yaml（type: parent / child / meta）
# child_kind: sys|app|solution；parent_kind: company|solution|sys|none（调用方层别，不写入键名）
# 每条都写 type。type:meta 只写 repository/path/dir（dir=目标 KNOWLEDGE_TYPE，无 name/label）。
# parent/child 再写 name（必填）与 label（缺省等于 name）。dir 空则省略。
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
  local d i n lab t
  d="$(dirname "$f")"
  n="${#_paths[@]}"
  case "$child_kind" in
    sys|app|solution) ;;
    *) error "knowledge_links_write_entries: child_kind 须为 sys|app|solution（收到: ${child_kind})" ;;
  esac
  case "$parent_kind" in
    company|solution|sys|none) ;;
    *) error "knowledge_links_write_entries: parent_kind 须为 company|solution|sys|none（收到: ${parent_kind})" ;;
  esac
  # path 验证后才打开目标文件，避免越界路径留下半份清单。
  knowledge_links_workspace_for_file "$f" >/dev/null || return 1
  for ((i = 0; i < n; i++)); do
    knowledge_link_expand_stored_path "${_paths[i]}" "$f" >/dev/null || return 1
  done
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
        case "$t" in
          parent|child|meta) ;;
          *) error "knowledge-links.yaml 条目 type 非法: ${t}（仅 parent、child、meta）: $f" ;;
        esac
        printf '  - type: %s\n' "$t"
        _knowledge_links_print_repo_path_docdir '    ' "${_repos[i]}" "${_paths[i]}" "${_dirs[i]:-}"
        if [[ "$t" != 'meta' ]]; then
          [[ -n "${_apps[i]:-}" ]] || error "knowledge-links.yaml(${t}) 条目缺少 name（必填）: $f"
          lab="${_labels[i]:-${_apps[i]}}"
          _knowledge_links_print_name_label "${_apps[i]}" "$lab"
        fi
      done
    fi
  } >"$f"
}

# 读入 knowledge-links.yaml 填入数组（下标对齐）；path=URL 或旧键/缺 type/非法 type 时报错退出。
# 第 7 参 types：每条 type（parent / child / meta）。缺 type 拒绝，不默认 child。
# 旧键 doc_dir、*_name、*_label 整文件收集后一次报错。其他未知键跳过。
knowledge_links_load_into_arrays() {
  local f="${1:?}"
  local -n _paths="${2:?}"
  local -n _repos="${3:?}"
  local -n _dirs="${4:?}"
  local -n _apps="${5:?}"
  local -n _labels="${6:?}"
  local -n _types="${7:?}"
  local line key val path="" repo="" doc_dir="" link_name="" link_label="" entry_type=""
  local -a _errs=()
  local err_text err_line

  _paths=()
  _repos=()
  _dirs=()
  _apps=()
  _labels=()
  _types=()

  [[ -f "$f" ]] || return 0
  knowledge_links_workspace_for_file "$f" >/dev/null || return 1

  flush_pending() {
    local bad=0
    if [[ -z "$path$repo$doc_dir$link_name$link_label$entry_type" ]]; then
      path='' repo='' doc_dir='' link_name='' link_label='' entry_type=''
      return 0
    fi
    if [[ -z "$entry_type" ]]; then
      _errs+=("条目缺少 type（须为 parent、child 或 meta）")
      bad=1
    elif [[ "$entry_type" != 'parent' && "$entry_type" != 'child' && "$entry_type" != 'meta' ]]; then
      _errs+=("type 非法: ${entry_type}（仅 parent、child、meta）")
      bad=1
    fi
    if [[ -z "$path" ]]; then
      _errs+=("条目缺少 path")
      bad=1
    fi
    if [[ "$bad" -eq 0 ]]; then
      knowledge_link_expand_stored_path "$path" "$f" >/dev/null || return 1
      _paths+=("$path")
      _repos+=("${repo:-}")
      _dirs+=("${doc_dir:-}")
      _types+=("$entry_type")
      if [[ "$entry_type" == 'meta' ]]; then
        _apps+=('')
        _labels+=('')
      else
        _apps+=("${link_name:-}")
        _labels+=("${link_label:-}")
      fi
    fi
    path='' repo='' doc_dir='' link_name='' link_label='' entry_type=''
  }

  set_kv() {
    case "${1:?}" in
      path) path="$2" ;;
      repository) repo="$2" ;;
      dir) doc_dir="$2" ;;
      type) entry_type="$2" ;;
      name) link_name="$2" ;;
      label) link_label="$2" ;;
      doc_dir) _errs+=("doc_dir → dir") ;;
      app_name|sys_name|company_name|solution_name) _errs+=("$1 → name") ;;
      app_label|sys_label|company_label|solution_label) _errs+=("$1 → label") ;;
      *) ;;
    esac
  }

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+([a-z_]+):[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")"
      flush_pending || return 1
      set_kv "$key" "$val"
    elif [[ "$line" =~ ^[[:space:]]{4}([a-z_]+):[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")"
      set_kv "$key" "$val"
    fi
  done <"$f"
  flush_pending || return 1
  if [[ ${#_errs[@]} -gt 0 ]]; then
    err_text="knowledge-links.yaml 拒绝旧键或非法 type: $f"
    for err_line in "${_errs[@]}"; do
      err_text+=$'\n'"  ${err_line}"
    done
    error "$err_text"
  fi
}
