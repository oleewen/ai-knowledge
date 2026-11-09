#!/usr/bin/env bash
set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1
python3 -B "$(dirname "${BASH_SOURCE[0]}")/run_behavior_evals.py" "$@"
