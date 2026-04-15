#!/usr/bin/env bash
# docs-link.sh — 在源知识库登记 / 注销目标知识库（path + 目标 DOC_DIR + app_name）
# application 建联时 app_name：--app-name > 登记文件已有 > Git 仓库根目录名推断
# 同一 target 重复 link：合并更新同一条记录，不追加重复 path
# 用法: ./scripts/docs-link.sh --link|--unlink --target=<目标仓库根> [--app-name=名] [--dry-run]
# 须在源 Git 仓库内执行；link 需校验源、目标 .docsconfig 与 KNOWLEDGE_TYPE；
# unlink 支持目标失联场景（按登记 path 注销）；system 源注销 application 建联时先将
# DOC_ROOT 下 application-<APPNAME>/ 备份至 REPO_ROOT/.docs-init/<时间戳>/（与 docs-install 一致）再移除。
# 登记值：目标为 Git 仓库时优先 remote URL（origin，否则第一个 remote），
#       若无可用 remote 则使用 git 仓库根绝对路径；非 Git 目标为规范化绝对路径。
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./link-config.sh
source "${SCRIPT_DIR}/link-config.sh"

error() { printf '错误: %s\n' "$*" >&2; exit 1; }
warn() { printf '警告: %s\n' "$*" >&2; }

# =============================================================================
# knowledge-links.yaml
# =============================================================================

# 从 knowledge-links.yaml 解析每条 link：path、可选 doc_dir、可选 app_name（application 槽位）
# 输出每行：path<TAB>doc_dir<TAB>app_name（后两者可为空）
knowledge_links_parse_entries_stream() {
  local f="${1:?}"
  [[ -f "$f" ]] || return 0
  local path="" doc_dir="" app_name="" v w z
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*path:[[:space:]]*(.*)$ ]]; then
      [[ -n "$path" ]] && printf '%s\t%s\t%s\n' "$path" "$doc_dir" "$app_name"
      v="${BASH_REMATCH[1]}"
      v="${v#\"}"; v="${v%\"}"
      v="${v#\'}"; v="${v%\'}"
      path="$v"
      doc_dir=""
      app_name=""
    elif [[ -n "$path" && "$line" =~ ^[[:space:]]*doc_dir:[[:space:]]*(.*)$ ]]; then
      w="${BASH_REMATCH[1]}"
      w="${w#\"}"; w="${w%\"}"
      w="${w#\'}"; w="${w%\'}"
      doc_dir="$w"
    elif [[ -n "$path" && "$line" =~ ^[[:space:]]*app_name:[[:space:]]*(.*)$ ]]; then
      z="${BASH_REMATCH[1]}"
      z="${z#\"}"; z="${z%\"}"
      z="${z#\'}"; z="${z%\'}"
      app_name="$z"
    fi
  done <"$f"
  [[ -n "$path" ]] && printf '%s\t%s\t%s\n' "$path" "$doc_dir" "$app_name"
}

