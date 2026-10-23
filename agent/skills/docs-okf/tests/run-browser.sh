#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PYTHONDONTWRITEBYTECODE=1
NODE="${NODE:-node}"
export NODE
fail() { printf '[ERROR] docs-okf-browser: %s\n' "$*" >&2; exit 1; }
command -v "$NODE" >/dev/null 2>&1 || fail 'existing Node.js is required (NODE may select it)'
"$NODE" - <<'JS' || exit 1
const fs = require('node:fs');
try {
  const { chromium } = require('playwright');
  const executable = process.env.OKF_BROWSER_EXECUTABLE || chromium.executablePath();
  fs.accessSync(executable, fs.constants.X_OK);
} catch (error) {
  console.error('[ERROR] docs-okf-browser: existing Playwright and Chromium/Chrome required; set NODE_PATH and OKF_BROWSER_EXECUTABLE if needed. ' + error.message);
  process.exitCode = 1;
}
JS
[[ -n "${OKF_VIZ_ASSETS:-}" && -d "$OKF_VIZ_ASSETS" ]] || fail 'OKF_VIZ_ASSETS must name an existing directory containing pinned production assets'
# Read production SRI metadata rather than weakening or duplicating its hashes.
python3 -B - "$TEST_ROOT/../scripts" "$OKF_VIZ_ASSETS" <<'PY'
import base64
import hashlib
from html.parser import HTMLParser
from pathlib import Path
import sys

sys.path.insert(0, sys.argv[1])
import visualize

class ScriptParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.scripts = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "script" and "src" in attrs:
            self.scripts.append(attrs)

parser = ScriptParser()
parser.feed(visualize.render_html({
    "name": "preflight", "concepts": {}, "types": [], "typeColors": {}, "edges": [],
}))
assets = Path(sys.argv[2])
expected = {"cytoscape.min.js", "marked.min.js", "purify.min.js"}
seen = set()
for attrs in parser.scripts:
    src = attrs["src"]
    name = ("cytoscape.min.js" if "/cytoscape@" in src else
            "marked.min.js" if "/marked@" in src else
            "purify.min.js" if "/dompurify@" in src else None)
    if name is None or name in seen:
        raise SystemExit(f"[ERROR] docs-okf-browser: unexpected production dependency: {src}")
    seen.add(name)
    file = assets / name
    if not file.is_file():
        raise SystemExit(f"[ERROR] docs-okf-browser: missing pinned asset {file} ({src})")
    integrity = attrs.get("integrity", "")
    tokens = integrity.split()
    valid = False
    for token in tokens:
        algorithm, _, digest = token.partition("-")
        if algorithm in {"sha256", "sha384", "sha512"}:
            actual = base64.b64encode(hashlib.new(algorithm, file.read_bytes()).digest()).decode()
            valid = valid or actual == digest
    if not valid:
        raise SystemExit(f"[ERROR] docs-okf-browser: production SRI mismatch for {file} ({src})")
if seen != expected:
    raise SystemExit("[ERROR] docs-okf-browser: production dependency set changed; update preflight mapping")
PY
OKF_BROWSER_TESTS=1 python3 -B "$TEST_ROOT/test_visualize_security.py"
