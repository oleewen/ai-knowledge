#!/usr/bin/env bash
# docs-link.sh — 在源知识库登记 / 注销目标知识库（双边 knowledge-links.yaml）
# 源仓 links：向下 child（缺省无 type）；子仓 links：一条 type:parent（1:1）
# application 建联时 app_name：--app-name > 登记文件已有 > Git 仓库根目录名推断
# app_label：新登记或条目中尚无 app_label 时默认等于 app_name；重复 link 且已有 app_label 则保留不覆盖
# 同一 target 重复 link：合并更新同一条记录，不追加重复行
# 用法: bash agent/skills/docs-link/scripts/docs-link.sh --link|--unlink --target <目标仓库根> [--app-name=名] [--rewrite-http] [--dry-run]
# 须在源 Git 仓库内执行；link 需校验源、目标 .docsconfig 与 KNOWLEDGE_TYPE；
# 目标须已有 knowledge-links.yaml（application 由 docs-install 落盘）；缺则失败。
# unlink 支持目标失联场景（按登记 identity 注销）；注销时移除槽位软链（共用 changelogs 保留）。
# 登记值：repository 存 Git remote URL；path 存本机路径（$HOME 下 ~/…）；doc_dir=对方 DOC_DIR。
# type:meta（docs-install 写入）写回时保活；meta.doc_dir=目标 KNOWLEDGE_TYPE。pull/push 跳过 meta。
# 不再读写 knowledge-parent.yaml；跨层 HTTP 前缀替换仅当 --rewrite-http。
# 槽位：application-slots/application-{NAME} 或 system-slots/system-{NAME} 为指向下级 DOC_ROOT 的软链。
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./link-config.sh
source "${SCRIPT_DIR}/link-config.sh"

docs_link_source_federation_helpers() {
  local c
  for c in \
    "${SCRIPT_DIR}/../../../scripts/federation-slot-symlink.sh" \
    "${HOME}/.agents/scripts/federation-slot-symlink.sh" \
    "${HOME}/.cursor/scripts/federation-slot-symlink.sh" \
    "${HOME}/.trae/scripts/federation-slot-symlink.sh" \
    "${HOME}/.claude/scripts/federation-slot-symlink.sh" \
    "${HOME}/.kiro/scripts/federation-slot-symlink.sh" \
    "${HOME}/.codex/scripts/federation-slot-symlink.sh"
  do
    if [[ -f "$c" ]]; then
      # shellcheck source=/dev/null
      source "$c"
      return 0
    fi
  done
  sdx_error "未找到 federation-slot-symlink.sh（请安装 Agent 或在中央库执行）"
}
docs_link_source_federation_helpers


REWRITE_HTTP=0

