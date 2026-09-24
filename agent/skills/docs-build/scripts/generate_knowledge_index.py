#!/usr/bin/env python3
"""写入 {DOC_DIR}/INDEX-GUIDE.md 第五章视角导航块（docs-build；静态引用，不扫 concept）。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Optional

SCRIPT_DIR = Path(__file__).resolve().parent
OKF_SCRIPTS = SCRIPT_DIR.parent.parent / "docs-okf" / "scripts"
sys.path.insert(0, str(OKF_SCRIPTS))
import okf_lib  # noqa: E402

ENTITY_BEGIN = "<!-- docs-build:entity-index:begin -->"
ENTITY_END = "<!-- docs-build:entity-index:end -->"

_LEAD = (
    "> 本块由 `/docs-build` 写入；实体台账 ∈ 各视角 README；"
    "正文 ∈ per-entity `{ID}.md`；九章骨架 ∈ `/docs-indexing`。"
)

_SCOPE_NOTE = {
    "company": (
        "> 本层登记公司级 **VC / BD / BSD(L1) / CAP / PL / SLN / TPL**；"
        "SLN ∈ application（AA）；无 BSD(L2)/PD/SYS/MDG（见系统库）。"
    ),
    "system": (
        "> 公司级 **TPL-*** / **SLN-*** / **PL-*** 不在本层登记。"
        "本层 **BSD(L2) / PD / SYS / MDG** 首次定义；产品自 **PD** 起；应用自 **SYS** 起。"
    ),
    "application": (
        "> 本层仅登记本层首次定义样例（API/TBL/MW/CMP）。"
        "上游 BD/SYS/MDG/TSD 等以纯 ID 引用公司/系统 SSOT，本层不落 reference 文件。"
        "产品 **PL/SLN** 见公司；**PD/PM** 见系统层。"
    ),
}

_NAV_LINKS = """### 视角入口

- [知识库总说明](knowledge/README.md)
- [目录索引](knowledge/index.md)
- [业务](knowledge/business/README.md)
- [产品](knowledge/product/README.md)
- [应用](knowledge/application/README.md)
- [数据](knowledge/data/README.md)
- [技术](knowledge/technical/README.md)"""


def _repo_root() -> Path:
    return okf_lib.find_repo_root(Path(__file__).resolve())


def _bundle_root(repo: Path, bundle: str) -> Path:
    return (repo / bundle).resolve()


def _scope_note(bundle: str) -> str:
    return _SCOPE_NOTE.get(bundle, _SCOPE_NOTE["application"])


def render_knowledge_index(
    bundle_root: Path,
    bundle: str = "application",
) -> str:
    """渲染第五章视角导航正文（静态；实体台账 ∈ 各视角 README）。"""
    del bundle_root  # 静态块；保留参数供调用方/测试签名兼容
    return "\n".join(
        [
            _LEAD,
            "",
            _scope_note(bundle),
            "",
            _NAV_LINKS,
            "",
        ]
    )


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


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="将视角导航块写入 bundle/INDEX-GUIDE.md 第五章（docs-build）"
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
