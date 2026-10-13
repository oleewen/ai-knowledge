#!/usr/bin/env bash
set -euo pipefail

# SOLUTION 切分叙事校验（六段；不承担写前门禁）。
# 用法：validate-solution.sh [--file <path>]

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
source "$_AGENT_HOME/scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate

if [[ "${KNOWLEDGE_TYPE:-}" != "solution" && "${KNOWLEDGE_TYPE:-}" != "sln" ]]; then
  echo "[ERROR] /sdx-solution 仅允许 KNOWLEDGE_TYPE=solution（别名 sln）；当前=${KNOWLEDGE_TYPE:-unset}"
  exit 1
fi

doc_abs="$(docsconfig_doc_abs)"
repo_abs="$(docsconfig_repo_abs)"
cd "$repo_abs" || exit 1

SOLUTIONS_DIR="${doc_abs}/solutions"
TEMPLATE="${SCRIPT_DIR}/../assets/solution-template.md"

info()    { echo "[INFO]  $1"; }
warn()    { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
error()   { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
success() { echo "[OK]    $1"; }

echo "=== 解决方案切分叙事校验 ==="
echo "doc_abs: ${doc_abs}"

if [[ -f "${TEMPLATE}" ]]; then
  success "solution-template.md 存在"
else
  warn "solution-template.md 不存在: ${TEMPLATE}"
fi

FILES=()
if [[ -n "${TARGET_FILE}" ]]; then
  if [[ -f "${TARGET_FILE}" ]]; then
    FILES=("${TARGET_FILE}")
  else
    error "指定文件不存在: ${TARGET_FILE}"
    echo "错误: ${ERRORS}  警告: ${WARNINGS}"
    exit 1
  fi
elif [[ -d "${SOLUTIONS_DIR}" ]]; then
  while IFS= read -r -d '' f; do
    FILES+=("$f")
  done < <(find "${SOLUTIONS_DIR}" -name "SOLUTION-*.md" -print0 2>/dev/null)
else
  warn "solutions/ 目录不存在: ${SOLUTIONS_DIR}"
  echo "错误: ${ERRORS}  警告: ${WARNINGS}"
  exit 0
fi

REQUIRED=(
  "## 这次改了什么"
  "## 为什么这样切"
  "## 范围内外"
  "## 流程怎么串"
  "## 主数据主权"
  "## 技术例外"
)

declare -a IDS=()
declare -a PARENTS=()

for file in "${FILES[@]}"; do
  BASENAME="$(basename "${file}")"
  if ! grep -q '^parent:' "${file}"; then
    error "${BASENAME}: 缺少 frontmatter parent"
  fi
  for section in "${REQUIRED[@]}"; do
    if ! grep -qF "${section}" "${file}"; then
      error "${BASENAME}: 缺少 ${section}"
    fi
  done
  if grep -qE '(^|[^A-Za-z])SYS([^A-Za-z]|$)|SYS-[A-Za-z0-9]' "${file}"; then
    error "${BASENAME}: 正文出现 SYS"
  fi
  id_line="$(grep -E '^id:' "${file}" | head -1 || true)"
  parent_line="$(grep -E '^parent:' "${file}" | head -1 || true)"
  IDS+=("${id_line}")
  PARENTS+=("${parent_line}")
  success "${BASENAME}: 六段已检查"
done

# 同一 parent 不能有两个后继（空 parent 除外）
declare -A SEEN=()
for parent_line in "${PARENTS[@]}"; do
  value="$(echo "${parent_line}" | sed -E 's/^parent:[[:space:]]*//; s/^"//; s/"$//')"
  if [[ -z "${value}" || "${value}" == "null" || "${value}" == "~" ]]; then
    continue
  fi
  if [[ -n "${SEEN[${value}]+x}" ]]; then
    error "parent ${value} 已有后继，不能再有第二份"
  fi
  SEEN["${value}"]=1
done

echo "错误: ${ERRORS}  警告: ${WARNINGS}"
if [[ ${ERRORS} -gt 0 ]]; then
  exit 1
fi
exit 0
