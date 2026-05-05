#!/usr/bin/env bash
# 模拟 ~/.cursor/skills/docs-push/scripts/ 扁平安装：脚本不在仓库树内，须从 cwd 解析根。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
REAL_PUSH="${ROOT_DIR}/agent/skills/docs-push/scripts/push-specs.sh"

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

FAKE_SCRIPTS="${TMP}/.cursor/skills/docs-push/scripts"
mkdir -p "$FAKE_SCRIPTS"
cp "$REAL_PUSH" "${FAKE_SCRIPTS}/push-specs.sh"

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

# 在中央库根下调用「伪 Cursor 路径」脚本，应通过 cwd 上溯解析 _AIK_ROOT
out="$(cd "$ROOT_DIR" && "${BASH:-bash}" "${FAKE_SCRIPTS}/push-specs.sh" copy \
  --specs-dir "$SRC" \
  --links "${TMP}/knowledge-links.yaml" \
  --mode path \
  --dry-run 2>&1)"

printf '%s\n' "$out" | grep -Fq 'application/specs/spec-250504-1-myapp.md' \
  || {
    printf '期望 dry-run 输出包含 application/specs/spec-250504-1-myapp.md，实际:\n%s\n' "$out" >&2
    exit 1
  }

printf 'PASS: 扁平安装路径下自 cwd 解析中央库根\n'
