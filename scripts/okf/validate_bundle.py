#!/usr/bin/env python3
"""OKF bundle 校验：frontmatter、full_id 唯一性、链接与 index 条目。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402

BUNDLE_LINK_RE = re.compile(r"\]\((/(?:knowledge|application)/[^)]+)\)")
INDEX_LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
ALLOWED_ROOT_INDEX_KEYS = frozenset({"okf_version"})


class Validator:
    def __init__(self, bundle_root: Path) -> None:
        self.bundle_root = bundle_root.resolve()
        self.errors = 0
        self.warnings = 0

    def error(self, msg: str) -> None:
        print(f"[ERROR] {msg}", file=sys.stderr)
        self.errors += 1

    def warn(self, msg: str) -> None:
        print(f"[WARN]  {msg}", file=sys.stderr)
        self.warnings += 1

    def relpath(self, path: Path) -> str:
        return path.resolve().relative_to(self.bundle_root).as_posix()

    def run(self) -> int:
        md_files = sorted(self.bundle_root.rglob("*.md"))
        full_id_map: Dict[str, List[str]] = {}

        for path in md_files:
            relpath = self.relpath(path)
            text = path.read_text(encoding="utf-8")
            self._check_frontmatter(path, relpath, text)
            meta, _ = okf_lib.parse_frontmatter(text)
            full_id = meta.get("full_id")
            if full_id:
                full_id_map.setdefault(str(full_id), []).append(relpath)

        for full_id, paths in sorted(full_id_map.items()):
            if len(paths) > 1:
                self.error(
                    f"full_id 重复: {full_id} -> {', '.join(paths)}"
                )

        for path in md_files:
            text = path.read_text(encoding="utf-8")
            self._check_bundle_links(path, text)
            if path.name == "index.md":
                self._check_index_links(path, text)

        print("")
        print("=== OKF bundle 校验结果 ===")
        print(f"bundle: {self.bundle_root}")
        print(f"错误: {self.errors}  警告: {self.warnings}")
        if self.errors:
            print("校验失败，请修正后重跑。")
            return 1
        print("验证通过。")
        return 0

    def _has_frontmatter(self, text: str) -> bool:
        return bool(okf_lib.FRONTMATTER_RE.match(text))

    def _is_bundle_root_index(self, relpath: str) -> bool:
        return relpath == "index.md"

    def _check_frontmatter(self, path: Path, relpath: str, text: str) -> None:
        name = path.name
        has_fm = self._has_frontmatter(text)
        meta, _ = okf_lib.parse_frontmatter(text)

        if name in okf_lib.OKF_RESERVED_NAMES:
            if not has_fm:
                return
            if self._is_bundle_root_index(relpath):
                extra = set(meta.keys()) - ALLOWED_ROOT_INDEX_KEYS
                if extra:
                    self.warn(
                        f"{relpath}: 根 index.md 仅允许 okf_version frontmatter，"
                        f"多余键: {', '.join(sorted(extra))}"
                    )
                return
            self.warn(f"{relpath}: index.md/log.md 不应含 frontmatter（OKF §6）")
            return

        if not has_fm:
            if name == "README.md":
                self.warn(f"{relpath}: 缺少 frontmatter")
            else:
                self.error(f"{relpath}: 缺少可解析 frontmatter")
            return

        type_val = meta.get("type")
        if type_val is None or str(type_val).strip() == "":
            self.error(f"{relpath}: frontmatter 缺少非空 type")

    def _resolve_bundle_target(self, link: str) -> Path:
        normalized = link.lstrip("/")
        return self.bundle_root / normalized

    def _resolve_index_target(self, index_path: Path, link: str) -> Path:
        if link.startswith("/"):
            return self._resolve_bundle_target(link)
        if link.startswith(("http://", "https://", "mailto:")):
            return index_path  # skip external
        return (index_path.parent / link).resolve()

    def _target_exists(self, target: Path) -> bool:
        return target.exists()

    def _check_bundle_links(self, path: Path, text: str) -> None:
        relpath = self.relpath(path)
        for match in BUNDLE_LINK_RE.finditer(text):
            link = match.group(1)
            target = self._resolve_bundle_target(link)
            if not self._target_exists(target):
                self.warn(f"{relpath}: 链接目标不存在 {link}")

    def _check_index_links(self, index_path: Path, text: str) -> None:
        relpath = self.relpath(index_path)
        for match in INDEX_LINK_RE.finditer(text):
            link = match.group(1).strip()
            if link.startswith("#"):
                continue
            if link.startswith(("http://", "https://", "mailto:")):
                continue
            target = self._resolve_index_target(index_path, link)
            if not self._target_exists(target):
                self.warn(f"{relpath}: index 链接目标不存在 {link}")


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _bundle_root(repo: Path, bundle: str) -> Path:
    return (repo / bundle).resolve()


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="校验 OKF bundle")
    parser.add_argument(
        "--bundle",
        required=True,
        help="bundle 目录名（相对仓库根），如 application",
    )
    parser.add_argument(
        "--repo",
        default=None,
        help="仓库根目录（默认：脚本上两级）",
    )
    args = parser.parse_args(argv)

    repo = Path(args.repo).resolve() if args.repo else _repo_root()
    bundle_root = _bundle_root(repo, args.bundle)
    if not bundle_root.is_dir():
        print(f"[ERROR] bundle 不存在: {bundle_root}", file=sys.stderr)
        return 1

    print("=== OKF bundle 校验 ===")
    print(f"REPO_ROOT: {repo}")
    print(f"BUNDLE:    {args.bundle}")
    print(f"BUNDLE_ROOT: {bundle_root}")
    print("")

    return Validator(bundle_root).run()


if __name__ == "__main__":
    raise SystemExit(main())
