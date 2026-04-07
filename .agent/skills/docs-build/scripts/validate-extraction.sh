#!/usr/bin/env bash
set -euo pipefail

# 知识实体提取结果验证脚本
# 用法: scripts/validate-extraction.sh [--doc-root <path>]
# doc_root 首段：--doc-root > SDX_DOC_ROOT > .sdx-doc-root > 探测 > system（见 .agent/scripts/sdx-doc-root.sh）
# 知识库目录：优先 {seg}/knowledge；否则 {seg}/application/knowledge
#
# 校验项:
#   1. KNOWLEDGE_INDEX.md 存在且非空
#   2. *_knowledge.json 文件格式有效（schema 2.1）
#   3. ID 前缀符合约定
#   4. 层级+ID 唯一性
#   5. 证据链非空
#   6. metadata 节存在

DOC_ROOT_ARG=""
ERRORS=0
WARNINGS=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --doc-root) DOC_ROOT_ARG="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AI_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AI_HOME/scripts/sdx-validate-bootstrap.sh"
sdx_validate_load_doc_root "$SCRIPT_DIR"

REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || pwd)"
DOC_ROOT="$(sdx_resolve_doc_root_segment "$DOC_ROOT_ARG" "$REPO_ROOT")"
cd "$REPO_ROOT" || exit 1

# 路径约定：{doc_root}/application/knowledge/ 或 {doc_root}/knowledge/（与 SKILL.md 一致）
if [[ -d "${DOC_ROOT}/knowledge" && ! -d "${DOC_ROOT}/application/knowledge" ]]; then
  KNOWLEDGE_DIR="${DOC_ROOT}/knowledge"
else
  KNOWLEDGE_DIR="${DOC_ROOT}/application/knowledge"
fi
INDEX_FILE="${KNOWLEDGE_DIR}/KNOWLEDGE_INDEX.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== 知识实体提取结果验证 ==="
echo "Doc Root: ${DOC_ROOT}"
echo ""

# 1. KNOWLEDGE_INDEX.md
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

# 2. *_knowledge.json 文件检查
PERSPECTIVES=("technical" "data" "business" "product")
KNOWLEDGE_COUNT=0

