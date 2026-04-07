#!/usr/bin/env bash
set -euo pipefail

# 解决方案文档结构校验脚本
# 用法: scripts/validate-solution.sh [--doc-root <path>] [--file <path>]
# doc_root 解析顺序（方案 A）：--doc-root > SDX_DOC_ROOT > .sdx-doc-root > 目录探测 > system
# 详见 .agent/scripts/sdx-doc-root.sh
#
# 校验项:
#   1. 模板文件存在
#   2. 文档目录存在
#   3. 文末「文档元数据」YAML 完整性（与 solution-template 一致）；禁止文件头 YAML frontmatter（首行 ---）
#   4. id 格式符合 SOLUTION-{IDEA-ID}
#   5. 七章 ## 结构完整性
#   6. 模板小节（### / ####）标题完整性
#   7. 空章节检测（无内容且未标注「不适用」或「待补充」）
#   8. 编号体系一致性（G-n、Q-n、C-n、R-n）
#   9. 技术语言检测（接口名、表名等技术词混入正文）

DOC_ROOT_ARG=""
TARGET_FILE=""
ERRORS=0
WARNINGS=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --doc-root) DOC_ROOT_ARG="$2"; shift 2 ;;
    --file) TARGET_FILE="$2"; shift 2 ;;
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

SOLUTIONS_DIR="${DOC_ROOT}/solutions"
TEMPLATE=".agent/skills/sdx-solution/assets/solution-template.md"

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

  # 2. 文档元数据（文末 YAML）；禁止首行 --- 作为 frontmatter（模板内分隔线通常在第 3 行及以后）
  FIRST_LINE=$(head -1 "${file}" 2>/dev/null || true)
  if [[ "${FIRST_LINE}" == "---" ]]; then
    warn "${BASENAME}: 首行为 ---（疑似 YAML frontmatter，应移除）；元数据须仅在文末「## 文档元数据」的 yaml 代码块中"
  fi

  if grep -qF "## 文档元数据" "${file}"; then
    success "${BASENAME}: 「文档元数据」章节存在"
    for field in "id:" "title:" "version:" "status:" "created:" "updated:" "author:" "parent:" "dependencies:" "tags:"; do
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

  # 3. 七章结构检查（与当前 solution-template.md 一致）
  REQUIRED_SECTIONS=(
    "## 1. 背景与目标"
    "## 2. 范围与约束"
    "## 3. 影响与冲突"
    "## 4. 思路与方案"
    "## 5. 风险与待定"
    "## 6. 交付计划"
    "## 7. 附录"
  )

  SECTION_COUNT=0
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qF "${section}" "${file}"; then
      SECTION_COUNT=$((SECTION_COUNT + 1))
    else
      warn "${BASENAME}: 缺少章节 '${section}'"
    fi
  done
  info "${BASENAME}: ${SECTION_COUNT}/7 个必需章节"

  # 3b. 模板小节标题（与 assets/solution-template.md 对齐）
  REQUIRED_SUBHEADINGS=(
    "### 1.1 业务现状"
    "### 1.2 存在问题"
    "### 1.3 业务目标"
    "### 1.4 业务价值"
    "### 2.1 核心场景"
    "### 2.2 涉及角色"
    "### 2.3 范围边界"
    "#### 范围内（In Scope）"
    "#### 范围外（Out of Scope）"
    "#### 成功标准"
    "### 2.4 关键约束"
    "#### 业务约束"
    "#### 资源约束"
    "#### 技术约束"
    "#### 交付约束"
    "### 3.1 影响面"
    "### 3.2 影响业务能力"
    "### 3.3 影响传播路径"
    "### 3.4 业务冲突"
    "### 4.1 解决思路"
    "### 4.2 方案对比（如有多种方案）"
    "### 4.3 关键决策"
    "### 5.1 风险评估"
    "### 5.2 待澄清问题"
    "### 6.1 MVP 拆分"
    "### 6.2 关键里程碑"
    "### 7.1 术语表"
    "### 7.2 参考文档"
    "### 7.3 内部参考（仅供研发接力）"
    "### 7.4 质量自查表 (Self-Check)"
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

  # 4. 空章节检测（有章节标题但无实质内容，且未标注「不适用」或「待补充」）
  EMPTY_SECTION_COUNT=0
  TOTAL_LINES=$(wc -l < "${file}" | tr -d ' ')

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
  C_COUNT=$(grep -c 'C-[0-9]' "${file}" 2>/dev/null || true)
  R_COUNT=$(grep -c 'R-[0-9]' "${file}" 2>/dev/null || true)

  info "${BASENAME}: G-n=${G_COUNT} Q-n=${Q_COUNT} C-n=${C_COUNT} R-n=${R_COUNT}"

  if [[ ${G_COUNT} -eq 0 ]]; then
    warn "${BASENAME}: 未发现业务目标编号 (G-n)"
  fi

  # 6. 技术语言检测（常见技术词混入正文）
  TECH_TERMS=("Spring Boot" "Kafka" "Redis" "TiDB" "MySQL" "Dubbo" "RPC" "MQ" "MyBatis" "Docker" "Kubernetes")
  TECH_WARN=0
  for term in "${TECH_TERMS[@]}"; do
    MATCH_COUNT=$(grep -v "^<!--" "${file}" | grep -c "${term}" 2>/dev/null || true)
    if [[ ${MATCH_COUNT} -gt 0 ]]; then
      warn "${BASENAME}: 正文中发现技术词「${term}」(${MATCH_COUNT} 处)，请确认是否已放入 §7.3 内部参考"
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
