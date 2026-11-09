#!/usr/bin/env bash
set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1
python3 -B -m unittest discover -s "$(dirname "${BASH_SOURCE[0]}")" -p "test_*.py"
