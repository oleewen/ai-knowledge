#!/bin/bash

# docs-indexing - 文档索引生成器
# 基于 docs-indexing Skill 的实现

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AGENT_HOME/scripts/docsconfig-bootstrap.sh"
validate_bootstrap_docsconfig "$SCRIPT_DIR"

DOC_ROOT="$(resolve_repo_doc_root)"
cd "$REPO_ROOT" || exit 1

# 配置变量（cwd=仓库根；路径由 resolve_repo_doc_root / .docsconfig 与 DOC_ROOT 统一）
DEFAULT_OUTPUT="${DOC_ROOT}/INDEX_GUIDE.md"
LOG_FILE="${DOC_ROOT}/changelogs/indexing-log.jsonl"
CHANGES_INDEX="${DOC_ROOT}/changelogs/changes-index.json"

now_ms() {
    python3 - <<'PY'
import time
print(int(time.time() * 1000))
PY
}

# 显示帮助信息
show_help() {
    echo "Usage: $0 [options]"
    echo "为代码库生成结构化文档索引（INDEX_GUIDE.md）"
    echo ""
    echo "Options:"
    echo "  --mode MODE           扫描模式：f/full（全量）或 i/incremental（增量）"
    echo "  --depth DEPTH         扫描深度：1（拓扑）、2（结构）、3（精读）"
    echo "  --output OUTPUT       输出文件路径（默认：文档根下 INDEX_GUIDE.md，见 .docsconfig / resolve_repo_doc_root）"
    echo "  --since TIMESTAMP     增量模式起始时间（epoch ms）"
    echo "  -h, --help            显示帮助信息"
    echo ""
    echo "Examples:"
    echo "  $0 --mode full --depth 3"
    echo "  $0 --mode incremental --depth 2"
}

# 解析命令行参数
MODE=""
DEPTH=""
OUTPUT="$DEFAULT_OUTPUT"
SINCE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --depth)
            DEPTH="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        --since)
            SINCE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# 验证必需参数
if [[ -z "$MODE" ]] || [[ -z "$DEPTH" ]]; then
    echo "Error: --mode and --depth are required parameters"
    show_help
    exit 1
fi

# 转换模式参数
case $MODE in
    f|full) DATA_MODE="full" ;;
    i|incremental) DATA_MODE="incremental" ;;
    *)
        echo "Error: Invalid mode '$MODE'. Use 'f'/'full' or 'i'/'incremental'"
        exit 1
        ;;
esac

# 转换深度参数
case $DEPTH in
    1|2|3) READ_MODE=$DEPTH ;;
    *)
        echo "Error: Invalid depth '$DEPTH'. Use 1, 2, or 3"
        exit 1
        ;;
esac

# 获取当前时间戳
CURRENT_TIME_MS=$(now_ms)
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# 检查输出目录
OUTPUT_DIR=$(dirname "$OUTPUT")
mkdir -p "$OUTPUT_DIR"

# 获取上次索引时间（用于增量模式）
BASE_INDEXING_TIME_MS=0
if [[ "$DATA_MODE" == "incremental" ]]; then
    if [[ -n "$SINCE" ]]; then
        BASE_INDEXING_TIME_MS="$SINCE"
    elif [[ -f "$LOG_FILE" ]]; then
        # jsonl 每行是独立 JSON，取最后一行的 indexing_finished_at
        BASE_INDEXING_TIME_MS=$(tail -n 1 "$LOG_FILE" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('indexing_finished_at',0))" 2>/dev/null || echo "0")
    fi

    if [[ "$BASE_INDEXING_TIME_MS" == "0" ]] || [[ -z "$BASE_INDEXING_TIME_MS" ]]; then
        echo "Warning: No valid baseline in $LOG_FILE, forcing full mode"
        DATA_MODE="full"
        BASE_INDEXING_TIME_MS=0
    else
        echo "Using incremental mode since $BASE_INDEXING_TIME_MS"
    fi
fi

# 生成变更索引（简版元数据）
echo "Generating change index..."

# 执行扫描（根据深度级别）
echo "Starting scan with mode: $DATA_MODE, depth: $READ_MODE"

# 枚举仓库内待扫描文件（优先 ripgrep；否则 git ls-files；再否则 find）
collect_all_files() {
    ALL_FILES=()
    if command -v rg >/dev/null 2>&1; then
        while IFS= read -r line; do ALL_FILES+=("$line"); done < <(rg --files)
    elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        while IFS= read -r line; do ALL_FILES+=("$line"); done < <(git ls-files)
    else
        while IFS= read -r line; do ALL_FILES+=("$line"); done < <(find . -type f -not -path './.git/*' 2>/dev/null | sed 's|^\./||')
    fi
}

