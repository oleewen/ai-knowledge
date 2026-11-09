#!/usr/bin/env bash
# 消费登记与操作记录重装保留，未完成操作在任何模板写入前阻塞。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
ensure_test_agent_home "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/out"
mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q
"$BASH" "$DOCS_INSTALL_SCRIPT" --type application --target "$DOCS_DIR" > "$OUT_FILE" 2>&1
cat >> "$DOCS_DIR/knowledge-links.yaml" <<'YAML'
  - type: dependency
    repository: "https://example.test/provider.git"
    path: "${WORK_SPACE}/provider"
    dir: "docs"
    name: "provider"
    label: "消费目标"
    target_layer: "system"
    entity_ids: ["SYS-A"]
YAML
old_count="$(find "$DOCS_DIR/governance/operations" -name '*.yaml' | wc -l)"
"$BASH" "$DOCS_INSTALL_SCRIPT" --type application --target "$DOCS_DIR" --force > "$OUT_FILE" 2>&1 || { cat "$OUT_FILE"; fail '重装应保留 dependency'; }
assert_contains 'SYS-A' "$DOCS_DIR/knowledge-links.yaml"
new_count="$(find "$DOCS_DIR/governance/operations" -name '*.yaml' | wc -l)"
((new_count > old_count)) || fail '已有操作记录被重装丢弃'
# An editor does not participate in flock; preserving a stale stash must not
# overwrite an edit made during template installation.
(
  source "$ROOT_DIR/agent/scripts/docs-core.sh"
  source "$ROOT_DIR/agent/skills/docs-install/scripts/lib/install.sh"
  declare -A CFG=([docs_abs]="$DOCS_DIR" [dry_run]=0)
  docs_install_stash_knowledge_links
  printf '\n# external-edit\n' >> "$DOCS_DIR/knowledge-links.yaml"
  if docs_install_restore_knowledge_links > "$OUT_FILE" 2>&1; then fail '安装不能覆盖预读后外部编辑'; fi
  assert_contains 'external-edit' "$DOCS_DIR/knowledge-links.yaml"
)
PYTHONPATH="$ROOT_DIR/agent/scripts/tools" python3 -B - "$DOCS_DIR" <<'PYTHON'
import sys
from pathlib import Path
from unittest.mock import patch
from federation_write.operations import Plan
root=Path(sys.argv[1]); plan=Plan(root,[root],'interrupted')
plan.file(root/'knowledge-links.yaml','links: []\n')
with patch('federation_write.operations.apply_step',side_effect=OSError('disk')):
    try: plan.execute()
    except OSError: pass
PYTHON
cp "$DOCS_DIR/knowledge-links.yaml" "$TMP_DIR/before"
if "$BASH" "$DOCS_INSTALL_SCRIPT" --type application --target "$DOCS_DIR" --force > "$OUT_FILE" 2>&1; then fail '未完成操作不能继续安装'; fi
assert_contains '未完成' "$OUT_FILE"
if "$BASH" "$DOCS_INSTALL_SCRIPT" --type application --target "$DOCS_DIR" --force --dry-run > "$OUT_FILE" 2>&1; then fail '预览不能忽略未完成操作'; fi
assert_contains '未完成' "$OUT_FILE"
cmp "$TMP_DIR/before" "$DOCS_DIR/knowledge-links.yaml"
pass '重装保留消费登记与操作历史，未完成操作阻塞模板写入'
