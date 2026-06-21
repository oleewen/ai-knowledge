#!/usr/bin/env python3
"""generate_index / generate_knowledge_index 单元测试。"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "okf"))
import generate_index  # noqa: E402
import generate_knowledge_index  # noqa: E402
import okf_lib  # noqa: E402


def test_render_index_lists_concepts_and_subdirs():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        concept = root / "BD-EXAMPLE.md"
        concept.write_text(
            "---\n"
            "title: 示例业务域\n"
            "description: 演示用\n"
            "full_id: BD-EXAMPLE\n"
            "---\n"
            "# Body\n",
            encoding="utf-8",
        )
        sub = root / "BSD-EXAMPLE"
        sub.mkdir()
        (sub / "BSD-EXAMPLE.md").write_text(
            "---\n"
            "title: 示例子域\n"
            "description: 子域描述\n"
            "full_id: BSD-EXAMPLE\n"
            "---\n",
            encoding="utf-8",
        )

        body = generate_index.render_index_body(root)
        assert "* [示例业务域](BD-EXAMPLE.md) - 演示用" in body
        assert "* [BSD-EXAMPLE](BSD-EXAMPLE/) - 子域描述" in body


def test_skip_bundle_root_with_okf_version():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        index_path = root / "index.md"
        index_path.write_text(
            '---\nokf_version: "0.1"\n---\n# Root\n',
            encoding="utf-8",
        )
        assert not generate_index.write_index(root, root)


def test_knowledge_index_id_suffix_and_evidence():
    with tempfile.TemporaryDirectory() as tmp:
        bundle = Path(tmp)
        concept_path = bundle / "knowledge" / "business" / "BD-EXAMPLE.md"
        concept_path.parent.mkdir(parents=True)
        concept_path.write_text(
            "---\n"
            "type: Business Domain\n"
            "title: 示例业务域\n"
            "full_id: BD-EXAMPLE\n"
            "perspective: business\n"
            "hierarchy: BD\n"
            "---\n",
            encoding="utf-8",
        )
        rendered = generate_knowledge_index.render_knowledge_index(bundle)
        assert "| BD | EXAMPLE |" in rendered
        assert "`business/BD-EXAMPLE.md`" in rendered


def main() -> None:
    tests = [
        test_render_index_lists_concepts_and_subdirs,
        test_skip_bundle_root_with_okf_version,
        test_knowledge_index_id_suffix_and_evidence,
    ]
    for fn in tests:
        fn()
        print(f"PASS {fn.__name__}")
    print(f"\nAll {len(tests)} tests passed.")


if __name__ == "__main__":
    main()
