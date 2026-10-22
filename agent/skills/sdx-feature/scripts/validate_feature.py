#!/usr/bin/env python3
"""Read-only checks for the FEATURE template's Markdown structure.

This is a deliberately bounded Markdown reader, not a general Markdown or YAML
parser. Frontmatter delimiters and template fields are checked; business meaning,
ANALYSIS equivalence and human approval remain outside this command's scope.
"""

import argparse
from collections import Counter
from dataclasses import dataclass
import os
from pathlib import Path
import re
from typing import Dict, List, Optional, Tuple
from urllib.parse import unquote, urlsplit


CHAPTERS = ["1. 背景目标", "2. 功能需求", "3. 非功能需求", "4. 交付计划",
            "5. 依赖与风险", "6. 附录"]
SUBHEADINGS = [
    ["1.1 需求背景", "1.2 需求目标", "1.3 范围约束"],
    ["概览"],
    ["3.1 体验与性能", "3.2 可用性与连续性", "3.3 安全与合规",
     "3.4 可追溯与问题定位", "3.5 兼容与升级"],
    ["4.1 MVP 总览", "4.2 MVP 详细规划", "4.3 MVP 依赖关系"],
    ["5.1 依赖关系", "5.2 风险评估"],
    ["6.1 术语表", "6.2 参考文档", "6.3 变更历史", "6.4 质量自查表 (Self-Check)"],
]
OVERVIEW_COLUMNS = ["需求编号", "需求名称", "需求概要", "优先级", "所属模块",
                    "所属里程碑", "关联目标"]
FR_PATTERN = re.compile(r"(?<![\w-])FR-[0-9]{3}(?![\w-])")
ADR_PATTERN = re.compile(r"(?<![A-Za-z0-9_-])ADR-[0-9]+(?![0-9])")


class Report:
    def __init__(self):
        self.errors = 0
        self.warnings = 0

    def warn(self, message: str) -> None:
        self.warnings += 1
        print(f"[WARN]  {message}")

    def error(self, message: str) -> None:
        self.errors += 1
        print(f"[ERROR] {message}")


def visible_lines(text: str) -> List[str]:
    """Blank comments and code blocks, preserving line positions for diagnostics."""
    result = []
    comment = False
    fence = ""
    for raw in text.splitlines():
        if fence:
            if re.fullmatch(r" {0,3}" + re.escape(fence[0]) + "{" + str(len(fence)) + r",}[ \t]*", raw):
                fence = ""
            result.append("")
            continue
        remainder = raw
        visible = ""
        while remainder:
            if comment:
                end = remainder.find("-->")
                if end < 0:
                    break
                remainder = remainder[end + 3:]
                comment = False
            else:
                start = remainder.find("<!--")
                if start < 0:
                    visible += remainder
                    break
                visible += remainder[:start]
                remainder = remainder[start + 4:]
                comment = True
        opening = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", visible)
        if opening and not (opening[1][0] == "`" and "`" in opening[2]):
            fence = opening[1]
            visible = ""
        if visible.startswith(("    ", "\t")):
            visible = ""
        result.append(visible)
    return result


@dataclass
class Heading:
    line: int
    end: int
    level: int
    title: str
    parent: Optional[int]


class Document:
    def __init__(self, lines: List[str]):
        self.lines = lines
        self.headings = []
        stack = []
        for index, line in enumerate(lines):
            match = re.match(r"^ {0,3}(#{1,6})[ \t]+(.+?)\s*$", line)
            if not match:
                continue
            level = len(match[1])
            title = re.sub(r"[ \t]+#+[ \t]*$", "", match[2])
            while stack and stack[-1].level >= level:
                stack.pop().end = index
            heading = Heading(index, len(lines), level, title,
                              stack[-1].line if stack else None)
            self.headings.append(heading)
            stack.append(heading)

    def section(self, title: str, level: int, parent: Optional[Heading],
                label: str, report: Report) -> Optional[Heading]:
        matches = [h for h in self.headings if h.title == title and h.level == level
                   and (level == 2 or (parent is not None and h.parent == parent.line))]
        if not matches:
            report.warn(f"{label}: 缺少章节/小节 '{'#' * level} {title}'（须位于对应章节）")
            return None
        if len(matches) > 1:
            report.warn(f"{label}: 标题重复 '{title}'")
        return matches[0]

    def body(self, heading: Optional[Heading]) -> List[Tuple[int, str]]:
        if heading is None:
            return []
        return [(i + 1, self.lines[i]) for i in range(heading.line + 1, heading.end)]


