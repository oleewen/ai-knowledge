#!/usr/bin/env bash
# 删除匹配 parent 时，不得丢弃目标的 meta/child。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair solution system
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
cat >> "$TGT/docs/knowledge-links.yaml" <<'EOF'
  - type: meta
    repository: "https://example.com/meta.git"
    path: "${WORK_SPACE}/meta"
    dir: "system"
  - type: child
    repository: "https://example.com/billing.git"
    path: "${WORK_SPACE}/billing"
    dir: "docs"
    name: "billing"
    label: "账单应用"
EOF
run_link --unlink --target "$TGT" >> "$TMP_DIR/out" 2>&1
assert_contains 'type: meta' "$TGT/docs/knowledge-links.yaml"
assert_contains 'type: child' "$TGT/docs/knowledge-links.yaml"
assert_contains 'label: "账单应用"' "$TGT/docs/knowledge-links.yaml"
assert_not_contains 'type: parent' "$TGT/docs/knowledge-links.yaml"
pass 'unlink 仅移除匹配 parent'
