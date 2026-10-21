#!/usr/bin/env bash
# 两个独立仓库：增量范围必须来自元库发布历史，写入必须来自同一目标快照。
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
DOCS_UPGRADE_SCRIPT="${DOCS_UPGRADE_TEST_SCRIPT:-$DOCS_UPGRADE_SCRIPT}"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT

snapshot() {
  local repo="$1" subject="$2"
  git -C "$repo" add -A
  git -C "$repo" -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "$subject"
}

setup_case() {
  CASE_ROOT="$TMP_DIR/$1"
  PROJECT_DIR="$CASE_ROOT/project"
  DOCS_DIR="$PROJECT_DIR/docs"
  META_ROOT="$CASE_ROOT/meta"
  OUT_FILE="$CASE_ROOT/output"
  mkdir -p "$DOCS_DIR" "$META_ROOT/application"
  git -C "$PROJECT_DIR" init -q
  git -C "$META_ROOT" init -q
  git -C "$META_ROOT" symbolic-ref HEAD refs/heads/main
  cat >"$PROJECT_DIR/.docsconfig" <<EOF
REPO_DIR=project
DOC_DIR=docs
AGENT_ROOT=$CASE_ROOT/agent-home
AGENT_DIR=.agents
KNOWLEDGE_TYPE=application
EOF
  pin_workspace_for_repo "$PROJECT_DIR" "$CASE_ROOT/agent-home" .agents
  printf '%s\n' '---' 'version: 2026.1020.0' '---' '# Design' >"$META_ROOT/application/DESIGN.md"
  printf '%s\n' '# Original' >"$META_ROOT/application/changed.md"
  printf '%s\n' '# Stable' >"$META_ROOT/application/stable.md"
  printf '%s\n' '# Readme original' >"$META_ROOT/application/README-s.md"
  snapshot "$META_ROOT" 'docs-publish: version 2026.1020.0'
  BASE_SHA="$(git -C "$META_ROOT" rev-parse HEAD)"
  cp "$META_ROOT/application/DESIGN.md" "$DOCS_DIR/DESIGN.md"
  printf '%s\n' '# Local changed body' >"$DOCS_DIR/changed.md"
  printf '%s\n' '# Local stable body' >"$DOCS_DIR/stable.md"
  printf '%s\n' '# Local readme body' >"$DOCS_DIR/README.md"
  printf '%s\n' '---' 'version: 2026.1021.0' '---' '# Design' >"$META_ROOT/application/DESIGN.md"
  printf '%s\n' '# Released changed' >"$META_ROOT/application/changed.md"
  printf '%s\n' '# Released new' >"$META_ROOT/application/new.md"
  snapshot "$META_ROOT" 'docs-publish: version 2026.1021.0'
  TARGET_SHA="$(git -C "$META_ROOT" rev-parse HEAD)"
}

run_upgrade() {
  (cd "$PROJECT_DIR" && "$BASH" "$DOCS_UPGRADE_SCRIPT" --meta-path "$META_ROOT" "$@") >"$OUT_FILE" 2>&1
}

changed_only() {
  setup_case changed-only
  # 本库有更高版本的独立发布历史，不能影响元库升级范围。
  snapshot "$PROJECT_DIR" 'docs-publish: version 2026.1020.0'
  printf '%s\n' '# Local publish' >"$DOCS_DIR/local.md"
  snapshot "$PROJECT_DIR" 'docs-publish: version 2026.1022.0'
  run_upgrade --dry-run || { cat "$OUT_FILE"; return 1; }
  assert_contains "$BASE_SHA..$TARGET_SHA" "$OUT_FILE"
  assert_contains ' changed.md' "$OUT_FILE"
  assert_contains ' new.md' "$OUT_FILE"
  assert_not_contains ' stable.md' "$OUT_FILE"
  assert_not_contains ' README.md' "$OUT_FILE"
  assert_file_not_exists "$DOCS_DIR/new.md"
}

readme_mapping() {
  setup_case readme-mapping
  printf '%s\n' '# Released mapped readme' >"$META_ROOT/application/README-s.md"
  snapshot "$META_ROOT" 'docs-publish: version 2026.1021.1'
  run_upgrade --dry-run || { cat "$OUT_FILE"; return 1; }
  assert_contains ' README.md' "$OUT_FILE"
  assert_not_contains ' README-s.md' "$OUT_FILE"
  assert_not_contains ' stable.md' "$OUT_FILE"
}

