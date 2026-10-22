#!/usr/bin/env bash
set -euo pipefail

# SOLUTION 结构、正文与父链校验；只读，不承担写前门禁或业务事实核验。
usage() {
  cat <<'EOF'
用法: validate-solution.sh [--file <path>] [--help]

  --file <path>  仅检查该文件的正文；相对路径基于调用目录。
                 id / parent 仍校验当前 solutions/ 全集及指定文件。
  -h, --help     显示帮助，不读取工程配置。

依赖 Bash 5+、awk 和标准命令；工程须有有效 .docsconfig。
遍历可解析的目录/文件软链；断链、目录环报错。同一实体去重，所有别名须与 id 同名。
frontmatter 须以 --- 包围；id / parent 仅支持单行简单标量，
允许无引号、单引号、双引号及行尾注释，不支持转义、锚点或复杂 YAML。
空 parent、null、~ 表示首份；允许多个首份。
正文须有且仅有六个规定 H2，顺序固定；允许草稿段落为空。
HTML 注释和代码围栏不能充当标题；正文（含代码）禁 SYS / FR / MVP / 里程碑。
行内代码中的注释标记按字面检查；跨行反引号与注释标记存在歧义时报告错误。
块起点识别无标题、无转义的简单单行引用定义；跨行行内注释遇块边界时报歧义。
不核验 knowledge 事实。无文件仅警告并返回 0；校验或参数错误返回 1。
EOF
}

TARGET_FILE=""
SHOW_HELP=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      if [[ $# -lt 2 || -z "$2" || "$2" == -* ]]; then
        printf '[ERROR] --file 需要文件路径\n' >&2
        exit 1
      fi
      [[ -z "$TARGET_FILE" ]] || { printf '[ERROR] --file 不能重复\n' >&2; exit 1; }
      TARGET_FILE="$2"
      shift 2
      ;;
    -h|--help) SHOW_HELP=1; shift ;;
    *) printf '[ERROR] 未知参数: %s\n' "$1" >&2; exit 1 ;;
  esac
done
if [[ "$SHOW_HELP" -eq 1 ]]; then usage; exit 0; fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AGENT_HOME/scripts/lib/bash.sh"
# shellcheck disable=SC1091
source "$_AGENT_HOME/scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate

if [[ "${KNOWLEDGE_TYPE:-}" != "solution" && "${KNOWLEDGE_TYPE:-}" != "sln" ]]; then
  echo "[ERROR] /sdx-solution 仅允许 KNOWLEDGE_TYPE=solution（别名 sln）；当前=${KNOWLEDGE_TYPE:-unset}"
  exit 1
fi

doc_abs="$(docsconfig_doc_abs)"
SOLUTIONS_DIR="${doc_abs}/solutions"
TEMPLATE="${SCRIPT_DIR}/../assets/solution-template.md"
ERRORS=0
WARNINGS=0
declare -A FILE_ERRORS=() ID_FILE=() ID_PARENT=() SUCCESSOR=() ALIAS_REP=() FILE_ID=()
declare -a FILES=() BODY_FILES=()

warn() { printf '[WARN]  %s\n' "$1"; WARNINGS=$((WARNINGS + 1)); }
error() { printf '[ERROR] %s\n' "$1"; ERRORS=$((ERRORS + 1)); }
file_error() {
  FILE_ERRORS["$1"]=1
  error "${1##*/}: $2"
}
success() { printf '[OK]    %s\n' "$1"; }
add_file() {
  local candidate="$1" representative
  for representative in "${FILES[@]}"; do
    if [[ "$candidate" -ef "$representative" ]]; then
      ALIAS_REP["$candidate"]="$representative"
      return 0
    fi
  done
  FILES+=("$candidate")
  ALIAS_REP["$candidate"]="$candidate"
}
check_linked_directory() {
  local path="$1" ancestor
  [[ -L "$path" ]] || return 0
  ancestor="${path%/*}"
  while [[ -n "$ancestor" ]]; do
    if [[ "$path" -ef "$ancestor" ]]; then
      error "目录软链形成环: $path"
      return 1
    fi
    [[ "$ancestor" != / ]] || break
    ancestor="${ancestor%/*}"
    [[ -n "$ancestor" ]] || ancestor=/
  done
}

