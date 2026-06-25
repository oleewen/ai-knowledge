#!/usr/bin/env python3
"""
SDX 阶段写入闸门（preToolUse）：根据 --gate 选择具体阶段，逻辑共用。

会话触发语义：
- 仅当会话内出现过 /sdx-* 或 /docs-distill、/docs-extract、/docs-archive、/docs-build、/docs-indexing 并被 sdx_session_gate.py 激活后，本闸门才生效；
- 未激活会话时直接 allow（不拦截）。

stdin：Cursor preToolUse JSON（结构可能演进，故递归扫描全部字符串）。
stdout：仅输出一行 JSON（permission 等）。
stderr：可选调试（DEBUG=1）。

用法：
  python3 agent/hooks/sdx_gate_common.py --gate prd
  python3 agent/hooks/sdx_gate_common.py --gate analysis
  （其余：architect | solution | design | test | distill | extract | archive | build | indexing）

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

from session_spec_paths import is_session_spec_path, iter_session_spec_files
from sdx_session_state import get_session_specs, is_session_active, iter_strings

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


def _OVERVIEW_DIR_FRAGMENTS() -> tuple[str, ...]:
    return ("system/knowledge/overview/", "company/knowledge/overview/")


def _make_overview_collector() -> Callable[[list[str]], list[str]]:
    """收集写入 system/knowledge/overview/ 或 company/knowledge/overview/ 下 .md 文件的路径。"""
    fragments = _OVERVIEW_DIR_FRAGMENTS()

    def _collect(strings: list[str]) -> list[str]:
        out: list[str] = []
        for s in strings:
            s_norm = s.replace("\\", "/")
            if not s_norm.endswith(".md"):
                continue
            if any(frag in s_norm for frag in fragments):
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


def _normalize_repo_relative_for_gate(repo: Path, candidate: str) -> str | None:
    """将工具 payload 中的路径规范为仓库根相对 POSIX 路径；无法落在仓库内则 None。"""
    repo_r = repo.resolve()
    raw = (candidate or "").strip().replace("\\", "/")
    if not raw:
        return None
    try:
        p = Path(raw)
        if p.is_absolute():
            full = p.resolve()
        else:
            full = (repo_r / raw.lstrip("./")).resolve()
        rel = full.relative_to(repo_r)
    except (ValueError, OSError):
        return None
    return str(rel).replace("\\", "/")


def _iter_spec_paths_for_gate(
    repo: Path,
    payload: object,
    environ: dict[str, str] | None,
) -> list[Path]:
    ordered: list[Path] = []
    seen: set[str] = set()
    for rel in get_session_specs(payload, environ):
        if not is_session_spec_path(rel, repo=repo):
            continue
        p = (repo / rel).resolve()
        key = str(p)
        if key not in seen and p.is_file():
            seen.add(key)
            ordered.append(p)
    for p in iter_session_spec_files(repo):
        key = str(p.resolve())
        if key not in seen:
            seen.add(key)
            ordered.append(p)
    return ordered


def _spec_text_confirms(path: Path, marker_confirmed: str, basename: str) -> bool:
    basename_pattern = re.compile(
        rf"(?<![A-Za-z0-9._-]){re.escape(basename)}(?![A-Za-z0-9._-])"
    )
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return False
    return marker_confirmed in text and bool(basename_pattern.search(text))


def _has_indexing_write_allowed(
    repo: Path,
    marker_confirmed: str,
    candidate: str,
    payload: object,
    environ: dict[str, str] | None = None,
) -> bool:
    """除 CONFIRMED 标记外，须任一 spec 正文包含与 candidate 一致的仓库根相对路径（防多份 INDEX_GUIDE 同名误放行）。"""
    rel = _normalize_repo_relative_for_gate(repo, candidate)
    if not rel:
        return False
    variants = (rel, f"./{rel}")
    for p in _iter_spec_paths_for_gate(repo, payload, environ):
        try:
            text = p.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        if marker_confirmed not in text:
            continue
        if any(v in text for v in variants):
            return True
    return False


def _make_indexing_collector() -> Callable[[list[str]], list[str]]:
    """收集 INDEX-GUIDE.md 与各域 changelogs/INDEXING-LOG.md 的写入路径。"""

    def _collect(strings: list[str]) -> list[str]:
        out: list[str] = []
        for s in strings:
            s_norm = s.replace("\\", "/")
            if s_norm.endswith("INDEX-GUIDE.md"):
                out.append(s)
                continue
            if s_norm.endswith("INDEXING-LOG.md") and "/changelogs/" in s_norm:
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
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- docs-build-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名（如 KNOWLEDGE-INDEX.md）。本 gate 无 bypass 环境变量，须完整走确认流程。"
        ),
        basename_prefix="",
        collect=_make_knowledge_collector(),
    ),
    "distill": GateConfig(
        marker_confirmed="<!-- docs-distill-gate: CONFIRMED -->",
        bypass_env="",  # 无 bypass：必须走 CONFIRMED 流程
        debug_label="docs-distill-gate",
        deny_message=(
            "docs-distill：禁止在未完成中间 spec「用户总确认」前写入 system/knowledge/overview/ 或 company/knowledge/overview/ 下的文件。"
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- docs-distill-gate: PENDING --> 改为 CONFIRMED，"
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
            "docs-extract：禁止在未完成中间 spec「用户总确认」前写入 system/knowledge/overview/ 或 company/knowledge/overview/ 下的文件。"
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- docs-extract-gate: PENDING --> 改为 CONFIRMED，"
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
            "docs-archive：禁止在未完成中间 spec「用户总确认」前写入 system/knowledge/overview/ 或 company/knowledge/overview/ 下的文件。"
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- docs-archive-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。本 gate 无 bypass 环境变量，须完整走确认流程。"
        ),
        basename_prefix="",
        collect=_make_overview_collector(),
    ),
    "indexing": GateConfig(
        marker_confirmed="<!-- docs-indexing-gate: CONFIRMED -->",
        bypass_env="",  # 无 bypass
        debug_label="docs-indexing-gate",
        deny_message=(
            "docs-indexing：禁止在未完成中间 spec「用户总确认」前写入 INDEX-GUIDE.md 或 */changelogs/INDEXING-LOG.md。"
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下）维护 `*-docs-indexing.md`，将 <!-- docs-indexing-gate: PENDING --> 改为 CONFIRMED，"
            "且正文须**逐字列出**本轮将写入的仓库根相对路径（例如 application/INDEX-GUIDE.md）。"
            "本 gate 无 bypass 环境变量，须完整走确认流程。"
        ),
        basename_prefix="",
        collect=_make_indexing_collector(),
    ),
    "prd": GateConfig(
        marker_confirmed="<!-- sdx-prd-gate: CONFIRMED -->",
        bypass_env="SDX_PRD_ALLOW_PRD_WRITE",
        debug_label="sdx-prd-gate",
        deny_message=(
            "sdx-prd：禁止在未完成中间 spec「用户总确认」前写入 requirements 下的 PRD 文件。"
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- sdx-prd-gate: PENDING --> 改为 CONFIRMED，"
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
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- sdx-analysis-gate: PENDING --> 改为 CONFIRMED，"
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
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- sdx-solution-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_SOLUTION_ALLOW_SOLUTION_WRITE=1。"
        ),
        basename_prefix="SOLUTION-",
        collect=_make_collector("/solutions/SOLUTION-", "SOLUTION-"),
    ),
    "architect": GateConfig(
        marker_confirmed="<!-- sdx-architect-gate: CONFIRMED -->",
        bypass_env="SDX_ARCHITECT_ALLOW_ASD_WRITE",
        debug_label="sdx-architect-gate",
        deny_message=(
            "sdx-architect：禁止在未完成中间 spec「用户总确认」前写入 requirements 下的 ASD 文件。"
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- sdx-architect-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_ARCHITECT_ALLOW_ASD_WRITE=1。"
        ),
        basename_prefix="ASD-",
        collect=_make_collector("/requirements/", "ASD-"),
    ),
    "design": GateConfig(
        marker_confirmed="<!-- sdx-design-gate: CONFIRMED -->",
        bypass_env="SDX_DESIGN_ALLOW_DSD_WRITE",
        debug_label="sdx-design-gate",
        deny_message=(
            "sdx-design：禁止在未完成中间 spec「用户总确认」前写入 requirements 下的 DSD 文件。"
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- sdx-design-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_DESIGN_ALLOW_DSD_WRITE=1。"
        ),
        basename_prefix="DSD-",
        collect=_make_collector("/requirements/", "DSD-"),
    ),
    "test": GateConfig(
        marker_confirmed="<!-- sdx-test-gate: CONFIRMED -->",
        bypass_env="SDX_TEST_ALLOW_TDD_WRITE",
        debug_label="sdx-test-gate",
        deny_message=(
            "sdx-test：禁止在未完成中间 spec「用户总确认」前写入 requirements 下的 TDD 文件。"
            "请先在当前会话 spec（{DOC_DIR}/superpowers/specs/ 下，见 agent/references/session-spec-path.md）维护，将 <!-- sdx-test-gate: PENDING --> 改为 CONFIRMED，"
            "并确保文中引用目标文件名。若确需跳过闸门（仅限人工授权），可在环境中设置 SDX_TEST_ALLOW_TDD_WRITE=1。"
        ),
        basename_prefix="TDD-",
        collect=_make_collector("/requirements/", "TDD-"),
    ),
}


def _repo_root() -> Path:
    here = Path(__file__).resolve()
    return here.parents[2]


def _has_confirmed_spec(
    repo: Path,
    marker_confirmed: str,
    basename: str,
    payload: object,
    environ: dict[str, str] | None = None,
) -> bool:
    for p in _iter_spec_paths_for_gate(repo, payload, environ):
        if _spec_text_confirms(p, marker_confirmed, basename):
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
        if gate_id == "indexing":
            if _has_indexing_write_allowed(repo, cfg.marker_confirmed, c, payload, env):
                continue
        else:
            base = Path(c.replace("\\", "/")).name
            if _has_confirmed_spec(repo, cfg.marker_confirmed, base, payload, env):
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
        help="阶段：architect | archive | analysis | build | design | distill | extract | indexing | prd | solution | test",
    )
    return p


def main(argv: list[str] | None = None) -> int:
    args = _build_arg_parser().parse_args(argv)
    return run_gate(args.gate)


if __name__ == "__main__":
    raise SystemExit(main())
