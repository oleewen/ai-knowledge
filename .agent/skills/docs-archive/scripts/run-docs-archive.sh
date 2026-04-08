#!/usr/bin/env bash
set -euo pipefail

# run-docs-archive.sh
# 最小可执行入口：
# - 支持 dry-run 三层预览
# - 非 dry-run 仅做最小日志写入编排（暂不实现架构内容提炼写入）

usage() {
  cat <<'EOF'
Usage:
  run-docs-archive.sh --app APP [--since ID_OR_TIME] [--full] [--dry-run]

Options:
  --app       应用名（对应 system/application-{app}/）
  --since     手动起点（覆盖应用 ARCHIVE-LOG 锚点）
  --full      全量模式（忽略锚点）
  --dry-run   仅预览，不落盘
EOF
}

APP=""
SINCE=""
FULL=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app) APP="${2:-}"; shift 2 ;;
    --since) SINCE="${2:-}"; shift 2 ;;
    --full) FULL=true; shift 1 ;;
    --dry-run) DRY_RUN=true; shift 1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[ERROR] Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$APP" ]]; then
  echo "[ERROR] --app is required" >&2
  usage >&2
  exit 1
fi

if [[ ! "$APP" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
  echo "[ERROR] Invalid --app: $APP" >&2
  exit 1
fi

APP_DIR="system/application-${APP}"
APP_CHANGE_LOG="${APP_DIR}/changelogs/CHANGE-LOG.md"
APP_ARCHIVE_LOG="${APP_DIR}/changelogs/ARCHIVE-LOG.md"
SYSTEM_CHANGE_LOG="system/changelogs/CHANGE-LOG.md"
SYSTEM_TARGETS=(
  "system/architecture/BUSINESS-ARCHITECTURE.md"
  "system/architecture/TECHNICAL-ARCHITECTURE.md"
  "system/architecture/DATA-ARCHITECTURE.md"
  "system/architecture/PRODUCT-ARCHITECTURE.md"
)

now_iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

extract_last_changelog_id() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return 0
  fi
  local id
  id="$(rg -n "^## " "$file" | tail -n 1 | sed -E 's/^[0-9]+:##[[:space:]]+([^[:space:]]+).*/\1/' || true)"
  if [[ -n "$id" ]]; then
    printf '%s' "$id"
    return 0
  fi
  # fallback：读取表格最后一行第一列
  id="$(rg -n "^\| " "$file" | tail -n 1 | sed -E 's/^[0-9]+:\|[[:space:]]*([^|]+).*/\1/' | sed 's/[[:space:]]*$//' || true)"
  printf '%s' "$id"
}

source_last_id="$(extract_last_changelog_id "$APP_CHANGE_LOG")"
anchor_last_id="$(extract_last_changelog_id "$APP_ARCHIVE_LOG")"

range_mode="incremental"
range_from="$anchor_last_id"
range_to="$source_last_id"

if [[ "$FULL" == true ]]; then
  range_mode="full"
  range_from="BEGIN"
elif [[ -n "$SINCE" ]]; then
  range_mode="since"
  range_from="$SINCE"
fi

show_targets_preview() {
  local f
  for f in "${SYSTEM_TARGETS[@]}"; do
    if [[ -f "$f" ]]; then
      if rg -q "BEGIN MANAGED BLOCK|END MANAGED BLOCK" "$f"; then
        echo "- ${f} (managed-block: yes)"
      else
        echo "- ${f} (managed-block: no)"
      fi
    else
      echo "- ${f} (missing)"
    fi
  done
}

if [[ "$DRY_RUN" == true ]]; then
  echo "=== Dry-Run Preview: docs-archive ==="
  echo "[Layer 1] Candidate range"
  echo "- app: ${APP}"
  echo "- mode: ${range_mode}"
  echo "- source_change_log: ${APP_CHANGE_LOG}"
  echo "- archive_anchor_log: ${APP_ARCHIVE_LOG}"
  echo "- from: ${range_from:-<none>}"
  echo "- to: ${range_to:-<none>}"
  echo
  echo "[Layer 2] Target files/blocks"
  show_targets_preview
  echo
  echo "[Layer 3] Planned log records"
  echo "- system_change_log -> ${SYSTEM_CHANGE_LOG}"
  echo "  | ${APP} | ${range_to:-N/A} | ${now_iso} | ${now_iso} | dry-run preview |"
  echo "- app_archive_log -> ${APP_ARCHIVE_LOG}"
  echo "  | ${range_to:-N/A} | ${now_iso} | ${now_iso} |"
  exit 0
fi

echo "[INFO] Non-dry-run mode currently writes logs only."

if [[ -z "$range_to" ]]; then
  echo "[ERROR] Cannot proceed: no changelog marker found in ${APP_CHANGE_LOG}" >&2
  exit 1
fi

".agent/skills/docs-archive/scripts/append-system-change-log.sh" \
  --app "$APP" \
  --changelog-id "$range_to" \
  --changelog-time "$now_iso" \
  --archived-at "$now_iso" \
  --summary "archive run (logs-only)"

".agent/skills/docs-archive/scripts/update-application-archive-log.sh" \
  --app "$APP" \
  --changelog-id "$range_to" \
  --changelog-time "$now_iso" \
  --archived-at "$now_iso"

echo "[DONE] Logs updated. Architecture content extraction/write is not implemented in this minimal runner."
