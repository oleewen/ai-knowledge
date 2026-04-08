#!/usr/bin/env bash
set -euo pipefail

# run-docs-archive.sh
# 仅保留 .agent 目录下脚本分发能力。

usage() {
  cat <<'EOF'
Usage:
  run-docs-archive.sh --app APP [--dry-run]

Options:
  --app      应用名（透传给 .agent 子脚本）
  --dry-run  仅预览，不调用子脚本
EOF
}

APP=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app) APP="${2:-}"; shift 2 ;;
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

SCRIPT_ROOT=".agent/skills/docs-archive/scripts"
APPEND_SCRIPT="${SCRIPT_ROOT}/append-system-change-log.sh"
ARCHIVE_SCRIPT="${SCRIPT_ROOT}/update-application-archive-log.sh"
NOW_ISO="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

[[ -x "$APPEND_SCRIPT" ]] || { echo "[ERROR] Missing script: $APPEND_SCRIPT" >&2; exit 1; }
[[ -x "$ARCHIVE_SCRIPT" ]] || { echo "[ERROR] Missing script: $ARCHIVE_SCRIPT" >&2; exit 1; }

if [[ "$DRY_RUN" == true ]]; then
  echo "=== Dry-Run Preview: docs-archive (.agent only) ==="
  echo "- app: ${APP}"
  echo "- append script: ${APPEND_SCRIPT}"
  echo "- archive script: ${ARCHIVE_SCRIPT}"
  echo "- timestamp: ${NOW_ISO}"
  exit 0
fi

"$APPEND_SCRIPT" \
  --app "$APP" \
  --changelog-id "$NOW_ISO" \
  --changelog-time "$NOW_ISO" \
  --archived-at "$NOW_ISO" \
  --summary "archive run (.agent-only dispatcher)"

"$ARCHIVE_SCRIPT" \
  --app "$APP" \
  --changelog-id "$NOW_ISO" \
  --changelog-time "$NOW_ISO" \
  --archived-at "$NOW_ISO"

echo "[DONE] .agent 脚本分发完成。"
