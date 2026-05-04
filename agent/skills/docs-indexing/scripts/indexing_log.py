#!/usr/bin/env python3
# INDEXING-LOG 写入与基线解析（对齐 references/indexing-log-spec.md）

from __future__ import annotations

import argparse
import os
import re
import sys
from typing import List

MARKER_TABLE = "| indexing_finished_ms |"
RE_HTML_MS = re.compile(
    r"<!--\s*sdx-indexing:indexing_finished_ms=(\d+)\s*-->"
)
def is_separator_line(line: str) -> bool:
    """表分隔行（|--- / :---| 等）。"""
    if "|" not in line or "---" not in line:
        return False
    inner = [p.strip() for p in line.split("|") if p.strip() != ""]
    if not inner:
        return False
    return all(re.match(r"^:?-+-?:?$", c) for c in inner)


INTRO = """# INDEXING-LOG

> 由 **docs-indexing** 维护。增量基线取自主表**第一行**的 `indexing_finished_ms`（`INDEX_GUIDE` 落盘成功后再写本表；新行**最新在上**）。兼容：若无表可解析，可回退读文内最后一次 `<!-- sdx-indexing:indexing_finished_ms=... -->`。

"""

TABLE_HEADER = (
    "| indexing_finished_ms | indexed_at | mode | depth | since_ms | "
    "output_path | file_count | duration_ms | summary |\n"
    "| --- | --- | --- | --- | --- | --- | --- | --- | --- |\n"
)


def _escape_cell(raw: str) -> str:
    s = (raw or "").replace("\n", " ").replace("|", "\\|")
    return s


def _table_row(
    finished_ms: int,
    indexed_at: str,
    mode: str,
    depth: int,
    since_ms: int,
    output_path: str,
    file_count: int,
    duration_ms: int,
    summary: str,
) -> str:
    return (
        f"| {finished_ms} | {_escape_cell(indexed_at)} | {_escape_cell(mode)} | "
        f"{depth} | {since_ms} | {_escape_cell(output_path)} | {file_count} | "
        f"{duration_ms} | {_escape_cell(summary)} |"
    )


def read_baseline_ms(path: str) -> int:
    """表第一行 indexing_finished_ms；无则文内最后 HTML 注释。失败返回 0。"""
    if not path or not os.path.isfile(path):
        return 0
    try:
        text = open(path, encoding="utf-8").read()
    except OSError:
        return 0

    header_idx = -1
    lines = text.splitlines()
    for i, line in enumerate(lines):
        if MARKER_TABLE in line and line.lstrip().startswith("|"):
            header_idx = i
            break
    if header_idx >= 0:
        seen_sep = False
        for j in range(header_idx + 1, len(lines)):
            line = lines[j]
            if not line.strip():
                continue
            if is_separator_line(line):
                seen_sep = True
                continue
            if seen_sep and line.strip().startswith("|") and not is_separator_line(
                line
            ):
                parts = [p.strip() for p in line.split("|") if p.strip() != ""]
                if not parts:
                    continue
                first = parts[0].replace("\\|", "")
                if first.isdigit() and int(first) > 0:
                    return int(first)

    mlist = RE_HTML_MS.findall(text)
    if mlist:
        return int(mlist[-1])
    return 0


def append_row(
    path: str,
    finished_ms: int,
    indexed_at: str,
    mode: str,
    depth: int,
    since_ms: int,
    output_path: str,
    file_count: int,
    duration_ms: int,
    summary: str,
) -> None:
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    row = _table_row(
        finished_ms,
        indexed_at,
        mode,
        depth,
        since_ms,
        output_path,
        file_count,
        duration_ms,
        summary,
    )

    old_text: Optional[str] = None
    if os.path.isfile(path):
        try:
            old_text = open(path, encoding="utf-8").read()
        except OSError as e:
            print(f"[ERROR] 无法读 {path}: {e}", file=sys.stderr)
            sys.exit(1)
    if old_text is None:
        old_text = ""

    if MARKER_TABLE in old_text and "| indexed_at |" in old_text:
        lines: List[str] = old_text.splitlines(keepends=True)
        for i, line in enumerate(lines):
            if is_separator_line(line.rstrip("\n")):
                lines.insert(i + 1, row + "\n")
                break
        else:
            lines.append(row + "\n")
        with open(path, "w", encoding="utf-8") as f:
            f.write("".join(lines))
        return

    # 无新表：初始化；旧内容落「历史」节
    body = INTRO + "\n" + TABLE_HEADER + row + "\n"
    if old_text.strip() and (MARKER_TABLE not in old_text or "| indexed_at |" not in old_text):
        body += "\n---\n\n## 历史（旧式记录，只读迁移）\n\n" + old_text.rstrip() + "\n"
    with open(path, "w", encoding="utf-8") as f:
        f.write(body)


def main() -> None:
    p = argparse.ArgumentParser(description="INDEXING-LOG 基线读取与表行写入")
    sub = p.add_subparsers(dest="cmd", required=True)

    sb = sub.add_parser("read-baseline", help="输出基线 epoch ms 或 0")
    sb.add_argument("log_file")

    sa = sub.add_parser("append", help="在表内插入新行（最新在上）")
    sa.add_argument("log_file")
    sa.add_argument("--finished-ms", type=int, required=True)
    sa.add_argument("--indexed-at", required=True)
    sa.add_argument("--mode", required=True)
    sa.add_argument("--depth", type=int, required=True)
    sa.add_argument("--since-ms", type=int, required=True)
    sa.add_argument("--output-path", required=True)
    sa.add_argument("--file-count", type=int, required=True)
    sa.add_argument("--duration-ms", type=int, required=True)
    sa.add_argument("--summary", default="")

    args = p.parse_args()
    if args.cmd == "read-baseline":
        print(read_baseline_ms(args.log_file))
        return
    if args.cmd == "append":
        append_row(
            args.log_file,
            args.finished_ms,
            args.indexed_at,
            args.mode,
            args.depth,
            args.since_ms,
            args.output_path,
            args.file_count,
            args.duration_ms,
            args.summary,
        )
        return
    p.error("unknown command")


if __name__ == "__main__":
    main()
