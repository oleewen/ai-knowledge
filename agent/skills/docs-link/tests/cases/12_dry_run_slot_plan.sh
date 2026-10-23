#!/usr/bin/env bash
# 捕获预览中槽位路径未插值，以及预览意外改写任一仓库的回归。
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
TASK_TMP="$(mktemp -d)"
trap 'rm -rf "$TASK_TMP"' EXIT
TASK_TMP="$(cd "$TASK_TMP" && pwd -P)"
SRC="$TASK_TMP/work space/system"
TGT="$TASK_TMP/work space/billing"
mkdir -p "$SRC/docs" "$TGT/docs" "$TASK_TMP/agent-data"
ln -s "$ROOT_DIR/agent/scripts" "$TASK_TMP/agent-data/scripts"
for repo in "$SRC" "$TGT"; do
  git -C "$repo" init -q
  git -C "$repo" remote add origin "https://example.com/$(basename "$repo").git"
  printf 'links: []\n' > "$repo/docs/knowledge-links.yaml"
  printf 'AGENT_ROOT=%s\nAGENT_DIR=agent-data\nREPO_DIR=%s\nDOC_DIR=docs\nKNOWLEDGE_TYPE=%s\n' \
    "$TASK_TMP" "$(basename "$repo")" "$(if [[ "$repo" == "$SRC" ]]; then printf system; else printf application; fi)" > "$repo/.docsconfig"
done
printf 'WORK_SPACE=%s\n' "$TASK_TMP/work space" > "$TASK_TMP/agent-data/configs"
printf 'existing business text\n' > "$TGT/docs/business.md"
# 包括 Git 元数据、配置、目录与软链；快照存到被观察树之外。
snapshot() {
  python3 -B - "$SRC" "$TGT" <<'PY'
import hashlib, json, os, sys
rows = []
for root in sys.argv[1:]:
    for parent, dirs, files in os.walk(root, followlinks=False):
        for name in sorted(dirs + files):
            path = os.path.join(parent, name)
            relative = os.path.relpath(path, root)
            if os.path.islink(path):
                rows.append((root, relative, 'link', os.readlink(path)))
            elif os.path.isfile(path):
                with open(path, 'rb') as stream:
                    rows.append((root, relative, 'file', hashlib.sha256(stream.read()).hexdigest()))
            else:
                rows.append((root, relative, 'dir'))
print(json.dumps(sorted(rows)))
PY
}
snapshot > "$TASK_TMP/before"
(cd "$SRC" && "$BASH" "$ROOT_DIR/agent/skills/docs-link/scripts/docs-link.sh" \
  --link --target "$TGT" --app-name billing --dry-run) > "$TASK_TMP/out" 2>&1
snapshot > "$TASK_TMP/after"
cmp "$TASK_TMP/before" "$TASK_TMP/after" || { echo 'FAIL: dry-run modified repository trees'; exit 1; }
# 独立手算路径；验证用户看到的映射，而非源码或共享 logger 实现。
grep -Fq "$SRC/docs/application-slots/application-billing → $TGT/docs" "$TASK_TMP/out" \
  || { echo 'FAIL: dry-run omits the resolved slot-to-document mapping'; cat "$TASK_TMP/out"; exit 1; }
echo 'PASS: dry-run shows resolved slot mapping and preserves both repositories'
