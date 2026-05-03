#!/usr/bin/env bash
# docs-link.sh — 在源知识库登记 / 注销目标知识库（repository + path + doc_dir + app_name + app_label）
# application 建联时 app_name：--app-name > 登记文件已有 > Git 仓库根目录名推断
# 同一 target 重复 link：合并更新同一条记录，不追加重复行
# 用法: ./scripts/docs-link.sh --link|--unlink --target <目标仓库根> [--app-name=名] [--dry-run]
# 须在源 Git 仓库内执行；link 需校验源、目标 .docsconfig 与 KNOWLEDGE_TYPE；
# unlink 支持目标失联场景（按登记 identity 注销）；system 源注销 application 建联时先将
# DOC_ROOT 下 application-<APPNAME>/ 备份至 REPO_ROOT/.docs-init/<时间戳>/（与 docs-install 一致）再移除。
# 登记值：repository 存 Git remote URL（有 remote 时）；path 存本机路径（在 $HOME 下为相对 $HOME，
#       否则为规范化绝对路径）。path 不得为 URL 形态（须写在 repository）。不兼容旧版仅 path=URL 的 YAML。
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./link-config.sh
source "${SCRIPT_DIR}/link-config.sh"

# =============================================================================
# knowledge-links.yaml
# =============================================================================

# 去除 YAML 字段值两端的单/双引号
_yaml_unquote() {
  local v="${1:-}"
  v="${v#\"}"; v="${v%\"}"
  v="${v#\'}"; v="${v%\'}"
  printf '%s' "$v"
}

