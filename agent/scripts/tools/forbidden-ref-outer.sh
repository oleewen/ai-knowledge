#!/usr/bin/env bash
# forbidden-ref-outer.sh — 库外禁止的文件引用（当前：superpowers 具名文件）
# 在仓库根执行：bash agent/scripts/tools/forbidden-ref-outer.sh
# 规则见 agent/rules/CONVENTIONS.md §superpowers 引用隔离

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/docsconfig.sh"
docsconfig_bootstrap_validate
repo_abs="$(docsconfig_repo_abs)"

readonly EXIT_VIOLATION=1
readonly EXIT_TOOL_ERROR=2

# 具名文件路径公共段与文档根无关；仅接受路径分隔符或明确的文本起始边界。
# 支持行首、/、空白、反引号、单双引号、左圆/尖括号、等号、英文/中文冒号；非通用 Markdown 解析。
readonly SUPERPOWERS_NAMED_PREFIX='superpowers/(specs|plans)/'
readonly PATTERN_LITERAL="(^|[/[:space:]\`\"'(<=:：])${SUPERPOWERS_NAMED_PREFIX}[0-9]{4}-[0-9]{2}-[0-9]{2}-"
readonly PATTERN_MD_LINK="\]\(([^)]*/)?${SUPERPOWERS_NAMED_PREFIX}[0-9]{4}-"

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
    exit "$EXIT_TOOL_ERROR"
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
  local out status=0
  # 一次扫描的两种模式不会重复报告重叠匹配；同一行的不同位置分别计数。
  out="$(rg --with-filename --line-number --column --only-matching --color never \
    -e "$PATTERN_LITERAL" -e "$PATTERN_MD_LINK" "${GLOBS[@]}" .)" || status=$?
  case "$status" in
    0|1) ;;
    *)
      printf '[ERROR] 引用扫描未完成（rg exit %s）\n' "$status" >&2
      return "$EXIT_TOOL_ERROR"
      ;;
  esac
  if [[ -n "$out" ]]; then
    echo "== 具名 superpowers 引用（文件:行:列）==" >&2
    echo "$out" >&2
    violations="$(count_nonempty_lines "$out")"
  fi
}

main() {
  require_ripgrep
  cd "$repo_abs"

  run_scan || exit "$EXIT_TOOL_ERROR"

  if [[ "$violations" -gt 0 ]]; then
    echo "[FAIL] 发现 ${violations} 处 superpowers 具名文件引用（库外）" >&2
    echo "规则见 agent/rules/CONVENTIONS.md §superpowers 引用隔离" >&2
    exit "$EXIT_VIOLATION"
  fi

  echo "[OK] 未发现库外 superpowers 具名文件引用"
  exit 0
}

main "$@"
