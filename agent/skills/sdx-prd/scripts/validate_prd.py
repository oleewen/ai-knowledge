#!/usr/bin/env python3
"""Read-only PRD structure checks; deliberately supports a small YAML subset.

Top-level scalar keys and reviewers string lists only. Double-quoted scalars
use JSON escapes; unsupported YAML is an error, never silently accepted.
Markdown checks cover ATX headings outside fences, quotes and HTML comments.
They do not establish content completeness, link validity or Mermaid validity.
"""

import argparse
from collections import Counter
import json
import os
from pathlib import Path
import re
import sys


FIELDS = ("id", "title", "version", "status", "created", "updated", "author",
          "reviewers", "parent", "mvp_phase")
SECTIONS = ("产品概述", "业务流程", "产品交互", "用例模型", "用户故事", "功能模块设计",
            "业务规则汇总", "数据字典", "非功能需求", "验收标准", "附录")
SUBSECTIONS = ("1.2 成功标准", "2.1 核心业务流程", "4.1 用例图", "5.1 用户故事清单",
               "10.1 功能验收标准", "11.3 质量自查表")
SUBSECTION_ALIASES = {
    "10.1 功能验收标准（FAC）": "10.1 功能验收标准",
    "11.3 质量自查表 (Self-Check)": "11.3 质量自查表",
}


class Report:
    def __init__(self, path):
        self.path = path
        self.errors = 0
        self.warnings = 0

    def emit(self, level, code, message, line=None):
        location = f"{self.path}:{line}" if line else str(self.path)
        print(f"[{level}] [{code}] {location}: {message}")
        self.errors += level == "ERROR"
        self.warnings += level == "WARN"

    def error(self, code, message, line=None):
        self.emit("ERROR", code, message, line)


def scalar(value):
    """Parse one scalar in the documented subset, rejecting YAML structures."""
    value = value.strip()
    if not value or value.startswith("#"):
        return ""
    if value.startswith("'"):
        match = re.match(r"'((?:[^']|'')*)'", value)
        if not match:
            raise ValueError("单引号未闭合")
        result, rest = match[1].replace("''", "'"), value[match.end():]
    elif value.startswith('"'):
        try:
            result, end = json.JSONDecoder().raw_decode(value)
        except ValueError as exc:
            raise ValueError("双引号标量须闭合，且仅支持 JSON 转义") from exc
        rest = value[end:]
    else:
        result = re.split(r"\s+#", value, maxsplit=1)[0].strip()
        if (result[0] in "[]{}>|&*!%@`" or re.search(r":(?:\s|$)", result)
                or result in ("~", "null", "Null", "NULL")
                or re.match(r"[-?:](?:\s|$)", result)):
            raise ValueError("不支持此 YAML 表达；请使用非空单行字符串")
        return result
    if rest and (not rest[0].isspace() or (rest.strip() and not rest.lstrip().startswith("#"))):
        raise ValueError("引号后仅允许空白与注释")
    return result


def reviewer_list(value):
    """Split a flow list without treating quoted commas as separators."""
    value = value.strip()
    if not value.startswith("["):
        raise ValueError("reviewers 须为字符串列表，如 [] 或 ['产品', '架构']")
    pieces, quote, start, index = [], None, 1, 1
    while index < len(value):
        char = value[index]
        if quote:
            if char == "\\" and quote == '"':
                index += 2
                continue
            if char == quote:
                if quote == "'" and value[index:index + 2] == "''":
                    index += 2
                    continue
                quote = None
        elif char in "'\"" and not value[start:index].strip():
            quote = char
        elif char == "#" and (index == start or value[index - 1].isspace()):
            raise ValueError("reviewers 行内列表须在注释开始前闭合")
        elif char in ",]":
            item = value[start:index].strip()
            if item and item[0] not in "'\"" and re.search(r"[\[\]{}]", item):
                raise ValueError("reviewers 行内列表中的集合符号须放在引号内")
            if char == "," or item:
                pieces.append(scalar(item))
            if char == "]":
                rest = value[index + 1:]
                if rest and (not rest[0].isspace() or (rest.strip() and not rest.lstrip().startswith("#"))):
                    raise ValueError("reviewers 列表后仅允许空白与注释")
                if any(not item for item in pieces):
                    raise ValueError("reviewers 列表项不得为空")
                return pieces
            start = index + 1
        index += 1
    raise ValueError("reviewers 列表或引号未闭合")


