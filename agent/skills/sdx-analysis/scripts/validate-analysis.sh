#!/usr/bin/env bash
set -euo pipefail

# 只读结构检查；默认警告不阻断，--strict 将警告视为失败。
# frontmatter 只检查模板字段与标量，不承担完整 YAML 解析或语义审批。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATE="$SCRIPT_DIR/../assets/analysis-template.md"
TARGET_FILE=''
STRICT=0
ERRORS=0
WARNINGS=0

usage() {
  cat <<'HELP'
用法: validate-analysis.sh [--file <path>] [--strict]
  --file <path>  只检查指定文件；相对路径以调用目录为准
  --strict       任一警告或没有文档时退出 1
  -h, --help     显示帮助；无需 .docsconfig
退出码: 0 成功（默认允许警告），1 校验失败，2 参数错误。
HELP
}
cli_error() { printf '[ERROR] %s\n' "$1" >&2; exit 2; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || cli_error '缺少 --file 路径'
      [[ -z "$TARGET_FILE" ]] || cli_error '--file 只能指定一次'
      TARGET_FILE="$2"; shift 2 ;;
    --strict) STRICT=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) cli_error "未知参数: $1" ;;
  esac
done
[[ -z "$TARGET_FILE" || "$TARGET_FILE" == /* ]] || TARGET_FILE="$PWD/$TARGET_FILE"

# shellcheck source=../../../scripts/lib/docsconfig.sh
source "$AGENT_HOME/scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate
if [[ "$KNOWLEDGE_TYPE" != system && "$KNOWLEDGE_TYPE" != application ]]; then
  printf '[ERROR] /sdx-analysis 仅允许 KNOWLEDGE_TYPE=system|application；当前=%s\n' "${KNOWLEDGE_TYPE:-unset}"
  exit 1
fi
DOC_ABS="$(docsconfig_doc_abs)"
warn() { printf '[WARN]  %s\n' "$1"; WARNINGS=$((WARNINGS + 1)); }
error() { printf '[ERROR] %s\n' "$1"; ERRORS=$((ERRORS + 1)); }
summary() {
  printf '\n=== 校验结果 ===\n错误: %s  警告: %s\n' "$ERRORS" "$WARNINGS"
  if (( ERRORS > 0 || (STRICT && WARNINGS > 0) )); then
    printf '校验失败，请处理以上问题。\n'
    return 1
  fi
  if (( WARNINGS > 0 )); then
    printf '检查完成，存在待处理警告；收尾请使用 --strict。\n'
  else
    printf '校验通过。\n'
  fi
}

printf '=== 需求分析文档结构校验 ===\ndoc_abs: %s\n\n' "$DOC_ABS"
[[ -r "$TEMPLATE" ]] || { error "模板不可读: $TEMPLATE"; summary; exit 1; }
FILES=()
if [[ -n "$TARGET_FILE" ]]; then
  [[ -f "$TARGET_FILE" && -r "$TARGET_FILE" ]] || { error "指定文件不存在或不可读: $TARGET_FILE"; summary; exit 1; }
  FILES=("$TARGET_FILE")
elif [[ -d "$DOC_ABS/analysis" ]]; then
  # 只遍历文件，使用 NUL 分隔，保留空格等合法路径字符。
  # 单独保留进程替换的 PID；只检查 read 循环会漏掉 find 的遍历错误。
  exec {SCAN_FD}< <(find "$DOC_ABS/analysis" -type f -name 'ANALYSIS-*.md' -print0)
  SCAN_PID=$!
  while IFS= read -r -d '' file; do FILES+=("$file"); done <&"$SCAN_FD"
  exec {SCAN_FD}<&-
  if ! wait "$SCAN_PID"; then error "目录扫描失败: $DOC_ABS/analysis"; fi
fi
if (( ${#FILES[@]} == 0 )); then
  printf '[INFO]  未找到需求分析文档: %s/analysis\n' "$DOC_ABS"
  (( STRICT == 0 )) || error '严格校验需要至少一个需求分析文档'
  summary
  exit $?
fi

for file in "${FILES[@]}"; do
  BASENAME="${file##*/}"
  printf '\n--- 校验: %s ---\n' "$BASENAME"
  # macOS awk 的字节切片可能截断 UTF-8 字符；只为此子进程固定字节语义。
  if ! REPORT="$(LC_ALL=C awk -v template="$TEMPLATE" -v name="$BASENAME" -f "$SCRIPT_DIR/validate-analysis.awk" "$file")"; then
    error "$BASENAME: 无法完成文档检查"
    continue
  fi
  ADR_IDS=()
  CONTEXT_TARGETS=()
  CONTEXT_LINK=0
  ADR_PENDING=0
  while IFS= read -r line; do
    case "$line" in
      $'ADR\t'*) ADR_IDS+=("${line#*$'\t'}") ;;
      $'CONTEXT\t'*) CONTEXT_TARGETS+=("${line#*$'\t'}") ;;
      $'PENDING\t'*) ADR_PENDING=1 ;;
      '[WARN]'*) WARNINGS=$((WARNINGS + 1)); printf '%s\n' "$line" ;;
      '[ERROR]'*) ERRORS=$((ERRORS + 1)); printf '%s\n' "$line" ;;
      *) [[ -z "$line" ]] || printf '%s\n' "$line" ;;
    esac
  done <<< "$REPORT"

  if (( ${#ADR_IDS[@]} > 0 || ADR_PENDING )); then
    CONTEXT_FILE="$DOC_ABS/adr/CONTEXT.md"
    for target in "${CONTEXT_TARGETS[@]}"; do
      target="${target%%#*}"
      target="${target//%20/ }"
      [[ "$target" == /* ]] || target="${file%/*}/$target"
      [[ "$target" -ef "$CONTEXT_FILE" ]] && CONTEXT_LINK=1
    done
    (( CONTEXT_LINK )) || warn "$BASENAME: 出现 ADR 引用/占位，但未有效链接本层 adr/CONTEXT.md"
    if [[ -f "$CONTEXT_FILE" && -r "$CONTEXT_FILE" ]]; then
      for adr_id in "${ADR_IDS[@]}"; do
        if ! LC_ALL=C awk -v mode=context -v adr_id="$adr_id" -f "$SCRIPT_DIR/validate-analysis.awk" "$CONTEXT_FILE"; then
          warn "$BASENAME: CONTEXT 未登记 $adr_id"
        fi
        ADR_FOUND=0
        for adr_file in "$DOC_ABS/adr/$adr_id-"*.md; do
          [[ -f "$adr_file" ]] && ADR_FOUND=1
        done
        (( ADR_FOUND )) || warn "$BASENAME: 未找到 $DOC_ABS/adr/$adr_id-*.md"
      done
    else
      warn "$BASENAME: 缺少或不可读 $CONTEXT_FILE"
    fi
    (( ADR_PENDING == 0 )) || warn "$BASENAME: 仍有 ADR-待定 占位，推进前须落盘"
  fi
done
summary
