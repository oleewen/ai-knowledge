#!/usr/bin/env python3
"""跨层 HTTP / knowledge-links.yaml type:parent（SSOT：knowledge-governance 引用边界）。"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterator, List, Optional, Tuple
from urllib.parse import urlparse

import okf_lib

LINKS_FILENAME = "knowledge-links.yaml"
MD_LINK_RE = re.compile(r"\[([^\]]+)\]\((https?://[^)\s]+)\)")
KNOWN_BLOB: Dict[str, str] = {
    "github.com": "/blob/{ref}/",
    "www.github.com": "/blob/{ref}/",
    "gitlab.com": "/-/blob/{ref}/",
    "www.gitlab.com": "/-/blob/{ref}/",
    "gitee.com": "/blob/{ref}/",
    "www.gitee.com": "/blob/{ref}/",
}


@dataclass(frozen=True)
class Parent:
    knowledge_type: str
    repository: str
    path: str
    doc_dir: str
    ref: str = "main"
    parent_name: str = ""
    parent_label: str = ""

    def expanded_path(self) -> Path:
        return Path(self.path).expanduser()

    def local_doc_root(self) -> Path:
        base = self.expanded_path()
        dd = (self.doc_dir or "").strip()
        if dd in ("", "."):
            return base
        return base / dd


def _yaml_scalar(val: str) -> str:
    val = val.strip()
    if len(val) >= 2 and val[0] == val[-1] and val[0] in ('"', "'"):
        return val[1:-1]
    return val


def links_yaml_path(doc_root: Path) -> Path:
    return Path(doc_root) / LINKS_FILENAME


def _yaml_quote_dq(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _entry_type(ent: Dict[str, str]) -> str:
    return (ent.get("type") or "child").strip() or "child"


def _parse_link_entries(text: str) -> List[Dict[str, str]]:
    entries: List[Dict[str, str]] = []
    current: Dict[str, str] = {}

    def flush() -> None:
        nonlocal current
        if current.get("path") or current.get("repository") or current.get("type"):
            entries.append(current)
        current = {}

    for raw in text.splitlines():
        line = raw.rstrip()
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        m = re.match(r"^(\s*)-\s+([a-z_]+):\s*(.*)$", line)
        if m:
            flush()
            current[m.group(2)] = _yaml_scalar(m.group(3))
            continue
        m2 = re.match(r"^(\s{2,})([a-z_]+):\s*(.*)$", line)
        if m2:
            current[m2.group(2)] = _yaml_scalar(m2.group(3))
    flush()
    return entries


def load_parent(doc_root: Path) -> Optional[Parent]:
    path = links_yaml_path(doc_root)
    if not path.is_file():
        return None
    text = path.read_text(encoding="utf-8")
    for ent in _parse_link_entries(text):
        if _entry_type(ent) != "parent":
            continue
        repo = (ent.get("repository") or "").strip()
        stored_path = (ent.get("path") or "").strip()
        doc_dir = (ent.get("doc_dir") or "").strip()
        if not stored_path or not doc_dir:
            return None
        company_name = (ent.get("company_name") or "").strip()
        company_label = (ent.get("company_label") or "").strip()
        sys_name = (ent.get("sys_name") or "").strip()
        sys_label = (ent.get("sys_label") or "").strip()
        if company_name or company_label:
            kt = "company"
            pname = company_name
            plabel = company_label or company_name
        else:
            kt = "system"
            pname = sys_name
            plabel = sys_label or sys_name
        return Parent(
            knowledge_type=kt,
            repository=repo,
            path=stored_path,
            doc_dir=doc_dir,
            ref="main",
            parent_name=pname,
            parent_label=plabel,
        )
    return None


def dump_parent_entry(parent: Parent) -> List[str]:
    q = _yaml_quote_dq
    lines = [
        "  - type: parent",
        f"    repository: {q(parent.repository)}",
        f"    path: {q(parent.path)}",
        f"    doc_dir: {q(parent.doc_dir)}",
    ]
    name = parent.parent_name or Path(parent.path).expanduser().name
    label = parent.parent_label or name
    if parent.knowledge_type == "company":
        lines.append(f"    company_name: {q(name)}")
        lines.append(f"    company_label: {q(label)}")
    else:
        lines.append(f"    sys_name: {q(name)}")
        lines.append(f"    sys_label: {q(label)}")
    return lines


def _format_child_entry(ent: Dict[str, str]) -> List[str]:
    """测试/CLI 重建 child 条（docs-link 正式写出以 bash 为准）。"""
    q = _yaml_quote_dq
    block = [
        f"  - repository: {q(ent.get('repository', ''))}",
        f"    path: {q(ent.get('path', ''))}",
    ]
    if ent.get("doc_dir"):
        block.append(f"    doc_dir: {q(ent['doc_dir'])}")
    if ent.get("app_name"):
        block.append(f"    app_name: {q(ent['app_name'])}")
        block.append(f"    app_label: {q(ent.get('app_label') or ent['app_name'])}")
    elif ent.get("sys_name"):
        block.append(f"    sys_name: {q(ent['sys_name'])}")
        block.append(f"    sys_label: {q(ent.get('sys_label') or ent['sys_name'])}")
    return block


def _child_blocks_from_entries(entries: List[Dict[str, str]]) -> List[List[str]]:
    return [
        _format_child_entry(ent)
        for ent in entries
        if _entry_type(ent) != "parent"
    ]


def _render_links_document(
    *, parent: Optional[Parent] = None, child_blocks: Optional[List[List[str]]] = None
) -> str:
    child_blocks = child_blocks or []
    lines = ["# 知识库建联清单（可由 docs-link.sh 维护）"]
    if parent is None and not child_blocks:
        lines.append("links: []")
        lines.append("")
        return "\n".join(lines)
    lines.append("links:")
    if parent is not None:
        lines.extend(dump_parent_entry(parent))
    for block in child_blocks:
        lines.extend(block)
    lines.append("")
    return "\n".join(lines)


def write_parent(doc_root: Path, parent: Parent, *, dry_run: bool = False) -> Path:
    """Upsert 唯一 type:parent；保留其它 child 条（测试/CLI；正式路径用 docs-link）。"""
    dest = links_yaml_path(doc_root)
    child_blocks: List[List[str]] = []
    if dest.is_file():
        child_blocks = _child_blocks_from_entries(
            _parse_link_entries(dest.read_text(encoding="utf-8"))
        )
    out = _render_links_document(parent=parent, child_blocks=child_blocks)
    if dry_run:
        return dest
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(out, encoding="utf-8")
    return dest


def delete_parent(doc_root: Path, *, dry_run: bool = False) -> None:
    """从 knowledge-links.yaml 删除 type:parent；保留 child。"""
    dest = links_yaml_path(doc_root)
    if not dest.is_file():
        return
    child_blocks = _child_blocks_from_entries(
        _parse_link_entries(dest.read_text(encoding="utf-8"))
    )
    if dry_run:
        return
    dest.write_text(_render_links_document(child_blocks=child_blocks), encoding="utf-8")


def web_base_from_repo(repository: str, doc_dir: str, *, ref: str = "main") -> Optional[str]:
    """仅由 repository+doc_dir 算 web_base（不依赖 knowledge_type）。"""
    return parent_web_base(
        Parent(
            knowledge_type="",
            repository=repository or "",
            path=".",
            doc_dir=doc_dir,
            ref=ref,
        )
    )


def https_repo_home(repository: str) -> Optional[str]:
    raw = (repository or "").strip()
    if not raw:
        return None
    if raw.startswith("git@"):
        rest = raw[4:]
        if ":" not in rest:
            return None
        host, path = rest.split(":", 1)
        path = path.removesuffix(".git")
        return f"https://{host}/{path}"
    if raw.startswith("ssh://"):
        parsed = urlparse(raw)
        host = parsed.hostname or ""
        path = (parsed.path or "").lstrip("/").removesuffix(".git")
        if not host or not path:
            return None
        return f"https://{host}/{path}"
    if raw.startswith("http://") or raw.startswith("https://"):
        parsed = urlparse(raw)
        host = parsed.netloc
        path = (parsed.path or "").removesuffix(".git").rstrip("/")
        if not host:
            return None
        scheme = "https" if parsed.scheme == "http" else parsed.scheme
        return f"{scheme}://{host}{path}"
    return None


def blob_infix(host: str, ref: str) -> Optional[str]:
    host = host.lower()
    tmpl = KNOWN_BLOB.get(host)
    if not tmpl:
        return None
    return tmpl.format(ref=ref)


def parent_web_base(parent: Parent) -> Optional[str]:
    home = https_repo_home(parent.repository)
    if not home:
        return None
    host = urlparse(home).hostname or ""
    infix = blob_infix(host, parent.ref)
    if not infix:
        return None
    dd = (parent.doc_dir or "").strip()
    if dd in ("", "."):
        return f"{home}{infix}".rstrip("/")
    return f"{home}{infix}{dd}".rstrip("/")


def walk_parents(start_doc_root: Path) -> Iterator[Parent]:
    seen: set[str] = set()
    current = load_parent(start_doc_root)
    while current is not None:
        key = f"{current.knowledge_type}|{current.path}|{current.doc_dir}"
        if key in seen:
            return
        seen.add(key)
        yield current
        nxt = current.local_doc_root()
        if not nxt.is_dir():
            return
        current = load_parent(nxt)


def parent_for_layer(start_doc_root: Path, knowledge_type: str) -> Optional[Parent]:
    for p in walk_parents(start_doc_root):
        if p.knowledge_type == knowledge_type:
            return p
    return None


def collect_web_bases(start_doc_root: Path) -> List[Tuple[Parent, str]]:
    out: List[Tuple[Parent, str]] = []
    for p in walk_parents(start_doc_root):
        wb = parent_web_base(p)
        if wb:
            out.append((p, wb))
    return out


def cross_layer_href(
    start_doc_root: Path,
    full_id: str,
    *,
    parent_id: Optional[str] = None,
    hierarchy: Optional[str] = None,
) -> Optional[str]:
    prefix = hierarchy or okf_lib._id_prefix(full_id)
    layer = okf_lib.hierarchy_first_layer(prefix)
    perspective = okf_lib.hierarchy_to_perspective(prefix)
    if not layer or not perspective:
        return None
    parent = parent_for_layer(start_doc_root, layer)
    if parent is None:
        return None
    wb = parent_web_base(parent)
    if not wb:
        return None
    rel = okf_lib.entity_relpath(
        perspective, full_id, parent_id=parent_id, bundle=layer
    )
    return f"{wb}/{rel}"


def iter_knowledge_md(doc_root: Path) -> Iterator[Path]:
    root = Path(doc_root) / "knowledge"
    if not root.is_dir():
        return
    yield from sorted(root.rglob("*.md"))


def rewrite_web_base(
    doc_root: Path,
    old_web_base: str,
    new_web_base: Optional[str],
    *,
    dry_run: bool = False,
) -> int:
    """替换或拆成纯 ID。返回改写文件数。"""
    if not old_web_base:
        return 0
    changed = 0
    for path in iter_knowledge_md(doc_root):
        text = path.read_text(encoding="utf-8")
        if old_web_base not in text:
            continue
        new_text, n = _rewrite_text(text, old_web_base, new_web_base)
        if n:
            changed += 1
            if not dry_run:
                path.write_text(new_text, encoding="utf-8")
    return changed


def _rewrite_text(
    text: str, old_web_base: str, new_web_base: Optional[str]
) -> Tuple[str, int]:
    count = 0

    def repl(m: re.Match[str]) -> str:
        nonlocal count
        label, url = m.group(1), m.group(2)
        if not (url == old_web_base or url.startswith(old_web_base + "/")):
            return m.group(0)
        count += 1
        if new_web_base:
            suffix = url[len(old_web_base) :]
            return f"[{label}]({new_web_base}{suffix})"
        return label

    return MD_LINK_RE.sub(repl, text), count


def unlink_http_to_id(doc_root: Path, *, dry_run: bool = False) -> int:
    parent = load_parent(doc_root)
    if parent is None:
        return 0
    wb = parent_web_base(parent)
    if not wb:
        return 0
    return rewrite_web_base(doc_root, wb, None, dry_run=dry_run)


def expected_relpath_for_url(
    parent: Parent, url: str, web_base: str
) -> Optional[str]:
    if not (url == web_base or url.startswith(web_base + "/")):
        return None
    rel = url[len(web_base) :].lstrip("/")
    return rel or None


def validate_http_href(
    start_doc_root: Path, href: str
) -> Optional[str]:
    """返回错误信息；合法则 None。无 parent 时任何 http(s) 均非法。"""
    if not (href.startswith("http://") or href.startswith("https://")):
        return None
    bases = collect_web_bases(start_doc_root)
    if not bases:
        return (
            "跨层 HTTP 但缺少 knowledge-links.yaml 中 type: parent"
            "（或无法从 repository 推导已知托管的 HTTP 前缀）"
        )
    matched: Optional[Tuple[Parent, str]] = None
    for parent, wb in bases:
        if href == wb or href.startswith(wb + "/"):
            matched = (parent, wb)
            break
    if matched is None:
        allowed = ", ".join(wb for _, wb in bases)
        return f"跨层 HTTP 前缀不匹配（允许 web_base: {allowed}）"
    parent, wb = matched
    rel = expected_relpath_for_url(parent, href, wb)
    if not rel or not rel.startswith("knowledge/"):
        return f"跨层 HTTP 缺少目标层 knowledge 相对路径: {href}"
    name = Path(rel).name
    if not name.endswith(".md"):
        return f"跨层 HTTP 未指向 .md: {href}"
    full_id = name[:-3]
    prefix = okf_lib._id_prefix(full_id)
    perspective = okf_lib.hierarchy_to_perspective(prefix)
    if not perspective:
        return f"跨层 HTTP 无法识别实体 ID: {full_id}"
    try:
        expected = okf_lib.entity_relpath(
            perspective, full_id, bundle=parent.knowledge_type
        )
    except ValueError:
        expected = None
    if expected and rel != expected:
        if not rel.endswith(f"/{name}") and rel != expected:
            return (
                f"跨层 HTTP 路径与目标层 entity_relpath 不一致: "
                f"得 {rel} 期望 {expected}"
            )
    local_root = parent.local_doc_root()
    if local_root.is_dir():
        target = local_root / rel
        if not target.is_file():
            return f"本机上级文件不存在: {target}"
    return None
