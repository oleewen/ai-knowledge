#!/usr/bin/env bash
# 验收：concept 数量、okf_version、无 legacy *-entities.md、KNOWLEDGE-INDEX 有效
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
BUNDLE_ROOT="$ROOT/application"
MIN_CONCEPTS=4

count="$(python3 - "$BUNDLE_ROOT" <<'PY'
import sys
from pathlib import Path

bundle_root = Path(sys.argv[1])
repo_root = bundle_root.parent
sys.path.insert(0, str(repo_root / "agent" / "skills" / "docs-okf" / "scripts"))
import okf_lib  # noqa: E402

n = 0
for path in okf_lib.scan_concepts(bundle_root):
    if path.name == "KNOWLEDGE-INDEX.md":
        continue
    meta, _ = okf_lib.parse_frontmatter(path.read_text(encoding="utf-8"))
    if meta.get("full_id"):
        n += 1
print(n)
PY
)"

if [[ "$count" -lt "$MIN_CONCEPTS" ]]; then
  echo "concept 文件（含 full_id）数量应 >= ${MIN_CONCEPTS}，实际: $count" >&2
  exit 1
fi

grep -q 'okf_version' "$BUNDLE_ROOT/index.md" || {
  echo "application/index.md 应含 okf_version" >&2
  exit 1
}

entities="$(find "$BUNDLE_ROOT/knowledge" -name '*-entities.md' 2>/dev/null || true)"
if [[ -n "$entities" ]]; then
  echo "application/knowledge 下不应存在 *-entities.md:" >&2
  echo "$entities" >&2
  exit 1
fi

nav="$BUNDLE_ROOT/knowledge/index.md"
[[ -f "$nav" ]] || {
  echo "缺少目录索引: $nav" >&2
  exit 1
}

ki="$BUNDLE_ROOT/knowledge/KNOWLEDGE-INDEX.md"
[[ -f "$ki" ]] || {
  echo "缺少 KNOWLEDGE-INDEX.md: $ki" >&2
  exit 1
}

grep -qE 'API-EXAMPLE|TBL-EXAMPLE|MW-EXAMPLE' "$ki" || {
  echo "KNOWLEDGE-INDEX.md 应含本层 EXAMPLE 实体" >&2
  exit 1
}

grep -q 'KNOWLEDGE-INDEX' "$nav" || {
  echo "knowledge/index.md 应链到 KNOWLEDGE-INDEX.md" >&2
  exit 1
}

echo "[OK] acceptance checklist (concepts=$count, okf_version, no *-entities.md, KNOWLEDGE-INDEX)"