# 覆盖写出 knowledge-links.yaml（path、doc_dir、app_name 三组数组下标对齐）
knowledge_links_write_triples() {
  local f="${1:?}"
  local -n _paths="${2:?}"
  local -n _dirs="${3:?}"
  local -n _apps="${4:?}"
  local d i n
  d="$(dirname "$f")"
  n="${#_paths[@]}"
  [[ "$DRY" == '1' ]] && { printf '[dry-run] 将写入 %s（%d 条 links）\n' "$f" "$n" >&2; return 0; }
  mkdir -p "$d"
  umask 022
  {
    printf '%s\n' '# 知识库建联清单（可由 docs-link.sh 维护）'
    printf '%s\n' 'links:'
    for ((i = 0; i < n; i++)); do
      printf '  - path: "%s"\n' "${_paths[i]//\"/\\\"}"
      if [[ -n "${_dirs[i]:-}" ]]; then
        printf '    doc_dir: "%s"\n' "${_dirs[i]//\"/\\\"}"
      fi
      if [[ -n "${_apps[i]:-}" ]]; then
        printf '    app_name: "%s"\n' "${_apps[i]//\"/\\\"}"
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

# 将「已登记的一条 path」规范为身份串（目录则按 Git 规则，否则原样）
knowledge_link_identity_from_stored_path() {
  local stored="${1:?}"
  if [[ -d "$stored" ]]; then
    knowledge_link_register_value_from_dir "$stored"
  else
    printf '%s\n' "$(strip_trailing_slash "$stored")"
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
  if [[ "$app" == 'APPNAME' ]]; then
    warn "推断的 APPNAME 为 APPNAME，跳过槽位目录生成（与模板同名）"
    return 0
  fi
  [[ -d "$tpl" ]] || error "源 DOC_ROOT 下缺少模板目录: $tpl"
  if [[ -d "$dest" ]]; then
    return 0
  fi
  if [[ "$DRY" == '1' ]]; then
    printf '[dry-run] 将自模板创建目录: %s → %s\n' "$tpl" "$dest" >&2
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
    warn "APPNAME 为保留名，跳过删除槽位目录"
    return 0
  fi
  dest="$(strip_trailing_slash "$(abs_path "$doc_root")")/application-${app}"
  if [[ ! -d "$dest" ]]; then
    return 0
  fi
  repo_root="$(knowledge_link_repo_root_for_backup "$doc_root")" || {
    warn "无法解析 REPO_ROOT，跳过备份，将直接删除: $dest"
    if [[ "$DRY" == '1' ]]; then
      printf '[dry-run] 将删除目录: %s\n' "$dest" >&2
      return 0
    fi
    rm -rf "$dest"
    printf '已删除槽位目录: %s\n' "$dest" >&2
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

while (( $# > 0 )); do
  case "$1" in
    --link)
      [[ "$CMD" == 'unlink' ]] && error "不能同时指定 --link 与 --unlink"
      [[ "$CMD" == 'link' ]] && error "重复指定 --link"
      CMD='link'
      shift
      ;;
    --unlink)
      [[ "$CMD" == 'link' ]] && error "不能同时指定 --link 与 --unlink"
      [[ "$CMD" == 'unlink' ]] && error "重复指定 --unlink"
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
      [[ -n "${1:-}" ]] || error "缺少 --app-name 值"
      CLI_APP_NAME="$1"
      shift
      ;;
    --target=*)  TARGET_RAW="${1#*=}"; shift ;;
    --target)
      shift
      [[ -n "${1:-}" ]] || error "缺少 --target 值"
      TARGET_RAW="$1"
      shift
      ;;
    --path=*)
      TARGET_RAW="${1#*=}"
      warn "--path 已弃用，请改用 --target"
      shift
      ;;
    --path)
      shift
      [[ -n "${1:-}" ]] || error "缺少 --path 值"
      TARGET_RAW="$1"
      warn "--path 已弃用，请改用 --target"
      shift
      ;;
    -h|--help)
      cat >&2 <<'EOF'
用法: ./scripts/docs-link.sh --link|--unlink --target=<目标知识库仓库根> [--app-name=名] [--dry-run]

  --link / --unlink 二选一，不得同时出现。

  须在「源」知识库 Git 仓库内执行（git rev-parse 取根）。登记文件：源 .docsconfig 的 DOC_ROOT/knowledge-links.yaml

  允许边：company→system、system→application（源/目标 .docsconfig 须含合法 KNOWLEDGE_TYPE）。
  unlink 支持目标失联（路径不存在或目标仓库配置缺失）时按登记 path 注销。

  --dry-run     仅打印将执行的操作，不写文件。
  --target      目标知识库仓库根（或已登记的 remote URL）；兼容旧参数 --path（已弃用）。
  --app-name    仅 system→application 建联有效：显式指定 YAML 中的 app_name 及槽位目录名。
                若省略：登记文件中该 path 已有 app_name 则沿用、不再推断；否则由目标本地 Git 仓库根目录名推断。
  每条 link 记录：path、目标 doc_dir（DOC_DIR）、以及 application 时的 app_name。
  system→application：在源 DOC_ROOT 下自 application-APPNAME 模板生成 application-<APPNAME>/（已存在则跳过）。
  同一 target 重复 link：不新增行，只更新已存在且 identity 相同的那条记录（path/doc_dir/app_name）。
  unlink 时：注销该 path 的同时将 application-<APPNAME>/ 备份到工程根 .docs-init/ 再移除（若目录存在）。

