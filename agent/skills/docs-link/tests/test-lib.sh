#!/usr/bin/env bash
# 所有可写夹具均置于临时目录；只读复用元库脚本。
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
DOCS_LINK="$ROOT_DIR/agent/skills/docs-link/scripts/docs-link.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_tmp_dir() { mktemp -d "${TMPDIR:-/tmp}/docs-link-tests.XXXXXX"; }

pin_workspace_for_repo() {
  local repo="${1:?}" agent_root="${2:?}" agent_dir="${3:-agent}"
  mkdir -p "$agent_root/$agent_dir"
  [[ -e "$agent_root/$agent_dir/scripts" ]] || ln -s "$ROOT_DIR/agent/scripts" "$agent_root/$agent_dir/scripts"
  printf 'WORK_SPACE=%s\n' "$(dirname "$repo")" > "$agent_root/$agent_dir/configs"
}

fixture_pair() {
  TMP_DIR="$(new_tmp_dir)"
  TMP_DIR="$(cd "$TMP_DIR" && pwd -P)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  SRC="$TMP_DIR/work space/source"
  TGT="$TMP_DIR/work space/target"
  local repo kind
  for repo in "$SRC" "$TGT"; do
    kind="${1:-system}"
    [[ "$repo" == "$SRC" ]] || kind="${2:-application}"
    mkdir -p "$repo/docs"
    git -C "$repo" init -q
    git -C "$repo" remote add origin "https://github.com/example/$(basename "$repo").git"
    printf 'links: []\n' > "$repo/docs/knowledge-links.yaml"
    printf 'REPO_DIR=%s\nDOC_DIR=docs\nKNOWLEDGE_TYPE=%s\nAGENT_ROOT=%s\nAGENT_DIR=agent\n' \
      "$(basename "$repo")" "$kind" "$TMP_DIR" > "$repo/.docsconfig"
    pin_workspace_for_repo "$repo" "$TMP_DIR" agent
  done
}

run_link() { (cd "$SRC" && "$BASH" "$DOCS_LINK" "$@"); }

# 独立文件系统快照：内容、目录、软链、权限；不调用生产辅助函数。
snapshot_pair() {
  python3 -B - "$SRC" "$TGT" <<'PY'
import hashlib, json, os, stat, sys
rows = []
for root in sys.argv[1:]:
    for parent, dirs, files in os.walk(root, followlinks=False):
        for name in sorted(dirs + files):
            path = os.path.join(parent, name)
            mode = stat.S_IMODE(os.lstat(path).st_mode)
            if os.path.islink(path):
                value = ('link', os.readlink(path))
            elif os.path.isfile(path):
                with open(path, 'rb') as stream:
                    value = ('file', hashlib.sha256(stream.read()).hexdigest())
            else:
                value = ('dir', '')
            rows.append((root, os.path.relpath(path, root), mode, value))
print(json.dumps(sorted(rows)))
PY
}
