#!/usr/bin/env bash
# 编码、完整预检与单文件原子替换；所有写入仅临时夹具。
set -euo pipefail
SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$SCRIPTS_ROOT/test-core.sh"
source "$SCRIPTS_ROOT/docs-core.sh"
TMP_DIR="$(mktemp -d)"
TMP_DIR="$(cd "$TMP_DIR" && pwd -P)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/work/owner/docs" "$TMP_DIR/agent"
printf 'WORK_SPACE=%s\n' "$TMP_DIR/work" >"$TMP_DIR/agent/configs"
printf 'REPO_DIR=owner\nDOC_DIR=docs\nAGENT_ROOT=%s\nAGENT_DIR=agent\nKNOWLEDGE_TYPE=system\n' "$TMP_DIR" >"$TMP_DIR/work/owner/.docsconfig"
f="$TMP_DIR/work/owner/docs/knowledge-links.yaml"
declare -a paths=() repos=() dirs=() names=() labels=() types=()
reset_entries() {
  paths=('${WORK_SPACE}/child' '${WORK_SPACE}/other')
  repos=('https://example.test/child.git' 'https://example.test/other.git')
  dirs=(docs docs); names=(child other); labels=(child other); types=(child child)
}
write_entries() { knowledge_links_write_entries "$f" repos paths dirs names labels types app sys; }
seed_original() { printf '# keep exact bytes\nlinks: []\n' >"$f"; chmod 600 "$f"; cp -p "$f" "$TMP_DIR/original"; }
unchanged() {
  cmp -s "$f" "$TMP_DIR/original" || fail '失败写入改动原清单字节'
  [[ "$(python3 -c 'import os,stat,sys;print(stat.S_IMODE(os.stat(sys.argv[1]).st_mode))' "$f")" == 384 ]] || fail '失败写入改动原清单权限'
  [[ "$(find "$(dirname "$f")" -mindepth 1 -maxdepth 1 | wc -l)" -eq 1 ]] || fail '失败写入遗留临时文件'
}
codec_roundtrip() (
  reset_entries
  names[0]='child "quoted"'; labels[0]='back\slash "quoted" # literal'
  write_entries
  declare -a lp=() lr=() ld=() ln=() ll=() lt=()
  knowledge_links_load_into_arrays "$f" lp lr ld ln ll lt
  [[ "${ln[0]}" == "${names[0]}" && "${ll[0]}" == "${labels[0]}" ]] || fail 'writer/loader 引号和反斜杠未往返'
  [[ "$(_yaml_unquote "'it''s literal\\n'")" == "it's literal\\n" ]] || fail '单引号双写或裸反斜杠错误'
  [[ "$(_yaml_unquote 'literal\n # value')" == 'literal\n # value' ]] || fail '裸值字面内容被改写'
  for value in '"bad\n"' '"bad\q"' '"open' "'open" $'bad\tvalue' $'bad\nvalue' $'bad\rvalue'; do
    if _yaml_unquote "$value" >"$TMP_DIR/decoded"; then fail "非法标量未拒绝: $value"; fi
  done
)
preflight_preserves() (
  local kind="$1" dry="$2"
  reset_entries; seed_original
  case "$kind" in
    repository) repos[1]='' ;; name) names[1]='' ;; type) types[1]=wrong ;;
    scalar) labels[1]=$'invalid\nlabel' ;; array) unset 'repos[1]' ;;
  esac
  if (DRY="$dry" write_entries) >"$TMP_DIR/out" 2>&1; then fail "预检未拒绝 $kind (DRY=$dry)"; fi
  unchanged
)
io_failure_preserves() (
  local kind="$1"
  reset_entries; seed_original
  case "$kind" in
    temporary) mktemp() { return 71; } ;;
    render) printf() { if [[ "${1:-}" == '%srepository: "%s"\n' ]]; then return 72; fi; builtin printf "$@"; } ;;
    replace) python3() { if [[ "${2:-}" == *'/.knowledge-links.'* ]]; then return 73; fi; command python3 "$@"; } ;;
  esac
  if write_entries >"$TMP_DIR/out" 2>&1; then fail "未传播 $kind 失败"; fi
  unchanged
)
target_types() (
  reset_entries
  for kind in link broken directory fifo; do
    local dest="$TMP_DIR/work/owner/docs-$kind"
    mkdir -p "$dest"
    f="$dest/knowledge-links.yaml"
    case "$kind" in
      link) printf 'keep\n' >"$TMP_DIR/referent"; ln -s "$TMP_DIR/referent" "$f" ;;
      broken) ln -s "$TMP_DIR/missing" "$f" ;;
      directory) mkdir "$f" ;;
      fifo) mkfifo "$f" ;;
    esac
    if (write_entries) >"$TMP_DIR/out" 2>&1; then fail "writer 未拒绝末段 $kind"; fi
    if (DRY=1 write_entries) >"$TMP_DIR/out" 2>&1; then fail "dry-run 未拒绝末段 $kind"; fi
  done
  [[ "$(cat "$TMP_DIR/referent")" == keep ]] || fail 'writer 跟随软链改写了指向文件'
)
success_modes() (
  reset_entries; seed_original
  local old_umask before_trap
  old_umask="$(umask)"; before_trap="$(trap -p EXIT)"
  write_entries
  [[ "$(umask)" == "$old_umask" && "$(trap -p EXIT)" == "$before_trap" ]] || fail 'writer 改动调用方 umask/trap'
  [[ "$(python3 -c 'import os,stat,sys;print(stat.S_IMODE(os.stat(sys.argv[1]).st_mode))' "$f")" == 384 ]] || fail '成功替换丢失原权限'
  mkdir "$TMP_DIR/work/owner/physical"
  ln -s "$TMP_DIR/work/owner/physical" "$TMP_DIR/work/owner/alias"
  f="$TMP_DIR/work/owner/alias/knowledge-links.yaml"
  (umask 077; write_entries)
  [[ "$(python3 -c 'import os,stat,sys;print(stat.S_IMODE(os.stat(sys.argv[1]).st_mode))' "$f")" == 420 ]] || fail '新清单权限须为 0644'
)
failures=0
for check in codec_roundtrip target_types success_modes; do "$check" || failures=$((failures + 1)); done
for kind in repository name type scalar array; do
  for dry in 0 1; do preflight_preserves "$kind" "$dry" || failures=$((failures + 1)); done
done
for kind in temporary render replace; do io_failure_preserves "$kind" || failures=$((failures + 1)); done
((failures == 0)) || fail "清单 codec/atomic 回归失败: $failures 组"
pass '清单单行标量往返、完整预检、原子失败清理和权限契约'
