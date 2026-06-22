#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# 物理文件不得存在旧名
for f in application/docs_meta.md system/docs_meta.md company/docs_meta.md; do
  if [[ -f "$f" ]]; then
    echo "FAIL: 旧文件仍存在: $f" >&2
    exit 1
  fi
done

# 新文件必须存在
for f in application/docs-meta.md system/docs-meta.md company/docs-meta.md; do
  if [[ ! -f "$f" ]]; then
    echo "FAIL: 缺少新文件: $f" >&2
    exit 1
  fi
done

# 引用清零（排除 CHANGE-LOG 历史、superpowers 设计文档、门禁与测试自身）
_EXCLUDE=(
  --glob '!application/changelogs/CHANGE-LOG.md'
  --glob '!docs/superpowers/**'
  --glob '!scripts/check-docs-meta-naming.sh'
  --glob '!scripts/tests/docs-install/cases/11_central_installs_docs_meta.sh'
  --glob '!scripts/tests/okf/test_inject_frontmatter.py'
)

if rg -l 'docs_meta' "${_EXCLUDE[@]}" . >/dev/null 2>&1; then
  echo "FAIL: 仍存在 docs_meta 引用:" >&2
  rg 'docs_meta' "${_EXCLUDE[@]}" . >&2 || true
  exit 1
fi

echo "check-docs-meta-naming: OK"
