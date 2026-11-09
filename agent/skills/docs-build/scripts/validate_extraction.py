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
sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "scripts/tools"))
from knowledge_validation.core import validate, render, entity_candidate

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
    entities: dict[str, list[Path]] = {p: [] for p in perspectives}
    for perspective in perspectives:
        directory = knowledge / perspective
        if directory.is_symlink() or not directory.is_dir():
            errors.append(f"缺少普通视角目录: {directory}")
            continue
        for path in okf_lib.iter_bundle_markdown_files(directory):
            if path.is_symlink():
                errors.append(f"不读取符号链接: {path}")
                continue
            meta, _ = okf_lib.parse_frontmatter(path.read_text(encoding="utf-8"))
            if entity_candidate(path, root, meta):
                entities[perspective].append(path)

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
        result = validate(args.repo, args.bundle, args.layer_scope,
                          scopes=["knowledge/" + p for p in perspectives] if set(perspectives) != set(PERSPECTIVES) else ())
        print(render(result))
        errors = [f"{x['rule']}: {x['object']}: {x['evidence']}" for x in result['checks'] if x['status'] == 'FAIL']
        if not any(x['domain'] == 'context' and x['status'] == 'FAIL' for x in result['checks']):
            errors.extend(check_bundle(root, args.layer_scope, list(dict.fromkeys(perspectives)), args.entities_only))
    except (OSError, UnicodeError, ValueError) as exc:
        errors = [str(exc)]
    for message in errors:
        print(f"[ERROR] {message}", file=sys.stderr)
    print(f"docs-build 校验：{len(errors)} 个错误；统一核心分项状态见上文，导航另行检查。")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
