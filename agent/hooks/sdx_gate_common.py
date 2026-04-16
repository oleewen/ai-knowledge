#!/usr/bin/env python3
"""
SDX 阶段写入闸门（preToolUse）：根据 --gate 选择具体阶段，逻辑共用。

会话触发语义：
- 仅当会话内出现过 /sdx-* 并被 sdx_session_gate.py 激活后，本闸门才生效；
- 未激活会话时直接 allow（不拦截）。

stdin：Cursor preToolUse JSON（结构可能演进，故递归扫描全部字符串）。
stdout：仅输出一行 JSON（permission 等）。
stderr：可选调试（DEBUG=1）。

用法：
  python3 agent/hooks/sdx_gate_common.py --gate prd
  python3 agent/hooks/sdx_gate_common.py --gate analysis
  （其余：solution | design | test）
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent))

from sdx_session_state import is_session_active

# ---------------------------------------------------------------------------
# 各阶段：候选路径收集（须与历史五脚本行为一致）
# ---------------------------------------------------------------------------


def _collect_prd(strings: list[str]) -> list[str]:
    out: list[str] = []
    for s in strings:
        s_norm = s.replace("\\", "/")
        if "/requirements/" not in s_norm or not s_norm.endswith(".md"):
            continue
        base = s_norm.rsplit("/", 1)[-1]
        if base.startswith("PRD-") and base.endswith(".md"):
            out.append(s)
    return out


def _collect_analysis(strings: list[str]) -> list[str]:
    out: list[str] = []
    for s in strings:
        s_norm = s.replace("\\", "/")
        if "/analysis/ANALYSIS-" not in s_norm or not s_norm.endswith(".md"):
            continue
        base = s_norm.rsplit("/", 1)[-1]
        if base.startswith("ANALYSIS-") and base.endswith(".md"):
            out.append(s)
    return out


def _collect_solution(strings: list[str]) -> list[str]:
    out: list[str] = []
    for s in strings:
        s_norm = s.replace("\\", "/")
        if "/solutions/SOLUTION-" not in s_norm or not s_norm.endswith(".md"):
            continue
        base = s_norm.rsplit("/", 1)[-1]
        if base.startswith("SOLUTION-") and base.endswith(".md"):
            out.append(s)
    return out


def _collect_add(strings: list[str]) -> list[str]:
    out: list[str] = []
    for s in strings:
        s_norm = s.replace("\\", "/")
        if "/requirements/" not in s_norm or not s_norm.endswith(".md"):
            continue
        base = s_norm.rsplit("/", 1)[-1]
        if base.startswith("ADD-") and base.endswith(".md"):
            out.append(s)
    return out


def _collect_tdd(strings: list[str]) -> list[str]:
    out: list[str] = []
    for s in strings:
        s_norm = s.replace("\\", "/")
        if "/requirements/" not in s_norm or not s_norm.endswith(".md"):
            continue
        base = s_norm.rsplit("/", 1)[-1]
        if base.startswith("TDD-") and base.endswith(".md"):
            out.append(s)
    return out


@dataclass(frozen=True)
class GateConfig:
    marker_confirmed: str
    bypass_env: str
    debug_label: str
    deny_message: str
    basename_prefix: str
    collect: Callable[[list[str]], list[str]]


GATES: dict[str, GateConfig] = {
    "prd": GateConfig(
        marker_confirmed="<!-- sdx-prd-gate: CONFIRMED -->",
        bypass_env="SDX_PRD_ALLOW_PRD_WRITE",
        debug_label="sdx-prd-gate",
        deny_message=(
            "sdx-prd：禁止在未完成中间 spec「用户总确认」前写入 requirements 下的 PRD 文件。"
            "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- sdx-prd-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_PRD_ALLOW_PRD_WRITE=1。"
        ),
        basename_prefix="PRD-",
        collect=_collect_prd,
    ),
    "analysis": GateConfig(
        marker_confirmed="<!-- sdx-analysis-gate: CONFIRMED -->",
        bypass_env="SDX_ANALYSIS_ALLOW_ANALYSIS_WRITE",
        debug_label="sdx-analysis-gate",
        deny_message=(
            "sdx-analysis：禁止在未完成中间 spec「用户总确认」前写入 analysis 下的 ANALYSIS 文件。"
            "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- sdx-analysis-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_ANALYSIS_ALLOW_ANALYSIS_WRITE=1。"
        ),
        basename_prefix="ANALYSIS-",
        collect=_collect_analysis,
    ),
    "solution": GateConfig(
        marker_confirmed="<!-- sdx-solution-gate: CONFIRMED -->",
        bypass_env="SDX_SOLUTION_ALLOW_SOLUTION_WRITE",
        debug_label="sdx-solution-gate",
        deny_message=(
            "sdx-solution：禁止在未完成中间 spec「用户总确认」前写入 solutions 下的 SOLUTION 文件。"
            "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- sdx-solution-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_SOLUTION_ALLOW_SOLUTION_WRITE=1。"
        ),
        basename_prefix="SOLUTION-",
        collect=_collect_solution,
    ),
    "design": GateConfig(
        marker_confirmed="<!-- sdx-design-gate: CONFIRMED -->",
        bypass_env="SDX_DESIGN_ALLOW_ADD_WRITE",
        debug_label="sdx-design-gate",
        deny_message=(
            "sdx-design：禁止在未完成中间 spec「用户总确认」前写入 requirements 下的 ADD 文件。"
            "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- sdx-design-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_DESIGN_ALLOW_ADD_WRITE=1。"
        ),
        basename_prefix="ADD-",
        collect=_collect_add,
    ),
    "test": GateConfig(
        marker_confirmed="<!-- sdx-test-gate: CONFIRMED -->",
        bypass_env="SDX_TEST_ALLOW_TDD_WRITE",
        debug_label="sdx-test-gate",
        deny_message=(
            "sdx-test：禁止在未完成中间 spec「用户总确认」前写入 requirements 下的 TDD 文件。"
            "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- sdx-test-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_TEST_ALLOW_TDD_WRITE=1。"
        ),
        basename_prefix="TDD-",
        collect=_collect_tdd,
    ),
}


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


def _has_confirmed_spec(repo: Path, marker_confirmed: str, basename: str) -> bool:
    specs_dir = repo / "docs" / "superpowers" / "specs"
    if not specs_dir.is_dir():
        return False
    for p in specs_dir.rglob("*.md"):
        try:
            text = p.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if marker_confirmed not in text:
            continue
        if basename in text:
            return True
    return False


def run_gate(
    gate_id: str,
    *,
    stdin: str | None = None,
    environ: dict[str, str] | None = None,
) -> int:
    """执行闸门逻辑；stdin 默认从 sys.stdin 读取；environ 默认 os.environ。"""
    cfg = GATES[gate_id]
    env = environ if environ is not None else os.environ

    if env.get(cfg.bypass_env) == "1":
        print('{"permission": "allow"}', flush=True)
        return 0

    raw = stdin if stdin is not None else sys.stdin.read()
    if not raw.strip():
        print('{"permission": "allow"}', flush=True)
        return 0

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        if env.get("DEBUG"):
            print(f"{cfg.debug_label}: JSON parse fail, fail-open", file=sys.stderr)
        print('{"permission": "allow"}', flush=True)
        return 0

    if not is_session_active(payload, env):
        if env.get("DEBUG"):
            print(f"{cfg.debug_label}: session not active, allow", file=sys.stderr)
        print('{"permission": "allow"}', flush=True)
        return 0

    strings = list(_iter_strings(payload))
    candidates = list(dict.fromkeys(cfg.collect(strings)))
    if not candidates:
        print('{"permission": "allow"}', flush=True)
        return 0

    repo = _repo_root()
    deny_paths: list[str] = []
    for c in candidates:
        base = Path(c.replace("\\", "/")).name
        if not base.startswith(cfg.basename_prefix) or not base.endswith(".md"):
            continue
        if _has_confirmed_spec(repo, cfg.marker_confirmed, base):
            continue
        deny_paths.append(c)

    if not deny_paths:
        print('{"permission": "allow"}', flush=True)
        return 0

    msg = cfg.deny_message
    out = {
        "permission": "deny",
        "user_message": msg,
        "agent_message": msg + f" 目标: {deny_paths!r}",
    }
    print(json.dumps(out, ensure_ascii=False), flush=True)
    return 0


def _build_arg_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="SDX 写入闸门：按 --gate 选择阶段，从 stdin 读取 preToolUse JSON。",
    )
    p.add_argument(
        "--gate",
        required=True,
        choices=sorted(GATES.keys()),
        help="阶段：prd | analysis | solution | design | test",
    )
    return p


def main(argv: list[str] | None = None) -> int:
    args = _build_arg_parser().parse_args(argv)
    return run_gate(args.gate)


if __name__ == "__main__":
    raise SystemExit(main())
