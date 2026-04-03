#!/usr/bin/env bash
set -euo pipefail

# 需求分析文档结构校验脚本
# 用法: scripts/validate-analysis.sh [--doc-root <path>] [--file <path>]
#
# 校验项:
#   1. 文档目录存在
#   2. 文末「文档元数据」YAML 完整性（id、title、version、status、parent）；禁止文件头 ---
#   3. 八章结构完整性
#   4. 编号体系一致性（FR-n、BR-n、R-n、MVP-n）
#   5. 模板 analysis-template.md 存在

DOC_ROOT="docs"
TARGET_FILE=""
ERRORS=0
WARNINGS=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --doc-root) DOC_ROOT="$2"; shift 2 ;;
    --file) TARGET_FILE="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

ANALYSIS_DIR="${DOC_ROOT}/analysis"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="${SCRIPT_DIR}/../assets/analysis-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== 需求分析文档结构校验 ==="
echo "Doc Root: ${DOC_ROOT}"
echo ""

# 0. 模板文件
if [[ -f "${TEMPLATE}" ]]; then
  success "analysis-template.md 存在"
else
  warn "analysis-template.md 不存在: ${TEMPLATE}"
fi

# 1. 文档目录
if [[ -d "${ANALYSIS_DIR}" ]]; then
  FILE_COUNT=$(find "${ANALYSIS_DIR}" -name "ANALYSIS-*.md" 2>/dev/null | wc -l | tr -d ' ')
  success "analysis/ 目录存在 (${FILE_COUNT} 个需求分析文档)"
else
  warn "analysis/ 目录不存在: ${ANALYSIS_DIR}"
  echo ""
  echo "=== 校验结果 ==="
  echo "错误: ${ERRORS}  警告: ${WARNINGS}"
  exit 0
fi

# 收集要校验的文件
if [[ -n "${TARGET_FILE}" ]]; then
  if [[ -f "${TARGET_FILE}" ]]; then
    FILES=("${TARGET_FILE}")
  else
    error "指定文件不存在: ${TARGET_FILE}"
    echo ""
    echo "=== 校验结果 ==="
    echo "错误: ${ERRORS}  警告: ${WARNINGS}"
    exit 1
  fi
else
  FILES=()
  while IFS= read -r -d '' f; do
    FILES+=("$f")
  done < <(find "${ANALYSIS_DIR}" -name "ANALYSIS-*.md" -print0 2>/dev/null)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  info "未找到需求分析文档"
  echo ""
  echo "=== 校验结果 ==="
  echo "错误: ${ERRORS}  警告: ${WARNINGS}"
  exit 0
fi

# 校验每个文档
for file in "${FILES[@]}"; do
  BASENAME=$(basename "${file}")
  echo "--- 校验: ${BASENAME} ---"

  # 2. 文档元数据（文末 YAML，非文件头 frontmatter）
  if head -5 "${file}" | grep -q "^---"; then
    warn "${BASENAME}: 文件开头存在 ---（应移除）；元数据须仅在文末「## 文档元数据」的 yaml 代码块中"
  fi

  if grep -qF "## 文档元数据" "${file}"; then
    success "${BASENAME}: 「文档元数据」章节存在"
  else
    warn "${BASENAME}: 缺少「## 文档元数据」章节（须在文末放置 YAML 元数据）"
  fi

  for field in "id:" "title:" "version:" "status:" "parent:"; do
    if grep -q "${field}" "${file}"; then
      success "${BASENAME}: ${field} 字段存在"
    else
      warn "${BASENAME}: 缺少 ${field} 字段（应出现在文末 yaml 块）"
    fi
  done

  # 3. 八章结构检查
  REQUIRED_SECTIONS=(
    "## 1. 需求概述"
    "## 2. 功能需求"
    "## 3. 非功能需求"
    "## 4. 业务规则"
    "## 5. 数据需求"
    "## 6. MVP拆分方案"
    "## 7. 依赖与风险"
    "## 8. 附录"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/8 个必需章节"

  # 4. 编号体系检查
  FR_COUNT=$(grep -c 'FR-[0-9]' "${file}" 2>/dev/null || true)
  BR_COUNT=$(grep -c 'BR-[0-9]' "${file}" 2>/dev/null || true)
  R_COUNT=$(grep -c 'R-[0-9]' "${file}" 2>/dev/null || true)
  MVP_COUNT=$(grep -c 'MVP-[0-9]' "${file}" 2>/dev/null || true)

  info "${BASENAME}: FR-n=${FR_COUNT} BR-n=${BR_COUNT} R-n=${R_COUNT} MVP-n=${MVP_COUNT}"

  if [[ ${FR_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现功能需求编号 (FR-n)"
  fi

  if [[ ${MVP_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现 MVP 阶段编号 (MVP-n)"
  fi

  # 5. 解决方案关联检查
  if grep -q 'SOLUTION-' "${file}"; then
    success "${BASENAME}: 关联解决方案文档"
  else
    warn "${BASENAME}: 未发现关联解决方案编号 (SOLUTION-*)"
  fi

  echo ""
done

echo "=== 校验结果 ==="
echo "错误: ${ERRORS}  警告: ${WARNINGS}"

if [[ ${ERRORS} -gt 0 ]]; then
  echo "校验失败，请修复以上错误。"
  exit 1
else
  echo "校验通过。"
  exit 0
fi
