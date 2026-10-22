#!/usr/bin/env bash
set -euo pipefail
TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_ROOT/../../lib/bash.sh"
TEST_BASH="$BASH" python3 -B -m unittest discover -s "$TEST_ROOT" -v
