#!/usr/bin/env bash
# validate-guide.sh 的最小回归测试。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
VALIDATOR="$SCRIPT_DIR/validate-guide.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/docs-agent-guide.XXXXXX")"
VALID_OUTPUT="$TMP_ROOT/valid.out"
WARNING_OUTPUT="$TMP_ROOT/warning.out"
trap 'rm -rf "$TMP_ROOT"' EXIT

cat >"$TMP_ROOT/INDEX-GUIDE.md" <<'EOF'
# Index
EOF

cat >"$TMP_ROOT/README.md" <<'EOF'
# Demo

[Agent](AGENTS.md)
[Index](INDEX-GUIDE.md)
EOF

cat >"$TMP_ROOT/AGENTS.md" <<'EOF'
# Demo AI Agent Guide

[INDEX-GUIDE.md](INDEX-GUIDE.md)
EOF

bash "$VALIDATOR" --root "$TMP_ROOT" >"$VALID_OUTPUT"
grep -Fq '验证完成: 0 错误, 0 警告' "$VALID_OUTPUT"

# A current unit must not require or inspect the other, unselected file.
for selection in readme agents; do
  case "$selection" in
    readme) selected=README.md; other=AGENTS.md;;
    agents) selected=AGENTS.md; other=README.md;;
  esac
  single="$TMP_ROOT/$selection"
  mkdir -p "$single"
  cp "$TMP_ROOT/INDEX-GUIDE.md" "$single/INDEX-GUIDE.md"
  printf '# Current\n\n[Index](INDEX-GUIDE.md)\n' > "$single/$selected"
  bash "$VALIDATOR" --root "$single" --output "$selection" --strict
  printf '# Other\n\n[broken](missing.md)\n' > "$single/$other"
  bash "$VALIDATOR" --root "$single" --output "$selection" --strict
  mv "$single/$selected" "$single/saved"
  if bash "$VALIDATOR" --root "$single" --output "$selection" >/dev/null 2>&1; then
    echo "缺失所选 $selected 未失败" >&2
    exit 1
  fi
done
if bash "$VALIDATOR" --root "$TMP_ROOT" --output invalid >/dev/null 2>&1; then
  echo '非法output未失败' >&2
  exit 1
fi

printf '\n[broken](missing.md)\n' >>"$TMP_ROOT/README.md"
bash "$VALIDATOR" --root "$TMP_ROOT" >"$WARNING_OUTPUT"
grep -Fq 'README.md 引用路径不存在: missing.md' "$WARNING_OUTPUT"
if bash "$VALIDATOR" --root "$TMP_ROOT" --strict >/dev/null 2>&1; then
  echo 'strict 模式未将警告升级为失败' >&2
  exit 1
fi

rm "$TMP_ROOT/INDEX-GUIDE.md"
if bash "$VALIDATOR" --root "$TMP_ROOT" >/dev/null 2>&1; then
  echo '缺失 INDEX-GUIDE.md 未失败' >&2
  exit 1
fi

echo 'validate-guide.sh 回归通过'
