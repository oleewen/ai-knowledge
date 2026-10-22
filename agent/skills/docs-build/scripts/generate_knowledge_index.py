#!/usr/bin/env python3
"""写入 {DOC_DIR}/INDEX-GUIDE.md 第四章视角导航块（docs-build；静态引用，不扫 concept）。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Optional

SCRIPT_DIR = Path(__file__).resolve().parent

ENTITY_BEGIN = "<!-- docs-build:entity-index:begin -->"
ENTITY_END = "<!-- docs-build:entity-index:end -->"
ENTITY_BEGIN_LEGACY = "<!-- docs-build:entity-index -->"
ENTITY_END_LEGACY = "<!-- /docs-build:entity-index -->"

_SCOPE_NOTE = {
    "company": "> 本层登记 **VC / BD / BSD-L1 / CAP / BL / TPL**。",
    "solution": "> 本层登记 **SLN / PL / PD / BP / BSP / BSD-L2 / BS / MDG / TS**。",
    "system": (
        "> 本层登记 **SYS / BSD-L3 / BC / AGG / AB / PM / FT / FR / UC / BR / APP / MS / DS / ENT**。"
    ),
    "application": "> 本层仅登记 **API / TBL / MW / CMP**。",
}

def _repo_root() -> Path:
    """从调用目录定位消费仓，不跟随技能安装目录。"""
    current = Path.cwd().resolve()
    for candidate in (current, *current.parents):
        if (candidate / ".docsconfig").is_file() or (candidate / ".git").exists():
            return candidate
    raise ValueError("当前目录上方未找到 .docsconfig/.git；请进入目标仓或传 --repo")


def _bundle_root(repo: Path, bundle: str) -> Path:
    relative = Path(bundle)
    if relative.is_absolute() or ".." in relative.parts or not relative.parts:
        raise ValueError("--bundle 须为仓库内相对目录")
    root = (repo / relative).resolve()
    if repo not in root.parents or not root.is_dir():
        raise ValueError(f"bundle 不存在或越出仓库: {root}")
    return root


def _scope_note(bundle: str) -> str:
    if bundle not in _SCOPE_NOTE:
        raise ValueError("非标准 bundle 名须通过 --layer-scope 指定知识层")
    return _SCOPE_NOTE[bundle]


def render_knowledge_index(
    bundle_root: Path,
    bundle: str = "application",
) -> str:
    """渲染第四章视角导航正文（静态；实体台账 ∈ 各视角 README）。"""
    del bundle_root  # 静态块；保留参数供调用方/测试签名兼容
    template = (SCRIPT_DIR.parent / "assets" / "knowledge-index-template.md").read_text(encoding="utf-8")
    inner = template.split(ENTITY_BEGIN, 1)[1].split(ENTITY_END, 1)[0].strip()
    return inner.replace("> {层范围短注}", _scope_note(bundle)) + "\n"


def render_entity_index_block(bundle_root: Path, bundle: str = "application") -> str:
    inner = render_knowledge_index(bundle_root, bundle).rstrip()
    return f"{ENTITY_BEGIN}\n{inner}\n{ENTITY_END}\n"


def chapter_four_bounds(existing: str) -> tuple[int, int]:
    """定位唯一第四章，防止错放标记吞掉相邻章节。"""
    chapters = list(re.finditer(r"^##[ \t]+(?:四、|4[. 、])[^\r\n]*", existing, re.MULTILINE))
    if len(chapters) != 1:
        raise ValueError("INDEX-GUIDE.md 须有唯一第四章标题")
    start = chapters[0].end()
    next_chapter = re.search(r"^#{1,2}[ \t]+", existing[start:], re.MULTILINE)
    end = start + next_chapter.start() if next_chapter else len(existing)
    return start, end


def entity_block_span(existing: str) -> Optional[tuple[int, int]]:
    """返回唯一完整标记块；拒绝残缺、重复、倒置或混用标记。"""
    pairs = ((ENTITY_BEGIN, ENTITY_END), (ENTITY_BEGIN_LEGACY, ENTITY_END_LEGACY))
    present = [(begin, end) for begin, end in pairs if begin in existing or end in existing]
    if not present:
        return None
    if len(present) != 1:
        raise ValueError("实体导航混用新旧标记")
    begin, end = present[0]
    if existing.count(begin) != 1 or existing.count(end) != 1:
        raise ValueError("实体导航标记残缺或重复")
    start, finish = existing.index(begin), existing.index(end)
    if finish < start:
        raise ValueError("实体导航结束标记位于开始标记之前")
    chapter_start, chapter_end = chapter_four_bounds(existing)
    if start < chapter_start or finish + len(end) > chapter_end:
        raise ValueError("实体导航标记须完整位于第四章内，禁止跨章替换")
    return start, finish + len(end)


def patch_index_guide(existing: str, block: str) -> str:
    """只替换标记块；无标记时替换 4.5 正文，保留下一同级或上级节。"""
    newline = "\r\n" if "\r\n" in existing else "\n"
    block = block.replace("\r\n", "\n").rstrip().replace("\n", newline) + newline
    span = entity_block_span(existing)
    if span:
        start, end = span
        return existing[:start] + block.rstrip() + existing[end:]
    headings = list(re.finditer(r"^### 4\.5(?:[ \t]+[^\n]*)?\n", existing, re.MULTILINE))
    if len(headings) != 1:
        raise ValueError("INDEX-GUIDE.md 须有唯一「### 4.5」或实体块标记")
    start = headings[0].end()
    chapter_start, chapter_end = chapter_four_bounds(existing)
    if not chapter_start <= headings[0].start() < chapter_end:
        raise ValueError("4.5 标题须位于第四章内")
    following = re.search(r"^#{1,3} ", existing[start:], re.MULTILINE)
    end = start + following.start() if following else len(existing)
    return existing[:start] + newline + block + newline + existing[end:]


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bundle", required=True, help="仓库内文档目录，如 application 或 docs")
    parser.add_argument("--repo", type=Path, help="目标仓库根；默认从当前目录上溯")
    parser.add_argument("--layer-scope", choices=tuple(_SCOPE_NOTE), help="知识层；标准 bundle 名可省略")
    parser.add_argument("--dry-run", action="store_true", help="校验目标并输出导航块，不写文件")
    args = parser.parse_args(argv)
    try:
        repo = args.repo.resolve() if args.repo else _repo_root()
        bundle_root = _bundle_root(repo, args.bundle)
        layer = args.layer_scope or args.bundle
        block = render_entity_index_block(bundle_root, layer)
        out_path = bundle_root / "INDEX-GUIDE.md"
        if out_path.is_symlink():
            raise ValueError("INDEX-GUIDE.md 不得为符号链接")
        with out_path.open(encoding="utf-8", newline="") as stream:
            existing = stream.read()
        patched = patch_index_guide(existing, block)
        if args.dry_run:
            print(block, end="")
        elif patched != existing:
            with out_path.open("w", encoding="utf-8", newline="") as stream:
                stream.write(patched)
            print(f"patched {out_path.relative_to(repo)} 第四章")
        else:
            print(f"unchanged {out_path.relative_to(repo)}")
        return 0
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
