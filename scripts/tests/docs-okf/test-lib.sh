#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
RESOLVE_SCRIPT="$ROOT_DIR/agent/skills/docs-okf/scripts/resolve-okf-paths.sh"
VALIDATE_SCRIPT="$ROOT_DIR/agent/skills/docs-okf/scripts/okf-validate.sh"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }

new_tmp_dir() { mktemp -d "${TMPDIR:-/tmp}/docs-okf-tests.XXXXXX"; }

write_docsconfig() {
  local project_dir="$1"
  local doc_root="$2"
  local repo_root="$3"
  local doc_dir="$4"
  local knowledge_type="${5:-}"
  {
    printf 'DOC_ROOT=%s\nREPO_ROOT=%s\nDOC_DIR=%s\n' "$doc_root" "$repo_root" "$doc_dir"
    if [[ -n "$knowledge_type" ]]; then
      printf 'KNOWLEDGE_TYPE=%s\n' "$knowledge_type"
    fi
  } >"$project_dir/.docsconfig"
}
