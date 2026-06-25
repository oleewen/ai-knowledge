#!/usr/bin/env python3
"""将 *-entities.md 表格迁移为 OKF concept 文件。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402

NULL_MARKERS = frozenset({"", "—", "–", "-", "null", "~"})
TIMESTAMP = "2026-06-21T00:00:00Z"

# ID 前缀 → 默认视角（用于跨视角链接）
PREFIX_PERSPECTIVE: Dict[str, str] = {
    "BD": "business",
    "BSD": "business",
    "BC": "business",
    "AGG": "business",
    "AB": "business",
    "PL": "product",
    "PM": "product",
    "FT": "product",
    "UC": "product",
    "SYS": "application",
    "APP": "application",
    "MS": "application",
    "API": "application",
    "DS": "data",
    "ENT": "data",
    "MW": "technical",
    "CMP": "technical",
    "TSD": "technical",
    "CAP": "business",
    "MDG": "data",
    "TPL": "technical",
}

RELATION_FIELDS: Set[str] = {
    "parent_id",
    "children",
    "aggregates",
    "abilities",
    "bounded_contexts",
    "parent_mw_id",
    "parent_tsd_id",
    "parent_sys_id",
    "service_id",
}

CROSS_PERSPECTIVE_FIELDS: Set[str] = {
    "implemented_by_app_id",
    "persisted_as_entity_ids",
    "implemented_by_service_ids",
    "invokes_api_ids",
    "realizes_use_case_ids",
    "map_to_api_id",
    "owned_by_app_id",
    "maps_to_aggregate_id",
    "bound_app_id",
    "cross_references",
    "apis",
    "service_ids",
}

FRONTMATTER_SKIP: Set[str] = {
    "hierarchy",
    "full_id",
    "name",
    "description",
    "evidence_source",
    "id",
}

APPLICATION_SECTIONS = ("SYS", "APP", "MS", "API")


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def normalize_cell(raw: str) -> Optional[str]:
    val = raw.strip()
    if val in NULL_MARKERS:
        return None
    return val


def split_multi_value(val: Optional[str]) -> List[str]:
    if val is None:
        return []
    parts: List[str] = []
    for chunk in re.split(r"[;；]", val):
        chunk = chunk.strip()
        if not chunk or chunk in NULL_MARKERS:
            continue
        parts.append(chunk)
    return parts


def extract_id_token(token: str) -> str:
    """从 'API-EXAMPLE-001 / Example.create' 等取值中提取 ID。"""
    token = token.strip()
    if not token:
        return token
    if "/" in token:
        token = token.split("/", 1)[0].strip()
    m = re.match(r"^([A-Z][A-Z0-9_]*(?:-[A-Z0-9_]+)+)", token)
    if m:
        return m.group(1)
    return token


def parse_table_block(lines: List[str]) -> Tuple[List[str], List[Dict[str, Optional[str]]]]:
    """解析 markdown 表格，返回 (headers, rows)。"""
    if len(lines) < 2:
        return [], []
    header_line = lines[0].strip()
    if not header_line.startswith("|"):
        return [], []
    headers = [h.strip() for h in header_line.strip("|").split("|")]
    rows: List[Dict[str, Optional[str]]] = []
    for line in lines[2:]:
        line = line.strip()
        if not line.startswith("|"):
            break
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < len(headers):
            cells.extend([""] * (len(headers) - len(cells)))
        row = {headers[i]: normalize_cell(cells[i]) for i in range(len(headers))}
        rows.append(row)
    return headers, rows


def parse_entities_file(path: Path, perspective: str) -> List[Dict[str, Any]]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    entities: List[Dict[str, Any]] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if not line.startswith("## "):
            i += 1
            continue
        section = line[3:].strip()
        i += 1
        while i < len(lines) and not lines[i].strip():
            i += 1
        if i >= len(lines):
            break
        table_lines: List[str] = []
        while i < len(lines) and lines[i].strip().startswith("|"):
            table_lines.append(lines[i])
            i += 1
        if not table_lines:
            continue
        headers, rows = parse_table_block(table_lines)
        if not rows:
            continue

        if perspective == "application" and section in APPLICATION_SECTIONS:
            hierarchy = section
            for row in rows:
                entity = dict(row)
                if hierarchy in ("MS", "API") and "id" in entity:
                    entity["full_id"] = entity.pop("id")
                entity["hierarchy"] = hierarchy
                if hierarchy == "APP" and entity.get("parent_sys_id"):
                    entity["parent_id"] = entity["parent_sys_id"]
                elif hierarchy == "API" and entity.get("service_id"):
                    entity["parent_id"] = entity["service_id"]
                entities.append(entity)
        elif section == "实体总表":
            for row in rows:
                entity = dict(row)
                if entity.get("full_id"):
                    entities.append(entity)
    return entities


def build_entity_index(all_entities: List[Dict[str, Any]]) -> Dict[str, Dict[str, Any]]:
    index: Dict[str, Dict[str, Any]] = {}
    for ent in all_entities:
        fid = ent.get("full_id")
        if fid:
            index[fid] = ent
    return index


def _perspective_for_id(full_id: str) -> Optional[str]:
    prefix = full_id.split("-", 1)[0]
    return PREFIX_PERSPECTIVE.get(prefix)


def _flat_application_link(full_id: str) -> str:
    return okf_lib.to_bundle_link(f"knowledge/application/{full_id}.md")


def id_to_link(
    full_id: str,
    entity_index: Dict[str, Dict[str, Any]],
    *,
    cross_perspective: bool = False,
    bundle: str = "application",
) -> str:
    prefix = full_id.split("-", 1)[0]
    if cross_perspective and prefix in ("APP", "MS", "API"):
        return _flat_application_link(full_id)

    perspective = _perspective_for_id(full_id)
    if not perspective:
        return okf_lib.to_bundle_link(f"knowledge/{full_id}.md")

    parent_id: Optional[str] = None
    ent = entity_index.get(full_id)
    if ent:
        parent_id = ent.get("parent_id") or ent.get("parent_sys_id") or ent.get("service_id")
    if prefix == "ENT" and not parent_id:
        parent_id = "DS-EXAMPLE"

    relpath = okf_lib.entity_relpath(perspective, full_id, parent_id, bundle=bundle)
    return okf_lib.to_bundle_link(relpath)


def format_link(
    full_id: str,
    entity_index: Dict[str, Dict[str, Any]],
    *,
    cross: bool,
    bundle: str = "application",
) -> str:
    link = id_to_link(full_id, entity_index, cross_perspective=cross, bundle=bundle)
    return f"[{full_id}]({link})"


def format_field_links(
    field: str,
    value: Optional[str],
    entity_index: Dict[str, Dict[str, Any]],
    bundle: str = "application",
) -> List[str]:
    if value is None:
        return []
    cross = field in CROSS_PERSPECTIVE_FIELDS
    tokens = split_multi_value(value) if field in CROSS_PERSPECTIVE_FIELDS | RELATION_FIELDS else [value]
    lines: List[str] = []
    for token in tokens:
        fid = extract_id_token(token)
        if not fid or fid in NULL_MARKERS:
            continue
        if re.match(r"^[A-Z][A-Z0-9_]*(?:-[A-Z0-9_]+)+$", fid):
            lines.append(format_link(fid, entity_index, cross=cross, bundle=bundle))
        else:
            lines.append(token)
    return lines


def build_concept_content(
    entity: Dict[str, Any],
    perspective: str,
    entity_index: Dict[str, Dict[str, Any]],
    bundle: str = "application",
) -> str:
    hierarchy = entity.get("hierarchy") or entity.get("full_id", "").split("-", 1)[0]
    full_id = entity["full_id"]
    parent_id = entity.get("parent_id") or entity.get("parent_sys_id") or entity.get("service_id")
    name = entity.get("name") or full_id
    description = entity.get("description")

    meta: Dict[str, Any] = {
        "type": okf_lib.hierarchy_to_type(hierarchy),
        "title": name,
        "description": description,
        "tags": [perspective, hierarchy],
        "timestamp": TIMESTAMP,
        "full_id": full_id,
        "perspective": perspective,
        "hierarchy": hierarchy,
        "parent_id": parent_id,
    }
    if bundle == "system":
        meta["layer_scope"] = "system"
    elif bundle == "company":
        meta["layer_scope"] = "company"
        meta["definition_scope"] = "local"
    extra_meta_keys: Set[str] = set()
    for key, val in entity.items():
        if key in FRONTMATTER_SKIP or key in RELATION_FIELDS or key in CROSS_PERSPECTIVE_FIELDS:
            continue
        if key in ("parent_sys_id", "service_id"):
            continue
        if val is not None:
            meta[key] = val
            extra_meta_keys.add(key)

    relation_lines: List[str] = []
    if parent_id:
        relation_lines.append(
            f"- parent: {format_link(parent_id, entity_index, cross=False, bundle=bundle)}"
        )
    for field in ("children", "aggregates", "abilities", "bounded_contexts"):
        val = entity.get(field)
        if not val:
            continue
        links = format_field_links(field, val, entity_index, bundle=bundle)
        if links:
            relation_lines.append(f"- {field}:")
            for link in links:
                relation_lines.append(f"  - {link}")

    if perspective == "application":
        if entity.get("parent_sys_id"):
            ps = entity["parent_sys_id"]
            relation_lines.append(
                f"- parent_sys_id: {format_link(ps, entity_index, cross=False, bundle=bundle)}"
            )
        if entity.get("service_id"):
            sid = entity["service_id"]
            relation_lines.append(
                f"- service_id: {format_link(sid, entity_index, cross=False, bundle=bundle)}"
            )
        if entity.get("service_ids"):
            links = format_field_links("service_ids", entity["service_ids"], entity_index)
            if links:
                relation_lines.append("- service_ids:")
                for link in links:
                    relation_lines.append(f"  - {link}")

    cross_lines: List[str] = []
    for field in sorted(CROSS_PERSPECTIVE_FIELDS):
        val = entity.get(field)
        if not val or field in ("service_ids",):
            continue
        links = format_field_links(field, val, entity_index, bundle=bundle)
        if links:
            if len(links) == 1:
                cross_lines.append(f"- {field}: {links[0]}")
            else:
                cross_lines.append(f"- {field}:")
                for link in links:
                    cross_lines.append(f"  - {link}")

    detail_keys = [
        k
        for k in entity
        if k not in FRONTMATTER_SKIP
        and k not in RELATION_FIELDS
        and k not in CROSS_PERSPECTIVE_FIELDS
        and k not in extra_meta_keys
        and k not in ("parent_sys_id", "service_id", "hierarchy", "full_id")
        and entity.get(k) is not None
    ]
    detail_lines: List[str] = []
    for key in sorted(detail_keys):
        val = entity[key]
        if val is not None:
            detail_lines.append(f"- {key}: {val}")

    evidence = entity.get("evidence_source") or ""

    body_parts = ["## 关系", ""]
    body_parts.extend(relation_lines if relation_lines else ["- (none)"])
    body_parts.extend(["", "## 跨视角", ""])
    body_parts.extend(cross_lines if cross_lines else ["- (none)"])
    body_parts.extend(["", "## 详细说明", ""])
    body_parts.extend(detail_lines if detail_lines else ["- (none)"])
    body_parts.extend(["", "## 依据与证据", "", evidence, ""])

    return okf_lib.format_frontmatter(meta) + "\n".join(body_parts)


def load_global_entity_index(bundle_root: Path) -> Dict[str, Dict[str, Any]]:
    """从 bundle 下各视角 *-entities.md 构建全局 ID 索引（迁移过程中仍可用）。"""
    index: Dict[str, Dict[str, Any]] = {}
    for perspective in ("business", "product", "application", "data", "technical"):
        path = bundle_root / "knowledge" / perspective / f"{perspective}-entities.md"
        if not path.is_file():
            continue
        for ent in parse_entities_file(path, perspective):
            fid = ent.get("full_id")
            if fid:
                ent["_perspective"] = perspective
                index[fid] = ent
    return index


def migrate(
    bundle: str,
    entities_path: Path,
    perspective: str,
    dry_run: bool = False,
    global_index: Optional[Dict[str, Dict[str, Any]]] = None,
) -> List[Path]:
    repo = _repo_root()
    bundle_root = repo / bundle
    entities = parse_entities_file(entities_path, perspective)
    entity_index = global_index if global_index is not None else build_entity_index(entities)
    written: List[Path] = []

    for entity in entities:
        full_id = entity.get("full_id")
        if not full_id:
            continue
        parent_id = (
            entity.get("parent_id")
            or entity.get("parent_sys_id")
            or entity.get("service_id")
        )
        relpath = okf_lib.entity_relpath(perspective, full_id, parent_id, bundle=bundle)
        out_path = bundle_root / relpath
        content = build_concept_content(entity, perspective, entity_index, bundle=bundle)

        if dry_run:
            print(f"[dry-run] would write: {out_path.relative_to(repo)}")
            print(content[:200] + "...\n")
        else:
            out_path.parent.mkdir(parents=True, exist_ok=True)
            out_path.write_text(content, encoding="utf-8")
        written.append(out_path)

    return written


def main() -> None:
    parser = argparse.ArgumentParser(description="迁移 *-entities.md 至 OKF concept 文件")
    parser.add_argument(
        "--bundle",
        default="application",
        help="bundle 根目录（相对仓库根，默认 application）",
    )
    parser.add_argument(
        "--entities",
        required=True,
        help="*-entities.md 路径（相对仓库根或绝对路径）",
    )
    parser.add_argument(
        "--perspective",
        required=True,
        choices=["business", "product", "application", "data", "technical"],
        help="视角",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="仅打印将写入的内容，不实际写文件",
    )
    args = parser.parse_args()

    repo = _repo_root()
    entities_path = Path(args.entities)
    if not entities_path.is_absolute():
        entities_path = repo / entities_path
    if not entities_path.is_file():
        print(f"错误: 找不到实体文件 {entities_path}", file=sys.stderr)
        sys.exit(1)

    bundle_root = repo / args.bundle
    global_index = load_global_entity_index(bundle_root)

    written = migrate(
        args.bundle,
        entities_path,
        args.perspective,
        dry_run=args.dry_run,
        global_index=global_index,
    )
    action = "would write" if args.dry_run else "wrote"
    print(f"{action} {len(written)} concept file(s) for perspective={args.perspective}")


if __name__ == "__main__":
    main()
