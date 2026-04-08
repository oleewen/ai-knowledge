#!/usr/bin/env bash
set -euo pipefail

# 技术设计文档结构校验脚本
# 用法: scripts/validate-design.sh [--file <path>]
# DOC_ROOT：resolve_repo_doc_root（仅 .docsconfig）；见 .agent/scripts/docsconfig-bootstrap.sh
#
# 校验项:
#   1. 文档目录存在
#   2. 文末「文档元数据」YAML 完整性（id、title、version、status、parent、mvp_phase）；禁止文件头 ---
#   3. 五章结构完整性
#   4. 编号体系一致性（DD-n、API-n、LOGIC-n、TBL-n）
#   5. 模板 add-template.md 存在
#   6. specs 目录结构校验

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
source "$_AGENT_HOME/scripts/docsconfig-bootstrap.sh"
validate_bootstrap_docsconfig "$SCRIPT_DIR"

DOC_ROOT="$(resolve_repo_doc_root)"
cd "$REPO_ROOT" || exit 1

REQUIREMENTS_DIR="${DOC_ROOT}/requirements"
TEMPLATE=".agent/skills/sdx-design/assets/add-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== 技术设计文档结构校验 ==="
echo "DOC_ROOT: ${DOC_ROOT}"
echo ""

# 0. 模板文件
if [[ -f "${TEMPLATE}" ]]; then
  success "add-template.md 存在"
else
  warn "add-template.md 不存在: ${TEMPLATE}"
fi

# 1. 文档目录
if [[ -d "${REQUIREMENTS_DIR}" ]]; then
  FILE_COUNT=$(find "${REQUIREMENTS_DIR}" -name "ADD-*.md" 2>/dev/null | wc -l | tr -d ' ')
  success "requirements/ 目录存在 (${FILE_COUNT} 个 ADD 文档)"
else
  warn "requirements/ 目录不存在: ${REQUIREMENTS_DIR}"
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
  done < <(find "${REQUIREMENTS_DIR}" -name "ADD-*.md" -print0 2>/dev/null)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  info "未找到 ADD 文档"
  echo ""
  echo "=== 校验结果 ==="
  echo "错误: ${ERRORS}  警告: ${WARNINGS}"
  exit 0
fi

# 校验每个文档
for file in "${FILES[@]}"; do
  BASENAME=$(basename "${file}")
  DIRPATH=$(dirname "${file}")
  echo "--- 校验: ${BASENAME} ---"

  # 2. 文档元数据（文末 YAML，非文件头 frontmatter）
  if head -5 "${file}" | grep -q "^---"; then
    warn "${BASENAME}: 文件开头存在 ---（应移除）；元数据须仅在文末「## 文档元数据」的 yaml 代码块中"
  fi

  if grep -qF "## 文档元数据" "${file}"; then
    success "${BASENAME}: 「文档元数据」章节存在"
    for field in "id:" "title:" "version:" "status:" "parent:" "mvp_phase:"; do
      if grep -q "${field}" "${file}"; then
        success "${BASENAME}: ${field} 字段存在"
      else
        warn "${BASENAME}: 缺少 ${field} 字段"
      fi
    done
  else
    warn "${BASENAME}: 缺少「## 文档元数据」章节（须在文末放置 YAML 元数据）"
  fi

  # 3. 五章结构检查
  REQUIRED_SECTIONS=(
    "## 1. 设计概述"
    "## 2. 架构设计"
    "## 3. 详细设计"
    "## 4. 需求规约"
    "## 5. 附录"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/5 个必需章节"

  # 4. 编号体系检查
  DD_COUNT=$(grep -c 'DD-[0-9]' "${file}" 2>/dev/null || true)
  API_COUNT=$(grep -c 'API-[0-9]' "${file}" 2>/dev/null || true)
  LOGIC_COUNT=$(grep -c 'LOGIC-[0-9]' "${file}" 2>/dev/null || true)
  TBL_COUNT=$(grep -c 'TBL-[0-9]' "${file}" 2>/dev/null || true)

  info "${BASENAME}: DD-n=${DD_COUNT} API-n=${API_COUNT} LOGIC-n=${LOGIC_COUNT} TBL-n=${TBL_COUNT}"

  if [[ ${DD_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现设计决策编号 (DD-n)"
  fi

  # 5. PRD 关联检查
  if grep -q 'PRD-' "${file}"; then
    success "${BASENAME}: 关联 PRD 文档"
  else
    warn "${BASENAME}: 未发现关联 PRD 编号 (PRD-*)"
  fi

  # 6. specs 目录检查
  SPECS_DIR="${DIRPATH}/specs"
  if [[ -d "${SPECS_DIR}" ]]; then
    SPEC_COUNT=$(find "${SPECS_DIR}" -name "*.yaml" -o -name "*.yml" 2>/dev/null | wc -l | tr -d ' ')
    success "${BASENAME}: specs/ 目录存在 (${SPEC_COUNT} 个规约文件)"

    for subdir in "api" "domain" "data"; do
      if find "${SPECS_DIR}" -type d -name "${subdir}" 2>/dev/null | grep -q .; then
        success "${BASENAME}: specs/ 含 ${subdir}/ 子目录"
      else
        warn "${BASENAME}: specs/ 缺少 ${subdir}/ 子目录"
      fi
    done
  else
    warn "${BASENAME}: specs/ 目录不存在: ${SPECS_DIR}"
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