# path 字段禁止为远程 URL 形态（须写在 repository）
knowledge_links_validate_stored_path_field() {
  local p="${1:?}" src="${2:?}"
  [[ -n "$p" ]] || sdx_error "knowledge-links.yaml 条目缺少 path 或 path 为空: $src"
  if [[ "$p" =~ ^(git@|ssh://|https://|http://) ]]; then
    sdx_error "knowledge-links.yaml: path 不得为远程 URL（已废弃）。请将远端写入 repository，path 改为相对 \$HOME 或本机绝对路径: $src"
  fi
}

# 将绝对仓库根路径转为写入 knowledge-links 的 path（$HOME 下为相对 $HOME，否则绝对路径）
knowledge_link_stored_path_from_absolute() {
  local abs="${1:?}" home_abs r
  abs="$(cd -P "$abs" 2>/dev/null && pwd)" || {
    printf '%s\n' "$abs"
    return 0
  }
  home_abs="${HOME:-}"
  [[ -n "$home_abs" ]] && home_abs="$(cd -P "$home_abs" 2>/dev/null && pwd)" || home_abs=''
  [[ -z "$home_abs" ]] && {
    printf '%s\n' "$abs"
    return 0
  }
  if [[ "$abs" == "$home_abs" ]]; then
    printf '%s\n' '.'
    return 0
  fi
  if [[ "$abs" == "$home_abs/"* ]]; then
    r="${abs#"${home_abs}"/}"
    printf '%s\n' "$r"
    return 0
  fi
  printf '%s\n' "$abs"
}

# 将登记 path 展开为绝对路径（相对 $HOME 的 path 会拼 $HOME）
knowledge_link_expand_stored_path() {
  local p="${1:?}" home
  if [[ "$p" == /* ]]; then
    abs_path "$p"
    return 0
  fi
  home="${HOME:-}"
  [[ -n "$home" ]] || sdx_error "未设置 HOME，无法展开相对 path: $p"
  abs_path "${home%/}/$p"
}

# 读入 knowledge-links.yaml 填入数组（下标对齐）；非法旧形态 path=URL 时报错退出
knowledge_links_load_into_arrays() {
  local f="${1:?}"
  local -n _paths="${2:?}"
  local -n _repos="${3:?}"
  local -n _dirs="${4:?}"
  local -n _apps="${5:?}"
  local -n _labels="${6:?}"
  local line key val path="" repo="" doc_dir="" app_name="" app_label=""

  _paths=()
  _repos=()
  _dirs=()
  _apps=()
  _labels=()

  [[ -f "$f" ]] || return 0

  knowledge_links__flush_pending() {
    if [[ -n "$path" ]]; then
      knowledge_links_validate_stored_path_field "$path" "$f"
      _paths+=("$path")
      _repos+=("${repo:-}")
      _dirs+=("${doc_dir:-}")
      _apps+=("${app_name:-}")
      _labels+=("${app_label:-}")
    elif [[ -n "$repo$doc_dir$app_name$app_label" ]]; then
      sdx_error "knowledge-links.yaml 中存在未写完的条目（有 repository/doc_dir/app_name/app_label 但缺少 path）: $f"
    fi
    path=''
    repo=''
    doc_dir=''
    app_name=''
    app_label=''
  }

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+([a-z_]+):[[:space:]]*(.*)$ ]]; then
      knowledge_links__flush_pending
      key="${BASH_REMATCH[1]}"
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")"
      case "$key" in
        path) path="$val" ;;
        repository) repo="$val" ;;
        doc_dir) doc_dir="$val" ;;
        app_name) app_name="$val" ;;
        app_label) app_label="$val" ;;
        *) ;;
      esac
    elif [[ "$line" =~ ^[[:space:]]{4}([a-z_]+):[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="$(_yaml_unquote "${BASH_REMATCH[2]}")"
      case "$key" in
        path) path="$val" ;;
        repository) repo="$val" ;;
        doc_dir) doc_dir="$val" ;;
        app_name) app_name="$val" ;;
        app_label) app_label="$val" ;;
        *) ;;
      esac
    fi
  done <"$f"
  knowledge_links__flush_pending
}

# 覆盖写出 knowledge-links.yaml（repository、path、doc_dir、app_name、app_label 数组下标对齐）
knowledge_links_write_quads() {
  local f="${1:?}"
  local -n _repos="${2:?}"
  local -n _paths="${3:?}"
  local -n _dirs="${4:?}"
  local -n _apps="${5:?}"
  local -n _labels="${6:?}"
  local d i n lab
  d="$(dirname "$f")"
  n="${#_paths[@]}"
  [[ "$DRY" == '1' ]] && { printf '[dry-run] 将写入 %s（%d 条 links）\n' "$f" "$n" >&2; return 0; }
  mkdir -p "$d"
  umask 022
  {
    printf '%s\n' '# 知识库建联清单（可由 docs-link.sh 维护）'
    printf '%s\n' 'links:'
    for ((i = 0; i < n; i++)); do
      if [[ -n "${_repos[i]:-}" ]]; then
        printf '  - repository: "%s"\n' "${_repos[i]//\"/\\\"}"
        printf '    path: "%s"\n' "${_paths[i]//\"/\\\"}"
      else
        printf '  - path: "%s"\n' "${_paths[i]//\"/\\\"}"
      fi
      if [[ -n "${_dirs[i]:-}" ]]; then
        printf '    doc_dir: "%s"\n' "${_dirs[i]//\"/\\\"}"
      fi
      if [[ -n "${_apps[i]:-}" ]]; then
        printf '    app_name: "%s"\n' "${_apps[i]//\"/\\\"}"
        lab="${_labels[i]:-${_apps[i]}}"
        printf '    app_label: "%s"\n' "${lab//\"/\\\"}"
      fi
    done
  } >"$f"
}

# -----------------------------------------------------------------------------
# 登记 path：Git 优先 remote URL，否则仓库根路径 / 文件系统路径
# -----------------------------------------------------------------------------

# 打印 origin 或第一个可用的 remote URL；若无则返回 1 且无输出
knowledge_link_git_remote_url_prefer_origin() {
  local top="${1:?}" url r
  url="$(git -C "$top" remote get-url origin 2>/dev/null || true)"
  [[ -n "$url" ]] && { printf '%s\n' "$url"; return 0; }
  while IFS= read -r r; do
    [[ -z "$r" ]] && continue
    url="$(git -C "$top" remote get-url "$r" 2>/dev/null || true)"
    [[ -n "$url" ]] && { printf '%s\n' "$url"; return 0; }
  done < <(git -C "$top" remote 2>/dev/null)
  return 1
}

# 给定已存在的本地目录：得到与 link 时一致的登记字符串（用于去重 / unlink）
knowledge_link_register_value_from_dir() {
  local dir="${1:?}" resolved top url
  resolved="$(cd -P "$dir" 2>/dev/null && pwd)" || {
    printf '%s\n' "$dir"
    return 0
  }
  if ! git -C "$resolved" rev-parse --is-inside-work-tree &>/dev/null; then
    printf '%s\n' "$resolved"
    return 0
  fi
  top="$(git -C "$resolved" rev-parse --show-toplevel 2>/dev/null)" || {
    printf '%s\n' "$resolved"
    return 0
  }
  url="$(knowledge_link_git_remote_url_prefer_origin "$top" || true)"
  if [[ -n "$url" ]]; then
    printf '%s\n' "$(strip_trailing_slash "$url")"
    return 0
  fi
  printf '%s\n' "$(strip_trailing_slash "$top")"
}

# 将「用户传入的 --target」规范为与已登记项可比对的身份串
knowledge_link_identity_from_raw_target() {
  local raw="${1:?}" p
  if [[ "$raw" =~ ^(git@|ssh://|https://|http://) ]]; then
    printf '%s\n' "$(strip_trailing_slash "$raw")"
    return 0
  fi
  p="$(normalize_target_repo_root "$raw")" || return 1
  if [[ -d "$p" ]]; then
    knowledge_link_register_value_from_dir "$p"
  else
    printf '%s\n' "$(strip_trailing_slash "$p")"
  fi
}

# 将「已登记的一条 repository + path」规范为身份串（与 REGISTER_KEY / --target 比对）
knowledge_link_identity_from_stored_entry() {
  local repo="${1:-}" stored_path="${2:?}"
  local exp
  if [[ -n "$repo" ]]; then
    printf '%s\n' "$(strip_trailing_slash "$repo")"
    return 0
  fi
  exp="$(knowledge_link_expand_stored_path "$stored_path")"
  if [[ -d "$exp" ]]; then
    knowledge_link_register_value_from_dir "$exp"
  else
    printf '%s\n' "$(strip_trailing_slash "$exp")"
  fi
}

# -----------------------------------------------------------------------------
# 应用槽位 application-${APPNAME}（自 DOC_ROOT 下 application-APPNAME 模板生成）
# -----------------------------------------------------------------------------

# 校验并规范化 app_name（小写）；非法则报错
knowledge_link_validate_app_name() {
  local raw="${1:?}" base
  base="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
  [[ -n "$base" ]] || {
    printf '错误: app_name 不能为空\n' >&2
    return 1
  }
  if [[ ! "$base" =~ ^[a-z0-9][a-z0-9_.-]*$ ]]; then
    printf '错误: 非法 app_name: %s（仅允许 a-z0-9._-）\n' "$raw" >&2
    return 1
  fi
  printf '%s\n' "$base"
}

# 从目标仓库根推断应用标识：优先 Git 仓库根目录名，否则为路径 basename（无用户指定时用）
knowledge_link_guess_app_name() {
  local root="${1:?}" top base
  if git -C "$root" rev-parse --show-toplevel &>/dev/null; then
    top="$(git -C "$root" rev-parse --show-toplevel)"
    base="$(basename "$top")"
  else
    base="$(basename "$(cd -P "$root" 2>/dev/null && pwd)")"
  fi
  knowledge_link_validate_app_name "$base"
}

# 将模板目录中的占位符替换为实际 APPNAME（仅处理常见文本后缀）
knowledge_link_apply_app_slot_substitutions() {
  local dest="${1:?}" app="${2:?}" f tmp
  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    case "$f" in
      *.md|*.yaml|*.yml) ;;
      *) continue ;;
    esac
    tmp="${f}.tmp.$$"
    sed \
      -e "s/CHANGE LOG - APPNAME/CHANGE LOG - ${app}/g" \
      -e "s/application-{app-name}/application-${app}/g" \
      -e "s/{app-name}/${app}/g" \
      -e "s/\`APPNAME\`/\`${app}\`/g" \
      "$f" >"$tmp" && mv "$tmp" "$f"
  done < <(find "$dest" -type f 2>/dev/null)
}

# 在源 DOC_ROOT 下生成 application-${APPNAME}（参考 application-APPNAME 模板）
knowledge_link_ensure_application_slot() {
  local doc_root="${1:?}" app="${2:?}"
  local tpl dest
  tpl="$(strip_trailing_slash "$(abs_path "$doc_root")")/application-APPNAME"
  dest="$(strip_trailing_slash "$(abs_path "$doc_root")")/application-${app}"
  [[ -d "$tpl" ]] || sdx_error "源 DOC_ROOT 下缺少模板目录: $tpl"
  if [[ -d "$dest" ]]; then
    return 0
  fi
  if [[ "$DRY" == '1' ]]; then
    sdx_log "[dry-run] 将自模板创建目录: %s → %s" "$tpl" "$dest"
    return 0
  fi
  cp -R "$tpl" "$dest"
  knowledge_link_apply_app_slot_substitutions "$dest" "$app"
}

# 从已登记的 path（URL 或本地路径）推断 APPNAME，供旧数据或无 app_name 字段时 unlink 删槽位
knowledge_link_app_name_from_register_key() {
  local key="${1:?}" base
  if [[ -d "$key" ]]; then
    knowledge_link_guess_app_name "$key"
    return
  fi
  base="${key##*/}"
  base="${base%.git}"
  base="${base%%\?*}"
  base="${base%%#*}"
  base="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')"
  [[ -n "$base" ]] || return 1
  [[ "$base" =~ ^[a-z0-9][a-z0-9_.-]*$ ]] || return 1
  printf '%s\n' "$base"
}

# 解析工程根（与 docs-install 写入 .docsconfig 的 REPO_ROOT 推导一致，供 .docs-init 备份路径）
knowledge_link_repo_root_for_backup() {
  local doc_root="${1:?}" dr rr
  dr="$(strip_trailing_slash "$(abs_path "$doc_root")")"
  rr="$(docsconfig_repo_root_from_doc_root "$dr")"
  [[ -n "$rr" ]] || rr="$(docsconfig_repo_root_fallback_from_doc_root "$dr")"
  [[ -n "$rr" ]] || return 1
  printf '%s\n' "$(strip_trailing_slash "$rr")"
}

# 备份至 REPO_ROOT/.docs-init/<stamp>/ 后移除 application-${app}/（与 docs-install 的 backup_path 同源：sdx_docs_backup_path_to_init）
knowledge_link_remove_application_slot() {
  local doc_root="${1:?}" app="${2:?}"
  local dest repo_root
  [[ -n "$app" ]] || return 0
  if [[ "$app" == 'APPNAME' ]]; then
    sdx_warn "APPNAME 为保留名，跳过删除槽位目录"
    return 0
  fi
  dest="$(strip_trailing_slash "$(abs_path "$doc_root")")/application-${app}"
  if [[ ! -d "$dest" ]]; then
    return 0
  fi
  repo_root="$(knowledge_link_repo_root_for_backup "$doc_root")" || {
    sdx_warn "无法解析 REPO_ROOT，跳过备份，将直接删除: $dest"
    if [[ "$DRY" == '1' ]]; then
      sdx_log "[dry-run] 将删除目录: $dest"
      return 0
    fi
    rm -rf "$dest"
    sdx_info "已删除槽位目录: $dest"
    return 0
  }
  sdx_docs_backup_path_to_init "$repo_root" "$dest" "" "$DRY"
}

# =============================================================================
# CLI
# =============================================================================

DRY="${KLINK_DEFAULT_DRY_RUN}"
CMD=''
TARGET_RAW=''
CLI_APP_NAME=''

usage() {
  cat >&2 <<'EOF'
用法: ./scripts/docs-link.sh --link|--unlink --target <目标知识库仓库根> [--app-name 名] [--dry-run]

  --link / --unlink 二选一，不得同时出现。

  须在「源」知识库 Git 仓库内执行（git rev-parse 取根）。登记文件：源 .docsconfig 的 DOC_ROOT/knowledge-links.yaml

  允许边：company→system、system→application（源/目标 .docsconfig 须含合法 KNOWLEDGE_TYPE）。
  unlink 支持目标失联（路径不存在或目标仓库配置缺失）时按登记 identity 注销。

  --dry-run     仅打印将执行的操作，不写文件。
  --target      目标知识库仓库根（或已登记的 remote URL）；兼容旧参数 --path（已弃用）。
  --app-name    仅 system→application 建联有效：显式指定 YAML 中的 app_name 及槽位目录名。
                若省略：登记文件中该 path 已有 app_name 则沿用、不再推断；否则由目标本地 Git 仓库根目录名推断。
  每条 link 记录：repository（有 Git remote 时）、path（本机相对 \$HOME 或绝对路径）、doc_dir、application 时的 app_name 与 app_label（脚本写入时 app_label 默认等于 app_name）。
  system→application：在源 DOC_ROOT 下自 application-APPNAME 模板生成 application-<APPNAME>/（已存在则跳过）。
  同一 target 重复 link：不新增行，只更新已存在且 identity 相同的那条记录。
  unlink 时：注销该条目的同时将 application-<APPNAME>/ 备份到工程根 .docs-init/ 再移除（若目录存在）。

示例:
  ./scripts/docs-link.sh --target ~/workspaces/target-repo --link
  ./scripts/docs-link.sh --target ~/workspaces/target-repo --link --app-name=my-app
  ./scripts/docs-link.sh --target ~/workspaces/target-repo --unlink --dry-run
EOF
}

while (( $# > 0 )); do
  case "$1" in
    --link)
      [[ "$CMD" == 'unlink' ]] && sdx_error "不能同时指定 --link 与 --unlink"
      [[ "$CMD" == 'link' ]] && sdx_error "重复指定 --link"
      CMD='link'
      shift
      ;;
    --unlink)
      [[ "$CMD" == 'link' ]] && sdx_error "不能同时指定 --link 与 --unlink"
      [[ "$CMD" == 'unlink' ]] && sdx_error "重复指定 --unlink"
      CMD='unlink'
      shift
      ;;
    --dry-run)   DRY=1; shift ;;
    --app-name=*)
      CLI_APP_NAME="${1#*=}"
      shift
      ;;
    --app-name)
      shift
      [[ -n "${1:-}" ]] || sdx_error "缺少 --app-name 值"
      CLI_APP_NAME="$1"
      shift
      ;;
    --target=*)  TARGET_RAW="${1#*=}"; shift ;;
    --target)
      shift
      [[ -n "${1:-}" ]] || sdx_error "缺少 --target 值"
      TARGET_RAW="$1"
      shift
      ;;
    --path=*)
      TARGET_RAW="${1#*=}"
      sdx_warn "--path 已弃用，请改用 --target"
      shift
      ;;
    --path)
      shift
      [[ -n "${1:-}" ]] || sdx_error "缺少 --path 值"
      TARGET_RAW="$1"
      sdx_warn "--path 已弃用，请改用 --target"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) sdx_error "未知参数: $1" ;;
  esac
