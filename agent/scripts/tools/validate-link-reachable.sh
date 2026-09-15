#!/usr/bin/env bash
# validate-link-reachable.sh — 校验 agent 下 Markdown 链接：agent 内互链须存在；跨出 agent 须落在
# REPO_ROOT 或 DOC_ROOT 下（且非 .git），落实 link-reachability §1.1 强校验。
# 在仓库根执行：bash agent/scripts/tools/validate-link-reachable.sh
# 文档根路径来自目标仓库根 .docsconfig（见 lib/docsconfig.sh；§2.2.2 不向子进程 export，仅前缀传参）。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/docsconfig.sh"
docsconfig_bootstrap_validate

REPO_ROOT="${REPO_ROOT:?docsconfig_bootstrap_validate 未注入 REPO_ROOT}"
DOC_ROOT="${DOC_ROOT:?docsconfig_bootstrap_validate 未注入 DOC_ROOT}"
AGENT_DIR="$REPO_ROOT/agent"

readonly EXIT_FAIL=1

require_agent_dir() {
  [[ -d "$AGENT_DIR" ]] || {
    echo "[ERROR] 未找到 ${AGENT_DIR}（REPO_ROOT=$REPO_ROOT）" >&2
    exit "$EXIT_FAIL"
  }
}

# §2.2.2：不 export；仅对本次 python3 进程传入环境变量
run_link_check() {
  DOC_ROOT="$DOC_ROOT" REPO_ROOT="$REPO_ROOT" AGENT_DIR="$AGENT_DIR" python3 <<'PY'
import os
import re
import sys

repo = os.environ["REPO_ROOT"]
agent = os.environ["AGENT_DIR"]
doc_root = os.environ["DOC_ROOT"]
git_dir = os.path.join(repo, ".git")

link_re = re.compile(r"\]\(([^)]+)\)")
bare_app_or_docs_re = re.compile(r"^(application|docs)/")

errs: list[str] = []
warns: list[str] = []
exists_cache: dict[str, bool] = {}


def norm(p: str) -> str:
    return os.path.normpath(p)


def path_exists(path: str) -> bool:
    key = norm(path)
    if key not in exists_cache:
        exists_cache[key] = os.path.exists(path)
    return exists_cache[key]


def is_under(path: str, root: str) -> bool:
    a, b = norm(path), norm(root)
    return a == b or a.startswith(b + os.sep)


def is_external(p: str) -> bool:
    p = p.strip()
    return not p or p.startswith(("#", "http://", "https://", "mailto:"))


def missing_target_err(rel_md: str, target: str) -> str:
    return f"{rel_md}: 目标不存在 → ({target})"


def check_cross_agent_link(rel_md: str, target: str, joined: str) -> None:
    if not (is_under(joined, repo) or is_under(joined, doc_root)):
        errs.append(
            f"{rel_md}: 跨出 agent 的链接须指向 REPO_ROOT 或 DOC_ROOT 下路径 → ({target})"
        )
        return
    if is_under(joined, git_dir):
        errs.append(f"{rel_md}: 禁止链接到 .git → ({target})")
        return
    if not path_exists(joined):
        errs.append(missing_target_err(rel_md, target))


def check_l3_bare_root_link(rel_md: str, target: str) -> None:
    rel_slash = rel_md.replace("\\", "/")
    if "/reference/" not in rel_slash:
        return
    target_slash = target.replace("\\", "/")
    if bare_app_or_docs_re.match(target_slash):
        errs.append(
            f"{rel_md}: 深层 reference 禁止使用裸 ({target})，须 ../../../ 等到仓库根"
        )


def check_link(rel_md: str, md_path: str, raw_target: str) -> None:
    target = raw_target.strip().split("#", 1)[0].strip()
    if is_external(target):
        return

    joined = norm(os.path.join(os.path.dirname(md_path), target))
    if is_under(joined, agent):
        if not path_exists(joined):
            errs.append(missing_target_err(rel_md, target))
    else:
        check_cross_agent_link(rel_md, target, joined)

    check_l3_bare_root_link(rel_md, target)


def scan_agent_markdown() -> None:
    for dirpath, _, files in os.walk(agent):
        for name in files:
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            rel_md = os.path.relpath(path, repo)
            try:
                with open(path, encoding="utf-8") as f:
                    text = f.read()
            except (OSError, UnicodeDecodeError) as e:
                warns.append(f"{rel_md}: 无法读取 ({e})")
                continue
            for m in link_re.finditer(text):
                check_link(rel_md, path, m.group(1))


def report() -> int:
    for w in warns:
        print("[WARN]", w, file=sys.stderr)
    if not errs:
        print(
            "[OK] agent Markdown 链接检查通过"
            f"（agent 内互链 + 跨边界须 REPO_ROOT/DOC_ROOT；DOC_ROOT={doc_root}）"
        )
        return 0
    print(f"校验失败（{len(errs)}）:", file=sys.stderr)
    for e in errs:
        print(" ", e, file=sys.stderr)
    return 1


scan_agent_markdown()
sys.exit(report())
PY
}

main() {
  require_agent_dir
  run_link_check
}

main "$@"
