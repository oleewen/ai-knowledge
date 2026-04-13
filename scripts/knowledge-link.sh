#!/usr/bin/env bash
# knowledge-link.sh — 在源知识库登记 / 注销目标知识库（仅本地 path）
# 用法: ./scripts/knowledge-link.sh link|unlink --path=<目标仓库根> [--dry-run]
# 须在源 Git 仓库内执行；源、目标均须含合法 .docsconfig 与 KNOWLEDGE_TYPE。
#
# 维护策略 A（已选）：不 source 其他脚本；下列「.docsconfig 解析」与 scripts/docs-config.sh
# §10/§8 中对应函数语义一致，为对照 SSOT 的并行内联。改 .docsconfig 读入语义时须同步
# docs-config.sh 与本段。
set -euo pipefail

# --- Bash 5+（nameref）---------------------------------------------------------
if (( BASH_VERSINFO[0] < 5 )); then
  printf '错误: 需要 Bash 5+，当前: %s\n' "$BASH_VERSION" >&2
  exit 1
fi

# .docsconfig 中 KNOWLEDGE_TYPE 取值（与 docs-config.sh / agent-init 一致）
readonly -a SDX_SUPPORTED_KNOWLEDGE_TYPES=(application system company)

error() { printf '错误: %s\n' "$*" >&2; exit 1; }

# =============================================================================
# 以下为 .docsconfig 读入所需最小子集（策略 A：自包含；与 docs-config.sh 对照维护）
# =============================================================================

# 展开路径中的 ~ 为用户主目录
expand_tilde() {
  local p="${1:-}"
  if [[ "$p" == '~' ]]; then
    printf '%s\n' "${HOME:-}"
  elif [[ "$p" =~ ^~/ ]]; then
    printf '%s\n' "${HOME:-}/${p:2}"
  else
    printf '%s\n' "$p"
  fi
}

