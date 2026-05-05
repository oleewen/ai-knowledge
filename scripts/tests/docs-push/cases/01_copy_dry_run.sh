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
printf '# x\n' >"${SRC}/spec-250504-1-myapp.md"

cat >"${TMP}/knowledge-links.yaml" <<EOF
links:
  - path: "${TARGET}"
    doc_dir: application
    app_name: myapp
EOF

out="$("${BASH:-bash}" "$PUSH" copy \
  --specs-dir "$SRC" \
  --links "${TMP}/knowledge-links.yaml" \
  --mode path \
  --dry-run 2>&1)"

printf '%s\n' "$out" | grep -Fq 'application/specs/spec-250504-1-myapp.md' \
  || {
    printf '期望 dry-run 输出包含 application/specs/spec-250504-1-myapp.md，实际:\n%s\n' "$out" >&2
    exit 1
  }

printf 'PASS: copy dry-run 含目标路径\n'
