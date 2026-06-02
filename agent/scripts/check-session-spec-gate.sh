#!/usr/bin/env bash
# 在 {DOC_DIR}/superpowers/*.md 中查找 CONFIRMED 标记与目标 basename。
# 用法: check_session_spec_gate "<!-- sdx-prd-gate: CONFIRMED -->" "PRD-foo.md"
set -euo pipefail

MARKER="${1:?marker required}"
TARGET="${2:?target basename required}"
REPO_ROOT="${REPO_ROOT:?REPO_ROOT required}"

found=0
while IFS= read -r -d '' spec; do
  rel="${spec#"${REPO_ROOT}/"}"
  case "${rel}" in
    */requirements/*) continue ;;
  esac
  IFS=/ read -r seg1 seg2 _rest <<< "${rel}/x/x"
  if [[ "${seg2}" != "superpowers" ]]; then
    continue
  fi
  if grep -qF "${MARKER}" "${spec}" 2>/dev/null && grep -qF "${TARGET}" "${spec}" 2>/dev/null; then
    found=1
    break
  fi
done < <(find "${REPO_ROOT}" -type f -name '*.md' -path '*/superpowers/*' ! -path '*/requirements/*' -print0 2>/dev/null)

if [[ "${found}" -eq 1 ]]; then
  exit 0
fi
exit 1
