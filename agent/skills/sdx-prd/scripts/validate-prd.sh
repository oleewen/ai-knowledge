#!/usr/bin/env bash
set -euo pipefail

# PRD 文档结构校验脚本
# 用法: scripts/validate-prd.sh [--file <path>] [--gate-check] [--gate-strict]
# DOC_ROOT：resolve_repo_doc_root（仅 .docsconfig）；见 agent/scripts/docsconfig-bootstrap.sh
#
# 说明：闸门式工作流仅改变产出过程，不改变 PRD 文档结构要求；校验项仍以十一章模板为准。
#
# 校验项:
#   1. 文档目录存在
#   2. 文末「文档元数据」YAML 完整性（id、title、version、status、parent、mvp_phase）；禁止文件头 ---
#   3. 十一章结构完整性（与当前 prd-template.md 一致）
#   4. 编号体系一致性（US-n、UC-n、BR-n、EX-n、AC-n）
#   5. 模板 prd-template.md 存在
#   6. 需求分析关联检查
#   7. 可选 --gate-check：是否存在含 <!-- sdx-prd-gate: CONFIRMED --> 且引用该文件名的会话 spec（见 SKILL HARD-GATE）

TARGET_FILE=""
ERRORS=0
WARNINGS=0
GATE_CHECK=false
GATE_STRICT=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --file) TARGET_FILE="$2"; shift 2 ;;
    --gate-check) GATE_CHECK=true; shift ;;
    --gate-strict) GATE_CHECK=true; GATE_STRICT=true; shift ;;
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
TEMPLATE="agent/skills/sdx-prd/assets/prd-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

# 会话 spec 闸门：docs/superpowers/specs/**/*.md 须同时包含 CONFIRMED 标记与目标文件名
check_prd_gate() {
  local file="$1"
  local base
  base=$(basename "${file}")
  local specs_dir="${REPO_ROOT}/docs/superpowers/specs"
  if [[ ! -d "${specs_dir}" ]]; then
    warn "闸门：未找到 ${specs_dir}，跳过 gate 检查"
    return
  fi
  local found=0
  local spec
  while IFS= read -r -d '' spec; do
    if grep -qF "<!-- sdx-prd-gate: CONFIRMED -->" "${spec}" 2>/dev/null && grep -qF "${base}" "${spec}" 2>/dev/null; then
      found=1
      break
    fi
  done < <(find "${specs_dir}" -name "*.md" -print0 2>/dev/null)
  if [[ ${found} -eq 1 ]]; then
    success "闸门：已找到引用 ${base} 且 CONFIRMED 的会话 spec"
  else
    local msg="闸门：未找到引用 ${base} 且 <!-- sdx-prd-gate: CONFIRMED --> 的会话 spec（见 agent/skills/sdx-prd/SKILL.md）"
    if [[ "${GATE_STRICT}" == true ]]; then
      error "${msg}"
    else
      warn "${msg}"
    fi
  fi
}

echo "=== PRD 文档结构校验 ==="
echo "DOC_ROOT: ${DOC_ROOT}"
echo ""

# 0. 模板文件
if [[ -f "${TEMPLATE}" ]]; then
  success "prd-template.md 存在"
else
  warn "prd-template.md 不存在: ${TEMPLATE}"
fi

# 1. 文档目录
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
  done < <(find "${REQUIREMENTS_DIR}" -name "PRD-*.md" -print0 2>/dev/null)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  info "未找到 PRD 文档"
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
  FIRST_LINE=$(head -1 "${file}" 2>/dev/null || true)
  if [[ "${FIRST_LINE}" == "---" ]]; then
    warn "${BASENAME}: 首行为 ---（疑似 YAML frontmatter，应移除）；元数据须仅在文末「## 文档元数据」的 yaml 代码块中"
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

  # 3. 十一章结构检查
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

  # 3b. 模板小节（缺失时仅警告，兼容旧 PRD）
  if ! grep -qF "### 1.2 成功标准" "${file}"; then
    warn "${BASENAME}: 未找到「### 1.2 成功标准」（建议按当前 prd-template 补全 §1.2）"
  fi
  if ! grep -qF "## 9. 非功能需求" "${file}"; then
    warn "${BASENAME}: 未找到「## 9. 非功能需求」（建议按当前 prd-template 补全独立 §9）"
  fi

  # 4. 编号体系检查
  US_COUNT=$(grep -c 'US-[0-9]' "${file}" 2>/dev/null || true)
  UC_COUNT=$(grep -c 'UC-[0-9]' "${file}" 2>/dev/null || true)
  BR_COUNT=$(grep -c 'BR-[0-9]' "${file}" 2>/dev/null || true)
  EX_COUNT=$(grep -c 'EX-[0-9]' "${file}" 2>/dev/null || true)
  AC_COUNT=$(grep -c 'AC-[0-9]' "${file}" 2>/dev/null || true)

  info "${BASENAME}: US-n=${US_COUNT} UC-n=${UC_COUNT} BR-n=${BR_COUNT} EX-n=${EX_COUNT} AC-n=${AC_COUNT}"

  if [[ ${US_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现用户故事编号 (US-n)"
  fi

  if [[ ${UC_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现用例编号 (UC-n)"
  fi

  # 5. Mermaid 图检查
  MERMAID_COUNT=$(grep -c '```mermaid' "${file}" 2>/dev/null || true)
  if [[ ${MERMAID_COUNT} -gt 0 ]]; then
    success "${BASENAME}: 包含 ${MERMAID_COUNT} 个 Mermaid 图"
  else
    warn "${BASENAME}: 未发现 Mermaid 图（业务流程与用例图应使用 Mermaid）"
  fi

  # 6. 需求分析关联检查
  if grep -q 'REQUIREMENT-' "${file}"; then
    success "${BASENAME}: 关联需求分析文档"
  else
    warn "${BASENAME}: 未发现关联需求分析编号 (REQUIREMENT-*)"
  fi

  # 7. FR-n 追溯检查
  FR_COUNT=$(grep -c 'FR-[0-9]' "${file}" 2>/dev/null || true)
  if [[ ${FR_COUNT} -gt 0 ]]; then
    success "${BASENAME}: 包含 ${FR_COUNT} 处 FR-n 引用"
  else
    warn "${BASENAME}: 未发现功能需求引用 (FR-n)，可追溯性可能不足"
  fi

  if [[ "${GATE_CHECK}" == true ]]; then
    check_prd_gate "${file}"
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
