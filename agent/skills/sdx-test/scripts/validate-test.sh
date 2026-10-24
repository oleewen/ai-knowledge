#!/usr/bin/env bash
set -euo pipefail

# TDD 模板子集的静态结构检查；不解析完整 YAML/Markdown、不验证语义追溯或会话授权。
# 必需元数据支持单行 plain/single/double-quoted scalar；reviewers 支持 []、单行列表或块列表。
# 仅从文首 frontmatter 取元数据；仅从非代码块、非 HTML 注释的 ATX 标题取章节。

usage() {
  cat <<'USAGE'
用法: validate-test.sh [--file <path>] | --help

  --file <path>  只校验该文件；相对调用目录解析，不读取 .docsconfig。
  无参数         只读加载当前工程 .docsconfig，扫描 DOC_DIR 整棵树内的 TDD-*.md。
  -h, --help    显示帮助。

退出码: 0=至少一个文件，且所有已校验文件结构通过；1=结构校验失败；
        2=参数/配置/执行/读取错误；
        3=skipped（未校验任何文件）。结构通过不代表用例执行或业务覆盖通过。
USAGE
}

argument_error() {
  printf '[ERROR] %s\n' "$*" >&2
  usage >&2
  exit 2
}

TARGET_FILE=''
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      [[ -z "$TARGET_FILE" ]] || argument_error '--file 不能重复指定'
      [[ $# -ge 2 && -n "$2" && "$2" != -* ]] || argument_error '--file 缺少文件路径'
      TARGET_FILE="$2"
      shift 2
      ;;
    -h|--help)
      [[ $# -eq 1 && -z "$TARGET_FILE" ]] || argument_error '--help 须单独使用'
      usage
      exit 0
      ;;
    *) argument_error "未知参数: $1" ;;
  esac
done

FILES=()
if [[ -n "$TARGET_FILE" ]]; then
  # 不改变 cwd；独立文件无需安装知识库或配置工作区。
  [[ "$TARGET_FILE" == /* ]] || TARGET_FILE="$PWD/$TARGET_FILE"
  if [[ ! -f "$TARGET_FILE" || ! -r "$TARGET_FILE" ]]; then
    printf '[ERROR] 指定文件不存在或不可读: %s\n' "$TARGET_FILE" >&2
    exit 2
  fi
  FILES=("$TARGET_FILE")
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
  # shellcheck source=../../../scripts/lib/docsconfig.sh
  source "$AGENT_HOME/scripts/lib/docsconfig.sh" || exit 2
  docsconfig_bootstrap_validate || exit 2
  SCAN_DIR="$(docsconfig_doc_abs)"
  if [[ ! -d "$SCAN_DIR" ]]; then
    printf '[SKIP] DOC_DIR 目录不存在，未校验任何文件: %s\n' "$SCAN_DIR"
    exit 3
  fi
  # 先检查 find 返回码，再读 NUL 列表；避免进程替换吞掉扫描错误。
  SCAN_LIST="$(mktemp "${TMPDIR:-/tmp}/validate-test.XXXXXX")" || exit 2
  trap 'rm -f "$SCAN_LIST"' EXIT
  if ! find "$SCAN_DIR" -type f -name 'TDD-*.md' -print0 > "$SCAN_LIST"; then
    printf '[ERROR] 无法完整扫描: %s\n' "$SCAN_DIR" >&2
    exit 2
  fi
  while IFS= read -r -d '' file; do FILES+=("$file"); done < "$SCAN_LIST"
  if [[ ${#FILES[@]} -eq 0 ]]; then
    printf '[SKIP] 未找到 TDD 文档，未校验任何文件: %s\n' "$SCAN_DIR"
    exit 3
  fi
fi

validate_file() {
  local file="$1" basename="${1##*/}"
  # 受支持的模板格式由本检查器定义。字段是否真实、章节是否存在可静态校验；
  # 内容完整性、引用文件可达性、每项 US/BR/API/DSD 追溯及定稿决定仍须人工审阅。
  awk -v filename="$basename" '
    function fail(message) {
      printf "[ERROR] %s: %s\n", filename, message
      errors++
    }
    function trim(value) {
      sub(/^[ \t]+/, "", value)
      sub(/[ \t]+$/, "", value)
      return value
    }
    # 只接受单行标量，识别引号外注释；不把块字符串、映射或 YAML 别名伪装成标量。
    function scalar(raw,    value,q,i,c,tail,result) {
      scalar_ok = 1
      value = trim(raw)
      q = substr(value, 1, 1)
      if (q == "\"" || q == single_quote) {
        result = ""
        for (i = 2; i <= length(value); i++) {
          c = substr(value, i, 1)
          if (q == "\"" && c == "\\") {
            if (i == length(value)) break
            result = result substr(value, ++i, 1)
          } else if (c == q) {
            if (q == single_quote && substr(value, i + 1, 1) == q) {
              result = result q
              i++
              continue
            }
            tail = trim(substr(value, i + 1))
            if (tail != "" && substr(tail, 1, 1) != "#") scalar_ok = 0
            return result
          } else result = result c
        }
        scalar_ok = 0
        return ""
      }
      sub(/[ \t]+#.*/, "", value)
      if (substr(value, 1, 1) == "#") value = ""
      value = trim(value)
      if (value ~ /^[>|\[\]{&*!]/ || value ~ /:[ \t]/ || tolower(value) == "null" || value == "~") scalar_ok = 0
      return value
    }
    function reference_id(value) {
      sub(/^.*\//, "", value)
      sub(/\.md$/, "", value)
      return value
    }
    function reviewer_member(raw,    value) {
      value = scalar(raw)
      return scalar_ok && trim(value) != ""
    }
    # 仅支持标量成员组成的单行列表。引号内的逗号、括号和 # 均为成员内容。
    function reviewer_list(raw,    i,c,q,member,tail) {
      if (substr(raw, 1, 1) != "[") return 0
      for (i = 2; i <= length(raw); i++) {
        c = substr(raw, i, 1)
        if (q != "") {
          member = member c
          if (q == "\"" && c == "\\") member = member substr(raw, ++i, 1)
          else if (c == q) {
            if (q == single_quote && substr(raw, i + 1, 1) == q) member = member substr(raw, ++i, 1)
            else q = ""
          }
        } else if ((c == "\"" || c == single_quote) && trim(member) == "") {
          q = c
          member = member c
        } else if (c == ",") {
          if (!reviewer_member(member)) return 0
          member = ""
        } else if (c == "]") {
          if (trim(member) != "" && !reviewer_member(member)) return 0
          tail = trim(substr(raw, i + 1))
          return tail == "" || substr(tail, 1, 1) == "#"
        } else if (c == "[" || c == "{" || c == "}") return 0
        else if (c == "#" && (i == 2 || substr(raw, i - 1, 1) ~ /[ \t]/)) return 0
        else member = member c
      }
      return 0
    }
    function metadata(line,    key,raw,value) {
      if (line ~ /^[ \t]*(#|$)/) return
      if (line ~ /^[A-Za-z_][A-Za-z0-9_]*:([ \t]|$)/) {
        key = line
        sub(/:.*/, "", key)
        raw = substr(line, length(key) + 2)
        reviewer_block = 0
        if (!required[key]) return
        if (++seen[key] > 1) fail("frontmatter 字段重复: " key)
        if (key == "reviewers") {
          raw = trim(raw)
          if (raw == "" || substr(raw, 1, 1) == "#") {
            reviewer_block = 1
            return
          }
          if (!reviewer_list(raw)) fail("reviewers 需为非空标量组成的单行列表或块列表（无人时用 []）")
          else values[key] = raw
          return
        }
        value = scalar(raw)
        if (!scalar_ok) fail("frontmatter " key " 不属于支持的单行标量格式")
        if (trim(value) == "") fail("frontmatter 字段为空: " key)
        values[key] = value
      } else if (reviewer_block && line ~ /^[ \t]+-[ \t]+/) {
        sub(/^[ \t]+-[ \t]+/, "", line)
        value = scalar(line)
        if (!scalar_ok || trim(value) == "") fail("reviewers 块列表项需为非空单行标量")
        else values["reviewers"] = "block-list"
      } else {
        fail("frontmatter 含不支持的结构（仅校验模板子集）")
      }
    }
    # 仅识别同一行内等长反引号配对；未闭合的反引号不屏蔽真实 HTML 注释。
    function code_span_size(line,    opening,offset,tail,pos,run) {
      opening = line
      sub(/[^`].*$/, "", opening)
      offset = length(opening) + 1
      while (offset <= length(line)) {
        tail = substr(line, offset)
        pos = index(tail, "`")
        if (!pos) return 0
        offset += pos - 1
        run = substr(line, offset)
        sub(/[^`].*$/, "", run)
        if (length(run) == length(opening)) return offset + length(run) - 1
        offset += length(run)
      }
      return 0
    }
    # 保留 HTML 注释之外的可见部分；跨行注释保持状态，行内代码保持字面内容。
    function visible(line,    output,start,finish,tick,size,run) {
      output = ""
      while (line != "") {
        if (in_comment) {
          finish = index(line, "-->")
          if (!finish) return output
          line = substr(line, finish + 3)
          in_comment = 0
        } else {
          start = index(line, "<!--")
          tick = index(line, "`")
          if (tick && (!start || tick < start)) {
            output = output substr(line, 1, tick - 1)
            line = substr(line, tick)
            size = code_span_size(line)
            if (!size) {
              run = line
              sub(/[^`].*$/, "", run)
              size = length(run)
            }
            output = output substr(line, 1, size)
            line = substr(line, size + 1)
            continue
          }
          if (!start) return output line
          output = output substr(line, 1, start - 1)
          line = substr(line, start + 4)
          in_comment = 1
        }
      }
      return output
    }
    function fence_run(text) {
      if (match(text, /^`+/) || match(text, /^~+/)) return substr(text, 1, RLENGTH)
      return ""
    }
    function body(line,    text,run,char,level,heading,is_heading) {
      # 已进入 HTML 注释时，缩进的结束符也必须关闭状态；结束行仍属于注释块。
      if (in_comment) {
        visible(line)
        return
      }
      # 四空格或 tab 开头的内容不是模板的顶层标题/围栏。
      if (line ~ /^(    |\t)/) return
      text = line
      sub(/^ {0,3}/, "", text)
      if (fence_char != "") {
        run = fence_run(text)
        char = substr(run, 1, 1)
        if (char == fence_char && length(run) >= fence_length && trim(substr(text, length(run) + 1)) == "") fence_char = ""
        return
      }
      # 围栏须在源行起始；其 info string 中的 HTML 字符仍是代码元信息。
      run = fence_run(text)
      # backtick 围栏的 info 不能含反引号；该行须继续按行内代码/普通文本处理。
      if (length(run) >= 3 && (substr(run, 1, 1) == "~" || index(substr(text, length(run) + 1), "`") == 0)) {
        fence_char = substr(run, 1, 1)
        fence_length = length(run)
        return
      }
      # 注释删除不能把普通文本变成 ATX 标题（例如 <!-- -->### ...）。
      is_heading = (text ~ /^#{1,3}[ \t]/)
      text = visible(text)
      if (!is_heading) return
      if (text ~ /^#[ \t]/) {
        current_chapter = ""
        return
      }
      heading = text
      sub(/^#+[ \t]+/, "", heading)
      sub(/[ \t]+#+[ \t]*$/, "", heading)
      heading = trim(heading)
      level = (text ~ /^##[ \t]/) ? 2 : 3
      headings[level SUBSEP heading]++
      if (level == 2) current_chapter = heading
      else heading_parents[heading] = current_chapter
    }
    function require_heading(level, heading, parent) {
      if (!headings[level SUBSEP heading]) fail("缺少必需标题: " heading)
      else {
        if (headings[level SUBSEP heading] > 1) fail("必需标题重复: " heading)
        if (level == 3 && heading_parents[heading] != parent) fail("小节须位于 " parent " 下: " heading)
      }
    }
    BEGIN {
      single_quote = sprintf("%c", 39)
      split("id title version status created updated author reviewers parent mvp_phase", fields, " ")
      for (i in fields) required[fields[i]] = 1
      expected_id = filename
      sub(/\.md$/, "", expected_id)
    }
    {
      sub(/\r$/, "")
      if (NR == 1) {
        if ($0 != "---") fail("缺少文首 frontmatter（首行应为 ---）")
        else in_frontmatter = 1
        next
      }
      if (in_frontmatter) {
        if ($0 == "---") {
          in_frontmatter = 0
          closed_frontmatter = 1
        } else metadata($0)
        next
      }
      body($0)
    }
    END {
      if (!closed_frontmatter) fail("frontmatter 未闭合或不存在")
      for (i = 1; i <= 10; i++) {
        key = fields[i]
        if (!seen[key]) fail("缺少 frontmatter 字段: " key)
      }
      if (seen["reviewers"] && values["reviewers"] == "") fail("reviewers 缺少列表值（无评审人时用 []）")
      if (expected_id !~ /^TDD-.+-[0-9]+$/ || filename !~ /\.md$/) fail("文件名应为 TDD-{IDEA-ID}-{N}.md")
      if (values["id"] != expected_id) fail("id 与文件名不一致，期望 " expected_id)
      suffix = substr(expected_id, 5)
      phase = expected_id
      sub(/^.*-/, "", phase)
      if (values["mvp_phase"] != "MVP-Phase-" phase) fail("mvp_phase 应为 MVP-Phase-" phase)
      if (reference_id(values["parent"]) != "PRD-" suffix) fail("parent 应引用 PRD-" suffix)
      require_heading(2, "1. 概述")
      require_heading(2, "2. 测试用例")
      require_heading(2, "3. 测试数据")
      require_heading(2, "4. 测试环境")
      require_heading(2, "5. 测试进出标准")
      require_heading(2, "6. 附录")
      require_heading(3, "1.1 测试目标", "1. 概述")
      require_heading(3, "1.2 测试范围", "1. 概述")
      require_heading(3, "1.3 测试策略", "1. 概述")
      require_heading(3, "2.1 功能测试用例", "2. 测试用例")
      require_heading(3, "2.2 接口测试用例", "2. 测试用例")
      require_heading(3, "2.3 业务规则测试用例", "2. 测试用例")
      require_heading(3, "2.4 异常场景测试用例", "2. 测试用例")
      require_heading(3, "2.6 回归测试用例", "2. 测试用例")
      require_heading(3, "5.1 进入标准", "5. 测试进出标准")
      require_heading(3, "5.2 退出标准", "5. 测试进出标准")
      if (errors) exit 1
      printf "[OK] %s: 结构校验通过\n", filename
    }
  ' "$file"
}

FAILED=0
for file in "${FILES[@]}"; do
  if [[ ! -f "$file" || ! -r "$file" ]]; then
    printf '[ERROR] 文件不存在或不可读: %s\n' "$file" >&2
    exit 2
  fi
  if validate_file "$file"; then
    :
  else
    status=$?
    if [[ "$status" -ne 1 ]]; then
      printf '[ERROR] awk 执行或读取失败: %s\n' "$file" >&2
      exit 2
    fi
    FAILED=$((FAILED + 1))
  fi
done
printf '已校验文件: %s；失败文件: %s\n' "${#FILES[@]}" "$FAILED"
if [[ "$FAILED" -gt 0 ]]; then
  printf '结构校验失败；请修复以上错误，草稿缺口不能视为可定稿。\n'
  exit 1
fi
printf '结构校验通过；不代表用例执行或业务覆盖通过。US/BR/API/DSD 追溯、缺口与定稿须另行审阅。\n'
