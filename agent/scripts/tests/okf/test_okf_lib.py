#!/usr/bin/env python3
"""OKF 共享库单元测试。"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "agent" / "skills" / "docs-okf" / "scripts"))
import okf_lib  # noqa: E402


def test_parse_frontmatter():
    text = "---\ntype: Business Domain\nid: BD-EXAMPLE\n---\n# Body\n"
    meta, body = okf_lib.parse_frontmatter(text)
    assert meta["type"] == "Business Domain"
    assert meta["id"] == "BD-EXAMPLE"
    assert body.strip() == "# Body"


def test_hierarchy_to_type():
    assert okf_lib.hierarchy_to_type("BD") == "Business Domain"
    assert okf_lib.hierarchy_to_type("VC") == "Value Chain"
    assert okf_lib.hierarchy_to_type("API") == "API Endpoint"


def test_entity_relpath_business_bd():
    try:
        okf_lib.entity_relpath("business", "BD-EXAMPLE")
    except ValueError as exc:
        assert "does not land BD" in str(exc)
    else:
        raise AssertionError("expected ValueError when application bundle gets BD")
    assert (
        okf_lib.entity_relpath("business", "BD-EXAMPLE", bundle="company")
        == "knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md"
    )


def test_entity_relpath_application_sys():
    try:
        okf_lib.entity_relpath("application", "SYS-EXAMPLE")
    except ValueError as exc:
        assert "does not land SYS" in str(exc)
    else:
        raise AssertionError("expected ValueError when application bundle gets SYS")
    assert (
        okf_lib.entity_relpath("application", "SYS-EXAMPLE", bundle="system")
        == "knowledge/application/SYS-EXAMPLE/SYS-EXAMPLE.md"
    )


def test_entity_relpath_application_api():
    try:
        okf_lib.entity_relpath("application", "API-EXAMPLE")
    except ValueError as exc:
        assert "API requires path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when API has no path_parent")
    assert (
        okf_lib.entity_relpath(
            "application", "API-EXAMPLE", path_parent="MS-EXAMPLE"
        )
        == "knowledge/application/MS-EXAMPLE/API-EXAMPLE.md"
    )


def test_parse_frontmatter_list():
    text = "---\ntags: [business, BD]\n---\n"
    meta, body = okf_lib.parse_frontmatter(text)
    assert meta["tags"] == ["business", "BD"]
    assert body == ""


def test_parse_frontmatter_null():
    text = "---\ndescription: null\ntitle: Example\n---\n"
    meta, body = okf_lib.parse_frontmatter(text)
    assert meta["description"] is None
    assert meta["title"] == "Example"
    assert body == ""


def test_entity_relpath_ent_with_parent():
    try:
        okf_lib.entity_relpath("data", "ENT-T_BILLING", path_parent="DS-BILLING")
    except ValueError as exc:
        assert "does not land ENT" in str(exc)
    else:
        raise AssertionError("expected ValueError when application bundle gets ENT")
    try:
        okf_lib.entity_relpath("data", "ENT-T_BILLING", bundle="system")
    except ValueError as exc:
        assert "ENT requires path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when ENT has no path_parent")
    assert (
        okf_lib.entity_relpath(
            "data",
            "ENT-T_BILLING",
            path_parent="MDG-BILLING/DS-BILLING",
            bundle="system",
        )
        == "knowledge/data/MDG-BILLING/DS-BILLING/ENT-T_BILLING.md"
    )


def test_bundle_link():
    link = okf_lib.to_bundle_link("knowledge/application/APP-EXAMPLE.md")
    assert link == "/knowledge/application/APP-EXAMPLE.md"


def test_format_frontmatter_roundtrip():
    meta = {
        "type": "Feature",
        "tags": ["product", "FT"],
        "description": None,
    }
    block = okf_lib.format_frontmatter(meta)
    parsed, _ = okf_lib.parse_frontmatter(block)
    assert parsed["type"] == "Feature"
    assert parsed["tags"] == ["product", "FT"]
    assert parsed["description"] is None


def test_scan_concepts():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "index.md").write_text("# index\n", encoding="utf-8")
        (root / "log.md").write_text("# log\n", encoding="utf-8")
        concept = root / "knowledge" / "business" / "BD-EXAMPLE.md"
        concept.parent.mkdir(parents=True)
        concept.write_text("# concept\n", encoding="utf-8")
        found = list(okf_lib.scan_concepts(root))
        assert len(found) == 1
        assert found[0].name == "BD-EXAMPLE.md"


def test_is_concept_file():
    assert okf_lib.is_concept_file(Path("knowledge/business/BD-EXAMPLE.md"))
    assert not okf_lib.is_concept_file(Path("knowledge/business/index.md"))
    assert not okf_lib.is_concept_file(Path("manifest.yaml"))


def test_hierarchy_to_type_cap():
    assert okf_lib.hierarchy_to_type("CAP") == "Business Capability"


def test_entity_relpath_company_bd_nested():
    path = okf_lib.entity_relpath("business", "BD-EXAMPLE", bundle="company")
    assert path == "knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md"


def test_entity_relpath_company_bd_uses_id():
    path = okf_lib.entity_relpath("business", "BD-CHARGING", bundle="company")
    assert path == "knowledge/business/BD-CHARGING/BD-CHARGING.md"


def test_entity_relpath_company_bsd_nested():
    path = okf_lib.entity_relpath(
        "business", "BSD-EXAMPLE", path_parent="BD-EXAMPLE", bundle="company"
    )
    assert path == "knowledge/business/BD-EXAMPLE/BSD-EXAMPLE.md"


def test_entity_relpath_company_bsd_default_parent():
    try:
        okf_lib.entity_relpath("business", "BSD-EXAMPLE", bundle="company")
    except ValueError as exc:
        assert "BSD requires path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when BSD has no path_parent")


def test_entity_relpath_company_cap_with_parent():
    path = okf_lib.entity_relpath(
        "business", "CAP-ORDER", path_parent="VC-EXPRESS", bundle="company"
    )
    assert path == "knowledge/business/VC-EXPRESS/CAP-ORDER.md"


def test_entity_relpath_company_cap():
    try:
        okf_lib.entity_relpath("business", "CAP-EXAMPLE", bundle="company")
    except ValueError as exc:
        assert "CAP requires path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when CAP has no path_parent")
    assert (
        okf_lib.entity_relpath(
            "business", "CAP-EXAMPLE", path_parent="VC-EXAMPLE", bundle="company"
        )
        == "knowledge/business/VC-EXAMPLE/CAP-EXAMPLE.md"
    )


def test_entity_relpath_company_bl():
    path = okf_lib.entity_relpath("business", "BL-EXAMPLE", bundle="company")
    assert path == "knowledge/business/BL/BL-EXAMPLE.md"
    assert okf_lib.hierarchy_to_type("BL") == "Business Line"
    assert okf_lib.hierarchy_first_layer("BL") == "company"
    assert okf_lib.hierarchy_to_perspective("BL") == "business"


def test_entity_relpath_company_tpl():
    path = okf_lib.entity_relpath("technical", "TPL-EXAMPLE", bundle="company")
    assert path == "knowledge/technical/TPL-EXAMPLE.md"


def test_entity_relpath_company_pl_and_sln():
    try:
        okf_lib.entity_relpath("application", "SLN-EXAMPLE", bundle="company")
    except ValueError as exc:
        assert "does not land SLN" in str(exc)
    else:
        raise AssertionError("expected ValueError when company bundle gets SLN")
    try:
        okf_lib.entity_relpath("data", "MDG-EXAMPLE", bundle="company")
    except ValueError as exc:
        assert "does not land MDG" in str(exc)
    else:
        raise AssertionError("expected ValueError when company bundle gets MDG")
    assert (
        okf_lib.entity_relpath("product", "PL-EXAMPLE", bundle="solution")
        == "knowledge/product/PL-EXAMPLE/PL-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath(
            "product", "PD-EXAMPLE", path_parent="PL-EXAMPLE", bundle="solution"
        )
        == "knowledge/product/PL-EXAMPLE/PD-EXAMPLE.md"
    )
    try:
        okf_lib.entity_relpath("product", "PD-EXAMPLE", bundle="solution")
    except ValueError as exc:
        assert "PL id" in str(exc) or "path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when solution PD has no PL parent")
    assert (
        okf_lib.entity_relpath("product", "BP-EXAMPLE", bundle="solution")
        == "knowledge/product/BP/BP-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath("product", "BSP-EXAMPLE", bundle="solution")
        == "knowledge/product/BP/BSP-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath("business", "BS-EXAMPLE", bundle="solution")
        == "knowledge/business/BS/BS-EXAMPLE.md"
    )


def test_entity_relpath_system_pd_and_pm():
    try:
        okf_lib.entity_relpath("product", "PD-EXAMPLE", bundle="system")
    except ValueError as exc:
        assert "does not land PD" in str(exc)
    else:
        raise AssertionError("expected ValueError when system PD is requested")
    for prefix, entity_id, perspective in (
        ("PL", "PL-EXAMPLE", "product"),
        ("MDG", "MDG-EXAMPLE", "data"),
        ("TS", "TS-EXAMPLE", "technical"),
    ):
        try:
            okf_lib.entity_relpath(perspective, entity_id, bundle="system")
        except ValueError as exc:
            assert f"does not land {prefix}" in str(exc)
        else:
            raise AssertionError(f"expected ValueError when system bundle gets {prefix}")
    assert (
        okf_lib.entity_relpath(
            "product", "PM-EXAMPLE", path_parent="PD-EXAMPLE", bundle="system"
        )
        == "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md"
    )
    try:
        okf_lib.entity_relpath("product", "PM-EXAMPLE", bundle="system")
    except ValueError as exc:
        assert "PM requires path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when PM has no path_parent")


def test_hierarchy_first_layer_pd_sys():
    assert okf_lib.hierarchy_first_layer("PD") == "solution"
    assert okf_lib.hierarchy_first_layer("PL") == "solution"
    assert okf_lib.hierarchy_first_layer("BP") == "solution"
    assert okf_lib.hierarchy_first_layer("BS") == "solution"
    assert okf_lib.hierarchy_first_layer("BSP") == "solution"
    assert okf_lib.hierarchy_first_layer("SYS") == "system"
    assert okf_lib.hierarchy_first_layer("SLN") == "solution"
    assert okf_lib.hierarchy_first_layer("MDG") == "solution"
    assert okf_lib.hierarchy_first_layer("TS") == "solution"
    assert okf_lib.hierarchy_to_perspective("SLN") == "application"
    assert okf_lib.hierarchy_first_layer("VC") == "company"
    assert okf_lib.hierarchy_first_layer("BSD") == "system"
    assert okf_lib.hierarchy_first_layer("BSD", "BSD-EXAMPLE-L3") == "system"
    assert okf_lib.hierarchy_first_layer("BSD", "BSD-EXAMPLE-L2") == "solution"
    assert okf_lib.hierarchy_first_layer("BSD", "BSD-EXAMPLE") == "company"


def test_entity_relpath_system_ms_and_mw():
    assert (
        okf_lib.entity_relpath(
            "application",
            "MS-EXAMPLE",
            path_parent="SYS-EXAMPLE/APP-EXAMPLE",
            bundle="system",
        )
        == "knowledge/application/SYS-EXAMPLE/APP-EXAMPLE/MS-EXAMPLE/MS-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath(
            "application",
            "APP-EXAMPLE",
            path_parent="SYS-EXAMPLE",
            bundle="system",
        )
        == "knowledge/application/SYS-EXAMPLE/APP-EXAMPLE/APP-EXAMPLE.md"
    )
    try:
        okf_lib.entity_relpath("technical", "MW-EXAMPLE", bundle="system")
    except ValueError as exc:
        assert "does not land MW" in str(exc)
    else:
        raise AssertionError("expected ValueError when system bundle gets MW")
    try:
        okf_lib.entity_relpath("technical", "CMP-EXAMPLE", bundle="system")
    except ValueError as exc:
        assert "does not land CMP" in str(exc)
    else:
        raise AssertionError("expected ValueError when system bundle gets CMP")
    assert (
        okf_lib.entity_relpath("technical", "MW-EXAMPLE", bundle="application")
        == "knowledge/technical/MW-EXAMPLE/MW-EXAMPLE.md"
    )
    try:
        okf_lib.entity_relpath("technical", "CMP-EXAMPLE", bundle="application")
    except ValueError as exc:
        assert "CMP requires path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when CMP has no path_parent")
    assert (
        okf_lib.entity_relpath(
            "technical", "CMP-EXAMPLE", path_parent="MW-EXAMPLE", bundle="application"
        )
        == "knowledge/technical/MW-EXAMPLE/CMP-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath(
            "data", "DS-EXAMPLE", path_parent="MDG-EXAMPLE", bundle="system"
        )
        == "knowledge/data/MDG-EXAMPLE/DS-EXAMPLE/DS-EXAMPLE.md"
    )
    try:
        okf_lib.entity_relpath("data", "DS-EXAMPLE", bundle="system")
    except ValueError as exc:
        assert "MDG host" in str(exc) or "path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when system DS has no MDG host")
    try:
        okf_lib.entity_relpath("data", "TBL-EXAMPLE")
    except ValueError as exc:
        assert "TBL requires path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when TBL has no path_parent")
    assert (
        okf_lib.entity_relpath("data", "TBL-EXAMPLE", path_parent="ENT-EXAMPLE")
        == "knowledge/data/ENT-EXAMPLE/TBL-EXAMPLE.md"
    )
    assert okf_lib.hierarchy_to_type("FR") == "Functional Requirement"


def test_entity_relpath_system_ms_requires_parent():
    try:
        okf_lib.entity_relpath("application", "MS-EXAMPLE", bundle="system")
    except ValueError as exc:
        assert "path_parent" in str(exc)
        return
    raise AssertionError("expected ValueError when system MS path_parent missing")


def test_relation_path_parent_prefers_parent_and_skips_cross_layer():
    body = """## 关系

