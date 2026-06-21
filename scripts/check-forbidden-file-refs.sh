#!/usr/bin/env bash
# check-forbidden-file-refs.sh — 库外禁止的文件引用（当前：superpowers 具名文件）
# 在仓库根执行：bash scripts/check-forbidden-file-refs.sh
# 规则见 agent/rules/CONVENTIONS.md §superpowers 引用隔离

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v rg >/dev/null 2>&1; then
  echo "[ERROR] 需要 ripgrep (rg)" >&2
  exit 2
fi

GLOBS=(
  --glob '!**/superpowers/**'
  --glob '!.git/**'
  --glob '!**/__pycache__/**'
  --glob '!**/node_modules/**'
  --glob '!**/target/**'
)

PATTERN_LITERAL='(application|system|company|docs)/superpowers/(specs|plans)/[0-9]{4}-[0-9]{2}-[0-9]{2}-'
PATTERN_MD_LINK='\]\([^)]*(application|system|company|docs)/superpowers/(specs|plans)/[0-9]{4}-'

violations=0

run_scan() {
  local label="$1"
  local pattern="$2"
  local out
  if out="$(rg -n "$pattern" "${GLOBS[@]}" . 2>/dev/null || true)"; then
    :
  fi
  if [[ -n "$out" ]]; then
    echo "== $label ==" >&2
    echo "$out" >&2
    local count
    count="$(echo "$out" | wc -l | tr -d ' ')"
    violations=$((violations + count))
  fi
}

run_scan "具名 superpowers 路径字面量" "$PATTERN_LITERAL"
run_scan "Markdown 链接指向具名 superpowers 文件" "$PATTERN_MD_LINK"

if [[ "$violations" -gt 0 ]]; then
  echo "[FAIL] 发现 ${violations} 处 superpowers 具名文件引用（库外）" >&2
  echo "规则见 agent/rules/CONVENTIONS.md §superpowers 引用隔离" >&2
  exit 1
fi

echo "[OK] 未发现库外 superpowers 具名文件引用"
exit 0
