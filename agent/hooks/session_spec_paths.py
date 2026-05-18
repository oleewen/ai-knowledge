#!/usr/bin/env python3
"""会话 spec 路径判定与枚举（见 agent/references/session-spec-path.md）。"""
from __future__ import annotations

import re
from pathlib import Path
from typing import Iterator

_PATH_IN_TEXT_RE = re.compile(
    r"(?<![A-Za-z0-9._-])((?:application|system|company|[^/\s]+)/specs/[^\s\"']+\.md)"
)


def normalize_repo_relative(raw: str) -> str:
    return raw.replace("\\", "/").strip().lstrip("./")


def is_session_spec_path(rel: str) -> bool:
    rel = normalize_repo_relative(rel)
    if not rel.endswith(".md") or "/requirements/" in rel:
        return False
    parts = rel.split("/")
    if len(parts) < 3 or parts[1] != "specs":
        return False
    return True


def iter_session_spec_files(repo: Path) -> Iterator[Path]:
    for docroot in repo.iterdir():
        if not docroot.is_dir() or docroot.name.startswith("."):
            continue
        specs = docroot / "specs"
        if not specs.is_dir():
            continue
        for p in specs.rglob("*.md"):
            try:
                rel = p.relative_to(repo)
            except ValueError:
                continue
            if is_session_spec_path(str(rel).replace("\\", "/")):
                yield p


def session_specs_from_payload(strings: list[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for s in strings:
        for m in _PATH_IN_TEXT_RE.finditer(s):
            rel = normalize_repo_relative(m.group(1))
            if is_session_spec_path(rel) and rel not in seen:
                seen.add(rel)
                out.append(rel)
    return out
