#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PUSH="${ROOT_DIR}/agent/skills/docs-push/scripts/push-specs.sh"

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

TARGET="${TMP}/target-app"
SRC="${TMP}/specs-src"
mkdir -p "$TARGET" "$SRC"
printf '# nope\n' >"${SRC}/spec-250504-1-nopeapp.md"

cat >"${TMP}/knowledge-links.yaml" <<EOF
links:
  - path: "${TARGET}"
    doc_dir: application
    app_name: myapp
EOF

set +e
"${BASH:-bash}" "$PUSH" copy \
  --specs-dir "$SRC" \
  --links "${TMP}/knowledge-links.yaml" \
  --mode path \
  --strict 2>/dev/null
code=$?
set -e

if [[ "$code" -eq 0 ]]; then
  printf '期望 --strict 且无 app 登记时非零退出\n' >&2
  exit 1
fi

printf 'PASS: strict 缺失 app 非零退出\n'