- parent: BP-EXAMPLE
- implements_to: PD-EXAMPLE

## 跨视角
"""
    assert okf_lib.relation_path_parent(body) == "BP-EXAMPLE"
    body = """## 关系

- implements_to: TPL-EXAMPLE
- implements_to: TS-EXAMPLE

## 详细说明
"""
    assert (
        okf_lib.relation_path_parent(body, local_ids={"TS-EXAMPLE"}) == "TS-EXAMPLE"
    )
    assert okf_lib.relation_path_parent(body, local_ids={"OTHER"}) is None


def test_entity_relpath_system_bd_not_landed():
    try:
        okf_lib.entity_relpath("business", "BD-EXAMPLE", bundle="system")
    except ValueError as exc:
        assert "does not land BD" in str(exc)
        return
    raise AssertionError("expected ValueError when system BD is requested")


def test_entity_relpath_solution_bsd_l2_flat():
    assert (
        okf_lib.entity_relpath("business", "BSD-EXAMPLE-L2", bundle="solution")
        == "knowledge/business/BSD-EXAMPLE-L1/BSD-EXAMPLE-L2/BSD-EXAMPLE-L2.md"
    )
    assert (
        okf_lib.entity_relpath("application", "SLN-EXAMPLE", bundle="solution")
        == "knowledge/application/SLN-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath("data", "MDG-EXAMPLE", bundle="solution")
        == "knowledge/data/MDG-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath("technical", "TS-EXAMPLE", bundle="solution")
        == "knowledge/technical/TS/TS-EXAMPLE.md"
    )
    try:
        okf_lib.entity_relpath("business", "BSD-EXAMPLE-L3", bundle="solution")
    except ValueError as exc:
        assert "does not land BSD" in str(exc)
        return
    raise AssertionError("expected ValueError when solution bundle gets non-L2 BSD")


def test_entity_relpath_system_bsd_l3_under_l2_host():
    assert (
        okf_lib.entity_relpath(
            "business",
            "BSD-EXAMPLE-L3",
            path_parent="BSD-EXAMPLE-L2",
            bundle="system",
        )
        == "knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BSD-EXAMPLE-L3.md"
    )
    try:
        okf_lib.entity_relpath("business", "BSD-EXAMPLE-L3", bundle="system")
    except ValueError as exc:
        assert "BSD-L2 host" in str(exc) or "path_parent" in str(exc)
    else:
        raise AssertionError("expected ValueError when system L3 has no L2 host")


def test_entity_relpath_system_bsd_l1_l2_not_landed():
    for entity_id, parent in (
        ("BSD-EXAMPLE", "BD-EXAMPLE"),
        ("BSD-EXAMPLE-L2", "BSD-EXAMPLE"),
    ):
        try:
            okf_lib.entity_relpath(
                "business", entity_id, path_parent=parent, bundle="system"
            )
        except ValueError as exc:
            assert "does not land BSD" in str(exc)
            continue
        raise AssertionError(f"expected ValueError for {entity_id}")


def test_entity_relpath_system_nested_chain():
    assert (
        okf_lib.entity_relpath(
            "business",
            "BC-EXAMPLE",
            path_parent="BSD-EXAMPLE-L2/BSD-EXAMPLE-L3",
            bundle="system",
        )
        == "knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/BC-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath(
            "business",
            "AGG-EXAMPLE",
            path_parent="BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE",
            bundle="system",
        )
        == "knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath(
            "business",
            "AB-EXAMPLE",
            path_parent="BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE",
            bundle="system",
        )
        == "knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath(
            "product",
            "FT-EXAMPLE",
            path_parent="PD-EXAMPLE/PM-EXAMPLE",
            bundle="system",
        )
        == "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md"
    )
    assert (
        okf_lib.entity_relpath(
            "product",
            "FR-EXAMPLE",
            path_parent="PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE",
            bundle="system",
        )
        == "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md"
    )
    for entity_id in ("UC-EXAMPLE", "BR-EXAMPLE"):
        assert (
            okf_lib.entity_relpath(
                "product",
                entity_id,
                path_parent="PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE",
                bundle="system",
            )
            == f"knowledge/product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/{entity_id}.md"
        )
    try:
        okf_lib.entity_relpath(
            "business", "AGG-EXAMPLE", path_parent="BC-EXAMPLE", bundle="system"
        )
    except ValueError as exc:
        assert "parent directory chain" in str(exc)
    else:
        raise AssertionError("expected ValueError when AGG has only one parent id")


def main() -> None:
    tests = [
        test_parse_frontmatter,
        test_hierarchy_to_type,
        test_entity_relpath_business_bd,
        test_entity_relpath_application_sys,
        test_entity_relpath_application_api,
        test_bundle_link,
        test_parse_frontmatter_list,
        test_parse_frontmatter_null,
        test_entity_relpath_ent_with_parent,
        test_format_frontmatter_roundtrip,
        test_scan_concepts,
        test_is_concept_file,
        test_hierarchy_to_type_cap,
        test_entity_relpath_company_bd_nested,
        test_entity_relpath_company_bd_uses_id,
        test_entity_relpath_company_bsd_nested,
        test_entity_relpath_company_bsd_default_parent,
        test_entity_relpath_company_cap,
        test_entity_relpath_company_bl,
        test_entity_relpath_company_cap_with_parent,
        test_entity_relpath_company_tpl,
        test_entity_relpath_company_pl_and_sln,
        test_entity_relpath_system_pd_and_pm,
        test_hierarchy_first_layer_pd_sys,
        test_entity_relpath_system_ms_and_mw,
        test_entity_relpath_system_ms_requires_parent,
        test_relation_path_parent_prefers_parent_and_skips_cross_layer,
        test_entity_relpath_system_bd_not_landed,
        test_entity_relpath_solution_bsd_l2_flat,
        test_entity_relpath_system_bsd_l3_under_l2_host,
        test_entity_relpath_system_bsd_l1_l2_not_landed,
        test_entity_relpath_system_nested_chain,
    ]
    for fn in tests:
        fn()
        print(f"PASS {fn.__name__}")
    print(f"\nAll {len(tests)} tests passed.")


if __name__ == "__main__":
    main()