done

validate_link_command "$CMD" || sdx_error "请指定 --link 或 --unlink（二选一）"
[[ -n "$TARGET_RAW" ]] || sdx_error "请指定 --target <目标仓库根>（仍兼容 --target=PATH）"

SRC_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || sdx_error "请在 Git 仓库内执行 docs-link"
SRC_CFG="$SRC_ROOT/.docsconfig"
[[ -f "$SRC_CFG" ]] || sdx_error "源仓库缺少 .docsconfig: $SRC_CFG"

_sdoc='' _srepo='' _sdd='' _skt=''
docsconfig_read_into "$SRC_CFG" _sdoc _srepo _sdd _skt || sdx_error "无法解析源 .docsconfig"
[[ -n "$_sdoc" ]] || sdx_error "源 .docsconfig 缺少 DOC_ROOT"
[[ -n "$_skt" ]] || sdx_error "源 .docsconfig 缺少 KNOWLEDGE_TYPE"
docsconfig_validate_knowledge_type "$_skt" || exit 1

expect_target=''
LIST_FILE="$_sdoc/knowledge-links.yaml"
case "$_skt" in
  company) expect_target='system' ;;
  system)  expect_target='application' ;;
  *) sdx_error "源 KNOWLEDGE_TYPE=${_skt} 不支持建联（仅 company 或 system 可作为源）" ;;
