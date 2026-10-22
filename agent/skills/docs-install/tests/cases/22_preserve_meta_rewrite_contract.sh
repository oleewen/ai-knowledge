#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
META="$TMP_DIR/meta"
mkdir -p "$META/company/knowledge/business" "$META/agent/knowledge"
printf 'AGENT_ROOT=~\nAGENT_DIR=.agents\nREPO_DIR=meta\nDOC_DIR=company\nKNOWLEDGE_TYPE=meta\n' >"$META/.docsconfig"
printf '../agent/knowledge/business-meta.md\n' >"$META/company/knowledge/business/paths.md"
(
  source "$ROOT_DIR/agent/skills/docs-install/scripts/docs-config.sh"
  source "$ROOT_DIR/agent/skills/docs-install/scripts/lib/install.sh"
  declare -A CFG=([dry_run]=0 [docs_abs]="$META/company" [config_file]="$META/.docsconfig" [agent_root]="$HOME" [agent_dir]=.agents)
  docs_install_rewrite_agent_paths
)
[[ ! -e "$META/company/.agents" && ! -L "$META/company/.agents" ]] || fail 'meta 重写不得创建 .agents 软链'
assert_contains '../../../agent/knowledge/business-meta.md' "$META/company/knowledge/business/paths.md"
if "$BASH" "$DOCS_INSTALL_SCRIPT" --type=meta --target "$META/company" --dry-run >"$TMP_DIR/out" 2>&1; then
  fail 'CLI 仅允许四层类型，不允许 --type=meta'
fi
grep -Fq -- '无效 --type' "$TMP_DIR/out" || fail 'meta 类型应在 CLI 预检拒绝'
pass '保留最终配置为 meta 时的路径重写能力，CLI 仍严格四层类型'
