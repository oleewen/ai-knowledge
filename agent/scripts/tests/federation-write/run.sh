#!/usr/bin/env bash
set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1
export KNOWLEDGE_VALIDATION_BASH="${BASH}"
python3 -B -m unittest discover -s "$(dirname "${BASH_SOURCE[0]}")" -p 'test_*.py'
