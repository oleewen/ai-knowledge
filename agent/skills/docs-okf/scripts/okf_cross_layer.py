#!/usr/bin/env python3
"""跨层 HTTP / knowledge-links.yaml type:parent（SSOT：knowledge-governance 引用边界）。"""

from __future__ import annotations

import re
from dataclasses import dataclass, replace
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
    # 中通自建 GitLab
    "git.ztosys.com": "/-/blob/{ref}/",
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

    owner_doc_root: Optional[Path] = None

    def expanded_path(self) -> Path:
        if self.owner_doc_root is None:
            raise ValueError("parent 缺少所属知识库配置上下文")
        return resolve_link_path(self.owner_doc_root, self.path)

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


def _config_values(path: Path) -> Dict[str, str]:
    if not path.is_file():
        raise ValueError(f"缺少配置文件: {path}")
    values = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        match = re.match(r"^([A-Z_]+)=(.*)$", line.strip())
        if match:
            values[match[1]] = _yaml_scalar(match[2])
    return values


def workspace_for(doc_root: Path) -> Path:
    """从 YAML 所属库上溯配置；不读取环境中的 WORK_SPACE。"""
    start = Path(doc_root).resolve()
    owner = next((p for p in (start, *start.parents) if (p / ".docsconfig").is_file()), None)
    if owner is None:
        raise ValueError(f"缺少所属库 .docsconfig: {doc_root}")
    config = _config_values(owner / ".docsconfig")
    root, directory = config.get("AGENT_ROOT", ""), config.get("AGENT_DIR", "")
    if not root or not directory:
        raise ValueError(f".docsconfig 缺少 AGENT_ROOT / AGENT_DIR: {owner}")
    agent_root = Path(root).expanduser()
    if not agent_root.is_absolute() or Path(directory).is_absolute():
        raise ValueError("AGENT_ROOT 必须是绝对路径或 ~/ 路径，AGENT_DIR 必须是相对路径")
    configs = agent_root / directory / "configs"
    workspace = _config_values(configs).get("WORK_SPACE", "")
    if not workspace:
        raise ValueError(f"配置缺少 WORK_SPACE: {configs}")
    base = Path(workspace).expanduser()
    if not base.is_absolute():
        raise ValueError(f"WORK_SPACE 必须是绝对路径或 ~/ 路径: {configs}")
    return base.resolve()


def resolve_link_path(doc_root: Path, value: str, *, writing: bool = False) -> Path:
    workspace = workspace_for(doc_root)
    token = "${WORK_SPACE}"
    if value == token:
        target = workspace
    elif value.startswith(token + "/"):
        target = workspace / value[len(token):].lstrip("/")
    elif writing and (value.startswith("/") or value.startswith("~/")):
        target = Path(value).expanduser()
    else:
        raise ValueError(f"knowledge-links path 必须使用 ${{WORK_SPACE}} 占位符: {value!r}")
    resolved = target.resolve()
    if not resolved.is_relative_to(workspace):
        raise ValueError(f"knowledge-links path 越出 WORK_SPACE: {value!r}")
    return resolved


def _validate_entries(doc_root: Path, entries: List[Dict[str, str]]) -> None:
    workspace_for(doc_root)
    for entry in entries:
        resolve_link_path(doc_root, entry.get("path", ""))


def links_yaml_path(doc_root: Path) -> Path:
    return Path(doc_root) / LINKS_FILENAME


