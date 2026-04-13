#!/bin/bash

# docs-change - 原始变更数据采集器
#
# 职责：采集三源原始数据并输出到临时目录，供 Agent 解析并写入 CHANGE-LOG.md（Markdown）。
# 不负责：CHANGE-LOG 正文排版、时间格式统一、数据合并排序（由 Agent 完成）。
#
# 输出文件（写入 {output_dir}/.raw/）：
#   git_commits.txt     - git log 原始输出（格式：HASH|ISO_TIME|AUTHOR|MESSAGE\nFILE\n...）
#   changelog_files.txt - 找到的 CHANGELOG 文件路径列表
#   local_files.txt     - mtime 超过基线的本地文件路径列表
#   meta.env            - 采集元信息（BASELINE_TIME、CUTOFF_TIME、IS_GIT_REPO 等）

set -euo pipefail

DEFAULT_OUTPUT="./changelogs"
DEFAULT_SINCE="2020-01-01 00:00:00.000"
DEFAULT_SINCE_MS="1577836800000"

# ── 帮助 ──────────────────────────────────────────────────────────────────────

show_help() {
    cat <<EOF
Usage: $0 [options]

从 Git、CHANGELOG、本地文件三个维度采集原始变更数据。

Options:
  --since TIME    变更起始时间（yyyy-MM-dd HH:mm:ss.SSS 或 epoch ms）
  --output DIR    输出目录（默认：$DEFAULT_OUTPUT）
  -h, --help      显示帮助

Examples:
  $0 --since '2026-03-20 00:00:00.000' --output ./changelogs/
  $0                  # 基于上次 baseline 增量运行
EOF
}

# ── 参数解析 ──────────────────────────────────────────────────────────────────

SINCE=""
OUTPUT="$DEFAULT_OUTPUT"

