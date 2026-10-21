#!/usr/bin/env bash
# 升级模板目录必须匹配本库层级；错配在扫描和写盘前停止。
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
META_ROOT="$TMP_DIR/meta"
OUT_FILE="$TMP_DIR/output"
mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q
pin_workspace_for_repo "$PROJECT_DIR" "$TMP_DIR/agent-home" .agents
for layer in application system solution company agent; do
  mkdir -p "$META_ROOT/$layer"
  printf '# %s template\n' "$layer" >"$META_ROOT/$layer/template-$layer.md"
done
printf '%s\n' '# Keep local content' >"$DOCS_DIR/local.md"

configure() {
  local layer="$1" source_dir="$2"
  cat >"$PROJECT_DIR/.docsconfig" <<EOF
REPO_DIR=project
DOC_DIR=docs
AGENT_ROOT=$TMP_DIR/agent-home
AGENT_DIR=.agents
KNOWLEDGE_TYPE=$layer
EOF
  cat >"$DOCS_DIR/knowledge-links.yaml" <<'EOF'
links:
  - type: meta
    path: '${WORK_SPACE}/meta'
EOF
  if [[ -n "$source_dir" ]]; then
    printf '    dir: "%s"\n' "$source_dir" >>"$DOCS_DIR/knowledge-links.yaml"
  fi
}

run_upgrade() {
  (cd "$PROJECT_DIR" && "$BASH" "$DOCS_UPGRADE_SCRIPT" "$@") >"$OUT_FILE" 2>&1
}

# 所有其他层、Agent、越过层目录的路径都不得形成升级清单或副作用。
for source_dir in system solution company agent application/../company .; do
  configure application "$source_dir"
  for mode in --dry-run --apply-scaffold; do
    if run_upgrade "$mode"; then
      fail "KNOWLEDGE_TYPE=application、meta.dir=$source_dir 必须硬停 ($mode)"
    fi
    assert_contains '元库模板目录与本库层级不一致' "$OUT_FILE"
    assert_contains "dir=$source_dir" "$OUT_FILE"
    assert_contains 'KNOWLEDGE_TYPE=application' "$OUT_FILE"
    assert_not_contains '== 新增骨架' "$OUT_FILE"
    assert_dir_not_exists "$PROJECT_DIR/.docs-init"
    [[ ! -L "$DOCS_DIR/.agents" ]] || fail '错配不得创建 .agents 软链'
    assert_contains '# Keep local content' "$DOCS_DIR/local.md"
    for layer in application system solution company agent; do
      assert_file_not_exists "$DOCS_DIR/template-$layer.md"
    done
  done
done

# 四层均允许显式同层 dir；省略 dir 时仍使用 KNOWLEDGE_TYPE。
for layer in application system solution company; do
  for source_dir in "$layer" ''; do
    configure "$layer" "$source_dir"
    run_upgrade --dry-run || { cat "$OUT_FILE"; fail '同层配置应成功'; }
    assert_contains " template-$layer.md" "$OUT_FILE"
    for other in application system solution company agent; do
      [[ "$other" == "$layer" ]] && continue
      assert_not_contains " template-$other.md" "$OUT_FILE"
    done
  done
done

# --meta-path 沿用覆盖语义：直接使用本库层级，不读取登记项中的 dir。
configure application company
run_upgrade --dry-run --meta-path "$META_ROOT" || { cat "$OUT_FILE"; fail 'meta-path 覆盖应使用本库层级'; }
assert_contains ' template-application.md' "$OUT_FILE"
assert_not_contains ' template-company.md' "$OUT_FILE"

configure application application
run_upgrade --apply-scaffold || { cat "$OUT_FILE"; fail '同层 scaffold 应成功'; }
assert_file_exists "$DOCS_DIR/template-application.md"
assert_file_not_exists "$DOCS_DIR/template-company.md"
assert_file_not_exists "$DOCS_DIR/template-agent.md"
assert_contains '# Keep local content' "$DOCS_DIR/local.md"

pass 'meta.dir 错配在 dry-run/apply 前硬停；同层、缺省和 meta-path 正常升级'
