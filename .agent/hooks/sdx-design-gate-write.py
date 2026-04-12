#!/usr/bin/env python3
"""
preToolUse：拦截对 **/requirements/**/ADD-*.md 的写入类工具调用，
除非已在 docs/superpowers/specs/ 下存在带闸门总确认标记的会话 spec。

放行条件（任一）：
  1. 环境变量 SDX_DESIGN_ALLOW_ADD_WRITE=1
  2. 存在至少一个 docs/superpowers/specs/**/*.md，同时包含：
     - 子串 `<!-- sdx-design-gate: CONFIRMED -->`
     - 与本次写入目标同名的 `ADD-*.md` 文件名（basename）

stdin：Cursor preToolUse JSON（结构可能演进，故递归扫描全部字符串）。
stdout：仅输出一行 JSON（permission 等）。
stderr：可选调试（DEBUG=1）。
"""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

MARKER_CONFIRMED = "<!-- sdx-design-gate: CONFIRMED -->"


def _repo_root() -> Path:
    here = Path(__file__).resolve()
    return here.parents[2]


def _iter_strings(obj: object):
    if isinstance(obj, str):
        yield obj
    elif isinstance(obj, dict):
        for v in obj.values():
            yield from _iter_strings(v)
    elif isinstance(obj, list):
        for v in obj:
            yield from _iter_strings(v)


def _candidate_add_paths(strings: list[str]) -> list[str]:
    """从工具参数中收集指向 requirements/**/ADD-*.md 的路径。"""
    out: list[str] = []
    for s in strings:
        s_norm = s.replace("\\", "/")
        if "/requirements/" not in s_norm or not s_norm.endswith(".md"):
            continue
        base = s_norm.rsplit("/", 1)[-1]
        if base.startswith("ADD-") and base.endswith(".md"):
            out.append(s)
    return out


def _has_confirmed_spec(repo: Path, basename: str) -> bool:
    specs_dir = repo / "docs" / "superpowers" / "specs"
    if not specs_dir.is_dir():
        return False
    for p in specs_dir.rglob("*.md"):
        try:
            text = p.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if MARKER_CONFIRMED not in text:
            continue
        if basename in text:
            return True
    return False


def main() -> int:
    if os.environ.get("SDX_DESIGN_ALLOW_ADD_WRITE") == "1":
        print('{"permission": "allow"}', flush=True)
        return 0

    raw = sys.stdin.read()
    if not raw.strip():
        print('{"permission": "allow"}', flush=True)
        return 0

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        if os.environ.get("DEBUG"):
            print("sdx-design-gate: JSON parse fail, fail-open", file=sys.stderr)
        print('{"permission": "allow"}', flush=True)
        return 0

    strings = list(_iter_strings(payload))
    candidates = list(dict.fromkeys(_candidate_add_paths(strings)))
    if not candidates:
        print('{"permission": "allow"}', flush=True)
        return 0

    repo = _repo_root()
    deny_paths: list[str] = []
    for c in candidates:
        base = Path(c.replace("\\", "/")).name
        if not base.startswith("ADD-") or not base.endswith(".md"):
            continue
        if _has_confirmed_spec(repo, base):
            continue
        deny_paths.append(c)

    if not deny_paths:
        print('{"permission": "allow"}', flush=True)
        return 0

    msg = (
        "sdx-design：禁止在未完成中间 spec「用户总确认」前写入 requirements 下的 ADD 文件。"
        "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- sdx-design-gate: PENDING --> 改为 CONFIRMED，"
        "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_DESIGN_ALLOW_ADD_WRITE=1。"
    )
    out = {
        "permission": "deny",
        "user_message": msg,
        "agent_message": msg + f" 目标: {deny_paths!r}",
    }
    print(json.dumps(out, ensure_ascii=False), flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
