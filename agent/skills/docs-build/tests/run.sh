#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PYTHONDONTWRITEBYTECODE=1
source "$TEST_ROOT/../../../scripts/lib/bash.sh"
# The Python cases invoke `bash` by name; keep their subprocesses on this Bash 5+.
export PATH="$(dirname "$BASH"):$PATH"
# Fail closed when discovery collects no executable cases.
python3 -B - "$TEST_ROOT" <<'PYTHON'
import sys
import unittest

suite = unittest.defaultTestLoader.discover(sys.argv[1], pattern="test_*.py")
if suite.countTestCases() == 0:
    raise SystemExit("No Python test cases collected")
result = unittest.TextTestRunner(verbosity=2).run(suite)
raise SystemExit(0 if result.wasSuccessful() else 1)
PYTHON
