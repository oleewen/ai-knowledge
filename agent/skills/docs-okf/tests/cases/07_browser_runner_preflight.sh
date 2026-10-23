#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$TEST_ROOT/../../../scripts/test-core.sh"
FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT
mkdir -p "$FIXTURE/assets"
cat > "$FIXTURE/node" <<'STUB'
#!/usr/bin/env bash
cat >/dev/null
if [[ "${FAKE_NODE_MISSING:-}" == 1 ]]; then
  echo 'fake Node: missing Playwright' >&2
  exit 1
fi
STUB
chmod +x "$FIXTURE/node"
runner="$TEST_ROOT/run-browser.sh"
if FAKE_NODE_MISSING=1 NODE="$FIXTURE/node" "$BASH" "$runner" >"$FIXTURE/output" 2>&1; then
  fail 'browser runner swallowed dependency preflight failure'
fi
assert_contains 'missing Playwright' "$FIXTURE/output"
if OKF_VIZ_ASSETS='' NODE="$FIXTURE/node" "$BASH" "$runner" >"$FIXTURE/output" 2>&1; then
  fail 'browser runner accepted missing assets directory'
fi
assert_contains 'OKF_VIZ_ASSETS' "$FIXTURE/output"
if OKF_VIZ_ASSETS="$FIXTURE/assets" NODE="$FIXTURE/node" "$BASH" "$runner" >"$FIXTURE/output" 2>&1; then
  fail 'browser runner accepted missing pinned production asset'
fi
assert_contains 'missing pinned asset' "$FIXTURE/output"
printf 'untrusted bytes\n' >"$FIXTURE/assets/cytoscape.min.js"
if OKF_VIZ_ASSETS="$FIXTURE/assets" NODE="$FIXTURE/node" "$BASH" "$runner" >"$FIXTURE/output" 2>&1; then
  fail 'browser runner accepted mismatched production SRI'
fi
assert_contains 'production SRI mismatch' "$FIXTURE/output"
pass 'browser optional dependencies and production SRI fail closed'
