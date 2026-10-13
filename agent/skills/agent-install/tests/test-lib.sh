#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
AGENT_INSTALL_SCRIPT="$ROOT_DIR/agent/skills/agent-install/scripts/agent-install.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_fake_home() {
  mktemp -d "${TMPDIR:-/tmp}/agent-install-tests.XXXXXX"
}

run_agent_install() {
  local fake_home="$1"
  shift
  HOME="$fake_home" "${BASH:-$(command -v bash)}" "$AGENT_INSTALL_SCRIPT" --workspace "$fake_home/workspaces" "$@"
}

# 不传 --workspace；依赖 cwd 上溯 .docsconfig + HOME 下 configs 推断
run_agent_install_infer_workspace() {
  local fake_home="$1"
  shift
  HOME="$fake_home" "${BASH:-$(command -v bash)}" "$AGENT_INSTALL_SCRIPT" "$@"
}
