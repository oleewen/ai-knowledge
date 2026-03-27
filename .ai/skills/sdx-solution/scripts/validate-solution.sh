#!/usr/bin/env bash
set -euo pipefail

# 解决方案文档结构校验脚本
# 用法: scripts/validate-solution.sh [--doc-root <path>] [--file <path>]
#
# 校验项:
#   1. 文档目录存在
#   2. frontmatter 完整性（id、title、version、status）
#   3. 九章结构完整性
#   4. 编号体系一致性（G-n、Q-n、C-n、R-n）
#   5. 模板 solution-template.md 存在

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

SOLUTIONS_DIR="${DOC_ROOT}/solutions"
TEMPLATE=".cursor/rules/solution/solution-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== 解决方案文档结构校验 ==="
echo "Doc Root: ${DOC_ROOT}"
echo ""

# 0. 模板文件
if [[ -f "${TEMPLATE}" ]]; then
  success "solution-template.md 存在"
else
  warn "solution-template.md 不存在: ${TEMPLATE}"
fi

# 1. 文档目录
if [[ -d "${SOLUTIONS_DIR}" ]]; then
  FILE_COUNT=$(find "${SOLUTIONS_DIR}" -name "SOLUTION-*.md" 2>/dev/null | wc -l | tr -d ' ')
  success "solutions/ 目录存在 (${FILE_COUNT} 个解决方案文档)"
else
  warn "solutions/ 目录不存在: ${SOLUTIONS_DIR}"
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
  done < <(find "${SOLUTIONS_DIR}" -name "SOLUTION-*.md" -print0 2>/dev/null)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  info "未找到解决方案文档"
  echo ""
  echo "=== 校验结果 ==="
  echo "错误: ${ERRORS}  警告: ${WARNINGS}"
  exit 0
fi

# 校验每个文档
for file in "${FILES[@]}"; do
  BASENAME=$(basename "${file}")
  echo "--- 校验: ${BASENAME} ---"

  # 2. frontmatter 检查
  if head -5 "${file}" | grep -q "^---"; then
    success "${BASENAME}: frontmatter 存在"

    for field in "id:" "title:" "version:" "status:"; do
      if grep -q "${field}" "${file}"; then
        success "${BASENAME}: ${field} 字段存在"
      else
        warn "${BASENAME}: 缺少 ${field} 字段"
      fi
    done
  else
    warn "${BASENAME}: 缺少 frontmatter"
  fi

  # 3. 九章结构检查
  REQUIRED_SECTIONS=(
    "## 1. 业务背景"
    "## 2. 业务目标"
    "## 3. 需求概述"
    "## 4. 影响面评估"
    "## 5. 冲突分析"
    "## 6. 解决方案"
    "## 7. 可行性评估"
    "## 8. MVP拆分建议"
    "## 9. 附录"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/9 个必需章节"

  # 4. 编号体系检查
  G_COUNT=$(grep -c 'G-[0-9]' "${file}" 2>/dev/null || true)
  Q_COUNT=$(grep -c 'Q-[0-9]' "${file}" 2>/dev/null || true)
  C_COUNT=$(grep -c 'C-[0-9T]' "${file}" 2>/dev/null || true)
  R_COUNT=$(grep -c 'R-[0-9]' "${file}" 2>/dev/null || true)

  info "${BASENAME}: G-n=${G_COUNT} Q-n=${Q_COUNT} C-n=${C_COUNT} R-n=${R_COUNT}"

  if [[ ${G_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现业务目标编号 (G-n)"
  fi

  # 5. 空章节检查
  EMPTY_SECTIONS=0
  while IFS= read -r line; do
    if [[ "${line}" =~ ^##\  ]]; then
      SECTION_NAME="${line}"
    fi
  done < "${file}"

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
