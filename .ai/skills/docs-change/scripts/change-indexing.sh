#!/bin/bash

# document-change - 文档变更索引生成器
# 多源采集（Git / CHANGELOG / 本地文件），输出 changes-index.json + changes-index.md

set -e

DEFAULT_OUTPUT="./changelogs"
DEFAULT_SINCE="2020-01-01 00:00:00.000"

show_help() {
    echo "Usage: $0 [options]"
    echo "从 Git、CHANGELOG、本地文件三个维度采集变更，生成结构化索引"
    echo ""
    echo "Options:"
    echo "  --since TIME    变更起始时间（yyyy-MM-dd HH:mm:ss.SSS 或 epoch ms）"
    echo "  --output DIR    输出目录（默认：$DEFAULT_OUTPUT）"
    echo "  -h, --help      显示帮助信息"
    echo ""
    echo "Examples:"
    echo "  $0 --since '2026-03-20 00:00:00.000' --output ./changelogs/"
    echo "  $0                  # 基于上次 baseline 增量运行"
}

SINCE=""
OUTPUT="$DEFAULT_OUTPUT"

while [[ $# -gt 0 ]]; do
    case $1 in
        --since)  SINCE="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

mkdir -p "$OUTPUT"

INDEX_JSON="$OUTPUT/changes-index.json"

# --- 步骤 1: 时间基准计算 ---

if [[ -n "$SINCE" ]]; then
    if [[ "$SINCE" =~ ^[0-9]+$ ]]; then
        BASELINE_MS="$SINCE"
        BASELINE_TIME=$(date -r "$((BASELINE_MS / 1000))" '+%Y-%m-%d %H:%M:%S.000' 2>/dev/null || \
                        date -d "@$((BASELINE_MS / 1000))" '+%Y-%m-%d %H:%M:%S.000' 2>/dev/null || \
                        echo "$DEFAULT_SINCE")
    else
        BASELINE_TIME="$SINCE"
        BASELINE_MS=$(date -jf '%Y-%m-%d %H:%M:%S' "${SINCE%.*}" '+%s' 2>/dev/null || \
                      date -d "${SINCE%.*}" '+%s' 2>/dev/null || echo "0")
        BASELINE_MS="${BASELINE_MS}000"
    fi
elif [[ -f "$INDEX_JSON" ]]; then
    BASELINE_TIME=$(python3 -c "import json; d=json.load(open('$INDEX_JSON')); print(d.get('metadata',{}).get('baseline_time','$DEFAULT_SINCE'))" 2>/dev/null || echo "$DEFAULT_SINCE")
    BASELINE_MS=$(python3 -c "import json; d=json.load(open('$INDEX_JSON')); print(d.get('metadata',{}).get('baseline_time_ms',0))" 2>/dev/null || echo "0")
else
    BASELINE_TIME="$DEFAULT_SINCE"
    BASELINE_MS="1577836800000"
fi

# --- 步骤 2: Git 可用性检测 ---

IS_GIT_REPO=false
LATEST_GIT_TIME=""
LATEST_GIT_MS=0

if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    IS_GIT_REPO=true
    LATEST_GIT_TIME=$(git log -1 --format='%cI' 2>/dev/null || echo "")
    if [[ -n "$LATEST_GIT_TIME" ]]; then
        LATEST_GIT_MS=$(date -jf '%Y-%m-%dT%H:%M:%S' "${LATEST_GIT_TIME%%[+-]*}" '+%s' 2>/dev/null || \
                        date -d "$LATEST_GIT_TIME" '+%s' 2>/dev/null || echo "0")
        LATEST_GIT_MS="${LATEST_GIT_MS}000"
    fi
fi

# cutoff_time = max(baseline, latest_git)
if [[ "$LATEST_GIT_MS" -gt "$BASELINE_MS" ]]; then
    CUTOFF_TIME="$LATEST_GIT_TIME"
    CUTOFF_MS="$LATEST_GIT_MS"
else
    CUTOFF_TIME="$BASELINE_TIME"
    CUTOFF_MS="$BASELINE_MS"
fi

echo "=== document-change ==="
echo "  baseline_time : $BASELINE_TIME ($BASELINE_MS)"
echo "  is_git_repo   : $IS_GIT_REPO"
echo "  latest_git    : ${LATEST_GIT_TIME:-N/A}"
echo "  cutoff_time   : $CUTOFF_TIME ($CUTOFF_MS)"
echo "  output_dir    : $OUTPUT"

# --- 步骤 3: 数据采集 ---

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 3.1 Git 提交
if $IS_GIT_REPO; then
    echo "Collecting git commits since $BASELINE_TIME ..."
    git log --since="$BASELINE_TIME" --pretty=format:"%H|%aI|%aN|%s" --name-only > "$TEMP_DIR/git_raw.txt" 2>/dev/null || true
fi

# 3.2 CHANGELOG 文件
echo "Scanning CHANGELOG files ..."
find . -maxdepth 3 -type f \( -iname "CHANGELOG*" -o -iname "changes*" \) \
    ! -path "./$OUTPUT/*" ! -path "./.git/*" > "$TEMP_DIR/changelog_files.txt" 2>/dev/null || true

# 3.3 本地文件变更
echo "Scanning local file modifications ..."

EXCLUDE_DIRS=".git|node_modules|.venv|__pycache__|target|build|.cursor|.idea|.vscode"

if [[ "$(uname)" == "Darwin" ]]; then
    find . -type f -newer "$TEMP_DIR" \
        $(echo "$EXCLUDE_DIRS" | tr '|' '\n' | while read d; do echo "-not -path './$d/*'"; done) \
        2>/dev/null | head -500 > "$TEMP_DIR/local_files.txt" || true
else
    find . -type f -newermt "$BASELINE_TIME" \
        $(echo "$EXCLUDE_DIRS" | tr '|' '\n' | while read d; do echo "-not -path './$d/*'"; done) \
        2>/dev/null | head -500 > "$TEMP_DIR/local_files.txt" || true
fi

# --- 步骤 4: 组装输出（委托 Agent 完成 JSON/MD 生成）---

GIT_COUNT=0
if [[ -f "$TEMP_DIR/git_raw.txt" ]]; then
    GIT_COUNT=$(grep -c '^[a-f0-9]\{40\}|' "$TEMP_DIR/git_raw.txt" 2>/dev/null || echo "0")
fi

CHANGELOG_COUNT=0
if [[ -s "$TEMP_DIR/changelog_files.txt" ]]; then
    CHANGELOG_COUNT=$(wc -l < "$TEMP_DIR/changelog_files.txt" | tr -d ' ')
fi

LOCAL_COUNT=0
if [[ -s "$TEMP_DIR/local_files.txt" ]]; then
    LOCAL_COUNT=$(wc -l < "$TEMP_DIR/local_files.txt" | tr -d ' ')
fi

TOTAL=$((GIT_COUNT + CHANGELOG_COUNT + LOCAL_COUNT))
NOW_MS=$(date +%s)000
NOW_STR=$(date '+%Y-%m-%d %H:%M:%S.000')

echo ""
echo "=== 采集结果 ==="
echo "  git_commits      : $GIT_COUNT"
echo "  changelog_files  : $CHANGELOG_COUNT"
echo "  local_files      : $LOCAL_COUNT"
echo "  total            : $TOTAL"
echo ""
echo "Raw data in: $TEMP_DIR"
echo "Agent should parse raw data and generate:"
echo "  - $INDEX_JSON"
echo "  - $OUTPUT/changes-index.md"