esac

TARGET_KEY="$(normalize_target_repo_root "$TARGET_RAW")" || sdx_error "目标路径非法: $TARGET_RAW"
REGISTER_KEY=''
REGISTER_REPO=''
REGISTER_PATH_STORED=''
TARGET_DOC_DIR=''
TARGET_APP_NAME=''
TARGET_APP_LABEL=''
matched_idx=-1

if [[ "$CMD" == 'link' ]]; then
  TGT_ROOT="$(cd -P "$TARGET_KEY" 2>/dev/null && pwd)" || sdx_error "目标路径不存在或不可进入: $TARGET_KEY"
  TGT_CFG="$TGT_ROOT/.docsconfig"
  [[ -f "$TGT_CFG" ]] || sdx_error "目标仓库缺少 .docsconfig: $TGT_CFG"

  _tdoc='' _trepo='' _tdd='' _tkt=''
  docsconfig_read_into "$TGT_CFG" _tdoc _trepo _tdd _tkt || sdx_error "无法解析目标 .docsconfig"
  [[ -n "$_tkt" ]] || sdx_error "目标 .docsconfig 缺少 KNOWLEDGE_TYPE"
  docsconfig_validate_knowledge_type "$_tkt" || exit 1
  [[ "$_tkt" == "$expect_target" ]] || sdx_error "目标须为 ${expect_target} 知识库（KNOWLEDGE_TYPE=${_tkt}）"
  REGISTER_KEY="$(knowledge_link_register_value_from_dir "$TGT_ROOT")"
  TARGET_DOC_DIR="${_tdd:-}"
  _url="$(knowledge_link_git_remote_url_prefer_origin "$TGT_ROOT" || true)"
  [[ -n "$_url" ]] && REGISTER_REPO="$(strip_trailing_slash "$_url")"
  REGISTER_PATH_STORED="$(knowledge_link_stored_path_from_absolute "$TGT_ROOT")"
