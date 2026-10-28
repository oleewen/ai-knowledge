#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_ROOT/../../../scripts/lib/bash.sh"
"$BASH" "$TEST_ROOT/test-validate-guide.sh"
