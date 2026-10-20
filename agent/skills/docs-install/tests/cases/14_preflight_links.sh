#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
PROJECT="$TMP_DIR/project"
mkdir -p "$PROJECT/docs"
git -C "$PROJECT" init -q
printf 'AGENT_ROOT=~\nAGENT_DIR=.agents\nREPO_DIR=project\nDOC_DIR=docs\nKNOWLEDGE_TYPE=application\n' > "$PROJECT/.docsconfig"
printf 'links:\n  - type: meta\n    path: "%s"\n    repository: "https://example.com/meta.git"\n' "$ROOT_DIR" > "$PROJECT/docs/knowledge-links.yaml"
printf 'preserve\n' > "$PROJECT/docs/sentinel"
cp "$PROJECT/.docsconfig" "$TMP_DIR/config-before"
cp "$PROJECT/docs/knowledge-links.yaml" "$TMP_DIR/links-before"
for mode in --dry-run --force; do
  if "$BASH" "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target "$PROJECT/docs" "$mode" > "$TMP_DIR/out" 2>&1; then
    fail "旧 path 的 $mode 必须失败"
  fi
  grep -Fq 'WORK_SPACE' "$TMP_DIR/out" || fail '必须因路径契约失败'
  cmp "$TMP_DIR/config-before" "$PROJECT/.docsconfig"
  cmp "$TMP_DIR/links-before" "$PROJECT/docs/knowledge-links.yaml"
  [[ "$(cat "$PROJECT/docs/sentinel")" == preserve ]]
  [[ ! -e "$PROJECT/.docs-init" ]] || fail '预检失败不应创建备份或同步模板'
done
pass '安装 dry-run/实跑先验证旧清单，无部分写入'
