#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
unset _LIB_DIR
source "$SCRIPTS_ROOT/lib/agents.sh"
[[ "$(agents_normalize 'codex,cursor,codex')" == 'codex cursor' ]]
[[ "$(agents_normalize all)" == 'cursor codex claude trae kiro' ]]
agents_validate 'codex,cursor'
if agents_validate unknown; then exit 1; fi
printf 'PASS: agents 独立加载\n'
