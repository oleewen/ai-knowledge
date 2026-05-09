#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PUSH="${ROOT_DIR}/agent/skills/docs-push/scripts/push-specs.sh"

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

TARGET="${TMP}/target-app"
SRC="${TMP}/central-docs/specs"
mkdir -p "$TARGET" "$SRC"
printf '# spec asd relocate\n' >"${SRC}/spec-asd-ORDER-1-myapp.md"

cat >"${TMP}/knowledge-links.yaml" <<EOF
links:
  - path: "${TARGET}"
    doc_dir: application
    app_name: myapp
EOF

out="$("${BASH:-bash}" "$PUSH" copy \
  --specs-dir "${TMP}/central-docs" \
  --links "${TMP}/knowledge-links.yaml" \
  --mode path \
  --dry-run 2>&1)"

printf '%s\n' "$out" | grep -Fq 'application/requirements/REQUIREMENT-ORDER/MVP-Phase-1/specs/spec-asd-ORDER-1-myapp.md' \
  || {
    printf '期望 dry-run 含 REQUIREMENT/MVP/specs 归位路径，实际:\n%s\n' "$out" >&2
    exit 1
  }

printf 'PASS: spec-asd 文件名归位 dry-run\n'
