#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PUSH="${ROOT_DIR}/agent/skills/docs-push/scripts/push-specs.sh"

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

TARGET="${TMP}/target-app"
SRC="${TMP}/src-root"
rel='requirements/REQUIREMENT-order/MVP-Phase-2/specs/nested/spec-asd-order-2-myapp.md'
mkdir -p "$TARGET/$(dirname "$rel")"

mkdir -p "${SRC}/$(dirname "$rel")"
printf '# mirror\n' >"${SRC}/${rel}"

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

printf '%s\n' "$out" | grep -Fq "application/${rel}" \
  || {
    printf '期望 dry-run 输出含 application/%s ，实际:\n%s\n' "$rel" "$out" >&2
    exit 1
  }

printf 'PASS: requirements/ 前缀镜像 dry-run\n'
