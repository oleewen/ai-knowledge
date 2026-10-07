#!/usr/bin/env python3
# OKF 共享库：frontmatter、type 映射、concept 路径；细则见 /docs-okf 与 agent/knowledge/naming-conventions.md §OKF

from __future__ import annotations

import re
import os
from pathlib import Path
from typing import Any, Dict, Iterator, List, Optional, Tuple

OKF_RESERVED_NAMES = frozenset({"index.md", "log.md", "INDEX-GUIDE.md", "KNOWLEDGE-INDEX.md"})
FRONTMATTER_RE = re.compile(r"\A---\r?\n(.*?)\r?\n---\r?\n?", re.DOTALL)

# OKF v1 frontmatter 必填 9 字段（SSOT：agent/knowledge/okf-spec.md §2）
REQUIRED_FRONTMATTER_FIELDS = (
    "type",
    "title",
    "description",
    "tags",
    "timestamp",
    "id",
    "perspective",
    "hierarchy",
    "layer_scope",
)

# OKF v1 正文 4 段的中文落地标题；旧英文标题仅作为迁移兼容输入
REQUIRED_SECTIONS = ("关系", "跨视角", "详细说明", "依据与证据")
LEGACY_SECTION_ALIASES = {
    "Relations": "关系",
    "Cross-perspective": "跨视角",
    "Details": "详细说明",
    "Evidence": "依据与证据",
}
ALL_SECTION_TITLES = frozenset(REQUIRED_SECTIONS) | frozenset(LEGACY_SECTION_ALIASES.keys())

# OKF v1 合法 perspective 枚举
VALID_PERSPECTIVES = frozenset({"business", "product", "application", "data", "technical"})

# OKF v1 合法 layer_scope 枚举（okf-spec §2 / §11.1：application / system / solution / company）
VALID_LAYER_SCOPES = frozenset({"application", "system", "solution", "company"})

# ISO8601 时间戳正则（OKF v1 本仓统一北京时间 +08:00）
ISO8601_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+08:00$")


def find_repo_root(start: Path) -> Path:
    """向上查找仓库根；调用方可传提示路径，软链入口优先。"""
    hint_value = os.environ.get("DOCS_OKF_REPO_ROOT")
    hint = Path(hint_value).expanduser() if hint_value else None
    physical = start.resolve()
    if hint is not None and hint.is_dir():
        physical = hint
    lexical = start if start.is_absolute() else Path.cwd() / start
    lexical = Path(os.path.normpath(str(lexical)))

    seen = set()
    for p in (physical, *physical.parents, lexical, *lexical.parents):
        if p in seen:
            continue
        seen.add(p)
        if (p / ".docsconfig").exists() or (p / ".git").exists():
            return p
    raise RuntimeError(f"无法定位仓库根（未找到 .docsconfig/.git），start={p}")


def _bundle_walk(bundle_root: Path):
    """遍历 bundle；不进入隐藏目录或软链（含 .agents 与系统槽位）。"""
    root = bundle_root.resolve()
    if not root.is_dir():
        return
    for current, dirnames, filenames in os.walk(root, followlinks=False):
        dirnames[:] = sorted(
            name
            for name in dirnames
            if not name.startswith(".") and not (Path(current) / name).is_symlink()
        )
        for filename in sorted(filenames):
            if filename.endswith(".md"):
                yield Path(current) / filename


def iter_bundle_markdown_files(bundle_root: Path) -> Iterator[Path]:
    """遍历 bundle Markdown；不进入隐藏目录或软链。"""
    return _bundle_walk(bundle_root)


def iter_bundle_directories(bundle_root: Path) -> Iterator[Path]:
    """遍历 bundle 目录；不进入隐藏目录或软链（含 .agents 与系统槽位）。"""
    root = bundle_root.resolve()
    if not root.is_dir():
        return
    yield root
    for current, dirnames, _filenames in os.walk(root, followlinks=False):
        dirnames[:] = sorted(
            name
            for name in dirnames
            if not name.startswith(".") and not (Path(current) / name).is_symlink()
        )
        for dirname in dirnames:
            yield Path(current) / dirname