release_snapshot() {
  setup_case release-snapshot
  printf '%s\n' '# Unreleased overwrite' >"$META_ROOT/application/new.md"
  printf '%s\n' '# Unreleased file' >"$META_ROOT/application/unreleased.md"
  snapshot "$META_ROOT" 'unreleased work'
  run_upgrade --apply-scaffold || { cat "$OUT_FILE"; return 1; }
  assert_contains '# Released new' "$DOCS_DIR/new.md"
  assert_file_not_exists "$DOCS_DIR/unreleased.md"
  assert_contains '# Local stable body' "$DOCS_DIR/stable.md"
}

resume_pending_refill() {
  setup_case resume-pending-refill
  run_upgrade --apply-scaffold || { cat "$OUT_FILE"; return 1; }
  assert_contains 'version: 2026.1020.0' "$DOCS_DIR/DESIGN.md"
  run_upgrade --dry-run || { cat "$OUT_FILE"; return 1; }
  assert_contains ' changed.md' "$OUT_FILE"
}

missing_baseline() {
  setup_case missing-baseline
  printf '%s\n' 'version: 2026.1019.0' >"$DOCS_DIR/DESIGN.md"
  if run_upgrade --apply-scaffold; then fail '缺当前发布提交必须停止'; fi
  assert_file_not_exists "$DOCS_DIR/new.md"
  assert_contains '当前版本' "$OUT_FILE"
}

missing_release() {
  setup_case missing-release
  git -C "$META_ROOT" checkout -q --orphan unpublished
  snapshot "$META_ROOT" 'no release on this branch'
  if run_upgrade --apply-scaffold; then fail '所选分支无发布提交必须停止'; fi
  assert_file_not_exists "$DOCS_DIR/new.md"
}

same_version() {
  setup_case same-version
  printf '%s\n' 'version: 2026.1021.0' >"$DOCS_DIR/DESIGN.md"
  run_upgrade --dry-run || { cat "$OUT_FILE"; return 1; }
  assert_contains '== 新增骨架 (0)' "$OUT_FILE"
  assert_contains '== 结构重填 (0)' "$OUT_FILE"
  assert_contains '== 整文件覆盖 (0)' "$OUT_FILE"
}

selected_ref() {
  setup_case selected-ref
  git -C "$META_ROOT" branch older "$BASE_SHA"
  run_upgrade --dry-run --ref older || { cat "$OUT_FILE"; return 1; }
  assert_contains "$BASE_SHA..$BASE_SHA" "$OUT_FILE"
  assert_not_contains ' new.md' "$OUT_FILE"
  assert_not_contains ' README.md' "$OUT_FILE"
}

clone_history() {
  setup_case clone-history
  printf '%s\n' '# Unreleased clone content' >"$META_ROOT/application/new.md"
  snapshot "$META_ROOT" 'unreleased work'
  cat >"$DOCS_DIR/knowledge-links.yaml" <<EOF
links:
  - type: meta
    repository: "file://$META_ROOT"
    path: '\${WORK_SPACE}/missing-meta'
    dir: application
EOF
  (cd "$PROJECT_DIR" && "$BASH" "$DOCS_UPGRADE_SCRIPT" --apply-scaffold) >"$OUT_FILE" 2>&1 \
    || { cat "$OUT_FILE"; return 1; }
  assert_contains "$BASE_SHA..$TARGET_SHA" "$OUT_FILE"
  assert_contains '# Released new' "$DOCS_DIR/new.md"
  assert_contains 'version: 2026.1020.0' "$DOCS_DIR/DESIGN.md"
}

non_git_source() {
  setup_case non-git-source
  mkdir -p "$CASE_ROOT/plain-meta"
  cp -R "$META_ROOT/application" "$CASE_ROOT/plain-meta/"
  META_ROOT="$CASE_ROOT/plain-meta"
  if run_upgrade --apply-scaffold; then fail '有版本号但元库无 Git 历史必须停止'; fi
  assert_file_not_exists "$DOCS_DIR/new.md"
}

failed=0
for scenario in changed_only readme_mapping release_snapshot resume_pending_refill missing_baseline missing_release same_version selected_ref clone_history non_git_source; do
  if (set -e; "$scenario"); then
    pass "版本增量: $scenario"
  else
    printf '[FAIL] 版本增量: %s\n' "$scenario" >&2
    failed=$((failed + 1))
  fi
done
[[ "$failed" -eq 0 ]]
