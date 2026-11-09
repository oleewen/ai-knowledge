#!/usr/bin/env bash
# dependency 不阻塞模板定位；诊断与整体兼容完成分别报告。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"; ensure_test_agent_home "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT
PROJECT="$TMP_DIR/project"; META="$TMP_DIR/meta"; DOC="$PROJECT/docs"
mkdir -p "$DOC" "$META/application"
printf '# template\n' > "$META/application/new.md"
printf 'REPO_DIR=project\nDOC_DIR=docs\nKNOWLEDGE_TYPE=application\nAGENT_ROOT=%s\nAGENT_DIR=.agents\n' "$HOME" > "$PROJECT/.docsconfig"
pin_workspace_for_repo "$PROJECT" "$HOME" .agents
cat > "$DOC/knowledge-links.yaml" <<'YAML'
links:
  - type: meta
    repository: "https://example.test/meta.git"
    path: "${WORK_SPACE}/meta"
    dir: "application"
  - type: dependency
    repository: "https://example.test/offline.git"
    path: "${WORK_SPACE}/offline"
    dir: "docs"
    name: "offline"
    target_layer: "system"
    entity_ids: ["SYS-A"]
YAML
(cd "$PROJECT" && "$BASH" "$DOCS_UPGRADE_SCRIPT" --dry-run) > "$TMP_DIR/out" 2>&1 || { cat "$TMP_DIR/out"; fail 'dependency 应允许默认 meta 定位和模板预览'; }
assert_contains 'can_advance_version' "$TMP_DIR/out"
assert_contains 'INCOMPLETE' "$TMP_DIR/out"
[[ ! -f "$DOC/new.md" && ! -e "$DOC/governance" ]] || fail '诊断不得写产物'
if (cd "$PROJECT" && "$BASH" "$DOCS_UPGRADE_SCRIPT" --check-compat) > "$TMP_DIR/final" 2>&1; then fail '无最终核验/离线依赖不能称升级完成'; fi
assert_contains 'false' "$TMP_DIR/final"
pass 'dependency 来源兼容；预览诊断不阻塞修复，独立完成门禁拒绝未闭环'