def normalize_section_heading(title: str) -> Optional[str]:
    title = title.strip()
    if title in REQUIRED_SECTIONS:
        return title
    return LEGACY_SECTION_ALIASES.get(title)

HIERARCHY_TO_TYPE: Dict[str, str] = {
    "VC": "Value Chain",
    "BD": "Business Domain",
    "BSD": "Business Subdomain",
    "BC": "Bounded Context",
    "AGG": "Aggregate",
    "AB": "Ability",
    "PL": "Product Line",
    "SLN": "Solution",
    "PD": "Product",
    "PM": "Product Module",
    "FT": "Feature",
    "FR": "Functional Requirement",
    "UC": "Use Case",
    "SYS": "System",
    "APP": "Application",
    "MS": "Microservice",
    "API": "API Endpoint",
    "DS": "Data Store",
    "ENT": "Entity",
    "MDG": "Master Data Domain",
    "MW": "Middleware Binding",
    "CMP": "Component",
    "TSD": "Technical Subdomain",
    "CAP": "Business Capability",
    "BL": "Business Line",
    "BS": "Business Service",
    "TPL": "Technical Platform",
    "BP": "Business Process",
    "BSP": "Business Subprocess",
    "BR": "Business Rule",
    "TBL": "Data Table",
}

APPLICATION_PERSPECTIVE_DOMAIN_ANCHOR: Dict[str, str] = {
    "business": "BSD-EXAMPLE",
    "product": "PM-EXAMPLE",
    "application": "MS-EXAMPLE",
    "data": "ENT-EXAMPLE",
    "technical": "MW-EXAMPLE",
}

SYSTEM_PERSPECTIVE_DOMAIN_ANCHOR: Dict[str, str] = {
    "business": "BSD-EXAMPLE",
    "product": "PD-EXAMPLE",
    "application": "MS-EXAMPLE",
    "data": "DS-EXAMPLE",
    "technical": "MW-EXAMPLE",
}

COMPANY_PERSPECTIVE_DOMAIN_ANCHOR: Dict[str, str] = {
    "business": "VC-EXAMPLE",
    "product": "PL-EXAMPLE",
    "application": "SLN-EXAMPLE",
    "data": "MDG-EXAMPLE",
    "technical": "TPL-EXAMPLE",
}

# 默认 application bundle 锚点（向后兼容）
PERSPECTIVE_DOMAIN_ANCHOR = APPLICATION_PERSPECTIVE_DOMAIN_ANCHOR

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
_DEFAULT_PRODUCT_PD = "PD-EXAMPLE"
_DEFAULT_PRODUCT_PM = "PM-EXAMPLE"
_DEFAULT_BUSINESS_VC = "VC-EXAMPLE"
_DEFAULT_DATA_DS = "DS-EXAMPLE"


def _id_prefix(id: str) -> str:
    return id.split("-", 1)[0]


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


HIERARCHY_TO_PERSPECTIVE: Dict[str, str] = {
    "BU": "business",
    "BD": "business",
    "BSD": "business",
    "BC": "business",
    "AGG": "business",
    "AB": "business",
    "CAP": "business",
    "BL": "business",
    "BS": "business",
    "PL": "product",
    "SLN": "application",
    "PD": "product",
    "PM": "product",
    "FT": "product",
    "FR": "product",
    "UC": "product",
    "BP": "product",
    "BSP": "product",
    "BR": "product",
    "SYS": "application",
    "APP": "application",
    "MS": "application",
    "API": "application",
    "MDG": "data",
    "DS": "data",
    "ENT": "data",
    "TBL": "data",
    "TPL": "technical",
    "TSD": "technical",
    "MW": "technical",
    "CMP": "technical",
}

