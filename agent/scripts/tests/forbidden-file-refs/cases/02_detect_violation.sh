#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
SCRIPT="$ROOT/agent/scripts/check-forbidden-file-refs.sh"

# 优先检查目标脚本是否存在；不存在即直接失败（RED 状态正确表现）
if [[ ! -f "$SCRIPT" ]]; then
  echo "02_detect_violation: FAIL (script missing: $SCRIPT)" >&2
  exit 1
fi
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# 路径分段拼接：避免源文件出现 YYYY-MM-DD- 连续字面量（superpowers 引用 lint）
_violation_path() {
  local y m d stem
  y="2026"; m="01"; d="01"
  stem="${1:?}"
  echo "docs/superpowers/specs/${y}-${m}-${d}-${stem}.md"
}

echo "$(_violation_path fake-violation)" >"$TMP/violation.txt"

if rg -n '(application|system|company|docs)/superpowers/(specs|plans)/[0-9]{4}-[0-9]{2}-[0-9]{2}-' \
  "$TMP/violation.txt" >/dev/null 2>&1; then
  echo "02_detect_violation: pattern sanity OK"
else
  echo "02_detect_violation: pattern sanity FAIL" >&2
  exit 1
fi

# 临时污染仓库外文件，验证脚本会 fail
PROBE="$ROOT/superpowers-ref-probe.tmp"
echo "$(_violation_path probe-violation)" >"$PROBE"
trap 'rm -f "$ROOT/superpowers-ref-probe.tmp"; rm -rf "$TMP"' EXIT

if bash "$SCRIPT"; then
  echo "02_detect_violation: 期望 exit 1，实际通过" >&2
  exit 1
fi

echo "02_detect_violation: OK (detected violation)"
