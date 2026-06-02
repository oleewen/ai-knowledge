#!/usr/bin/env bash
set -euo pipefail

# ASD 结构校验。[--file <path>] [--gate-check|--gate-strict]

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
TEMPLATE="${_AGENT_HOME}/skills/sdx-architect/assets/asd-template.md"
if [[ ! -f "${TEMPLATE}" ]]; then
  TEMPLATE="${REPO_ROOT}/agent/skills/sdx-architect/assets/asd-template.md"
fi

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

# shellcheck source=../../../scripts/check-session-spec-gate.sh
source "${REPO_ROOT}/agent/scripts/check-session-spec-gate.sh"

# 会话 spec 闸门：{DOC_DIR}/superpower/specs/（见 agent/references/session-spec-path.md）

check_architect_gate() {
  local file="$1"
  local base
  base=$(basename "${file}")
  if check_session_spec_gate "<!-- sdx-architect-gate: CONFIRMED -->" "${base}"; then
    success "闸门：已找到引用 ${base} 且 CONFIRMED 的会话 spec"
  else
    local msg="闸门：缺少引用 ${base} 且 CONFIRMED 的会话 spec（见 sdx-architect SKILL 门禁）"
    if [[ "${GATE_STRICT}" == true ]]; then
      error "${msg}"
    else
      warn "${msg}"
    fi
  fi
}

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

if [[ -n "${TARGET_FILE}" ]]; then
  if [[ -f "${TARGET_FILE}" ]]; then
    FILES=("${TARGET_FILE}")
  else
    error "指定文件不存在: ${TARGET_FILE}"
    exit 1
  fi
else
  FILES=()
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

  if head -5 "${file}" | grep -q "^---"; then
    warn "${BASENAME}: 文件开头存在 ---（应移除）"
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
    "## 2. 架构设计"
    "## 3. 需求规约"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      error "${BASENAME}: 缺少 '${section}'（须 §1–§3）"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/3 个必需章节（§1–§3）"

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

  if [[ "${GATE_CHECK}" == true ]]; then
    check_architect_gate "${file}"
  fi

  echo ""
done

echo "=== 校验结果 ==="
echo "错误: ${ERRORS}  警告: ${WARNINGS}"

if [[ ${ERRORS} -gt 0 ]]; then
  echo "校验失败，请修正后重跑。"
  exit 1
else
  echo "校验通过。"
  exit 0
fi
