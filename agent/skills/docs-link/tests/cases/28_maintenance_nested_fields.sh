#!/usr/bin/env bash
# 嵌套字段不得充当双边登记；检查与修复均须拒绝且零写入。
source "$(dirname "${BASH_SOURCE[0]}")/../test-lib.sh"
fixture_pair
run_link --link --target "$TGT" > "$TMP_DIR/out" 2>&1
cp "$SRC/docs/knowledge-links.yaml" "$TMP_DIR/source-list"
cp "$TGT/docs/knowledge-links.yaml" "$TMP_DIR/target-list"
slot="$SRC/docs/application-slots/application-target"
rm "$slot"
for scenario in source-wrapper source-nested-list target-fields; do
  cp "$TMP_DIR/source-list" "$SRC/docs/knowledge-links.yaml"
  cp "$TMP_DIR/target-list" "$TGT/docs/knowledge-links.yaml"
  python3 -B - "$SRC/docs/knowledge-links.yaml" "$TGT/docs/knowledge-links.yaml" "$scenario" <<'PY'
from pathlib import Path
import sys
source, target = map(Path, sys.argv[1:3])
scenario = sys.argv[3]
path = target if scenario == 'target-fields' else source
lines = path.read_text().splitlines()
entry = lines[next(i for i, line in enumerate(lines) if line.startswith('  - ')):]
if scenario == 'source-wrapper':
    text = 'links:\n  - metadata:\n      ' + entry[0][4:] + '\n'
    text += ''.join('  ' + line + '\n' for line in entry[1:])
elif scenario == 'source-nested-list':
    text = 'links:\n  - type: meta\n    metadata:\n'
    text += ''.join('    ' + line + '\n' for line in entry)
else:
    text = 'links:\n' + entry[0] + '\n    metadata:\n'
    text += ''.join('  ' + line + '\n' for line in entry[1:])
path.write_text(text)
PY
  for action in check repair; do
    if [[ "$action" == check ]]; then
      ln -s "$TGT/docs" "$slot"
    else
      rm "$slot"
    fi
    snapshot_pair > "$TMP_DIR/before"
    if run_link "--$action" --target "$TGT" > "$TMP_DIR/out" 2>&1; then
      fail "$scenario/$action 接受嵌套身份字段"
    fi
    snapshot_pair > "$TMP_DIR/after"
    cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail "$scenario/$action 修改了仓库"
  done
  if run_link --repair --target "$TGT" --dry-run > "$TMP_DIR/out" 2>&1; then
    fail "$scenario 预览接受嵌套身份字段"
  fi
  snapshot_pair > "$TMP_DIR/after"
  cmp "$TMP_DIR/before" "$TMP_DIR/after" || fail "$scenario 预览修改了仓库"
done
# 合法的平面字段保持可用，包括 YAML 允许的无缩进列表。
for file in source target; do
  python3 -B - "$TMP_DIR/$file-list" "$TMP_DIR/work space/$file/docs/knowledge-links.yaml" <<'PY'
from pathlib import Path
import sys
lines = Path(sys.argv[1]).read_text().splitlines()
Path(sys.argv[2]).write_text('\n'.join(line[2:] if line.startswith('  ') else line for line in lines) + '\n')
PY
done
run_link --repair --target "$TGT" > "$TMP_DIR/out" 2>&1
run_link --check > "$TMP_DIR/out" 2>&1
pass '拒绝嵌套登记且保留合法平面字段'