# 获取绝对路径（不要求路径已存在；解析符号链接）
abs_path() {
  local p
  p="$(expand_tilde "${1:-}")"
  [[ "$p" == /* ]] || p="$PWD/$p"

  if [[ -d "$p" ]]; then
    (cd -P "$p" 2>/dev/null && pwd)
  else
    local dir base
    dir="$(dirname "$p")"
    base="$(basename "$p")"
    dir="$(cd -P "$dir" 2>/dev/null && pwd || printf '%s' "$dir")"
    printf '%s/%s\n' "$dir" "$base"
  fi
}

# 将 .docsconfig 中读入的 *_ROOT 原始值展开为绝对路径
docsconfig_normalize_root_value() {
  local v="${1:-}"
  v="${v%$'\r'}"
  printf '%s' "$(abs_path "$v")"
}

# 校验 KNOWLEDGE_TYPE 取值
docsconfig_validate_knowledge_type() {
  local v="${1:-}" t
  for t in "${SDX_SUPPORTED_KNOWLEDGE_TYPES[@]}"; do
    [[ "$v" == "$t" ]] && return 0
  done
  printf '[docsconfig] 非法 KNOWLEDGE_TYPE: %s（允许: %s）\n' \
    "$v" "${SDX_SUPPORTED_KNOWLEDGE_TYPES[*]}" >&2
  return 1
}

# 从文件解析 DOC_ROOT / REPO_ROOT / DOC_DIR；可选 AGENT_* / KNOWLEDGE_TYPE（nameref）
docsconfig_read_into() {
  local path="${1:?path}"
  local -n _doc="${2:?}"
  local -n _repo="${3:?}"
  local -n _ddir="${4:?}"
  _doc=''; _repo=''; _ddir=''
  [[ -f "$path" ]] || return 1

  local raw_doc='' raw_repo='' raw_ddir='' raw_ar='' raw_ads='' raw_kt=''
  local line k v
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    case "$line" in
      DOC_ROOT=*|REPO_ROOT=*|DOC_DIR=*|AGENT_ROOT=*|AGENT_DIRS=*|KNOWLEDGE_TYPE=*)
        k="${line%%=*}"
        v="${line#*=}"
        v="${v%$'\r'}"
        if [[ "$k" == 'AGENT_DIRS' && ${#v} -ge 2 && "${v:0:1}" == '"' && "${v: -1}" == '"' ]]; then
          v="${v:1:${#v}-2}"
        fi
        case "$k" in
          DOC_ROOT)         raw_doc="$v"  ;;
          REPO_ROOT)        raw_repo="$v" ;;
          DOC_DIR)          raw_ddir="$v" ;;
          AGENT_ROOT)       raw_ar="$v"   ;;
          AGENT_DIRS)       raw_ads="$v"  ;;
          KNOWLEDGE_TYPE)   raw_kt="$v"   ;;
        esac
        ;;
    esac
  done <"$path"

  [[ -n "$raw_doc"  ]] && _doc="$(docsconfig_normalize_root_value "$raw_doc")"
  [[ -n "$raw_repo" ]] && _repo="$(docsconfig_normalize_root_value "$raw_repo")"
  _ddir="$raw_ddir"

  if (( $# >= 6 )); then
    local -n _aroot="${5:?}"
    local -n _adirs="${6:?}"
    _aroot=''
    [[ -n "$raw_ar" ]] && _aroot="$(docsconfig_normalize_root_value "$raw_ar")"
    _adirs="$raw_ads"
  fi
  if (( $# >= 7 )); then
    local -n _ktype="${7:?}"
    _ktype="$raw_kt"
  fi
  return 0
}

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
    printf '%s\n' '# 知识库建联清单（可由 knowledge-link.sh 维护）'
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

DRY=0
CMD=
TGT_PATH=

while (( $# > 0 )); do
  case "$1" in
    link|unlink) CMD="$1"; shift ;;
    --dry-run)   DRY=1; shift ;;
    --path=*)    TGT_PATH="${1#*=}"; shift ;;
    -h|--help)
      cat >&2 <<'EOF'
用法: ./scripts/knowledge-link.sh link|unlink --path=<目标知识库仓库根> [--dry-run]

  须在「源」知识库 Git 仓库内执行（git rev-parse 取根）。登记文件：
    公司源（KNOWLEDGE_TYPE=company）→ company/knowledge-links.yaml
    系统源（KNOWLEDGE_TYPE=system） → system/knowledge-links.yaml

  允许边：company→system、system→application（源/目标 .docsconfig 须含合法 KNOWLEDGE_TYPE）。

  --dry-run  仅打印将执行的操作，不写文件。

维护策略 A：本脚本自包含，不 source 其它文件；内联 .docsconfig 读入与 docs-config.sh 并行维护。

示例:
  ./scripts/knowledge-link.sh link --path=/abs/path/to/target-system-repo
  ./scripts/knowledge-link.sh unlink --path=/abs/path/to/target-app-repo --dry-run
EOF
      exit 0
      ;;
    *) error "未知参数: $1" ;;
  esac
done

[[ -n "$CMD" ]] || error "请指定子命令: link | unlink"
[[ -n "$TGT_PATH" ]] || error "请指定 --path=<目标仓库根绝对路径>"

SRC_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || error "请在 Git 仓库内执行 knowledge-link"
SRC_CFG="$SRC_ROOT/.docsconfig"
[[ -f "$SRC_CFG" ]] || error "源仓库缺少 .docsconfig: $SRC_CFG"

_sdoc='' _srepo='' _sdd='' _sar='' _sads='' _skt=''
docsconfig_read_into "$SRC_CFG" _sdoc _srepo _sdd _sar _sads _skt || error "无法解析源 .docsconfig"
[[ -n "$_skt" ]] || error "源 .docsconfig 缺少 KNOWLEDGE_TYPE"
docsconfig_validate_knowledge_type "$_skt" || exit 1

expect_target=''
case "$_skt" in
  company) LIST_FILE="$SRC_ROOT/company/knowledge-links.yaml"; expect_target='system' ;;
  system)  LIST_FILE="$SRC_ROOT/system/knowledge-links.yaml"; expect_target='application' ;;
  *) error "源 KNOWLEDGE_TYPE=${_skt} 不支持建联（仅 company 或 system 可作为源）" ;;
esac

TGT_ROOT="$(cd -P "$TGT_PATH" 2>/dev/null && pwd)" || error "目标路径不存在或不可进入: $TGT_PATH"
TGT_CFG="$TGT_ROOT/.docsconfig"
[[ -f "$TGT_CFG" ]] || error "目标仓库缺少 .docsconfig: $TGT_CFG"

_tdoc='' _trepo='' _tdd='' _tar='' _tads='' _tkt=''
docsconfig_read_into "$TGT_CFG" _tdoc _trepo _tdd _tar _tads _tkt || error "无法解析目标 .docsconfig"
[[ -n "$_tkt" ]] || error "目标 .docsconfig 缺少 KNOWLEDGE_TYPE"
docsconfig_validate_knowledge_type "$_tkt" || exit 1
[[ "$_tkt" == "$expect_target" ]] || error "目标须为 ${expect_target} 知识库（KNOWLEDGE_TYPE=${_tkt}）"

declare -a paths=()
while IFS= read -r p; do paths+=("$p"); done < <(knowledge_links_paths_from_file "$LIST_FILE")

have=0
for p in "${paths[@]}"; do
  [[ "$p" == "$TGT_ROOT" ]] && { have=1; break; }
done

case "$CMD" in
  link)
    [[ "$have" -eq 1 ]] && { printf '提示: 已登记，跳过: %s\n' "$TGT_ROOT" >&2; exit 0; }
    paths+=("$TGT_ROOT")
    knowledge_links_write_file "$LIST_FILE" "${paths[@]}"
    printf '已登记: %s → %s\n' "$LIST_FILE" "$TGT_ROOT"
    ;;
  unlink)
    [[ "$have" -eq 0 ]] && { printf '提示: 未找到登记项，跳过: %s\n' "$TGT_ROOT" >&2; exit 0; }
    declare -a newp=()
    for p in "${paths[@]}"; do
      [[ "$p" == "$TGT_ROOT" ]] && continue
      newp+=("$p")
    done
    knowledge_links_write_file "$LIST_FILE" "${newp[@]}"
    printf '已注销: %s 中的 %s\n' "$LIST_FILE" "$TGT_ROOT"
    ;;
esac
