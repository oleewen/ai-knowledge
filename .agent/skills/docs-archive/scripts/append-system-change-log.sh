#!/usr/bin/env bash
set -euo pipefail

# append-system-change-log.sh
# 作用：向 .agent 侧 CHANGE-LOG.md 追加归档批次记录
#
# 用法：
#   .agent/skills/docs-archive/scripts/append-system-change-log.sh \
#     --app billing \
#     --changelog-id v1.3.0 \
#     --changelog-time "2026-04-05 10:00" \
#     [--archived-at "2026-04-05T10:30:00+08:00"] \
#     [--summary "归档 billing 结构更新"]

usage() {
    cat <<'EOF'
Usage:
  append-system-change-log.sh --app APP --changelog-id ID --changelog-time TIME [--archived-at ISO_TIME] [--summary TEXT]

Required:
  --app             应用名（用于 .agent 日志分组）
  --changelog-id    本次归档对应的应用变更 ID
  --changelog-time  应用变更时间（原始记录时间）

Optional:
  --archived-at     系统侧归档时间（默认：当前 UTC ISO8601）
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
        --app)
            APP="${2:-}"
            shift 2
            ;;
        --changelog-id)
            CHANGELOG_ID="${2:-}"
            shift 2
            ;;
        --changelog-time)
            CHANGELOG_TIME="${2:-}"
            shift 2
            ;;
        --archived-at)
            ARCHIVED_AT="${2:-}"
            shift 2
            ;;
        --summary)
            SUMMARY="${2:-}"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
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

escape_md_cell() {
    local raw="${1}"
    raw="${raw//$'\n'/ }"
    raw="${raw//|/\\|}"
    printf '%s' "${raw}"
}

LOG_FILE=".agent/skills/docs-archive/logs/CHANGE-LOG.md"
mkdir -p "$(dirname "${LOG_FILE}")"

if [[ ! -f "${LOG_FILE}" ]]; then
    {
        echo "# CHANGE LOG - docs-archive"
        echo
        echo "| app | changelog_id | changelog_time | archived_at | summary |"
        echo "|---|---|---|---|---|"
    } > "${LOG_FILE}"
fi

echo "| $(escape_md_cell "${APP}") | $(escape_md_cell "${CHANGELOG_ID}") | $(escape_md_cell "${CHANGELOG_TIME}") | $(escape_md_cell "${ARCHIVED_AT}") | $(escape_md_cell "${SUMMARY}") |" >> "${LOG_FILE}"

echo "[OK] 已追加 .agent 变更总账: ${LOG_FILE}"