else
  REGISTER_KEY="$(knowledge_link_identity_from_raw_target "$TARGET_RAW")" || sdx_error "目标路径非法: $TARGET_RAW"
  [[ -z "$CLI_APP_NAME" ]] || sdx_warn "--app-name 仅在 --link 时有效，已忽略"
fi

declare -a repos=() paths=() doc_dirs=() app_names=() app_labels=()
knowledge_links_load_into_arrays "$LIST_FILE" paths repos doc_dirs app_names app_labels

have=0
new_identity="${REGISTER_KEY}"
for i in "${!paths[@]}"; do
  if [[ "$(knowledge_link_identity_from_stored_entry "${repos[i]:-}" "${paths[i]}")" == "$new_identity" ]]; then
    have=1
    matched_idx=$i
    break
  fi
done

# application 槽位：app_name 优先级为 --app-name > 登记文件中已有 app_name > Git 路径推断
if [[ "$CMD" == 'link' && "$expect_target" == 'application' ]]; then
  if [[ -n "$CLI_APP_NAME" ]]; then
    TARGET_APP_NAME="$(knowledge_link_validate_app_name "$CLI_APP_NAME")" || exit 1
  elif [[ "$have" -eq 1 && "$matched_idx" -ge 0 && -n "${app_names[matched_idx]:-}" ]]; then
    TARGET_APP_NAME="$(knowledge_link_validate_app_name "${app_names[matched_idx]}")" || exit 1
  else
    TARGET_APP_NAME="$(knowledge_link_guess_app_name "$TGT_ROOT")" || exit 1
  fi
  knowledge_link_ensure_application_slot "$_sdoc" "$TARGET_APP_NAME"
  [[ -n "$TARGET_APP_NAME" ]] && TARGET_APP_LABEL="$TARGET_APP_NAME"
