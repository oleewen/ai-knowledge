#!/usr/bin/env python3
"""visualize.py 单元测试。"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "agent" / "skills" / "docs-okf" / "scripts"))
import visualize  # noqa: E402


def test_generate_visualization_html():
    with tempfile.TemporaryDirectory() as tmp:
        bundle = Path(tmp)
        concept_a = bundle / "knowledge" / "business" / "BD-EXAMPLE.md"
        concept_b = bundle / "knowledge" / "application" / "MS-EXAMPLE.md"
        concept_a.parent.mkdir(parents=True)
        concept_b.parent.mkdir(parents=True)
        concept_a.write_text(
            "---\n"
            "type: Business Domain\n"
            "title: 示例业务域\n"
            "description: 演示\n"
            "tags: [business, BD]\n"
            "---\n"
            "链接到 [MS-EXAMPLE](/knowledge/application/MS-EXAMPLE.md)\n",
            encoding="utf-8",
        )
        concept_b.write_text(
            "---\n"
            "type: Microservice\n"
            "title: 示例微服务\n"
            "description: null\n"
            "tags: [application]\n"
            "---\n"
            "# Body\n",
            encoding="utf-8",
        )
        out = Path(tmp) / "viz-test.html"
        visualize.generate_visualization(bundle, out, "test OKF")
        assert out.is_file()
        text = out.read_text(encoding="utf-8")
        assert "cytoscape.min.js" in text
        assert '"concepts"' in text
        assert "knowledge/business/BD-EXAMPLE" in text
        assert "knowledge/application/MS-EXAMPLE" in text


def main() -> None:
    tests = [test_generate_visualization_html]
    for fn in tests:
        fn()
        print(f"PASS {fn.__name__}")
    print(f"\nAll {len(tests)} tests passed.")


if __name__ == "__main__":
    main()
