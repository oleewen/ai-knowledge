#!/bin/bash

# document-indexing - 文档索引生成器
# 基于 document-indexing Skill 的实现

set -e

# 配置变量
DEFAULT_OUTPUT="./system/INDEX_GUIDE.md"
LOG_FILE="./system/changelogs/indexing-log.jsonl"
CHANGES_INDEX="./system/changelogs/changes-index.json"

# 显示帮助信息
show_help() {
    echo "Usage: $0 [options]"
    echo "为代码库生成结构化文档索引（INDEX_GUIDE.md）"
    echo ""
    echo "Options:"
    echo "  --mode MODE           扫描模式：f/full（全量）或 i/incremental（增量）"
    echo "  --depth DEPTH         扫描深度：1（拓扑）、2（结构）、3（精读）"
    echo "  --output OUTPUT       输出文件路径（默认：$DEFAULT_OUTPUT）"
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
CURRENT_TIME_MS=$(date +%s%3N)
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# 检查输出目录
OUTPUT_DIR=$(dirname "$OUTPUT")
mkdir -p "$OUTPUT_DIR"

# 检查changes-index.json是否存在
if [[ ! -f "$CHANGES_INDEX" ]]; then
    echo "Warning: $CHANGES_INDEX not found, forcing full mode"
    DATA_MODE="full"
fi

# 获取上次索引时间（用于增量模式）
if [[ "$DATA_MODE" == "incremental" ]]; then
    if [[ -f "$CHANGES_INDEX" ]]; then
        BASE_INDEXING_TIME_MS=$(jq -r '.baseline_time_ms' "$CHANGES_INDEX" 2>/dev/null || echo "0")
        if [[ "$BASE_INDEXING_TIME_MS" == "null" ]] || [[ "$BASE_INDEXING_TIME_MS" == "0" ]]; then
            echo "Warning: Invalid baseline time in $CHANGES_INDEX, forcing full mode"
            DATA_MODE="full"
        else
            echo "Using incremental mode since $BASE_INDEXING_TIME_MS"
        fi
    else
        DATA_MODE="full"
    fi
fi

# 生成变更索引（模拟）
echo "Generating change index..."
echo "[]" > "$CHANGES_INDEX"

# 执行扫描（根据深度级别）
echo "Starting scan with mode: $DATA_MODE, depth: $READ_MODE"

# 扫描函数
scan_project() {
    local depth=$1
    local mode=$2

    # 创建临时目录
    local temp_dir=$(mktemp -d)

    case $depth in
        1)
            # 拓扑扫描
            echo "# Topology Scan Mode"
            find . -type f -name "*.md" -o -name "*.xml" -o -name "*.yml" -o -name "*.yaml" | head -50 | sort > "$temp_dir/files.txt"
            ;;
        2)
            # 结构分析
            echo "# Structure Analysis Mode"
            find . -type f \( -name "*.md" -o -name "*.java" -o -name "*.xml" -o -name "*.yml" -o -name "*.yaml" \) | head -100 | sort > "$temp_dir/files.txt"

            # 提取类名和函数名（示例）
            echo "Extracting class and function names..."
            find . -name "*.java" -exec grep -l "class\|interface\|@Service\|@Component" {} \; | head -10 | sort > "$temp_dir/classes.txt"
            ;;
        3)
            # 精读提取
            echo "# Deep Reading Mode"
            find . -type f \( -name "*.md" -o -name "*.java" -o -name "*.xml" -o -name "*.yml" -o -name "*.yaml" \) | sort > "$temp_dir/files.txt"

            # 提取业务逻辑（示例）
            echo "Extracting business logic..."
            find . -name "*.java" -exec grep -l "public\|private\|void\|@Transactional" {} \; | head -20 | sort > "$temp_dir/business.txt"
            ;;
    esac

    return 0
}

# 执行扫描
scan_project $READ_MODE $DATA_MODE

# 从模板生成 INDEX_GUIDE.md
echo "Generating INDEX_GUIDE.md from template..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/../assets/index-guide-template.md"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template not found at $TEMPLATE_FILE"
    echo "Hint: The template should be at assets/index-guide-template.md relative to the skill root"
    exit 1
fi

cp "$TEMPLATE_FILE" "$OUTPUT"
echo "Template copied to $OUTPUT (Agent fills in actual scan data)"

# 更新变更索引
cat > "$CHANGES_INDEX" << EOF
{
  "baseline_time": "$(date '+%Y-%m-%d %H:%M:%S.%3N')",
  "baseline_time_ms": $CURRENT_TIME_MS,
  "note": "document-indexing 索引更新：模式=$DATA_MODE，深度=$READ_MODE，输出=$OUTPUT"
}
EOF

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 写入日志
FINISHED_TIME_MS=$(date +%s%3N)
cat >> "$LOG_FILE" << EOF
{"indexing_started_at_ms": $CURRENT_TIME_MS, "indexing_finished_at_ms": $FINISHED_TIME_MS, "data_mode": "$DATA_MODE", "read_mode": $READ_MODE, "base_indexing_finished_at_ms": ${BASE_INDEXING_TIME_MS:-0}, "index_output_path": "$OUTPUT"}
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