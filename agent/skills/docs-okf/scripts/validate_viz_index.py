#!/usr/bin/env python3
"""校验 OKF index/viz 产物存在性与轻量一致性。"""

from __future__ import annotations

import argparse
from html.parser import HTMLParser
import json
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402
from artifact_checks import okf_block_span  # noqa: E402
from generate_knowledge_index import entity_block_span, ENTITY_BEGIN  # noqa: E402
from visualize import build_bundle_data  # noqa: E402

KNOWLEDGE_NAV_MARKERS = ("## 子目录", "## 目录文件")
KNOWLEDGE_ENTITY_MARKERS = (
    "### 视角入口",
    "knowledge/business/README.md",
    "knowledge/README.md",
)
VIZ_MARKERS = ('"concepts"', '"edges"', "<html")


class BundleDataParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=False)
        self.payloads = []
        self.active = False

    def handle_starttag(self, tag, attrs):
        if tag == "script" and ("id", "okf-bundle-data") in attrs:
            for name in ("id", "type"):
                if sum(key == name for key, _ in attrs) > 1:
                    raise ValueError(f"duplicate viz data attribute: {name}")
        attrs = dict(attrs)
        if tag == "script" and attrs.get("id") == "okf-bundle-data":
            if attrs.get("type") != "application/json":
                raise ValueError("viz data script must use application/json")
            self.payloads.append("")
            self.active = True

    def handle_data(self, data):
        if self.active:
            self.payloads[-1] += data

    def handle_endtag(self, tag):
        if tag == "script":
            self.active = False


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def embedded_bundle(text: str) -> dict:
    parser = BundleDataParser()
    parser.feed(text)
    if len(parser.payloads) != 1 or parser.active:
        raise ValueError("viz must contain one closed okf-bundle-data script")
    value = json.loads(parser.payloads[0], object_pairs_hook=unique_object)
    if not isinstance(value, dict) or not isinstance(value.get("concepts"), dict) or not isinstance(value.get("edges"), list):
        raise ValueError("viz concepts/edges schema is invalid")
    return value


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
    knowledge_nav = knowledge_root / "index.md"
    root_guide = bundle_root / "INDEX-GUIDE.md"
    if not knowledge_root.is_dir():
        return _error(f"missing-knowledge-root: {knowledge_root}")
    if not root_index.is_file():
        return _error(f"missing-index: {root_index}")
    if not knowledge_nav.is_file():
        return _error(f"missing-knowledge-nav: {knowledge_nav}")
    if not root_guide.is_file():
        return _error(f"missing-index-guide: {root_guide}")

    for path in okf_lib.iter_bundle_directories(knowledge_root):
        if not (path / "index.md").is_file():
            return _error(f"missing-dir-index: {path / 'index.md'}")

    root_text = root_index.read_text(encoding="utf-8")
    try:
        root_span = okf_block_span(root_text)
    except ValueError as exc:
        return _error(str(exc))
    if root_span is None:
        return _error(f"missing-okf-block: {root_index}")

    nav_text = knowledge_nav.read_text(encoding="utf-8")
    if not any(marker in nav_text for marker in KNOWLEDGE_NAV_MARKERS):
        return _error(f"missing-knowledge-nav-sections: {knowledge_nav}")

    guide_text = root_guide.read_text(encoding="utf-8")
    try:
        span = entity_block_span(guide_text)
    except ValueError as exc:
        return _error(f"invalid-entity-index-block: {exc}")
    if span is None or not guide_text[span[0]:span[1]].startswith(ENTITY_BEGIN):
        return _error(f"missing-entity-index-block: {root_guide}")
    if not any(marker in guide_text[span[0]:span[1]] for marker in KNOWLEDGE_ENTITY_MARKERS):
        return _error(f"missing-knowledge-entity-sections: {root_guide}")

    if not viz_path.is_file():
        return _error(f"missing-viz: {viz_path}")

    viz_text = viz_path.read_text(encoding="utf-8")
    if not viz_text.strip():
        return _error(f"viz-empty: {viz_path}")
    if not all(marker in viz_text for marker in VIZ_MARKERS):
        return _error(f"viz-missing-markers: {viz_path}")

    try:
        embedded = embedded_bundle(viz_text)
        expected = build_bundle_data(bundle_root, "validation")
    except (OSError, ValueError) as exc:
        return _error(f"viz-invalid-data: {exc}")
    if embedded["concepts"] != expected["concepts"] or embedded["edges"] != expected["edges"]:
        return _error(f"viz-bundle-mismatch: concepts or edges differ from current bundle: {viz_path}")
    concept_count = len(expected["concepts"])
    embedded_count = len(embedded["concepts"])

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

    repo_root = Path(args.repo).resolve() if args.repo else okf_lib.find_repo_root(Path(__file__).resolve())
    bundle_root = _resolve_path(repo_root, args.bundle)
    viz_path = _resolve_path(repo_root, args.viz)
    raise SystemExit(validate(bundle_root, viz_path))


if __name__ == "__main__":
    main()
