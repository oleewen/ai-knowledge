#!/usr/bin/env bash
# 来源识别、写前原字节备份及收尾软链保护。
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT

setup_case() {
  local name="$1" layer="${2:-application}"
  CASE_ROOT="$TMP_DIR/$name"
  PROJECT_DIR="$CASE_ROOT/project"
  DOCS_DIR="$PROJECT_DIR/docs"
  META_ROOT="$CASE_ROOT/meta"
  META_DOCS="$META_ROOT/$layer"
  OUT_FILE="$CASE_ROOT/output"
  mkdir -p "$DOCS_DIR" "$META_DOCS"
  git -C "$PROJECT_DIR" init -q
  cat >"$PROJECT_DIR/.docsconfig" <<EOF
REPO_DIR=project
DOC_DIR=docs
AGENT_ROOT=$CASE_ROOT/agent-home
AGENT_DIR=.agents
KNOWLEDGE_TYPE=$layer
EOF
  pin_workspace_for_repo "$PROJECT_DIR" "$CASE_ROOT/agent-home" .agents
}

run_upgrade() {
  (cd "$PROJECT_DIR" && "$BASH" "$DOCS_UPGRADE_SCRIPT" --meta-path "$META_ROOT" "$@") >"$OUT_FILE" 2>&1
}

require_upgrade() {
  run_upgrade "$@" || { cat "$OUT_FILE"; fail '升级命令失败'; }
}

