#!/usr/bin/env python3
"""
SDX 会话激活态管理（供 preToolUse 钩子共享）。

语义：
- 会话内一旦检测到 /sdx-*，即标记为 active；
- 后续同会话持续 active，直到会话结束（状态文件按会话 ID 隔离）；
- 读取/写入异常时走 fail-open，不抛异常阻断主流程。
"""
from __future__ import annotations

import json
import os
import re
import tempfile
from pathlib import Path

_SESSION_ID_KEYS = {
    "sessionId",
    "session_id",
    "conversationId",
    "conversation_id",
    "chatId",
    "chat_id",
}
_SESSION_ID_KEYS_LOWER = {k.lower() for k in _SESSION_ID_KEYS}
_MAX_SESSION_ID_LEN = 120
_STATE_DIR_ENV = "SDX_SESSION_STATE_DIR"


def iter_strings(obj: object):
    if isinstance(obj, str):
        yield obj
    elif isinstance(obj, dict):
        for v in obj.values():
            yield from iter_strings(v)
    elif isinstance(obj, list):
        for v in obj:
            yield from iter_strings(v)


def find_session_id(obj: object) -> str | None:
    if isinstance(obj, dict):
        for k, v in obj.items():
            if isinstance(k, str) and k.lower() in _SESSION_ID_KEYS_LOWER and isinstance(v, str):
                sid = v.strip()
                if sid:
                    return sid
        for v in obj.values():
            sid = find_session_id(v)
            if sid:
                return sid
    elif isinstance(obj, list):
        for v in obj:
            sid = find_session_id(v)
            if sid:
                return sid
    return None


def _sanitize_session_id(raw: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9._-]", "_", raw.strip())
    if not cleaned:
        return "default"
    return cleaned[:_MAX_SESSION_ID_LEN]


def _state_dir(environ: dict[str, str] | None = None) -> Path:
    env = environ if environ is not None else os.environ
    configured = env.get(_STATE_DIR_ENV)
    if configured:
        return Path(configured)
    return Path(tempfile.gettempdir()) / "ai-knowledge-sdx-session"


def session_state_path(payload: object, environ: dict[str, str] | None = None) -> Path:
    sid = find_session_id(payload) or "default"
    return _state_dir(environ) / f"{_sanitize_session_id(sid)}.json"


def is_session_active(payload: object, environ: dict[str, str] | None = None) -> bool:
    state_file = session_state_path(payload, environ)
    try:
        if not state_file.is_file():
            return False
        data = json.loads(state_file.read_text(encoding="utf-8", errors="replace"))
    except (OSError, json.JSONDecodeError):
        return False
    return bool(data.get("active"))


def activate_session(payload: object, environ: dict[str, str] | None = None) -> bool:
    state_file = session_state_path(payload, environ)
    state_file.parent.mkdir(parents=True, exist_ok=True)
    state_file.write_text(json.dumps({"active": True}, ensure_ascii=False), encoding="utf-8")
    return True
