#!/usr/bin/env python3
from __future__ import annotations

import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "agent" / "skills" / "docs-okf" / "scripts"))
import validate_bundle  # noqa: E402


FRONTMATTER = """\
---
type: Business Domain
title: 示例业务域
description: 示例
tags: [business, BD]
timestamp: "2026-06-16T00:00:00Z"
full_id: BD-EXAMPLE
perspective: business
hierarchy: BD
parent_id: null
layer_scope: application
---
"""


def _write_bundle(tmp: str, headings: list[str]) -> Path:
    root = Path(tmp) / "application"
    (root / "knowledge" / "business").mkdir(parents=True)
    (root / "index.md").write_text('---\nokf_version: "0.1"\n---\n', encoding="utf-8")
    body = "\n\n".join(f"{heading}\n\n- (none)" for heading in headings)
    (root / "knowledge" / "business" / "BD-EXAMPLE.md").write_text(
        FRONTMATTER + body + "\n",
        encoding="utf-8",
    )
    return root


def test_validator_accepts_legacy_english_h1_sections() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = _write_bundle(
            tmp,
            ["# Relations", "# Cross-perspective", "# Details", "# Evidence"],
        )
        validator = validate_bundle.Validator(root, "application")
        code = validator.run()
        assert code == 0


def test_validator_accepts_target_chinese_h2_sections() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = _write_bundle(
            tmp,
            ["## 关系", "## 跨视角", "## 详细说明", "## 依据与证据"],
        )
        validator = validate_bundle.Validator(root, "application")
        code = validator.run()
        assert code == 0


def test_validator_rejects_missing_section() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = _write_bundle(
            tmp,
            ["## 关系", "## 跨视角", "## 详细说明"],
        )
        validator = validate_bundle.Validator(root, "application")
        code = validator.run()
        assert code == 1


def main() -> None:
    tests = [
        test_validator_accepts_legacy_english_h1_sections,
        test_validator_accepts_target_chinese_h2_sections,
        test_validator_rejects_missing_section,
    ]
    for fn in tests:
        fn()
        print(f"PASS {fn.__name__}")
    print(f"\nAll {len(tests)} tests passed.")


if __name__ == "__main__":
    main()
