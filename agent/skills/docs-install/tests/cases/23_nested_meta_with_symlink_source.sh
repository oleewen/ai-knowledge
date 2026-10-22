#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
PROJECT="$TMP_DIR/project"
META="$PROJECT/docs/meta"
TEMPLATES="$TMP_DIR/external-templates"
mkdir -p "$META" "$TEMPLATES"
git -C "$META" init -q
git -C "$META" remote add origin https://example.com/meta.git
printf '# external template\n' >"$TEMPLATES/README.md"
printf 'preserve\n' >"$PROJECT/docs/sentinel"
ln -s "$TEMPLATES" "$META/application"
for flag in --dry-run --force; do
  if "$BASH" "$DOCS_INSTALL_SCRIPT" --meta "$META" --target "$PROJECT/docs" "$flag" >"$TMP_DIR/out" 2>&1; then
    fail "目标包含元库根时必须拒绝，即使模板指向外部: $flag"
  fi
  assert_file_exists "$PROJECT/docs/sentinel"
  assert_file_exists "$META/.git/config"
  assert_file_exists "$TEMPLATES/README.md"
  [[ ! -e "$PROJECT/.docs-init" && ! -e "$PROJECT/.docsconfig" ]] || fail '不得先搬走元库再报告失败'
done
pass '模板软链指向外部时，仍拒绝目标包含元库根'
