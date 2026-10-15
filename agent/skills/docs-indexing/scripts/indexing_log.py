#!/usr/bin/env python3
# INDEX-GUIDE 增量锚点读写；见 references/indexing-log-spec.md

from __future__ import annotations

import argparse
import os
import re
import sys

RE_HTML_MS = re.compile(
    r"<!--\s*sdx-indexing:indexing_finished_ms=(\d+)\s*-->"
)
ANCHOR_FMT = "<!-- sdx-indexing:indexing_finished_ms={ms} -->"


def read_baseline_ms(path: str) -> int:
    """读 INDEX-GUIDE（或任意 md）内最后一处 HTML 锚点。失败返回 0。"""
    if not path or not os.path.isfile(path):
        return 0
    try:
        text = open(path, encoding="utf-8").read()
    except OSError:
        return 0
    mlist = RE_HTML_MS.findall(text)
    if mlist:
        return int(mlist[-1])
    return 0


def write_anchor(path: str, finished_ms: int) -> None:
    """写入或替换文内唯一增量锚点（不落盘独立 LOG）。"""
    if finished_ms <= 0:
        print("[ERROR] finished_ms 须为正整数", file=sys.stderr)
        sys.exit(1)
    marker = ANCHOR_FMT.format(ms=finished_ms)
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)
    try:
        original = open(path, encoding="utf-8").read() if os.path.isfile(path) else ""
    except OSError as e:
        print(f"[ERROR] 无法读 {path}: {e}", file=sys.stderr)
        sys.exit(1)

    matches = list(RE_HTML_MS.finditer(original))
    if matches:
        first = matches[0]
        head = original[: first.start()]
        tail = RE_HTML_MS.sub("", original[first.end() :])
        new_text = head + marker + tail
    elif original.strip():
        new_text = original.rstrip() + "\n\n" + marker + "\n"
    else:
        new_text = marker + "\n"

    if not new_text.endswith("\n"):
        new_text += "\n"
    with open(path, "w", encoding="utf-8") as f:
        f.write(new_text)


def main() -> None:
    p = argparse.ArgumentParser(description="INDEX-GUIDE 增量锚点读取与写入")
    sub = p.add_subparsers(dest="cmd", required=True)

    sb = sub.add_parser("read-baseline", help="输出基线 epoch ms 或 0")
    sb.add_argument("guide_file")

    sw = sub.add_parser("write-anchor", help="写入/更新 HTML 锚点")
    sw.add_argument("guide_file")
    sw.add_argument("--finished-ms", type=int, required=True)

    # 兼容旧调用名：append 仅写锚点（忽略表字段）
    sa = sub.add_parser("append", help="(兼容) 等同 write-anchor")
    sa.add_argument("guide_file")
    sa.add_argument("--finished-ms", type=int, required=True)
    sa.add_argument("--indexed-at", default="")
    sa.add_argument("--mode", default="")
    sa.add_argument("--depth", type=int, default=0)
    sa.add_argument("--since-ms", type=int, default=0)
    sa.add_argument("--output-path", default="")
    sa.add_argument("--file-count", type=int, default=0)
    sa.add_argument("--duration-ms", type=int, default=0)
    sa.add_argument("--summary", default="")

    args = p.parse_args()
    if args.cmd == "read-baseline":
        print(read_baseline_ms(args.guide_file))
        return
    if args.cmd in ("write-anchor", "append"):
        write_anchor(args.guide_file, args.finished_ms)
        return
    p.error("unknown command")


if __name__ == "__main__":
    main()
