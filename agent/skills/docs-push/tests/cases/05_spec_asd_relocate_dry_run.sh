#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
PUSH="${ROOT_DIR}/agent/skills/docs-push/scripts/push-specs.sh"

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

TARGET="${TMP}/target-app"
SRC="${TMP}/central-docs/specs"
mkdir -p "$TARGET" "$SRC"
printf '# spec asd relocate\n' >"${SRC}/spec-asd-ORDER-1-myapp.md"

mkdir -p "$TMP/agent"
printf 'AGENT_ROOT=%s\nAGENT_DIR=agent\n' "$TMP" > "$TMP/.docsconfig"
printf 'WORK_SPACE=%s\n' "$TMP" > "$TMP/agent/configs"

cat >"${TMP}/knowledge-links.yaml" <<EOF
links:
  - type: child
    path: "\${WORK_SPACE}/$(basename "$TARGET")"
    dir: docs
    name: myapp
EOF

out="$("${BASH:-bash}" "$PUSH" copy \
  --specs-dir "${TMP}/central-docs" \
  --links "${TMP}/knowledge-links.yaml" \
  --mode path \
  --dry-run 2>&1)"

printf '%s\n' "$out" | grep -Fq 'docs/requirements/REQUIREMENT-ORDER/MVP-Phase-1/specs/spec-asd-ORDER-1-myapp.md' \
  || {
    printf '期望 dry-run 含 REQUIREMENT/MVP/specs 归位路径，实际:\n%s\n' "$out" >&2
    exit 1
  }

printf 'PASS: spec-asd 文件名归位 dry-run\n'
