#!/usr/bin/env python3
"""跨层 HTTP / knowledge-links type:parent 单元测试。"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "agent" / "skills" / "docs-okf" / "scripts"))
import okf_cross_layer as x  # noqa: E402


def test_https_repo_home_ssh_and_https() -> None:
    assert (
        x.https_repo_home("git@github.com:org/ea.git")
        == "https://github.com/org/ea"
    )
    assert (
        x.https_repo_home("https://github.com/org/ea.git")
        == "https://github.com/org/ea"
    )


def test_parent_web_base_github() -> None:
    p = x.Parent(
        knowledge_type="company",
        repository="git@github.com:org/ea.git",
        path="~/ws/ea",
        doc_dir="company",
        ref="main",
    )
    assert (
        x.parent_web_base(p)
        == "https://github.com/org/ea/blob/main/company"
    )


def test_unknown_host_no_web_base() -> None:
    p = x.Parent(
        knowledge_type="company",
        repository="https://example.com/org/ea.git",
        path="~/ws/ea",
        doc_dir="docs",
        ref="main",
    )
    assert x.parent_web_base(p) is None


def test_href_and_validate(tmp_path: Path) -> None:
    company = tmp_path / "ea"
    cdoc = company / "company"
    biz = cdoc / "knowledge" / "business"
    biz.mkdir(parents=True)
    (company / ".docsconfig").write_text("KNOWLEDGE_TYPE=company\n", encoding="utf-8")
    bd_dir = biz / "BD" / "BD-EXAMPLE"
    bd_dir.mkdir(parents=True)
    (bd_dir / "BD-EXAMPLE.md").write_text("# bd\n", encoding="utf-8")
    sys_root = tmp_path / "sys" / "system"
    sys_root.mkdir(parents=True)
    x.write_parent(
        sys_root,
        x.Parent(
            knowledge_type="company",
            repository="https://github.com/org/ea.git",
            path=str(company),
            doc_dir="company",
            ref="main",
            parent_name="ea",
            parent_label="ea",
        ),
    )
    href = x.cross_layer_href(sys_root, "BD-EXAMPLE")
    assert href == (
        "https://github.com/org/ea/blob/main/company/"
        "knowledge/business/BD/BD-EXAMPLE/BD-EXAMPLE.md"
    )
    assert x.validate_http_href(sys_root, href) is None


def test_http_without_parent_errors(tmp_path: Path) -> None:
    doc = tmp_path / "system"
    doc.mkdir(parents=True)
    err = x.validate_http_href(
        doc,
        "https://github.com/org/ea/blob/main/company/knowledge/business/BD/BD-X/BD-X.md",
    )
    assert err and "type: parent" in err


def test_rewrite_to_id() -> None:
    text = (
        "见 [BD-EXAMPLE](https://github.com/org/ea/blob/main/company/"
        "knowledge/business/BD/BD-EXAMPLE/BD-EXAMPLE.md) 与本地。"
    )
    old = "https://github.com/org/ea/blob/main/company"
    new_text, n = x._rewrite_text(text, old, None)
    assert n == 1
    assert "BD-EXAMPLE" in new_text
    assert "https://" not in new_text


def test_href_walks_same_layer_parent_chain(tmp_path: Path) -> None:
    system = tmp_path / "sysrepo"
    doc = system / "system"
    bsd = (
        doc
        / "knowledge"
        / "business"
        / "BSD-EXAMPLE-L2"
        / "BSD-EXAMPLE-L3"
    )
    bc = bsd / "BC-EXAMPLE"
    agg = bc / "AGG-EXAMPLE"
    agg.mkdir(parents=True)
    (bsd / "BSD-EXAMPLE-L3.md").write_text(
        "---\nid: BSD-EXAMPLE-L3\n---\n## 关系\n\n- parent: BSD-EXAMPLE-L2\n",
        encoding="utf-8",
    )
    (bc / "BC-EXAMPLE.md").write_text(
        "---\nid: BC-EXAMPLE\n---\n## 关系\n\n- implements_to: BSD-EXAMPLE-L3\n",
        encoding="utf-8",
    )
    (agg / "AGG-EXAMPLE.md").write_text(
        "---\nid: AGG-EXAMPLE\n---\n## 关系\n\n- implements_to: BC-EXAMPLE\n",
        encoding="utf-8",
    )
    pm = doc / "knowledge" / "product" / "PD-EXAMPLE" / "PM-EXAMPLE"
    ft = pm / "FT-EXAMPLE"
    ft.mkdir(parents=True)
    (system / ".docsconfig").write_text("KNOWLEDGE_TYPE=system\n", encoding="utf-8")
    (pm / "PM-EXAMPLE.md").write_text(
        "---\nid: PM-EXAMPLE\n---\n## 关系\n\n- implements_to: PD-EXAMPLE\n",
        encoding="utf-8",
    )
    (ft / "FT-EXAMPLE.md").write_text(
        "---\nid: FT-EXAMPLE\n---\n## 关系\n\n- implements_to: PM-EXAMPLE\n",
        encoding="utf-8",
    )
    app = tmp_path / "app" / "application"
    app.mkdir(parents=True)
    x.write_parent(
        app,
        x.Parent(
            knowledge_type="system",
            repository="https://github.com/org/sys.git",
            path=str(system),
            doc_dir="system",
            ref="main",
            parent_name="sys",
            parent_label="sys",
        ),
    )
    base = "https://github.com/org/sys/blob/main/system/"
    agg_href = x.cross_layer_href(app, "AGG-EXAMPLE")
    assert agg_href == (
        base + "knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/"
        "AGG-EXAMPLE/AGG-EXAMPLE.md"
    )
    ft_href = x.cross_layer_href(app, "FT-EXAMPLE")
    assert ft_href == (
        base + "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/"
        "FT-EXAMPLE/FT-EXAMPLE.md"
    )
    assert x.validate_http_href(app, agg_href) is None
    wrong = (
        base + "knowledge/business/BSD-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md"
    )
    mismatch = x.validate_http_href(app, wrong)
    assert mismatch and "不一致" in mismatch
    (agg / "AGG-EXAMPLE.md").write_text(
        "---\nid: AGG-EXAMPLE\n---\n## 关系\n\n- implements_to: NOT-LOCAL\n",
        encoding="utf-8",
    )
    assert x.validate_http_href(app, agg_href) is None
    (agg / "AGG-EXAMPLE.md").unlink()
    flat = doc / "knowledge" / "business" / "AGG-EXAMPLE.md"
    flat.write_text(
        "---\nid: AGG-EXAMPLE\n---\n## 关系\n\n- implements_to: NOT-LOCAL\n",
        encoding="utf-8",
    )
    short = x.validate_http_href(app, agg_href)
    assert short and "路径不足" in short


def test_single_parent_uses_disk_dir(tmp_path: Path) -> None:
    app = tmp_path / "application"
    api_dir = app / "knowledge" / "application" / "MS-EXAMPLE"
    api_dir.mkdir(parents=True)
    (api_dir / "API-EXAMPLE.md").write_text(
        "---\nid: API-EXAMPLE\n---\n## 关系\n\n- implements_to: MS-EXAMPLE\n",
        encoding="utf-8",
    )
    assert (
        x.directory_chain_for_entity(app, "API-EXAMPLE", "application", 1)
        == "MS-EXAMPLE"
    )

    repo = tmp_path / "sysrepo-pm"
    doc = repo / "system"
    pm = doc / "knowledge" / "product" / "PD-EXAMPLE" / "PM-EXAMPLE"
    pm.mkdir(parents=True)
    (repo / ".docsconfig").write_text("KNOWLEDGE_TYPE=system\n", encoding="utf-8")
    (pm / "PM-EXAMPLE.md").write_text(
        "---\nid: PM-EXAMPLE\n---\n## 关系\n\n- implements_to: PD-EXAMPLE\n",
        encoding="utf-8",
    )
    child = tmp_path / "child"
    child.mkdir()
    x.write_parent(
        child,
        x.Parent(
            knowledge_type="system",
            repository="https://github.com/org/sys.git",
            path=str(repo),
            doc_dir="system",
            ref="main",
            parent_name="sys",
            parent_label="sys",
        ),
    )
    href = x.cross_layer_href(child, "PM-EXAMPLE")
    assert href == (
        "https://github.com/org/sys/blob/main/system/"
        "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md"
    )
    assert x.validate_http_href(child, href) is None
    wrong = href.replace("PD-EXAMPLE", "PD-OTHER")
    mismatch = x.validate_http_href(child, wrong)
    assert mismatch and "不一致" in mismatch
    (pm / "PM-EXAMPLE.md").unlink()
    flat = doc / "knowledge" / "product" / "PM-EXAMPLE.md"
    flat.write_text(
        "---\nid: PM-EXAMPLE\n---\n## 关系\n\n- implements_to: PD-EXAMPLE\n",
        encoding="utf-8",
    )
    short = x.validate_http_href(child, href)
    assert short and "路径不足" in short

    ghost = tmp_path / "ghost"
    ghost.mkdir()
    x.write_parent(
        ghost,
        x.Parent(
            knowledge_type="system",
            repository="https://github.com/org/sys.git",
            path=str(tmp_path / "missing"),
            doc_dir="system",
            ref="main",
            parent_name="sys",
            parent_label="sys",
        ),
    )
    absent = x.validate_http_href(ghost, href)
    assert absent is None or "路径不足" not in absent


def test_load_parent_uses_name_field(tmp_path: Path) -> None:
    sln = tmp_path / "sln-repo"
    sln.mkdir()
    (sln / ".docsconfig").write_text("KNOWLEDGE_TYPE=solution\n", encoding="utf-8")
    doc = tmp_path / "system-parent"
    doc.mkdir()
    (doc / "knowledge-links.yaml").write_text(
        "\n".join(
            [
                "links:",
                "  - type: parent",
                '    repository: "git@github.com:org/sln.git"',
                f'    path: "{sln}"',
                '    dir: "docs"',
                '    name: "sln-kb"',
                '    label: "sln-kb"',
                "",
            ]
        ),
        encoding="utf-8",
    )
    parent = x.load_parent(doc)
    assert parent is not None
    assert parent.knowledge_type == "solution"
    assert parent.parent_name == "sln-kb"
    bare = tmp_path / "bare"
    bare.mkdir()
    (bare / "knowledge-links.yaml").write_text(
        "\n".join(
            [
                "links:",
                "  - type: parent",
                '    repository: "git@github.com:org/x.git"',
                '    path: "/tmp/x"',
                '    dir: "docs"',
                "",
            ]
        ),
        encoding="utf-8",
    )
    assert x.load_parent(bare) is None
    written = tmp_path / "out"
    x.write_parent(
        written,
        x.Parent(
            knowledge_type="solution",
            repository="https://github.com/org/sln.git",
            path=str(sln),
            doc_dir="docs",
            parent_name="sln-kb",
            parent_label="sln-kb",
        ),
    )
    text = (written / "knowledge-links.yaml").read_text(encoding="utf-8")
    assert 'name: "sln-kb"' in text
    assert 'label: "sln-kb"' in text
    assert 'dir: "docs"' in text
    assert "solution_name:" not in text
    again = x.load_parent(written)
    assert again is not None and again.knowledge_type == "solution"
    mixed = tmp_path / "mixed"
    mixed.mkdir()
    (mixed / "knowledge-links.yaml").write_text(
        "\n".join(
            [
                "links:",
                "  - type: parent",
                '    repository: "git@github.com:org/co.git"',
                '    path: "/tmp/co"',
                '    dir: "docs"',
                '    name: "co"',
                '    label: "co"',
                "  - type: meta",
                '    repository: "git@github.com:org/meta.git"',
                '    path: "/tmp/meta"',
                '    dir: "company"',
                '    name: "should-drop"',
                "  - type: child",
                '    repository: "git@github.com:org/sln.git"',
                '    path: "/tmp/sln"',
                '    dir: "docs"',
                '    name: "sln-child"',
                '    label: "方案"',
                "  - type: child",
                '    repository: "git@github.com:org/sys.git"',
                '    path: "/tmp/sys"',
                '    dir: "docs"',
                '    name: "sys-child"',
                '    label: "系统"',
                "  - type: child",
                '    repository: "git@github.com:org/app.git"',
                '    path: "/tmp/app"',
                '    dir: "docs"',
                '    name: "app-child"',
                '    label: "应用"',
                "",
            ]
        ),
        encoding="utf-8",
    )
    x.write_parent(
        mixed,
        x.Parent(
            knowledge_type="company",
            repository="https://github.com/org/co.git",
            path="/tmp/co",
            doc_dir="docs",
            parent_name="co",
            parent_label="co",
        ),
    )
    kept = (mixed / "knowledge-links.yaml").read_text(encoding="utf-8")
    assert 'name: "sln-child"' in kept
    assert 'label: "方案"' in kept
    assert 'name: "sys-child"' in kept
    assert 'name: "app-child"' in kept
    assert 'label: "应用"' in kept
    assert "type: meta" in kept
    assert "type: child" in kept
    assert "should-drop" not in kept


def main() -> None:
    test_https_repo_home_ssh_and_https()
    print("PASS test_https_repo_home_ssh_and_https")
    test_parent_web_base_github()
    print("PASS test_parent_web_base_github")
    test_unknown_host_no_web_base()
    print("PASS test_unknown_host_no_web_base")
    test_rewrite_to_id()
    print("PASS test_rewrite_to_id")
    with tempfile.TemporaryDirectory() as tmp:
        test_href_and_validate(Path(tmp))
        print("PASS test_href_and_validate")
        test_href_walks_same_layer_parent_chain(Path(tmp))
        print("PASS test_href_walks_same_layer_parent_chain")
        test_single_parent_uses_disk_dir(Path(tmp))
        print("PASS test_single_parent_uses_disk_dir")
        test_load_parent_uses_name_field(Path(tmp))
        print("PASS test_load_parent_uses_name_field")
        test_http_without_parent_errors(Path(tmp))
        print("PASS test_http_without_parent_errors")
    print("\nAll cross-layer tests passed.")


if __name__ == "__main__":
    main()
