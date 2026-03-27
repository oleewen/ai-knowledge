#!/usr/bin/env bash
set -euo pipefail

# 知识库结构校验脚本
# 用法: scripts/validate-knowledge.sh [--doc-root <path>]
#
# 校验项:
#   1. knowledge_meta.yaml 存在（knowledge 块为可选覆盖层）
#   2. KNOWLEDGE_INDEX.md 存在
#   3. 各视角目录存在且含 README.md
#   4. *_meta.yaml 文件格式有效
#   5. CHANGELOG.md 存在

DOC_ROOT="."
ERRORS=0
WARNINGS=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --doc-root) DOC_ROOT="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

KNOWLEDGE_DIR="${DOC_ROOT}/knowledge"
META_FILE="${DOC_ROOT}/knowledge/knowledge_meta.yaml"
INDEX_FILE="${DOC_ROOT}/knowledge/KNOWLEDGE_INDEX.md"
CHANGELOG_DIR="${DOC_ROOT}/changelogs"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== 知识库结构校验 ==="
echo "Doc Root: ${DOC_ROOT}"
echo ""

# 1. knowledge_meta.yaml（目录元数据必需，knowledge 块为可选覆盖）
if [[ -f "${META_FILE}" ]]; then
  success "knowledge_meta.yaml 存在"
  if grep -q "^knowledge:" "${META_FILE}" 2>/dev/null || grep -q "^knowledge$" "${META_FILE}" 2>/dev/null; then
    info "knowledge 覆盖块存在（将与内置默认合并）"
  else
    info "无 knowledge 覆盖块（使用内置默认配置）"
  fi
else
  warn "knowledge_meta.yaml 不存在: ${META_FILE}（使用内置默认配置）"
fi

# 2. KNOWLEDGE_INDEX.md
if [[ -f "${INDEX_FILE}" ]]; then
  LINE_COUNT=$(wc -l < "${INDEX_FILE}" | tr -d ' ')
  if [[ ${LINE_COUNT} -gt 5 ]]; then
    success "KNOWLEDGE_INDEX.md 存在 (${LINE_COUNT} 行)"
  else
    warn "KNOWLEDGE_INDEX.md 内容过少 (${LINE_COUNT} 行)"
  fi
else
  error "KNOWLEDGE_INDEX.md 不存在: ${INDEX_FILE}"
fi

# 3. 视角目录
PERSPECTIVES=("technical" "data" "business" "product")
for p in "${PERSPECTIVES[@]}"; do
  DIR="${KNOWLEDGE_DIR}/${p}"
  if [[ -d "${DIR}" ]]; then
    if [[ -f "${DIR}/README.md" ]]; then
      success "${p}/ 目录及 README.md 存在"
    else
      warn "${p}/ 目录存在但缺少 README.md"
    fi
  else
    warn "${p}/ 视角目录不存在: ${DIR}"
  fi
done

# 4. *_meta.yaml 文件检查
META_COUNT=0
if [[ -d "${KNOWLEDGE_DIR}" ]]; then
  while IFS= read -r -d '' meta_file; do
    META_COUNT=$((META_COUNT + 1))
    if [[ ! -s "${meta_file}" ]]; then
      warn "空的 meta 文件: ${meta_file}"
    fi
  done < <(find "${KNOWLEDGE_DIR}" -name "*_meta.yaml" -print0 2>/dev/null)
fi
info "发现 ${META_COUNT} 个 *_meta.yaml 文件"

# 5. CHANGELOG
if [[ -d "${CHANGELOG_DIR}" ]]; then
  if [[ -f "${CHANGELOG_DIR}/CHANGELOG.md" ]]; then
    success "changelogs/CHANGELOG.md 存在"
  else
    warn "changelogs/ 目录存在但缺少 CHANGELOG.md"
  fi
else
  warn "changelogs/ 目录不存在"
fi

# 6. 实体 JSON 文件检查
ENTITY_FILES=("technical_entity.json" "data_entity.json" "business_entity.json" "product_entity.json")
for ef in "${ENTITY_FILES[@]}"; do
  PERSPECTIVE=$(echo "${ef}" | sed 's/_entity\.json//')
  ENTITY_PATH="${KNOWLEDGE_DIR}/${PERSPECTIVE}/${ef}"
  if [[ -f "${ENTITY_PATH}" ]]; then
    success "${ef} 存在"
  else
    info "${ef} 未找到（可选）"
  fi
done

echo ""
echo "=== 校验结果 ==="
echo "错误: ${ERRORS}  警告: ${WARNINGS}"

if [[ ${ERRORS} -gt 0 ]]; then
  echo "校验失败，请修复以上错误。"
  exit 1
else
  echo "校验通过。"
  exit 0
fi
