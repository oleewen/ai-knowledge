#!/usr/bin/env bash
# docs-indexing 候选扫描入口；完成锚点由 Agent 在指南完成后显式写入。
set -euo pipefail

show_help() {
    cat <<HELP
Usage: $0 [options]
索引指南候选扫描；默认只读，不生成九章或写入完成锚点。

  --mode f|full|i|incremental
  --depth 1|2|3
  --output PATH   默认 DOC_DIR/INDEX-GUIDE.md；相对路径基于仓库根
  --since MS      正整数 epoch ms；增量模式优先使用此基线
  --rewrite       仅更新 docs-indexing:begin/end 运行块
  --dry-run       只读预览，优先于 --rewrite，不创建输出目录
  -h, --help
HELP
}

fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
require_value() {
    [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || fail "$1 缺少参数值"
}

MODE=""
DEPTH=""
OUTPUT=""
SINCE=""
REWRITE=0
DRY_RUN=0

# help 与参数校验须先于配置加载，使错误不被配置缺失掩盖。
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode) require_value "$@"; MODE="$2"; shift 2 ;;
        --depth) require_value "$@"; DEPTH="$2"; shift 2 ;;
        --output) require_value "$@"; OUTPUT="$2"; shift 2 ;;
        --since) require_value "$@"; SINCE="$2"; shift 2 ;;
        --rewrite) REWRITE=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) fail "未知参数: $1" ;;
    esac
done

case "$MODE" in
    f|full) MODE=full ;;
    i|incremental) MODE=incremental ;;
    *) fail "--mode 须为 f/full/i/incremental" ;;
esac
case "$DEPTH" in
    1|2|3) ;;
    *) fail "--depth 须为 1、2 或 3" ;;
esac
if [[ -n "$SINCE" ]] && { [[ ! "$SINCE" =~ ^[0-9]+$ ]] || [[ "$SINCE" =~ ^0+$ ]]; }; then
    fail "--since 须为正整数 epoch ms"
fi
if [[ -n "$OUTPUT" && "${OUTPUT##*/}" != INDEX-GUIDE.md ]]; then
    fail "--output 文件名固定为 INDEX-GUIDE.md"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AGENT_HOME/scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate
repo_abs="$(docsconfig_repo_abs)"
doc_abs="$(docsconfig_doc_abs)"
[[ -n "$OUTPUT" ]] || OUTPUT="$doc_abs/INDEX-GUIDE.md"

args=(--repo "$repo_abs" --doc-root "$doc_abs" --mode "$MODE" --depth "$DEPTH" --output "$OUTPUT")
[[ -z "$SINCE" ]] || args+=(--since "$SINCE")
(( REWRITE == 0 )) || args+=(--rewrite)
(( DRY_RUN == 0 )) || args+=(--dry-run)
# -B 防止只读扫描在脚本目录创建 __pycache__。
exec python3 -B "$SCRIPT_DIR/indexing.py" "${args[@]}"
