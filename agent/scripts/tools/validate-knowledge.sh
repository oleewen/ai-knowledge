#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PYTHONDONTWRITEBYTECODE=1
export KNOWLEDGE_VALIDATION_BASH="$BASH"
exec python3 -B "$SCRIPT_DIR/validate_knowledge.py" "$@"
