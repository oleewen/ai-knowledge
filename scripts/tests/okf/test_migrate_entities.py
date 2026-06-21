#!/usr/bin/env python3
"""migrate_entities 单元测试。"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "okf"))
import migrate_entities  # noqa: E402
import okf_lib  # noqa: E402

BUSINESS_TABLE = """\
## 实体总表

| hierarchy | full_id | name | description | parent_id | strategic_classification | children | bounded_contexts | implemented_by_app_id | aggregates | root_entity | persisted_as_entity_ids | implemented_by_service_ids | abilities | capability | apis | evidence_source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BD | BD-EXAMPLE | 示例业务域 | 仅用于演示业务视角数据结构（示例）。 | — | supporting_domain | BSD-EXAMPLE | — | — | — | — | — | — | — | — | — | 示例数据 |
| BC | BC-EXAMPLE | 示例限界上下文 | 仅用于演示业务视角数据结构（示例）。 | BSD-EXAMPLE | — | — | — | APP-EXAMPLE | AGG-EXAMPLE | — | — | — | — | — | — | 示例数据 |
"""


def test_parse_business_table_row():
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as f:
        f.write(BUSINESS_TABLE)
        path = Path(f.name)
    try:
        entities = migrate_entities.parse_entities_file(path, "business")
        assert len(entities) == 2
        bd = entities[0]
        assert bd["hierarchy"] == "BD"
        assert bd["full_id"] == "BD-EXAMPLE"
        assert bd["name"] == "示例业务域"
        assert bd["parent_id"] is None
        assert bd["children"] == "BSD-EXAMPLE"
        bc = entities[1]
        assert bc["full_id"] == "BC-EXAMPLE"
        assert bc["parent_id"] == "BSD-EXAMPLE"
        assert bc["implemented_by_app_id"] == "APP-EXAMPLE"
    finally:
        path.unlink()


def test_output_path_business_bd():
    entity = {
        "hierarchy": "BD",
        "full_id": "BD-EXAMPLE",
        "name": "示例业务域",
        "description": "desc",
        "parent_id": None,
    }
    relpath = okf_lib.entity_relpath("business", entity["full_id"], entity.get("parent_id"))
    assert relpath == "knowledge/business/BD-EXAMPLE.md"


def test_migrate_writes_concept_file():
    with tempfile.TemporaryDirectory() as tmp:
        repo = Path(tmp)
        bundle_root = repo / "application"
        entities_dir = bundle_root / "knowledge" / "business"
        entities_dir.mkdir(parents=True)
        entities_path = entities_dir / "business-entities.md"
        entities_path.write_text(BUSINESS_TABLE, encoding="utf-8")

        # 临时替换 _repo_root
        orig = migrate_entities._repo_root
        migrate_entities._repo_root = lambda: repo  # type: ignore[assignment]
        try:
            written = migrate_entities.migrate(
                "application", entities_path, "business", dry_run=False
            )
            assert len(written) == 2
            bd_path = bundle_root / "knowledge/business/BD-EXAMPLE.md"
            assert bd_path in written
            assert bd_path.is_file()
            text = bd_path.read_text(encoding="utf-8")
            assert "full_id: BD-EXAMPLE" in text
            assert "# Relations" in text
            assert "# Cross-perspective" in text
            assert "# Evidence" in text
        finally:
            migrate_entities._repo_root = orig  # type: ignore[assignment]


def test_application_ms_id_maps_to_full_id():
    app_table = """\
## MS

| id | name | host_class | host_module | protocol | cross_references | evidence_source |
| --- | --- | --- | --- | --- | --- | --- |
| MS-EXAMPLE | 示例微服务 | ExampleApiImpl | example-module | HTTP | BC-EXAMPLE | 示例数据 |
"""
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as f:
        f.write(app_table)
        path = Path(f.name)
    try:
        entities = migrate_entities.parse_entities_file(path, "application")
        assert len(entities) == 1
        assert entities[0]["full_id"] == "MS-EXAMPLE"
        assert entities[0]["hierarchy"] == "MS"
    finally:
        path.unlink()


def main() -> None:
    tests = [
        test_parse_business_table_row,
        test_output_path_business_bd,
        test_migrate_writes_concept_file,
        test_application_ms_id_maps_to_full_id,
    ]
    for fn in tests:
        fn()
        print(f"PASS {fn.__name__}")
    print(f"\nAll {len(tests)} tests passed.")


if __name__ == "__main__":
    main()
