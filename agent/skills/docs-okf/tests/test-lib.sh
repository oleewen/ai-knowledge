#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
RESOLVE_SCRIPT="$ROOT_DIR/agent/skills/docs-okf/scripts/resolve-okf-paths.sh"
VALIDATE_SCRIPT="$ROOT_DIR/agent/skills/docs-okf/scripts/okf-validate.sh"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }

new_tmp_dir() { mktemp -d "${TMPDIR:-/tmp}/docs-okf-tests.XXXXXX"; }

write_docsconfig() {
  local project_dir="$1"
  local doc_dir="$4"
  local knowledge_type="${5:-}"
  local agent_dir="${6:-.agents}"
  local repo_dir ws agent_root
  repo_dir="$(basename "$project_dir")"
  ws="$(dirname "$project_dir")"
  agent_root="${ws}/agent-home"
  mkdir -p "${agent_root}/${agent_dir}"
  printf 'WORK_SPACE=%s\n' "$ws" >"${agent_root}/${agent_dir}/configs"
  {
    printf 'REPO_DIR=%s\nDOC_DIR=%s\n' "$repo_dir" "$doc_dir"
    if [[ -n "$knowledge_type" ]]; then
      printf 'KNOWLEDGE_TYPE=%s\n' "$knowledge_type"
    fi
    printf 'AGENT_ROOT=%s\nAGENT_DIR=%s\n' "$agent_root" "$agent_dir"
  } >"$project_dir/.docsconfig"
}
