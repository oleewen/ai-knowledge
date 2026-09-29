#!/bin/bash

# docs-indexing 辅助脚本（技能契约见 agent/skills/docs-indexing）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AGENT_HOME/scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate

DOC_ROOT="$(docsconfig_resolve_doc_root)"
cd "$REPO_ROOT" || exit 1

# cwd=仓库根；路径见 .docsconfig / docsconfig_resolve_doc_root
DEFAULT_OUTPUT="${DOC_ROOT}/INDEX-GUIDE.md"
LOG_FILE="${DOC_ROOT}/changelogs/INDEXING-LOG.md"
INDEXING_LOG_PY="${SCRIPT_DIR}/indexing_log.py"
mkdir -p "${DOC_ROOT}/changelogs"

now_ms() {
    python3 - <<'PY'
import time
print(int(time.time() * 1000))
PY
}

show_help() {
    echo "Usage: $0 [options]"
    echo "索引指南辅助脚本；参数须与技能会话确认一致"
    echo ""
    echo "  --mode f|full|i|incremental"
    echo "  --depth 1|2|3"
    echo "  --output PATH   (默认文档根 INDEX-GUIDE.md；文件名固定)"
  echo "  --since MS      增量 epoch ms"
  echo "  --rewrite       重建 INDEX-GUIDE；默认只刷新扫描统计并写 LOG"
    echo "  -h, --help"
}

# 解析命令行参数
MODE=""
DEPTH=""
OUTPUT="$DEFAULT_OUTPUT"
SINCE=""
REWRITE=0

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
        --rewrite)
            REWRITE=1
            shift
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

if [[ "$(basename "$OUTPUT")" != "INDEX-GUIDE.md" ]]; then
    echo "Error: docs-indexing 输出文件名固定为 INDEX-GUIDE.md，当前为 '$(basename "$OUTPUT")'" >&2
    exit 1
fi

# 获取上次索引时间（用于增量模式）；主表首行，否则回退文内 HTML 注释（见 indexing-log-spec）
BASE_INDEXING_TIME_MS=0
SINCE_MS_FOR_LOG=0
if [[ "$DATA_MODE" == "incremental" ]]; then
    if [[ -n "$SINCE" ]]; then
        BASE_INDEXING_TIME_MS="$SINCE"
        SINCE_MS_FOR_LOG="$SINCE"
    elif [[ -f "$LOG_FILE" ]]; then
        BASE_INDEXING_TIME_MS=$(
            python3 "$INDEXING_LOG_PY" read-baseline "$LOG_FILE" 2>/dev/null || echo "0"
        )
        SINCE_MS_FOR_LOG="$BASE_INDEXING_TIME_MS"
    fi

    if [[ "$BASE_INDEXING_TIME_MS" == "0" ]] || [[ -z "$BASE_INDEXING_TIME_MS" ]]; then
        echo "[ERROR] incremental 需要有效基线：主表第一行 indexing_finished_ms，"
        echo "  或显式 \`--since <epoch ms>\`。"
        echo "  可改 \`--mode full\`，或先补全 ${LOG_FILE} 见 agent/skills/docs-indexing/references/indexing-log-spec.md" >&2
        exit 1
    else
        echo "Using incremental mode with baseline (since) $BASE_INDEXING_TIME_MS"
    fi
else
    SINCE_MS_FOR_LOG=0
fi

# 生成变更索引（简版元数据）
echo "Generating change index..."

# 执行扫描（根据深度级别）
echo "Starting scan with mode: $DATA_MODE, depth: $READ_MODE"

# 枚举 DOC_ROOT 内待扫描文件；不进入隐藏目录或软链
collect_all_files() {
    ALL_FILES=()
    local dir file rel
    while IFS= read -r dir; do
        for file in "$dir"/*; do
            [[ -e "$file" && ! -L "$file" && -f "$file" ]] || continue
            rel="${file#"$REPO_ROOT"/}"
            case "${rel##*/}" in
                .DS_Store|viz.html) continue ;;
            esac
            ALL_FILES+=("$rel")
        done
    done < <(
        find "$DOC_ROOT" \
            \( -type d \( -name '.*' -o -name .git -o -name node_modules -o -name target -o -name build \) -prune \) \
            -o \( -type d ! -type l -print \)
    )
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

# 生成扫描运行元数据；默认不改既有 INDEX-GUIDE
echo "Generating scan metadata..."
PROJECT_NAME="$(basename "$(pwd)")"
ISO_TIME="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TOP_DIRS="$(
    printf '%s\n' "${SCANNED_FILES[@]}" \
        | sed "s#^${DOC_DIR}/##;s#/[^/]*\$##;s#^\$#.#" | sort -u \
        | sed 's#^#- `#;s#$#`#'
)"
if [[ -z "$TOP_DIRS" ]]; then
    TOP_DIRS="- 无"
fi

