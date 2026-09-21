#!/usr/bin/env python3
"""扫描 concept，写入 {DOC_DIR}/INDEX-GUIDE.md 第五章实体表（docs-build）。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

SCRIPT_DIR = Path(__file__).resolve().parent
OKF_SCRIPTS = SCRIPT_DIR.parent.parent / "docs-okf" / "scripts"
sys.path.insert(0, str(OKF_SCRIPTS))
import okf_lib  # noqa: E402

_APPLICATION_PERSPECTIVE_SECTIONS: List[Tuple[str, str, List[str]]] = [
    (
        "§1 业务视角（business · 一级 BSD → 二级 BSD → BC → AGG → AB）",
        "business",
        ["BD", "BSD", "BC", "AGG", "AB"],
    ),
    (
        "§2 产品视角（product · PD → PM → FT → FR → UC/BR · BP）",
        "product",
        ["PD", "PM", "FT", "FR", "UC", "BR", "BP"],
    ),
    (
        "§3 应用视角（application · SYS → APP → MS → API）",
        "application",
        ["SYS", "APP", "MS", "API"],
    ),
    (
        "§4 数据视角（data · MDG → DS → ENT → TBL）",
        "data",
        ["MDG", "DS", "ENT", "TBL"],
    ),
    (
        "§5 技术视角（technical · TSD → MW → CMP）",
        "technical",
        ["TSD", "MW", "CMP"],
    ),
]


_COMPANY_PERSPECTIVE_SECTIONS: List[Tuple[str, str, List[str]]] = [
    (
        "§1 业务视角（business · VC / BD / 一级 BSD / CAP）",
        "business",
        ["VC", "BD", "BSD", "CAP"],
    ),
    (
        "§2 产品视角（product · PL）",
        "product",
        ["PL"],
    ),
    (
        "§3 应用视角（application · SLN）",
        "application",
        ["SLN"],
    ),
    (
        "§4 技术视角（technical · TPL）",
        "technical",
        ["TPL"],
    ),
]


def _perspective_sections(bundle: str) -> List[Tuple[str, str, List[str]]]:
    if bundle == "company":
        return list(_COMPANY_PERSPECTIVE_SECTIONS)
    sections = list(_APPLICATION_PERSPECTIVE_SECTIONS)
    if bundle == "system":
        sections[2] = (
            "§3 应用视角（application · SYS → APP → MS）",
            "application",
            ["SYS", "APP", "MS"],
        )
        sections[3] = (
            "§4 数据视角（data · MDG → DS → ENT）",
            "data",
            ["MDG", "DS", "ENT"],
        )
        sections[4] = (
            "§5 技术视角（technical · TSD → MW）",
            "technical",
            ["TSD", "MW"],
        )
    return sections


def _repo_root() -> Path:
    return okf_lib.find_repo_root(Path(__file__).resolve())


def _bundle_root(repo: Path, bundle: str) -> Path:
    return (repo / bundle).resolve()


def _load_concepts(bundle_root: Path) -> List[Dict[str, Any]]:
    concepts: List[Dict[str, Any]] = []
    root = bundle_root.resolve()
    for path in okf_lib.scan_concepts(root):
        if path.name in ("KNOWLEDGE-INDEX.md", "INDEX-GUIDE.md"):
            continue
        text = path.read_text(encoding="utf-8")
        meta, _ = okf_lib.parse_frontmatter(text)
        id = meta.get("id")
        if not id:
            continue
        hierarchy = str(meta.get("hierarchy") or id.split("-", 1)[0])
        perspective = str(meta.get("perspective") or "")
        parent_id = meta.get("parent_id")
        parent = None if parent_id in (None, "null") else str(parent_id)
        relpath = path.resolve().relative_to(root).as_posix()
        evidence = relpath
        if evidence.startswith("knowledge/"):
            evidence = evidence[len("knowledge/") :]
        concepts.append(
            {
                "id": str(id),
                "hierarchy": hierarchy,
                "perspective": perspective,
                "parent_id": parent,
                "title": str(meta.get("title") or id),
                "alias": str(meta.get("alias") or meta.get("name") or ""),
                "evidence": evidence,
                "path": path,
            }
        )
    return concepts


def _forest_sort(concepts: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """同批实体：无 parent 在前，父先于子；环/断链按 id 回退。"""
    by_id = {c["id"]: c for c in concepts}
    children: Dict[Optional[str], List[str]] = {}
    for c in concepts:
        parent = c["parent_id"] if c["parent_id"] in by_id else None
        children.setdefault(parent, []).append(c["id"])
    for kids in children.values():
        kids.sort()

    ordered: List[Dict[str, Any]] = []
    seen: set[str] = set()

    def walk(node_id: str) -> None:
        if node_id in seen or node_id not in by_id:
            return
        seen.add(node_id)
        ordered.append(by_id[node_id])
        for child_id in children.get(node_id, []):
            walk(child_id)

    for root_id in children.get(None, []):
        walk(root_id)
    for c in sorted(concepts, key=lambda x: x["id"]):
        if c["id"] not in seen:
            walk(c["id"])
    return ordered


def _filter_for_section(
    concepts: List[Dict[str, Any]],
    perspective: str,
    hierarchies: List[str],
) -> List[Dict[str, Any]]:
    allowed = set(hierarchies)
    filtered = [
        c
        for c in concepts
        if c["hierarchy"] in allowed
        and (not c["perspective"] or c["perspective"] == perspective)
    ]
    grouped: List[Dict[str, Any]] = []
    for hierarchy in hierarchies:
        group = [c for c in filtered if c["hierarchy"] == hierarchy]
        grouped.extend(_forest_sort(group))
    listed = {c["id"] for c in grouped}
    for c in sorted(filtered, key=lambda x: x["id"]):
        if c["id"] not in listed:
            grouped.append(c)
    return grouped


def _render_table_rows(concepts: List[Dict[str, Any]]) -> List[str]:
    rows = [
        "| 层级 | ID | 别名（英文名） | 名称 | 证据链 |",
        "|------|----|--------------|------|---------|",
    ]
    for concept in concepts:
        rows.append(
            "| {hierarchy} | {id} | {alias} | {title} | `{evidence}` |".format(
                hierarchy=concept["hierarchy"],
                id=concept["id"],
                alias=concept["alias"],
                title=concept["title"],
                evidence=concept["evidence"],
            )
        )
    if len(rows) == 2:
        rows.append("| — | — | — | — | — |")
    return rows


def _render_section(
    heading: str,
    perspective: str,
    hierarchies: List[str],
    concepts: List[Dict[str, Any]],
) -> str:
    section_concepts = _filter_for_section(concepts, perspective, hierarchies)
    lines = [f"### {heading}", ""]
    lines.extend(_render_table_rows(section_concepts))
    lines.append("")
    return "\n".join(lines)


def _default_suffix(bundle: str) -> str:
    if bundle == "company":
        footer_note = (
            "> 本索引登记公司级 **VC / BD / 一级 BSD / CAP / PL / SLN / TPL**；"
            "SLN ∈ application（AA）；无二级 BSD/PD/SYS/MDG（见系统库）。"
        )
        mapping_rows = [
            "| VC-EXAMPLE | `business/VC-EXAMPLE/` |",
            "| BD-EXAMPLE | `business/BD-EXAMPLE.md` |",
            "| BSD-EXAMPLE | `business/BSD-EXAMPLE.md` |",
            "| CAP-EXAMPLE | `business/VC-EXAMPLE/CAP-EXAMPLE.md` |",
            "| PL-EXAMPLE | `product/PL-EXAMPLE.md` |",
            "| SLN-EXAMPLE | `application/SLN-EXAMPLE.md` |",
            "| TPL-EXAMPLE | `technical/TPL-EXAMPLE.md` |",
        ]
    elif bundle == "system":
        footer_note = (
            "> 公司级 **TPL-*** / **SLN-*** / **PL-*** 不在本索引登记。"
            "本层 **二级 BSD / PD / SYS / MDG** 首次定义；产品自 **PD** 起；应用自 **SYS** 起。"
        )
        mapping_rows = [
            "| BSD-EXAMPLE | `business/BSD-EXAMPLE/BSD-EXAMPLE.md`（一级 reference） |",
            "| BSD-EXAMPLE-SUB | `business/BSD-EXAMPLE/BSD-EXAMPLE-SUB/BSD-EXAMPLE-SUB.md` |",
            "| PD-EXAMPLE | `product/PD-EXAMPLE/` |",
            "| PM-EXAMPLE | `product/PD-EXAMPLE/PM-EXAMPLE/` |",
            "| SYS-EXAMPLE | `application/SYS-EXAMPLE.md` |",
            "| APP-EXAMPLE | `application/APP-EXAMPLE/` |",
            "| MDG-EXAMPLE | `data/MDG-EXAMPLE.md` |",
            "| DS-EXAMPLE | `data/DS-EXAMPLE/` |",
            "| TSD-EXAMPLE | `technical/TSD-EXAMPLE.md` |",
        ]
    else:
        footer_note = (
            "> 本索引仅登记本层首次定义样例（API/TBL/MW/CMP）。"
            "上游 BD/SYS/MDG/TSD 等以纯 ID 引用公司/系统 SSOT，本层不落 reference 文件。"
            "产品 **PL/SLN** 见公司；**PD/PM** 见系统层。"
        )
        mapping_rows = [
            "| API-EXAMPLE | `application/MS-EXAMPLE/API-EXAMPLE.md` |",
            "| TBL-EXAMPLE | `data/DS-EXAMPLE/TBL-EXAMPLE.md` |",
            "| MW-EXAMPLE | `technical/MW-EXAMPLE/` |",
        ]

    return "\n".join(
        [
            footer_note,
            "",
            "---",
            "",
            "### 物化目录映射（示例）",
            "",
            "| 索引 ID | 命名式 ID（锚点目录） |",
            "|---------|----------------------|",
            *mapping_rows,
            "",
            "---",
            "",
            "### 交叉引用",
            "",
            "- 目录索引：`knowledge/index.md`",
            "- 应用：`knowledge/application/`",
            "- 业务：`knowledge/business/`",
            "- 产品：`knowledge/product/`",
            "- 数据：`knowledge/data/`",
            "- 技术：`knowledge/technical/`",
            "- 知识库总说明：`knowledge/README.md`",
        ]
    )


ENTITY_BEGIN = "<!-- docs-build:entity-index:begin -->"
ENTITY_END = "<!-- docs-build:entity-index:end -->"


def render_knowledge_index(
    bundle_root: Path,
    bundle: str = "application",
) -> str:
    """渲染第五章实体表正文（无 YAML；扫描生成、非 SSOT）。供测试与 patch 复用。"""
    concepts = _load_concepts(bundle_root)
    suffix = _default_suffix(bundle)

    parts = [
        "> 扫描生成；非 SSOT。实体正文 ∈ 各视角 per-entity `{ID}.md`。九章骨架由 `/docs-indexing` 维护；本块由 `/docs-build` 写入。",
        "",
        "### 统一表头规范",
        "",
        '- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`',
        "- **字段语义**：`ID` 为完整实体 ID（如 `VC-EXAMPLE`）；`别名（英文名）` 为英文编码；`名称` 为中文名称",
        "- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一",
        "",
    ]

    for heading, perspective, hierarchies in _perspective_sections(bundle):
        parts.append(_render_section(heading, perspective, hierarchies, concepts).rstrip())
        parts.append("")

    parts.append(suffix.rstrip())
    return "\n".join(parts).rstrip() + "\n"


def render_entity_index_block(bundle_root: Path, bundle: str = "application") -> str:
    inner = render_knowledge_index(bundle_root, bundle).rstrip()
    return f"{ENTITY_BEGIN}\n{inner}\n{ENTITY_END}\n"


def patch_index_guide(existing: str, block: str) -> str:
    """替换 INDEX-GUIDE 第五章内实体块；无标记则替换「五、」至「六、」之间。"""
    block = block.rstrip() + "\n"
    if ENTITY_BEGIN in existing and ENTITY_END in existing:
        pattern = re.compile(
            re.escape(ENTITY_BEGIN) + r".*?" + re.escape(ENTITY_END),
            re.DOTALL,
        )
        return pattern.sub(block.rstrip(), existing, count=1)

    chapter = re.search(
        r"(## 五、[^\n]*\n)(.*?)(\n## 六、)",
        existing,
        flags=re.DOTALL,
    )
    if chapter:
        return (
            existing[: chapter.start()]
            + chapter.group(1)
            + "\n"
            + block
            + chapter.group(3)
            + existing[chapter.end() :]
        )
    raise ValueError("INDEX-GUIDE.md 缺少「## 五、」或实体块标记，无法写入")


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="将实体扫描表写入 bundle/INDEX-GUIDE.md 第五章（docs-build）"
    )
    parser.add_argument("--bundle", required=True, help="bundle 名称，如 application")
    parser.add_argument("--dry-run", action="store_true", help="仅输出实体块到 stdout")
    args = parser.parse_args(argv)

    repo = _repo_root()
    bundle_root = _bundle_root(repo, args.bundle)
    if not bundle_root.is_dir():
        print(f"error: bundle 不存在: {bundle_root}", file=sys.stderr)
        return 1

    out_path = bundle_root / "INDEX-GUIDE.md"
    block = render_entity_index_block(bundle_root, args.bundle)

    if args.dry_run:
        print(block)
        return 0

    if not out_path.is_file():
        print(f"error: 缺少 INDEX-GUIDE.md（先 /docs-indexing）: {out_path}", file=sys.stderr)
        return 1

    patched = patch_index_guide(out_path.read_text(encoding="utf-8"), block)
    if not patched.endswith("\n"):
        patched += "\n"
    out_path.write_text(patched, encoding="utf-8")
    stale = bundle_root / "knowledge" / "KNOWLEDGE-INDEX.md"
    if stale.is_file():
        stale.unlink()
        print(f"removed {stale.relative_to(repo)}")
    stale_guide = bundle_root / "knowledge" / "INDEX-GUIDE.md"
    if stale_guide.is_file():
        stale_guide.unlink()
        print(f"removed {stale_guide.relative_to(repo)}")
    print(f"patched {out_path.relative_to(repo)} 第五章")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
