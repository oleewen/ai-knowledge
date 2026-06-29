#!/usr/bin/env python3
"""validate_viz_index.py 单元测试。"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "okf"))
import validate_viz_index  # noqa: E402


def test_validate_viz_index_passes_for_complete_bundle() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        repo = Path(tmp)
        bundle = repo / "application"
        biz_dir = bundle / "knowledge" / "business"
        biz_dir.mkdir(parents=True)

        (bundle / "index.md").write_text(
            "---\nokf_version: \"0.1\"\n---\n# Root\n\n<!-- okf:begin -->\n## OKF 渐进披露\n<!-- okf:end -->\n",
            encoding="utf-8",
        )
        (bundle / "knowledge" / "index.md").write_text(
            "# 知识索引\n\n## §1 业务视角\n",
            encoding="utf-8",
        )
        (biz_dir / "index.md").write_text("# business\n", encoding="utf-8")
        (biz_dir / "BD-EXAMPLE.md").write_text(
            "---\n"
            "type: Business Domain\n"
            "title: 示例业务域\n"
            "description: 演示\n"
            "tags: [business, BD]\n"
            "timestamp: 2026-06-26T00:00:00Z\n"
            "full_id: BD-EXAMPLE\n"
            "perspective: business\n"
            "hierarchy: BD\n"
            "parent_id: null\n"
            "layer_scope: application\n"
            "---\n"
            "## 关系\n",
            encoding="utf-8",
        )

        viz = bundle / "viz.html"
        viz.write_text(
            "<html><head><title>application OKF</title></head>"
            "<body><script>"
            'window.__OKF_DATA__ = {"name": "application OKF", "concepts": {"knowledge/business/BD-EXAMPLE": {}}, "edges": []};'
            "</script></body></html>",
            encoding="utf-8",
        )

        assert validate_viz_index.validate(bundle, viz) == 0


def test_validate_viz_index_fails_without_okf_block() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        repo = Path(tmp)
        bundle = repo / "application"
        biz_dir = bundle / "knowledge" / "business"
        biz_dir.mkdir(parents=True)

        (bundle / "index.md").write_text("# Root\n", encoding="utf-8")
        (bundle / "knowledge" / "index.md").write_text(
            "# 知识索引\n\n## §1 业务视角\n",
            encoding="utf-8",
        )
        (biz_dir / "index.md").write_text("# business\n", encoding="utf-8")
        (biz_dir / "BD-EXAMPLE.md").write_text(
            "---\n"
            "type: Business Domain\n"
            "title: 示例业务域\n"
            "description: 演示\n"
            "tags: [business, BD]\n"
            "timestamp: 2026-06-26T00:00:00Z\n"
            "full_id: BD-EXAMPLE\n"
            "perspective: business\n"
            "hierarchy: BD\n"
            "parent_id: null\n"
            "layer_scope: application\n"
            "---\n"
            "## 关系\n",
            encoding="utf-8",
        )

        viz = bundle / "viz.html"
        viz.write_text(
            "<html><body>\"concepts\" \"edges\"</body></html>",
            encoding="utf-8",
        )

        assert validate_viz_index.validate(bundle, viz) == 1


def main() -> None:
    tests = [
        test_validate_viz_index_passes_for_complete_bundle,
        test_validate_viz_index_fails_without_okf_block,
    ]
    for fn in tests:
        fn()
        print(f"PASS {fn.__name__}")
    print(f"\nAll {len(tests)} tests passed.")


if __name__ == "__main__":
    main()
