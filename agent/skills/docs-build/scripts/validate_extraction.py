#!/usr/bin/env python3
"""检查 docs-build 实体结构、README 台账与导航；不替代关系语义审查。"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys
from typing import Optional
from urllib.parse import unquote

from generate_knowledge_index import _bundle_root, entity_block_span, ENTITY_BEGIN

OKF_SCRIPTS = Path(__file__).resolve().parents[2] / "docs-okf" / "scripts"
sys.path.insert(0, str(OKF_SCRIPTS))
import okf_lib  # noqa: E402

PERSPECTIVES = ("application", "data", "business", "product", "technical")
LINK = re.compile(r'''(?<!!)\[[^\]]*\]\(\s*(?:<([^>]+)>|([^\s)]+))(?:\s+["'][^\n]*?["'])?\s*\)''')


def without_fences(text: str) -> str:
    """忽略 fenced code 中的示例标题与链接。"""
    lines = []
    marker = ""
    for line in text.splitlines(keepends=True):
        fence = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", line.rstrip())
        if fence:
            token, rest = fence.groups()
            if not marker:
                marker = token
            elif token[0] == marker[0] and len(token) >= len(marker) and not rest.strip():
                marker = ""
            continue
        if not marker:
            lines.append(line)
    return "".join(lines)


def check_bundle(root: Path, layer: str, perspectives: list[str], entities_only: bool) -> list[str]:
    """返回错误清单；只读本层实体树，不进入软链与隐藏目录。"""
    errors: list[str] = []
    knowledge = root / "knowledge"
    if knowledge.is_symlink() or not knowledge.is_dir():
        return ["knowledge 目录不存在或为符号链接"]
    seen: dict[str, Path] = {}
    entities: dict[str, list[Path]] = {p: [] for p in perspectives}
    # 即便只验当前视角，也扫描其他视角的 ID，避免漏掉跨视角重复。
    for perspective in PERSPECTIVES:
        directory = knowledge / perspective
        if directory.is_symlink():
            errors.append(f"视角目录不得为符号链接: {directory}")
            continue
        if perspective in perspectives and not directory.is_dir():
            errors.append(f"缺少视角目录: {directory}")
        for path in okf_lib.iter_bundle_markdown_files(directory):
            if path.is_symlink():
                errors.append(f"不读取符号链接: {path}")
                continue
            if path.name.endswith("-entities.md"):
                print(f"[WARN] 旧聚合文件需另行迁移: {path}")
                continue
            if path.name in okf_lib.OKF_RESERVED_NAMES or path.name in ("README.md", "extraction_report.md") or path.name.endswith("-meta.md"):
                continue
            text = path.read_text(encoding="utf-8")
            meta, body = okf_lib.parse_frontmatter(text)
            is_entity = bool(meta.get("id")) or meta.get("type") in okf_lib.HIERARCHY_TO_TYPE.values() or bool(re.match(r"^[A-Z]+-", path.stem))
            if not is_entity:
                continue
            entity_id = meta.get("id")
            if isinstance(entity_id, str) and entity_id:
                if entity_id in seen:
                    errors.append(f"重复 ID {entity_id}: {seen[entity_id]} 与 {path}")
                seen[entity_id] = path
            if perspective not in perspectives:
                continue
            entities[perspective].append(path)
            label = str(path.relative_to(root))
            missing = set(okf_lib.REQUIRED_FRONTMATTER_FIELDS) - meta.keys()
            if missing:
                errors.append(f"{label}: frontmatter 缺少 {', '.join(sorted(missing))}")
            title = meta.get("title")
            if not isinstance(title, str) or not title.strip():
                errors.append(f"{label}: title 须为非空字符串")
            tags = meta.get("tags")
            if not isinstance(tags, list) or not all(isinstance(tag, str) for tag in tags) or perspective not in tags or meta.get("hierarchy") not in tags:
                errors.append(f"{label}: tags 须为包含 perspective 与 hierarchy 的字符串数组")
            timestamp = meta.get("timestamp")
            if not isinstance(timestamp, str) or not okf_lib.ISO8601_RE.fullmatch(timestamp):
                errors.append(f"{label}: timestamp 须为 ISO8601 +08:00 字符串")
            hierarchy = meta.get("hierarchy")
            if not isinstance(hierarchy, str) or hierarchy not in okf_lib.HIERARCHY_TO_TYPE:
                errors.append(f"{label}: 非法 hierarchy")
                continue
            if not isinstance(entity_id, str) or not entity_id.startswith(hierarchy + "-") or path.stem != entity_id:
                errors.append(f"{label}: id、hierarchy 与文件名不一致")
            if meta.get("type") != okf_lib.hierarchy_to_type(hierarchy):
                errors.append(f"{label}: type 与 hierarchy 不一致")
            if meta.get("perspective") != perspective or okf_lib.hierarchy_to_perspective(hierarchy) != perspective:
                errors.append(f"{label}: perspective 与目录或 hierarchy 不一致")
            if meta.get("layer_scope") != layer:
                errors.append(f"{label}: layer_scope 应为 {layer}")
            if isinstance(entity_id, str) and okf_lib.hierarchy_first_layer(hierarchy, entity_id) != layer:
                errors.append(f"{label}: 不属于本层首次定义实体")
            body = without_fences(body)
            first_heading = re.search(r"^#{1,6} .+$", body, re.MULTILINE)
            h1 = re.findall(r"^# (.+?)\s*$", body, re.MULTILINE)
            if h1 != [title] or first_heading is None or first_heading.group() != f"# {title}":
                errors.append(f"{label}: 首标题须为与 title 一致的唯一 H1")
            elif not body[:first_heading.start()].endswith("<!-- markdownlint-disable-next-line MD025 -->\n"):
                errors.append(f"{label}: H1 前须有 MD025 单行豁免")
            headings = re.findall(r"^## (.+?)\s*$", body, re.MULTILINE)
            if headings != list(okf_lib.REQUIRED_SECTIONS):
                errors.append(f"{label}: 正文须为四个有序中文 H2")

    for perspective, paths in entities.items():
        readme = knowledge / perspective / "README.md"
        if not readme.is_file() or readme.is_symlink():
            errors.append(f"缺少普通 README 文件: {readme}")
            continue
        targets = local_targets(readme, root, errors)
        for path in paths:
            if path.resolve() not in targets:
                errors.append(f"README 未登记实体: {path.relative_to(root)}")
        print(f"[INFO] {perspective}: {len(paths)} 个实体；空视角不要求补造实体")

    if not entities_only:
        guide = root / "INDEX-GUIDE.md"
        if not guide.is_file() or guide.is_symlink():
            errors.append(f"缺少普通 INDEX-GUIDE.md 文件: {guide}")
        else:
            text = guide.read_text(encoding="utf-8")
            try:
                span = entity_block_span(text)
                if span is None or not text[span[0]:span[1]].startswith(ENTITY_BEGIN):
                    errors.append("INDEX-GUIDE.md 缺少当前版完整导航标记块")
                else:
                    local_targets(guide, root, errors, text[span[0]:span[1]])
            except ValueError as exc:
                errors.append(str(exc))
    return errors


def local_targets(path: Path, root: Path, errors: list[str], text: Optional[str] = None) -> set[Path]:
    """解析普通 Markdown 本地链接并检查文件存在；HTTP/锚点交由完整 OKF 校验。"""
    targets: set[Path] = set()
    content = text if text is not None else path.read_text(encoding="utf-8")
    for angle, bare in LINK.findall(without_fences(content)):
        href = angle or bare
        if re.match(r"^[a-zA-Z][\w+.-]*:", href) or href.startswith("#"):
            continue
        href = unquote(href.split("#", 1)[0].strip("<>"))
        if href.startswith("/knowledge/"):
            target = (root / href.lstrip("/")).resolve()
        else:
            target = (path.parent / href).resolve()
        targets.add(target)
        if not target.exists():
            errors.append(f"失效链接: {path} -> {href}")
    return targets


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, required=True)
    parser.add_argument("--bundle", required=True)
    parser.add_argument("--layer-scope", choices=sorted(okf_lib.VALID_LAYER_SCOPES), required=True)
    parser.add_argument("--perspectives", default=",".join(PERSPECTIVES))
    parser.add_argument("--entities-only", action="store_true", help="归并前仅检查实体与 README")
    args = parser.parse_args(argv)
    perspectives = args.perspectives.split(",")
    if not perspectives or any(p not in PERSPECTIVES for p in perspectives):
        parser.error("--perspectives 须为五视角名称的逗号列表")
    try:
        root = _bundle_root(args.repo.resolve(), args.bundle)
        errors = check_bundle(root, args.layer_scope, list(dict.fromkeys(perspectives)), args.entities_only)
    except (OSError, UnicodeError, ValueError) as exc:
        errors = [str(exc)]
    for message in errors:
        print(f"[ERROR] {message}", file=sys.stderr)
    print(f"docs-build 结构校验：{len(errors)} 个错误；关系语义与跨层 HTTP 另行核验。")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
