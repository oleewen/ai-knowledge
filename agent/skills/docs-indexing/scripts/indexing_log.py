#!/usr/bin/env python3
"""Read and explicitly write completion anchors in an existing INDEX-GUIDE."""

from __future__ import annotations

import argparse
from datetime import datetime, timedelta, timezone
import os
from pathlib import Path
import re
import stat
import sys
import tempfile


RE_HTML_MS = re.compile(rb"<!--\s*sdx-indexing:indexing_finished_ms=([0-9]+)\s*-->")
ANCHOR_FMT = "<!-- sdx-indexing:indexing_finished_ms={ms} -->"
RE_FENCE = re.compile(rb"^ {0,3}(`{3,}|~{3,})([^\r\n]*)\r?\n?$")
RE_QUOTE_PREFIX = re.compile(rb"^ {0,3}>[ \t]?")


def positive_ms(value: str) -> int:
    """Accept decimal positive integers, without signs or fractions."""
    if not re.fullmatch(r"[0-9]+", value) or int(value) <= 0:
        raise ValueError("时间须为正整数 epoch ms")
    return int(value)


def display_time(milliseconds: int) -> str:
    """Keep human-facing timestamps explicit about timezone and epoch units."""
    instant = datetime.fromtimestamp(milliseconds // 1000, timezone(timedelta(hours=8)))
    return f"{instant:%Y-%m-%d %H:%M:%S} +08（{milliseconds}）"


def body_regions(content: bytes) -> tuple[list[tuple[int, int]], bool]:
    """Locate body bytes outside frontmatter/fences and report safe EOF appends."""
    offset = 0
    section_start = 0
    fence = None
    fence_quotes = 0
    in_frontmatter = False
    regions = []
    for line_number, line in enumerate(content.splitlines(keepends=True)):
        if line_number == 0 and line.removeprefix(b"\xef\xbb\xbf").strip() == b"---":
            in_frontmatter = True
            offset += len(line)
            continue
        if in_frontmatter:
            offset += len(line)
            if line.rstrip(b" \t\r\n") in (b"---", b"..."):
                in_frontmatter = False
                section_start = offset
            continue

        line_size = len(line)
        quotes = 0
        while prefix := RE_QUOTE_PREFIX.match(line):
            quotes += 1
            line = line[prefix.end():]
        # Leaving a blockquote also ends its fenced example.
        if fence is not None and quotes < fence_quotes:
            fence = None
            section_start = offset
        match = RE_FENCE.match(line)
        if match:
            ticks, remainder = match.groups()
            if fence is None:
                if ticks[:1] != b"`" or b"`" not in remainder:
                    regions.append((section_start, offset))
                    fence = ticks
                    fence_quotes = quotes
            elif (quotes == fence_quotes and ticks[:1] == fence[:1]
                  and len(ticks) >= len(fence) and not remainder.strip()):
                fence = None
                section_start = offset + line_size
        offset += line_size
    safe_append = fence is None and not in_frontmatter
    if safe_append:
        regions.append((section_start, len(content)))
    return regions, safe_append


def unfenced_matches(content: bytes, pattern: re.Pattern[bytes]):
    """Find markers in body text, preserving metadata and fenced examples."""
    regions, _ = body_regions(content)
    for start, end in regions:
        yield from pattern.finditer(content, start, end)


def read_guide(path: Path) -> bytes:
    content = path.read_bytes()
    # Invalid UTF-8 is an I/O/content error, never an absent baseline.
    content.decode("utf-8")
    return content


def read_baseline_ms(path: str | Path) -> int:
    """Return the first real anchor; absent guides or anchors return zero."""
    try:
        content = read_guide(Path(path))
    except FileNotFoundError:
        return 0
    first = next(unfenced_matches(content, RE_HTML_MS), None)
    return positive_ms(first.group(1).decode("ascii")) if first else 0


def atomic_write(path: Path, content: bytes) -> None:
    """Replace a regular file atomically, preserving existing permission bits."""
    if path.is_symlink():
        raise ValueError(f"拒绝写入输出软链: {path}")
    current = path.stat() if path.exists() else None
    if current and not stat.S_ISREG(current.st_mode):
        raise ValueError(f"输出不是普通文件: {path}")
    mode = stat.S_IMODE(current.st_mode) if current else 0o644
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(content)
            stream.flush()
            os.fchmod(stream.fileno(), mode)
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def append_block(original: bytes, block: bytes) -> bytes:
    """Append without stripping or normalizing any existing bytes."""
    _, safe_append = body_regions(original)
    if not safe_append:
        raise ValueError("指南存在未闭合的 frontmatter 或代码围栏，无法安全追加")
    newline = b"\r\n" if b"\r\n" in original else b"\n"
    separator = b"" if not original or original.endswith(newline * 2) else newline
    if original and not original.endswith(newline):
        separator += newline
    return original + separator + block + newline


def write_anchor(path: str | Path, finished_ms: int) -> None:
    """Normalize real anchors to one occurrence while preserving all other bytes."""
    if finished_ms <= 0:
        raise ValueError("finished_ms 须为正整数")
    guide = Path(path)
    if guide.is_symlink():
        raise ValueError(f"拒绝写入输出软链: {guide}")
    original = read_guide(guide)
    if not original.strip():
        raise ValueError(f"指南为空，完成指南后才能写入锚点: {guide}")
    marker = ANCHOR_FMT.format(ms=finished_ms).encode("ascii")
    matches = list(unfenced_matches(original, RE_HTML_MS))
    if matches:
        pieces = []
        offset = 0
        for index, match in enumerate(matches):
            pieces.extend((original[offset:match.start()], marker if index == 0 else b""))
            offset = match.end()
        pieces.append(original[offset:])
        updated = b"".join(pieces)
    else:
        updated = append_block(original, marker)
    atomic_write(guide, updated)


def main() -> int:
    parser = argparse.ArgumentParser(description="INDEX-GUIDE 增量锚点读取与显式写入")
    sub = parser.add_subparsers(dest="cmd", required=True)
    reader = sub.add_parser("read-baseline", help="输出首条非围栏锚点；无锚点输出 0，读取失败非 0 退出")
    reader.add_argument("guide_file")
    writer = sub.add_parser("write-anchor", help="指南完成后写入/更新 HTML 锚点")
    writer.add_argument("guide_file")
    writer.add_argument("--finished-ms", required=True)

    # Retain legacy metadata arguments; append now writes only the completion anchor.
    legacy = sub.add_parser("append", help="兼容入口，等同 write-anchor")
    legacy.add_argument("guide_file")
    legacy.add_argument("--finished-ms", required=True)
    for option in ("indexed-at", "mode", "output-path", "summary"):
        legacy.add_argument(f"--{option}", default="")
    for option in ("depth", "since-ms", "file-count", "duration-ms"):
        legacy.add_argument(f"--{option}", type=int, default=0)

    args = parser.parse_args()
    try:
        if args.cmd == "read-baseline":
            print(read_baseline_ms(args.guide_file))
        else:
            finished_ms = positive_ms(args.finished_ms)
            timestamp = display_time(finished_ms)
            write_anchor(args.guide_file, finished_ms)
            print(f"已写入完成锚点: {timestamp}")
    except (OSError, ValueError, OverflowError) as error:
        print(f"[ERROR] {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
