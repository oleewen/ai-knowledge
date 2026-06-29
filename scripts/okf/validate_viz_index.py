#!/usr/bin/env python3
"""校验 OKF index/viz 产物存在性与轻量一致性。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402

ROOT_INDEX_MARKERS = ("<!-- okf:begin -->", "<!-- okf:end -->")
KNOWLEDGE_SECTION_MARKERS = ("## §1 ", "## 统一表头规范")
VIZ_MARKERS = ('"concepts"', '"edges"', "<html")
SKIP_VIZ_NAMES = frozenset({"CHANGE-LOG.md", "INDEXING-LOG.md"})


def _error(msg: str) -> int:
    print(f"[ERROR] {msg}", file=sys.stderr)
    return 1


def _resolve_path(repo_root: Path, candidate: str) -> Path:
    path = Path(candidate)
    if path.is_absolute():
        return path.resolve()
    return (repo_root / path).resolve()


def validate(bundle_root: Path, viz_path: Path) -> int:
    bundle_root = bundle_root.resolve()
    knowledge_root = bundle_root / "knowledge"
    root_index = bundle_root / "index.md"
    knowledge_index = knowledge_root / "index.md"
    if not knowledge_root.is_dir():
        return _error(f"missing-knowledge-root: {knowledge_root}")
    if not root_index.is_file():
        return _error(f"missing-index: {root_index}")
    if not knowledge_index.is_file():
        return _error(f"missing-knowledge-index: {knowledge_index}")

    for path in sorted(knowledge_root.rglob("*")):
        if path.is_dir() and not (path / "index.md").is_file():
            return _error(f"missing-dir-index: {path / 'index.md'}")

    root_text = root_index.read_text(encoding="utf-8")
    if not all(marker in root_text for marker in ROOT_INDEX_MARKERS):
        return _error(f"missing-okf-block: {root_index}")

    knowledge_text = knowledge_index.read_text(encoding="utf-8")
    if not any(marker in knowledge_text for marker in KNOWLEDGE_SECTION_MARKERS):
        return _error(f"missing-knowledge-sections: {knowledge_index}")

    if not viz_path.is_file():
        return _error(f"missing-viz: {viz_path}")

    viz_text = viz_path.read_text(encoding="utf-8")
    if not viz_text.strip():
        return _error(f"viz-empty: {viz_path}")
    if not all(marker in viz_text for marker in VIZ_MARKERS):
        return _error(f"viz-missing-markers: {viz_path}")

    concept_count = sum(
        1 for path in okf_lib.scan_concepts(bundle_root) if path.name not in SKIP_VIZ_NAMES
    )
    embedded_count = len(re.findall(r'"knowledge/[^"]+"\s*:', viz_text))
    if concept_count == 0:
        return _error(f"viz-bundle-mismatch: no concepts under {bundle_root}")
    if embedded_count == 0:
        return _error(f"viz-bundle-mismatch: no embedded concepts in {viz_path}")

    print(
        f"OK: bundle={bundle_root} viz={viz_path} concepts={concept_count} embedded={embedded_count}"
    )
    return 0


def main() -> None:
    parser = argparse.ArgumentParser(description="校验 OKF index/viz 产物")
    parser.add_argument(
        "--bundle",
        required=True,
        help="bundle 路径（相对仓库根，如 application，或绝对路径）",
    )
    parser.add_argument(
        "--viz",
        required=True,
        help="viz.html 路径（相对仓库根，如 application/viz.html，或绝对路径）",
    )
    parser.add_argument(
        "--repo",
        default=None,
        help="仓库根目录（默认：脚本上两级）",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo).resolve() if args.repo else Path(__file__).resolve().parents[2]
    bundle_root = _resolve_path(repo_root, args.bundle)
    viz_path = _resolve_path(repo_root, args.viz)
    raise SystemExit(validate(bundle_root, viz_path))


if __name__ == "__main__":
    main()