def split_row(line: str) -> Optional[List[str]]:
    """Split unescaped pipes; a Markdown escaped pipe belongs to its cell."""
    if "|" not in line:
        return None
    cells = []
    cell = ""
    backslashes = 0
    for char in line.strip():
        if char == "|" and backslashes % 2 == 0:
            cells.append(cell.strip())
            cell = ""
        else:
            cell += char
        backslashes = backslashes + 1 if char == "\\" else 0
    cells.append(cell.strip())
    if line.strip().startswith("|"):
        cells = cells[1:]
    if line.rstrip().endswith("|") and not cells[-1]:
        cells = cells[:-1]
    return [re.sub(r"\\([|\\])", r"\1", cell) for cell in cells]


def table_rows(lines: List[Tuple[int, str]], columns: List[str], label: str,
               report: Report, exact: bool = False) -> List[Tuple[int, Dict[str, str]]]:
    rows = []
    table_count = 0
    for index in range(len(lines) - 1):
        header = split_row(lines[index][1])
        separator = split_row(lines[index + 1][1])
        if not header or not separator or not all(re.fullmatch(r":?-+:?", c) for c in separator):
            continue
        if not set(header).intersection(columns):
            continue
        table_count += 1
        if len(separator) != len(header):
            report.warn(f"{label}: 表头与分隔行列数不一致")
        missing = [column for column in columns if column not in header]
        if missing:
            report.warn(f"{label}: 缺少列 {'、'.join(missing)}")
        if len(set(header)) != len(header):
            report.warn(f"{label}: 表头存在重复列")
        if exact and len(header) != len(columns):
            report.warn(f"{label}: 表头列数应为 {len(columns)}，实际 {len(header)}")
        for line_number, line in lines[index + 2:]:
            cells = split_row(line)
            if cells is None:
                break
            if len(cells) != len(header):
                report.warn(f"{label}:{line_number}: 表行列数应为 {len(header)}，实际 {len(cells)}")
                continue
            rows.append((line_number, dict(zip(header, cells))))
    if not table_count:
        report.warn(f"{label}: 缺少有效表格（须有表头和分隔行）")
    elif table_count > 1:
        report.warn(f"{label}: 存在多个表格，应合并为一张清单")
    return rows


def scalar(value: str) -> str:
    # Template metadata uses ordinary single/double quoted or plain scalars.
    match = re.fullmatch(r'''(["'])(.*?)\1(?:\s+#.*)?''', value.strip())
    return match[2] if match else re.split(r"\s+#", value.strip(), maxsplit=1)[0]


def frontmatter(raw: List[str], path: Path, report: Report) -> Optional[int]:
    if not raw or raw[0] != "---":
        report.error(f"{path.name}: 缺少文首 YAML frontmatter（首行应为 ---）")
        return None
    end = next((i for i in range(1, len(raw)) if raw[i] == "---"), None)
    if end is None:
        report.error(f"{path.name}: YAML frontmatter 未闭合（缺少第二个 ---）")
        return None
    fields = {}
    for line in raw[1:end]:
        match = re.match(r"^([A-Za-z_][A-Za-z_0-9-]*):\s*(.*)$", line)
        if match:
            if match[1] in fields:
                report.warn(f"{path.name}: frontmatter 字段重复 {match[1]}")
            fields[match[1]] = scalar(match[2])
    for field in ["id", "title", "version", "status", "created", "updated", "author",
                  "reviewers", "parent", "tags"]:
        if field not in fields:
            report.warn(f"{path.name}: 缺少 {field}: 字段")
        elif not fields[field] and field not in ("tags", "reviewers"):
            report.warn(f"{path.name}: {field}: 字段为空")
    identifier = fields.get("id", "")
    if not re.fullmatch(r"FEATURE-[^\s{}]+", identifier):
        report.warn(f"{path.name}: id 应为 FEATURE-{{IDEA-ID}}，实际: {identifier}")
    if identifier != path.stem:
        report.warn(f"{path.name}: id 与文件名不一致，实际: {identifier}")
    expected_parent = "ANALYSIS-" + path.stem[len("FEATURE-"):] if path.stem.startswith("FEATURE-") else ""
    if not expected_parent or fields.get("parent") != expected_parent:
        report.warn(f"{path.name}: parent 须关联同链 {expected_parent or 'ANALYSIS-{IDEA-ID}'}")
    return end