示例:
  ./scripts/docs-link.sh --target=~/workspaces/target-repo --link
  ./scripts/docs-link.sh --target=~/workspaces/target-repo --link --app-name=my-app
  ./scripts/docs-link.sh --target=~/workspaces/target-repo --unlink --dry-run
EOF
      exit 0
      ;;
    *) error "未知参数: $1" ;;
  esac
done

validate_link_command "$CMD" || error "请指定 --link 或 --unlink（二选一）"
[[ -n "$TARGET_RAW" ]] || error "请指定 --target=<目标仓库根>"

SRC_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || error "请在 Git 仓库内执行 docs-link"
SRC_CFG="$SRC_ROOT/.docsconfig"
[[ -f "$SRC_CFG" ]] || error "源仓库缺少 .docsconfig: $SRC_CFG"

_sdoc='' _srepo='' _sdd='' _skt=''
docsconfig_read_into "$SRC_CFG" _sdoc _srepo _sdd _skt || error "无法解析源 .docsconfig"
[[ -n "$_sdoc" ]] || error "源 .docsconfig 缺少 DOC_ROOT"
[[ -n "$_skt" ]] || error "源 .docsconfig 缺少 KNOWLEDGE_TYPE"
docsconfig_validate_knowledge_type "$_skt" || exit 1

expect_target=''
LIST_FILE="$_sdoc/knowledge-links.yaml"
case "$_skt" in
  company) expect_target='system' ;;
  system)  expect_target='application' ;;
  *) error "源 KNOWLEDGE_TYPE=${_skt} 不支持建联（仅 company 或 system 可作为源）" ;;
esac

TARGET_KEY="$(normalize_target_repo_root "$TARGET_RAW")" || error "目标路径非法: $TARGET_RAW"
REGISTER_KEY=''
TARGET_DOC_DIR=''
TARGET_APP_NAME=''
matched_idx=-1

if [[ "$CMD" == 'link' ]]; then
  TGT_ROOT="$(cd -P "$TARGET_KEY" 2>/dev/null && pwd)" || error "目标路径不存在或不可进入: $TARGET_KEY"
  TGT_CFG="$TGT_ROOT/.docsconfig"
  [[ -f "$TGT_CFG" ]] || error "目标仓库缺少 .docsconfig: $TGT_CFG"

  _tdoc='' _trepo='' _tdd='' _tkt=''
  docsconfig_read_into "$TGT_CFG" _tdoc _trepo _tdd _tkt || error "无法解析目标 .docsconfig"
  [[ -n "$_tkt" ]] || error "目标 .docsconfig 缺少 KNOWLEDGE_TYPE"
  docsconfig_validate_knowledge_type "$_tkt" || exit 1
  [[ "$_tkt" == "$expect_target" ]] || error "目标须为 ${expect_target} 知识库（KNOWLEDGE_TYPE=${_tkt}）"
  REGISTER_KEY="$(knowledge_link_register_value_from_dir "$TGT_ROOT")"
  TARGET_DOC_DIR="${_tdd:-}"
else
  REGISTER_KEY="$(knowledge_link_identity_from_raw_target "$TARGET_RAW")" || error "目标路径非法: $TARGET_RAW"
  [[ -z "$CLI_APP_NAME" ]] || warn "--app-name 仅在 --link 时有效，已忽略"
fi

declare -a paths=() doc_dirs=() app_names=()
while IFS=$'\t' read -r p d a || [[ -n "${p:-}" ]]; do
  [[ -z "${p:-}" ]] && continue
  paths+=("$p")
  doc_dirs+=("${d:-}")
  app_names+=("${a:-}")
done < <(knowledge_links_parse_entries_stream "$LIST_FILE")

