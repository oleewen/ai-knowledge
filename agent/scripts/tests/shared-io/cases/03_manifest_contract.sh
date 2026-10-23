#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
source "$SCRIPTS_ROOT/docs-core.sh"
TMP_DIR="$(mktemp -d)"
TMP_DIR="$(cd "$TMP_DIR" && pwd -P)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/work space/owner/docs" "$TMP_DIR/agent"
printf 'WORK_SPACE=%s\n' "$TMP_DIR/work space" >"$TMP_DIR/agent/configs"
printf 'REPO_DIR=owner\nDOC_DIR=docs\nAGENT_ROOT=%s\nAGENT_DIR=agent\nKNOWLEDGE_TYPE=system\n' "$TMP_DIR" >"$TMP_DIR/work space/owner/.docsconfig"
f="$TMP_DIR/work space/owner/docs/knowledge-links.yaml"
declare -a paths=('stale') repos=('stale') dirs=('stale') names=('stale') labels=('stale') types=('stale')
knowledge_links_load_into_arrays "$f" paths repos dirs names labels types
[[ "${#paths[@]}:${#repos[@]}:${#dirs[@]}:${#names[@]}:${#labels[@]}:${#types[@]}" == 0:0:0:0:0:0 ]] || fail '缺文件未清空全部数组'
paths=('${WORK_SPACE}/child repo' '${WORK_SPACE}/meta')
repos=('https://example.test/child.git' 'git@example.test:meta.git')
dirs=(docs application) names=('child name' ignored) labels=('child label' ignored) types=(child meta)
DRY=1
knowledge_links_write_entries "$f" repos paths dirs names labels types app sys 2>"$TMP_DIR/err"
[[ ! -e "$f" ]] || fail '清单 DRY=1 不应落盘'
assert_contains '（2 条 links）' "$TMP_DIR/err"
unset DRY
DRY_RUN=1
knowledge_links_write_entries "$f" repos paths dirs names labels types app sys
[[ -f "$f" ]] || fail '清单写入不应受 IO DRY_RUN 影响'
assert_contains 'path: "${WORK_SPACE}/child repo"' "$f"
WORK_SPACE='/unrelated/environment'
knowledge_links_load_into_arrays "$f" paths repos dirs names labels types
[[ "${paths[0]}" == '${WORK_SPACE}/child repo' && "${paths[1]}" == '${WORK_SPACE}/meta' ]] || fail 'loader 展开或改写字面占位符'
[[ "${repos[0]}" == 'https://example.test/child.git' && "${dirs[1]}" == application ]] || fail 'loader 字段未对齐'
[[ "${names[0]}:${labels[0]}:${types[0]}" == 'child name:child label:child' && -z "${names[1]}${labels[1]}" && "${types[1]}" == meta ]] || fail 'child/meta 字段漂移'
[[ "$(knowledge_link_expand_stored_path "${paths[0]}" "$f")" == "$TMP_DIR/work space/child repo" ]] || fail '清单工作区错误读取环境 WORK_SPACE'
printf 'links: []\n' >"$f"
knowledge_links_load_into_arrays "$f" paths repos dirs names labels types
[[ "${#paths[@]}:${#repos[@]}:${#dirs[@]}:${#names[@]}:${#labels[@]}:${#types[@]}" == 0:0:0:0:0:0 ]] || fail '空清单未清空全部数组'
for api in git_remote_url_prefer_origin knowledge_link_git_remote_url_prefer_origin; do
  declare -F "$api" >/dev/null || fail "清单门面缺失 Git API: $api"
done
pass '清单数组重置、字面占位符、所属配置与 DRY 契约保持'
