#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
DOCS_BOOTSTRAP_SCRIPT="$ROOT_DIR/bootstrap.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_fake_home() {
  mktemp -d "${TMPDIR:-/tmp}/docs-bootstrap-tests.XXXXXX"
}

run_docs_bootstrap() {
  local fake_home="$1"
  shift
  HOME="$fake_home" \
    GIT_REPO_URL="$ROOT_DIR" \
    GIT_REF='HEAD' \
    bash "$DOCS_BOOTSTRAP_SCRIPT" "$@"
}
