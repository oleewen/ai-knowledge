#!/usr/bin/env bash
set -euo pipefail
# overview 内容由 Agent；本脚本 orchestrate dry-run 与 DISTILL-LOG。
# 从仓库根执行，或 `--root`。

usage() {
  cat <<'EOF'
Usage:
  run-docs-distill.sh --app APP [--since ID_OR_TIME] [--full] [--dry-run] [--root DIR]

Options:
  --app       应用名（对应 system/application-{app}/）
  --since     手动起点（覆盖 DISTILL-LOG 锚点）
  --full      全量模式（忽略锚点）
  --dry-run   仅预览，不落盘
  --root      项目根目录（默认：脚本所在目录上溯四级，即仓库根）
EOF
}

APP=""
SINCE=""
FULL=false
DRY_RUN=false
ROOT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app)     APP="${2:-}";       shift 2 ;;
    --since)   SINCE="${2:-}";     shift 2 ;;
    --full)    FULL=true;          shift 1 ;;
    --dry-run) DRY_RUN=true;       shift 1 ;;
    --root)    ROOT_DIR="${2:-}";  shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[ERROR] 未知参数: $1" >&2; usage >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 确定项目根目录：优先 --root，其次脚本位置上溯四级（scripts/ → docs-distill/ → skills/ → agent/ → 根）
if [[ -z "${ROOT_DIR}" ]]; then
  ROOT_DIR="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
fi

if [[ ! -d "${ROOT_DIR}" ]]; then
  echo "[ERROR] 项目根目录不存在: ${ROOT_DIR}" >&2
  exit 1
fi

cd "${ROOT_DIR}"

if [[ -z "$APP" ]]; then
  echo "[ERROR] --app 为必填参数" >&2
  usage >&2
  exit 1
fi

