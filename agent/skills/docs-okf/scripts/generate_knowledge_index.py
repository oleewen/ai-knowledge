#!/usr/bin/env python3
"""已退役：实体表改由 docs-build 写入 {DOC_DIR}/INDEX-GUIDE.md 第五章。

兼容入口：转发到 agent/skills/docs-build/scripts/generate_knowledge_index.py。
OKF 流水线（okf-indexing.sh）不再调用本脚本。
"""

from __future__ import annotations

import runpy
import subprocess
import sys
from pathlib import Path

_TARGET = (
    Path(__file__).resolve().parent.parent.parent
    / "docs-build"
    / "scripts"
    / "generate_knowledge_index.py"
)


def _load_build_module():
    """供测试/兼容 import 复用 docs-build 实现。"""
    import importlib.util

    spec = importlib.util.spec_from_file_location(
        "docs_build_generate_knowledge_index", _TARGET
    )
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load {_TARGET}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


_build = _load_build_module()
render_knowledge_index = _build.render_knowledge_index
patch_index_guide = _build.patch_index_guide
render_entity_index_block = _build.render_entity_index_block
ENTITY_BEGIN = _build.ENTITY_BEGIN
ENTITY_END = _build.ENTITY_END
main = _build.main


def _cli() -> int:
    print(
        "[deprecated] generate_knowledge_index 已迁入 docs-build；"
        "请用: python3 agent/skills/docs-build/scripts/generate_knowledge_index.py",
        file=sys.stderr,
    )
    if not _TARGET.is_file():
        print(f"error: missing {_TARGET}", file=sys.stderr)
        return 1
    return subprocess.call([sys.executable, str(_TARGET), *sys.argv[1:]])


if __name__ == "__main__":
    raise SystemExit(_cli())