def named_stage(value: str, prefix: str) -> bool:
    match = re.fullmatch(prefix + r"[1-9][0-9]*(?:（([^（）(){}]+)）|\(([^（）(){}]+)\))", value)
    return bool(match and (match[1] or match[2]).strip())


def check_overview(doc: Document, chapter: Optional[Heading], overview: Optional[Heading],
                   label: str, report: Report) -> Counter:
    rows = table_rows(doc.body(overview), OVERVIEW_COLUMNS, f"{label}: 概览", report, exact=True)
    ids = Counter()
    names = {}
    for number, row in rows:
        identifier = row.get("需求编号", "")
        prefix = f"{label}:{number}: {identifier or '概览行'}"
        if not re.fullmatch(r"FR-[0-9]{3}", identifier):
            report.warn(f"{prefix}: 需求编号须为 FR-nnn")
            continue
        ids[identifier] += 1
        names[identifier] = row.get("需求名称", "")
        for column, limit in [("需求名称", 30), ("需求概要", 60)]:
            value = row.get(column, "")
            if not value or re.search(r"\{[^}]*\}", value):
                report.warn(f"{prefix}: {column}为空或仍有占位")
            elif len(value) > limit:
                report.warn(f"{prefix}: {column}超长（{len(value)}>{limit}）")
        module = row.get("所属模块", "")
        if not module or re.search(r"[,，、;；{}]", module):
            report.warn(f"{prefix}: 所属模块须非空且一 FR 一模块，禁占位或逗号多值")
        if not named_stage(row.get("所属里程碑", ""), "M"):
            report.warn(f"{prefix}: 所属里程碑须为单个 M{{n}}（短名），非空且禁 MVP{{n}}")
        if row.get("优先级", "") not in ("P0", "P1", "P2", "P3"):
            report.warn(f"{prefix}: 优先级须为 P0/P1/P2/P3")
        goals = re.split(r"[,，、;；\s]+", row.get("关联目标", ""))
        if not goals or not all(re.fullmatch(r"G-[1-9][0-9]*", goal) for goal in goals):
            report.warn(f"{prefix}: 关联目标须填写 G-n")
    if not ids:
        report.warn(f"{label}: 概览至少需要一条 FR")
    for identifier, count in ids.items():
        if count > 1:
            report.warn(f"{label}: 概览 {identifier} 重复 {count} 次")

    headings = Counter()
    for heading in doc.headings:
        if chapter is None or heading.level != 3 or heading.parent != chapter.line:
            continue
        if not heading.title.startswith("FR-"):
            continue
        match = re.fullmatch(r"(FR-[0-9]{3})\s*[:：]\s*(.*)", heading.title)
        if not match:
            report.warn(f"{label}: FR 标题格式应为 '### FR-nnn: 需求名称'")
            continue
        identifier, name = match[1], match[2].strip()
        headings[identifier] += 1
        if len(name) > 30:
            report.warn(f"{label}: {identifier} 标题名称超长（{len(name)}>30）")
        if identifier not in ids:
            report.warn(f"{label}: FR 标题 {identifier} 未列入概览")
        elif name != names[identifier]:
            report.warn(f"{label}: {identifier} 标题名称与概览需求名称不一致")
    for identifier in ids:
        if not headings[identifier]:
            report.warn(f"{label}: 概览 {identifier} 缺少对应 FR 标题")
    for identifier, count in headings.items():
        if count > 1:
            report.warn(f"{label}: FR 标题 {identifier} 重复 {count} 次")
    return ids


