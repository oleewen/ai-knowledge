#!/usr/bin/env bash
# DESIGN §11 验收：concept 数量、okf_version、无 legacy *-entities.md、KNOWLEDGE_INDEX 有效
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
BUNDLE_ROOT="$ROOT/application"
MIN_CONCEPTS=17

count="$(python3 - "$BUNDLE_ROOT" <<'PY'
import sys
from pathlib import Path

bundle_root = Path(sys.argv[1])
repo_root = bundle_root.parent
sys.path.insert(0, str(repo_root / "scripts" / "okf"))
import okf_lib  # noqa: E402

n = 0
for path in okf_lib.scan_concepts(bundle_root):
    meta, _ = okf_lib.parse_frontmatter(path.read_text(encoding="utf-8"))
    if meta.get("full_id"):
        n += 1
print(n)
PY
)"

if [[ "$count" -lt "$MIN_CONCEPTS" ]]; then
  echo "concept 文件（含 full_id）数量应 >= $MIN_CONCEPTS，实际: $count" >&2
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

ki="$BUNDLE_ROOT/knowledge/KNOWLEDGE_INDEX.md"
[[ -f "$ki" ]] || {
  echo "缺少 KNOWLEDGE_INDEX.md: $ki" >&2
  exit 1
}

grep -qE 'BD-EXAMPLE|business' "$ki" || {
  echo "KNOWLEDGE_INDEX.md 应提及 BD-EXAMPLE 或 business" >&2
  exit 1
}

echo "[OK] acceptance checklist (concepts=$count, okf_version, no *-entities.md, KNOWLEDGE_INDEX)"
