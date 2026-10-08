#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
INDEXING_SCRIPT="$ROOT_DIR/agent/skills/docs-indexing/scripts/indexing.sh"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }

new_tmp_dir() { mktemp -d "${TMPDIR:-/tmp}/docs-indexing-tests.XXXXXX"; }

pin_workspace_for_repo() {
  local repo="${1:?}" agent_root="${2:?}" agent_dir="${3:-.agents}"
  mkdir -p "${agent_root}/${agent_dir}"
  printf 'WORK_SPACE=%s\n' "$(dirname "$repo")" >"${agent_root}/${agent_dir}/configs"
}
