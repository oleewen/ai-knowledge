#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
VALIDATE_SCRIPT="$ROOT/agent/skills/docs-okf/scripts/okf-validate.sh"
BUNDLE_ROOT="$ROOT/application"
VIZ_HTML="$BUNDLE_ROOT/viz.html"
LEGACY_ENTITIES="$BUNDLE_ROOT/knowledge/business/business-entities.md"

DOCS_CONFIG="$ROOT/.docsconfig"
DOCS_CONFIG_CREATED=0

cleanup_docsconfig() {
  if [[ "$DOCS_CONFIG_CREATED" -eq 1 && -f "$DOCS_CONFIG" ]]; then
    rm -f "$DOCS_CONFIG"
  fi
}

if [[ ! -f "$DOCS_CONFIG" ]]; then
  DOCS_CONFIG_CREATED=1
  trap cleanup_docsconfig EXIT
  cat >"$DOCS_CONFIG" <<EOF
DOC_ROOT=$ROOT/application
REPO_ROOT=$ROOT
DOC_DIR=application
KNOWLEDGE_TYPE=application
EOF
fi

if [[ ! -x "$VALIDATE_SCRIPT" ]] && [[ ! -f "$VALIDATE_SCRIPT" ]]; then
  echo "未找到 okf-validate.sh: $VALIDATE_SCRIPT" >&2
  exit 1
fi

set +e
out="$(bash "$VALIDATE_SCRIPT" --bundle application 2>&1)"
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
