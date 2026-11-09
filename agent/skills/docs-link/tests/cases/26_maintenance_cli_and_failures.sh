#!/usr/bin/env bash
# 互斥、空清单、dirty/detached 与真正 ln 失败传播。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --check > "$TMP_DIR/out" 2>&1 || fail '空 child 清单检查应成功'
assert_contains 'child' "$TMP_DIR/out"
for scenario in no-action no-target all duplicate check-name repair-http; do
  case "$scenario" in
    no-action) args=(--target "$TGT") ;;
    no-target) args=(--repair) ;;
    all) args=(--repair --all) ;;
    duplicate) args=(--check --repair --target "$TGT") ;;
    check-name) args=(--check --app-name target) ;;
    repair-http) args=(--repair --target "$TGT" --rewrite-http) ;;
  esac
  if run_link "${args[@]}" > "$TMP_DIR/out" 2>&1; then fail "$scenario 应拒绝"; fi
done
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
# fixture 提交仅在临时仓，用于生成真实 detached HEAD。
for repo in "$SRC" "$TGT"; do
  git -C "$repo" add .
  git -C "$repo" -c user.name=Test -c user.email=test@example.com -c commit.gpgsign=false commit -qm fixture
  git -C "$repo" checkout -q --detach
  printf 'dirty\n' > "$repo/dirty.txt"
done
slot="$SRC/docs/application-slots/application-target"
rm "$slot"
run_link --repair --target "$TGT" > "$TMP_DIR/out" 2>&1 || fail 'dirty/detached 应允许维护'
rm "$slot"
chmod a-w "$(dirname "$slot")"
if run_link --repair --target "$TGT" > "$TMP_DIR/out" 2>&1; then
  chmod u+w "$(dirname "$slot")"
  fail '真实槽位写入失败必须返回非零'
fi
chmod u+w "$(dirname "$slot")"
assert_contains 'Permission denied' "$TMP_DIR/out"
[[ ! -L "$slot" ]] || fail '写入失败不应报告已修复'
python3 -B - "$SRC/docs/governance/operations" <<'PYTHON'
import json, pathlib, sys
records=[json.loads(p.read_text()) for p in pathlib.Path(sys.argv[1]).glob('*.yaml')]
assert any(r['action']=='repair' and r['state']=='partial' for r in records)
PYTHON
pass 'CLI 边界、dirty/detached 和真实槽位写入失败保留恢复记录'
