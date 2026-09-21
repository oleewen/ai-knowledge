#!/usr/bin/env python3
"""generate_index / generate_knowledge_index 单元测试。"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
# docs-build 为 INDEX-GUIDE 第五章实体表权威实现；docs-okf 脚本仅 generate_index / okf_lib
sys.path.insert(0, str(ROOT / "agent" / "skills" / "docs-okf" / "scripts"))
sys.path.insert(0, str(ROOT / "agent" / "skills" / "docs-build" / "scripts"))
import generate_index  # noqa: E402
import generate_knowledge_index  # noqa: E402
import okf_lib  # noqa: E402

assert hasattr(generate_knowledge_index, "render_knowledge_index"), (
    "须从 docs-build/scripts 加载 generate_knowledge_index"
)


def test_render_index_lists_concepts_and_subdirs():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        concept = root / "BD-EXAMPLE.md"
        concept.write_text(
            "---\n"
            "title: 示例业务域\n"
            "description: 演示用\n"
            "id: BD-EXAMPLE\n"
            "---\n"
            "# Body\n",
            encoding="utf-8",
        )
        sub = root / "BSD-EXAMPLE"
        sub.mkdir()
        (sub / "README.md").write_text(
            "---\ntype: Documentation\ntitle: BSD-EXAMPLE\n---\n# BSD-EXAMPLE\n\n子域描述\n",
            encoding="utf-8",
        )
        (sub / "BSD-EXAMPLE.md").write_text(
            "---\n"
            "title: 示例子域\n"
            "description: 子域描述\n"
            "id: BSD-EXAMPLE\n"
            "---\n",
            encoding="utf-8",
        )

        body = generate_index.render_index_body(root)
        assert "## 子目录" in body
        assert "## 目录文件" in body
        assert "## 阅读顺序" in body
        assert "## 关联索引" in body
        assert "* [示例业务域](BD-EXAMPLE.md) - 演示用" in body
        assert "* [BSD-EXAMPLE](BSD-EXAMPLE/README.md)" in body
        assert "子域描述" in body


def test_preserve_bundle_root_okf_version():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        index_path = root / "index.md"
        index_path.write_text(
            '---\nokf_version: "0.1"\n---\n# Root\n',
            encoding="utf-8",
        )
        assert generate_index.write_index(root, root)
        written = index_path.read_text(encoding="utf-8")
        meta, body = okf_lib.parse_frontmatter(written)
        assert meta["okf_version"] == "0.1"
        assert body.lstrip().startswith("<!-- okf:begin -->")
        assert "## OKF 渐进披露" in body
        assert "# Root" in body


def test_knowledge_index_id_and_evidence():
    with tempfile.TemporaryDirectory() as tmp:
        bundle = Path(tmp)
        concept_path = bundle / "knowledge" / "business" / "BD-EXAMPLE.md"
        concept_path.parent.mkdir(parents=True)
        concept_path.write_text(
            "---\n"
            "type: Business Domain\n"
            "title: 示例业务域\n"
            "id: BD-EXAMPLE\n"
            "perspective: business\n"
            "hierarchy: BD\n"
            "---\n",
            encoding="utf-8",
        )
        rendered = generate_knowledge_index.render_knowledge_index(bundle)
        assert "### 统一表头规范" in rendered
        assert "| BD | BD-EXAMPLE |" in rendered
        assert "`business/BD-EXAMPLE.md`" in rendered
        assert not rendered.startswith("---")


def test_patch_index_guide_chapter_five():
    existing = (
        "# G\n\n## 四、模块依赖\n\nx\n\n## 五、详细索引\n\nold\n\n## 六、API / 字典边界\n\ny\n"
    )
    block = (
        generate_knowledge_index.ENTITY_BEGIN
        + "\npatched-body\n"
        + generate_knowledge_index.ENTITY_END
        + "\n"
    )
    out = generate_knowledge_index.patch_index_guide(existing, block)
    assert generate_knowledge_index.ENTITY_BEGIN in out
    assert "patched-body" in out
    assert "## 六、API / 字典边界" in out
    assert "old" not in out
    again = generate_knowledge_index.patch_index_guide(
        out, block.replace("patched-body", "second")
    )
    assert "second" in again
    assert again.count(generate_knowledge_index.ENTITY_BEGIN) == 1


def test_system_knowledge_index_sections_and_mapping():
    with tempfile.TemporaryDirectory() as tmp:
        bundle = Path(tmp) / "system"
        (bundle / "knowledge").mkdir(parents=True)
        rendered = generate_knowledge_index.render_knowledge_index(
            bundle, bundle="system"
        )
        assert "§3 应用视角（application · SYS → APP → MS）" in rendered
        assert "§4 数据视角（data · MDG → DS → ENT）" in rendered
        assert "| PM-EXAMPLE | `product/PD-EXAMPLE/PM-EXAMPLE/` |" in rendered
        assert "| SYS-EXAMPLE | `application/SYS-EXAMPLE.md` |" in rendered
        assert "| DS-EXAMPLE | `data/DS-EXAMPLE/` |" in rendered
        assert "SYS → APP → MS → API" not in rendered


def test_application_knowledge_index_sections_and_mapping():
    with tempfile.TemporaryDirectory() as tmp:
        bundle = Path(tmp) / "application"
        (bundle / "knowledge").mkdir(parents=True)
        rendered = generate_knowledge_index.render_knowledge_index(
            bundle, bundle="application"
        )
        assert "§4 数据视角（data · MDG → DS → ENT → TBL）" in rendered
        assert "§5 技术视角（technical · TSD → MW → CMP）" in rendered
        assert "| API-EXAMPLE | `application/MS-EXAMPLE/API-EXAMPLE.md` |" in rendered
        assert "| TBL-EXAMPLE | `data/DS-EXAMPLE/TBL-EXAMPLE.md` |" in rendered
        assert "| MW-EXAMPLE | `technical/MW-EXAMPLE/` |" in rendered
        assert "business/BSD-EXAMPLE/" not in rendered
        assert "| PM-EXAMPLE |" not in rendered
        assert "| SYS-EXAMPLE |" not in rendered


def main() -> None:
    tests = [
        test_render_index_lists_concepts_and_subdirs,
        test_preserve_bundle_root_okf_version,
        test_knowledge_index_id_and_evidence,
        test_patch_index_guide_chapter_five,
        test_system_knowledge_index_sections_and_mapping,
        test_application_knowledge_index_sections_and_mapping,
    ]
    for fn in tests:
        fn()
        print(f"PASS {fn.__name__}")
    print(f"\nAll {len(tests)} tests passed.")


if __name__ == "__main__":
    main()