for p in "${PERSPECTIVES[@]}"; do
  KNOWLEDGE_FILE="${KNOWLEDGE_DIR}/${p}/${p}_knowledge.json"
  if [[ -f "${KNOWLEDGE_FILE}" ]]; then
    KNOWLEDGE_COUNT=$((KNOWLEDGE_COUNT + 1))
    # JSON 格式有效性
    if python3 -c "import json; json.load(open('${KNOWLEDGE_FILE}'))" 2>/dev/null; then
      success "${p}_knowledge.json 格式有效"

      # schema_version 检查
      VERSION=$(python3 -c "import json; d=json.load(open('${KNOWLEDGE_FILE}')); print(d.get('schema_version',''))" 2>/dev/null)
      if [[ "${VERSION}" == "2.1" ]]; then
        success "${p}_knowledge.json schema_version=2.1"
      else
        warn "${p}_knowledge.json schema_version 不是 2.1 (实际: ${VERSION})"
      fi

      # 实体数量（技术视角为分类结构，其余为扁平数组）
      if [[ "${p}" == "technical" ]]; then
        COUNT=$(python3 -c "
import json
d=json.load(open('${KNOWLEDGE_FILE}'))
ents=d.get('entities',{})
total=0
for k in ['systems','applications','services','apis']:
    total+=len(ents.get(k,[]))
print(total)
" 2>/dev/null)
      else
        COUNT=$(python3 -c "import json; d=json.load(open('${KNOWLEDGE_FILE}')); print(len(d.get('entities',[])))" 2>/dev/null)
      fi
      info "${p}_knowledge.json 包含 ${COUNT} 个实体"

      # 证据链非空检查
      if [[ "${p}" == "technical" ]]; then
        EMPTY_EVIDENCE=$(python3 -c "
import json
d=json.load(open('${KNOWLEDGE_FILE}'))
ents=d.get('entities',{})
count=0
for k in ['systems','applications','services','apis']:
    count+=sum(1 for e in ents.get(k,[]) if not e.get('evidence_chain'))
print(count)
" 2>/dev/null)
      else
        EMPTY_EVIDENCE=$(python3 -c "
import json
d=json.load(open('${KNOWLEDGE_FILE}'))
count=sum(1 for e in d.get('entities',[]) if not e.get('evidence_chain'))
print(count)
" 2>/dev/null)
      fi
      if [[ "${EMPTY_EVIDENCE}" -gt 0 ]]; then
        warn "${p}_knowledge.json 有 ${EMPTY_EVIDENCE} 个实体缺少证据链"
      fi

      # metadata 节检查
      HAS_META=$(python3 -c "import json; d=json.load(open('${KNOWLEDGE_FILE}')); print('yes' if 'metadata' in d else 'no')" 2>/dev/null)
      if [[ "${HAS_META}" == "yes" ]]; then
        success "${p}_knowledge.json 包含 metadata 节"
      else
        warn "${p}_knowledge.json 缺少 metadata 节"
      fi
    else
      error "${p}_knowledge.json JSON 格式无效"
    fi
  else
    info "${p}_knowledge.json 未找到（可选）"
  fi
done

info "发现 ${KNOWLEDGE_COUNT}/4 个 knowledge JSON 文件"

# 3. ID 前缀验证
declare -A PREFIX_MAP=(
  ["technical"]="SYS APP MS API"
  ["data"]="DS ENT"
  ["business"]="BD BSD BC AGG AB"
  ["product"]="PL PM FT UC"
)

for p in "${PERSPECTIVES[@]}"; do
  KNOWLEDGE_FILE="${KNOWLEDGE_DIR}/${p}/${p}_knowledge.json"
  [[ ! -f "${KNOWLEDGE_FILE}" ]] && continue

  ALLOWED="${PREFIX_MAP[$p]}"
  if [[ "${p}" == "technical" ]]; then
    INVALID=$(python3 -c "
import json
d=json.load(open('${KNOWLEDGE_FILE}'))
ents=d.get('entities',{})
allowed='${ALLOWED}'.split()
invalid=0
for k in ['systems','applications','services','apis']:
    invalid+=sum(1 for e in ents.get(k,[]) if e.get('hierarchy') not in allowed)
print(invalid)
" 2>/dev/null)
  else
    INVALID=$(python3 -c "
import json
d=json.load(open('${KNOWLEDGE_FILE}'))
allowed='${ALLOWED}'.split()
invalid=[e['hierarchy'] for e in d.get('entities',[]) if e.get('hierarchy') not in allowed]
print(len(invalid))
" 2>/dev/null)
  fi

  if [[ "${INVALID}" -gt 0 ]]; then
    error "${p}_knowledge.json 包含 ${INVALID} 个非法前缀"
  else
    success "${p}_knowledge.json 前缀验证通过"
  fi
done

# 4. 唯一性检查（层级+ID）
if [[ ${KNOWLEDGE_COUNT} -gt 0 ]]; then
  DUPLICATES=$(python3 -c "
import json, os
seen=set()
dups=0
for p in ['technical','data','business','product']:
    f=os.path.join('${KNOWLEDGE_DIR}',p,f'{p}_knowledge.json')
    if not os.path.exists(f): continue
    d=json.load(open(f))
    entities=d.get('entities',[])
    if isinstance(entities, dict):
        all_ents=[]
        for k in ['systems','applications','services','apis']:
            all_ents.extend(entities.get(k,[]))
        entities=all_ents
    for e in entities:
        key=f\"{e.get('hierarchy','')}-{e.get('id','')}\"
        if key in seen: dups+=1
        seen.add(key)
print(dups)
" 2>/dev/null)

  if [[ "${DUPLICATES}" -gt 0 ]]; then
    error "发现 ${DUPLICATES} 个重复的 层级+ID 组合"
  else
    success "层级+ID 唯一性验证通过"
  fi
fi

# 5. 提取报告（可选）
for p in "${PERSPECTIVES[@]}"; do
  REPORT="${KNOWLEDGE_DIR}/${p}/extraction_report.md"
  if [[ -f "${REPORT}" ]]; then
    info "${p}/extraction_report.md 存在"
  fi
done

echo ""
echo "=== 验证结果 ==="
echo "错误: ${ERRORS}  警告: ${WARNINGS}"

if [[ ${ERRORS} -gt 0 ]]; then
  echo "验证失败，请修复以上错误。"
  exit 1
else
  echo "验证通过。"
  exit 0
fi