def frontmatter(lines, report):
    if not lines or lines[0].strip() != "---":
        report.error("frontmatter.missing", "缺少文首 frontmatter（首行应为 ---）", 1)
        return {}, 0
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if end is None:
        report.error("frontmatter.unclosed", "frontmatter 缺少结束 ---", 1)
        return {}, len(lines)
    values, seen = {}, set()
    index = 1
    while index < end:
        line = lines[index]
        number = index + 1
        index += 1
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        match = re.fullmatch(r"([A-Za-z_][A-Za-z0-9_-]*):(?:\s+(.*)|\s*)", line)
        if not match:
            report.error("frontmatter.unsupported", "仅支持顶层 key: value 和 reviewers 列表", number)
            continue
        key, raw = match[1], match[2] or ""
        if key in seen:
            report.error("frontmatter.duplicate", f"重复字段 {key}", number)
        seen.add(key)
        try:
            if key == "reviewers" and (not raw.strip() or raw.lstrip().startswith("#")):
                items = []
                indentation = None
                while index < end:
                    if not lines[index].strip() or lines[index].lstrip().startswith("#"):
                        index += 1
                        continue
                    item = re.fullmatch(r"( +)-[ \t]+(.+)", lines[index])
                    if not item or (indentation is not None and len(item[1]) != indentation):
                        break
                    indentation = len(item[1])
                    items.append(scalar(item[2]))
                    index += 1
                if not items or not all(items):
                    raise ValueError("空 reviewers 请显式写 []，列表项须为非空字符串")
                values[key] = items
            elif key == "reviewers":
                values[key] = reviewer_list(raw)
            else:
                values[key] = scalar(raw)
        except ValueError as exc:
            report.error("frontmatter.unsupported", str(exc), number)
    for field in FIELDS:
        if field not in values or (field != "reviewers" and not values[field].strip()):
            report.error("metadata.required", f"缺少或空置必需字段 {field}")
    return values, end + 1


def identity(path, metadata, report):
    # Upstream IDs are inherited verbatim, including Chinese and legacy IDs.
    # The final hyphen-delimited segment alone identifies the MVP phase.
    match = re.fullmatch(r"PRD-(.+)-([1-9][0-9]*)\.md", path.name)
    if not match or not match[1].strip():
        report.error("identity.filename", "文件名须为 PRD-{IDEA-ID}-{N}.md，N 为正整数")
        return
    idea, phase = match.groups()
    expected = {"id": path.stem, "parent": f"FEATURE-{idea}", "mvp_phase": f"MVP-Phase-{phase}"}
    for field, value in expected.items():
        if field in metadata and metadata[field] != value:
            report.error("identity.mismatch", f"{field} 应为 {value}，实际 {metadata[field]!r}")
    # Free-form --file paths are allowed. Enforce layout only when this pair exists.
    if path.parent.name.startswith("MVP-Phase-") and path.parent.parent.name.startswith("REQUIREMENT-"):
        if path.parent.name != expected["mvp_phase"] or path.parent.parent.name != f"REQUIREMENT-{idea}":
            report.error("identity.directory", "REQUIREMENT/MVP-Phase 目录与文件身份不一致")


def without_comments(line, comment):
    """Strip comments while preserving literal markers in inline code spans."""
    # An HTML comment block includes its entire closing line. Its suffix must
    # not become a Markdown block after the comment markers are removed.
    if comment or re.match(r"^ {0,3}<!--", line):
        return "", "-->" not in line
    rendered = ""
    while line:
        if comment:
            _, found, line = line.partition("-->")
            if not found:
                return rendered, True
            comment = False
            continue
        opening = line.find("<!--")
        if opening < 0:
            return rendered + line, False
        code = re.search(r"(?<!`)(`+)(?!`)(.*?)\1(?!`)", line)
        if code and code.start() < opening:
            rendered += line[:code.end()]
            line = line[code.end():]
        elif (opening - len(line[:opening].rstrip("\\"))) % 2:
            rendered += line[:opening + 4]
            line = line[opening + 4:]
        else:
            rendered += line[:opening]
            line = line[opening + 4:]
            comment = True
    return rendered, comment


