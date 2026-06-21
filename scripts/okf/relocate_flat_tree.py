#!/usr/bin/env python3
"""将 application/knowledge 五视角嵌套锚点搬迁为域扁平树。见 docs/superpowers/specs/2026-06-21-business-flat-tree-design.md"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path
from typing import Dict, List, Tuple

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parents[2]
KNOWLEDGE = REPO_ROOT / "application" / "knowledge"

# 旧 bundle-relative 路径前缀 → 新前缀（用于全文链接替换）
LINK_REWRITES: List[Tuple[str, str]] = [
    ("/knowledge/business/BD-EXAMPLE/", "/knowledge/business/BSD-EXAMPLE/"),
    ("/knowledge/business/BSD-EXAMPLE/BC-EXAMPLE.md", "/knowledge/business/BSD-EXAMPLE/BC-EXAMPLE.md"),
    ("/knowledge/business/BC-EXAMPLE/", "/knowledge/business/BSD-EXAMPLE/"),
    ("/knowledge/business/AGG-EXAMPLE/", "/knowledge/business/BSD-EXAMPLE/"),
    ("/knowledge/product/PL-EXAMPLE/PM-EXAMPLE/", "/knowledge/product/PM-EXAMPLE/"),
    ("/knowledge/product/PL-EXAMPLE/PL-EXAMPLE.md", "/knowledge/product/PM-EXAMPLE/PL-EXAMPLE.md"),
    ("/knowledge/product/PL-EXAMPLE/PM-EXAMPLE.md", "/knowledge/product/PM-EXAMPLE/PM-EXAMPLE.md"),
    ("/knowledge/application/SYS-EXAMPLE/", "/knowledge/application/MS-EXAMPLE/"),
    ("/knowledge/application/APP-EXAMPLE/MS-EXAMPLE.md", "/knowledge/application/MS-EXAMPLE/MS-EXAMPLE.md"),
    ("/knowledge/application/API-EXAMPLE-001.md", "/knowledge/application/MS-EXAMPLE/API-EXAMPLE-001.md"),
    ("/knowledge/data/DS-EXAMPLE/", "/knowledge/data/ENT-EXAMPLE/"),
    ("/knowledge/technical/MW-EXAMPLE.md", "/knowledge/technical/MW-EXAMPLE/MW-EXAMPLE.md"),
    ("/knowledge/technical/CMP-EXAMPLE.md", "/knowledge/technical/MW-EXAMPLE/CMP-EXAMPLE.md"),
]

# 相对 knowledge/ 的搬迁：旧 → 新
FILE_MOVES: List[Tuple[str, str]] = [
    ("business/BD-EXAMPLE/BD-EXAMPLE.md", "business/BSD-EXAMPLE/BD-EXAMPLE.md"),
    ("business/BD-EXAMPLE/BSD-EXAMPLE.md", "business/BSD-EXAMPLE/BSD-EXAMPLE.md"),
    ("business/BSD-EXAMPLE/BC-EXAMPLE.md", "business/BSD-EXAMPLE/BC-EXAMPLE.md"),
    ("business/BC-EXAMPLE/AGG-EXAMPLE.md", "business/BSD-EXAMPLE/AGG-EXAMPLE.md"),
    ("business/AGG-EXAMPLE/AB-EXAMPLE.md", "business/BSD-EXAMPLE/AB-EXAMPLE.md"),
    ("product/PL-EXAMPLE/PL-EXAMPLE.md", "product/PM-EXAMPLE/PL-EXAMPLE.md"),
    ("product/PL-EXAMPLE/PM-EXAMPLE.md", "product/PM-EXAMPLE/PM-EXAMPLE.md"),
    ("product/PL-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE.md", "product/PM-EXAMPLE/FT-EXAMPLE.md"),
    ("product/PL-EXAMPLE/PM-EXAMPLE/UC-EXAMPLE-001.md", "product/PM-EXAMPLE/UC-EXAMPLE-001.md"),
    ("application/SYS-EXAMPLE/SYS-EXAMPLE.md", "application/MS-EXAMPLE/SYS-EXAMPLE.md"),
    ("application/SYS-EXAMPLE/APP-EXAMPLE.md", "application/MS-EXAMPLE/APP-EXAMPLE.md"),
    ("application/MS-EXAMPLE.md", "application/MS-EXAMPLE/MS-EXAMPLE.md"),
    ("application/API-EXAMPLE-001.md", "application/MS-EXAMPLE/API-EXAMPLE-001.md"),
    ("application/MS-EXAMPLE/API-EXAMPLE-001.md", "application/MS-EXAMPLE/API-EXAMPLE-001.md"),
    ("data/DS-EXAMPLE/DS-EXAMPLE.md", "data/ENT-EXAMPLE/DS-EXAMPLE.md"),
    ("data/DS-EXAMPLE/ENT-EXAMPLE.md", "data/ENT-EXAMPLE/ENT-EXAMPLE.md"),
    ("technical/MW-EXAMPLE.md", "technical/MW-EXAMPLE/MW-EXAMPLE.md"),
    ("technical/CMP-EXAMPLE.md", "technical/MW-EXAMPLE/CMP-EXAMPLE.md"),
]

REFERENCE_META: Dict[str, Dict[str, str]] = {
    "BD-EXAMPLE": {"definition_scope": "reference", "ssot_layer": "company"},
    "PL-EXAMPLE": {"definition_scope": "reference", "ssot_layer": "company"},
    "SYS-EXAMPLE": {"definition_scope": "reference", "ssot_layer": "company"},
    "APP-EXAMPLE": {"definition_scope": "reference", "ssot_layer": "system"},
    "MS-EXAMPLE": {"definition_scope": "reference", "ssot_layer": "system"},
    "DS-EXAMPLE": {"definition_scope": "reference", "ssot_layer": "system"},
    "ENT-EXAMPLE": {"definition_scope": "reference", "ssot_layer": "system"},
}

SSOT_BODY: Dict[str, str] = {
    "BD-EXAMPLE": (
        "# SSOT\n\n"
        "上游主定义：`company/knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md`（公司层 OKF SSOT）。\n"
    ),
    "PL-EXAMPLE": (
        "# SSOT\n\n"
        "上游主定义：`company/knowledge/product/PL-EXAMPLE.md`（公司层 OKF SSOT）。\n"
    ),
    "SYS-EXAMPLE": (
        "# SSOT\n\n"
        "上游主定义：`company/knowledge/application/SYS-EXAMPLE.md`（公司层 OKF SSOT）。\n"
    ),
    "APP-EXAMPLE": (
        "# SSOT\n\n"
        "上游主定义：`system/knowledge/application/APP-EXAMPLE/APP-EXAMPLE.md`（系统层 OKF SSOT）。\n"
    ),
    "MS-EXAMPLE": (
        "# SSOT\n\n"
        "上游主定义：`system/knowledge/application/APP-EXAMPLE/MS-EXAMPLE.md`（系统层 OKF SSOT）。\n"
    ),
    "DS-EXAMPLE": (
        "# SSOT\n\n"
        "上游主定义：`system/knowledge/data/DS-EXAMPLE/DS-EXAMPLE.md`（系统层 OKF SSOT）。\n"
    ),
    "ENT-EXAMPLE": (
        "# SSOT\n\n"
        "上游主定义：`system/knowledge/data/DS-EXAMPLE/ENT-EXAMPLE.md`（系统层 OKF SSOT）。\n"
    ),
}

REMOVE_DIRS = [
    "business/BD-EXAMPLE",
    "business/BSD-EXAMPLE",  # old nested only if empty - careful BC was in BSD
    "business/BC-EXAMPLE",
    "business/AGG-EXAMPLE",
    "product/PL-EXAMPLE",
    "application/SYS-EXAMPLE",
    "application/MS-EXAMPLE",  # only subdir API - we'll remove old nested after move
    "data/DS-EXAMPLE",
]


def rewrite_links(text: str) -> str:
    for old, new in LINK_REWRITES:
        text = text.replace(old, new)
    return text


def apply_reference_meta(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    meta, body = okf_lib.parse_frontmatter(text)
    fid = meta.get("full_id")
    if not fid or fid not in REFERENCE_META:
        return
    for k, v in REFERENCE_META[fid].items():
        meta[k] = v
    ssot = SSOT_BODY.get(fid, "")
    if ssot and "# SSOT" not in body:
        body = ssot + "\n" + body.lstrip()
    path.write_text(okf_lib.format_frontmatter(meta) + rewrite_links(body), encoding="utf-8")


def move_files(dry_run: bool) -> None:
    for old_rel, new_rel in FILE_MOVES:
        src = KNOWLEDGE / old_rel
        dst = KNOWLEDGE / new_rel
        if not src.is_file():
            continue
        if dst.exists() and src.resolve() == dst.resolve():
            continue
        print(f"move {old_rel} -> {new_rel}")
        if not dry_run:
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(src), str(dst))


def rewrite_all_concepts(dry_run: bool) -> None:
    for path in okf_lib.scan_concepts(KNOWLEDGE.parent):  # application bundle
        text = path.read_text(encoding="utf-8")
        new_text = rewrite_links(text)
        if new_text != text:
            print(f"rewrite links in {path.relative_to(REPO_ROOT)}")
            if not dry_run:
                path.write_text(new_text, encoding="utf-8")
        if not dry_run:
            apply_reference_meta(path)


def remove_empty_nested(dry_run: bool) -> None:
    # 删除已知嵌套目录（若仍存在）
    stale = [
        KNOWLEDGE / "business/BD-EXAMPLE",
        KNOWLEDGE / "business/BC-EXAMPLE",
        KNOWLEDGE / "business/AGG-EXAMPLE",
        KNOWLEDGE / "product/PL-EXAMPLE",
        KNOWLEDGE / "application/SYS-EXAMPLE",
        KNOWLEDGE / "data/DS-EXAMPLE",
    ]
    for d in stale:
        if d.is_dir():
            # only remove if no concept files left
            concepts = list(okf_lib.scan_concepts(d))
            if concepts:
                print(f"skip remove {d.relative_to(REPO_ROOT)} (still has concepts)")
                continue
            print(f"remove dir {d.relative_to(REPO_ROOT)}")
            if not dry_run:
                shutil.rmtree(d)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    move_files(args.dry_run)
    if not args.dry_run:
        rewrite_all_concepts(args.dry_run)
        remove_empty_nested(args.dry_run)
    else:
        print("(dry-run: skip link rewrite and dir cleanup)")


if __name__ == "__main__":
    main()
