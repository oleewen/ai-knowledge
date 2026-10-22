#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
PROJECT="$TMP_DIR/project"
mkdir -p "$PROJECT/docs"
printf 'AGENT_ROOT=~\nAGENT_DIR=.agents\nREPO_DIR=project\nDOC_DIR=docs\nKNOWLEDGE_TYPE=application\n' >"$PROJECT/.docsconfig"
printf 'links: []\n' >"$PROJECT/docs/knowledge-links.yaml"
chmod 644 "$PROJECT/docs/knowledge-links.yaml"
snapshot() {
  python3 - "$PROJECT" <<'PY'
import hashlib, json, pathlib, sys
root = pathlib.Path(sys.argv[1])
print(json.dumps([(str(p.relative_to(root)), p.lstat().st_ino, p.lstat().st_mode,
                   p.lstat().st_mtime_ns, hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else '')
                  for p in sorted(root.rglob('*'))]))
PY
}
snapshot >"$TMP_DIR/before"
"$BASH" "$DOCS_INSTALL_SCRIPT" --target "$PROJECT/docs" --dry-run >"$TMP_DIR/out" 2>&1
snapshot >"$TMP_DIR/after"
cmp -s "$TMP_DIR/before" "$TMP_DIR/after" || fail 'dry-run 必须保留文件内容、inode、权限与修改时间'
pass 'dry-run 对已有文档、配置与 links 零变更'