have=0
new_identity="${REGISTER_KEY}"
for i in "${!paths[@]}"; do
  if [[ "$(knowledge_link_identity_from_stored_path "${paths[i]}")" == "$new_identity" ]]; then
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
elif [[ "$CMD" == 'link' && "$expect_target" != 'application' && -n "$CLI_APP_NAME" ]]; then
  warn "--app-name 仅用于 system→application 建联，已忽略"
fi

case "$CMD" in
  link)
    link_is_update=0
    [[ "$have" -eq 1 ]] && link_is_update=1
    if [[ "$have" -eq 1 ]]; then
      paths[matched_idx]="$REGISTER_KEY"
      doc_dirs[matched_idx]="$TARGET_DOC_DIR"
      app_names[matched_idx]="${TARGET_APP_NAME:-}"
    else
      paths+=("$REGISTER_KEY")
      doc_dirs+=("$TARGET_DOC_DIR")
      app_names+=("${TARGET_APP_NAME:-}")
    fi
    knowledge_links_write_triples "$LIST_FILE" paths doc_dirs app_names
    if [[ "$link_is_update" -eq 1 ]]; then
      if [[ -n "$TARGET_APP_NAME" ]]; then
        if [[ -n "$TARGET_DOC_DIR" ]]; then
          printf '已更新登记: %s → %s (doc_dir=%s, application-%s)\n' "$LIST_FILE" "$REGISTER_KEY" "$TARGET_DOC_DIR" "$TARGET_APP_NAME"
        else
          printf '已更新登记: %s → %s (application-%s)\n' "$LIST_FILE" "$REGISTER_KEY" "$TARGET_APP_NAME"
        fi
      elif [[ -n "$TARGET_DOC_DIR" ]]; then
        printf '已更新登记: %s → %s (doc_dir=%s)\n' "$LIST_FILE" "$REGISTER_KEY" "$TARGET_DOC_DIR"
      else
        printf '已更新登记: %s → %s\n' "$LIST_FILE" "$REGISTER_KEY"
      fi
    elif [[ -n "$TARGET_APP_NAME" ]]; then
      if [[ -n "$TARGET_DOC_DIR" ]]; then
        printf '已登记: %s → %s (doc_dir=%s, application-%s)\n' "$LIST_FILE" "$REGISTER_KEY" "$TARGET_DOC_DIR" "$TARGET_APP_NAME"
      else
        printf '已登记: %s → %s (application-%s)\n' "$LIST_FILE" "$REGISTER_KEY" "$TARGET_APP_NAME"
      fi
    elif [[ -n "$TARGET_DOC_DIR" ]]; then
      printf '已登记: %s → %s (doc_dir=%s)\n' "$LIST_FILE" "$REGISTER_KEY" "$TARGET_DOC_DIR"
    else
      printf '已登记: %s → %s\n' "$LIST_FILE" "$REGISTER_KEY"
    fi
    ;;
  unlink)
    [[ "$have" -eq 0 ]] && { printf '提示: 未找到登记项，跳过: %s\n' "$REGISTER_KEY" >&2; exit 0; }
    UNLINK_APP_NAME=''
    if [[ "$matched_idx" -ge 0 && "$_skt" == 'system' ]]; then
      UNLINK_APP_NAME="${app_names[matched_idx]:-}"
      if [[ -z "$UNLINK_APP_NAME" ]]; then
        UNLINK_APP_NAME="$(knowledge_link_app_name_from_register_key "${paths[matched_idx]}")" || UNLINK_APP_NAME=''
      fi
    fi
    declare -a newp=() newd=() newa=()
    for i in "${!paths[@]}"; do
      [[ "$(knowledge_link_identity_from_stored_path "${paths[i]}")" == "$new_identity" ]] && continue
      newp+=("${paths[i]}")
      newd+=("${doc_dirs[i]:-}")
      newa+=("${app_names[i]:-}")
    done
    knowledge_links_write_triples "$LIST_FILE" newp newd newa
    if [[ -n "$UNLINK_APP_NAME" ]]; then
      knowledge_link_remove_application_slot "$_sdoc" "$UNLINK_APP_NAME"
    fi
    printf '已注销: %s 中的 %s\n' "$LIST_FILE" "$REGISTER_KEY"
    ;;
esac
