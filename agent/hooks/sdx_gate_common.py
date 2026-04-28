#!/usr/bin/env python3
"""
SDX 阶段写入闸门（preToolUse）：根据 --gate 选择具体阶段，逻辑共用。

会话触发语义：
- 仅当会话内出现过 /sdx-* 或 /docs-distill|extract|archive|build 并被 sdx_session_gate.py 激活后，本闸门才生效；
- 未激活会话时直接 allow（不拦截）。

stdin：Cursor preToolUse JSON（结构可能演进，故递归扫描全部字符串）。
stdout：仅输出一行 JSON（permission 等）。
stderr：可选调试（DEBUG=1）。

用法：
  python3 agent/hooks/sdx_gate_common.py --gate prd
  python3 agent/hooks/sdx_gate_common.py --gate analysis
  （其余：solution | design | test | distill | extract | archive | build）

bypass_env 为空字符串（""）表示该 gate 无 bypass 机制，必须完整走 CONFIRMED 流程。
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent))

from sdx_session_state import is_session_active, iter_strings

# ---------------------------------------------------------------------------
# 各阶段：候选路径收集（须与历史五脚本行为一致）
# ---------------------------------------------------------------------------


def _make_collector(dir_fragment: str, prefix: str) -> Callable[[list[str]], list[str]]:
    """工厂：生成按目录片段与文件名前缀过滤路径字符串的收集函数。"""
    def _collect(strings: list[str]) -> list[str]:
        out: list[str] = []
        for s in strings:
            s_norm = s.replace("\\", "/")
            if dir_fragment not in s_norm or not s_norm.endswith(".md"):
                continue
            if s_norm.rsplit("/", 1)[-1].startswith(prefix):
                out.append(s)
        return out
    return _collect


@dataclass(frozen=True)
class GateConfig:
    marker_confirmed: str
    bypass_env: str
    debug_label: str
    deny_message: str
    basename_prefix: str
    collect: Callable[[list[str]], list[str]]


def _make_overview_collector() -> Callable[[list[str]], list[str]]:
    """收集写入 system/architecture/overview/ 下 .md 文件的路径。"""
    def _collect(strings: list[str]) -> list[str]:
        out: list[str] = []
        for s in strings:
            s_norm = s.replace("\\", "/")
            if "system/architecture/overview/" in s_norm and s_norm.endswith(".md"):
                out.append(s)
        return out
    return _collect


def _make_knowledge_collector() -> Callable[[list[str]], list[str]]:
    """收集写入 {DOC_DIR}/knowledge/ 下文件的路径（按路径片段 /knowledge/ 匹配）。"""
    def _collect(strings: list[str]) -> list[str]:
        out: list[str] = []
        for s in strings:
            s_norm = s.replace("\\", "/")
            # 匹配 knowledge/ 目录下的 .md 或 .json 文件
            if "/knowledge/" in s_norm and (s_norm.endswith(".md") or s_norm.endswith(".json")):
                out.append(s)
        return out
    return _collect


GATES: dict[str, GateConfig] = {
    "build": GateConfig(
        marker_confirmed="<!-- docs-build-gate: CONFIRMED -->",
        bypass_env="",  # 无 bypass
        debug_label="docs-build-gate",
        deny_message=(
            "docs-build：禁止在未完成中间 spec「用户总确认」前写入 knowledge/ 下的文件。"
            "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- docs-build-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名（如 KNOWLEDGE_INDEX.md）。本 gate 无 bypass 环境变量，须完整走确认流程。"
        ),
        basename_prefix="",
        collect=_make_knowledge_collector(),
    ),
    "distill": GateConfig(
        marker_confirmed="<!-- docs-distill-gate: CONFIRMED -->",
        bypass_env="",  # 无 bypass：必须走 CONFIRMED 流程
        debug_label="docs-distill-gate",
        deny_message=(
            "docs-distill：禁止在未完成中间 spec「用户总确认」前写入 system/architecture/overview/ 下的文件。"
            "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- docs-distill-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。本 gate 无 bypass 环境变量，须完整走确认流程。"
        ),
        basename_prefix="",  # overview 文件名不固定，由路径收集器负责过滤
        collect=_make_overview_collector(),
    ),
    "extract": GateConfig(
        marker_confirmed="<!-- docs-extract-gate: CONFIRMED -->",
        bypass_env="",  # 无 bypass
        debug_label="docs-extract-gate",
        deny_message=(
            "docs-extract：禁止在未完成中间 spec「用户总确认」前写入 system/architecture/overview/ 下的文件。"
            "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- docs-extract-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。本 gate 无 bypass 环境变量，须完整走确认流程。"
        ),
        basename_prefix="",
        collect=_make_overview_collector(),
    ),
    "archive": GateConfig(
        marker_confirmed="<!-- docs-archive-gate: CONFIRMED -->",
        bypass_env="",  # 无 bypass
        debug_label="docs-archive-gate",
        deny_message=(
            "docs-archive：禁止在未完成中间 spec「用户总确认」前写入 system/architecture/overview/ 下的文件。"
            "请先在 docs/superpowers/specs/ 维护会话 spec，将 <!-- docs-archive-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。本 gate 无 bypass 环境变量，须完整走确认流程。"
        ),
        basename_prefix="",
        collect=_make_overview_collector(),
    ),
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
        collect=_make_collector("/requirements/", "PRD-"),
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
        collect=_make_collector("/analysis/ANALYSIS-", "ANALYSIS-"),
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
        collect=_make_collector("/solutions/SOLUTION-", "SOLUTION-"),
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
        collect=_make_collector("/requirements/", "ADD-"),
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
        collect=_make_collector("/requirements/", "TDD-"),
    ),
}


def _repo_root() -> Path:
    here = Path(__file__).resolve()
    return here.parents[2]


def _has_confirmed_spec(repo: Path, marker_confirmed: str, basename: str) -> bool:
    specs_dir = repo / "docs" / "superpowers" / "specs"
    if not specs_dir.is_dir():
        return False
    # 仅接受“独立文件名标记”，避免相似名称的子串误命中。
    basename_pattern = re.compile(
        rf"(?<![A-Za-z0-9._-]){re.escape(basename)}(?![A-Za-z0-9._-])"
    )
    for p in specs_dir.rglob("*.md"):
        try:
            text = p.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if marker_confirmed not in text:
            continue
        if basename_pattern.search(text):
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

    # bypass_env 为空字符串表示该 gate 无 bypass 机制，跳过此检查
    if cfg.bypass_env and env.get(cfg.bypass_env) == "1":
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

    strings = list(iter_strings(payload))
    candidates = list(dict.fromkeys(cfg.collect(strings)))
    if not candidates:
        print('{"permission": "allow"}', flush=True)
        return 0

    repo = _repo_root()
    deny_paths: list[str] = []
    for c in candidates:
        base = Path(c.replace("\\", "/")).name
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
        help="阶段：archive | analysis | design | distill | extract | prd | solution | test",
    )
    return p


def main(argv: list[str] | None = None) -> int:
    args = _build_arg_parser().parse_args(argv)
    return run_gate(args.gate)


if __name__ == "__main__":
    raise SystemExit(main())
