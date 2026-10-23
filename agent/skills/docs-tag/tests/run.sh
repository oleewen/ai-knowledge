#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PYTHONDONTWRITEBYTECODE=1
# pytest returns nonzero when no tests are collected; never fall back to unittest.
python3 -B -c 'import pytest, hypothesis, yaml' || {
  echo '[ERROR] docs-tag tests require existing pytest, hypothesis and PyYAML' >&2
  exit 1
}
TEST_TMP="$(mktemp -d)"
trap 'rm -rf "$TEST_TMP"' EXIT
export HYPOTHESIS_STORAGE_DIRECTORY="$TEST_TMP/hypothesis"
python3 -B -m pytest -p no:cacheprovider "$TEST_ROOT"
