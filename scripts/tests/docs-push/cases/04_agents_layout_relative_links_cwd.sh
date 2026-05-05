#!/usr/bin/env bash
# agent-install 布局：core 在 ~/.agents/scripts；技能在 .agents/skills/...；相对 --links 依赖 cwd 上溯到「含该文件的根」。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
REAL_PUSH="${ROOT_DIR}/agent/skills/docs-push/scripts/push-specs.sh"
REAL_CORE="${ROOT_DIR}/agent/scripts/docs-core.sh"

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

STORE="${TMP}/.agents"
CENTRAL="${TMP}/central"
mkdir -p "${STORE}/scripts" "${STORE}/skills/docs-push/scripts" "${CENTRAL}/system"
cp "$REAL_CORE" "${STORE}/scripts/docs-core.sh"
cp "$REAL_PUSH" "${STORE}/skills/docs-push/scripts/push-specs.sh"

SRC="${TMP}/specs-src"
mkdir -p "$SRC"
printf '# x\n' >"${SRC}/spec-250504-1-myapp.md"

TARGET="${TMP}/target-app"
mkdir -p "$TARGET"

cat >"${CENTRAL}/system/knowledge-links.yaml" <<EOF
links:
  - path: "${TARGET}"
    doc_dir: application
    app_name: myapp
EOF

out="$(cd "${CENTRAL}/system" && "${BASH:-bash}" "${STORE}/skills/docs-push/scripts/push-specs.sh" copy \
  --specs-dir "$SRC" \
  --links system/knowledge-links.yaml \
  --mode path \
  --dry-run 2>&1)"

printf '%s\n' "$out" | grep -Fq 'application/specs/spec-250504-1-myapp.md' \
  || {
    printf '期望 dry-run 输出包含 application/specs/spec-250504-1-myapp.md，实际:\n%s\n' "$out" >&2
    exit 1
  }

printf 'PASS: .agents 布局 + 相对 links（cwd 上溯含 yaml）\n'