def body_structure(lines, start, report):
    sections, subsections, visible = [], [], []
    current_section = None
    fence = None
    comment = False
    mermaid = 0
    for number, original in enumerate(lines[start:], start + 1):
        if fence:
            if re.fullmatch(r" {0,3}" + re.escape(fence[0]) + "{" + str(fence[1]) + r",}\s*", original):
                mermaid += fence[2] == "mermaid"
                fence = None
            continue
        if not comment and re.match(r"^(?: {4}|\t| {0,3}>)", original):
            continue
        opening = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", original)
        if (not comment and opening
                and (opening[1][0] != "`" or "`" not in opening[2])):
            fence = (opening[1][0], len(opening[1]), opening[2].strip(), number)
            continue
        line, comment = without_comments(original, comment)
        if not line.strip():
            continue
        visible.append(line)
        heading = re.match(r"^ {0,3}(#{1,6})(?:[ \t]+|$)", original)
        if not heading:
            continue
        title = re.sub(r"\s+#+\s*$", "", line[heading.end():]).strip()
        title = SUBSECTION_ALIASES.get(title, title)
        if len(heading[1]) <= 2:
            current_section = None
        if len(heading[1]) == 2:
            match = re.fullmatch(r"([0-9]+)\.\s+(.+)", title)
            if match:
                index = int(match[1])
                if 1 <= index <= 11 and match[2] == SECTIONS[index - 1]:
                    sections.append(index)
                    current_section = index
                else:
                    report.error("section.unexpected", f"章节编号或标题不符: {title}", number)
        elif len(heading[1]) == 3 and title in SUBSECTIONS:
            subsections.append(title)
            if current_section != int(title.split(".", 1)[0]):
                report.error("subsection.parent", f"小节不在对应章节内: {title}", number)
    if fence:
        report.error("markdown.fence", "代码围栏未闭合", fence[3])
    if comment:
        report.error("markdown.comment", "HTML 注释未闭合")
    for index, title in enumerate(SECTIONS, 1):
        count = sections.count(index)
        if count != 1:
            report.error("section.count", f"## {index}. {title} 应出现一次，实际 {count}")
    if sections != sorted(sections):
        report.error("section.order", "十一章顺序不正确")
    counts = Counter(subsections)
    for title in SUBSECTIONS:
        if counts[title] != 1:
            report.error("subsection.count", f"### {title} 应出现一次，实际 {counts[title]}")
    text = "\n".join(visible)
    counts = {}
    for prefix in ("US", "UC", "BR", "EX", "AC", "NAC", "FR"):
        counts[prefix] = len(set(re.findall(r"(?<![A-Za-z0-9_-])" + prefix + r"-[0-9]+(?![A-Za-z0-9_-])", text)))
    report.emit("INFO", "references.count", " ".join(f"{key}={count}" for key, count in counts.items()))
    for prefix in ("US", "UC", "FR"):
        if not counts[prefix]:
            report.emit("WARN", "content.reference", f"未发现 {prefix}-n；请人工检查内容及可追溯性")
    if not mermaid:
        report.emit("WARN", "content.mermaid", "未发现闭合 Mermaid 围栏；请人工核对图表适用性")


def scan(root):
    if not root.exists():
        return []
    if not root.is_dir():
        raise OSError(f"扫描路径不是目录: {root}")
    files = []

    def failed(error):
        raise error

    for directory, _, names in os.walk(root, onerror=failed):
        files.extend(Path(directory) / name for name in names
                     if name.startswith("PRD-") and name.endswith(".md"))
    return sorted(files)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--file", type=Path)
    group.add_argument("--scan-root", type=Path)
    args = parser.parse_args()
    print("PRD 结构校验；结果不等于语义验收，未验证内容正确性、关联文件存在或 Mermaid 渲染。")
    try:
        files = [args.file.resolve()] if args.file else scan(args.scan_root.resolve())
    except (OSError, RuntimeError) as exc:
        print(f"[ERROR] [environment.scan] {exc}", file=sys.stderr)
        return 2
    if not files:
        print("未找到 PRD，未校验。")
        print("status=NOT_VALIDATED validated=0 errors=0 warnings=0")
        return 0
    errors = warnings = validated = 0
    environment_error = False
    for path in files:
        report = Report(path)
        try:
            path = path.resolve()
            report.path = path
            if not path.is_file():
                raise OSError(f"目标不存在或不是普通文件: {path}")
            lines = path.read_text(encoding="utf-8-sig").splitlines()
        except UnicodeError as exc:
            report.error("document.encoding", f"文档须为 UTF-8: {exc}")
            errors += report.errors
            validated += 1
            continue
        except (OSError, RuntimeError) as exc:
            report.error("environment.read", f"无法读取文件: {exc}")
            errors += report.errors
            environment_error = True
            continue
        metadata, start = frontmatter(lines, report)
        identity(path, metadata, report)
        body_structure(lines, start, report)
        errors += report.errors
        warnings += report.warnings
        validated += 1
    status = "ERROR" if environment_error else "FAIL" if errors else "PASS"
    print(f"status={status} validated={validated} errors={errors} warnings={warnings}")
    return 2 if environment_error else 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