TOP_FILES="$(printf '%s\n' "${SCANNED_FILES[@]}" | head -n 20 | sed 's#^#- `./#;s#$#`#' || true)"
if [[ -z "$TOP_FILES" ]]; then
    TOP_FILES="- 无"
fi

REL_LOG="./${LOG_FILE#"$REPO_ROOT"/}"
REL_DEFAULT_OUT="./${DEFAULT_OUTPUT#"$REPO_ROOT"/}"
REL_LOG="${REL_LOG//.\/././}"
REL_DEFAULT_OUT="${REL_DEFAULT_OUT//.\/././}"

TMP_OUT="$(mktemp)"
cat > "$TMP_OUT" << EOF
### 扫描运行（${ISO_TIME}）

| 项 | 值 |
|----|----|
| mode / depth | \`${DATA_MODE} / ${READ_MODE}\` |
| 文件总数 | \`${INDEXED_FILES}\` |
| 输出路径 | \`${REL_DEFAULT_OUT}\` |
| 运行日志 | \`${REL_LOG}\` |

<details>
<summary>扫描目录</summary>

${TOP_DIRS}

</details>
EOF

python3 - "$OUTPUT" "$TMP_OUT" "$REWRITE" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

out_path = Path(sys.argv[1])
gen_path = Path(sys.argv[2])
generated = gen_path.read_text(encoding="utf-8").rstrip() + "\n"
rewrite = sys.argv[3] == "1"

RE_OKF = re.compile(r"<!--\s*okf:begin\s*-->.*?<!--\s*okf:end\s*-->", re.DOTALL)
RE_IDX = re.compile(
    r"<!--\s*docs-indexing:begin\s*-->.*?<!--\s*docs-indexing:end\s*-->",
    re.DOTALL,
)

def split_frontmatter(text: str) -> tuple[str, str]:
    if not text.lstrip().startswith("---"):
        return "", text
    lines = text.splitlines(keepends=True)
    start = None
    for i, line in enumerate(lines):
        if line.strip() == "---":
            start = i
            break
        if line.strip():
            return "", text
    if start is None:
        return "", text
    for j in range(start + 1, len(lines)):
        if lines[j].strip() == "---":
            fm = "".join(lines[: j + 1]).rstrip() + "\n"
            body = "".join(lines[j + 1 :]).lstrip("\n")
            return fm, body
    return "", text

existing = out_path.read_text(encoding="utf-8") if out_path.is_file() else ""
fm, body = split_frontmatter(existing)

idx_wrapped = (
    "<!-- docs-indexing:begin -->\n"
    + generated
    + "<!-- docs-indexing:end -->\n"
)

if rewrite:
    if RE_IDX.search(body):
        body = RE_IDX.sub(idx_wrapped, body, count=1)
    else:
        if not body.strip():
            body = (
                f"# {out_path.parent.name} INDEX-GUIDE\n\n"
                "> 由 docs-indexing 生成扫描运行块；九章内容由 Agent 按契约维护。\n\n"
                + idx_wrapped
            )
        else:
            body = body.rstrip() + "\n\n" + idx_wrapped

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text((fm + body).rstrip() + "\n", encoding="utf-8")
else:
    print("scan-only: INDEX-GUIDE 未修改；使用 --rewrite 才更新运行块")

out_path.parent.mkdir(parents=True, exist_ok=True)
out_path.write_text((fm + body).rstrip() + "\n", encoding="utf-8")
PY

rm -f "$TMP_OUT"

# 写入索引运行日志（主表、最新在上；见 indexing_log.py / indexing-log-spec）
FINISHED_TIME_MS=$(now_ms)
DURATION_MS=$((FINISHED_TIME_MS - CURRENT_TIME_MS))
TIMESTAMP_ISO="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
REL_OUTPUT=$(
    REPO_ROOT="${REPO_ROOT}" OUT="${OUTPUT}" python3 -c \
        "import os, os.path as p; r=os.environ['REPO_ROOT']; o=os.environ['OUT']; \
print(p.relpath(p.abspath(o), p.abspath(r)))" 2>/dev/null || echo "$OUTPUT"
)
SUMMARY="${DATA_MODE} d${READ_MODE}"
python3 "$INDEXING_LOG_PY" append "$LOG_FILE" \
    --finished-ms "$FINISHED_TIME_MS" \
    --indexed-at "$TIMESTAMP_ISO" \
    --mode "$DATA_MODE" \
    --depth "$READ_MODE" \
    --since-ms "$SINCE_MS_FOR_LOG" \
    --output-path "$REL_OUTPUT" \
    --file-count "$INDEXED_FILES" \
    --duration-ms "$DURATION_MS" \
    --summary "$SUMMARY"

# 完成时间
END_TIME=$(date '+%Y-%m-%d %H:%M:%S')

echo "Document indexing completed successfully!"
echo "   - Mode: $DATA_MODE"
echo "   - Depth: $READ_MODE"
echo "   - Output: $OUTPUT"
echo "   - Started: $START_TIME"
echo "   - Finished: $END_TIME"
echo "   - Log: $LOG_FILE"
