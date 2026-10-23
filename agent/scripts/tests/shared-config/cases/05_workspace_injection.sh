#!/usr/bin/env bash
set -euo pipefail

SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/lib/docsconfig.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shared-config-workspace.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
TEST_ROOT="$(cd "$TEST_ROOT" && pwd -P)"
mkdir -p "$TEST_ROOT/workspace/project/docs/nested" "$TEST_ROOT/agent-root/.agents"
printf 'WORK_SPACE="%s"\r\nWORK_SPACE=/ignored\n' "$TEST_ROOT/workspace" > "$TEST_ROOT/agent-root/.agents/configs"
printf 'AGENT_ROOT=%s\nAGENT_DIR=.agents\nREPO_DIR=project\nDOC_DIR=docs\nKNOWLEDGE_TYPE=application\n' "$TEST_ROOT/agent-root" > "$TEST_ROOT/workspace/project/.docsconfig"
[[ "$(docsconfig_read_workspace_raw "$TEST_ROOT/agent-root/.agents/configs")" == "$TEST_ROOT/workspace" ]]
WORK_SPACE=unchanged
actual_repo='' actual_doc='' actual_dir='' actual_agent_root='' actual_kind='' actual_agent_dir=''
docsconfig_abs_for_config "$TEST_ROOT/workspace/project/.docsconfig" actual_repo actual_doc actual_dir actual_agent_root actual_kind actual_agent_dir
[[ "$actual_repo" == "$TEST_ROOT/workspace/project" && "$actual_doc" == "$TEST_ROOT/workspace/project/docs" ]]
[[ "$actual_dir" == docs && "$actual_agent_root" == "$TEST_ROOT/agent-root" && "$actual_kind" == application && "$actual_agent_dir" == .agents ]]
[[ "$WORK_SPACE" == unchanged ]]
unset WORK_SPACE REPO_DIR DOC_DIR AGENT_ROOT AGENT_DIR KNOWLEDGE_TYPE
cd "$TEST_ROOT/workspace/project/docs/nested"
docsconfig_bootstrap_validate
[[ "$WORK_SPACE" == "$TEST_ROOT/workspace" && "$REPO_DIR" == project && "$DOC_DIR" == docs ]]
[[ "$AGENT_ROOT" == "$TEST_ROOT/agent-root" && "$AGENT_DIR" == .agents && "$KNOWLEDGE_TYPE" == application ]]
[[ "$(docsconfig_repo_abs)" == "$actual_repo" && "$(docsconfig_doc_abs)" == "$actual_doc" ]]
"$BASH" -c '[[ -z "${WORK_SPACE+x}${REPO_DIR+x}${DOC_DIR+x}${AGENT_ROOT+x}${AGENT_DIR+x}${KNOWLEDGE_TYPE+x}" ]]'
mkdir -p "$TEST_ROOT/workspace/other"
if docsconfig_validate_owner_matches_repo "$actual_repo" "$TEST_ROOT/workspace/other" >/dev/null 2>&1; then exit 1; fi
if docsconfig_load_workspace_abs "$TEST_ROOT/missing-root" .agents > "$TEST_ROOT/stdout" 2> "$TEST_ROOT/stderr"; then exit 1; fi
[[ ! -s "$TEST_ROOT/stdout" && "$(cat "$TEST_ROOT/stderr")" == *'/agent-install'* ]]
printf 'PASS: 工作区解析、当前 shell 注入与配置归属\n'