def check_delivery(doc: Document, section: Optional[Heading], ids: Counter,
                   label: str, report: Report) -> None:
    rows = table_rows(doc.body(section), ["MVP 阶段", "包含需求"], f"{label}: §4.1 MVP 总览", report)
    loads = Counter()
    stages = Counter()
    for number, row in rows:
        stage = row.get("MVP 阶段", "")
        if not named_stage(stage, "MVP"):
            report.warn(f"{label}:{number}: MVP 阶段须为 MVP{{n}}（短名）")
        stage_id = re.match(r"MVP[0-9]+", stage)
        if stage_id:
            stages[stage_id[0]] += 1
        included = row.get("包含需求", "")
        references = FR_PATTERN.findall(included)
        if not references or re.sub(FR_PATTERN, "", included).strip(" ,，、;；`\t"):
            report.warn(f"{label}:{number}: MVP 包含需求须列出 FR-nnn 清单")
        loads.update(references)
    if not rows:
        report.warn(f"{label}: §4.1 缺少 MVP 装载行")
    for stage, count in stages.items():
        if count > 1:
            report.warn(f"{label}: §4.1 {stage} 阶段重复 {count} 次")
    for identifier in ids:
        if loads[identifier] != 1:
            report.warn(f"{label}: §4.1 {identifier} 须恰好装入一个 MVP，实际 {loads[identifier]} 次")
    for identifier in loads.keys() - ids.keys():
        report.warn(f"{label}: §4.1 MVP 包含未知需求 {identifier}")


def check_adr(doc: Document, references: Optional[Heading], path: Path, report: Report) -> None:
    text = "\n".join(doc.lines)
    ids = set(ADR_PATTERN.findall(text))
    pending = "ADR-待定" in text
    if not ids and not pending:
        return
    adr_dir = path.parent.parent / "adr"
    context = adr_dir / "CONTEXT.md"
    reference_text = "\n".join(line for _, line in doc.body(references))
    reference_text = re.sub(r"(`+)(?!`)[\s\S]*?(?<!`)\1(?!`)", "", reference_text)
    context_linked = False
    # Only local inline links are resolved; reference-style Markdown is outside
    # this lightweight template check. A mere CONTEXT.md mention is not a link.
    link_pattern = r'''\[[^\]\n]*\]\(\s*(?:<([^>\n]+)>|([^\s)]+))(?:[ \t]+["'][^"'\n]*["'])?\s*\)'''
    reference_links = {link[0] for link in re.finditer(link_pattern, reference_text)}
    link_text = re.sub(r"(`+)(?!`)[\s\S]*?(?<!`)\1(?!`)", "", text)
    for link in re.finditer(link_pattern, link_text):
        target = link[1] or link[2]
        is_adr_link = False
        try:
            url = urlsplit(target)
            is_adr_link = bool(ADR_PATTERN.search(Path(unquote(url.path)).name))
            if (url.scheme or url.netloc) and is_adr_link:
                report.warn(f"{path.name}: ADR 链接不属本层，须指向本地 ADR 文件: {target}")
                continue
            if not url.scheme and not url.netloc and url.path:
                linked_path = path.parent / unquote(url.path)
                resolved = linked_path.resolve()
                if link[0] in reference_links and resolved == context.resolve():
                    context_linked = True
                if is_adr_link and not (
                    re.fullmatch(r"ADR-[0-9]+-.+\.md", linked_path.name)
                    and resolved.parent == adr_dir.resolve()
                    and resolved.is_file()
                ):
                    report.warn(f"{path.name}: ADR 链接须指向本层已有 ADR 文件: {target}")
        except (OSError, ValueError, RuntimeError):
            if is_adr_link:
                report.warn(f"{path.name}: 无法解析 ADR 链接目标: {target}")
            continue
    if not context_linked:
        report.warn(f"{path.name}: 出现 ADR 引用/占位，但 §6.2 未链接本层 adr/CONTEXT.md")
    context_ids = set()
    if not context.is_file():
        report.warn(f"{path.name}: 缺少 {context}")
    else:
        try:
            context_lines = list(enumerate(visible_lines(context.read_text(encoding="utf-8-sig")), start=1))
            rows = table_rows(context_lines, ["决策编号"], f"{path.name}: CONTEXT", report)
            for line_number, row in rows:
                identifier = row.get("决策编号", "")
                if re.fullmatch(r"ADR-[0-9]+", identifier):
                    context_ids.add(identifier)
                else:
                    report.warn(f"{path.name}: CONTEXT:{line_number} 决策编号须为单个 ADR-n")
        except (OSError, UnicodeError) as exc:
            report.error(f"{path.name}: 无法读取 {context}: {exc}")
    for identifier in sorted(ids):
        if context.is_file() and identifier not in context_ids:
            report.warn(f"{path.name}: CONTEXT 未登记 {identifier}")
        if not any(file.is_file() for file in adr_dir.glob(f"{identifier}-*.md")):
            report.warn(f"{path.name}: 未找到 {adr_dir}/{identifier}-*.md")
    if pending:
        report.warn(f"{path.name}: 仍有 ADR-待定 占位，推进前须落盘")


