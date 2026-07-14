#!/usr/bin/env bash
set -euo pipefail

# ASD 结构校验（§1-§3 模板；不承担写前门禁）。
# 用法：validate-asd.sh [--file <path>]
# 要点：文首 frontmatter、`id`、`§1-§3`、关键标题、DD 编号、PRD 关联；
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
TEMPLATE="${SCRIPT_DIR}/../assets/asd-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== ASD 结构校验 ==="
echo "DOC_ROOT: ${DOC_ROOT}"
if [[ -n "${KNOWLEDGE_TYPE:-}" ]]; then
  echo "KNOWLEDGE_TYPE: ${KNOWLEDGE_TYPE}"
fi
echo ""

if [[ -f "${TEMPLATE}" ]]; then
  success "asd-template.md 存在"
else
  warn "asd-template.md 不存在: ${TEMPLATE}"
fi

FILES=()
if [[ -n "${TARGET_FILE}" ]]; then
  if [[ -f "${TARGET_FILE}" ]]; then
    FILES=("${TARGET_FILE}")
  else
    error "指定文件不存在: ${TARGET_FILE}"
    exit 1
  fi
else
  if [[ -d "${REQUIREMENTS_DIR}" ]]; then
    FILE_COUNT=$(find "${REQUIREMENTS_DIR}" -name "ASD-*.md" 2>/dev/null | wc -l | tr -d ' ')
    success "requirements/ 目录存在 (${FILE_COUNT} 个 ASD 文档)"
  else
    warn "requirements/ 目录不存在: ${REQUIREMENTS_DIR}"
    echo ""
    echo "=== 校验结果 ==="
    echo "错误: ${ERRORS}  警告: ${WARNINGS}"
    exit 0
  fi

  while IFS= read -r -d '' f; do
    FILES+=("$f")
  done < <(find "${REQUIREMENTS_DIR}" -name "ASD-*.md" -print0 2>/dev/null)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  info "未找到 ASD 文档"
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
      if echo "${PARENT_LINE}" | grep -q 'PRD-'; then
        success "${BASENAME}: parent 含 PRD- 前缀"
      else
        warn "${BASENAME}: parent 建议指向 PRD-{IDEA-ID}-{N}，实际: ${PARENT_LINE}"
      fi
    fi
  fi

  REQUIRED_SECTIONS=(
    "## 1. 设计概述"
    "## 2. 架构设计"
    "## 3. 需求规约"
  )
  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/3 个必需章节"

  REQUIRED_SUBHEADINGS=(
    "### 1.1 设计目标"
    "### 1.2 设计约束"
    "### 1.3 关键设计决策"
    "### 2.1 系统架构设计"
    "### 3.1 需求规约摘要"
  )
  for h in "${REQUIRED_SUBHEADINGS[@]}"; do
    if grep -qF "${h}" "${file}"; then
      success "${BASENAME}: 小节标题 '${h}' 存在"
    else
      warn "${BASENAME}: 缺少小节标题 '${h}'"
    fi
  done

  DD_COUNT=$(grep -c 'DD-[0-9]' "${file}" 2>/dev/null || true)
  info "${BASENAME}: DD-n=${DD_COUNT}"
  if [[ ${DD_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现设计决策编号 (DD-n)"
  fi

  if grep -q 'PRD-' "${file}"; then
    success "${BASENAME}: 关联 PRD 文档"
  else
    warn "${BASENAME}: 未发现关联 PRD 编号 (PRD-*)"
  fi

  if [[ "${KNOWLEDGE_TYPE:-}" == "system" || "${KNOWLEDGE_TYPE:-}" == "company" ]]; then
    if grep -q 'DSD-' "${file}" || grep -q 'spec-asd-' "${file}"; then
      success "${BASENAME}: 含下游承接指针"
    else
      warn "${BASENAME}: 联邦模式建议显式给出下游承接指针（DSD/spec-asd）"
    fi
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
