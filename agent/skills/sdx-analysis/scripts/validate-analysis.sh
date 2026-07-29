#!/usr/bin/env bash
set -euo pipefail

# ANALYSIS 结构校验（六章模板；不承担写前门禁）。
# 用法：validate-analysis.sh [--file <path>]
# DOC_ROOT：resolve_repo_doc_root（.docsconfig）；先 config-bootstrap.sh
#
# 要点：文首 frontmatter、六章、`### FR-`、小节标题、FR/BR/R/MVP、概览「需求概要」、
#       所属 MVP 形如 MVP-n（…）、与 SOLUTION 关联；
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

ANALYSIS_DIR="${DOC_ROOT}/analysis"
TEMPLATE="${SCRIPT_DIR}/../assets/analysis-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== 需求分析文档结构校验 ==="
echo "DOC_ROOT: ${DOC_ROOT}"
echo ""

if [[ -f "${TEMPLATE}" ]]; then
  success "analysis-template.md 存在"
else
  warn "analysis-template.md 不存在: ${TEMPLATE}"
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
      for field in "id:" "title:" "version:" "status:" "created:" "updated:" "author:" "reviewers:" "parent:" "tags:"; do
        if echo "${FRONTMATTER_CONTENT}" | grep -qE "^${field}"; then
          success "${BASENAME}: ${field} 字段存在"
        else
          warn "${BASENAME}: 缺少 ${field} 字段"
        fi
      done

      ID_LINE=$(echo "${FRONTMATTER_CONTENT}" | grep -E '^id:' 2>/dev/null | head -1 || true)
      if [[ -n "${ID_LINE}" ]]; then
        if echo "${ID_LINE}" | grep -qE 'ANALYSIS-'; then
          success "${BASENAME}: id 含 ANALYSIS- 前缀"
        else
          warn "${BASENAME}: id 建议符合 ANALYSIS-{IDEA-ID}，实际: ${ID_LINE}"
        fi
      fi

      PARENT_LINE=$(echo "${FRONTMATTER_CONTENT}" | grep -E '^parent:' 2>/dev/null | head -1 || true)
      if echo "${PARENT_LINE}" | grep -q 'SOLUTION-'; then
        success "${BASENAME}: parent 已关联 SOLUTION-*"
      else
        warn "${BASENAME}: parent 建议关联 SOLUTION-{IDEA-ID}，实际: ${PARENT_LINE}"
      fi
    fi
  fi

  REQUIRED_SECTIONS=(
    "## 1. 背景目标"
    "## 2. 功能需求"
    "## 3. 非功能需求"
    "## 4. 交付计划"
    "## 5. 依赖与风险"
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

  REQUIRED_SUBHEADINGS=(
    "### 1.1 需求背景"
    "### 1.2 需求目标"
    "### 1.3 范围约束"
    "#### 范围与边界"
    "#### 假设与约束"
    "#### 研究与分析"
    "### 概览"
    "### 3.1 体验与性能"
    "### 3.2 可用性与连续性"
    "### 3.3 安全与合规"
    "### 3.4 可追溯与问题定位"
    "### 3.5 兼容与升级"
    "### 4.1 MVP 总览"
    "### 4.2 MVP 详细规划"
    "### 4.3 MVP 依赖关系"
    "### 5.1 依赖关系"
    "### 5.2 风险评估"
    "### 6.1 术语表"
    "### 6.2 参考文档"
    "### 6.3 变更历史"
    "### 6.4 质量自查表 (Self-Check)"
  )
  SUB_COUNT=0
  SUB_TOTAL=${#REQUIRED_SUBHEADINGS[@]}
  for h in "${REQUIRED_SUBHEADINGS[@]}"; do
    if grep -qF "${h}" "${file}"; then
      SUB_COUNT=$((SUB_COUNT + 1))
    else
      warn "${BASENAME}: 缺少小节标题 '${h}'"
    fi
  done
  info "${BASENAME}: 模板小节 ${SUB_COUNT}/${SUB_TOTAL} 个标题命中"

  FR_COUNT=$(grep -cE 'FR-[0-9]{3}|FR-[0-9][0-9]' "${file}" 2>/dev/null || true)
  BR_COUNT=$(grep -c 'BR-[0-9]' "${file}" 2>/dev/null || true)
  R_COUNT=$(grep -c 'R-[0-9]' "${file}" 2>/dev/null || true)
  MVP_COUNT=$(grep -c 'MVP-[0-9]' "${file}" 2>/dev/null || true)

  info "${BASENAME}: FR 引用=${FR_COUNT} BR-n=${BR_COUNT} R-n=${R_COUNT} MVP-n=${MVP_COUNT}"

  if ! grep -qE '### FR-[0-9]' "${file}" 2>/dev/null; then
    warn "${BASENAME}: 未发现「### FR-n」功能需求分节标题"
  fi

  if [[ ${MVP_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现 MVP 阶段编号 (MVP-n)"
  fi

  # 概览表：需求概要列 + 所属 MVP 形如 MVP-n（…）
  if grep -qF '### 概览' "${file}" 2>/dev/null; then
    if grep -qF '需求概要' "${file}" 2>/dev/null; then
      success "${BASENAME}: 概览含「需求概要」列"
    else
      warn "${BASENAME}: 概览缺少「需求概要」列（模板要求）"
    fi
    if grep -qE 'MVP-[0-9]+（[^）]+）|MVP-[0-9]+\([^)]+\)' "${file}" 2>/dev/null; then
      success "${BASENAME}: 发现所属 MVP 形如 MVP-n（里程碑名）"
    else
      warn "${BASENAME}: 未发现 MVP-n（里程碑名）写法（建议对齐 SOLUTION §6.1）"
    fi
  fi

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
