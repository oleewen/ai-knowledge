#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_INIT_TEST_REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
export DOCS_INIT_TEST_REPO_ROOT

# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/assert.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/cases/bootstrap-config-sync.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/cases/cross-cut.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/cases/by-scope-config.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/cases/by-scope-knowledge.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/cases/by-scope-agent.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/cases/by-scope-ck.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/cases/by-agents.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/cases/by-mode-type.sh"

printf 'DOCS_INIT_TEST_REPO_ROOT=%s\n' "$DOCS_INIT_TEST_REPO_ROOT"
echo ">>> CI 子集"

test_BS_URL_SYNC

test_XC_H
test_XC_N01
test_XC_N02
test_XC_R

test_SC_C_D
test_SC_C_W
test_SC_C_H
test_SC_C_M

test_SC_K_D
test_SC_K_E

test_SC_A_S

test_SC_CK_D
test_SC_CK_H

test_AG_M

test_MD_N04
test_MD_APP_ID_REMOVED
test_MD_CENTRAL_SYSTEM_SLOT

if [[ "${DOCS_INIT_TEST_FULL:-}" == "1" ]]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/cases/full-copy.sh"

  echo ">>> FULL"
  test_SC_A_RS
  test_SC_X_M

  test_MD_DF
  test_MD_TP_C
  test_MD_C01

  test_FULL_CK
  test_FULL_CFG
fi

echo "全部通过。"
