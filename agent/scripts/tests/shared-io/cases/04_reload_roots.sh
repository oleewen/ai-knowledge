#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
for root in A B; do
  mkdir -p "$TMP_DIR/$root"
  cp -R "$SCRIPTS_ROOT/lib" "$TMP_DIR/$root/lib"
  cp "$SCRIPTS_ROOT/docs-core.sh" "$TMP_DIR/$root/docs-core.sh"
done
# 在每份副本对应职责末尾放入可观察实现，检验换根确实刷新函数。
python3 - "$TMP_DIR" <<'PY'
from pathlib import Path
import sys
for root, status in [('A', 11), ('B', 12)]:
    lib = Path(sys.argv[1], root, 'lib')
    modules = [
        ('logging.sh', 'log-io.sh', f'log() {{ printf "{root}:%s\\n" "$*" >&2; }}\n'),
        ('file-io.sh', 'log-io.sh', f'io_should_overwrite() {{ return {status}; }}\n'),
        ('knowledge-link-paths.sh', 'knowledge-links.sh', f'knowledge_link_value_looks_like_git_remote() {{ return {status}; }}\n'),
        ('knowledge-links-yaml.sh', 'knowledge-links.sh', f'_yaml_unquote() {{ printf "{root}:%s" "$1"; }}\n'),
    ]
    for preferred, fallback, definition in modules:
        path = lib / preferred
        if not path.exists():
            path = lib / fallback
        with path.open('a') as stream:
            stream.write('\n' + definition)
PY
for root in A B; do
  unset _AGENT_SHARED_DOCS_CONFIG_LOADED
  source "$TMP_DIR/$root/docs-core.sh"
  [[ "$(log marker 2>&1)" == "$root:marker" ]] || fail "$root 日志函数未重载"
  [[ "$(_yaml_unquote value)" == "$root:value" ]] || fail "$root YAML 函数未重载"
  expected=11
  [[ "$root" == A ]] || expected=12
  rc=0
  io_should_overwrite target || rc=$?
  [[ "$rc" -eq "$expected" ]] || fail "$root IO 函数未重载"
  rc=0
  knowledge_link_value_looks_like_git_remote value || rc=$?
  [[ "$rc" -eq "$expected" ]] || fail "$root 路径函数未重载"
done
pass '只 unset 聚合哨兵即可从 A 重载 B 的四组实现'
