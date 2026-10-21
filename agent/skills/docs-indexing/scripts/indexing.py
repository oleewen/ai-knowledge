#!/usr/bin/env python3
"""Enumerate candidate files; optionally update only the scan runtime block."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import sys
import time

from indexing_log import (
    append_block,
    atomic_write,
    display_time,
    positive_ms,
    read_baseline_ms,
    read_guide,
    unfenced_matches,
)


EXCLUDED_DIRS = {"node_modules", "target", "build"}
EXCLUDED_FILES = {"viz.html", ".DS_Store"}
EXCLUDED_SUFFIXES = {".log", ".class", ".jar"}
DEPTH_ONE = {".md", ".yml", ".yaml", ".json", ".sh"}
DEPTH_TWO = DEPTH_ONE | {".py", ".js", ".ts", ".tsx", ".java"}
RE_RUNTIME_MARKER = re.compile(rb"<!--\s*docs-indexing:(begin|end)\s*-->")
RE_PROTECTED_MARKER = re.compile(
    rb"<!--\s*(okf|docs-build(?::[\w-]+)*):(begin|end)\s*-->"
)


def repository_path(repo: Path, path: Path) -> Path:
    candidate = path if path.is_absolute() else repo / path
    if not candidate.resolve().is_relative_to(repo):
        raise ValueError(f"路径须位于仓库内: {path}")
    # Resolve parent aliases and dot segments, but retain the leaf to reject symlink writes.
    return candidate.parent.resolve() / candidate.name


def collect_candidates(root: Path, depth: int) -> list[Path]:
    """Walk regular files only; scandir errors propagate to the command exit code."""
    if root.is_symlink() or not root.is_dir():
        raise ValueError(f"扫描根不存在、不是目录或为软链: {root}")
    candidates = []
    pending = [root]
    while pending:
        directory = pending.pop()
        with os.scandir(directory) as entries:
            for entry in sorted(entries, key=lambda item: item.name):
                if entry.is_symlink() or entry.name.startswith("."):
                    continue
                path = Path(entry.path)
                if entry.is_dir(follow_symlinks=False):
                    if entry.name not in EXCLUDED_DIRS:
                        pending.append(path)
                elif entry.is_file(follow_symlinks=False):
                    if entry.name in EXCLUDED_FILES or path.suffix in EXCLUDED_SUFFIXES:
                        continue
                    extensions = DEPTH_ONE if depth == 1 else DEPTH_TWO
                    if depth == 3 or path.suffix in extensions:
                        candidates.append(path.relative_to(root))
    return sorted(candidates)


def markdown_code(value: str) -> str:
    """Keep unusual path characters from breaking generated Markdown tables."""
    value = value.replace("\r", "\\r").replace("\n", "\\n").replace("|", "&#124;")
    fence = "`" * (max((len(run) for run in re.findall(r"`+", value)), default=0) + 1)
    return f"{fence} {value} {fence}" if "`" in value else f"{fence}{value}{fence}"


def runtime_report(args, repo: Path, output: Path, candidates: list[Path], baseline: int) -> str:
    scanned_ms = time.time_ns() // 1_000_000
    directories = sorted({str(path.parent) for path in candidates})
    rows = [
        f"### 扫描运行（{display_time(scanned_ms)}）",
        "", "| 项 | 值 |", "|----|----|",
        f"| mode / depth | `{args.mode} / {args.depth}` |",
        f"| 文件总数 | `{len(candidates)}` |",
        f"| 输出路径 | {markdown_code('./' + str(output.relative_to(repo)))} |",
        "| 扫描含义 | 候选文件统计；未读取业务内容，未生成九章 |",
    ]
    if args.mode == "incremental":
        rows.extend((
            f"| 增量基线 | `{baseline}`；{display_time(baseline)} |",
            "| 增量限制 | 仅校验基线，未按 since 过滤；Git 变更合并由 Agent 完成 |",
        ))
    rows.extend(("", "<details>", "<summary>扫描目录</summary>", ""))
    rows.extend(f"- {markdown_code(path)}" for path in directories)
    if not directories:
        rows.append("- 无")
    rows.extend(("", "</details>"))
    return "\n".join(rows)


def rewrite_runtime(output: Path, report: str) -> None:
    if output.is_symlink():
        raise ValueError(f"拒绝写入输出软链: {output}")
    original = read_guide(output) if output.exists() else b""
    block = ("<!-- docs-indexing:begin -->\n" + report + "\n<!-- docs-indexing:end -->").encode("utf-8")
    runtime = list(unfenced_matches(original, RE_RUNTIME_MARKER))
    if runtime and [match.group(1) for match in runtime] != [b"begin", b"end"]:
        raise ValueError("运行块标记须为唯一一对 begin/end，拒绝孤立、嵌套或多对标记")

    # Check ownership before replacing any bytes. Malformed protected blocks are ambiguous.
    protected = []
    stack = []
    for match in unfenced_matches(original, RE_PROTECTED_MARKER):
        owner, kind = match.groups()
        if kind == b"begin":
            stack.append((owner, match.start()))
        elif not stack or stack[-1][0] != owner:
            raise ValueError("OKF/docs-build 保护块标记未正确配对，拒绝更新运行块")
        else:
            _, start = stack.pop()
            protected.append((start, match.end()))
    if stack:
        raise ValueError("OKF/docs-build 保护块未闭合，拒绝更新运行块")

    if runtime:
        start, end = runtime[0].start(), runtime[1].end()
        if any(start < protected_end and protected_start < end
               for protected_start, protected_end in protected):
            raise ValueError("运行块与 OKF/docs-build 保护块重叠，拒绝更新")
        updated = original[:start] + block + original[end:]
    else:
        updated = append_block(original, block)
    output.parent.mkdir(parents=True, exist_ok=True)
    atomic_write(output, updated)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, required=True)
    parser.add_argument("--doc-root", type=Path, required=True)
    parser.add_argument("--mode", choices=("full", "incremental"), required=True)
    parser.add_argument("--depth", type=int, choices=(1, 2, 3), required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--since")
    parser.add_argument("--rewrite", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    try:
        repo = args.repo.resolve(strict=True)
        root = repository_path(repo, args.doc_root)
        output = repository_path(repo, args.output)
        if output.name != "INDEX-GUIDE.md":
            raise ValueError("输出文件名固定为 INDEX-GUIDE.md")
        baseline = positive_ms(args.since) if args.since is not None else 0
        if args.mode == "incremental":
            if args.since is None:
                baseline = read_baseline_ms(output)
            if not baseline:
                raise ValueError("incremental 需要有效基线：目标指南首条 HTML 锚点或 --since；可显式选择 full")
        candidates = collect_candidates(root, args.depth)
        report = runtime_report(args, repo, output, candidates, baseline)
        if args.rewrite and not args.dry_run:
            rewrite_runtime(output, report)
            action = "已更新扫描运行块；完成锚点未写入。"
        else:
            action = "dry-run: 只读预览。" if args.dry_run else "scan-only: 只读扫描。"
        print(report)
        print(f"\n{action}")
    except (OSError, ValueError, OverflowError) as error:
        print(f"[ERROR] {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
