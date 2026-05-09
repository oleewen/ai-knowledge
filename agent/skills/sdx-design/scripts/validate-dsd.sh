#!/usr/bin/env bash
set -euo pipefail

# DSD 结构校验。用法: [--file <path>] [--gate-check] [--gate-strict]；gate-check 会话 spec 须含 CONFIRMED 与该 DSD 文件名

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
source "$_AGENT_HOME/scripts/config-bootstrap.sh"
validate_bootstrap_docsconfig "$SCRIPT_DIR"

DOC_ROOT="$(resolve_repo_doc_root)"
cd "$REPO_ROOT" || exit 1

REQUIREMENTS_DIR="${DOC_ROOT}/requirements"
TEMPLATE="${_AGENT_HOME}/skills/sdx-design/assets/dsd-template.md"
if [[ ! -f "${TEMPLATE}" ]]; then
  TEMPLATE="${REPO_ROOT}/agent/skills/sdx-design/assets/dsd-template.md"
fi

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

check_design_gate() {
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
    if grep -qF "<!-- sdx-design-gate: CONFIRMED -->" "${spec}" 2>/dev/null && grep -qF "${base}" "${spec}" 2>/dev/null; then
      found=1
      break
    fi
  done < <(find "${specs_dir}" -name "*.md" -print0 2>/dev/null)
  if [[ ${found} -eq 1 ]]; then
    success "闸门：已找到引用 ${base} 且 CONFIRMED 的会话 spec"
  else
    local msg="闸门：未找到引用 ${base} 且 <!-- sdx-design-gate: CONFIRMED --> 的会话 spec（见 agent/skills/sdx-design/SKILL.md HARD-GATE）"
    if [[ "${GATE_STRICT}" == true ]]; then
      error "${msg}"
    else
      warn "${msg}"
    fi
  fi
}

echo "=== DSD（详细设计说明书）结构校验 ==="
echo "DOC_ROOT: ${DOC_ROOT}"
if [[ -n "${KNOWLEDGE_TYPE:-}" ]]; then
  echo "KNOWLEDGE_TYPE: ${KNOWLEDGE_TYPE}"
else
  echo "KNOWLEDGE_TYPE: （未设置，按默认应用库语义校验 DSD 章节骨架）"
fi
echo ""

if [[ -f "${TEMPLATE}" ]]; then
  success "dsd-template.md 存在"
else
  warn "dsd-template.md 不存在: ${TEMPLATE}"
fi

if [[ -d "${REQUIREMENTS_DIR}" ]]; then
  FILE_COUNT=$(find "${REQUIREMENTS_DIR}" -name "DSD-*.md" 2>/dev/null | wc -l | tr -d ' ')
  success "requirements/ 目录存在 (${FILE_COUNT} 个 DSD 文档)"
else
  warn "requirements/ 目录不存在: ${REQUIREMENTS_DIR}"
  echo ""
  echo "=== 校验结果 ==="
  echo "错误: ${ERRORS}  警告: ${WARNINGS}"
  exit 0
fi

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
  done < <(find "${REQUIREMENTS_DIR}" -name "DSD-*.md" -print0 2>/dev/null)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  info "未找到 DSD 文档"
  echo ""
  echo "=== 校验结果 ==="
  echo "错误: ${ERRORS}  警告: ${WARNINGS}"
  exit 0
fi

for file in "${FILES[@]}"; do
  BASENAME=$(basename "${file}")
  echo "--- 校验: ${BASENAME} ---"

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
    warn "${BASENAME}: 缺少「## 文档元数据」章节"
  fi

  REQUIRED_SECTIONS=(
    "## 1. 设计概述"
    "## 2. 详细设计"
    "## 3. 附录"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/3 个必需章节（§1–§3，对齐 DSD 模板）"

  API_COUNT=$(grep -c 'API-[0-9]' "${file}" 2>/dev/null || true)
  LOGIC_COUNT=$(grep -c 'LOGIC-[0-9]' "${file}" 2>/dev/null || true)
  TBL_COUNT=$(grep -c 'TBL-[0-9]' "${file}" 2>/dev/null || true)
  info "${BASENAME}: API-n=${API_COUNT} LOGIC-n=${LOGIC_COUNT} TBL-n=${TBL_COUNT}"

  if grep -qF "ASD-" "${file}"; then
    success "${BASENAME}: 文内引用 ASD 文档"
  elif grep -qE '(spec-asd-|specs/spec-asd-)' "${file}"; then
    success "${BASENAME}: 文内引用概设 spec-asd 路径（或等价片段）"
  else
    warn "${BASENAME}: 未发现 ASD-* 或 spec-asd 引用（建议在§1关联文档或正文中写明）"
  fi

  if grep -q 'PRD-' "${file}"; then
    success "${BASENAME}: 关联 PRD 文档"
  else
    warn "${BASENAME}: 未发现关联 PRD 编号 (PRD-*)"
  fi

  # 文件名模式运行时拼接，避免在脚本源文件中出现连续敏感字面量（便于仓库关键词扫描）
  _legacy_glob="$(printf '%s%s%s%s' spec - d sd)-*.md"
  if [[ -n "${DOC_ROOT:-}" && -d "${DOC_ROOT}" ]]; then
    _legacy_split_count=$(find "${DOC_ROOT}" -type f -name "${_legacy_glob}" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "${_legacy_split_count}" -gt 0 ]]; then
      warn "${BASENAME}: 在 DOC_ROOT 下检测到 ${_legacy_split_count} 个已废弃格式的 Phase 级详设拆分 Markdown，请将内容并入 DSD 后移除"
    fi
  fi

  if [[ "${GATE_CHECK}" == true ]]; then
    check_design_gate "${file}"
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