only_backup() {
  local -a paths=("$PROJECT_DIR/.docs-init"/upgrade-*)
  [[ ${#paths[@]} -eq 1 && -d "${paths[0]}" ]] || fail '应只有一个升级备份目录'
  printf '%s\n' "${paths[0]}"
}

solution_only_source() {
  setup_case solution-only solution
  printf '%s\n' '# Solution scaffold' >"$META_DOCS/new.md"
  require_upgrade --dry-run
  assert_contains ' new.md' "$OUT_FILE"
  assert_dir_not_exists "$PROJECT_DIR/.docs-init"
  require_upgrade --apply-scaffold
  cmp -s "$META_DOCS/new.md" "$DOCS_DIR/new.md" || fail 'solution 源应可写入骨架'
}

original_bytes_backup() {
  setup_case original-bytes
  mkdir -p "$DOCS_DIR/nested/deeper" "$CASE_ROOT/original/nested/deeper"
  printf '# README without links\r\n' >"$DOCS_DIR/README.md"
  printf '# Local\r\nagent/skills/docs-upgrade  \r\n' >"$DOCS_DIR/local-only.md"
  printf '%s\n' 'Read ../../agent/knowledge/glossary.md' >"$DOCS_DIR/nested/deeper/link.txt"
  printf '# Local Design\r\n\r\n## Policy\r\nOriginal bytes  \r\n' >"$DOCS_DIR/DESIGN.md"
  printf '%s\n' '# Meta Design' '## Policy' 'agent/rules/design/design-guidelines.md' >"$META_DOCS/DESIGN.md"
  printf '%s\n' '# New scaffold' >"$META_DOCS/new.md"
  cp -R "$DOCS_DIR/." "$CASE_ROOT/original/"

  require_upgrade --dry-run
  assert_dir_not_exists "$PROJECT_DIR/.docs-init"
  diff -r "$CASE_ROOT/original" "$DOCS_DIR" >/dev/null || fail 'dry-run 不应改变原文件'
  require_upgrade --apply-scaffold
  local backup rel
  backup="$(only_backup)"
  for rel in README.md local-only.md nested/deeper/link.txt DESIGN.md; do
    cmp -s "$CASE_ROOT/original/$rel" "$backup/$rel" || fail "备份须保留原字节: $rel"
  done
  assert_file_not_exists "$backup/new.md"
  assert_contains 'Agent 路径' "$DOCS_DIR/README.md"
  assert_contains '.agents/skills/docs-upgrade' "$DOCS_DIR/local-only.md"
  assert_contains '../../.agents/knowledge/glossary.md' "$DOCS_DIR/nested/deeper/link.txt"
  assert_not_contains '../../agent/' "$DOCS_DIR/nested/deeper/link.txt"
  assert_contains '# Meta Design' "$DOCS_DIR/DESIGN.md"
}

unique_backups() {
  setup_case unique-backups
  mkdir -p "$CASE_ROOT/bin"
  cat >"$CASE_ROOT/bin/date" <<'EOF'
#!/usr/bin/env bash
if [[ "$*" == '+%Y-%m-%d_%H-%M-%S' ]]; then
  printf '%s\n' '2026-10-21_12-00-00'
else
  exec /bin/date "$@"
fi
EOF
  chmod +x "$CASE_ROOT/bin/date"
  printf '%s\n' '# First local design' >"$DOCS_DIR/DESIGN.md"
  printf '%s\n' '# Template design' >"$META_DOCS/DESIGN.md"
  cp "$DOCS_DIR/DESIGN.md" "$CASE_ROOT/first-original"
  PATH="$CASE_ROOT/bin:$PATH" require_upgrade --apply-scaffold
  local first second path
  first="$(only_backup)"
  printf '%s\n' '# Second local design' >"$DOCS_DIR/DESIGN.md"
  cp "$DOCS_DIR/DESIGN.md" "$CASE_ROOT/second-original"
  PATH="$CASE_ROOT/bin:$PATH" require_upgrade --apply-scaffold
  local -a paths=("$PROJECT_DIR/.docs-init"/upgrade-*)
  [[ ${#paths[@]} -eq 2 ]] || fail '同秒实跑必须创建不同备份目录'
  second=''
  for path in "${paths[@]}"; do [[ "$path" == "$first" ]] || second="$path"; done
  cmp -s "$CASE_ROOT/first-original" "$first/DESIGN.md" || fail '后次执行覆盖了前次备份'
  cmp -s "$CASE_ROOT/second-original" "$second/DESIGN.md" || fail '后次备份必须保存第二次执行前原文'
}

readme_symlink_untouched() {
  setup_case readme-symlink
  printf '%s\n' '# External README' 'agent/skills/docs-upgrade' >"$CASE_ROOT/external.md"
  cp "$CASE_ROOT/external.md" "$CASE_ROOT/external-original"
  ln -s "$CASE_ROOT/external.md" "$DOCS_DIR/README.md"
  printf '%s\n' '# Template README' >"$META_DOCS/README.md"
  printf '%s\n' '# New scaffold' >"$META_DOCS/new.md"
  require_upgrade --apply-scaffold
  [[ -L "$DOCS_DIR/README.md" ]] || fail 'README 软链应保留'
  cmp -s "$CASE_ROOT/external-original" "$CASE_ROOT/external.md" || fail '收尾注记不得改写 README 软链目标'
  local backup
  backup="$(only_backup)"
  [[ ! -e "$backup/README.md" && ! -L "$backup/README.md" ]] || fail '不得跟随软链备份外部内容'
  assert_file_exists "$DOCS_DIR/new.md"
}

backup_failure_before_writes() {
  setup_case backup-failure
  mkdir -p "$CASE_ROOT/bin"
  printf '%s\n' '# Local' 'agent/skills/docs-upgrade' >"$DOCS_DIR/local-only.md"
  cp "$DOCS_DIR/local-only.md" "$CASE_ROOT/original"
  printf '%s\n' '# New scaffold' >"$META_DOCS/new.md"
  cat >"$CASE_ROOT/bin/cp" <<'EOF'
#!/usr/bin/env bash
for arg in "$@"; do
  case "$arg" in
    */.docs-init/upgrade-*/*) printf '%s\n' 'injected backup failure' >&2; exit 73 ;;
  esac
done
exec /bin/cp "$@"
EOF
  chmod +x "$CASE_ROOT/bin/cp"
  if PATH="$CASE_ROOT/bin:$PATH" run_upgrade --apply-scaffold; then
    fail '备份失败必须退出，不能继续写盘'
  fi
  assert_contains 'injected backup failure' "$OUT_FILE"
  assert_file_not_exists "$DOCS_DIR/new.md"
  [[ ! -e "$DOCS_DIR/.agents" && ! -L "$DOCS_DIR/.agents" ]] || fail '备份失败不得创建 .agents'
  cmp -s "$CASE_ROOT/original" "$DOCS_DIR/local-only.md" || fail '备份失败不得改正文'
}

backup_enumeration_failure_before_writes() {
  setup_case backup-enumeration-failure
  mkdir -p "$CASE_ROOT/bin"
  printf '%s\n' '# Local' 'agent/skills/docs-upgrade' >"$DOCS_DIR/local-only.md"
  cp "$DOCS_DIR/local-only.md" "$CASE_ROOT/original"
  printf '%s\n' '# New scaffold' >"$META_DOCS/new.md"
  cat >"$CASE_ROOT/bin/find" <<'EOF'
#!/usr/bin/env bash
# 只让备份遍历失败：扫描使用相对根，收尾遍历还限定文件名。
if [[ "$1" == /* && "$*" == *'-prune -o -type f -print0' ]]; then
  printf '%s\n' 'injected backup enumeration failure' >&2
  exit 74
fi
exec /usr/bin/find "$@"
EOF
  chmod +x "$CASE_ROOT/bin/find"
  if PATH="$CASE_ROOT/bin:$PATH" run_upgrade --apply-scaffold; then
    fail '备份枚举失败必须退出，不能继续写盘'
  fi
  assert_contains 'injected backup enumeration failure' "$OUT_FILE"
  assert_file_not_exists "$DOCS_DIR/new.md"
  [[ ! -e "$DOCS_DIR/.agents" && ! -L "$DOCS_DIR/.agents" ]] || fail '备份枚举失败不得创建 .agents'
  cmp -s "$CASE_ROOT/original" "$DOCS_DIR/local-only.md" || fail '备份枚举失败不得改正文'
}

failed=0
for scenario in solution_only_source original_bytes_backup unique_backups readme_symlink_untouched backup_failure_before_writes backup_enumeration_failure_before_writes; do
  if ("$scenario"); then
    pass "来源与写盘安全: $scenario"
  else
    printf '[FAIL] 来源与写盘安全: %s\n' "$scenario" >&2
    failed=$((failed + 1))
  fi
done
[[ "$failed" -eq 0 ]]
