#!/usr/bin/env python3
# OKF 共享库：frontmatter、type 映射、concept 路径；见 docs/superpowers/plans/2026-06-21-application-okf.md

from __future__ import annotations

import re
from pathlib import Path
from typing import Any, Dict, Iterator, List, Optional, Tuple

OKF_RESERVED_NAMES = frozenset({"index.md", "log.md"})
FRONTMATTER_RE = re.compile(r"\A---\r?\n(.*?)\r?\n---\r?\n?", re.DOTALL)

HIERARCHY_TO_TYPE: Dict[str, str] = {
    "BD": "Business Domain",
    "BSD": "Business Subdomain",
    "BC": "Bounded Context",
    "AGG": "Aggregate",
    "AB": "Ability",
    "PL": "Product Line",
    "PM": "Product Module",
    "FT": "Feature",
    "UC": "Use Case",
    "SYS": "System",
    "APP": "Application",
    "MS": "Microservice",
    "API": "API Endpoint",
    "DS": "Data Store",
    "ENT": "Entity",
    "MW": "Middleware Binding",
    "CMP": "Component",
}

PERSPECTIVE_DOMAIN_ANCHOR: Dict[str, str] = {
    "business": "BSD-EXAMPLE",
    "product": "PM-EXAMPLE",
    "application": "MS-EXAMPLE",
    "data": "ENT-EXAMPLE",
    "technical": "MW-EXAMPLE",
}

# legacy：嵌套锚点规则（迁移前）；新落盘见 entity_relpath + PERSPECTIVE_DOMAIN_ANCHOR
PERSPECTIVE_ANCHOR_RULES: Dict[str, str] = {
    "business": "BD",
    "product": "PL",
    "application": "SYS",
    "data": "DS",
}

# application 层 reference concept（非本层 SSOT）
REFERENCE_FULL_IDS = frozenset(
    {
        "BD-EXAMPLE",
        "PL-EXAMPLE",
        "SYS-EXAMPLE",
        "APP-EXAMPLE",
        "MS-EXAMPLE",
        "DS-EXAMPLE",
        "ENT-EXAMPLE",
    }
)

_DEFAULT_PRODUCT_PL = "PL-EXAMPLE"
_DEFAULT_PRODUCT_PM = "PM-EXAMPLE"
_DEFAULT_DATA_DS = "DS-EXAMPLE"


def _id_prefix(full_id: str) -> str:
    return full_id.split("-", 1)[0]


def _parse_scalar(val: str) -> Any:
    val = val.strip()
    if val in ("null", "~", ""):
        return None
    if val.startswith("[") and val.endswith("]"):
        inner = val[1:-1].strip()
        if not inner:
            return []
        return [_strip_quotes(x.strip()) for x in inner.split(",") if x.strip()]
    return _strip_quotes(val)


def _strip_quotes(val: str) -> str:
    if len(val) >= 2 and val[0] == val[-1] and val[0] in ('"', "'"):
        return val[1:-1]
    return val


def parse_frontmatter(text: str) -> Tuple[Dict[str, Any], str]:
    """解析 YAML frontmatter（字符串、行内列表、null）。"""
    m = FRONTMATTER_RE.match(text)
    if not m:
        return {}, text
    block = m.group(1)
    body = text[m.end():]
    meta: Dict[str, Any] = {}
    for line in block.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if ":" not in line:
            continue
        key, val = line.split(":", 1)
        key = key.strip()
        meta[key] = _parse_scalar(val)
    return meta, body


def format_frontmatter(meta: Dict[str, Any]) -> str:
    """将 meta 序列化为 YAML frontmatter 块（含首尾 ---）。"""
    lines = ["---"]
    for key, val in meta.items():
        lines.append(f"{key}: {_format_yaml_value(val)}")
    lines.append("---")
    return "\n".join(lines) + "\n"


def _format_yaml_value(val: Any) -> str:
    if val is None:
        return "null"
    if isinstance(val, bool):
        return "true" if val else "false"
    if isinstance(val, list):
        if not val:
            return "[]"
        items = ", ".join(_format_yaml_scalar(x) for x in val)
        return f"[{items}]"
    return _format_yaml_scalar(val)


def _format_yaml_scalar(val: Any) -> str:
    if val is None:
        return "null"
    s = str(val)
    if s == "" or any(c in s for c in ":[]{}#&*!|>'\"%@`"):
        return f'"{s}"'
    return s


def hierarchy_to_type(hierarchy: str) -> str:
    return HIERARCHY_TO_TYPE.get(hierarchy, hierarchy)


def perspective_domain_anchor(perspective: str, full_id: Optional[str] = None) -> str:
    """域扁平树：返回 perspective 下域文件夹名（示例 ID 用 PERSPECTIVE_DOMAIN_ANCHOR）。"""
    return PERSPECTIVE_DOMAIN_ANCHOR.get(perspective, full_id or "")


def entity_relpath(
    perspective: str,
    full_id: str,
    parent_id: Optional[str] = None,
) -> str:
    """相对 application/ bundle 根的 concept 路径（域扁平树）。"""
    prefix = _id_prefix(full_id)
    if perspective == "application" and prefix in ("SYS", "APP"):
        return f"knowledge/application/{full_id}.md"
    if perspective == "business" and prefix == "BD":
        return f"knowledge/business/{full_id}.md"
    if perspective == "data" and prefix == "DS":
        return f"knowledge/data/{full_id}.md"
    if perspective == "product" and prefix == "PL":
        return f"knowledge/product/{full_id}.md"
    anchor = perspective_domain_anchor(perspective, full_id)
    if not anchor:
        return f"knowledge/{perspective}/{full_id}.md"
    return f"knowledge/{perspective}/{anchor}/{full_id}.md"


def to_bundle_link(relpath: str) -> str:
    if not relpath.startswith("/"):
        return "/" + relpath.lstrip("/")
    return relpath


def is_concept_file(path: Path) -> bool:
    return path.suffix == ".md" and path.name not in OKF_RESERVED_NAMES


def scan_concepts(bundle_root: Path) -> Iterator[Path]:
    """遍历 bundle 下所有 concept 文件路径（相对 bundle_root 的绝对 Path）。"""
    root = bundle_root.resolve()
    if not root.is_dir():
        return
    for path in sorted(root.rglob("*.md")):
        if is_concept_file(path):
            yield path