elif [[ "$CMD" == 'link' && "$expect_target" != 'application' && -n "$CLI_APP_NAME" ]]; then
  sdx_warn "--app-name 仅用于 system→application 建联，已忽略"
fi

case "$CMD" in
  link)
    link_is_update=$have
    if [[ "$have" -eq 1 ]]; then
      repos[matched_idx]="$REGISTER_REPO"
      paths[matched_idx]="$REGISTER_PATH_STORED"
      doc_dirs[matched_idx]="$TARGET_DOC_DIR"
      app_names[matched_idx]="${TARGET_APP_NAME:-}"
      app_labels[matched_idx]="${TARGET_APP_LABEL:-}"
    else
      repos+=("$REGISTER_REPO")
      paths+=("$REGISTER_PATH_STORED")
      doc_dirs+=("$TARGET_DOC_DIR")
      app_names+=("${TARGET_APP_NAME:-}")
      app_labels+=("${TARGET_APP_LABEL:-}")
    fi
    knowledge_links_write_quads "$LIST_FILE" repos paths doc_dirs app_names app_labels
    _link_verb='已登记'; [[ "$link_is_update" -eq 1 ]] && _link_verb='已更新登记'
    _link_info=''
    if [[ -n "$TARGET_APP_NAME" && -n "$TARGET_DOC_DIR" ]]; then
      _link_info=" (doc_dir=${TARGET_DOC_DIR}, application-${TARGET_APP_NAME})"
    elif [[ -n "$TARGET_APP_NAME" ]]; then
      _link_info=" (application-${TARGET_APP_NAME})"
    elif [[ -n "$TARGET_DOC_DIR" ]]; then
      _link_info=" (doc_dir=${TARGET_DOC_DIR})"
    fi
    _loc=''
    [[ -n "$REGISTER_REPO" ]] && _loc=" repository=${REGISTER_REPO}"
    _loc="${_loc} path=${REGISTER_PATH_STORED}"
    printf '%s: %s → identity=%s%s%s\n' "$_link_verb" "$LIST_FILE" "$REGISTER_KEY" "$_loc" "$_link_info"
    ;;
  unlink)
    [[ "$have" -eq 0 ]] && { printf '提示: 未找到登记项，跳过: %s\n' "$REGISTER_KEY" >&2; exit 0; }
    UNLINK_APP_NAME=''
    if [[ "$matched_idx" -ge 0 && "$_skt" == 'system' ]]; then
      UNLINK_APP_NAME="${app_names[matched_idx]:-}"
      if [[ -z "$UNLINK_APP_NAME" ]]; then
        if [[ -n "${repos[matched_idx]:-}" ]]; then
          UNLINK_APP_NAME="$(knowledge_link_app_name_from_register_key "${repos[matched_idx]}")" || UNLINK_APP_NAME=''
        else
          _exp="$(knowledge_link_expand_stored_path "${paths[matched_idx]}")"
          UNLINK_APP_NAME="$(knowledge_link_app_name_from_register_key "$_exp")" || UNLINK_APP_NAME=''
        fi
      fi
    fi
    declare -a newr=() newp=() newd=() newa=() newl=()
    for i in "${!paths[@]}"; do
      [[ "$(knowledge_link_identity_from_stored_entry "${repos[i]:-}" "${paths[i]}")" == "$new_identity" ]] && continue
      newr+=("${repos[i]:-}")
      newp+=("${paths[i]}")
      newd+=("${doc_dirs[i]:-}")
      newa+=("${app_names[i]:-}")
      newl+=("${app_labels[i]:-}")
    done
    knowledge_links_write_quads "$LIST_FILE" newr newp newd newa newl
    if [[ -n "$UNLINK_APP_NAME" ]]; then
      knowledge_link_remove_application_slot "$_sdoc" "$UNLINK_APP_NAME"
    fi
    printf '已注销: %s 中的 %s\n' "$LIST_FILE" "$REGISTER_KEY"
    ;;
esac
