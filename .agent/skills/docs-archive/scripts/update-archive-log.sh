#!/usr/bin/env bash
set -euo pipefail

# update-archive-log.sh
# 作用：向 .agent 侧 ARCHIVE-LOG.md 追加归档锚点记录
#
# 用法：
#   .agent/skills/docs-archive/scripts/update-archive-log.sh \
#     --app billing \
#     --changelog-id v1.3.0 \
#     --changelog-time "2026-04-05 10:00" \
#     [--archived-at "2026-04-05T10:30:00+08:00"]

usage() {
    cat <<'EOF'
Usage:
  update-archive-log.sh --app APP --changelog-id ID --changelog-time TIME [--archived-at ISO_TIME]

Required:
  --app             应用名（用于 .agent 日志分组）
  --changelog-id    变更唯一标识
  --changelog-time  变更时间（原始记录时间）

Optional:
  --archived-at     归档时间（默认：当前 UTC ISO8601）
EOF
}

APP=""
CHANGELOG_ID=""
CHANGELOG_TIME=""
ARCHIVED_AT=""

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

LOG_FILE=".agent/skills/docs-archive/logs/application-${APP}/ARCHIVE-LOG.md"
mkdir -p "$(dirname "${LOG_FILE}")"

if [[ ! -f "${LOG_FILE}" ]]; then
    {
        echo "# ARCHIVE LOG - ${APP}"
        echo
        echo "| changelog_id | changelog_time | archived_at |"
        echo "|---|---|---|"
    } > "${LOG_FILE}"
fi

echo "| $(escape_md_cell "${CHANGELOG_ID}") | $(escape_md_cell "${CHANGELOG_TIME}") | $(escape_md_cell "${ARCHIVED_AT}") |" >> "${LOG_FILE}"

echo "[OK] 已追加 .agent 应用归档锚点: ${LOG_FILE}"
