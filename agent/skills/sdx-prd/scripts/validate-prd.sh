#!/usr/bin/env bash
set -euo pipefail

# PRD 结构校验（十一章模板；不承担写前门禁）。
# 用法：validate-prd.sh [--file <path>]
# 文档根：resolve_repo_doc_root（.docsconfig）；先 source config-bootstrap.sh
#
# 要点：文首 frontmatter、`id`、`## 1`-`## 11`、关键小节标题、编号、ANALYSIS 关联、Mermaid 自检提示；
#       不校验会话 spec、CONFIRMED、HTML gate 或写前 hook。

TARGET_FILE=""
ERRORS=0
WARNINGS=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --file) TARGET_FILE="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AGENT_HOME/scripts/config-bootstrap.sh"
validate_bootstrap_docsconfig "$SCRIPT_DIR"

DOC_ROOT="$(resolve_repo_doc_root)"
cd "$REPO_ROOT" || exit 1

REQUIREMENTS_DIR="${DOC_ROOT}/requirements"
_TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="${_TEMPLATE_DIR}/assets/prd-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== PRD 文档结构校验 ==="
echo "DOC_ROOT: ${DOC_ROOT}"
echo ""

if [[ -f "${TEMPLATE}" ]]; then
  success "prd-template.md 存在"
else
  warn "prd-template.md 不存在: ${TEMPLATE}"
fi

FILES=()
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
  if [[ -d "${REQUIREMENTS_DIR}" ]]; then
    FILE_COUNT=$(find "${REQUIREMENTS_DIR}" -name "PRD-*.md" 2>/dev/null | wc -l | tr -d ' ')
    success "requirements/ 目录存在 (${FILE_COUNT} 个 PRD 文档)"
  else
    warn "requirements/ 目录不存在: ${REQUIREMENTS_DIR}"
    echo ""
    echo "=== 校验结果 ==="
    echo "错误: ${ERRORS}  警告: ${WARNINGS}"
    exit 0
  fi

  while IFS= read -r -d '' f; do
    FILES+=("$f")
  done < <(find "${REQUIREMENTS_DIR}" -name "PRD-*.md" -print0 2>/dev/null)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  info "未找到 PRD 文档"
  echo ""
  echo "=== 校验结果 ==="
  echo "错误: ${ERRORS}  警告: ${WARNINGS}"
  exit 0
fi

for file in "${FILES[@]}"; do
  BASENAME=$(basename "${file}")
  echo "--- 校验: ${BASENAME} ---"

  FIRST_LINE=$(head -1 "${file}" 2>/dev/null || true)
  if [[ "${FIRST_LINE}" != "---" ]]; then
    error "${BASENAME}: 缺少文首 YAML frontmatter（首行应为 ---）"
  else
    FRONTMATTER_END_LINE=$(awk 'NR>1 && $0=="---"{print NR; exit}' "${file}" 2>/dev/null || true)
    if [[ -z "${FRONTMATTER_END_LINE}" ]]; then
      error "${BASENAME}: YAML frontmatter 未闭合（缺少第二个 ---）"
    else
      FRONTMATTER_CONTENT=$(sed -n "2,$((FRONTMATTER_END_LINE - 1))p" "${file}" 2>/dev/null || true)
      success "${BASENAME}: YAML frontmatter 存在"
      for field in "id:" "title:" "version:" "status:" "created:" "updated:" "author:" "reviewers:" "parent:" "mvp_phase:"; do
        if echo "${FRONTMATTER_CONTENT}" | grep -qE "^${field}"; then
          success "${BASENAME}: ${field} 字段存在"
        else
          warn "${BASENAME}: 缺少 ${field} 字段"
        fi
      done

      ID_VALUE=$(echo "${FRONTMATTER_CONTENT}" | sed -n 's/^id:[[:space:]]*"\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' | head -1)
      EXPECTED_ID="${BASENAME%.md}"
      if [[ -n "${ID_VALUE}" ]]; then
        if [[ "${ID_VALUE}" == "${EXPECTED_ID}" ]]; then
          success "${BASENAME}: id 与文件名一致"
        else
          warn "${BASENAME}: id 建议与文件名一致，期望 ${EXPECTED_ID}，实际 ${ID_VALUE}"
        fi
      fi

      PARENT_LINE=$(echo "${FRONTMATTER_CONTENT}" | grep -E '^parent:' 2>/dev/null | head -1 || true)
      if echo "${PARENT_LINE}" | grep -q 'ANALYSIS-'; then
        success "${BASENAME}: parent 含 ANALYSIS- 前缀"
      else
        warn "${BASENAME}: parent 建议指向 ANALYSIS-{IDEA-ID}，实际: ${PARENT_LINE}"
      fi
    fi
  fi

  REQUIRED_SECTIONS=(
    "## 1. 产品概述"
    "## 2. 业务流程"
    "## 3. 产品交互"
    "## 4. 用例模型"
    "## 5. 用户故事"
    "## 6. 功能模块设计"
    "## 7. 业务规则汇总"
    "## 8. 数据字典"
    "## 9. 非功能需求"
    "## 10. 验收标准"
    "## 11. 附录"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/11 个必需章节"

  REQUIRED_SUBHEADINGS=(
    "### 1.2 成功标准"
    "### 2.1 核心业务流程"
    "### 4.1 用例图"
    "### 5.1 用户故事清单"
    "### 10.1 功能验收标准"
    "### 11.3 质量自查表"
  )
  for h in "${REQUIRED_SUBHEADINGS[@]}"; do
    if grep -qF "${h}" "${file}"; then
      success "${BASENAME}: 小节标题 '${h}' 存在"
    else
      warn "${BASENAME}: 缺少小节标题 '${h}'"
    fi
  done

  US_COUNT=$(grep -c 'US-[0-9]' "${file}" 2>/dev/null || true)
  UC_COUNT=$(grep -c 'UC-[0-9]' "${file}" 2>/dev/null || true)
  BR_COUNT=$(grep -c 'BR-[0-9]' "${file}" 2>/dev/null || true)
  EX_COUNT=$(grep -c 'EX-[0-9]' "${file}" 2>/dev/null || true)
  AC_COUNT=$(grep -c 'AC-[0-9]' "${file}" 2>/dev/null || true)
  NAC_COUNT=$(grep -c 'NAC-[0-9]' "${file}" 2>/dev/null || true)
  FR_COUNT=$(grep -c 'FR-[0-9]' "${file}" 2>/dev/null || true)

  info "${BASENAME}: US-n=${US_COUNT} UC-n=${UC_COUNT} BR-n=${BR_COUNT} EX-n=${EX_COUNT} AC-n=${AC_COUNT} NAC-n=${NAC_COUNT} FR-n=${FR_COUNT}"

  if [[ ${US_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现用户故事编号 (US-n)"
  fi
  if [[ ${UC_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现用例编号 (UC-n)"
  fi
  if [[ ${FR_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现功能需求引用 (FR-n)，可追溯性可能不足"
  fi

  MERMAID_COUNT=$(grep -c '```mermaid' "${file}" 2>/dev/null || true)
  if [[ ${MERMAID_COUNT} -gt 0 ]]; then
    success "${BASENAME}: 包含 ${MERMAID_COUNT} 个 Mermaid 图"
  else
    warn "${BASENAME}: 未发现 Mermaid 图（业务流程、用例或交互图建议使用 Mermaid）"
  fi

  if grep -q 'ANALYSIS-' "${file}" || grep -q '^parent:' "${file}"; then
    success "${BASENAME}: 关联 ANALYSIS 基线"
  else
    warn "${BASENAME}: 未发现 ANALYSIS 关联信息"
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
