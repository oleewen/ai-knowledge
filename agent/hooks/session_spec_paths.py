#!/usr/bin/env python3
"""会话 spec 路径判定与枚举（见 agent/references/session-spec-path.md）。"""
from __future__ import annotations

import re
from pathlib import Path
from typing import Iterator

_SESSION_SPEC_SHAPE_ROOTS = frozenset({"application", "system", "company", "docs"})
_SESSION_SPEC_PREFIX = "superpowers/specs"
_DEFAULT_DOC_DIR = "docs"

_PATH_IN_TEXT_RE = re.compile(
    r"(?<![A-Za-z0-9._-])"
    r"((?:application|system|company|docs)/superpowers/specs/[^\s\"']+\.md)"
)


def normalize_repo_relative(raw: str) -> str:
    return raw.replace("\\", "/").strip().lstrip("./")


def parse_doc_dir_from_docsconfig_text(text: str) -> str | None:
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if stripped.startswith("DOC_DIR="):
            return stripped.split("=", 1)[1].strip().strip('"').strip("'")
    return None


def normalize_configured_doc_dir(raw: str | None) -> str | None:
    if raw is None:
        return None
    value = raw.strip().strip('"').strip("'")
    if not value or value == ".":
        return None
    return normalize_repo_relative(value).split("/")[0] or None


def resolve_session_spec_doc_dir(repo: Path) -> str:
    """Effective DOC_DIR for session specs: .docsconfig DOC_DIR, else docs."""
    cfg = repo / ".docsconfig"
    if not cfg.is_file():
        return _DEFAULT_DOC_DIR
    try:
        text = cfg.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return _DEFAULT_DOC_DIR
    configured = normalize_configured_doc_dir(parse_doc_dir_from_docsconfig_text(text))
    return configured if configured else _DEFAULT_DOC_DIR


def _has_session_spec_shape(rel: str) -> bool:
    rel = normalize_repo_relative(rel)
    if not rel.endswith(".md") or "/requirements/" in rel:
        return False
    parts = rel.split("/")
    if len(parts) < 4:
        return False
    if parts[0] not in _SESSION_SPEC_SHAPE_ROOTS:
        return False
    if parts[1] != "superpowers" or parts[2] != "specs":
        return False
    return True


def is_session_spec_path(rel: str, *, repo: Path | None = None) -> bool:
    if not _has_session_spec_shape(rel):
        return False
    if repo is None:
        return True
    parts = normalize_repo_relative(rel).split("/")
    return parts[0] == resolve_session_spec_doc_dir(repo)


def iter_session_spec_files(repo: Path) -> Iterator[Path]:
    doc_dir = resolve_session_spec_doc_dir(repo)
    specs_dir = repo / doc_dir / "superpowers" / "specs"
    if not specs_dir.is_dir():
        return
    for p in specs_dir.rglob("*.md"):
        try:
            rel = p.relative_to(repo)
        except ValueError:
            continue
        rel_s = str(rel).replace("\\", "/")
        if is_session_spec_path(rel_s, repo=repo):
            yield p


def session_specs_from_payload(strings: list[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for s in strings:
        for m in _PATH_IN_TEXT_RE.finditer(s):
            rel = normalize_repo_relative(m.group(1))
            if _has_session_spec_shape(rel) and rel not in seen:
                seen.add(rel)
                out.append(rel)
    return out
