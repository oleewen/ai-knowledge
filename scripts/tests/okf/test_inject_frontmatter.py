#!/usr/bin/env python3
"""inject_frontmatter 单元测试。"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "okf"))
import inject_frontmatter  # noqa: E402
import okf_lib  # noqa: E402


def test_classify_governance_readme():
    meta = inject_frontmatter.classify_governance("README.md")
    assert meta == {"type": "Documentation Root", "tags": ["governance"]}


def test_classify_perspective_meta():
    meta = inject_frontmatter.classify_governance("knowledge/business/business-meta.md")
    assert meta == {"type": "Perspective Meta"}


def test_skip_entity_concept():
    assert inject_frontmatter.is_entity_concept("knowledge/business/BD-EXAMPLE.md")
    assert not inject_frontmatter.is_entity_concept("knowledge/knowledge-meta.md")


def test_inject_design_md():
    body = "# 应用知识文档库 — 设计方案摘录\n\n正文\n"
    result = inject_frontmatter.inject_file("DESIGN.md", body)
    assert result is not None
    meta, rest = okf_lib.parse_frontmatter(result)
    assert meta["type"] == "Design Document"
    assert meta["title"] == "应用知识文档库 — 设计方案摘录"
    assert rest.strip().startswith("# 应用知识文档库")


def test_skip_existing_frontmatter():
    text = "---\ntype: Business Domain\n---\n# Body\n"
    assert inject_frontmatter.inject_file("knowledge/business/BD-EXAMPLE.md", text) is None


def test_should_skip_reserved_and_entity():
    assert inject_frontmatter.should_skip_injection("index.md", "# Index\n")
    assert inject_frontmatter.should_skip_injection("changelogs/log.md", "# Log\n")
    assert inject_frontmatter.should_skip_injection(
        "knowledge/business/BD-EXAMPLE.md",
        "# concept\n",
    )
    assert not inject_frontmatter.should_skip_injection("README.md", "# App Root\n")


def test_inject_readme_governance_tag():
    body = "# application — 应用知识库\n"
    result = inject_frontmatter.inject_file("README.md", body)
    assert result is not None
    meta, _ = okf_lib.parse_frontmatter(result)
    assert meta["type"] == "Documentation Root"
    assert meta["tags"] == ["governance"]


def main() -> None:
    tests = [
        test_classify_governance_readme,
        test_classify_perspective_meta,
        test_skip_entity_concept,
        test_inject_design_md,
        test_skip_existing_frontmatter,
        test_should_skip_reserved_and_entity,
        test_inject_readme_governance_tag,
    ]
    for fn in tests:
        fn()
        print(f"PASS {fn.__name__}")
    print(f"\nAll {len(tests)} tests passed.")


if __name__ == "__main__":
    main()