# 首次定义层（SSOT：agent/knowledge/knowledge-governance.md「各层聚焦摘要」）
HIERARCHY_FIRST_LAYER: Dict[str, str] = {
    "VC": "company",
    "BD": "company",
    "CAP": "company",
    "BL": "company",
    "PL": "solution",
    "SLN": "company",
    "MDG": "company",
    "TPL": "company",
    "BSD": "system",
    "BC": "system",
    "AGG": "system",
    "AB": "system",
    "PD": "solution",
    "PM": "system",
    "BP": "solution",
    "BSP": "solution",
    "BS": "solution",
    "FT": "system",
    "FR": "system",
    "UC": "system",
    "BR": "system",
    "SYS": "system",
    "APP": "system",
    "MS": "system",
    "DS": "system",
    "ENT": "system",
    "TSD": "system",
    "API": "application",
    "TBL": "application",
    "MW": "application",
    "CMP": "application",
}


def hierarchy_first_layer(hierarchy: str) -> Optional[str]:
    return HIERARCHY_FIRST_LAYER.get(hierarchy)


def hierarchy_to_perspective(hierarchy: str) -> Optional[str]:
    return HIERARCHY_TO_PERSPECTIVE.get(hierarchy)


def perspective_domain_anchor(
    perspective: str,
    id: Optional[str] = None,
    bundle: str = "application",
) -> str:
    """域扁平树：返回 perspective 下域文件夹名。"""
    anchor_map = (
        COMPANY_PERSPECTIVE_DOMAIN_ANCHOR
        if bundle == "company"
        else SYSTEM_PERSPECTIVE_DOMAIN_ANCHOR
        if bundle == "system"
        else APPLICATION_PERSPECTIVE_DOMAIN_ANCHOR
    )
    return anchor_map.get(perspective, id or "")


_REL_ID_RE = re.compile(r"[A-Z][A-Z0-9]*-[A-Za-z0-9_-]+")


def relation_path_parent(body: str, local_ids: Optional[set] = None) -> Optional[str]:
    """路径父级：同层 `parent` 优先，否则同层 `implements_to`。跨层 ID 不返回。

    local_ids 为本 bundle 已有 id。为 None 时不按层过滤。
    """
    match = re.search(r"^## 关系\s*$", body, re.M)
    if not match:
        return None
    rest = body[match.end() :]
    nxt = re.search(r"^## ", rest, re.M)
    section = rest[: nxt.start()] if nxt else rest

    def pick(verb: str) -> Optional[str]:
        for line in section.splitlines():
            found = re.match(rf"^-\s*{verb}\s*:\s*(.*)$", line.strip())
            if not found:
                continue
            for item in _REL_ID_RE.findall(found.group(1)):
                if local_ids is not None and item not in local_ids:
                    continue
                return item
        return None

    return pick("parent") or pick("implements_to")


