#!/usr/bin/env python3
"""检查会话目录外的具体文件引用；目录说明和路径占位模式不算引用。"""
from pathlib import Path
from bisect import bisect_right
import re
import subprocess
import sys
from urllib.parse import unquote


SESSION_NAMES = {"superpowers", ".superpowers"}
PREFIX = r"(?<![\w.+@-])(?:[^/\s`\"'<>\[\]():=，。；]+/|/)*\.?" + "superpowers/"
REFERENCE = re.compile(PREFIX + r"[^\s`\"'\[\](),，。；]+")
PLACEHOLDER = re.compile(r"[{}*$<>|\\]|%(?:[0-9.+-]*[sd])|YYYY-MM-DD")
EXCLUDED = (".git", ".worktrees", "node_modules", "__pycache__", "target")


def concrete_reference(value: str, source: Path, root: Path, markdown: bool) -> bool:
    value = value.split("#", 1)[0].split("?", 1)[0]
    suffix = value.split("superpowers/", 1)[1]
    if not suffix or suffix.endswith("/") or PLACEHOLDER.search(suffix):
        return False
    # 无斜杠的标准分类名仍是目录说明；其他无扩展名目标照常检查。
    if suffix in {"specs", "plans", "sdd"}:
        return False
    # Markdown 目标相对来源；裸路径按仓根，显式 ../ 或 ./ 则按来源。
    base = source.parent if markdown or value.startswith(("./", "../")) else root
    if (base / value).is_dir():
        return False
    return True


def scan(root: Path) -> int:
    command = ["rg", "--no-config", "--files", "--hidden", "--no-ignore", "-0"]
    for name in (*sorted(SESSION_NAMES), *EXCLUDED):
        command.extend(["--glob", f"!**/{name}/**"])
    result = subprocess.run(command + ["."], cwd=root, capture_output=True)
    if result.returncode not in (0, 1):
        sys.stderr.buffer.write(result.stderr)
        raise RuntimeError(f"引用扫描未完成（rg exit {result.returncode}）")
    violations = []
    for raw_path in result.stdout.split(b"\0"):
        if not raw_path:
            continue
        source = root / raw_path.decode("utf-8", errors="surrogateescape")
        if source.is_symlink():
            continue
        content = source.read_bytes()
        if b"\0" in content:
            continue
        decoded = unquote(content.decode("utf-8", errors="replace"))
        line_starts = [0] + [match.end() for match in re.finditer("\n", decoded)]
        for match in REFERENCE.finditer(decoded):
            value = match.group().rstrip(".,;:>")
            preceding = decoded[:match.start()]
            markdown = bool(re.search(r"\]\(\s*<?$|\]:\s*<?$", preceding))
            if concrete_reference(value, source, root, markdown):
                number = bisect_right(line_starts, match.start())
                column = match.start() - line_starts[number - 1] + 1
                violations.append(f"{source.relative_to(root)}:{number}:{column}: {value}")
    if violations:
        print("\n".join(violations), file=sys.stderr)
        print(f"[FAIL] 发现 {len(violations)} 处 superpowers 具体文件引用（目录外）", file=sys.stderr)
        return 1
    print("[OK] 未发现目录外 superpowers 具体文件引用")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(scan(Path(sys.argv[1]).resolve()))
    except (OSError, RuntimeError) as error:
        print(f"[ERROR] {error}", file=sys.stderr)
        sys.exit(2)
