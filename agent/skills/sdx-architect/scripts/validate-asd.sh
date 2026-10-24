#!/usr/bin/env bash
set -euo pipefail

# ASD 结构校验：frontmatter 边界、模板字段形状及同链、可见正文结构。
# 不解析完整 YAML，不判断设计内容质量，不承担写前或会话确认门禁。
TARGET_FILE=''
STRICT=0
ERRORS=0
WARNINGS=0

usage() {
  cat <<'HELP'
用法：validate-asd.sh [--strict] [--file <path>]
  --file <path>  校验单文件；相对路径以调用目录为准。省略时扫描 requirements/。
  --strict       有警告即失败；默认仅错误导致失败。
  --help         显示帮助，无需工程配置。
退出码：0 无错误（默认模式可能有警告）；1 校验失败；2 参数错误。
范围：frontmatter 边界、模板字段形状与同链、正文标题/编号/摘要/下游文件指针。
不提供完整 YAML 语法校验；非模板表达会提示人工核对。
HELP
}

argument_error() { printf '[ERROR] %s\n' "$1" >&2; exit 2; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || argument_error '--file 需要非空文件路径'
      [[ -z "$TARGET_FILE" ]] || argument_error '--file 不可重复指定'
      TARGET_FILE="$2"
      [[ "$TARGET_FILE" == /* ]] || TARGET_FILE="$PWD/$TARGET_FILE"
      shift 2
      ;;
    --strict) STRICT=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) argument_error "未知参数: $1" ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck source=../../../scripts/lib/docsconfig.sh
source "$_AGENT_HOME/scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate
DOC_ABS="$(docsconfig_doc_abs)"
REQUIREMENTS_DIR="${DOC_ABS}/requirements"

info()    { printf '[INFO]  %s\n' "$1"; }
warn()    { printf '[WARN]  %s\n' "$1"; WARNINGS=$((WARNINGS + 1)); }
error()   { printf '[ERROR] %s\n' "$1"; ERRORS=$((ERRORS + 1)); }
success() { printf '[OK]    %s\n' "$1"; }

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

# 只读取模板支持的单行标量。复杂 YAML 表达留给人工/专用解析器。
read_scalar() {
  local raw double_quoted='^"(([^"\\]|\\.)*)"[[:space:]]*(#.*)?$' single_quoted="^'(([^']|'')*)'[[:space:]]*(#.*)?$"
  raw="$(trim "$1")"
  SCALAR_VALUE=''
  if [[ "$raw" == \"* ]]; then
    [[ "$raw" =~ $double_quoted ]] || return 1
    SCALAR_VALUE="${BASH_REMATCH[1]}"
  elif [[ "$raw" == \'* ]]; then
    [[ "$raw" =~ $single_quoted ]] || return 1
    SCALAR_VALUE="${BASH_REMATCH[1]}"
  else
    raw="${raw%%[[:space:]]#*}"
    [[ "$raw" == \#* ]] && raw=''
    raw="$(trim "$raw")"
    case "$raw" in
      \[*|\{*|\&*|\**|\!*|\|*|\>*) return 1 ;;
      null|Null|NULL|'~') raw='' ;;
    esac
    SCALAR_VALUE="$raw"
  fi
  SCALAR_VALUE="$(trim "$SCALAR_VALUE")"
}

validate_metadata() {
  local basename="$1" frontmatter="$2" line current='' field raw block expected_parent phase
  local -A fields=() blocks=() counts=() values=()
  while IFS= read -r line; do
    if [[ "$line" =~ ^([a-z_]+):([[:space:]].*|$) ]]; then
      current="${BASH_REMATCH[1]}"
      fields["$current"]="${BASH_REMATCH[2]}"
      counts["$current"]=$(( ${counts[$current]:-0} + 1 ))
      blocks["$current"]=''
    elif [[ -n "$current" && ( "$line" =~ ^[[:space:]] || "$line" =~ ^-[[:space:]] ) ]]; then
      blocks["$current"]+="$line"$'\n'
    elif [[ -n "$line" && "$line" != \#* ]]; then
      current=''
    fi
  done <<< "$frontmatter"

  for field in id title version status created updated author reviewers parent mvp_phase; do
    if [[ ${counts[$field]:-0} -eq 0 ]]; then
      warn "${basename}: 缺少 ${field} 字段"
      continue
    fi
    [[ ${counts[$field]} -eq 1 ]] || warn "${basename}: ${field} 重复，需人工核对"
    raw="$(trim "${fields[$field]}")"
    block="${blocks[$field]}"
    if [[ "$field" == reviewers ]]; then
      # 保留模板 []、常见行内列表与多行序列，不把 YAML 序列当空标量。
      if [[ "$raw" =~ ^\[.*\][[:space:]]*(#.*)?$ ]]; then
        continue
      elif [[ ( -z "$raw" || "$raw" == \#* ) ]] && grep -Eq '^[[:space:]]*-[[:space:]]+[^[:space:]#]' <<< "$block"; then
        continue
      fi
    elif [[ "$field" != id && "$field" != parent && "$field" != mvp_phase && "$raw" =~ ^[\|\>][-+0-9]*$ && -n "$(trim "$block")" ]]; then
      continue
    fi
    if ! read_scalar "$raw"; then
      warn "${basename}: ${field} 使用非模板单行标量，需人工核对"
    elif [[ -z "$SCALAR_VALUE" ]]; then
      warn "${basename}: ${field} 为空"
    elif [[ "$field" == reviewers ]]; then
      warn "${basename}: reviewers 应为列表，需人工核对"
    else
      values["$field"]="$SCALAR_VALUE"
    fi
  done

  if [[ -n "${values[id]:-}" && "${values[id]}" != "${basename%.md}" ]]; then
    warn "${basename}: id 与文件名不一致，期望 ${basename%.md}，实际 ${values[id]}"
  fi
  if [[ "$basename" =~ ^ASD-(.+)-([0-9]+)\.md$ ]]; then
    expected_parent="PRD-${BASH_REMATCH[1]}-${BASH_REMATCH[2]}"
    phase="MVP-Phase-${BASH_REMATCH[2]}"
    if [[ -n "${values[parent]:-}" && "${values[parent]}" != "$expected_parent" ]]; then
      warn "${basename}: parent 应为 ${expected_parent}，实际 ${values[parent]}"
    fi
    if [[ -n "${values[mvp_phase]:-}" && "${values[mvp_phase]}" != "$phase" ]]; then
      warn "${basename}: mvp_phase 应为 ${phase}，实际 ${values[mvp_phase]}"
    fi
  else
    warn "${basename}: 文件名应为 ASD-{IDEA-ID}-{N}.md，N 为数字"
  fi
}

# 排除围栏代码、缩进代码与 HTML 注释；仅规范化 ATX 标题的空格和结尾 #。
visible_markdown() {
  awk '
    # 同一行已闭合的反引号代码跨度内，<!-- 是代码文本。
    function comment_start(text, i, j, width, run, close_at) {
      for (i=1; i<=length(text);) {
        if (substr(text,i,4)=="<!--") return i
        if (substr(text,i,1)!="`") { i++; continue }
        width=1
        while (substr(text,i+width,1)=="`") width++
        close_at=0
        for (j=i+width; j<=length(text);) {
          if (substr(text,j,1)!="`") { j++; continue }
          run=1
          while (substr(text,j+run,1)=="`") run++
          if (run==width) { close_at=j+run; break }
          j+=run
        }
        i=close_at ? close_at : i+width
      }
      return 0
    }
    {
      line=$0
      heading_eligible=(!comment && line ~ /^ {0,3}#{1,6}[ \t]/)
      if (fence != "") {
        candidate=line; sub(/^ {0,3}/, "", candidate)
        run=candidate; sub(fence=="`" ? "[^`].*$" : "[^~].*$", "", run)
        rest=substr(candidate,length(run)+1)
        if (substr(run,1,1)==fence && length(run)>=width && rest ~ /^[ \t]*$/) fence=""
        print ""; next
      }
      # 已处于 HTML 注释时仍须先找 -->；其他代码应在注释识别前排除。
      if (!comment) {
        if (line ~ /^(    |\t)/) { print ""; next }
        candidate=line; sub(/^ {0,3}/,"",candidate)
        if (candidate ~ /^(`{3,}|~{3,})/) {
          marker=substr(candidate,1,1)
          run=candidate; sub(marker=="`" ? "[^`].*$" : "[^~].*$", "", run)
          # 反引号围栏的信息串不能含反引号；行首代码跨度仍按正文处理。
          if (marker=="~" || index(substr(candidate,length(run)+1),"`")==0) {
            fence=marker; width=length(run); print ""; next
          }
        }
      }
      visible=""
      while (length(line)) {
        if (comment) {
          end=index(line,"-->")
          if (!end) { line=""; break }
          line=substr(line,end+3); comment=0
        } else {
          start=comment_start(line)
          if (!start) { visible=visible line; break }
          visible=visible substr(line,1,start-1); line=substr(line,start+4); comment=1
        }
      }
      line=visible
      if (line ~ /^(    |\t)/) { print ""; next }
      sub(/^ {0,3}/,"",line)
      if (line ~ /^#{1,6}[ \t]/) {
        # 剥注释只清理内容，不把原本的 HTML/正文行升级成 ATX 标题。
        if (!heading_eligible) { print "\\" line; next }
        match(line,/^#+/); hashes=substr(line,1,RLENGTH)
        line=substr(line,RLENGTH+1); sub(/^[ \t]+/,"",line)
        sub(/[ \t]+#+[ \t]*$/,"",line); sub(/[ \t]+$/,"",line)
        line=hashes " " line
      }
      print line
    }'
}

has_summary_row() {
  awk '
    $0=="### 3.1 需求规约摘要" { active=1; next }
    active && /^#{1,3}[ \t]/ { active=0 }
    active {
      if ($0 ~ /\|/) {
        # GFM 表格的左右外管道可省略；保留表头、分隔行、数据行顺序。
        if ($0 ~ /^[-:| \t]+$/ && $0 ~ /-/) {
          if (header) separator=1
        } else {
          content=$0; gsub(/[| \t]/,"",content)
          if (separator && length(content)) found=1
          header=1
        }
      } else { header=0; separator=0 }
    }
    END { exit !found }'
}

validate_file() {
  local file="$1" basename document end=0 i frontmatter body heading
  local -a lines=()
  basename="$(basename "$file")"
  printf '\n--- 校验: %s ---\n' "$basename"
  if [[ -L "$file" && ! -e "$file" ]]; then
    error "${basename}: 失效文件软链（目标不存在或不可访问）: ${file}"
    return
  fi
  if [[ ! -f "$file" || ! -r "$file" ]] || ! document="$(awk '{ sub(/\r$/, ""); print }' "$file")"; then
    error "${basename}: 无法读取文件: ${file}"
    return
  fi
  mapfile -t lines <<< "$document"
  if [[ ! "${lines[0]}" =~ ^---[[:space:]]*$ ]]; then
    error "${basename}: 缺少文首 frontmatter（首行应为 ---）"
    return
  fi
  for ((i=1; i<${#lines[@]}; i++)); do
    if [[ "${lines[$i]}" =~ ^---[[:space:]]*$ ]]; then end=$i; break; fi
  done
  if [[ "$end" -eq 0 ]]; then
    error "${basename}: frontmatter 未闭合（缺少第二个 ---）"
    return
  fi
  frontmatter="$(printf '%s\n' "${lines[@]:1:end-1}")"
  validate_metadata "$basename" "$frontmatter"
  body="$(printf '%s\n' "${lines[@]:end+1}" | visible_markdown)"
  for heading in '## 1. 设计概述' '## 2. 架构设计' '## 3. 需求规约'; do
    grep -Fqx -- "$heading" <<< "$body" || warn "${basename}: 缺少章节 '${heading}'"
  done
  for heading in '### 1.1 设计目标' '### 1.2 设计约束' '### 1.3 关键设计决策' '### 2.1 系统架构设计' '### 3.1 需求规约摘要'; do
    grep -Fqx -- "$heading" <<< "$body" || warn "${basename}: 缺少小节标题 '${heading}'"
  done
  if ! grep -Eq '(^|[^[:alnum:]_-])DD-[0-9]+([^[:alnum:]_-]|$)' <<< "$body"; then
    warn "${basename}: 未发现设计决策编号 (DD-n)"
  fi
  has_summary_row <<< "$body" || warn "${basename}: 规约摘要表缺少数据行（§3.1）"
  if [[ "${KNOWLEDGE_TYPE:-}" == system ]] && ! grep -Eq '(^|[^[:alnum:]_-])(DSD-|spec-asd-)[A-Za-z0-9._-]+\.md([^[:alnum:]_.-]|$)' <<< "$body"; then
    warn "${basename}: 未发现下游承接指针（DSD-*.md / spec-asd-*.md）"
  fi
  return 0
}

printf '=== ASD 结构校验 ===\ndoc_abs: %s\nKNOWLEDGE_TYPE: %s\n' "$DOC_ABS" "${KNOWLEDGE_TYPE:-application}"
case "${KNOWLEDGE_TYPE:-application}" in
  application|system|meta) ;;
  *) error "KNOWLEDGE_TYPE=${KNOWLEDGE_TYPE} 不支持 ASD；请在 application/system 库执行" ;;
esac
[[ -f "$SCRIPT_DIR/../assets/asd-template.md" ]] || warn 'asd-template.md 不存在'
FILES=()
if [[ "$ERRORS" -eq 0 ]]; then
  if [[ -n "$TARGET_FILE" ]]; then
    if [[ -f "$TARGET_FILE" || -L "$TARGET_FILE" ]]; then FILES=("$TARGET_FILE"); else error "指定文件不存在: ${TARGET_FILE}"; fi
  elif [[ ! -d "$REQUIREMENTS_DIR" ]]; then
    warn "requirements/ 目录不存在: ${REQUIREMENTS_DIR}"
  else
    # NUL 保留文件名空格/换行；wait 传播 find 读取失败，避免空扫描掩盖错误。
    mapfile -d '' -t FILES < <(find "$REQUIREMENTS_DIR" \( -type f -o -type l \) -name 'ASD-*.md' -print0)
    if ! wait "$!"; then error "无法完整扫描目录: ${REQUIREMENTS_DIR}"; fi
    [[ ${#FILES[@]} -gt 0 ]] || warn '未找到 ASD 文档'
  fi
fi
for file in "${FILES[@]}"; do validate_file "$file"; done

printf '\n=== 校验结果 ===\n错误: %s  警告: %s\n' "$ERRORS" "$WARNINGS"
if [[ "$ERRORS" -gt 0 || ( "$STRICT" -eq 1 && "$WARNINGS" -gt 0 ) ]]; then
  printf '校验失败，请处理以上错误或严格模式警告。\n'
  exit 1
elif [[ "$WARNINGS" -gt 0 ]]; then
  printf '结构检查完成，存在警告；处理后请用 --strict 复核。\n'
else
  success '校验通过（仅上述结构检查范围）。'
fi
