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
mkdir "$TMP_DIR/bin"
cat > "$TMP_DIR/bin/ln" <<'SH'
#!/usr/bin/env bash
printf 'injected ln failure\n' >&2
exit 73
SH
chmod +x "$TMP_DIR/bin/ln"
snapshot_pair > "$TMP_DIR/before"
if PATH="$TMP_DIR/bin:$PATH" run_link --repair --target "$TGT" > "$TMP_DIR/out" 2>&1; then fail '实际 ln 失败必须返回非零'; fi
assert_contains 'injected ln failure' "$TMP_DIR/out"
[[ ! -L "$slot" ]] || fail 'ln 失败不应报告已修复'
snapshot_pair > "$TMP_DIR/after"
cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail '失败修改了软链外的仓库内容'
pass 'CLI 边界、dirty/detached 和实际 ln 失败传播'
