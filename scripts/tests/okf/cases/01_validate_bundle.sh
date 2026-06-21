#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
VALIDATE_SCRIPT="$ROOT/scripts/validate-okf.sh"
BUNDLE_ROOT="$ROOT/application"
VIZ_HTML="$BUNDLE_ROOT/viz.html"
LEGACY_ENTITIES="$BUNDLE_ROOT/knowledge/business/business-entities.md"

if [[ ! -x "$VALIDATE_SCRIPT" ]] && [[ ! -f "$VALIDATE_SCRIPT" ]]; then
  echo "未找到 validate-okf.sh: $VALIDATE_SCRIPT" >&2
  exit 1
fi

set +e
out="$(bash "$VALIDATE_SCRIPT" 2>&1)"
code=$?
set -e

if [[ "$code" -ne 0 ]]; then
  echo "$out"
  echo "validate-okf 应通过 (exit=$code)" >&2
  exit 1
fi

echo "$out" | grep -q "验证通过" || {
  echo "$out"
  echo "输出应包含「验证通过」" >&2
  exit 1
}

[[ -f "$VIZ_HTML" ]] || {
  echo "缺少 viz.html: $VIZ_HTML" >&2
  exit 1
}

[[ ! -f "$LEGACY_ENTITIES" ]] || {
  echo "legacy 文件应已移除: $LEGACY_ENTITIES" >&2
  exit 1
}

echo "[OK] validate_bundle application bundle"