def entity_relpath(
    perspective: str,
    id: str,
    path_parent: Optional[str] = None,
    bundle: str = "application",
) -> str:
    """相对 bundle 根的 concept 路径（域扁平树）。

    path_parent 来自 relation_path_parent，不读 frontmatter。
    """
    prefix = _id_prefix(id)
    if bundle == "company":
        if perspective == "business" and prefix == "VC":
            return f"knowledge/business/{id}/{id}.md"
        if perspective == "business" and prefix == "BD":
            return f"knowledge/business/{id}/{id}.md"
        if perspective == "business" and prefix == "BL":
            return f"knowledge/business/BL/{id}.md"
        if perspective == "business" and prefix == "BSD":
            bd = path_parent or "BD-EXAMPLE"
            return f"knowledge/business/{bd}/{id}.md"
        if perspective == "business" and prefix == "CAP":
            vc = path_parent or _DEFAULT_BUSINESS_VC
            return f"knowledge/business/{vc}/{id}.md"
        if perspective == "application" and prefix == "SLN":
            return f"knowledge/application/{id}.md"
        if perspective == "data" and prefix == "MDG":
            return f"knowledge/data/{id}.md"
        if perspective == "technical" and prefix == "TPL":
            return f"knowledge/technical/{id}.md"
        anchor = perspective_domain_anchor(perspective, id, bundle)
        if not anchor:
            return f"knowledge/{perspective}/{id}.md"
        return f"knowledge/{perspective}/{anchor}/{id}.md"

    if bundle == "system":
        if perspective == "business" and prefix == "BD":
            return f"knowledge/business/{id}.md"
        if perspective == "business" and prefix == "BSD":
            # L1（parent=BD-* 或空）：knowledge/business/BSD-{L1}/BSD-{L1}.md
            # L2（parent=BSD-*）：knowledge/business/{parent}/{id}/{id}.md
            if not path_parent or path_parent.startswith("BD-"):
                return f"knowledge/business/{id}/{id}.md"
            return f"knowledge/business/{path_parent}/{id}/{id}.md"
        if perspective == "product" and prefix == "PL":
            return f"knowledge/product/{id}.md"
        if perspective == "product" and prefix == "PD":
            return f"knowledge/product/{id}/{id}.md"
        if perspective == "product" and prefix == "PM":
            pd = path_parent or _DEFAULT_PRODUCT_PD
            return f"knowledge/product/{pd}/{id}/{id}.md"
        if perspective == "application" and prefix == "SYS":
            return f"knowledge/application/{id}.md"
        if perspective == "application" and prefix == "APP":
            return f"knowledge/application/{id}/{id}.md"
        if perspective == "application" and prefix == "MS":
            if not path_parent:
                raise ValueError(
                    "entity_relpath: system MS requires path_parent (APP id)"
                )
            return f"knowledge/application/{path_parent}/{id}/{id}.md"
        if perspective == "data" and prefix == "MDG":
            return f"knowledge/data/{id}.md"
        if perspective == "technical" and prefix == "TSD":
            return f"knowledge/technical/{id}.md"
        if perspective == "technical" and prefix == "MW":
            return f"knowledge/technical/{id}/{id}.md"
        anchor = perspective_domain_anchor(perspective, id, bundle)
        if not anchor:
            return f"knowledge/{perspective}/{id}.md"
        return f"knowledge/{perspective}/{anchor}/{id}.md"

    if bundle == "solution":
        if perspective == "product" and prefix in ("PL", "PD"):
            return f"knowledge/product/PL/{id}.md"
        if perspective == "product" and prefix in ("BP", "BSP"):
            return f"knowledge/product/BP/{id}.md"
        if perspective == "business" and prefix == "BS":
            return f"knowledge/business/BS/{id}.md"

    if perspective == "application" and prefix in ("SYS", "APP"):
        return f"knowledge/application/{id}.md"
    if perspective == "business" and prefix == "BD":
        return f"knowledge/business/{id}.md"
    if perspective == "data" and prefix == "DS":
        return f"knowledge/data/{id}.md"
    if perspective == "product" and prefix == "PL":
        return f"knowledge/product/{id}.md"
    anchor = perspective_domain_anchor(perspective, id, bundle)
    if not anchor:
        return f"knowledge/{perspective}/{id}.md"
    return f"knowledge/{perspective}/{anchor}/{id}.md"


def to_bundle_link(relpath: str) -> str:
    if not relpath.startswith("/"):
        return "/" + relpath.lstrip("/")
    return relpath


def is_concept_file(path: Path) -> bool:
    return path.suffix == ".md" and path.name not in OKF_RESERVED_NAMES


def scan_concepts(bundle_root: Path) -> Iterator[Path]:
    """遍历 bundle 下所有 concept 文件路径（相对 bundle_root 的绝对 Path）。"""
    for path in iter_bundle_markdown_files(bundle_root):
        if is_concept_file(path):
            yield path