printf '=== 解决方案切分叙事校验 ===\ndoc_abs: %s\n' "$doc_abs"

if [[ -f "${TEMPLATE}" ]]; then
  success "solution-template.md 存在"
else
  warn "solution-template.md 不存在: ${TEMPLATE}"
fi

if [[ -n "${TARGET_FILE}" ]]; then
  if [[ ! -f "${TARGET_FILE}" ]]; then
    error "指定文件不存在: ${TARGET_FILE}"
    exit 1
  fi
  TARGET_FILE="$(abs_path "$TARGET_FILE")"
fi

if [[ -L "$SOLUTIONS_DIR" && ! -e "$SOLUTIONS_DIR" ]]; then
  error "无法解析 solutions/ 软链: $SOLUTIONS_DIR"
  exit 1
elif [[ -d "${SOLUTIONS_DIR}" ]]; then
  find_status=1
  while IFS= read -r -d '' f; do
    # 空记录是 find 状态哨兵，真实路径不可能为空。
    if [[ -z "$f" ]]; then
      IFS= read -r -d '' find_status
      break
    fi
    if [[ -L "$f" && ! -e "$f" ]]; then
      error "无法解析的软链: $f"
    elif [[ -d "$f" ]]; then
      # BSD find 可能对目录环静默剪枝并返回 0，另验软链与祖先身份。
      check_linked_directory "$f" || exit 1
    else
      add_file "$f"
    fi
  done < <(status=0; find -L "$SOLUTIONS_DIR" \( -type f -name 'SOLUTION-*.md' -o -type l -o -type d \) -print0 || status=$?; printf '\0%d\0' "$status")
  if [[ "$find_status" -ne 0 ]]; then error '无法完整扫描 solutions/'; exit 1; fi
else
  warn "solutions/ 目录不存在: ${SOLUTIONS_DIR}"
fi

if [[ -n "$TARGET_FILE" ]]; then
  add_file "$TARGET_FILE"
fi
if [[ "${#FILES[@]}" -eq 0 && -d "$SOLUTIONS_DIR" ]]; then warn '未找到 SOLUTION-*.md'; fi

