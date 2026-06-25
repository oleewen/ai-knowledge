#!/usr/bin/env python3
"""为 OKF bundle 目录生成 index.md（bundle 根仅更新 OKF 区块）。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _bundle_root(repo: Path, bundle: str) -> Path:
    return (repo / bundle).resolve()


def _is_bundle_root(bundle_root: Path, directory: Path) -> bool:
    return directory.resolve() == bundle_root.resolve()


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
        entries.append((path.name, f"{path.name}/README.md", _subdir_description(path)))
    return entries


def _bullet(title: str, link: str, desc: str) -> str:
    if desc:
        return f"* [{title}]({link}) - {desc}"
    return f"* [{title}]({link})"


SECTION_TITLE_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
_RE_SENTINEL_LINE = re.compile(
    r"^\s*<!--\s*(okf:begin|okf:end|docs-indexing:begin|docs-indexing:end)\s*-->\s*$"
)


def _extract_section(text: str, title: str) -> str:
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        m = SECTION_TITLE_RE.match(lines[i])
        if not m:
            i += 1
            continue
        level = len(m.group(1))
        heading = m.group(2).strip()
        if heading != title:
            i += 1
            continue
        i += 1
        start = i
        while i < len(lines):
            m2 = SECTION_TITLE_RE.match(lines[i])
            if m2 and len(m2.group(1)) <= level:
                break
            i += 1
        content = "\n".join(lines[start:i]).strip()
        return content
    return ""

def _sanitize_preserved_section(content: str) -> str:
    if not content:
        return ""
    lines = [ln for ln in content.splitlines() if not _RE_SENTINEL_LINE.match(ln)]
    return "\n".join(lines).strip()


def _render_related_indexes(directory: Path) -> str:
    parent = directory.parent
    lines: List[str] = []
    if (parent / "index.md").exists():
        lines.append("- 上一级索引：[../index.md](../index.md)")
    if (parent / "README.md").exists():
        lines.append("- 上一级说明：[../README.md](../README.md)")
    if not lines:
        return "（暂无）"
    return "\n".join(lines)


def _render_directory_files(directory: Path) -> str:
    concept_files = {link for _, link, _ in _concept_entries(directory)}
    other: List[str] = []
    for path in sorted(directory.iterdir()):
        if not path.is_file():
            continue
        if path.name in {"index.md", "README.md"}:
            continue
        if path.name in concept_files:
            continue
        other.append(path.name)
    lines: List[str] = []
    concepts = _concept_entries(directory)
    if concepts:
        lines.extend(_bullet(title, link, desc) for title, link, desc in concepts)
    if other:
        if concepts:
            lines.append("")
        lines.extend(f"* [{name}]({name})" for name in other)
    if not lines:
        return "（无）"
    return "\n".join(lines)


def _render_subdirectories(directory: Path) -> str:
    subdirs = _subdir_entries(directory)
    if not subdirs:
        return "（无）"
    return "\n".join(_bullet(name, link, desc) for name, link, desc in subdirs)


def render_index_body(directory: Path) -> str:
    index_path = directory / "index.md"
    existing = {"阅读顺序": "", "关联索引": ""}
    if index_path.is_file():
        _, body = okf_lib.parse_frontmatter(index_path.read_text(encoding="utf-8"))
        existing["阅读顺序"] = _sanitize_preserved_section(_extract_section(body, "阅读顺序"))
        existing["关联索引"] = _sanitize_preserved_section(_extract_section(body, "关联索引"))

    lines = [f"# {directory.name}", "", "目录说明见 [README.md](README.md)。", ""]

    lines.append("## 子目录")
    lines.append("")
    lines.append(_render_subdirectories(directory))
    lines.append("")

    lines.append("## 目录文件")
    lines.append("")
    lines.append(_render_directory_files(directory))
    lines.append("")

    lines.append("## 阅读顺序")
    lines.append("")
    lines.append(existing["阅读顺序"] if existing["阅读顺序"] else "（待补充）")
    lines.append("")

    lines.append("## 关联索引")
    lines.append("")
    lines.append(existing["关联索引"] if existing["关联索引"] else _render_related_indexes(directory))
    lines.append("")
    return "\n".join(lines).rstrip() + "\n"

_RE_OKF_BLOCK = re.compile(
    r"<!--\s*okf:begin\s*-->.*?<!--\s*okf:end\s*-->",
    flags=re.DOTALL,
)


def _demote_headings(text: str) -> str:
    lines: List[str] = []
    for line in text.splitlines():
        m = re.match(r"^(#{1,6})\s+(.*)$", line)
        if m:
            level = min(len(m.group(1)) + 1, 6)
            lines.append("#" * level + " " + m.group(2))
        else:
            lines.append(line)
    return "\n".join(lines).rstrip() + "\n"


def _render_okf_root_block(directory: Path) -> str:
    body = render_index_body(directory)
    lines = body.splitlines()
    if lines and lines[0].startswith("# "):
        lines = lines[1:]
    body_wo_h1 = "\n".join(lines).lstrip("\n").rstrip() + "\n"
    demoted = _demote_headings(body_wo_h1)
    return "## OKF 渐进披露\n\n" + demoted


def _split_frontmatter(text: str) -> tuple[str, str]:
    if not text.lstrip().startswith("---"):
        return "", text
    lines = text.splitlines(keepends=True)
    start = None
    for i, line in enumerate(lines):
        if line.strip() == "---":
            start = i
            break
        if line.strip():
            return "", text
    if start is None:
        return "", text
    for j in range(start + 1, len(lines)):
        if lines[j].strip() == "---":
            fm = "".join(lines[: j + 1]).rstrip() + "\n"
            body = "".join(lines[j + 1 :]).lstrip("\n")
            return fm, body
    return "", text


def _upsert_okf_block_in_index(index_path: Path, okf_block: str) -> str:
    okf_block = okf_block.rstrip() + "\n"
    okf_wrapped = (
        "<!-- okf:begin -->\n" + okf_block + "<!-- okf:end -->\n"
    )
    existing = index_path.read_text(encoding="utf-8") if index_path.is_file() else ""
    fm, body = _split_frontmatter(existing)
    if _RE_OKF_BLOCK.search(body):
        body = _RE_OKF_BLOCK.sub(okf_wrapped, body, count=1)
    else:
        body = okf_wrapped + "\n" + body.lstrip("\n")
    return (fm + body).rstrip() + "\n"


def write_index(directory: Path, bundle_root: Path, dry_run: bool = False) -> bool:
    index_path = directory / "index.md"
    if _is_bundle_root(bundle_root, directory):
        okf_block = _render_okf_root_block(directory)
        merged = _upsert_okf_block_in_index(index_path, okf_block)
        if dry_run:
            return True
        index_path.write_text(merged, encoding="utf-8")
        return True

    existing_meta: Dict[str, object] = {}
    if index_path.is_file():
        existing_meta, _ = okf_lib.parse_frontmatter(index_path.read_text(encoding="utf-8"))
        if existing_meta:
            return True
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
            return [base] + sorted(p for p in base.rglob("*") if p.is_dir())
        return [base]
    if recursive:
        return [bundle_root] + sorted(p for p in bundle_root.rglob("*") if p.is_dir())
    return [bundle_root]


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="生成 OKF bundle 目录 index.md（bundle 根仅更新 OKF 区块）")
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
    print(f"{action} {written} index file(s) ({skipped} skipped)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
