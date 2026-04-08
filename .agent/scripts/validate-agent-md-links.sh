#!/usr/bin/env bash
# validate-agent-md-links.sh — 校验 .agent 下 Markdown 链接：.agent 内互链须存在；跨出 .agent 须落在
# REPO_ROOT 或 REPO_DOC_ROOT 下（且非 .git），落实 link-reachability §1.1 强校验。
# 在仓库根执行：bash .agent/scripts/validate-agent-md-links.sh

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$REPO_ROOT" ]] || { echo "[ERROR] 请在 git 仓库内执行"; exit 1; }

AGENT_DIR="$REPO_ROOT/.agent"
[[ -d "$AGENT_DIR" ]] || { echo "[ERROR] 未找到 $AGENT_DIR"; exit 1; }

# shellcheck disable=SC1091
source "$AGENT_DIR/scripts/sdx-doc-root.sh"
REPO_DOC_ROOT="$(sdx_resolve_repo_doc_root "" "$REPO_ROOT")"

export REPO_ROOT AGENT_DIR REPO_DOC_ROOT
exec python3 << 'PY'
import os
import re
import sys

repo = os.environ["REPO_ROOT"]
agent = os.environ["AGENT_DIR"]
doc_root = os.environ["REPO_DOC_ROOT"]
link_re = re.compile(r"\]\(([^)]+)\)")

errs = []
warns = []


def norm(p: str) -> str:
    return os.path.normpath(p)


def is_under(path: str, root: str) -> bool:
    a, b = norm(path), norm(root)
    return a == b or a.startswith(b + os.sep)


def is_external(p: str) -> bool:
    p = p.strip()
    return not p or p.startswith(("#", "http://", "https://", "mailto:"))


git_dir = os.path.join(repo, ".git")

for dirpath, _, files in os.walk(agent):
    for name in files:
        if not name.endswith(".md"):
            continue
        path = os.path.join(dirpath, name)
        rel_md = os.path.relpath(path, repo)
        try:
            text = open(path, encoding="utf-8").read()
        except OSError as e:
            warns.append(f"{rel_md}: 无法读取 ({e})")
            continue
        for m in link_re.finditer(text):
            raw = m.group(1).strip()
            if is_external(raw.split("#", 1)[0]):
                continue
            target = raw.split("#", 1)[0].strip()
            if not target:
                continue
            joined = norm(os.path.join(os.path.dirname(path), target))
            # .agent 内互链：目标须在 .agent 下且存在（含 L3 裸链规则）
            if is_under(joined, agent):
                if not os.path.exists(joined):
                    errs.append(f"{rel_md}: 目标不存在 → ({target})")
            else:
                # 跨出 .agent：须落在 REPO_ROOT 或 REPO_DOC_ROOT 目录树内（后者通常为前者子树），
                # Agent 语义可达即可，不要求 IDE/浏览器可点击。
                if not (is_under(joined, repo) or is_under(joined, doc_root)):
                    errs.append(
                        f"{rel_md}: 跨出 .agent 的链接须指向 REPO_ROOT 或 REPO_DOC_ROOT 下路径 → ({target})"
                    )
                    continue
                if is_under(joined, git_dir):
                    errs.append(f"{rel_md}: 禁止链接到 .git → ({target})")
                    continue
                if not os.path.exists(joined):
                    errs.append(f"{rel_md}: 目标不存在 → ({target})")
            # 深层 reference 禁止裸 application|docs 根链（规范 L3）
            target_slash = target.replace("\\", "/")
            if "/reference/" in rel_md.replace("\\", "/") and re.match(
                r"^(application|docs)/", target_slash
            ):
                errs.append(
                    f"{rel_md}: 深层 reference 禁止使用裸 ({target})，须 ../../../ 等到仓库根"
                )

if warns:
    for w in warns:
        print("[WARN]", w, file=sys.stderr)
if errs:
    print("校验失败（", len(errs), "）:", file=sys.stderr)
    for e in errs:
        print(" ", e, file=sys.stderr)
    sys.exit(1)
print(
    "[OK] .agent Markdown 链接检查通过（.agent 内互链 + 跨边界须 REPO_ROOT/REPO_DOC_ROOT；REPO_DOC_ROOT=",
    doc_root,
    "）",
)
PY
