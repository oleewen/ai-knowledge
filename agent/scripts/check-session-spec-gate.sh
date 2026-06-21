#!/usr/bin/env bash
# check_session_spec_gate — 在 {DOC_DIR}/superpowers/specs/*.md 中查找 CONFIRMED 标记与目标 basename。
# 用法（source 后）: check_session_spec_gate "<!-- sdx-prd-gate: CONFIRMED -->" "PRD-foo.md"
# 依赖 REPO_ROOT；扫描逻辑与 agent/hooks/session_spec_paths.py 一致。

check_session_spec_gate() {
  local marker="${1:?marker required}" target="${2:?target basename required}"
  local repo="${REPO_ROOT:?REPO_ROOT required}"
  local hooks="${repo}/agent/hooks"
  [[ -d "$hooks" ]] || return 1

  REPO_ROOT="$repo" MARKER="$marker" TARGET="$target" python3 <<'PY'
import os
import re
import sys
from pathlib import Path

repo = Path(os.environ["REPO_ROOT"])
sys.path.insert(0, str(repo / "agent" / "hooks"))
from session_spec_paths import iter_session_spec_files  # noqa: E402

marker = os.environ["MARKER"]
target = os.environ["TARGET"]
pat = re.compile(rf"(?<![A-Za-z0-9._-]){re.escape(target)}(?![A-Za-z0-9._-])")
for p in iter_session_spec_files(repo):
    try:
        text = p.read_text(encoding="utf-8", errors="replace")
    except OSError:
        continue
    if marker in text and pat.search(text):
        sys.exit(0)
sys.exit(1)
PY
}
