#!/usr/bin/env python3
"""为 bundle 治理 Markdown 注入 OKF YAML frontmatter。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Any, Dict, Iterator, Optional, Tuple

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402

EXACT_GOVERNANCE: Dict[str, Dict[str, Any]] = {
    "README.md": {"type": "Documentation Root", "tags": ["governance"]},
    "README-s.md": {"type": "Documentation"},
    "README-c.md": {"type": "Documentation"},
    "index.md": {"type": "Agent Index Guide"},
    "DESIGN.md": {"type": "Design Document"},
    "CONTRIBUTING.md": {"type": "Contributing Guide"},
    "knowledge/README.md": {"type": "Documentation"},
    "knowledge/knowledge-meta.md": {"type": "Perspective Tree Meta"},
    # knowledge/index.md：OKF §6 保留名，禁止注入 frontmatter（由 generate_knowledge_index 生成）
    "knowledge/technical-debt.md": {"type": "Documentation", "tags": ["technical-debt"]},
    "solutions/README.md": {"type": "Documentation"},
    "analysis/README.md": {"type": "Documentation"},
    "requirements/README.md": {"type": "Documentation"},
    "adr/README.md": {"type": "Documentation"},
    "changelogs/README.md": {"type": "Documentation"},
    "changelogs/CHANGE-LOG.md": {"type": "Change Log"},
    "changelogs/INDEXING-LOG.md": {"type": "Indexing Log"},
    "docs-meta.md": {"type": "Directory Meta"},
    "application-APPNAME/README.md": {"type": "Documentation", "tags": ["federation"]},
    "requirements/REQUIREMENT-EXAMPLE/README.md": {"type": "Requirement Package"},
}

PERSPECTIVE_META_RE = re.compile(r"^knowledge/[^/]+/[^/]+-meta\.md$")
PERSPECTIVE_README_RE = re.compile(r"^knowledge/[^/]+/README\.md$")
ARCHITECTURE_CHAPTER_RE = re.compile(
    r"^knowledge/(?:business|product|application|data|technical)/[a-z][a-z0-9-]*\.md$"
)
OVERVIEW_BUFFER_RE = re.compile(r"^knowledge/overview/[^/]+\.md$")
TITLE_RE = re.compile(r"^#\s+(.+)$", re.MULTILINE)


def _repo_root() -> Path:
    return okf_lib.find_repo_root(Path(__file__).resolve())


def classify_governance(relpath: str) -> Optional[Dict[str, Any]]:
    """返回治理文档 frontmatter 字段（不含 title）；非治理文档返回 None。"""
    posix = relpath.replace("\\", "/")
    if posix in EXACT_GOVERNANCE:
        return dict(EXACT_GOVERNANCE[posix])
    if PERSPECTIVE_META_RE.match(posix):
        return {"type": "Perspective Meta"}
    if PERSPECTIVE_README_RE.match(posix):
        return {"type": "Documentation"}
    if OVERVIEW_BUFFER_RE.match(posix):
        return {"type": "Architecture Overview Buffer", "tags": ["overview", "distill"]}
    if ARCHITECTURE_CHAPTER_RE.match(posix):
        return {"type": "Architecture Chapter", "tags": ["architecture", "chapter"]}
    return None


def is_entity_concept(relpath: str) -> bool:
    """knowledge/ 下非治理的 concept 实体文件（通常已有 frontmatter）。"""
    posix = relpath.replace("\\", "/")
    if not posix.startswith("knowledge/") or not posix.endswith(".md"):
        return False
    if classify_governance(posix) is not None:
        return False
    return True


def should_skip_injection(relpath: str, text: str) -> bool:
    name = Path(relpath).name
    if name in okf_lib.OKF_RESERVED_NAMES:
        return True
    if text.lstrip().startswith("---"):
        return True
    if is_entity_concept(relpath):
        return True
    return False


def extract_title(text: str, fallback: str) -> str:
    m = TITLE_RE.search(text)
    if m:
        return m.group(1).strip()
    return fallback


def build_frontmatter_meta(relpath: str, text: str) -> Optional[Dict[str, Any]]:
    base = classify_governance(relpath)
    if base is None:
        return None
    meta = dict(base)
    stem = Path(relpath).stem
    meta["title"] = extract_title(text, stem)
    return meta


def inject_file(relpath: str, text: str) -> Optional[str]:
    if should_skip_injection(relpath, text):
        return None
    meta = build_frontmatter_meta(relpath, text)
    if meta is None:
        return None
    body = text
    if text.lstrip().startswith("---"):
        _, body = okf_lib.parse_frontmatter(text)
    return okf_lib.format_frontmatter(meta) + body.lstrip("\n")


def iter_markdown_files(bundle_root: Path) -> Iterator[Path]:
    for path in sorted(bundle_root.rglob("*.md")):
        if path.is_file():
            yield path


def run_inject(bundle: str, dry_run: bool = False) -> Tuple[int, int, int]:
    bundle_root = (_repo_root() / bundle).resolve()
    if not bundle_root.is_dir():
        raise SystemExit(f"bundle 不存在: {bundle_root}")

    injected = skipped = unchanged = 0
    for path in iter_markdown_files(bundle_root):
        relpath = path.relative_to(bundle_root).as_posix()
        text = path.read_text(encoding="utf-8")
        if should_skip_injection(relpath, text):
            skipped += 1
            continue
        new_text = inject_file(relpath, text)
        if new_text is None:
            unchanged += 1
            continue
        if new_text == text:
            unchanged += 1
            continue
        injected += 1
        if dry_run:
            print(f"[dry-run] inject: {relpath}")
        else:
            path.write_text(new_text, encoding="utf-8")
            print(f"injected: {relpath}")
    return injected, skipped, unchanged


def main() -> None:
    parser = argparse.ArgumentParser(description="为 bundle 治理 Markdown 注入 OKF frontmatter")
    parser.add_argument(
        "--bundle",
        required=True,
        help="bundle 路径（相对仓库根，如 application）",
    )
    parser.add_argument("--dry-run", action="store_true", help="仅打印将注入的文件")
    args = parser.parse_args()
    injected, skipped, unchanged = run_inject(args.bundle, dry_run=args.dry_run)
    print(f"done: injected={injected} skipped={skipped} unchanged={unchanged}")


if __name__ == "__main__":
    main()