def _yaml_quote_dq(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


_PARENT_LAYER = {
    "application": "system",
    "system": "solution",
    "solution": "company",
}


def _read_knowledge_type(root: Path) -> str:
    cfg = root / ".docsconfig"
    if not cfg.is_file():
        return ""
    for line in cfg.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line.startswith("KNOWLEDGE_TYPE="):
            return line.split("=", 1)[1].strip().strip('"').strip("'")
    return ""


def _parent_layer(doc_root: Path, parent_path: str) -> str:
    """父层取自父仓 .docsconfig；父仓不在本机时，由当前仓 KNOWLEDGE_TYPE 上推一层。"""
    expanded = resolve_link_path(doc_root, parent_path)
    if expanded.is_dir():
        kt = _read_knowledge_type(expanded)
        if kt:
            return kt
    start = Path(doc_root).resolve()
    for base in (start, *start.parents):
        if (base / ".docsconfig").is_file():
            return _PARENT_LAYER.get(_read_knowledge_type(base), "")
    return ""


def _entry_type(ent: Dict[str, str]) -> str:
    return (ent.get("type") or "").strip()


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
    entries = _parse_link_entries(text)
    _validate_entries(doc_root, entries)
    for ent in entries:
        if _entry_type(ent) != "parent":
            continue
        repo = (ent.get("repository") or "").strip()
        stored_path = (ent.get("path") or "").strip()
        doc_dir = (ent.get("dir") or "").strip()
        pname = (ent.get("name") or "").strip()
        plabel = (ent.get("label") or "").strip() or pname
        if not stored_path or not doc_dir or not pname:
            return None
        kt = _parent_layer(doc_root, stored_path)
        if not kt:
            return None
        return Parent(
            knowledge_type=kt,
            repository=repo,
            path=stored_path,
            doc_dir=doc_dir,
            ref="main",
            parent_name=pname,
            parent_label=plabel,
            owner_doc_root=Path(doc_root).resolve(),
        )
    return None


def dump_parent_entry(parent: Parent) -> List[str]:
    q = _yaml_quote_dq
    lines = [
        "  - type: parent",
        f"    repository: {q(parent.repository)}",
        f"    path: {q(parent.path)}",
        f"    dir: {q(parent.doc_dir)}",
    ]
    name = parent.parent_name or Path(parent.path).expanduser().name
    label = parent.parent_label or name
    if parent.knowledge_type not in ("company", "solution", "system"):
        raise ValueError(
            f"parent knowledge_type 无法写入 knowledge-links: {parent.knowledge_type}"
        )
    lines.append(f"    name: {q(name)}")
    lines.append(f"    label: {q(label)}")
    return lines


def _format_child_entry(ent: Dict[str, str]) -> List[str]:
    """测试/CLI 重建 child 条（docs-link 正式写出以 bash 为准）。"""
    q = _yaml_quote_dq
    block = [
        "  - type: child",
        f"    repository: {q(ent.get('repository', ''))}",
        f"    path: {q(ent.get('path', ''))}",
    ]
    if ent.get("dir"):
        block.append(f"    dir: {q(ent['dir'])}")
    name = (ent.get("name") or "").strip()
    label = (ent.get("label") or "").strip() or name
    if name:
        block.append(f"    name: {q(name)}")
        block.append(f"    label: {q(label)}")
    return block


def _format_meta_entry(ent: Dict[str, str]) -> List[str]:
    """type:meta 只留 repository、path、dir。"""
    q = _yaml_quote_dq
    block = [
        "  - type: meta",
        f"    repository: {q(ent.get('repository', ''))}",
        f"    path: {q(ent.get('path', ''))}",
    ]
    if ent.get("dir"):
        block.append(f"    dir: {q(ent['dir'])}")
    return block


def _child_blocks_from_entries(entries: List[Dict[str, str]]) -> List[List[str]]:
    blocks: List[List[str]] = []
    for ent in entries:
        kind = _entry_type(ent)
        if kind == "parent":
            continue
        if kind == "meta":
            blocks.append(_format_meta_entry(ent))
        elif kind == "child":
            blocks.append(_format_child_entry(ent))
        else:
            raise ValueError(f"knowledge-links 条目缺少或非法 type: {kind!r}")
    return blocks


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
    resolved = resolve_link_path(doc_root, parent.path, writing=True)
    relative = resolved.relative_to(workspace_for(doc_root)).as_posix()
    stored = "${WORK_SPACE}" + ("/" + relative if relative != "." else "")
    parent = replace(parent, path=stored, owner_doc_root=Path(doc_root).resolve())
    child_blocks: List[List[str]] = []
    if dest.is_file():
        entries = _parse_link_entries(dest.read_text(encoding="utf-8"))
        _validate_entries(doc_root, entries)
        child_blocks = _child_blocks_from_entries(entries)
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
    entries = _parse_link_entries(dest.read_text(encoding="utf-8"))
    _validate_entries(doc_root, entries)
    child_blocks = _child_blocks_from_entries(entries)
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
        key = str(current.local_doc_root().resolve())
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


def _index_concepts(doc_root: Path) -> Dict[str, Tuple[Path, str]]:
    knowledge = Path(doc_root) / "knowledge"
    found: Dict[str, Tuple[Path, str]] = {}
    if not knowledge.is_dir():
        return found
    for path in knowledge.rglob("*.md"):
        if not okf_lib.is_concept_file(path):
            continue
        text = path.read_text(encoding="utf-8")
        meta, body = okf_lib.parse_frontmatter(text)
        fid = meta.get("id") or path.stem
        found[str(fid)] = (path, body)
    return found


def _disk_parent_chain(
    doc_root: Path,
    file_path: Path,
    perspective: str,
    entity_id: str,
    need: int,
) -> Optional[str]:
    """文件所在目录。宿主文件 `{id}/{id}.md` 去掉自身目录名。"""
    persp_root = Path(doc_root) / "knowledge" / perspective
    try:
        rel_dir = file_path.parent.relative_to(persp_root)
    except ValueError:
        return None
    parts = [part for part in rel_dir.parts if part and part != "."]
    if parts and parts[-1] == entity_id:
        parts = parts[:-1]
    if len(parts) == need:
        return "/".join(parts)
    return None


def directory_chain_for_entity(
    doc_root: Path, entity_id: str, perspective: str, need: int
) -> Optional[str]:
    """沿同层 parent / implements_to 向上收集父 ID。

    段数不够时用直接父文件的目录。同层走不到时，用本文件所在父目录。
    跨层 ID 不在本 bundle，relation_path_parent 会跳过。
    """
    by_id = _index_concepts(doc_root)
    if entity_id not in by_id:
        return None
    file_path = by_id[entity_id][0]
    local_ids = set(by_id)
    ancestors: List[str] = []
    seen = {entity_id}
    current = entity_id
    while len(ancestors) < need:
        parent_id = okf_lib.relation_path_parent(by_id[current][1], local_ids)
        if not parent_id or parent_id in seen or parent_id not in by_id:
            break
        seen.add(parent_id)
        ancestors.append(parent_id)
        current = parent_id
    if len(ancestors) == need:
        return "/".join(reversed(ancestors))
    if ancestors:
        parent_path = by_id[ancestors[0]][0]
        persp_root = Path(doc_root) / "knowledge" / perspective
        try:
            rel_dir = parent_path.parent.relative_to(persp_root).as_posix()
        except ValueError:
            rel_dir = ""
        parts = [part for part in rel_dir.split("/") if part and part != "."]
        if len(parts) == need:
            return "/".join(parts)
    return _disk_parent_chain(doc_root, file_path, perspective, entity_id, need)


def cross_layer_href(
    start_doc_root: Path,
    id: str,
    *,
    path_parent: Optional[str] = None,
    hierarchy: Optional[str] = None,
) -> Optional[str]:
    code = hierarchy or okf_lib._id_prefix(id)
    layer = okf_lib.hierarchy_first_layer(code, id)
    perspective = okf_lib.hierarchy_to_perspective(code)
    if not layer or not perspective:
        return None
    parent = parent_for_layer(start_doc_root, layer)
    if parent is None:
        return None
    wb = parent_web_base(parent)
    if not wb:
        return None
    chain = path_parent
    local = parent.local_doc_root()
    need = okf_lib.relpath_parent_count(code, layer)
    if need:
        given = [part for part in (path_parent or "").split("/") if part]
        if len(given) == need:
            chain = "/".join(given)
        elif not local.is_dir():
            return None
        else:
            chain = directory_chain_for_entity(local, id, perspective, need)
    try:
        rel = okf_lib.entity_relpath(
            perspective, id, path_parent=chain, bundle=layer
        )
    except ValueError:
        return None
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
    id = name[:-3]
    prefix = okf_lib._id_prefix(id)
    perspective = okf_lib.hierarchy_to_perspective(prefix)
    if not perspective:
        return f"跨层 HTTP 无法识别实体 ID: {id}"
    local_root = parent.local_doc_root()
    need = okf_lib.relpath_parent_count(prefix, parent.knowledge_type)
    chain = None
    if need and local_root.is_dir():
        chain = directory_chain_for_entity(local_root, id, perspective, need)
        if not chain:
            return f"跨层 HTTP 路径不足：{id} 缺少父目录链"
    try:
        expected = okf_lib.entity_relpath(
            perspective, id, path_parent=chain, bundle=parent.knowledge_type
        )
    except ValueError:
        expected = None
    if expected and rel != expected:
        return (
            f"跨层 HTTP 路径与目标层 entity_relpath 不一致: "
            f"得 {rel} 期望 {expected}"
        )
    if local_root.is_dir():
        target = local_root / rel
        if not target.is_file():
            return f"本机上级文件不存在: {target}"
    return None
