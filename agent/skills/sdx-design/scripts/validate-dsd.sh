#!/usr/bin/env bash
set -euo pipefail

# 详细设计说明书（DSD）结构校验
# 用法: validate-dsd.sh [--file <path>] [--gate-check] [--gate-strict]
#
# 可选 --gate-check：是否存在含 <!-- sdx-design-gate: CONFIRMED --> 且引用该 DSD 文件名的会话 spec

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
  echo "KNOWLEDGE_TYPE: （未设置，规约路径形态：{DOC_ROOT}/{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/specs/spec-dsd-{IDEA-ID}-{N}-{MS-ID}.md，按 application 语义终检）"
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
  DIRPATH=$(dirname "${file}")
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
    "## 3. 需求规约"
    "## 4. 附录"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/4 个必需章节（§1–§4，对齐 DSD 模板）"

  API_COUNT=$(grep -c 'API-[0-9]' "${file}" 2>/dev/null || true)
  LOGIC_COUNT=$(grep -c 'LOGIC-[0-9]' "${file}" 2>/dev/null || true)
  TBL_COUNT=$(grep -c 'TBL-[0-9]' "${file}" 2>/dev/null || true)
  info "${BASENAME}: API-n=${API_COUNT} LOGIC-n=${LOGIC_COUNT} TBL-n=${TBL_COUNT}"

  if grep -qF "ASD-" "${file}"; then
    success "${BASENAME}: 文内引用 ASD 文档"
  elif grep -qE '\./specs/spec-|specs/spec-' "${file}"; then
    success "${BASENAME}: 文内引用需求规约路径（{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/specs/spec-dsd-{IDEA-ID}-{N}-{MS-ID}.md 形态）"
  else
    warn "${BASENAME}: 未发现 ASD-* 或 {DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/specs/spec-dsd-{IDEA-ID}-{N}-{MS-ID}.md 引用（建议在「关联文档」或正文引用 ASD，或 **概设需求规约** / **详设需求规约** 路径）"
  fi

  if grep -q 'PRD-' "${file}"; then
    success "${BASENAME}: 关联 PRD 文档"
  else
    warn "${BASENAME}: 未发现关联 PRD 编号 (PRD-*)"
  fi

  MVP_SPECS_DIR="${DIRPATH}/specs"
  DOC_SPECS_DIR="${DOC_ROOT}/specs"
  _kt="${KNOWLEDGE_TYPE:-}"

  # spec-dsd 唯一合法目录：与 DSD 同包 MVP-Phase-{N}/specs/；禁止落在 {DOC_ROOT}/specs/
  if [[ -d "${DOC_SPECS_DIR}" ]]; then
    MIS_DSD=$(find "${DOC_SPECS_DIR}" -maxdepth 1 -name 'spec-dsd-*.md' 2>/dev/null | wc -l | tr -d ' ')
    if [[ "${MIS_DSD}" -gt 0 ]]; then
      warn "${BASENAME}: ${DOC_SPECS_DIR} 下存在 spec-dsd-*.md —— 详设需求规约只能写在 requirements/.../MVP-Phase-*/specs/，不得放在 {DOC_ROOT}/specs/"
    fi
  fi

  if [[ "${_kt}" == "system" || "${_kt}" == "company" ]]; then
    success "${BASENAME}: KNOWLEDGE_TYPE=${_kt}，跳过 MVP-Phase 下 spec-dsd 检查（联邦概要）"
    if [[ -d "${DOC_SPECS_DIR}" ]]; then
      FSPEC_COUNT=$(find "${DOC_SPECS_DIR}" -maxdepth 1 -name 'spec-asd-*.md' 2>/dev/null | wc -l | tr -d ' ')
      if [[ "${FSPEC_COUNT}" -gt 0 ]]; then
        info "${BASENAME}: 联邦概要下 ${DOC_SPECS_DIR} 有 ${FSPEC_COUNT} 个 spec-asd-*.md（可忽略）"
      fi
    fi
  elif [[ -d "${MVP_SPECS_DIR}" ]]; then
    DSD_SPEC_COUNT=$(find "${MVP_SPECS_DIR}" -maxdepth 1 -name 'spec-dsd-*.md' 2>/dev/null | wc -l | tr -d ' ')
    if [[ "${DSD_SPEC_COUNT}" -gt 0 ]]; then
      success "${BASENAME}: ${MVP_SPECS_DIR} 下存在 ${DSD_SPEC_COUNT} 个 spec-dsd-*.md（合法路径）"
    else
      warn "${BASENAME}: ${MVP_SPECS_DIR} 下未发现 spec-dsd-*.md（应用全量时应在总确认后与 DSD 同期产出）"
    fi
  else
    warn "${BASENAME}: 未找到 ${MVP_SPECS_DIR}（应与 DSD 同目录创建 specs/ 并落 spec-dsd-*.md）"
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
