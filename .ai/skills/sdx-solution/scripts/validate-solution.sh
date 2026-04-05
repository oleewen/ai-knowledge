#!/usr/bin/env bash
set -euo pipefail

# 解决方案文档结构校验脚本
# 用法: scripts/validate-solution.sh [--doc-root <path>] [--file <path>]
# 默认 --doc-root 为 system，与 SKILL 约定路径 system/solutions/SOLUTION-*.md 一致；旧布局可传 --doc-root docs
#
# 校验项:
#   1. 模板文件存在
#   2. 文档目录存在
#   3. 文末「文档元数据」YAML 完整性（id、title、version、status、created、updated）；禁止文件头 ---
#   4. id 格式符合 SOLUTION-{IDEA-ID}
#   5. 九章结构完整性
#   6. 空章节检测（无内容且未标注「不适用」或「待补充」）
#   7. 编号体系一致性（G-n、Q-n、C-n、R-n）
#   8. 技术语言检测（接口名、表名等技术词混入正文）

DOC_ROOT="system"
TARGET_FILE=""
ERRORS=0
WARNINGS=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --doc-root) DOC_ROOT="$2"; shift 2 ;;
    --file) TARGET_FILE="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

SOLUTIONS_DIR="${DOC_ROOT}/solutions"
TEMPLATE=".ai/skills/sdx-solution/assets/solution-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== 解决方案文档结构校验 ==="
echo "Doc Root: ${DOC_ROOT}"
echo ""

# 0. 模板文件
if [[ -f "${TEMPLATE}" ]]; then
  success "solution-template.md 存在"
else
  warn "solution-template.md 不存在: ${TEMPLATE}"
fi

# 1. 文档目录
if [[ -d "${SOLUTIONS_DIR}" ]]; then
  FILE_COUNT=$(find "${SOLUTIONS_DIR}" -name "SOLUTION-*.md" 2>/dev/null | wc -l | tr -d ' ')
  success "solutions/ 目录存在 (${FILE_COUNT} 个解决方案文档)"
