#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"

FIXTURE="$(new_fake_home)"
trap 'rm -rf "$FIXTURE"' EXIT
make_meta_fixture "$FIXTURE/meta"
for skill in docs-agent docs-archive docs-merge docs-revise docs-simplify sdx-test; do
  cp -R "$ROOT_DIR/agent/skills/$skill" "$FIXTURE/meta/agent/skills/"
done
development=(
  docs-agent/test-validate-guide.sh
  docs-archive/run_evals.py
  docs-archive/codex_adapter.py
  docs-merge/evaluate.py
  docs-revise/score_evals.py
  docs-simplify/eval_case.py
)
runtime=(docs-agent/scripts/validate-guide.sh sdx-test/scripts/validate-test.sh)
TEST_PYTHON="$(command -v python3)"
snapshot() {
  "$TEST_PYTHON" - "$1" <<'PY'
import hashlib, json, os, sys
from pathlib import Path
root = Path(sys.argv[1])
result = {}
for path in sorted(root.rglob('*')):
    key = str(path.relative_to(root))
    if path.is_symlink():
        result[key] = ['link', os.readlink(path)]
    elif path.is_file():
        result[key] = ['file', hashlib.sha256(path.read_bytes()).hexdigest()]
    else:
        result[key] = ['directory']
print(json.dumps(result, sort_keys=True))
PY
}

modes=(fallback)
if command -v rsync >/dev/null; then
  modes=(native fallback)
else
  printf '[SKIP] rsync 不可用，native 路径未覆盖；继续验证 cp fallback\n'
fi
mkdir -p "$FIXTURE/bin"
for tool in dirname basename date mkdir cp mv rm ln readlink find sed tr cat rg; do
  ln -s "$(command -v "$tool")" "$FIXTURE/bin/$tool"
done
original_path="$PATH"
for mode in "${modes[@]}"; do
  for phase in fresh upgrade; do
    sandbox="$FIXTURE/$mode-$phase"
    mkdir -p "$sandbox"
    if [[ "$phase" == upgrade ]]; then
      for entry in "${development[@]}"; do
        skill="${entry%%/*}" file="${entry#*/}"
        mkdir -p "$sandbox/.agents/skills/$skill/scripts"
        printf 'old development entry\n' >"$sandbox/.agents/skills/$skill/scripts/$file"
      done
    fi
    if [[ "$mode" == fallback ]]; then export PATH="$FIXTURE/bin"; else export PATH="$original_path"; fi
    before="$(snapshot "$sandbox")"
    run_agent_install "$sandbox" --meta "$FIXTURE/meta" --scope=a --agents=codex --dry-run >"$FIXTURE/$mode-$phase-preview" 2>&1
    [[ "$(snapshot "$sandbox")" == "$before" ]] || fail 'dry-run 修改了安装目标'
    run_agent_install "$sandbox" --meta "$FIXTURE/meta" --scope=a --agents=codex >"$FIXTURE/$mode-$phase-output" 2>&1
    for entry in "${development[@]}"; do
      skill="${entry%%/*}" file="${entry#*/}"
      for location in scripts tests; do
        assert_file_not_exists "$sandbox/.agents/skills/$skill/$location/$file"
      done
    done
    for entry in "${runtime[@]}"; do
      assert_file_exists "$sandbox/.agents/skills/$entry"
      assert_file_exists "$sandbox/.codex/skills/$entry"
    done
  done
done
export PATH="$original_path"
pass "六个真实研发入口不安装；已验证 ${modes[*]} 首装/升级清除旧入口、保留运行验证器、预览不写入"
