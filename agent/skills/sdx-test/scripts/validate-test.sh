#!/usr/bin/env bash
set -euo pipefail

# TDD 结构校验（六章模板；不承担写前门禁）。
# 用法：validate-test.sh [--file <path>]
# 要点：文首 frontmatter、`id`、六章、关键子章节、TC 编号、PRD/DSD 关联；
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

TEMPLATE="${SCRIPT_DIR}/../assets/tdd-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== TDD 结构校验 ==="
echo "DOC_ROOT: ${DOC_ROOT}"
echo ""

if [[ -f "${TEMPLATE}" ]]; then
  success "tdd-template.md 存在"
else
  warn "tdd-template.md 不存在: ${TEMPLATE}"
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
    fi
  fi

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

  SUB_SECTIONS=(
    "### 1.1 测试目标"
    "### 1.2 测试范围"
    "### 1.3 测试策略"
    "### 2.1 功能测试用例"
    "### 2.2 接口测试用例"
    "### 2.3 业务规则测试用例"
    "### 2.4 异常场景测试用例"
    "### 2.6 回归测试用例"
    "### 5.1 进入标准"
    "### 5.2 退出标准"
  )
  SUB_COUNT=0
  for sub in "${SUB_SECTIONS[@]}"; do
    if grep -qF "${sub}" "${file}"; then
      SUB_COUNT=$((SUB_COUNT + 1))
    else
      warn "${BASENAME}: 缺少关键子章节 '${sub}'"
    fi
  done
  info "${BASENAME}: ${SUB_COUNT}/${#SUB_SECTIONS[@]} 个关键子章节"

  TC_COUNT=$(grep -c 'TC-[0-9]' "${file}" 2>/dev/null || true)
  TC_API_COUNT=$(grep -c 'TC-API-[0-9]' "${file}" 2>/dev/null || true)
  TC_BR_COUNT=$(grep -c 'TC-BR-[0-9]' "${file}" 2>/dev/null || true)
  TC_EX_COUNT=$(grep -c 'TC-EX-[0-9]' "${file}" 2>/dev/null || true)
  TC_REG_COUNT=$(grep -c 'TC-REG-[0-9]' "${file}" 2>/dev/null || true)
  info "${BASENAME}: TC=${TC_COUNT} TC-API=${TC_API_COUNT} TC-BR=${TC_BR_COUNT} TC-EX=${TC_EX_COUNT} TC-REG=${TC_REG_COUNT}"

  if grep -q 'PRD-' "${file}"; then
    success "${BASENAME}: 关联 PRD 文档"
  else
    warn "${BASENAME}: 未发现关联 PRD 编号 (PRD-*)"
  fi

  if grep -q 'DSD-' "${file}" || grep -q 'ASD-' "${file}"; then
    success "${BASENAME}: 关联 DSD/ASD 文档"
  else
    warn "${BASENAME}: 未发现关联 DSD-* 或 ASD-* 引用"
  fi

  if grep -q 'US-' "${file}" || grep -q 'BR-' "${file}"; then
    success "${BASENAME}: 存在需求或规则追溯"
  else
    warn "${BASENAME}: 未发现 US-* 或 BR-* 追溯"
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
