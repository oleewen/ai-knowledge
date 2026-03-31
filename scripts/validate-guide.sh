#!/usr/bin/env bash
# 轻量校验：AGENTS / README 中指向根目录 INDEX、CONVENTIONS 的路径是否存在（可选门禁）
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
ok=0
for f in INDEX_GUIDE.md AGENTS.md README.md .ai/rules/CONVENTIONS.md; do
  if [[ ! -e "$f" ]]; then
    echo "missing: $f" >&2
    ok=1
  fi
done
exit "$ok"
