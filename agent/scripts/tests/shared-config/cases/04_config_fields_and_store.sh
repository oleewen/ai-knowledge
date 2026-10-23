#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/lib/docsconfig.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shared-config-fields.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
TEST_ROOT="$(cd "$TEST_ROOT" && pwd -P)"
mkdir -p "$TEST_ROOT/project/docs/nested" "$TEST_ROOT/store"
printf '# comment\r\nREPO_DIR=first\r\nREPO_DIR="project"\r\nDOC_DIR=\047docs/nested\047\r\nAGENT_ROOT="~"\r\nAGENT_DIR=.agents\r\nKNOWLEDGE_TYPE=system' > "$TEST_ROOT/input"
parsed_repo='' parsed_doc='' raw_ar='' parsed_type='' parsed_agent=''
docsconfig_read_into "$TEST_ROOT/input" parsed_repo parsed_doc raw_ar parsed_type parsed_agent
[[ "$parsed_repo" == project && "$parsed_doc" == docs/nested ]]
[[ "$raw_ar" == "$(abs_path "$HOME")" && "$parsed_type" == system && "$parsed_agent" == .agents ]]
status=0
docsconfig_read_into "$TEST_ROOT/missing" parsed_repo parsed_doc raw_ar parsed_type parsed_agent || status=$?
[[ "$status" == 1 && -z "$parsed_repo$parsed_doc$raw_ar$parsed_type$parsed_agent" ]]
status=0
docsconfig_read_into "$TEST_ROOT/input" 'bad-name' parsed_doc || status=$?
[[ "$status" == 2 ]]
printf '%s\n' 'REPO_DIR=$(printf injected)' 'DOC_DIR=`printf injected`' > "$TEST_ROOT/literal"
docsconfig_read_into "$TEST_ROOT/literal" parsed_repo parsed_doc
[[ "$parsed_repo" == '$(printf injected)' && "$parsed_doc" == '`printf injected`' ]]
for invalid in '' . .. /abs '~' '~/repo' nested/repo; do
  if docsconfig_validate_repo_dir "$invalid" >/dev/null 2>&1; then exit 1; fi
done
for invalid in '' . /abs '~' '~/docs' a/../b a/./b a//b; do
  if docsconfig_validate_doc_dir "$invalid" >/dev/null 2>&1; then exit 1; fi
done
docsconfig_validate_repo_dir 'project space'
docsconfig_validate_doc_dir docs/nested
for kind in application system solution company meta; do docsconfig_validate_knowledge_type "$kind"; done
if docsconfig_validate_knowledge_type unknown >/dev/null 2>&1; then exit 1; fi
[[ "$(docsconfig_format_root_for_write "$HOME")" == '~' ]]
[[ "$(docsconfig_format_root_for_write "$HOME/child")" == '~/child' ]]
expected="$(printf 'AGENT_ROOT=~\nAGENT_DIR=.agents\nREPO_DIR=project\nDOC_DIR=docs/nested\nKNOWLEDGE_TYPE=system')"
docsconfig_write "$TEST_ROOT/project" "$TEST_ROOT/project/docs/nested" docs/nested 0 "$HOME" system .agents
[[ "$(cat "$TEST_ROOT/project/.docsconfig")" == "$expected" ]]
docsconfig_write "$TEST_ROOT/project" "$TEST_ROOT/project/docs/nested" docs/nested 1 "$HOME" system .agents > "$TEST_ROOT/preview"
[[ "$(cat "$TEST_ROOT/project/.docsconfig")" == "$expected" ]]
[[ "$(cat "$TEST_ROOT/preview")" == "Would write $TEST_ROOT/project/.docsconfig:"$'\n'"$expected" ]]
docsconfig_write "$TEST_ROOT/project" "$TEST_ROOT/project/docs/nested" docs/nested 0 application
[[ "$(cat "$TEST_ROOT/project/.docsconfig")" == $'REPO_DIR=project\nDOC_DIR=docs/nested\nKNOWLEDGE_TYPE=application' ]]
if docsconfig_write "$TEST_ROOT/project" "$TEST_ROOT/project/docs/nested" docs >/dev/null 2>&1; then exit 1; fi
docsconfig_write_workspace "$TEST_ROOT/store" "$HOME" 1 > "$TEST_ROOT/workspace-preview"
[[ ! -e "$TEST_ROOT/store/configs" ]]
docsconfig_write_workspace "$TEST_ROOT/store" "$HOME"
[[ "$(cat "$TEST_ROOT/store/configs")" == 'WORK_SPACE=~' ]]
printf 'PASS: 配置解析、字段校验与序列化兼容\n'
