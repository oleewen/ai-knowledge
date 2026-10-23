#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shared-config-reload.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
for copy_name in a b; do
  cp -R "$SCRIPTS_ROOT" "$TEST_ROOT/$copy_name"
  printf '\ndocsconfig_knowledge_type_is_valid() { printf %s; }\n' "$copy_name-fields" >> "$TEST_ROOT/$copy_name/lib/docsconfig-fields.sh"
  printf '\ndocsconfig_find_repo_root() { printf %s; }\n' "$copy_name-workspace" >> "$TEST_ROOT/$copy_name/lib/docsconfig-workspace.sh"
  printf '\ndocsconfig_write_workspace() { printf %s; }\n' "$copy_name-store" >> "$TEST_ROOT/$copy_name/lib/docsconfig-store.sh"
  printf '\nbackup_rel_under_root() { printf %s; }\n' "$copy_name-backup" >> "$TEST_ROOT/$copy_name/lib/backup.sh"
done
source "$TEST_ROOT/a/docs-core.sh"
[[ "$(docsconfig_knowledge_type_is_valid)" == a-fields ]]
[[ "$(docsconfig_find_repo_root)" == a-workspace ]]
[[ "$(docsconfig_write_workspace)" == a-store ]]
[[ "$(backup_rel_under_root)" == a-backup ]]
unset _AGENT_SHARED_DOCS_CONFIG_LOADED
source "$TEST_ROOT/b/docs-core.sh"
[[ "$(docsconfig_knowledge_type_is_valid)" == b-fields ]]
[[ "$(docsconfig_find_repo_root)" == b-workspace ]]
[[ "$(docsconfig_write_workspace)" == b-store ]]
[[ "$(backup_rel_under_root)" == b-backup ]]
printf 'PASS: 仅重置聚合哨兵时刷新所有配置与备份片段\n'