def validate(path: Path, report: Report) -> None:
    print(f"--- 校验: {path.name} ---")
    try:
        raw = path.read_text(encoding="utf-8-sig").splitlines()
    except (OSError, UnicodeError) as exc:
        report.error(f"无法读取 {path}: {exc}")
        return
    end = frontmatter(raw, path, report)
    if end is None:
        return
    doc = Document([""] * (end + 1) + visible_lines("\n".join(raw[end + 1:])))
    sections = {}
    chapters = []
    for title, subtitles in zip(CHAPTERS, SUBHEADINGS):
        chapter = doc.section(title, 2, None, path.name, report)
        chapters.append(chapter)
        for subtitle in subtitles:
            sections[subtitle] = doc.section(subtitle, 3, chapter, path.name, report)
    for title in ["范围与边界", "假设与约束", "研究与分析"]:
        doc.section(title, 4, sections["1.3 范围约束"], path.name, report)
    ids = check_overview(doc, chapters[1], sections["概览"], path.name, report)
    check_delivery(doc, sections["4.1 MVP 总览"], ids, path.name, report)
    check_adr(doc, sections["6.2 参考文档"], path, report)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    target = parser.add_mutually_exclusive_group(required=True)
    target.add_argument("--file", type=Path)
    target.add_argument("--scan", type=Path)
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    report = Report()
    print("=== 功能特性文档结构校验 ===")
    files = []
    if args.file is not None:
        files = [args.file.absolute()]
    elif not args.scan.exists():
        report.warn(f"features/ 目录不存在: {args.scan}")
    elif not args.scan.is_dir():
        report.error(f"features/ 路径不是目录: {args.scan}")
    else:
        def scan_error(exc):
            raise exc
        try:
            for directory, _, filenames in os.walk(args.scan, onerror=scan_error):
                files.extend(Path(directory) / name for name in filenames
                             if name.startswith("FEATURE-") and name.endswith(".md"))
        except OSError as exc:
            report.error(f"无法扫描 features/: {exc}")
        if not files:
            report.warn("未找到功能特性文档；未检查任何文档")
    for path in sorted(files):
        validate(path, report)
    print("=== 校验结果 ===")
    print(f"错误: {report.errors}  警告: {report.warnings}")
    if report.errors or (args.strict and report.warnings):
        print("校验失败，请修复以上错误或严格模式警告。")
        return 1
    if report.warnings:
        print("检查完成；存在内容警告，默认模式不阻断。")
    else:
        print("校验通过。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
