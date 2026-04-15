#!/usr/bin/env bash
# docs-link.sh — 在源知识库登记 / 注销目标知识库（仅本地 path）
# 用法: ./scripts/docs-link.sh --link|--unlink --target=<目标仓库根> [--dry-run]
# 须在源 Git 仓库内执行；link 需校验源、目标 .docsconfig 与 KNOWLEDGE_TYPE；
# unlink 支持目标失联场景（仅按登记 path 注销）。
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./link-config.sh
source "${SCRIPT_DIR}/link-config.sh"

error() { printf '错误: %s\n' "$*" >&2; exit 1; }
warn() { printf '警告: %s\n' "$*" >&2; }

# =============================================================================
# knowledge-links.yaml
# =============================================================================

# 从 knowledge-links.yaml 收集已有 path（最小解析）
knowledge_links_paths_from_file() {
  local f="${1:?}"
  [[ -f "$f" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*-[[:space:]]*path:[[:space:]]*(.*)$ ]] || continue
    local v="${BASH_REMATCH[1]}"
    v="${v#\"}"; v="${v%\"}"
    v="${v#\'}"; v="${v%\'}"
    [[ -n "$v" ]] && printf '%s\n' "$v"
  done <"$f"
}

# 写出 knowledge-links.yaml（覆盖）
knowledge_links_write_file() {
  local f="${1:?}"
  shift
  local -a paths=( "$@" )
  local d
  d="$(dirname "$f")"
  [[ "$DRY" == '1' ]] && { printf '[dry-run] 将写入 %s（%d 条 path）\n' "$f" "${#paths[@]}" >&2; return 0; }
  mkdir -p "$d"
  umask 022
  {
    printf '%s\n' '# 知识库建联清单（可由 docs-link.sh 维护）'
    printf '%s\n' 'links:'
    local p
    for p in "${paths[@]}"; do
      printf '  - path: "%s"\n' "${p//\"/\\\"}"
    done
  } >"$f"
}

# =============================================================================
# CLI
# =============================================================================

DRY="${KLINK_DEFAULT_DRY_RUN}"
CMD=''
TARGET_RAW=''

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
用法: ./scripts/docs-link.sh --link|--unlink --target=<目标知识库仓库根> [--dry-run]

  --link / --unlink 二选一，不得同时出现。

  须在「源」知识库 Git 仓库内执行（git rev-parse 取根）。登记文件：源 .docsconfig 的 DOC_ROOT/knowledge-links.yaml

  允许边：company→system、system→application（源/目标 .docsconfig 须含合法 KNOWLEDGE_TYPE）。
  unlink 支持目标失联（路径不存在或目标仓库配置缺失）时按登记 path 注销。

  --dry-run  仅打印将执行的操作，不写文件。
  --target   目标知识库仓库根；兼容旧参数 --path（已弃用）。

示例:
  ./scripts/docs-link.sh --target=~/workspaces/target-repo --link
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

if [[ "$CMD" == 'link' ]]; then
  TGT_ROOT="$(cd -P "$TARGET_KEY" 2>/dev/null && pwd)" || error "目标路径不存在或不可进入: $TARGET_KEY"
  TGT_CFG="$TGT_ROOT/.docsconfig"
  [[ -f "$TGT_CFG" ]] || error "目标仓库缺少 .docsconfig: $TGT_CFG"

  _tdoc='' _trepo='' _tdd='' _tkt=''
  docsconfig_read_into "$TGT_CFG" _tdoc _trepo _tdd _tkt || error "无法解析目标 .docsconfig"
  [[ -n "$_tkt" ]] || error "目标 .docsconfig 缺少 KNOWLEDGE_TYPE"
  docsconfig_validate_knowledge_type "$_tkt" || exit 1
  [[ "$_tkt" == "$expect_target" ]] || error "目标须为 ${expect_target} 知识库（KNOWLEDGE_TYPE=${_tkt}）"
  TARGET_KEY="$TGT_ROOT"
fi

declare -a paths=()
while IFS= read -r p; do paths+=("$p"); done < <(knowledge_links_paths_from_file "$LIST_FILE")

have=0
for p in "${paths[@]}"; do
  [[ "$p" == "$TARGET_KEY" ]] && { have=1; break; }
done

case "$CMD" in
  link)
    [[ "$have" -eq 1 ]] && { printf '提示: 已登记，跳过: %s\n' "$TARGET_KEY" >&2; exit 0; }
    paths+=("$TARGET_KEY")
    knowledge_links_write_file "$LIST_FILE" "${paths[@]}"
    printf '已登记: %s → %s\n' "$LIST_FILE" "$TARGET_KEY"
    ;;
  unlink)
    [[ "$have" -eq 0 ]] && { printf '提示: 未找到登记项，跳过: %s\n' "$TARGET_KEY" >&2; exit 0; }
    declare -a newp=()
    for p in "${paths[@]}"; do
      [[ "$p" == "$TARGET_KEY" ]] && continue
      newp+=("$p")
    done
    knowledge_links_write_file "$LIST_FILE" "${newp[@]}"
    printf '已注销: %s 中的 %s\n' "$LIST_FILE" "$TARGET_KEY"
    ;;
esac
