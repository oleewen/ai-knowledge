#!/usr/bin/env bash
# 维护仅接受合法既有双边登记；任何阻塞不得变更仓库。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
cp "$SRC/.docsconfig" "$TMP_DIR/source-config"
cp "$TGT/.docsconfig" "$TMP_DIR/target-config"
cp "$SRC/docs/knowledge-links.yaml" "$TMP_DIR/source-list"
cp "$TGT/docs/knowledge-links.yaml" "$TMP_DIR/target-list"
slot="$SRC/docs/application-slots/application-target"
for problem in source-owner target-owner target-kind source-remote target-remote target-dir parent-dir parent-path parent-remote no-parent two-parents no-source-list no-target-list missing-repo doc-escape file directory slots-symlink name-collision; do
  case "$problem" in
    source-owner) sed 's/REPO_DIR=source/REPO_DIR=target/' "$TMP_DIR/source-config" > "$SRC/.docsconfig" ;;
    target-owner) sed 's/REPO_DIR=target/REPO_DIR=source/' "$TMP_DIR/target-config" > "$TGT/.docsconfig" ;;
    target-kind) sed 's/KNOWLEDGE_TYPE=application/KNOWLEDGE_TYPE=solution/' "$TMP_DIR/target-config" > "$TGT/.docsconfig" ;;
    source-remote) git -C "$SRC" remote remove origin ;;
    target-remote) git -C "$TGT" remote set-url origin https://example.com/wrong.git ;;
    target-dir) sed 's/dir: "docs"/dir: "other"/' "$TMP_DIR/source-list" > "$SRC/docs/knowledge-links.yaml" ;;
    parent-dir) sed 's/dir: "docs"/dir: "other"/' "$TMP_DIR/target-list" > "$TGT/docs/knowledge-links.yaml" ;;
    parent-path) sed 's@${WORK_SPACE}/source@${WORK_SPACE}/target@' "$TMP_DIR/target-list" > "$TGT/docs/knowledge-links.yaml" ;;
    parent-remote) sed 's@github.com/example/source.git@example.com/wrong.git@' "$TMP_DIR/target-list" > "$TGT/docs/knowledge-links.yaml" ;;
    no-parent) printf 'links: []\n' > "$TGT/docs/knowledge-links.yaml" ;;
    two-parents) sed '1,2d' "$TMP_DIR/target-list" >> "$TGT/docs/knowledge-links.yaml" ;;
    no-source-list) mv "$SRC/docs/knowledge-links.yaml" "$TMP_DIR/hidden-source" ;;
    no-target-list) mv "$TGT/docs/knowledge-links.yaml" "$TMP_DIR/hidden-target" ;;
    missing-repo) mv "$TGT/.git" "$TMP_DIR/hidden-git" ;;
    doc-escape) mv "$TGT/docs" "$TMP_DIR/external-docs"; ln -s "$TMP_DIR/external-docs" "$TGT/docs" ;;
    file) rm "$slot"; printf 'keep\n' > "$slot" ;;
    directory) rm "$slot"; mkdir "$slot"; printf 'keep\n' > "$slot/keep" ;;
    slots-symlink) mv "$SRC/docs/application-slots" "$TMP_DIR/external-slots"; ln -s "$TMP_DIR/external-slots" "$SRC/docs/application-slots" ;;
    name-collision) sed '1,2d;s@target.git@other.git@;s@WORK_SPACE}/target@WORK_SPACE}/other@;s/name: "target"/name: "TARGET"/' "$TMP_DIR/source-list" >> "$SRC/docs/knowledge-links.yaml" ;;
  esac
  snapshot_pair > "$TMP_DIR/before"
  for action in check repair; do
    if run_link "--$action" --target "$TGT" > "$TMP_DIR/out" 2>&1; then fail "$problem/$action 应拒绝"; fi
    snapshot_pair > "$TMP_DIR/after"
    cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail "$problem/$action 改动了仓库"
  done
  case "$problem" in
    source-remote) git -C "$SRC" remote add origin https://github.com/example/source.git ;;
    target-remote) git -C "$TGT" remote set-url origin https://github.com/example/target.git ;;
    missing-repo) mv "$TMP_DIR/hidden-git" "$TGT/.git" ;;
    doc-escape) rm "$TGT/docs"; mv "$TMP_DIR/external-docs" "$TGT/docs" ;;
    file|directory) rm -rf "$slot"; ln -s "$TGT/docs" "$slot" ;;
    slots-symlink) rm "$SRC/docs/application-slots"; mv "$TMP_DIR/external-slots" "$SRC/docs/application-slots" ;;
  esac
  cp "$TMP_DIR/source-config" "$SRC/.docsconfig"
  cp "$TMP_DIR/target-config" "$TGT/.docsconfig"
  cp "$TMP_DIR/source-list" "$SRC/docs/knowledge-links.yaml"
  cp "$TMP_DIR/target-list" "$TGT/docs/knowledge-links.yaml"
done
pass '配置、身份、反向 parent、边界与真实数据阻塞均无副作用'