else
  warn "solutions/ 目录不存在: ${SOLUTIONS_DIR}"
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
  done < <(find "${SOLUTIONS_DIR}" -name "SOLUTION-*.md" -print0 2>/dev/null)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  info "未找到解决方案文档"
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
  if head -5 "${file}" | grep -q "^---"; then
    warn "${BASENAME}: 文件开头存在 ---（应移除）；元数据须仅在文末「## 文档元数据」的 yaml 代码块中"
  fi

  if grep -qF "## 文档元数据" "${file}"; then
    success "${BASENAME}: 「文档元数据」章节存在"
    for field in "id:" "title:" "version:" "status:" "created:" "updated:"; do
      if grep -q "${field}" "${file}"; then
        success "${BASENAME}: ${field} 字段存在"
      else
        warn "${BASENAME}: 缺少 ${field} 字段"
      fi
    done

    ID_LINE=$(grep "id:" "${file}" 2>/dev/null | head -1 || true)
    if [[ -n "${ID_LINE}" ]]; then
      if echo "${ID_LINE}" | grep -qE 'SOLUTION-[0-9]{6}-'; then
        success "${BASENAME}: id 含 SOLUTION- 前缀与日期段"
      else
        warn "${BASENAME}: id 建议符合 SOLUTION-{IDEA-ID}，实际: ${ID_LINE}"
      fi
    fi

    STATUS_LINE=$(grep "status:" "${file}" 2>/dev/null | head -1 || true)
    if echo "${STATUS_LINE}" | grep -q "draft\|review\|approved"; then
      success "${BASENAME}: status 值有效"
    else
      warn "${BASENAME}: status 值异常: ${STATUS_LINE}"
    fi
  else
    warn "${BASENAME}: 缺少「## 文档元数据」章节（须在文末放置 YAML 元数据）"
  fi

  # 3. 九章结构检查
  REQUIRED_SECTIONS=(
    "## 1. 业务背景"
    "## 2. 业务目标"
    "## 3. 需求概述"
    "## 4. 影响面评估"
    "## 5. 冲突分析"
    "## 6. 解决方案"
    "## 7. 可行性评估"
    "## 8. MVP拆分建议"
    "## 9. 附录"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/9 个必需章节"

  # 4. 空章节检测（有章节标题但无实质内容，且未标注「不适用」或「待补充」）
  EMPTY_SECTION_COUNT=0
  TOTAL_LINES=$(wc -l < "${file}" | tr -d ' ')

  # 收集所有 ## 章节的行号，末尾追加一个哨兵行号（文件总行数+1）
  SECTION_LINES=()
  SECTION_NAMES=()
  LINE_NUM=0
  while IFS= read -r line; do
    LINE_NUM=$((LINE_NUM + 1))
    if [[ "${line}" =~ ^##\  ]]; then
      SECTION_LINES+=("${LINE_NUM}")
      SECTION_NAMES+=("${line}")
    fi
  done < "${file}"

  # 检查每个章节（包括最后一个）
  for i in "${!SECTION_LINES[@]}"; do
    START=${SECTION_LINES[$i]}
    if [[ $((i + 1)) -lt ${#SECTION_LINES[@]} ]]; then
      END=$((SECTION_LINES[$((i + 1))] - 1))
    else
      END=${TOTAL_LINES}
    fi
    SECTION_CONTENT=$(sed -n "$((START + 1)),${END}p" "${file}" 2>/dev/null || true)
    REAL_CONTENT=$(echo "${SECTION_CONTENT}" | grep -v "^[[:space:]]*$" | grep -v "^<!--" | grep -v "^-->" || true)
    if [[ -z "${REAL_CONTENT}" ]]; then
      warn "${BASENAME}: 章节 '${SECTION_NAMES[$i]}' 无内容且未标注「不适用」或「待补充」"
      EMPTY_SECTION_COUNT=$((EMPTY_SECTION_COUNT + 1))
    fi
  done

  if [[ ${EMPTY_SECTION_COUNT} -eq 0 ]]; then
    success "${BASENAME}: 无空章节"
  fi

  # 5. 编号体系检查
  G_COUNT=$(grep -c 'G-[0-9]' "${file}" 2>/dev/null || true)
  Q_COUNT=$(grep -c 'Q-[0-9]' "${file}" 2>/dev/null || true)
  C_COUNT=$(grep -c 'C-[0-9T]' "${file}" 2>/dev/null || true)
  R_COUNT=$(grep -c 'R-[0-9]' "${file}" 2>/dev/null || true)

  info "${BASENAME}: G-n=${G_COUNT} Q-n=${Q_COUNT} C-n=${C_COUNT} R-n=${R_COUNT}"

  if [[ ${G_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现业务目标编号 (G-n)"
  fi

  # 6. 技术语言检测（常见技术词混入正文）
  # 排除 §9.3 内部参考章节后检测
  TECH_TERMS=("Spring Boot" "Kafka" "Redis" "TiDB" "MySQL" "Dubbo" "RPC" "MQ" "MyBatis" "Docker" "Kubernetes")
  TECH_WARN=0
  for term in "${TECH_TERMS[@]}"; do
    # 简单检测：在正文中出现（排除注释行）
    MATCH_COUNT=$(grep -v "^<!--" "${file}" | grep -c "${term}" 2>/dev/null || true)
    if [[ ${MATCH_COUNT} -gt 0 ]]; then
      warn "${BASENAME}: 正文中发现技术词「${term}」(${MATCH_COUNT} 处)，请确认是否已放入 §9.3 内部参考"
      TECH_WARN=$((TECH_WARN + 1))
    fi
  done
  if [[ ${TECH_WARN} -eq 0 ]]; then
    success "${BASENAME}: 未发现明显技术语言"
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
