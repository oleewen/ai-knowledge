#!/usr/bin/env python3
"""docs-link 配套：knowledge-links type:parent 与可选跨层 HTTP 前缀替换。"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from typing import Optional

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_cross_layer as x  # noqa: E402


def _cmd_write(args: argparse.Namespace) -> int:
    doc_root = Path(args.doc_root)
    name = args.parent_name or Path(args.path).expanduser().name
    label = args.parent_label or name
    new = x.Parent(
        knowledge_type=args.knowledge_type,
        repository=args.repository or "",
        path=args.path,
        doc_dir=args.doc_dir,
        ref="main",
        parent_name=name,
        parent_label=label,
    )
    x.write_parent(doc_root, new, dry_run=args.dry_run)
    if args.dry_run:
        print(f"[dry-run] 将写入 parent → {x.links_yaml_path(doc_root)}")
    else:
        print(f"已写入 parent → {x.links_yaml_path(doc_root)}")
    return 0


def _cmd_unlink(args: argparse.Namespace) -> int:
    doc_root = Path(args.doc_root)
    if not args.dry_run:
        x.delete_parent(doc_root)
        print(f"已删除 type:parent → {x.links_yaml_path(doc_root)}")
    else:
        print(f"[dry-run] 将删除 type:parent → {x.links_yaml_path(doc_root)}")
    return 0


def _cmd_rewrite_http(args: argparse.Namespace) -> int:
    doc_root = Path(args.doc_root)
    old_wb = x.web_base_from_repo(args.old_repository or "", args.old_doc_dir)
    new_wb = x.web_base_from_repo(args.new_repository or "", args.new_doc_dir)
    if not old_wb:
        print("旧 parent 无法推导 web_base，跳过 HTTP 改写", file=sys.stderr)
        return 0
    if old_wb == new_wb:
        print("web_base 未变，跳过 HTTP 改写", file=sys.stderr)
        return 0
    n = x.rewrite_web_base(doc_root, old_wb, new_wb, dry_run=args.dry_run)
    print(f"web_base 替换文件数: {n}", file=sys.stderr)
    return 0


def _cmd_href(args: argparse.Namespace) -> int:
    href = x.cross_layer_href(
        Path(args.doc_root),
        args.full_id,
        parent_id=args.parent_id,
        hierarchy=args.hierarchy,
    )
    if href:
        print(href)
        return 0
    print("", end="")
    return 1


def main(argv: Optional[list] = None) -> int:
    parser = argparse.ArgumentParser(
        description="knowledge-links type:parent 与跨层 HTTP"
    )
    parser.add_argument("--dry-run", action="store_true")
    sub = parser.add_subparsers(dest="cmd", required=True)

    w = sub.add_parser("write")
    w.add_argument("--doc-root", required=True)
    w.add_argument("--knowledge-type", required=True)
    w.add_argument("--repository", default="")
    w.add_argument("--path", required=True)
    w.add_argument("--doc-dir", required=True)
    w.add_argument("--parent-name", default="")
    w.add_argument("--parent-label", default="")
    w.set_defaults(func=_cmd_write)

    u = sub.add_parser("unlink")
    u.add_argument("--doc-root", required=True)
    u.set_defaults(func=_cmd_unlink)

    r = sub.add_parser("rewrite-http")
    r.add_argument("--doc-root", required=True)
    r.add_argument("--old-repository", default="")
    r.add_argument("--old-path", required=True)
    r.add_argument("--old-doc-dir", required=True)
    r.add_argument("--new-repository", default="")
    r.add_argument("--new-path", required=True)
    r.add_argument("--new-doc-dir", required=True)
    r.set_defaults(func=_cmd_rewrite_http)

    h = sub.add_parser("href")
    h.add_argument("--doc-root", required=True)
    h.add_argument("--full-id", required=True)
    h.add_argument("--parent-id", default=None)
    h.add_argument("--hierarchy", default=None)
    h.set_defaults(func=_cmd_href)

    args = parser.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
