#!/usr/bin/env bash
# 非普通末段必须在备份/模板复制前拒绝；dry-run 同样检查。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
TMP_DIR="$(cd "$TMP_DIR" && pwd -P)"
trap 'rm -rf "$TMP_DIR"' EXIT
META="$TMP_DIR/work/meta"
mkdir -p "$META/application" "$TMP_DIR/agent/scripts"
printf '# fixture\n' > "$TMP_DIR/agent/scripts/docs-core.sh"
printf 'WORK_SPACE=%s\n' "$TMP_DIR/work" > "$TMP_DIR/agent/configs"
printf '# template\n' > "$META/application/README.md"
git -C "$META" init -q
git -C "$META" remote add origin 'https://example.test/meta.git'
snapshot() {
  python3 -B - "$1" <<'PY'
import hashlib, json, os, stat, sys
rows = []
for parent, dirs, files in os.walk(sys.argv[1], followlinks=False):
    for name in sorted(dirs + files):
        p = os.path.join(parent, name)
        s = os.lstat(p)
        value = os.readlink(p) if stat.S_ISLNK(s.st_mode) else ''
        if stat.S_ISREG(s.st_mode):
            with open(p, 'rb') as f:
                value = hashlib.sha256(f.read()).hexdigest()
        rows.append((p, s.st_mode, s.st_ino, s.st_mtime_ns, value))
print(json.dumps(sorted(rows)))
PY
}
for kind in link broken directory fifo; do
  PROJECT="$TMP_DIR/work/$kind"
  mkdir -p "$PROJECT/docs"
  printf 'REPO_DIR=%s\nDOC_DIR=docs\nKNOWLEDGE_TYPE=application\nAGENT_ROOT=%s\nAGENT_DIR=agent\n' "$kind" "$TMP_DIR" > "$PROJECT/.docsconfig"
  printf 'original\n' > "$PROJECT/docs/keep.md"
  f="$PROJECT/docs/knowledge-links.yaml"
  case "$kind" in
    link) printf 'links: []\n' > "$PROJECT/referent"; ln -s ../referent "$f" ;;
    broken) ln -s ../missing "$f" ;;
    directory) mkdir "$f" ;;
    fifo) mkfifo "$f" ;;
  esac
  for dry in 0 1; do
    snapshot "$PROJECT" > "$TMP_DIR/before"
    rc=0
    python3 -B - "$BASH" "$DOCS_INSTALL_SCRIPT" "$PROJECT/docs" "$META" "$dry" > "$TMP_DIR/out" 2>&1 <<'PY' || rc=$?
import subprocess, sys
args = [sys.argv[1], sys.argv[2], '--target', sys.argv[3], '--meta', sys.argv[4], '--force']
if sys.argv[5] == '1':
    args.append('--dry-run')
try:
    result = subprocess.run(args, timeout=10)
except subprocess.TimeoutExpired:
    sys.exit(124)
sys.exit(result.returncode)
PY
    [[ "$rc" -ne 0 && "$rc" -ne 124 ]] || fail "清单 $kind 未提前拒绝 (dry-run=$dry, rc=$rc)"
    snapshot "$PROJECT" > "$TMP_DIR/after"
    cmp -s "$TMP_DIR/before" "$TMP_DIR/after" || fail "清单 $kind 拒绝前已备份或复制 (dry-run=$dry)"
    assert_contains '普通' "$TMP_DIR/out"
  done
done
# upsert 本身失败须传播，并且不能先留下 links: [] 空壳。
(
  source "$ROOT_DIR/agent/scripts/docs-core.sh"
  source "$ROOT_DIR/agent/skills/docs-install/scripts/lib/install.sh"
  PROJECT="$TMP_DIR/work/upsert"
  mkdir -p "$PROJECT/docs"
  printf 'REPO_DIR=upsert\nDOC_DIR=docs\nKNOWLEDGE_TYPE=application\nAGENT_ROOT=%s\nAGENT_DIR=agent\n' "$TMP_DIR" > "$PROJECT/.docsconfig"
  declare -A CFG=([docs_abs]="$PROJECT/docs" [dry_run]=0 [type]=application
    [meta_repo]=$'https://example.test/bad\nremote.git' [meta_path_stored]='${WORK_SPACE}/meta')
  if docs_install_upsert_knowledge_meta > "$TMP_DIR/out" 2>&1; then fail 'upsert 未传播清单预检失败'; fi
  [[ ! -e "$PROJECT/docs/knowledge-links.yaml" ]] || fail 'upsert 失败留下预创建空清单'
)
pass '安装器拒绝清单软链/失效软链/目录/FIFO；失败 upsert 不留空壳，实际与 dry-run 均无副作用'
