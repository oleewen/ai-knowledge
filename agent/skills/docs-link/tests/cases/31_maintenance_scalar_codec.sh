#!/usr/bin/env bash
# 严格与维护读取共享标量解码；未选字段错误隔离，type 错误全局拒绝。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
cp "$SRC/docs/knowledge-links.yaml" "$TMP_DIR/valid"
for bad in '"bad\q"' '"open' "'open"; do
  cat > "$SRC/docs/knowledge-links.yaml" <<'YAML'
links:
  - type: child
    repository: "https://example.com/offline.git"
    path: "${WORK_SPACE}/offline"
    dir: "docs"
    name: "offline"
YAML
  printf '    label: %s\n' "$bad" >> "$SRC/docs/knowledge-links.yaml"
  sed '1,2d' "$TMP_DIR/valid" >> "$SRC/docs/knowledge-links.yaml"
  snapshot_pair > "$TMP_DIR/before"
  if run_link --check > "$TMP_DIR/out" 2>&1; then fail '全量检查漏掉非法标量'; fi
  assert_contains '标量' "$TMP_DIR/out"
  assert_contains 'child=2 成功=1 失败=1' "$TMP_DIR/out"
  run_link --check --target "$TGT" > "$TMP_DIR/out" 2>&1 || fail '未选普通字段编码错误阻塞正常 child'
  if run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1; then fail '严格 loader 未拒绝同一非法标量'; fi
  snapshot_pair > "$TMP_DIR/after"
  cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail '解析错误改动仓库'
done
# 已登记 remote 的单引号双写必须被正确解码，而非保留两个引号。
git -C "$TGT" remote set-url origin "https://example.com/target's.git"
python3 -B - "$TMP_DIR/valid" "$SRC/docs/knowledge-links.yaml" <<'PY'
import pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text()
text = text.replace('"https://github.com/example/target.git"', "'https://example.com/target''s.git'")
pathlib.Path(sys.argv[2]).write_text(text)
PY
run_link --check --target "$TGT" > "$TMP_DIR/out" 2>&1 || fail '维护 loader 未解码单引号双写'
# 无法解码 type 时不可借单项过滤绕过歧义。
cat > "$SRC/docs/knowledge-links.yaml" <<'YAML'
links:
  - type: "ch\qild"
    repository: "https://example.com/offline.git"
    path: "${WORK_SPACE}/offline"
    name: "offline"
YAML
sed '1,2d' "$TMP_DIR/valid" >> "$SRC/docs/knowledge-links.yaml"
if run_link --check --target "$TGT" > "$TMP_DIR/out" 2>&1; then fail '未选非法 type 编码须全局失败'; fi
assert_contains 'type' "$TMP_DIR/out"
pass '严格/维护共用 codec，普通字段按条隔离，type 编码错误全局失败'
