#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
AGENT_INSTALL_SCRIPT="$ROOT_DIR/scripts/agent-install.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_fake_home() {
  mktemp -d "${TMPDIR:-/tmp}/agent-install-tests.XXXXXX"
}

run_agent_install() {
  local fake_home="$1"
  shift
  HOME="$fake_home" bash "$AGENT_INSTALL_SCRIPT" "$@"
}
