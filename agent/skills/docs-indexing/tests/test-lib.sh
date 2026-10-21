#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEXING_SCRIPT="$SKILL_DIR/scripts/indexing.sh"
INDEXING_LOG_PY="$SKILL_DIR/scripts/indexing_log.py"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }

new_tmp_dir() { mktemp -d "${TMPDIR:-/tmp}/docs-indexing-tests.XXXXXX"; }

pin_workspace_for_repo() {
  local repo="${1:?}" agent_root="${2:?}" agent_dir="${3:-.agents}"
  mkdir -p "${agent_root}/${agent_dir}"
  printf 'WORK_SPACE=%s\n' "$(dirname "$repo")" >"${agent_root}/${agent_dir}/configs"
}
