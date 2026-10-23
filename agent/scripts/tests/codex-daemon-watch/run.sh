#!/usr/bin/env bash
set -euo pipefail
PYTHONDONTWRITEBYTECODE=1 python3 "$(dirname "${BASH_SOURCE[0]}")/test_watch.py"
