#!/usr/bin/env bash
set -euo pipefail

# 校验 docs-build 产物。无 CLI 参数；路径来自 .docsconfig（config-bootstrap.sh）
# 检查：INDEX 非空；{perspective}-entities.md / {perspective}-meta.md 存在且含实体表与统计节

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

# 3. 各视角 {perspective}-meta.md / {perspective}-entities.md
PERSPECTIVES=("application" "data" "business" "product" "technical")
ENTITIES_COUNT=0

for p in "${PERSPECTIVES[@]}"; do
  META_FILE="${KNOWLEDGE_DIR}/${p}/${p}-meta.md"
  ENTITIES_FILE="${KNOWLEDGE_DIR}/${p}/${p}-entities.md"

  if [[ -f "${META_FILE}" ]]; then
    success "${p}-meta.md 存在"
  else
    warn "${p}-meta.md 未找到"
  fi

  if [[ -f "${ENTITIES_FILE}" ]]; then
    ENTITIES_COUNT=$((ENTITIES_COUNT + 1))
    success "${p}-entities.md 存在"

    if grep -q "## 统计" "${ENTITIES_FILE}" || grep -q "## 实体总表" "${ENTITIES_FILE}"; then
      success "${p}-entities.md 含实体表或统计节"
    else
      warn "${p}-entities.md 缺少 ## 实体总表 或 ## 统计 节"
    fi

    ROWS=$(grep -c '^|' "${ENTITIES_FILE}" 2>/dev/null || echo 0)
    info "${p}-entities.md 表格行数约 ${ROWS}"
  else
    info "${p}-entities.md 未找到（可选）"
  fi
done

info "发现 ${ENTITIES_COUNT}/${#PERSPECTIVES[@]} 个 entities Markdown 文件"

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
