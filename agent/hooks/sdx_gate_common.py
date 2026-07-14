#!/usr/bin/env python3
"""
Legacy hook compatibility shim.

历史上本文件用于 sdx/docs 写前 gate；当前仓库主协议已切到
“参数向导 + 当前段/当前单元 + 自动 grilling + 用户动作推进”，
不再默认依赖会话 spec、CONFIRMED 或 preToolUse 写入拦截。

保留本文件仅为了兼容已安装但尚未刷新 hooks.json 的目标工程：
- 接受旧 `--gate` 参数；
- 永远 fail-open 返回 allow；
- DEBUG=1 时输出兼容提示到 stderr。
"""
from __future__ import annotations

import argparse
import os
import sys

LEGACY_GATES = (
    "architect",
    "archive",
    "build",
    "design",
    "distill",
    "extract",
    "indexing",
    "prd",
    "solution",
    "test",
)


def run_gate(
    gate_id: str,
    *,
    stdin: str | None = None,
    environ: dict[str, str] | None = None,
) -> int:
    del stdin
    env = environ if environ is not None else os.environ
    if env.get("DEBUG"):
        print(
            f"sdx_gate_common: legacy gate '{gate_id}' is disabled, allow",
            file=sys.stderr,
        )
    print('{"permission": "allow"}', flush=True)
    return 0


def _build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Legacy compatibility shim for retired preToolUse write gates.",
    )
    parser.add_argument(
        "--gate",
        required=True,
        choices=LEGACY_GATES,
        help="Legacy gate id kept for compatibility only.",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _build_arg_parser().parse_args(argv)
    return run_gate(args.gate)


if __name__ == "__main__":
    raise SystemExit(main())