if [[ ! "$APP" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
  echo "[ERROR] --app 格式非法: $APP" >&2
  exit 1
fi

SCRIPTS_DIR="${SCRIPT_DIR}"
APP_DIR="system/application-${APP}"
APP_CHANGE_LOG="${APP_DIR}/changelogs/CHANGE-LOG.md"  # 只读：应用侧变更来源
DISTILL_LOG="system/changelogs/DISTILL-LOG.md"        # 读写：蒸馏记录兼锚点（步骤 4.4）
OVERVIEW_DIR="system/architecture/overview"
OVERVIEW_TEMPLATE="${OVERVIEW_DIR}/NAME-overview.md"
OVERVIEW_TARGET="${OVERVIEW_DIR}/${APP}-overview.md"

now_iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# 从 Markdown 文件中提取最后一个 ## 标题的第一个 token 作为 changelog_id
extract_last_changelog_id() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    printf ''
    return 0
  fi
  local id=""
  id="$(grep -E '^## ' "$file" | tail -n 1 | sed -E 's/^##[[:space:]]+([^[:space:]]+).*/\1/' || true)"
  if [[ -n "$id" ]]; then
    printf '%s' "$id"
    return 0
  fi
  # 兜底：表格最后一行第一列
  id="$(grep -E '^\|' "$file" \
       | grep -v -E '^\|[[:space:]]*---' \
       | grep -v -E '^\|[[:space:]]*(changelog_id|app)[[:space:]]*\|' \
       | tail -n 1 \
       | sed -E 's/^\|[[:space:]]*([^|]+)[[:space:]]*\|.*/\1/' \
       | sed 's/[[:space:]]*$//' || true)"
  printf '%s' "$id"
}

# 从 DISTILL-LOG 中按 app 列过滤，取该应用最新一条 changelog_id（最新在前，取第一条匹配行）
extract_anchor_for_app() {
  local file="$1"
  local app="$2"
  if [[ ! -f "$file" ]]; then
    printf ''
    return 0
  fi
  local id=""
  id="$(grep -E '^\|' "$file" \
       | grep -v -E '^\|[[:space:]]*---' \
       | grep -v -E '^\|[[:space:]]*(app)[[:space:]]*\|' \
       | awk -F'|' -v app="${app}" '
           {
               gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
               if ($2 == app) { print $3; exit }
           }
       ' \
       | sed -E 's/^[[:space:]]+|[[:space:]]+$//' || true)"
  printf '%s' "$id"
}

source_last_id="$(extract_last_changelog_id "$APP_CHANGE_LOG")"
anchor_last_id="$(extract_anchor_for_app "$DISTILL_LOG" "$APP")"

range_mode="incremental"
range_from="${anchor_last_id}"
range_to="${source_last_id}"

if [[ "$FULL" == true ]]; then
  range_mode="full"
  range_from="BEGIN"
elif [[ -n "$SINCE" ]]; then
  range_mode="since"
  range_from="$SINCE"
fi

show_targets_preview() {
  echo "  overview_template : ${OVERVIEW_TEMPLATE}"
  if [[ -f "${OVERVIEW_TARGET}" ]]; then
    echo "  overview_target   : ${OVERVIEW_TARGET} (已存在，将更新)"
  else
    echo "  overview_target   : ${OVERVIEW_TARGET} (不存在，将从模板创建)"
  fi
}

# ── Dry-run：三层预览，不落盘 ──────────────────────────────────────────────
if [[ "$DRY_RUN" == true ]]; then
  echo "=== Dry-Run Preview: docs-distill ==="
  echo
  echo "[Layer 1] 候选变更区间"
  echo "  app              : ${APP}"
  echo "  mode             : ${range_mode}"
  echo "  app_change_log   : ${APP_CHANGE_LOG}"
  echo "  distill_anchor   : ${DISTILL_LOG} (app=${APP})"
  echo "  from             : ${range_from:-<无锚点，将全量蒸馏>}"
  echo "  to               : ${range_to:-<无变更来源>}"
  echo
  echo "[Layer 2] 目标文件状态"
  show_targets_preview
  echo
  echo "[Layer 3] 将写入的日志条目摘要"
  echo "  [4.4] distill_log -> ${DISTILL_LOG}"
  echo "        新行（最新在前）: | ${APP} | ${range_to:-N/A} | <changelog_time> | ${now_iso} | overview distill |"
  echo
  echo "[INFO] dry-run 完成，未写入任何文件。"
  exit 0
fi

# ── 正式执行：日志写入 ─────────────────────────────────────────────────────
# 内容提炼（步骤 4.2–4.3）由 Agent 按 federation-spec.md 规则执行，本脚本不覆盖。
# 本脚本仅承载步骤 4.4（overview 写入成功后写入 DISTILL-LOG）。

if [[ -z "$range_to" ]]; then
  echo "[ERROR] 无法继续：在 ${APP_CHANGE_LOG} 中未找到变更标识" >&2
  exit 1
fi

# 从应用 CHANGE-LOG 中提取 range_to 对应条目的时间（取 ## 标题中的日期部分）
changelog_time="$(grep -E "^## ${range_to}" "$APP_CHANGE_LOG" 2>/dev/null \
  | head -n 1 \
  | sed -E 's/^##[[:space:]]+[^[:space:]]+[[:space:]]+-[[:space:]]+//' \
  | sed 's/[[:space:]]*$//' || true)"
if [[ -z "$changelog_time" ]]; then
  changelog_time="${now_iso}"
fi

echo "[INFO] 开始写入蒸馏日志..."
echo "  app           : ${APP}"
echo "  changelog_id  : ${range_to}"
echo "  changelog_time: ${changelog_time}"
echo "  distilled_at  : ${now_iso}"

# 步骤 4.4：写入 DISTILL-LOG（overview 写入成功后执行）
echo "[STEP 4.4] 写入 DISTILL-LOG..."
bash "${SCRIPTS_DIR}/append-change-log.sh" \
  --app            "$APP" \
  --changelog-id   "$range_to" \
  --changelog-time "$changelog_time" \
  --archived-at    "$now_iso" \
  --summary        "overview distill"

echo
echo "[DONE] 日志写入完成。架构内容提炼（步骤 4.2–4.3）须由 Agent 按 federation-spec.md 执行。"
