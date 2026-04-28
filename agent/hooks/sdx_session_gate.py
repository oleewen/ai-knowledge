#!/usr/bin/env python3
"""
SDX 会话激活钩子（preToolUse）。

职责：
- 仅识别当前会话是否出现过 /sdx-* 指令；
- 命中后写入会话激活态；
- 永远返回 allow（由 sdx_gate_common.py 决定具体拦截）。
"""
from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent))

from sdx_session_state import activate_session, iter_strings

_SDX_COMMAND_PATTERN = re.compile(
    r"/(?:sdx-solution|sdx-analysis|sdx-prd|sdx-design|sdx-test"
    r"|docs-distill|docs-extract|docs-archive|docs-build)\b",
    re.IGNORECASE,
)


def _allow() -> int:
    print('{"permission": "allow"}', flush=True)
    return 0


def run(stdin: str | None = None, environ: dict[str, str] | None = None) -> int:
    env = environ if environ is not None else os.environ
    raw = stdin if stdin is not None else sys.stdin.read()
    if not raw.strip():
        return _allow()

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        if env.get("DEBUG"):
            print("sdx-session-gate: JSON parse fail, fail-open", file=sys.stderr)
        return _allow()

    try:
        matched = any(_SDX_COMMAND_PATTERN.search(s) for s in iter_strings(payload))
        if matched:
            activate_session(payload, env)
            if env.get("DEBUG"):
                print("sdx-session-gate: activated", file=sys.stderr)
    except OSError:
        # 会话状态写入异常时 fail-open
        if env.get("DEBUG"):
            print("sdx-session-gate: state write fail, fail-open", file=sys.stderr)

    return _allow()


def main() -> int:
    return run()


if __name__ == "__main__":
    raise SystemExit(main())
