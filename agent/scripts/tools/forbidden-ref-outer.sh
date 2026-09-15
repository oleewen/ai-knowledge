#!/usr/bin/env bash
# forbidden-ref-outer.sh — 库外禁止的文件引用（当前：superpowers 具名文件）
# 在仓库根执行：bash agent/scripts/tools/forbidden-ref-outer.sh
# 规则见 agent/rules/CONVENTIONS.md §superpowers 引用隔离

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/docsconfig.sh"
docsconfig_bootstrap_validate "$SCRIPT_DIR"

REPO_ROOT="${REPO_ROOT:?docsconfig_bootstrap_validate 未注入 REPO_ROOT}"

readonly EXIT_VIOLATION=1
readonly EXIT_MISSING_TOOL=2

# 具名文件路径公共段（specs|plans 下带日期前缀）
readonly SUPERPOWERS_NAMED_PREFIX='(application|system|company|docs)/superpowers/(specs|plans)/'
readonly PATTERN_LITERAL="${SUPERPOWERS_NAMED_PREFIX}[0-9]{4}-[0-9]{2}-[0-9]{2}-"
readonly PATTERN_MD_LINK="\]\([^)]*${SUPERPOWERS_NAMED_PREFIX}[0-9]{4}-"

GLOBS=(
  --glob '!**/superpowers/**'
  --glob '!.git/**'
  --glob '!**/__pycache__/**'
  --glob '!**/node_modules/**'
  --glob '!**/target/**'
)

violations=0

require_ripgrep() {
  if ! command -v rg >/dev/null 2>&1; then
    echo "[ERROR] 需要 ripgrep (rg)" >&2
    exit "$EXIT_MISSING_TOOL"
  fi
}

count_nonempty_lines() {
  local text="$1"
  local n=0
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "$line" ]] && n=$((n + 1))
  done <<<"$text"
  printf '%s' "$n"
}

run_scan() {
  local label="$1"
  local pattern="$2"
  local out
  out="$(rg -n "$pattern" "${GLOBS[@]}" . 2>/dev/null || true)"
  if [[ -n "$out" ]]; then
    echo "== $label ==" >&2
    echo "$out" >&2
    violations=$((violations + $(count_nonempty_lines "$out")))
  fi
}

main() {
  require_ripgrep
  cd "$REPO_ROOT"

  run_scan "具名 superpowers 路径字面量" "$PATTERN_LITERAL"
  run_scan "Markdown 链接指向具名 superpowers 文件" "$PATTERN_MD_LINK"

  if [[ "$violations" -gt 0 ]]; then
    echo "[FAIL] 发现 ${violations} 处 superpowers 具名文件引用（库外）" >&2
    echo "规则见 agent/rules/CONVENTIONS.md §superpowers 引用隔离" >&2
    exit "$EXIT_VIOLATION"
  fi

  echo "[OK] 未发现库外 superpowers 具名文件引用"
  exit 0
}

main "$@"
