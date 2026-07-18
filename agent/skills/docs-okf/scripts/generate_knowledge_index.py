#!/usr/bin/env python3
"""从 bundle concept 文件重建 index.md。"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402

_APPLICATION_PERSPECTIVE_SECTIONS: List[Tuple[str, str, List[str]]] = [
    (
        "§1 业务视角（business · BD → BSD → BC → AGG → AB）",
        "business",
        ["BD", "BSD", "BC", "AGG", "AB"],
    ),
    (
        "§2 产品视角（product · PL → PM → FT → FR → UC/BR · BP）",
        "product",
        ["PL", "PM", "FT", "FR", "UC", "BR", "BP"],
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
        "§1 业务视角（business · BD / CAP）",
        "business",
        ["BD", "CAP"],
    ),
    (
        "§2 产品视角（product · PL）",
        "product",
        ["PL"],
    ),
    (
        "§3 应用视角（application · SYS）",
        "application",
        ["SYS"],
    ),
    (
        "§4 数据视角（data · MDG）",
        "data",
        ["MDG"],
    ),
    (
        "§5 技术视角（technical · TPL）",
        "technical",
        ["TPL"],
    ),
]


def _perspective_sections(bundle: str) -> List[Tuple[str, str, List[str]]]:
    if bundle == "company":
        return list(_COMPANY_PERSPECTIVE_SECTIONS)
    sections = list(_APPLICATION_PERSPECTIVE_SECTIONS)
    if bundle == "system":
        # API 仅 application SSOT；MDG 为本层 company reference
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


def _id_suffix(full_id: str) -> str:
    if "-" not in full_id:
        return full_id
    return full_id.split("-", 1)[1]


def _load_concepts(bundle_root: Path) -> List[Dict[str, Any]]:
    concepts: List[Dict[str, Any]] = []
    root = bundle_root.resolve()
    for path in okf_lib.scan_concepts(root):
        text = path.read_text(encoding="utf-8")
        meta, _ = okf_lib.parse_frontmatter(text)
        full_id = meta.get("full_id")
        if not full_id:
            continue
        hierarchy = str(meta.get("hierarchy") or full_id.split("-", 1)[0])
        perspective = str(meta.get("perspective") or "")
        parent_id = meta.get("parent_id")
        parent = None if parent_id in (None, "null") else str(parent_id)
        relpath = path.resolve().relative_to(root).as_posix()
        evidence = relpath
        if evidence.startswith("knowledge/"):
            evidence = evidence[len("knowledge/") :]
        concepts.append(
            {
                "full_id": str(full_id),
                "hierarchy": hierarchy,
                "perspective": perspective,
                "parent_id": parent,
                "title": str(meta.get("title") or full_id),
                "alias": str(meta.get("alias") or meta.get("name") or ""),
                "evidence": evidence,
                "path": path,
            }
        )
    return concepts


def _forest_sort(concepts: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """同批实体：无 parent 在前，父先于子；环/断链按 full_id 回退。"""
    by_id = {c["full_id"]: c for c in concepts}
    children: Dict[Optional[str], List[str]] = {}
    for c in concepts:
        parent = c["parent_id"] if c["parent_id"] in by_id else None
        children.setdefault(parent, []).append(c["full_id"])
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
    # 断链残留（parent 不在本批）
    for c in sorted(concepts, key=lambda x: x["full_id"]):
        if c["full_id"] not in seen:
            walk(c["full_id"])
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
    # 先按 hierarchy 分组序，组内森林序
    grouped: List[Dict[str, Any]] = []
    for hierarchy in hierarchies:
        group = [c for c in filtered if c["hierarchy"] == hierarchy]
        grouped.extend(_forest_sort(group))
    # 未在 hierarchies 显式列出的（不应出现）按 full_id 追加
    listed = {c["full_id"] for c in grouped}
    for c in sorted(filtered, key=lambda x: x["full_id"]):
        if c["full_id"] not in listed:
            grouped.append(c)
    return grouped


def _render_table_rows(concepts: List[Dict[str, Any]]) -> List[str]:
    rows = [
        "| 层级 | ID | 别名（英文名） | 名称 | 证据链 |",
        "|------|----|--------------|------|---------|",
    ]
    for concept in concepts:
        rows.append(
            "| {hierarchy} | {id_suffix} | {alias} | {title} | `{evidence}` |".format(
                hierarchy=concept["hierarchy"],
                id_suffix=_id_suffix(concept["full_id"]),
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
    lines = [f"## {heading}", ""]
    lines.extend(_render_table_rows(section_concepts))
    lines.append("")
    return "\n".join(lines)


def _strip_frontmatter(text: str) -> str:
    """knowledge/index.md 按 OKF §6 禁止 frontmatter；生成时一律剥除。"""
    _, body = okf_lib.parse_frontmatter(text)
    return body.lstrip("\n") if text.startswith("---") else text


def _split_existing(text: str) -> Tuple[str, str]:
    """返回 (header_prefix, footer_suffix)。"""
    text = _strip_frontmatter(text)
    lines = text.splitlines()
    prefix_lines: List[str] = []
    suffix_lines: List[str] = []
    section_markers = (
        "## 统一表头规范",
        "## §1 ",
        "## 物化目录映射",
    )

    i = 0
    while i < len(lines):
        if any(lines[i].startswith(marker) for marker in section_markers):
            break
        prefix_lines.append(lines[i])
        i += 1

    while i < len(lines):
        if lines[i].startswith("## 物化目录映射"):
            suffix_lines = lines[i:]
            break
        if lines[i].startswith("> 公司级 **TPL-"):
            suffix_lines = lines[i:]
            break
        i += 1

    prefix = "\n".join(prefix_lines).rstrip()
    suffix = "\n".join(suffix_lines).rstrip()
    return prefix, suffix


def _default_suffix(bundle: str) -> str:
    if bundle == "company":
        footer_note = (
            "> 本索引登记公司级 **BD / CAP / PL / SYS / MDG / TPL**；"
            "系统层与应用层实体见对应 bundle 的 `knowledge/index.md`。"
        )
        mapping_rows = [
            "| BD-EXAMPLE | `business/BD-EXAMPLE/` |",
            "| CAP-EXAMPLE-L1 | `business/BD-EXAMPLE/CAP-EXAMPLE-L1.md` |",
            "| CAP-EXAMPLE | `business/BD-EXAMPLE/CAP-EXAMPLE.md` |",
            "| PL-EXAMPLE | `product/PL-EXAMPLE.md` |",
            "| SYS-EXAMPLE | `application/SYS-EXAMPLE.md` |",
            "| MDG-EXAMPLE | `data/MDG-EXAMPLE.md` |",
            "| TPL-EXAMPLE | `technical/TPL-EXAMPLE.md` |",
        ]
    elif bundle == "system":
        footer_note = (
            "> 公司级 **TPL-*** 不在本索引登记；见 `company/knowledge/technical/`。"
            "系统级 **TSD-*** 在本索引 §5 登记。"
        )
        mapping_rows = [
            "| BD-EXAMPLE | `business/BD-EXAMPLE.md` |",
            "| PL-EXAMPLE | `product/PL-EXAMPLE.md` |",
            "| SYS-EXAMPLE | `application/SYS-EXAMPLE.md` |",
            "| MDG-EXAMPLE | `data/MDG-EXAMPLE.md` |",
            "| DS-EXAMPLE | `data/DS-EXAMPLE/` |",
        ]
    else:
        footer_note = (
            "> 公司级 **TPL-*** 不在本索引登记（见 `company/knowledge/technical/`）。"
            "本层登记 **TSD/MDG** reference 与 **API/TBL/MW/CMP** SSOT。"
        )
        mapping_rows = [
            "| BD-EXAMPLE | `business/BD-EXAMPLE.md` |",
            "| PL-EXAMPLE | `product/PL-EXAMPLE.md` |",
            "| SYS-EXAMPLE | `application/SYS-EXAMPLE.md` |",
            "| MDG-EXAMPLE | `data/MDG-EXAMPLE.md` |",
            "| TBL-EXAMPLE | `data/DS-EXAMPLE/TBL-EXAMPLE.md` |",
            "| TSD-EXAMPLE | `technical/TSD-EXAMPLE.md` |",
            "| DS-EXAMPLE | `data/DS-EXAMPLE/` |",
        ]

    return "\n".join(
        [
            footer_note,
            "",
            "---",
            "",
            "## 物化目录映射（示例）",
            "",
            "| 索引 ID | 命名式 ID（锚点目录） |",
            "|---------|----------------------|",
            *mapping_rows,
            "",
            "---",
            "",
            "## 交叉引用",
            "",
            "- 应用：`application/`",
            "- 业务：`business/`",
            "- 产品：`product/`",
            "- 数据：`data/`",
            "- 技术：`technical/`",
            "- 知识库总说明：`README.md`",
        ]
    )


def render_knowledge_index(
    bundle_root: Path,
    existing_text: Optional[str] = None,
    bundle: str = "application",
) -> str:
    concepts = _load_concepts(bundle_root)
    if existing_text:
        prefix, _suffix = _split_existing(existing_text)
    else:
        # 无 frontmatter（OKF §6：子目录 index.md 不含 YAML）
        prefix = "# 知识库 · 五视角实体 ID 索引（SSOT）"

    if not prefix.strip():
        prefix = "# 知识库 · 五视角实体 ID 索引（SSOT）"

    suffix = _default_suffix(bundle)

    header = prefix.rstrip()
    # 反复去掉尾部分隔线，避免多轮生成累积双 ---
    while True:
        stripped = header.rstrip()
        if stripped.endswith("---"):
            header = stripped[:-3].rstrip()
            continue
        header = stripped
        break

    parts = [header, "", "---", ""]
    parts.append("## 统一表头规范")
    parts.append("")
    parts.append('- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`')
    parts.append('- **字段语义**：`ID` 为示例编码，`别名（英文名）` 为英文编码，`名称` 为中文名称')
    parts.append('- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一')
    parts.append("")
    parts.append("---")
    parts.append("")

    for heading, perspective, hierarchies in _perspective_sections(bundle):
        parts.append(_render_section(heading, perspective, hierarchies, concepts).rstrip())
        parts.append("")
        parts.append("---")
        parts.append("")

    parts.append(suffix.rstrip())
    return "\n".join(parts).rstrip() + "\n"


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="重建 bundle index.md")
    parser.add_argument("--bundle", required=True, help="bundle 名称，如 application")
    parser.add_argument("--dry-run", action="store_true", help="仅输出到 stdout")
    args = parser.parse_args(argv)

    repo = _repo_root()
    bundle_root = _bundle_root(repo, args.bundle)
    if not bundle_root.is_dir():
        print(f"error: bundle 不存在: {bundle_root}", file=sys.stderr)
        return 1

    index_path = bundle_root / "knowledge" / "index.md"
    existing = index_path.read_text(encoding="utf-8") if index_path.is_file() else None
    rendered = render_knowledge_index(bundle_root, existing, args.bundle)

    if args.dry_run:
        print(rendered)
        return 0

    index_path.parent.mkdir(parents=True, exist_ok=True)
    index_path.write_text(rendered, encoding="utf-8")
    print(f"wrote {index_path.relative_to(repo)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