# 只解析模板中 id / parent 的简单单行标量，不充当通用 YAML 解析器。
parse_document() {
  awk -v check_body="$2" -v expected_id="${1##*/}" '
    function fail(message) { print "E\t" message }
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function scalar(raw, key,    q, rest, end) {
      raw = trim(raw)
      q = substr(raw, 1, 1)
      if (q == "\042" || q == "\047") {
        rest = substr(raw, 2)
        end = index(rest, q)
        if (!end || substr(rest, end + 1) !~ /^([ \t]+#.*|[ \t]*)$/) {
          fail(key " 不是受支持的单行标量"); return ""
        }
        raw = substr(rest, 1, end - 1)
      } else {
        sub(/[ \t]+#.*/, "", raw)
        if (raw ~ /^#/) raw = ""
        raw = trim(raw)
        if (raw == "null" || raw == "~") raw = ""
      }
      if (raw == "" && key == "parent") return ""
      if (raw !~ /^SOLUTION-[^[:space:]\/]+$/ || raw ~ /[\042\047\\$`]/) {
        fail(key " 须为 SOLUTION ID；不支持复杂 YAML 或转义"); return ""
      }
      return raw
    }
    function ticks(s, pos,    n) {
      n = 0
      while (substr(s, pos + n, 1) == "`") n++
      return n
    }
    function code_end(s, n,    p, run) {
      p = n + 1
      while (p <= length(s)) {
        if (substr(s, p, 1) != "`") { p++; continue }
        run = ticks(s, p)
        if (run == n) return p + run - 1
        p += run
      }
      return 0
    }
    function visible(s,    output, p, n) {
      output = ""
      while (length(s)) {
        if (comment) {
          p = index(s, "-->")
          if (!p) return output
          s = substr(s, p + 3); comment = 0
        } else if (pending_ticks) {
          # 未配对反引号本身合法；只拒绝可能是跨行代码的注释歧义。
          if (substr(s, 1, 4) == "<!--") {
            fail("反引号与 HTML 注释存在歧义；请将含注释标记的行内代码放在同一行")
            return output s
          }
          n = substr(s, 1, 1) == "`" ? ticks(s, 1) : 1
          if (substr(s, 1, 1) == "`" && n == pending_ticks) pending_ticks = 0
          output = output substr(s, 1, n); s = substr(s, n + 1)
        } else if (substr(s, 1, 1) == "\\") {
          output = output substr(s, 1, 2); s = substr(s, 3)
        } else if (substr(s, 1, 1) == "`") {
          n = ticks(s, 1)
          p = code_end(s, n)
          if (!p) { pending_ticks = n; p = n }
          output = output substr(s, 1, p); s = substr(s, p + 1)
        } else if (substr(s, 1, 4) == "<!--") {
          s = substr(s, 5); comment = 1
        } else {
          output = output substr(s, 1, 1); s = substr(s, 2)
        }
      }
      return output
    }
    function forbidden(s,    i, token) {
      for (i = 1; i <= 3; i++) {
        token = banned[i]
        if (!reported[token] && s ~ ("(^|[^A-Za-z])" token "([^A-Za-z]|$)")) {
          fail("正文出现 " token); reported[token] = 1
        }
      }
      if (!reported["里程碑"] && index(s, "里程碑")) {
        fail("正文出现 里程碑"); reported["里程碑"] = 1
      }
    }
    function thematic_break(s) {
      if (s !~ /^ {0,3}[-*_]/) return 0
      gsub(/[ \t]/, "", s)
      return s ~ /^---+$/ || s ~ /^\*\*\*+$/ || s ~ /^___+$/
    }
    function simple_reference(s,    label) {
      if (s !~ /^ {0,3}\[[^][]+\]:/) return 0
      label = s; sub(/\]:.*/, "", label)
      sub(/^ {0,3}\[/, "", label)
      if (label !~ /[^[:space:]]/ || index(label, "\\")) return 0
      sub(/^ {0,3}\[[^][]+\]:[ \t]*/, "", s)
      return s ~ /^[^[:space:]<>()\\]+[ \t]*$/ || s ~ /^<[^[:space:]<>\\]*>[ \t]*$/
    }
    function fence_opening(s,    marker, n) {
      if (s !~ /^ {0,3}(```+|~~~+)/) return 0
      sub(/^ {0,3}/, "", s)
      marker = substr(s, 1, 1); n = 0
      while (substr(s, n + 1, 1) == marker) n++
      return marker != "`" || !index(substr(s, n + 1), "`")
    }
    BEGIN {
      required[1] = "这次改了什么"; required[2] = "为什么这样切"
      required[3] = "范围内外"; required[4] = "流程怎么串"
      required[5] = "主数据主权"; required[6] = "技术例外"
      banned[1] = "SYS"; banned[2] = "FR"; banned[3] = "MVP"
      sub(/\.md$/, "", expected_id)
    }
    {
      sub(/\r$/, "")
      if (NR == 1) {
        if ($0 !~ /^---[ \t]*$/) { fail("缺少起始 frontmatter ---"); invalid = 1 }
        else frontmatter = 1
        next
      }
      if (invalid) next
      if (frontmatter) {
        if ($0 ~ /^---[ \t]*$/) { frontmatter = 0; closed = 1; next }
        if ($0 ~ /^[ \t]*(#.*)?$/) next
        if (identity_key && $0 ~ /^([ \t]+|[-?:]([ \t]|$))/) fail(identity_key " 不支持多行或嵌套值")
        identity_key = ""
        if ($0 ~ /^(\042(id|parent)\042|\047(id|parent)\047)[ \t]*:/) fail("id / parent 键不支持引号")
        if ($0 ~ /^(id|parent)[ \t]*:/) {
          key = $0; sub(/[ \t]*:.*/, "", key)
          if ($0 !~ /^(id|parent)[ \t]*:([ \t]|$)/) fail(key " 冒号后须有分隔空白或为空")
          raw = $0; sub(/^[^:]*:/, "", raw)
          if (seen[key]++) fail("frontmatter 重复 " key)
          else values[key] = scalar(raw, key)
          identity_key = key
        }
        next
      }
      if (!check_body) next
      line = $0
      if (comment && !comment_block && !reported["comment-boundary"] &&
          (line ~ /^[ \t]*$/ || line ~ /^ {0,3}#{1,6}([ \t]+|$)/ || fence_opening(line) || thematic_break(line))) {
        fail("跨行行内 HTML 注释遇块边界，存在歧义；请拆为独立块注释")
        reported["comment-boundary"] = 1
      }
      if (fence) {
        forbidden(line)
        candidate = line; sub(/^ {0,3}/, "", candidate)
        marks = candidate; sub(/[^`~].*$/, "", marks)
        if (substr(marks, 1, 1) == fence && ((fence == "`" && marks !~ /~/) || (fence == "~" && marks !~ /`/)) && length(marks) >= fence_length && substr(candidate, length(marks) + 1) ~ /^[ \t]*$/) fence = ""
        paragraph = 0; setext_possible = 0
        next
      }
      if (!comment && line ~ /^[ \t]*$/) { paragraph = 0; setext_possible = 0; pending_ticks = 0; next }
      # 缩进代码不能打断普通段落；已打开的 HTML 注释仍按注释续行。
      if (!comment && !paragraph && line ~ /^( {4}| {0,3}\t)/) {
        forbidden(line)
        pending_ticks = 0; setext_possible = 0
        next
      }
      if (!comment && (!paragraph || paragraph == 2) && simple_reference(line)) {
        forbidden(line)
        # 仅含引用定义的段落仍允许缩进续行；普通正文出现后才可形成 Setext H2。
        paragraph = 2
        setext_possible = 0; pending_ticks = 0
        next
      }
      # 段落后的连续短横线优先是 Setext H2；模板只允许固定 ATX H2。
      if (!comment && paragraph && setext_possible && line ~ /^ {0,3}-+[ \t]*$/) {
        fail("出现非模板 Setext H2")
        paragraph = 0; setext_possible = 0; pending_ticks = 0
        next
      }
      if (!comment && thematic_break(line)) {
        paragraph = 0; setext_possible = 0; pending_ticks = 0
        next
      }
      # 标题和围栏须在原始行成立，删除注释不能拼出 Markdown 标记。
      source_heading = !comment && line ~ /^ {0,3}##([ \t]+|$)/
      source_block_heading = !comment && line ~ /^ {0,3}#{1,6}([ \t]+|$)/
      if (source_block_heading) pending_ticks = 0
      if (!comment && fence_opening(line)) {
        candidate = line; sub(/^ {0,3}/, "", candidate)
        marker = substr(candidate, 1, 1); marker_length = 0
        while (substr(candidate, marker_length + 1, 1) == marker) marker_length++
        pending_ticks = 0
        forbidden(line)
        fence = marker; fence_length = marker_length; paragraph = 0; setext_possible = 0
        next
      }
      # 行首块注释会结束段落；段落内注释跨行关闭则不结束原段落。
      block_comment_line = comment_block || (!comment && line ~ /^ {0,3}<!--/)
      if (block_comment_line) comment_block = 1
      line = visible(line)
      forbidden(line)
      if (source_heading && line ~ /^ {0,3}##([ \t]+|$)/) {
        heading = line; sub(/^ {0,3}##[ \t]*/, "", heading)
        sub(/[ \t]+#+[ \t]*$/, "", heading); heading = trim(heading)
        count++
        if (count > 6 || heading != required[count]) fail("H2 顺序或名称不符: " heading)
        headings[heading]++
      }
      if (source_block_heading || block_comment_line) {
        paragraph = 0; setext_possible = 0
      } else if (trim(line) != "") {
        if (!paragraph || paragraph == 2) setext_possible = 1
        # 列表和引用的惰性续行不能被当作顶层 Setext 标题文本。
        if ($0 ~ /^ {0,3}(>|[-+*][ \t]|[0-9]+[.)][ \t])/) setext_possible = 0
        paragraph = 1
      }
      if (!comment) comment_block = 0
    }
    END {
      if (!NR) fail("空文件，缺少 frontmatter")
      if (!invalid && !closed) fail("frontmatter 缺少结束 ---")
      if (!seen["id"]) fail("缺少 frontmatter id")
      if (!seen["parent"]) fail("缺少 frontmatter parent")
      if (values["id"] != "" && values["id"] != expected_id) fail("id 与文件名不一致")
      print "I\t" values["id"]; print "P\t" values["parent"]
      if (check_body) for (i = 1; i <= 6; i++) {
        if (headings[required[i]] != 1) fail("H2 须且仅出现一次: " required[i])
      }
    }
  ' "$1"
}

for file in "${FILES[@]}"; do
  check_body=0
  if [[ -z "$TARGET_FILE" || "$TARGET_FILE" -ef "$file" ]]; then
    check_body=1
    BODY_FILES+=("$file")
  fi
  if ! parsed="$(parse_document "$file" "$check_body")"; then
    file_error "$file" '无法读取或解析文件'
    continue
  fi
  id=''; parent=''
  while IFS=$'\t' read -r kind value; do
    case "$kind" in
      E) file_error "$file" "$value" ;;
      I) id="$value" ;;
      P) parent="$value" ;;
    esac
  done <<<"$parsed"
  FILE_ID["$file"]="$id"
  if [[ -n "$id" ]]; then
    if [[ -n "${ID_FILE[$id]-}" ]]; then
      file_error "$file" "重复 id: $id"
      FILE_ERRORS["${ID_FILE[$id]}"]=1
    else
      ID_FILE["$id"]="$file"
      ID_PARENT["$id"]="$parent"
    fi
  fi
done

for alias in "${!ALIAS_REP[@]}"; do
  representative="${ALIAS_REP[$alias]}"
  [[ "$alias" != "$representative" ]] || continue
  id="${FILE_ID[$representative]-}"
  alias_id="${alias##*/}"
  if [[ -n "$id" && "${alias_id%.md}" != "$id" ]]; then
    file_error "$alias" "软链别名与 id 不一致: $id"
    FILE_ERRORS["$representative"]=1
  fi
done

for id in "${!ID_FILE[@]}"; do
  parent="${ID_PARENT[$id]}"
  [[ -n "$parent" ]] || continue
  if [[ -z "${ID_FILE[$parent]-}" ]]; then
    file_error "${ID_FILE[$id]}" "parent 不存在: $parent"
  elif [[ "$id" == "$parent" ]]; then
    file_error "${ID_FILE[$id]}" 'parent 不能指向自身'
  fi
  if [[ -n "${SUCCESSOR[$parent]-}" ]]; then
    file_error "${ID_FILE[$id]}" "parent ${parent} 已有后继，不能再有第二份"
    FILE_ERRORS["${ID_FILE[${SUCCESSOR[$parent]}]}"]=1
  else
    SUCCESSOR["$parent"]="$id"
  fi
done

declare -A VISITED=()
for id in "${!ID_FILE[@]}"; do
  VISITED=()
  cursor="$id"
  while [[ -n "$cursor" && -n "${ID_FILE[$cursor]-}" ]]; do
    if [[ -n "${VISITED[$cursor]-}" ]]; then
      file_error "${ID_FILE[$id]}" "parent 链存在环: $cursor"
      break
    fi
    VISITED["$cursor"]=1
    cursor="${ID_PARENT[$cursor]}"
  done
done

for file in "${BODY_FILES[@]}"; do
  if [[ -z "${FILE_ERRORS[$file]-}" ]]; then success "${file##*/}: 六段与父链已检查"; fi
done
printf '错误: %d  警告: %d\n' "$ERRORS" "$WARNINGS"
[[ "$ERRORS" -eq 0 ]]