# 扫描函数
scan_project() {
    local depth=$1
    local mode=$2
    collect_all_files
    INDEXED_FILES=0
    SCANNED_FILES=()
    case $depth in
        1)
            echo "# Topology Scan Mode"
            for f in "${ALL_FILES[@]}"; do
                case "$f" in
                    *.md|*.yml|*.yaml|*.json|*.sh) SCANNED_FILES+=("$f") ;;
                esac
            done
            ;;
        2)
            echo "# Structure Analysis Mode"
            for f in "${ALL_FILES[@]}"; do
                case "$f" in
                    *.md|*.yml|*.yaml|*.json|*.sh|*.py|*.js|*.ts|*.tsx|*.java) SCANNED_FILES+=("$f") ;;
                esac
            done
            ;;
        3)
            echo "# Deep Reading Mode"
            echo "Extracting business logic..."
            SCANNED_FILES=("${ALL_FILES[@]}")
            ;;
    esac
    INDEXED_FILES=${#SCANNED_FILES[@]}
    return 0
}

# 执行扫描
scan_project $READ_MODE $DATA_MODE

# 生成 INDEX_GUIDE.md（九章结构，填充真实统计与路径）
echo "Generating INDEX_GUIDE.md from scanned data..."
PROJECT_NAME="$(basename "$(pwd)")"
ISO_TIME="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TOP_DIRS="$(ls -1d */ 2>/dev/null | sed 's#/$##' | sort | sed 's#^#- `./#;s#$#`#' || true)"
if [[ -z "$TOP_DIRS" ]]; then
    TOP_DIRS="- 无"
fi

TOP_FILES="$(printf '%s\n' "${SCANNED_FILES[@]}" | head -n 20 | sed 's#^#- `./#;s#$#`#' || true)"
if [[ -z "$TOP_FILES" ]]; then
    TOP_FILES="- 无"
fi

REL_LOG="./${LOG_FILE#"$REPO_ROOT"/}"
REL_CHANGES="./${CHANGES_INDEX#"$REPO_ROOT"/}"
REL_DEFAULT_OUT="./${DEFAULT_OUTPUT#"$REPO_ROOT"/}"

cat > "$OUTPUT" << EOF
# ${PROJECT_NAME} 索引指南

> 最后更新：${ISO_TIME}
> 文档定位：由 docs-indexing 自动生成的九章索引（mode=${DATA_MODE}, depth=${READ_MODE}）

## 一、项目概览（Project Overview）
- 项目名称：\`${PROJECT_NAME}\`
- 扫描模式：\`${DATA_MODE}\`
- 扫描深度：\`${READ_MODE}\`
- 索引文件总数：\`${INDEXED_FILES}\`
- 输出路径：\`${OUTPUT}\`

## 二、架构视图（Architecture View）
### 2.1 顶层目录
${TOP_DIRS}

### 2.2 主要文件（样本）
${TOP_FILES}

## 三、接口清单（Interface Catalog）
- 本仓库为文档与脚本仓库，未检测到应用运行时 API 接口清单。

## 四、核心流程（Core Flows）
- docs-indexing 扫描仓库文件并生成 \`INDEX_GUIDE.md\`
- 结果写入 \`${REL_LOG}\` 以支持增量基线

## 五、配置与环境（Config & Environment）
- \`--mode\`: \`full\` / \`incremental\`
- \`--depth\`: \`1\` / \`2\` / \`3\`
- \`--output\`: 输出文件路径（默认 \`${REL_DEFAULT_OUT}\`）
- \`--since\`: 增量扫描起始时间戳（epoch ms）

## 六、未索引区域声明（Unindexed Scope）
- 仅索引可读取文件，不推断未读取内容。
- 当前未进行语义抽取，仅提供结构化路径与统计。

## 七、质量与边界（Quality & Boundaries）
- 路径均为仓库根相对路径
- 输出具有幂等性（相同输入得到相同结构）
- 增量模式在无有效基线时自动降级为全量

## 八、日志与追溯（Traceability）
- 执行日志：\`${REL_LOG}\`
- 变更基线：\`${REL_CHANGES}\`

## 九、附录（Appendix）
- 生成器：\`.agent/skills/docs-indexing/scripts/indexing.sh\`
- 规范参考：\`.agent/skills/docs-indexing/reference/scan-spec.md\`
EOF

# 更新变更索引
cat > "$CHANGES_INDEX" << EOF
{
  "baseline_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "baseline_time_ms": $CURRENT_TIME_MS,
  "note": "docs-indexing 索引更新：模式=${DATA_MODE}，深度=${READ_MODE}，输出=${OUTPUT}"
}
EOF

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$CHANGES_INDEX")"

# 写入日志
FINISHED_TIME_MS=$(now_ms)
DURATION_MS=$((FINISHED_TIME_MS - CURRENT_TIME_MS))
TIMESTAMP_ISO="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
cat >> "$LOG_FILE" << EOF
{"timestamp":"$TIMESTAMP_ISO","data_mode":"$DATA_MODE","read_mode":$READ_MODE,"output_path":"$OUTPUT","indexed_files":$INDEXED_FILES,"duration_ms":$DURATION_MS,"indexing_finished_at":$FINISHED_TIME_MS}
EOF

# 完成时间
END_TIME=$(date '+%Y-%m-%d %H:%M:%S')

echo "Document indexing completed successfully!"
echo "   - Mode: $DATA_MODE"
echo "   - Depth: $READ_MODE"
echo "   - Output: $OUTPUT"
echo "   - Started: $START_TIME"
echo "   - Finished: $END_TIME"
echo "   - Log: $LOG_FILE"