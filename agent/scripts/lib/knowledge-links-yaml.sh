#!/usr/bin/env bash
# lib/knowledge-links-yaml.sh — 严格清单 YAML 编解码与数组装载。
# 依赖由 knowledge-links.sh 提供；维护模式容错解析仍由 docs-link 自行管理。

# 仅支持本清单的单行 scalar：双引号只解码 \\ 与 \"，单引号双写。
# 不解释裸值中的反斜杠、#、冒号；不执行通用 YAML 或 shell 转义。
_knowledge_link_yaml_scalar_decode() {
  local value="${1-}" result='' char next quote i end
  local LC_ALL=C
  [[ ! "$value" =~ [[:cntrl:]] ]] || return 1
  quote="${value:0:1}"
  if [[ "$quote" != '"' && "$quote" != "'" ]]; then
    printf '%s' "$value"
    return
  fi
  end=$((${#value} - 1))
  ((end >= 1)) && [[ "${value:end:1}" == "$quote" ]] || return 1
  for ((i = 1; i < end; i++)); do
    char="${value:i:1}"
    if [[ "$quote" == '"' && "$char" == \\ ]]; then
      ((i+=1)); ((i < end)) || return 1
      next="${value:i:1}"
      [[ "$next" == \\ || "$next" == '"' ]] || return 1
      result+="$next"
    elif [[ "$char" == "$quote" ]]; then
      [[ "$quote" == "'" ]] || return 1
      ((i+=1)); ((i < end)) && [[ "${value:i:1}" == "'" ]] || return 1
      result+="'"
    else
      result+="$char"
    fi
  done
  printf '%s' "$result"
}

# 兼容旧调用方；严格与维护 loader 均使用同一 codec。
_yaml_unquote() { _knowledge_link_yaml_scalar_decode "${1-}"; }

# 读写目标末段只允许缺席或普通文件；父目录可含合法软链。
knowledge_links_validate_file_target() {
  local file="${1:?}"
  if [[ -L "$file" || ( -e "$file" && ! -f "$file" ) ]]; then
    printf 'knowledge-links.yaml 须为普通文件，拒绝软链或非普通目标: %s\n' "$file" >&2
    return 1
  fi
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
  printf '%srepository: "%s"\n' "$first_prefix" "$(_knowledge_link_yaml_escape_dq "$repo")" || return 1
  printf '    path: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$path")" || return 1
  if [[ -n "$doc_dir" ]]; then
    printf '    dir: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$doc_dir")" || return 1
  fi
}

_knowledge_links_print_name_label() {
  local name="${1:?}" label="${2:?}"
  printf '    name: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$name")" || return 1
  printf '    label: "%s"\n' "$(_knowledge_link_yaml_escape_dq "$label")" || return 1
}

# 覆盖写出 knowledge-links.yaml（type: parent / child / meta）
# child_kind: sys|app|solution；parent_kind: company|solution|sys|none（调用方层别，不写入键名）
# 每条都写 type。type:meta 只写 repository/path/dir（dir=目标 KNOWLEDGE_TYPE，无 name/label）。
# parent/child 再写 name（必填）与 label（缺省等于 name）。dir 空则省略。
# DRY=1 时只打印将写入条数，不落盘
knowledge_links_write_entries() (
  # 独立 subshell 拥有临时文件和 trap，不改变调用方的 umask/退出处理。
  local f="${1:?}"
  local -n _repos="${2:?}" _paths="${3:?}" _dirs="${4:?}"
  local -n _apps="${5:?}" _labels="${6:?}" _types="${7:?}"
  local child_kind="${8:?}" parent_kind="${9:?}"
  local d i n lab t array_name declaration temporary=''
  case "$child_kind" in sys|app|solution) ;; *) error "非法 child_kind: $child_kind"; return 1 ;; esac
  case "$parent_kind" in company|solution|sys|none) ;; *) error "非法 parent_kind: $parent_kind"; return 1 ;; esac
  knowledge_links_validate_file_target "$f" || return 1
  # 数组必须完整、稠密且对齐；空值的必填性在下方按 type 判断。
  for array_name in "$2" "$3" "$4" "$5" "$6" "$7"; do
    declaration="$(declare -p "$array_name" 2>/dev/null)" || return 1
    [[ "$declaration" =~ ^declare\ -[a-zA-Z]*a[a-zA-Z]*\  ]] || { error "清单字段须为索引数组: $array_name"; return 1; }
  done
  n="${#_paths[@]}"
  local -n _field
  for array_name in "$2" "$3" "$4" "$5" "$6" "$7"; do
    local -n _field="$array_name"
    [[ "${#_field[@]}" -eq "$n" ]] || { error "清单数组长度不一致: $array_name"; return 1; }
    for ((i = 0; i < n; i++)); do
      [[ -v "_field[$i]" ]] || { error "清单数组下标不连续: $array_name"; return 1; }
      [[ ! "${_field[i]}" =~ [[:cntrl:]] ]] || { error "清单标量包含控制字符: $array_name [$i]"; return 1; }
    done
  done
  knowledge_links_workspace_for_file "$f" >/dev/null || return 1
  for ((i = 0; i < n; i++)); do
    [[ -n "${_repos[i]}" && -n "${_paths[i]}" ]] || { error "清单条目缺少 repository/path: $f"; return 1; }
    t="${_types[i]}"
    case "$t" in parent|child|meta) ;; *) error "清单条目 type 非法: $t ($f)"; return 1 ;; esac
    [[ "$t" == meta || -n "${_apps[i]}" ]] || { error "清单条目缺少 name: $f"; return 1; }
    knowledge_link_expand_stored_path "${_paths[i]}" "$f" >/dev/null || return 1
  done
  [[ "${DRY:-0}" != 1 ]] || { printf '[dry-run] 将写入 %s（%d 条 links）\n' "$f" "$n" >&2; return 0; }
  d="$(dirname "$f")"
  mkdir -p "$d" || return 1
  d="$(cd "$d" && pwd -P)" || return 1
  f="$d/$(basename "$f")"
  temporary="$(mktemp "$d/.knowledge-links.XXXXXX")" || return 1
  trap '[[ -z "$temporary" ]] || rm -f -- "$temporary"' EXIT
  # 每个打印操作显式检查，调用方即使位于 if/|| 中也不能吞掉写入错误。
  {
    printf '%s\n' '# 知识库建联清单（可由 docs-link.sh / docs-install.sh 维护）' || return 1
    if [[ "$n" -eq 0 ]]; then
      printf '%s\n' 'links: []' || return 1
    else
      printf '%s\n' 'links:' || return 1
      for ((i = 0; i < n; i++)); do
        t="${_types[i]}"
        printf '  - type: %s\n' "$t" || return 1
        _knowledge_links_print_repo_path_docdir '    ' "${_repos[i]}" "${_paths[i]}" "${_dirs[i]}" || return 1
        if [[ "$t" != meta ]]; then
          lab="${_labels[i]:-${_apps[i]}}"
          _knowledge_links_print_name_label "${_apps[i]}" "$lab" || return 1
        fi
      done
    fi
  } >"$temporary" || return 1
  # os.replace 不具备 mv 的“移入目录”行为。末段再次检查，保留旧 mode；新文件 0644。
  python3 - "$temporary" "$f" <<'PY_REPLACE'
import os, stat, sys
source, target = sys.argv[1:]
try:
    mode = 0o644
    try:
        current = os.lstat(target)
    except FileNotFoundError:
        pass
    else:
        if not stat.S_ISREG(current.st_mode):
            raise OSError("清单目标不再是普通文件")
        mode = stat.S_IMODE(current.st_mode)
    os.chmod(source, mode)
    os.replace(source, target)
except OSError as exc:
    print(f"knowledge-links 原子替换失败: {exc}", file=sys.stderr)
    sys.exit(1)
PY_REPLACE
  local status=$?
  ((status == 0)) || return "$status"
  temporary=''
)

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

  knowledge_links_validate_file_target "$f" || return 1
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
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")" || { error "knowledge-links.yaml 标量非法: $f ($key)"; return 1; }
      flush_pending || return 1
      set_kv "$key" "$val"
    elif [[ "$line" =~ ^[[:space:]]{4}([a-z_]+):[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")" || { error "knowledge-links.yaml 标量非法: $f ($key)"; return 1; }
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
