#!/usr/bin/env python3
"""为 OKF bundle 目录生成 §6 index.md。"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import List, Optional, Tuple

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _bundle_root(repo: Path, bundle: str) -> Path:
    return (repo / bundle).resolve()


def _is_bundle_root(bundle_root: Path, directory: Path) -> bool:
    return directory.resolve() == bundle_root.resolve()


def _has_okf_version(index_path: Path) -> bool:
    if not index_path.is_file():
        return False
    meta, _ = okf_lib.parse_frontmatter(index_path.read_text(encoding="utf-8"))
    return "okf_version" in meta


def _concept_entries(directory: Path) -> List[Tuple[str, str, str]]:
    entries: List[Tuple[str, str, str]] = []
    for path in sorted(directory.iterdir()):
        if not path.is_file() or not okf_lib.is_concept_file(path):
            continue
        meta, _ = okf_lib.parse_frontmatter(path.read_text(encoding="utf-8"))
        if not meta.get("full_id"):
            continue
        title = str(meta.get("title") or path.stem)
        desc = meta.get("description")
        desc_text = "" if desc is None else str(desc)
        entries.append((title, path.name, desc_text))
    return entries


def _subdir_description(subdir: Path) -> str:
    index_path = subdir / "index.md"
    if index_path.is_file():
        meta, _ = okf_lib.parse_frontmatter(index_path.read_text(encoding="utf-8"))
        desc = meta.get("description") or meta.get("title")
        if desc is not None:
            return str(desc)
    anchor = subdir / f"{subdir.name}.md"
    if anchor.is_file():
        meta, _ = okf_lib.parse_frontmatter(anchor.read_text(encoding="utf-8"))
        desc = meta.get("description") or meta.get("title")
        if desc is not None:
            return str(desc)
    return ""


def _subdir_entries(directory: Path) -> List[Tuple[str, str, str]]:
    entries: List[Tuple[str, str, str]] = []
    for path in sorted(directory.iterdir()):
        if not path.is_dir() or path.name.startswith("."):
            continue
        entries.append((path.name, f"{path.name}/", _subdir_description(path)))
    return entries


def _bullet(title: str, link: str, desc: str) -> str:
    if desc:
        return f"* [{title}]({link}) - {desc}"
    return f"* [{title}]({link})"


def render_index_body(directory: Path) -> str:
    concepts = _concept_entries(directory)
    subdirs = _subdir_entries(directory)
    lines = [f"# {directory.name}", ""]
    if concepts:
        lines.append("## Concepts")
        lines.append("")
        lines.extend(_bullet(title, link, desc) for title, link, desc in concepts)
        lines.append("")
    if subdirs:
        lines.append("## Subdirectories")
        lines.append("")
        lines.extend(_bullet(name, link, desc) for name, link, desc in subdirs)
        lines.append("")
    if not concepts and not subdirs:
        lines.append("*(empty)*")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def write_index(directory: Path, bundle_root: Path, dry_run: bool = False) -> bool:
    index_path = directory / "index.md"
    if _is_bundle_root(bundle_root, directory) and _has_okf_version(index_path):
        return False
    body = render_index_body(directory)
    if dry_run:
        return True
    index_path.write_text(body, encoding="utf-8")
    return True


def collect_directories(
    bundle_root: Path,
    target: Optional[Path],
    recursive: bool,
) -> List[Path]:
    if target is not None:
        base = target.resolve()
        if not base.is_dir():
            return []
        if recursive:
            return sorted(p for p in base.rglob("*") if p.is_dir())
        return [base]
    if recursive:
        return sorted(p for p in bundle_root.rglob("*") if p.is_dir())
    return [bundle_root]


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="生成 OKF bundle 目录 index.md")
    parser.add_argument("--bundle", required=True, help="bundle 名称，如 application")
    parser.add_argument(
        "--dir",
        default=None,
        help="目标目录（相对仓库根），如 application/knowledge/business",
    )
    parser.add_argument(
        "--recursive",
        action="store_true",
        help="递归处理 bundle 或 --dir 下全部子目录",
    )
    parser.add_argument("--dry-run", action="store_true", help="仅统计，不写文件")
    args = parser.parse_args(argv)

    repo = _repo_root()
    bundle_root = _bundle_root(repo, args.bundle)
    if not bundle_root.is_dir():
        print(f"error: bundle 不存在: {bundle_root}", file=sys.stderr)
        return 1

    target = (repo / args.dir).resolve() if args.dir else None
    if target is not None and not target.is_dir():
        print(f"error: 目录不存在: {target}", file=sys.stderr)
        return 1

    directories = collect_directories(bundle_root, target, args.recursive)
    written = 0
    skipped = 0
    for directory in directories:
        if write_index(directory, bundle_root, dry_run=args.dry_run):
            written += 1
        else:
            skipped += 1

    action = "would write" if args.dry_run else "wrote"
    print(f"{action} {written} index.md ({skipped} skipped)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
