#!/usr/bin/env bash
set -euo pipefail
# 追加 system/changelogs/DISTILL-LOG.md（最新在前；共用表，app 分列）。

usage() {
    cat <<'EOF'
Usage:
  append-change-log.sh --app APP --changelog-id ID --changelog-time TIME [--archived-at ISO_TIME] [--summary TEXT]

Required:
  --app             应用名
  --changelog-id    本次蒸馏对应的应用变更 ID
  --changelog-time  应用变更时间（原始记录时间）

Optional:
  --archived-at     蒸馏时间（默认：当前 UTC ISO8601）
  --summary         一句话摘要
EOF
}

APP=""
CHANGELOG_ID=""
CHANGELOG_TIME=""
ARCHIVED_AT=""
SUMMARY=""

while [[ $# -gt 0 ]]; do
    case "${1}" in
        --app)            APP="${2:-}";            shift 2 ;;
        --changelog-id)   CHANGELOG_ID="${2:-}";   shift 2 ;;
        --changelog-time) CHANGELOG_TIME="${2:-}"; shift 2 ;;
        --archived-at)    ARCHIVED_AT="${2:-}";    shift 2 ;;
        --summary)        SUMMARY="${2:-}";        shift 2 ;;
        -h|--help)        usage; exit 0 ;;
        *)
            echo "[ERROR] 未知参数: ${1}" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ -z "${APP}" || -z "${CHANGELOG_ID}" || -z "${CHANGELOG_TIME}" ]]; then
    echo "[ERROR] 缺少必填参数：--app --changelog-id --changelog-time" >&2
    usage >&2
    exit 1
fi

if [[ ! "${APP}" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
    echo "[ERROR] --app 格式非法：${APP}" >&2
    exit 1
fi

if [[ -z "${ARCHIVED_AT}" ]]; then
    ARCHIVED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
fi

# 转义 Markdown 表格单元格中的竖线与换行
escape_md_cell() {
    local raw="${1}"
    raw="$(printf '%s' "${raw}" | tr '\n' ' ')"
    raw="${raw//|/\\|}"
    printf '%s' "${raw}"
}

# 蒸馏批次总账（所有应用共用）
LOG_FILE="system/changelogs/DISTILL-LOG.md"
mkdir -p "$(dirname "${LOG_FILE}")"

# 文件不存在时初始化（含表头）
if [[ ! -f "${LOG_FILE}" ]]; then
    {
        echo "# DISTILL LOG"
        echo
        echo "| app | changelog_id | changelog_time | distilled_at | summary |"
        echo "|---|---|---|---|---|"
    } > "${LOG_FILE}"
fi

ROW="| $(escape_md_cell "${APP}") | $(escape_md_cell "${CHANGELOG_ID}") | $(escape_md_cell "${CHANGELOG_TIME}") | $(escape_md_cell "${ARCHIVED_AT}") | $(escape_md_cell "${SUMMARY}") |"

# 将新记录插入分隔行（|---|...）之后、上一条记录之前，实现最新在前
tmp_file="$(mktemp)"
awk -v row="${ROW}" '
    BEGIN { inserted = 0 }
    {
        print $0
        if (inserted == 0 && $0 ~ /^\|[[:space:]]*---/) {
            print row
            inserted = 1
        }
    }
    END {
        if (inserted == 0) {
            print row
        }
    }
' "${LOG_FILE}" > "${tmp_file}"
mv "${tmp_file}" "${LOG_FILE}"

echo "[OK] 已写入蒸馏批次总账（最新在前）: ${LOG_FILE}"
