#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../../../scripts/lib/bash.sh"
exec python3 -B -m unittest discover -s "$TEST_DIR" -p 'test_*.py'