while [[ $# -gt 0 ]]; do
    case $1 in
        --since)  SINCE="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "[ERROR] Unknown option: $1"; show_help; exit 1 ;;
    esac
done

mkdir -p "$OUTPUT"
RAW_DIR="$OUTPUT/.raw"
mkdir -p "$RAW_DIR"

CHANGE_LOG_MD="$OUTPUT/CHANGE-LOG.md"

# ── 步骤 1：时间基准计算 ──────────────────────────────────────────────────────

to_ms() {
    # 将时间字符串或 epoch ms 转为 13 位毫秒戳
    local t="$1"
    if [[ "$t" =~ ^[0-9]{13}$ ]]; then
        echo "$t"
    elif [[ "$t" =~ ^[0-9]{10}$ ]]; then
        echo "${t}000"
    else
        local s
        s=$(date -jf '%Y-%m-%d %H:%M:%S' "${t%.*}" '+%s' 2>/dev/null || \
            date -d "${t%.*}" '+%s' 2>/dev/null || echo "0")
        echo "${s}000"
    fi
}

if [[ -n "$SINCE" ]]; then
    BASELINE_TIME="$SINCE"
    BASELINE_MS=$(to_ms "$SINCE")
elif [[ -f "$CHANGE_LOG_MD" ]]; then
    # 从 CHANGE-LOG.md 文末 HTML 注释读取：<!-- docs-change:baseline_time_ms=... -->
    readarray -t _BL < <(python3 - <<PY
import re
from datetime import datetime

path = r"""$CHANGE_LOG_MD"""
default_ms = "$DEFAULT_SINCE_MS"
default_time = "$DEFAULT_SINCE"
try:
    text = open(path, encoding="utf-8").read()
except OSError:
    print(default_time)
    print(default_ms)
    raise SystemExit
ms_list = re.findall(r"<!-- docs-change:baseline_time_ms=(\d+) -->", text)
if not ms_list:
    print(default_time)
    print(default_ms)
    raise SystemExit
ms = ms_list[-1]
dt = datetime.utcfromtimestamp(int(ms) / 1000.0)
print(dt.strftime("%Y-%m-%d %H:%M:%S.000"))
print(ms)
PY
)
    BASELINE_TIME="${_BL[0]}"
    BASELINE_MS="${_BL[1]}"
else
    BASELINE_TIME="$DEFAULT_SINCE"
    BASELINE_MS="$DEFAULT_SINCE_MS"
fi

# ── 步骤 2：Git 可用性检测 ────────────────────────────────────────────────────

IS_GIT_REPO=false
LATEST_GIT_TIME=""
LATEST_GIT_MS=0

if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    IS_GIT_REPO=true
    LATEST_GIT_TIME=$(git log -1 --format='%cI' 2>/dev/null || echo "")
    if [[ -n "$LATEST_GIT_TIME" ]]; then
        LATEST_GIT_MS=$(to_ms "$LATEST_GIT_TIME")
    fi
else
    echo "[WARN] Not a git repository, skipping git source."
fi

# cutoff_time = max(baseline, latest_git)
if [[ "$LATEST_GIT_MS" -gt "$BASELINE_MS" ]]; then
    CUTOFF_TIME="$LATEST_GIT_TIME"
    CUTOFF_MS="$LATEST_GIT_MS"
else
    CUTOFF_TIME="$BASELINE_TIME"
    CUTOFF_MS="$BASELINE_MS"
fi

# ── 步骤 3：数据采集 ──────────────────────────────────────────────────────────

# 3.1 Git 提交（过滤：commit_time > baseline_time）
if $IS_GIT_REPO; then
    echo "[INFO] Collecting git commits since $BASELINE_TIME ..."
    git log --since="$BASELINE_TIME" \
        --pretty=format:"%H|%aI|%aN|%s" --name-only \
        > "$RAW_DIR/git_commits.txt" 2>/dev/null || true
    GIT_COUNT=$(grep -c '^[a-f0-9]\{40\}|' "$RAW_DIR/git_commits.txt" 2>/dev/null || echo "0")
else
    touch "$RAW_DIR/git_commits.txt"
    GIT_COUNT=0
fi

# 3.2 CHANGELOG 文件（过滤：entry_time > cutoff_time，由 Agent 解析）
echo "[INFO] Scanning CHANGELOG files ..."
find . -maxdepth 3 -type f \( -iname "CHANGELOG*" -o -iname "CHANGE-LOG.md" -o -iname "changes*" \) \
    ! -path "./$OUTPUT/*" \
    ! -path "./.git/*" \
    > "$RAW_DIR/changelog_files.txt" 2>/dev/null || true
CHANGELOG_FILE_COUNT=$(wc -l < "$RAW_DIR/changelog_files.txt" | tr -d ' ')

# 3.3 本地文件变更（过滤：mtime > cutoff_time）
echo "[INFO] Scanning local file modifications since $CUTOFF_TIME ..."

EXCLUDE_PATHS=(
    "./.git" "./node_modules" "./.venv" "./__pycache__"
    "./target" "./build" "./.cursor" "./.idea" "./.vscode"
    "./$OUTPUT"
)

EXCLUDE_ARGS=()
for p in "${EXCLUDE_PATHS[@]}"; do
    EXCLUDE_ARGS+=(-not -path "$p/*")
done

if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: 用 python3 做 mtime 过滤（find -newermt 在 macOS 上行为不一致）
    python3 - "$CUTOFF_MS" "$RAW_DIR/local_files.txt" "${EXCLUDE_PATHS[@]}" <<'PYEOF'
import os, sys, time

cutoff_ms = int(sys.argv[1])
output_file = sys.argv[2]
exclude_dirs = set(p.lstrip('./') for p in sys.argv[3:])

results = []
for root, dirs, files in os.walk('.'):
    # 排除目录
    dirs[:] = [d for d in dirs if os.path.join(root, d).lstrip('./') not in exclude_dirs
               and not any(os.path.join(root, d).startswith('./' + e) for e in exclude_dirs)]
    for f in files:
        path = os.path.join(root, f)
        try:
            mtime_ms = int(os.path.getmtime(path) * 1000)
            if mtime_ms > cutoff_ms:
                results.append(path)
        except OSError:
            pass
        if len(results) >= 500:
            break

with open(output_file, 'w') as fh:
    fh.write('\n'.join(results))
PYEOF
else
    find . -type f -newermt "$CUTOFF_TIME" \
        "${EXCLUDE_ARGS[@]}" \
        2>/dev/null | head -500 > "$RAW_DIR/local_files.txt" || true
fi

LOCAL_COUNT=$(wc -l < "$RAW_DIR/local_files.txt" | tr -d ' ')

# ── 步骤 4：输出元信息供 Agent 消费 ──────────────────────────────────────────

cat > "$RAW_DIR/meta.env" <<EOF
BASELINE_TIME="$BASELINE_TIME"
BASELINE_MS="$BASELINE_MS"
CUTOFF_TIME="$CUTOFF_TIME"
CUTOFF_MS="$CUTOFF_MS"
LATEST_GIT_TIME="$LATEST_GIT_TIME"
LATEST_GIT_MS="$LATEST_GIT_MS"
IS_GIT_REPO="$IS_GIT_REPO"
OUTPUT_DIR="$OUTPUT"
GIT_COUNT="$GIT_COUNT"
CHANGELOG_FILE_COUNT="$CHANGELOG_FILE_COUNT"
LOCAL_COUNT="$LOCAL_COUNT"
EOF

echo ""
echo "=== docs-change 采集完成 ==="
echo "  baseline_time        : $BASELINE_TIME"
echo "  cutoff_time          : $CUTOFF_TIME"
echo "  is_git_repo          : $IS_GIT_REPO"
echo "  git_commits          : $GIT_COUNT"
echo "  changelog_files      : $CHANGELOG_FILE_COUNT"
echo "  local_files_modified : $LOCAL_COUNT"
echo ""
echo "原始数据目录: $RAW_DIR"
echo "  git_commits.txt      - git log 原始输出"
echo "  changelog_files.txt  - CHANGELOG 文件路径列表"
echo "  local_files.txt      - 本地变更文件路径列表"
echo "  meta.env             - 时间基准与统计元信息"
echo ""
echo "下一步：Agent 读取以上文件，解析 CHANGELOG 条目（过滤 entry_time > cutoff_time），"
echo "        合并三源数据，按 time_ms 倒序排列，写入/更新："
echo "  $OUTPUT/CHANGE-LOG.md（Markdown；文末须更新 <!-- docs-change:baseline_time_ms=... -->）"
