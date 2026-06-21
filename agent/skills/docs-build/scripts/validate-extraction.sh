#!/usr/bin/env bash
set -euo pipefail

# 校验 docs-build 产物。无 CLI 参数；路径来自 .docsconfig（config-bootstrap.sh）
# 检查：KNOWLEDGE_INDEX 存在；各视角至少一个含 full_id 的 per-entity .md；
#       *-entities.md 若仍存在则 WARN（已废弃）

ERRORS=0
WARNINGS=0

if [[ $# -gt 0 ]]; then
  echo "未知参数: $*（本脚本不支持额外参数，路径仅来自 .docsconfig）"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AGENT_HOME/scripts/config-bootstrap.sh"
validate_bootstrap_docsconfig "$SCRIPT_DIR"

DOC_ROOT="$(resolve_repo_doc_root)"
cd "$REPO_ROOT" || exit 1

KNOWLEDGE_DIR="${REPO_ROOT}/${DOC_DIR}/knowledge"
INDEX_FILE="${KNOWLEDGE_DIR}/KNOWLEDGE_INDEX.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

_is_entity_concept_file() {
  local file="$1"
  local base
  base="$(basename "$file")"
  case "$base" in
    index.md | *-meta.md | *-entities.md | KNOWLEDGE_INDEX.md)
      return 1
      ;;
  esac
  [[ "$base" == *.md ]] || return 1
  grep -q '^full_id:' "$file" 2>/dev/null
}

echo "=== docs-build 校验 ==="
echo "REPO_ROOT: ${REPO_ROOT}"
echo "DOC_ROOT: ${DOC_ROOT}"
echo "DOC_DIR:  ${DOC_DIR}"
echo "KNOWLEDGE_DIR: ${KNOWLEDGE_DIR}"
echo ""

# 1. KNOWLEDGE_INDEX.md
if [[ -f "${INDEX_FILE}" ]]; then
  LINE_COUNT=$(wc -l < "${INDEX_FILE}" | tr -d ' ')
  if [[ ${LINE_COUNT} -gt 5 ]]; then
    success "KNOWLEDGE_INDEX.md 存在 (${LINE_COUNT} 行)"
  else
    warn "KNOWLEDGE_INDEX.md 内容过少 (${LINE_COUNT} 行)"
  fi
else
  error "KNOWLEDGE_INDEX.md 不存在: ${INDEX_FILE}"
fi

# 2. knowledge-meta.md
META_ROOT="${KNOWLEDGE_DIR}/knowledge-meta.md"
if [[ -f "${META_ROOT}" ]]; then
  success "knowledge-meta.md 存在"
else
  warn "knowledge-meta.md 未找到（可选）"
fi

# 3. 各视角 per-entity concept / meta / 废弃 entities
PERSPECTIVES=("application" "data" "business" "product" "technical")
TOTAL_ENTITIES=0

for p in "${PERSPECTIVES[@]}"; do
  PERSPECTIVE_DIR="${KNOWLEDGE_DIR}/${p}"
  META_FILE="${PERSPECTIVE_DIR}/${p}-meta.md"
  ENTITIES_FILE="${PERSPECTIVE_DIR}/${p}-entities.md"
  ENTITY_COUNT=0

  if [[ -f "${META_FILE}" ]]; then
    success "${p}-meta.md 存在"
  else
    warn "${p}-meta.md 未找到"
  fi

  if [[ -d "${PERSPECTIVE_DIR}" ]]; then
    while IFS= read -r -d '' f; do
      if _is_entity_concept_file "$f"; then
        ENTITY_COUNT=$((ENTITY_COUNT + 1))
      fi
    done < <(find "${PERSPECTIVE_DIR}" -name "*.md" -print0 2>/dev/null || true)
  fi

  TOTAL_ENTITIES=$((TOTAL_ENTITIES + ENTITY_COUNT))
  if [[ ${ENTITY_COUNT} -gt 0 ]]; then
    success "${p}: ${ENTITY_COUNT} 个含 full_id 的 per-entity concept 文件"
  else
    warn "${p}: 未发现含 full_id 的 per-entity .md（OKF 目标态每视角至少一个）"
  fi

  if [[ -f "${ENTITIES_FILE}" ]]; then
    warn "${p}-entities.md 仍存在（已废弃；SSOT 为 per-entity .md，请迁移后删除）"
  fi
done

info "合计 ${TOTAL_ENTITIES} 个 per-entity concept 文件"

# 4. 提取报告（可选）
for p in "${PERSPECTIVES[@]}"; do
  REPORT="${KNOWLEDGE_DIR}/${p}/extraction_report.md"
  if [[ -f "${REPORT}" ]]; then
    info "${p}/extraction_report.md 存在"
  fi
done

echo ""
echo "=== 验证结果 ==="
echo "错误: ${ERRORS}  警告: ${WARNINGS}"

if [[ ${ERRORS} -gt 0 ]]; then
  echo "校验失败，请修正后重跑。"
  exit 1
else
  echo "验证通过。"
  exit 0
fi