docs_link_okf_parent_py() {
  local c d base ar=''
  if [[ -n "${_sar:-}" ]]; then
    ar="$(abs_path "$_sar")" || ar="$_sar"
  fi
  for c in \
    "${SCRIPT_DIR}/../../docs-okf/scripts/okf_parent.py" \
    "${ar}/skills/docs-okf/scripts/okf_parent.py"
  do
    [[ -n "$c" && -f "$c" ]] && { printf '%s\n' "$c"; return 0; }
  done
  for d in ${_sads:-}; do
    [[ -z "$d" ]] && continue
    if [[ "$d" == /* || "$d" == '~'* ]]; then
      base="$(abs_path "$d")" || continue
    elif [[ -n "$ar" ]]; then
      base="$(abs_path "${ar}/${d}")" || continue
    else
      continue
    fi
    c="${base}/skills/docs-okf/scripts/okf_parent.py"
    [[ -f "$c" ]] && { printf '%s\n' "$c"; return 0; }
  done
  sdx_error "未找到 okf_parent.py（跨层 HTTP 改写）"
}

docs_link_run_okf_rewrite() {
  local py
  py="$(docs_link_okf_parent_py)"
  if [[ "$DRY" == '1' ]]; then
    python3 "$py" --dry-run "$@"
  else
    python3 "$py" "$@"
  fi
}

docs_link_abs_under_repo() {
  local repo="${1:?}" doc="${2:?}"
  local repo_abs doc_abs
  repo_abs="$(strip_trailing_slash "$(abs_path "$repo")")"
  if [[ "$doc" == /* ]]; then
    doc_abs="$(strip_trailing_slash "$(abs_path "$doc")")"
    case "$doc_abs" in
      "$repo_abs"|"$repo_abs"/*) printf '%s\n' "$doc_abs" ;;
      *)
        printf '%s\n' "$repo_abs/$(basename "$doc_abs")"
        ;;
    esac
  else
    strip_trailing_slash "$(abs_path "$repo_abs/$doc")"
  fi
}

# =============================================================================
# knowledge-links.yaml（解析/写出见 docs-core.sh；此处仅编排）
# =============================================================================

_knowledge_link_doc_root_abs_ns() {
  strip_trailing_slash "$(abs_path "${1:?}")"
}

# -----------------------------------------------------------------------------
# 登记 path：Git 优先 remote URL，否则仓库根路径 / 文件系统路径
# -----------------------------------------------------------------------------

# 给定已存在的本地目录：得到与 link 时一致的登记字符串（用于去重 / unlink）
knowledge_link_register_value_from_dir() {
  local dir="${1:?}" resolved top url
  resolved="$(cd -P "$dir" 2>/dev/null && pwd)" || {
    printf '%s\n' "$dir"
    return 0
  }
  if [[ -d "$resolved/.git" || -f "$resolved/.git" ]]; then
    top="$resolved"
  else
    printf '%s\n' "$resolved"
    return 0
  fi
  url="$(knowledge_link_git_remote_url_prefer_origin "$top" || true)"
  if [[ -n "$url" ]]; then
    url="$(strip_trailing_slash "$url")"
    printf '%s\n' "$url"
    return 0
  fi
  printf '%s\n' "$(strip_trailing_slash "$top")"
}

# 将「用户传入的 --target」规范为与已登记项可比对的身份串
knowledge_link_identity_from_raw_target() {
  local raw="${1:?}" p
  if knowledge_link_value_looks_like_git_remote "$raw"; then
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
# 应用槽位 application-slots/application-${NAME} = 指向下级 DOC_ROOT 的软链
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
  top="$(cd -P "$root" 2>/dev/null && pwd)" || top="$root"
  base="$(basename "$top")"
  knowledge_link_validate_app_name "$base"
}

# 在源 DOC_ROOT/application-slots 下确保 application-${app} 软链 + 共用 changelogs
# target_doc_root：下级 DOC_ROOT 绝对路径（可尚不存在 → 悬空软链）
knowledge_link_ensure_application_slot() {
  local doc_root="${1:?}" app="${2:?}" target_doc_root="${3:?}"
  local dr slots dest shared
  dr="$(_knowledge_link_doc_root_abs_ns "$doc_root")"
  slots="${dr}/application-slots"
  dest="${slots}/application-${app}"
  shared="${slots}/changelogs"
  if [[ "$DRY" == '1' ]]; then
    sdx_log "[dry-run] 将确保软链: %s → %s" "$dest" "$target_doc_root"
    return 0
  fi
  mkdir -p "$slots"
  federation_ensure_shared_changelogs "$slots"
  federation_ensure_slot_symlink "$dest" "$target_doc_root" "$shared" "$app" >/dev/null
}

# -----------------------------------------------------------------------------
# 系统槽位 system-slots/system-${NAME} = 指向下级 DOC_ROOT 的软链
# -----------------------------------------------------------------------------

knowledge_link_validate_sys_name() {
  local raw="${1:?}" base
  base="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
  [[ -n "$base" ]] || {
    printf '错误: sys_name 不能为空\n' >&2
    return 1
  }
  if [[ ! "$base" =~ ^[a-z0-9][a-z0-9_.-]*$ ]]; then
    printf '错误: 非法 sys_name: %s（仅允许 a-z0-9._-）\n' "$raw" >&2
    return 1
  fi
  printf '%s\n' "$base"
}

knowledge_link_guess_sys_name() {
  local root="${1:?}" top base
  top="$(cd -P "$root" 2>/dev/null && pwd)" || top="$root"
  base="$(basename "$top")"
  knowledge_link_validate_sys_name "$base"
}

knowledge_link_ensure_system_slot() {
  local doc_root="${1:?}" sys="${2:?}" target_doc_root="${3:?}"
  local dr slots dest shared
  dr="$(_knowledge_link_doc_root_abs_ns "$doc_root")"
  slots="${dr}/system-slots"
  dest="${slots}/system-${sys}"
  shared="${slots}/changelogs"
  if [[ "$DRY" == '1' ]]; then
    sdx_log "[dry-run] 将确保软链: %s → %s" "$dest" "$target_doc_root"
    return 0
  fi
  mkdir -p "$slots"
  federation_ensure_shared_changelogs "$slots"
  federation_ensure_slot_symlink "$dest" "$target_doc_root" "$shared" "$sys" >/dev/null
}

# 从登记 identity（repository URL 或已展开本地路径）推断 APPNAME，供旧数据或无 app_name 时 unlink 删槽位
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
  dr="$(_knowledge_link_doc_root_abs_ns "$doc_root")"
  rr="$(docsconfig_repo_root_from_doc_root "$dr")"
  [[ -n "$rr" ]] || rr="$(docsconfig_repo_root_fallback_from_doc_root "$dr")"
  [[ -n "$rr" ]] || return 1
  printf '%s\n' "$(strip_trailing_slash "$rr")"
}

# 移除槽位软链（或残留真目录）；共用 application-slots/changelogs 保留
knowledge_link_remove_application_slot() {
  local doc_root="${1:?}" app="${2:?}"
  local dest
  [[ -n "$app" ]] || return 0
  if [[ "$app" == 'NAME' || "$app" == 'APPNAME' ]]; then
    sdx_warn "NAME/APPNAME 为保留名，跳过删除槽位"
    return 0
  fi
  dest="$(_knowledge_link_doc_root_abs_ns "$doc_root")/application-slots/application-${app}"
  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    return 0
  fi
  if [[ "$DRY" == '1' ]]; then
    sdx_log "[dry-run] 将删除槽位软链/目录: $dest"
    return 0
  fi
  federation_remove_slot_path "$dest"
  sdx_info "已删除槽位: $dest"
}

knowledge_link_remove_system_slot() {
  local doc_root="${1:?}" sys="${2:?}"
  local dest
  [[ -n "$sys" ]] || return 0
  if [[ "$sys" == 'NAME' || "$sys" == 'SYSNAME' ]]; then
    sdx_warn "NAME/SYSNAME 为保留名，跳过删除槽位"
    return 0
  fi
  dest="$(_knowledge_link_doc_root_abs_ns "$doc_root")/system-slots/system-${sys}"
  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    return 0
  fi
  if [[ "$DRY" == '1' ]]; then
    sdx_log "[dry-run] 将删除槽位软链/目录: $dest"
    return 0
  fi
  federation_remove_slot_path "$dest"
  sdx_info "已删除槽位: $dest"
}

# =============================================================================
# CLI
# =============================================================================

DRY="${KLINK_DEFAULT_DRY_RUN}"
CMD=''
TARGET_RAW=''
CLI_APP_NAME=''

docs_link_require_value() {
  local flag="${1:?flag is required}"
  local value="${2-}"
  [[ -n "$value" ]] || sdx_error "缺少 ${flag} 值"
}

docs_link_unknown_arg() {
  local arg="${1:?arg is required}"
  sdx_error "未知参数: ${arg}"
}

docs_link_usage() {
  cat >&2 <<'EOF'
用法: bash agent/skills/docs-link/scripts/docs-link.sh --link|--unlink --target <目标知识库仓库根> [--app-name 名] [--rewrite-http] [--dry-run]

  --link / --unlink 二选一，不得同时出现。

  须在「源」知识库 Git 仓库内执行（git rev-parse 取根）。登记文件：源 .docsconfig 的 DOC_ROOT/knowledge-links.yaml

  允许边：company→system、system→application（源/目标 .docsconfig 须含合法 KNOWLEDGE_TYPE）。
  目标须已有 knowledge-links.yaml（缺则失败；application 由 docs-install 落盘空清单）。
  unlink 支持目标失联（路径不存在或目标仓库配置缺失）时按登记 identity 注销。

  --dry-run       仅打印将执行的操作，不写文件。
  --rewrite-http  换父级时替换目标 knowledge/** 中旧跨层 HTTP 前缀（默认不改正文）。
  --target        目标知识库仓库根（或已登记的 remote URL）；兼容旧参数 --path（已弃用）。
  --app-name      仅 system→application 建联有效。

  源仓 links：向下 child（不写 type；缺省=child）；doc_dir=目标 DOC_DIR；company→system 用 sys_*，system→application 用 app_*。
  子仓 links：恰好一条 type:parent（repository/path/doc_dir + company_* 或 sys_*）；HTTP ref 固定 main。
  槽位：建联时创建指向下级 DOC_ROOT 的软链；同步日志在 application-slots/changelogs/ 或 system-slots/changelogs/。
  不再读写 knowledge-parent.yaml。unlink 删除子仓 parent 条与槽位软链，不改正文 HTTP，共用日志保留。

示例:
  bash agent/skills/docs-link/scripts/docs-link.sh --target ~/workspaces/target-repo --link
  bash agent/skills/docs-link/scripts/docs-link.sh --target ~/workspaces/target-repo --link --app-name=my-app --rewrite-http
  bash agent/skills/docs-link/scripts/docs-link.sh --target ~/workspaces/target-repo --unlink --dry-run
EOF
}

docs_link_parse_args() {
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
      --dry-run) DRY=1; shift ;;
      --rewrite-http) REWRITE_HTTP=1; shift ;;
      --app-name=*)
        CLI_APP_NAME="${1#*=}"
        shift
        ;;
      --app-name)
        shift
        docs_link_require_value "--app-name" "${1:-}"
        CLI_APP_NAME="$1"
        shift
        ;;
      --target=*) TARGET_RAW="${1#*=}"; shift ;;
      --target)
        shift
        docs_link_require_value "--target" "${1:-}"
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
        docs_link_require_value "--path" "${1:-}"
        TARGET_RAW="$1"
        sdx_warn "--path 已弃用，请改用 --target"
        shift
        ;;
      -h|--help)
        docs_link_usage
        exit 0
        ;;
      *)
        docs_link_unknown_arg "$1"
        ;;
    esac
  done
}

docs_link_parse_args "$@"

validate_link_command "$CMD" || sdx_error "请指定 --link 或 --unlink（二选一）"
[[ -n "$TARGET_RAW" ]] || sdx_error "请指定 --target <目标仓库根>（仍兼容 --target=PATH）"

SRC_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || sdx_error "请在 Git 仓库内执行 docs-link"
SRC_CFG="$SRC_ROOT/.docsconfig"
[[ -f "$SRC_CFG" ]] || sdx_error "源仓库缺少 .docsconfig: $SRC_CFG"

_sdoc='' _srepo='' _sdd='' _sar='' _sads='' _skt=''
docsconfig_read_into "$SRC_CFG" _sdoc _srepo _sdd _sar _sads _skt || sdx_error "无法解析源 .docsconfig"
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

# 源仓写出：child 用 sys|app；源仓已有 parent 时用 parent_kind
# 目标仓 child 键族恒为 app（仅 system 文件会同时保留 parent+child）
case "$_skt" in
  company) SRC_CHILD_KIND='sys'; SRC_PARENT_KIND='none' ;;
  system)  SRC_CHILD_KIND='app'; SRC_PARENT_KIND='company' ;;
esac
case "$expect_target" in
  system) TGT_PARENT_KIND='company' ;;
  application) TGT_PARENT_KIND='sys' ;;
esac
TGT_CHILD_KIND='app'
TARGET_KEY="$(normalize_target_repo_root "$TARGET_RAW")" || sdx_error "目标路径非法: $TARGET_RAW"
REGISTER_KEY=''
REGISTER_REPO=''
REGISTER_PATH_STORED=''
TARGET_DOC_DIR=''
TARGET_APP_NAME=''
TARGET_APP_LABEL=''
TARGET_SYS_NAME=''
TARGET_SYS_LABEL=''
matched_idx=-1
TGT_LINKS=''
PARENT_NAME=''
PARENT_LABEL=''
SRC_DOC_DIR=''

if [[ "$CMD" == 'link' ]]; then
  TGT_ROOT="$(cd -P "$TARGET_KEY" 2>/dev/null && pwd)" || sdx_error "目标路径不存在或不可进入: $TARGET_KEY"
  TGT_CFG="$TGT_ROOT/.docsconfig"
  [[ -f "$TGT_CFG" ]] || sdx_error "目标仓库缺少 .docsconfig: $TGT_CFG"

  _tdoc='' _trepo='' _tdd='' _tar='' _tads='' _tkt=''
  docsconfig_read_into "$TGT_CFG" _tdoc _trepo _tdd _tar _tads _tkt || sdx_error "无法解析目标 .docsconfig"
  [[ -n "$_tkt" ]] || sdx_error "目标 .docsconfig 缺少 KNOWLEDGE_TYPE"
  docsconfig_validate_knowledge_type "$_tkt" || exit 1
  [[ "$_tkt" == "$expect_target" ]] || sdx_error "目标须为 ${expect_target} 知识库（KNOWLEDGE_TYPE=${_tkt}）"
  [[ -n "$_tdd" ]] || sdx_error "目标 .docsconfig 缺少 DOC_DIR"
  [[ -n "$_tdoc" ]] || sdx_error "目标 .docsconfig 缺少 DOC_ROOT"
  TGT_LINKS="$(docs_link_abs_under_repo "$TGT_ROOT" "$_tdoc")/knowledge-links.yaml"
  [[ -f "$TGT_LINKS" ]] || sdx_error "目标缺少 knowledge-links.yaml（请先 docs-install）: $TGT_LINKS"
  REGISTER_KEY="$(knowledge_link_register_value_from_dir "$TGT_ROOT")"
  REGISTER_REPO="$(knowledge_link_git_remote_url_prefer_origin "$TGT_ROOT" || true)"
  [[ -n "$REGISTER_REPO" ]] || sdx_error "目标仓库缺少 Git remote URL（repository 必填）。请为目标仓库配置 origin（或任一 remote）后重试: $TGT_ROOT"
  TARGET_DOC_DIR="$_tdd"
  REGISTER_PATH_STORED="$(knowledge_link_stored_path_from_absolute "$TGT_ROOT")"
  SRC_DOC_DIR="$_sdd"
  [[ -n "$SRC_DOC_DIR" ]] || SRC_DOC_DIR="$(docsconfig_doc_dir_from_roots "$SRC_ROOT" "$(docs_link_abs_under_repo "$SRC_ROOT" "$_sdoc")")" \
    || sdx_error "无法计算源 DOC_DIR"
  PARENT_NAME="$(basename "$SRC_ROOT")"
  PARENT_LABEL="$PARENT_NAME"
else
  REGISTER_KEY="$(knowledge_link_identity_from_raw_target "$TARGET_RAW")" || sdx_error "目标路径非法: $TARGET_RAW"
  [[ -z "$CLI_APP_NAME" ]] || sdx_warn "--app-name 仅在 --link 时有效，已忽略"
  if [[ -d "$TARGET_KEY" ]]; then
    _tdoc='' _trepo='' _tdd='' _tar='' _tads='' _tkt=''
    if [[ -f "$TARGET_KEY/.docsconfig" ]] && docsconfig_read_into "$TARGET_KEY/.docsconfig" _tdoc _trepo _tdd _tar _tads _tkt; then
      [[ -n "$_tdoc" ]] && TGT_LINKS="$(docs_link_abs_under_repo "$TARGET_KEY" "$_tdoc")/knowledge-links.yaml"
    fi
  fi
fi

declare -a repos=() paths=() doc_dirs=() app_names=() app_labels=() types=()
knowledge_links_load_into_arrays "$LIST_FILE" paths repos doc_dirs app_names app_labels types

have=0
new_identity="${REGISTER_KEY}"
for i in "${!paths[@]}"; do
  case "${types[i]:-child}" in
    parent|meta) continue ;;
  esac
  if [[ "$(knowledge_link_identity_from_stored_entry "${repos[i]:-}" "${paths[i]}")" == "$new_identity" ]]; then
    have=1
    matched_idx=$i
    break
  fi
done

if [[ "$CMD" == 'link' && "$expect_target" == 'application' ]]; then
  if [[ -n "$CLI_APP_NAME" ]]; then
    TARGET_APP_NAME="$(knowledge_link_validate_app_name "$CLI_APP_NAME")" || exit 1
  elif [[ "$have" -eq 1 && "$matched_idx" -ge 0 && -n "${app_names[matched_idx]:-}" ]]; then
    TARGET_APP_NAME="$(knowledge_link_validate_app_name "${app_names[matched_idx]}")" || exit 1
  else
    TARGET_APP_NAME="$(knowledge_link_guess_app_name "$TGT_ROOT")" || exit 1
  fi
  TARGET_SLOT_DOC_ROOT="$(docs_link_abs_under_repo "$TGT_ROOT" "$_tdoc")"
  knowledge_link_ensure_application_slot "$_sdoc" "$TARGET_APP_NAME" "$TARGET_SLOT_DOC_ROOT"
  if [[ "$have" -eq 1 && "$matched_idx" -ge 0 && -n "${app_labels[matched_idx]:-}" ]]; then
    TARGET_APP_LABEL="${app_labels[matched_idx]}"
  else
    [[ -n "$TARGET_APP_NAME" ]] && TARGET_APP_LABEL="$TARGET_APP_NAME"
  fi
elif [[ "$CMD" == 'link' && "$expect_target" == 'system' ]]; then
  if [[ "$have" -eq 1 && "$matched_idx" -ge 0 && -n "${app_names[matched_idx]:-}" ]]; then
    TARGET_SYS_NAME="$(knowledge_link_validate_sys_name "${app_names[matched_idx]}")" || exit 1
  else
    TARGET_SYS_NAME="$(knowledge_link_guess_sys_name "$TGT_ROOT")" || exit 1
  fi
  TARGET_SLOT_DOC_ROOT="$(docs_link_abs_under_repo "$TGT_ROOT" "$_tdoc")"
  knowledge_link_ensure_system_slot "$_sdoc" "$TARGET_SYS_NAME" "$TARGET_SLOT_DOC_ROOT"
  if [[ "$have" -eq 1 && "$matched_idx" -ge 0 && -n "${app_labels[matched_idx]:-}" ]]; then
    TARGET_SYS_LABEL="${app_labels[matched_idx]}"
  else
    [[ -n "$TARGET_SYS_NAME" ]] && TARGET_SYS_LABEL="$TARGET_SYS_NAME"
  fi
elif [[ "$CMD" == 'link' && "$expect_target" != 'application' && -n "$CLI_APP_NAME" ]]; then
  sdx_warn "--app-name 仅用于 system→application 建联，已忽略"
fi

# 在目标 links 中 upsert 唯一 type:parent；可选 --rewrite-http
docs_link_upsert_target_parent() {
  local src_repo src_path
  local -a trepos=() tpaths=() tdirs=() tapps=() tlabels=() ttypes=()
  local -a nrepos=() npaths=() ndirs=() napps=() nlabels=() ntypes=()
  local i parent_idx=-1 old_repo='' old_path='' old_dir=''

  src_repo="$(knowledge_link_git_remote_url_prefer_origin "$SRC_ROOT" || true)"
  [[ -n "$src_repo" ]] || sdx_error "源仓库缺少 Git remote URL（parent.repository 必填）: $SRC_ROOT"
  src_path="$(knowledge_link_stored_path_from_absolute "$SRC_ROOT")"

  knowledge_links_load_into_arrays "$TGT_LINKS" tpaths trepos tdirs tapps tlabels ttypes
  for i in "${!tpaths[@]}"; do
    if [[ "${ttypes[i]:-child}" == "parent" ]]; then
      parent_idx=$i
      old_repo="${trepos[i]:-}"
      old_path="${tpaths[i]:-}"
      old_dir="${tdirs[i]:-}"
      break
    fi
  done

  if [[ "$REWRITE_HTTP" -eq 1 && "$parent_idx" -ge 0 ]]; then
    docs_link_run_okf_rewrite rewrite-http \
      --doc-root "$(docs_link_abs_under_repo "$TGT_ROOT" "$_tdoc")" \
      --old-repository "$old_repo" \
      --old-path "$old_path" \
      --old-doc-dir "$old_dir" \
      --new-repository "$src_repo" \
      --new-path "$src_path" \
      --new-doc-dir "$SRC_DOC_DIR"
  fi

  for i in "${!tpaths[@]}"; do
    [[ "${ttypes[i]:-child}" == "parent" ]] && continue
    nrepos+=("${trepos[i]:-}")
    npaths+=("${tpaths[i]}")
    ndirs+=("${tdirs[i]:-}")
    napps+=("${tapps[i]:-}")
    nlabels+=("${tlabels[i]:-}")
    ntypes+=("${ttypes[i]:-child}")
  done
  # parent 放最前
  nrepos=("$src_repo" "${nrepos[@]}")
  npaths=("$src_path" "${npaths[@]}")
  ndirs=("$SRC_DOC_DIR" "${ndirs[@]}")
  napps=("$PARENT_NAME" "${napps[@]}")
  nlabels=("$PARENT_LABEL" "${nlabels[@]}")
  ntypes=('parent' "${ntypes[@]}")

  knowledge_links_write_entries "$TGT_LINKS" nrepos npaths ndirs napps nlabels ntypes \
    "$TGT_CHILD_KIND" "$TGT_PARENT_KIND"
}

docs_link_remove_target_parent() {
  local -a trepos=() tpaths=() tdirs=() tapps=() tlabels=() ttypes=()
  local -a nrepos=() npaths=() ndirs=() napps=() nlabels=() ntypes=()
  local i
  [[ -n "${TGT_LINKS:-}" && -f "$TGT_LINKS" ]] || return 0
  knowledge_links_load_into_arrays "$TGT_LINKS" tpaths trepos tdirs tapps tlabels ttypes
  for i in "${!tpaths[@]}"; do
    [[ "${ttypes[i]:-child}" == "parent" ]] && continue
    nrepos+=("${trepos[i]:-}")
    npaths+=("${tpaths[i]}")
    ndirs+=("${tdirs[i]:-}")
    napps+=("${tapps[i]:-}")
    nlabels+=("${tlabels[i]:-}")
    ntypes+=("${ttypes[i]:-child}")
  done
  knowledge_links_write_entries "$TGT_LINKS" nrepos npaths ndirs napps nlabels ntypes \
    "$TGT_CHILD_KIND" "$TGT_PARENT_KIND"
}

docs_link_execute_link() {
  local link_is_update link_info='' link_loc='' link_verb='已登记'

  link_is_update=$have
  if [[ "$have" -eq 1 ]]; then
    repos[matched_idx]="$REGISTER_REPO"
    paths[matched_idx]="$REGISTER_PATH_STORED"
    doc_dirs[matched_idx]="$TARGET_DOC_DIR"
    types[matched_idx]='child'
    if [[ "$expect_target" == 'system' ]]; then
      app_names[matched_idx]="${TARGET_SYS_NAME:-}"
      app_labels[matched_idx]="${TARGET_SYS_LABEL:-}"
    else
      app_names[matched_idx]="${TARGET_APP_NAME:-}"
      app_labels[matched_idx]="${TARGET_APP_LABEL:-}"
    fi
  else
    repos+=("$REGISTER_REPO")
    paths+=("$REGISTER_PATH_STORED")
    doc_dirs+=("$TARGET_DOC_DIR")
    types+=('child')
    if [[ "$expect_target" == 'system' ]]; then
      app_names+=("${TARGET_SYS_NAME:-}")
      app_labels+=("${TARGET_SYS_LABEL:-}")
    else
      app_names+=("${TARGET_APP_NAME:-}")
      app_labels+=("${TARGET_APP_LABEL:-}")
    fi
  fi

  knowledge_links_write_entries "$LIST_FILE" repos paths doc_dirs app_names app_labels types \
    "$SRC_CHILD_KIND" "$SRC_PARENT_KIND"
  docs_link_upsert_target_parent

  [[ "$link_is_update" -eq 1 ]] && link_verb='已更新登记'
  if [[ "$expect_target" == 'system' && -n "$TARGET_SYS_NAME" ]]; then
    link_info=" (doc_dir=${TARGET_DOC_DIR}, system-${TARGET_SYS_NAME})"
  elif [[ -n "$TARGET_APP_NAME" && -n "$TARGET_DOC_DIR" ]]; then
    link_info=" (doc_dir=${TARGET_DOC_DIR}, application-${TARGET_APP_NAME})"
  elif [[ -n "$TARGET_APP_NAME" ]]; then
    link_info=" (application-${TARGET_APP_NAME})"
  elif [[ -n "$TARGET_DOC_DIR" ]]; then
    link_info=" (doc_dir=${TARGET_DOC_DIR})"
  fi
  [[ -n "$REGISTER_REPO" ]] && link_loc=" repository=${REGISTER_REPO}"
  link_loc="${link_loc} path=${REGISTER_PATH_STORED}"
  printf '%s: %s → identity=%s%s%s；目标 parent → %s\n' \
    "$link_verb" "$LIST_FILE" "$REGISTER_KEY" "$link_loc" "$link_info" "$TGT_LINKS"
}

docs_link_execute_unlink() {
  local unlink_name='' exp='' i
  declare -a newr=() newp=() newd=() newa=() newl=() newt=()

  [[ "$have" -eq 0 ]] && { printf '提示: 未找到登记项，跳过: %s\n' "$REGISTER_KEY" >&2; exit 0; }
  docs_link_remove_target_parent
  if [[ "$matched_idx" -ge 0 ]]; then
    unlink_name="${app_names[matched_idx]:-}"
    if [[ -z "$unlink_name" ]]; then
      if [[ -n "${repos[matched_idx]:-}" ]]; then
        unlink_name="$(knowledge_link_app_name_from_register_key "${repos[matched_idx]}")" || unlink_name=''
      else
        exp="$(knowledge_link_expand_stored_path "${paths[matched_idx]}")"
        unlink_name="$(knowledge_link_app_name_from_register_key "$exp")" || unlink_name=''
      fi
    fi
  fi

  for i in "${!paths[@]}"; do
    case "${types[i]:-child}" in
      meta) ;; # 保活 type:meta
      parent) ;;
      *)
        if [[ "$(knowledge_link_identity_from_stored_entry "${repos[i]:-}" "${paths[i]}")" == "$new_identity" ]]; then
          continue
        fi
        ;;
    esac
    newr+=("${repos[i]:-}")
    newp+=("${paths[i]}")
    newd+=("${doc_dirs[i]:-}")
    newa+=("${app_names[i]:-}")
    newl+=("${app_labels[i]:-}")
    newt+=("${types[i]:-child}")
  done

  knowledge_links_write_entries "$LIST_FILE" newr newp newd newa newl newt \
    "$SRC_CHILD_KIND" "$SRC_PARENT_KIND"
  if [[ -n "$unlink_name" ]]; then
    if [[ "$_skt" == 'system' ]]; then
      knowledge_link_remove_application_slot "$_sdoc" "$unlink_name"
    elif [[ "$_skt" == 'company' ]]; then
      knowledge_link_remove_system_slot "$_sdoc" "$unlink_name"
    fi
  fi
  printf '已注销: %s 中的 %s\n' "$LIST_FILE" "$REGISTER_KEY"
}

case "$CMD" in
  link) docs_link_execute_link ;;
  unlink) docs_link_execute_unlink ;;
esac
