#!/usr/bin/env bash
set -euo pipefail
# 薄校验壳：解析 DOC_DIR + --name，检查槽位与 overview 模板；不写 overview / LOG。
# 正文蒸馏由 Agent 按 SKILL / federation-spec 执行。

usage() {
  cat <<'EOF'
Usage:
  run-docs-distill.sh --name NAME [--doc-dir system|company] [--dry-run] [--root DIR]

Options:
  --name      源名称（system 边=应用名；company 边=系统名）
  --doc-dir   目标层 system|company。缺省：环境变量 DOC_DIR，再试仓库根 .docsconfig（须已为 system|company）
  --dry-run   对齐 Agent 预览语义；本脚本本来就不写盘
  --root      项目根目录（默认：脚本所在目录上溯四级）
  --app       兼容别名，等同 --name
EOF
}

NAME=""
DOC_DIR_ARG=""
DRY_RUN=false
ROOT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name|--app) NAME="${2:-}";       shift 2 ;;
    --doc-dir)    DOC_DIR_ARG="${2:-}"; shift 2 ;;
    --dry-run)    DRY_RUN=true;        shift 1 ;;
    --root)       ROOT_DIR="${2:-}";   shift 2 ;;
    --since|--full)
      echo "[ERROR] 已废止参数: $1（本技能仅全量，且不写 DISTILL-LOG）" >&2
      usage >&2
      exit 1
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[ERROR] 未知参数: $1" >&2; usage >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${ROOT_DIR}" ]]; then
  ROOT_DIR="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
fi

if [[ ! -d "${ROOT_DIR}" ]]; then
  echo "[ERROR] 项目根目录不存在: ${ROOT_DIR}" >&2
  exit 1
fi

cd "${ROOT_DIR}"

if [[ -z "$NAME" ]]; then
  echo "[ERROR] --name 为必填参数" >&2
  usage >&2
  exit 1
fi

if [[ ! "$NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
  echo "[ERROR] --name 格式非法: $NAME" >&2
  exit 1
fi

resolve_doc_dir() {
  local candidate=""
  if [[ -n "${DOC_DIR_ARG}" ]]; then
    candidate="${DOC_DIR_ARG}"
  elif [[ -n "${DOC_DIR:-}" ]]; then
    candidate="${DOC_DIR}"
  elif [[ -f "${ROOT_DIR}/.docsconfig" ]]; then
    candidate="$(grep -E '^DOC_DIR=' "${ROOT_DIR}/.docsconfig" | head -n 1 | cut -d= -f2- | tr -d '"' | tr -d "'" || true)"
  fi
  candidate="${candidate#./}"
  candidate="${candidate%/}"
  printf '%s' "${candidate}"
}

DOC_DIR_RESOLVED="$(resolve_doc_dir)"

case "${DOC_DIR_RESOLVED}" in
  system|company) ;;
  "")
    echo "[ERROR] 无法解析 DOC_DIR。请传 --doc-dir system|company，或设置环境变量 / .docsconfig 为 system|company。" >&2
    exit 1
    ;;
  *)
    echo "[ERROR] DOC_DIR 须为 system|company（当前: ${DOC_DIR_RESOLVED}）。应用层无 overview，不能作蒸馏目标。" >&2
    exit 1
    ;;
esac

if [[ "${DOC_DIR_RESOLVED}" == "system" ]]; then
  SLOT_DIR="system/application-slots/application-${NAME}"
  OVERVIEW_DIR="system/knowledge/overview"
else
  SLOT_DIR="company/system-slots/system-${NAME}"
  OVERVIEW_DIR="company/knowledge/overview"
fi

OVERVIEW_TEMPLATE="${OVERVIEW_DIR}/NAME-overview.md"
OVERVIEW_TARGET="${OVERVIEW_DIR}/${NAME}-overview.md"

ERRORS=0

if [[ ! -d "${SLOT_DIR}" ]]; then
  echo "[ERROR] 槽位不存在: ${SLOT_DIR}（请先 docs-link / docs-pull）" >&2
  ERRORS=$((ERRORS + 1))
elif [[ -z "$(find "${SLOT_DIR}" -mindepth 1 -maxdepth 1 2>/dev/null | head -n 1)" ]]; then
  echo "[ERROR] 槽位为空: ${SLOT_DIR}（请先 docs-pull）" >&2
  ERRORS=$((ERRORS + 1))
else
  echo "[OK]    槽位: ${SLOT_DIR}"
fi

if [[ ! -f "${OVERVIEW_TEMPLATE}" ]]; then
  echo "[ERROR] overview 模板缺失: ${OVERVIEW_TEMPLATE}" >&2
  ERRORS=$((ERRORS + 1))
else
  echo "[OK]    模板: ${OVERVIEW_TEMPLATE}"
fi

if [[ -f "${OVERVIEW_TARGET}" ]]; then
  echo "[OK]    目标: ${OVERVIEW_TARGET} (已存在，将更新)"
else
  echo "[INFO]  目标: ${OVERVIEW_TARGET} (不存在，Agent 将从模板创建)"
fi

echo
echo "=== docs-distill 校验摘要 ==="
echo "  doc_dir : ${DOC_DIR_RESOLVED}"
echo "  name    : ${NAME}"
echo "  mode    : full"
echo "  edge    : ${SLOT_DIR} -> ${OVERVIEW_TARGET}"
echo "  dry_run : ${DRY_RUN}"
echo "  write   : 本脚本不写 overview / DISTILL-LOG；正文由 Agent 执行"
echo

if [[ "${ERRORS}" -gt 0 ]]; then
  echo "[FAIL] 校验未通过（${ERRORS}）" >&2
  exit 1
fi

echo "[DONE] 校验通过。请 Agent 按 federation-spec 全量蒸馏第三列。"
exit 0
