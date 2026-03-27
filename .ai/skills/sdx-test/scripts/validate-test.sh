#!/usr/bin/env bash
set -euo pipefail

# 测试设计文档结构校验脚本
# 用法: scripts/validate-test.sh [--doc-root <path>] [--file <path>]
#
# 校验项:
#   1. 文档目录存在
#   2. frontmatter 完整性（id、title、version、status、parent、mvp_phase）
#   3. 六章结构完整性
#   4. 编号体系一致性（TC-*）
#   5. 模板 tdd-template.md 存在

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

TEMPLATE=".cursor/rules/requirement/tdd-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== 测试设计文档结构校验 ==="
echo "Doc Root: ${DOC_ROOT}"
echo ""

# 0. 模板文件
if [[ -f "${TEMPLATE}" ]]; then
  success "tdd-template.md 存在"
else
  warn "tdd-template.md 不存在: ${TEMPLATE}"
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
  done < <(find "${DOC_ROOT}" -name "TDD-*.md" -print0 2>/dev/null)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  info "未找到测试设计文档"
  echo ""
  echo "=== 校验结果 ==="
  echo "错误: ${ERRORS}  警告: ${WARNINGS}"
  exit 0
fi

# 校验每个文档
for file in "${FILES[@]}"; do
  BASENAME=$(basename "${file}")
  echo "--- 校验: ${BASENAME} ---"

  # 1. frontmatter 检查
  if head -5 "${file}" | grep -q "^---"; then
    success "${BASENAME}: frontmatter 存在"

    for field in "id:" "title:" "version:" "status:" "parent:" "mvp_phase:"; do
      if grep -q "${field}" "${file}"; then
        success "${BASENAME}: ${field} 字段存在"
      else
        warn "${BASENAME}: 缺少 ${field} 字段"
      fi
    done
  else
    warn "${BASENAME}: 缺少 frontmatter"
  fi

  # 2. 六章结构检查
  REQUIRED_SECTIONS=(
    "## 1. 概述"
    "## 2. 测试用例"
    "## 3. 测试数据"
    "## 4. 测试环境"
    "## 5. 测试进出标准"
    "## 6. 附录"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/6 个必需章节"

  # 3. 子章节检查
  SUB_SECTIONS=(
    "### 1.1 测试目标"
    "### 1.2 测试范围"
    "### 1.3 测试策略"
    "### 2.1 功能测试用例"
    "### 2.2 接口测试用例"
    "### 2.3 业务规则测试用例"
    "### 5.1 进入标准"
    "### 5.2 退出标准"
  )

  SUB_COUNT=0
  for sub in "${SUB_SECTIONS[@]}"; do
    if grep -qF "${sub}" "${file}"; then
      SUB_COUNT=$((SUB_COUNT + 1))
    fi
  done
  info "${BASENAME}: ${SUB_COUNT}/${#SUB_SECTIONS[@]} 个关键子章节"

  # 4. 编号体系检查
  TC_COUNT=$(grep -c 'TC-[0-9]' "${file}" 2>/dev/null || true)
  TC_API_COUNT=$(grep -c 'TC-API-[0-9]' "${file}" 2>/dev/null || true)
  TC_BR_COUNT=$(grep -c 'TC-BR-[0-9]' "${file}" 2>/dev/null || true)
  TC_EX_COUNT=$(grep -c 'TC-EX-[0-9]' "${file}" 2>/dev/null || true)
  TC_REG_COUNT=$(grep -c 'TC-REG-[0-9]' "${file}" 2>/dev/null || true)

  info "${BASENAME}: TC=${TC_COUNT} TC-API=${TC_API_COUNT} TC-BR=${TC_BR_COUNT} TC-EX=${TC_EX_COUNT} TC-REG=${TC_REG_COUNT}"

  if [[ ${TC_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现功能测试用例编号 (TC-*)"
  fi

  # 5. PRD 关联检查
  if grep -q 'PRD-' "${file}"; then
    success "${BASENAME}: 关联产品需求文档"
  else
    warn "${BASENAME}: 未发现关联 PRD 编号 (PRD-*)"
  fi

  # 6. 用户故事关联检查
  if grep -q 'US-[0-9]' "${file}"; then
    success "${BASENAME}: 关联用户故事"
  else
    warn "${BASENAME}: 未发现关联用户故事编号 (US-*)"
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
