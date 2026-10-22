#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PYTHONDONTWRITEBYTECODE=1
export BASH
exec python3 -m unittest discover -s "$TEST_DIR" -p 'test_*.py' -v
