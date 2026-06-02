#!/usr/bin/env python3
"""会话 spec 路径判定与枚举（见 agent/references/session-spec-path.md）。"""
from __future__ import annotations

import re
from pathlib import Path
from typing import Iterator

# 会话闸门 spec 统一落在 {DOC_DIR}/superpowers/
_SESSION_SPEC_DIR_NAMES = ("superpowers",)
_DOCROOTS = frozenset({"application", "system", "company"})
_DIR_ALT = "|".join(_SESSION_SPEC_DIR_NAMES)

_PATH_IN_TEXT_RE = re.compile(
    rf"(?<![A-Za-z0-9._-])((?:application|system|company|[^/\s]+)/(?:{_DIR_ALT})/[^\s\"']+\.md)"
)


def normalize_repo_relative(raw: str) -> str:
    return raw.replace("\\", "/").strip().lstrip("./")


def is_session_spec_path(rel: str) -> bool:
    rel = normalize_repo_relative(rel)
    if not rel.endswith(".md") or "/requirements/" in rel:
        return False
    parts = rel.split("/")
    if len(parts) < 3 or parts[0] not in _DOCROOTS or parts[1] not in _SESSION_SPEC_DIR_NAMES:
        return False
    return True


def iter_session_spec_files(repo: Path) -> Iterator[Path]:
    for docroot_name in sorted(_DOCROOTS):
        docroot = repo / docroot_name
        if not docroot.is_dir():
            continue
        for dir_name in _SESSION_SPEC_DIR_NAMES:
            container = docroot / dir_name
            if not container.is_dir():
                continue
            for p in container.rglob("*.md"):
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
