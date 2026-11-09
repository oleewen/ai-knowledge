#!/usr/bin/env bash
# 单目标联邦建联：解析与校验 → 内存计划 → 预览或写入。
set -euo pipefail

usage() {
  cat <<'EOF'
用法: bash docs-link.sh --link|--unlink|--check|--repair [--target <仓库根或已登记 remote URL>] [选项]

在源 Git 根执行；允许 company→solution、solution→system、system→application。
  --check         只读检查；无 target 时逐项检查全部 child。
  --repair        修复一个已登记槽位；必须指定 target，不支持 --all。
  --dry-run       只预览；repair 预览不创建目录或软链。
  --app-name 名   link 的槽位名称（三种目标层通用）；默认已有 name，再取目录名。
  --rewrite-http  仅 link：显式换父时改写目标 knowledge 中的旧 HTTP 前缀。
  --downgrade-http 仅 unlink：将核实到唯一 SSOT 的 HTTP 降为完整身份。
  --dependency-add|--dependency-remove --target <仓库根> --entity-id <完整ID>
                  消费登记增量增删；可重复 --entity-id，不建立槽位。
  --clear         仅 dependency-remove：明确清空目标登记，与 entity-id 互斥。
  --consumer-root <文档根> 追加已知消费范围，可重复。
  --resume <操作ID>         显式续办原计划，可搭配 --dry-run。
  --operation-check <操作ID> Git 集成后只读复核当前状态。
  --path          --target 的弃用别名；一次只能传一个目标。
  -h, --help      显示帮助，不读取工作区配置。

link/unlink 双边更新 knowledge-links.yaml；path 使用字面量 ${WORK_SPACE}/…。
check/repair 仅使用既有登记，不改清单、正文和 Git 状态；缺仓或身份不符时停止。
只管理槽位软链，普通目录/文件冲突时停止；HTTP 降级须显式授权参数。
写入持本机锁、核对指纹并记录操作；未完成操作须按 ID 续办，普通重跑停止。
失联注销或引用未闭环返回非零并保留操作记录。无 clone/pull/提交动作。
依赖 Bash 5+、Git、Python 3，以及元库或已安装 Agent 的 docs-core.sh。
EOF
}

die() { printf '错误: %s\n' "$*" >&2; exit 1; }
[[ "${BASH_VERSINFO[0]:-0}" -ge 5 ]] || die '需要 Bash 5+'
readonly FEDERATION_WRITE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts/tools" && pwd)/federation-write.py"
export KNOWLEDGE_VALIDATION_BASH="${BASH}" PYTHONDONTWRITEBYTECODE=1
for arg in "$@"; do
  case "$arg" in --dependency-add|--dependency-remove|--resume|--operation-check|--resume=*|--operation-check=*)
    exec python3 -B "$FEDERATION_WRITE" direct "$@" ;;
  esac
done
KNOWLEDGE_LINKS_V2=1
DRY=0 CMD='' TARGET_RAW='' CLI_NAME='' REWRITE_HTTP=0 DOWNGRADE_HTTP=0
baseline_args=() consumer_args=()
seen_target=0 seen_name=0
while (($#)); do
  case "$1" in
    --link|--unlink|--check|--repair)
      [[ -z "$CMD" ]] || die '只能指定一次 --link、--unlink、--check 或 --repair'
      CMD="${1#--}"; shift ;;
    --dry-run) DRY=1; shift ;;
    --rewrite-http) REWRITE_HTTP=1; shift ;;
    --downgrade-http) DOWNGRADE_HTTP=1; shift ;;
    --consumer-root)
      (($# >= 2)) && [[ -n "$2" && "$2" != --* ]] || die '缺少 --consumer-root'
      consumer_args+=(--consumer-root "$2"); shift 2 ;;
    --target|--path|--app-name|--target=*|--path=*|--app-name=*)
      flag="${1%%=*}"
      if [[ "$1" == *=* ]]; then value="${1#*=}"; shift
      else
        (($# >= 2)) || die "缺少 ${flag} 值"
        value="$2"; shift 2
      fi
      [[ -n "$value" && "$value" != --* ]] || die "缺少 ${flag} 值"
      if [[ "$flag" == --app-name ]]; then
        ((seen_name == 0)) || die '重复指定 --app-name'
        CLI_NAME="$value"; seen_name=1
      else
        ((seen_target == 0)) || die '一次只能指定一个 --target（含 --path 别名）'
        TARGET_RAW="$value"; seen_target=1
        [[ "$flag" != --path ]] || printf '警告: --path 已弃用，请改用 --target\n' >&2
      fi ;;
    -h|--help) usage; exit 0 ;;
    *) die "未知参数: $1" ;;
  esac
done
[[ "$DOWNGRADE_HTTP" == 0 || "$CMD" == unlink ]] || die '--downgrade-http 仅用于 --unlink'
[[ -n "$CMD" ]] || die '请指定 --link|--unlink|--check|--repair'
[[ "$CMD" == check || -n "$TARGET_RAW" ]] || die '此动作必须指定单个 --target'
[[ "$CMD" == link || ( "$REWRITE_HTTP" == 0 && "$seen_name" == 0 ) ]] \
  || die '--app-name / --rewrite-http 仅用于 --link'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=link-config.sh
source "$SCRIPT_DIR/link-config.sh"
source "$SCRIPT_DIR/link-maintenance.sh"

# DOC_DIR 必须真实落在本仓内；不能把外部目录悄悄改成同名本地目录。
doc_root_in_repo() {
  python3 -B - "$1" "$2" <<'PY'
from pathlib import Path
import sys
try:
    repo = Path(sys.argv[1]).resolve()
    doc = (repo / sys.argv[2]).resolve()
    doc.relative_to(repo)
    print(doc)
except (ValueError, OSError, RuntimeError) as exc:
    sys.exit(f'DOC_DIR 必须位于所属仓库内: {exc}')
PY
}

validate_name() {
  local value="${1,,}"
  [[ "$value" =~ ^[a-z0-9][a-z0-9_.-]*$ ]] || die "非法槽位 name: $1（仅 a-z0-9._-）"
  printf '%s\n' "$value"
}

# 共享读取器容许缺 repository/name；写出器要求必填，因此在任何写入前补齐校验。
load_entries() {
  local file="$1" prefix="$2" i parents=0
  baseline_args+=(--baseline "$file" "$(python3 -B "$FEDERATION_WRITE" fingerprint "$file")")
  [[ ! -L "$file" ]] || die "清单不能是软链: $file"
  [[ ! -e "$file" || -f "$file" ]] || die "清单不是普通文件: $file"
  if [[ -f "$file" ]]; then
    local -a vp=() vr=() vd=() vn=() vt=() ve=()
    maintenance_load "$file" v
    for i in "${!ve[@]}"; do
      [[ -z "${ve[i]}" ]] || die "清单条目非法: ${ve[i]} ($file)"
    done
  fi
  knowledge_links_load_into_arrays "$file" "${prefix}p" "${prefix}r" "${prefix}d" "${prefix}n" "${prefix}l" "${prefix}t"
  local -n entry_repos="${prefix}r" entry_paths="${prefix}p" entry_dirs="${prefix}d" entry_names="${prefix}n" entry_types="${prefix}t"
  local -A identities=() names=()
  for i in "${!entry_paths[@]}"; do
    [[ -n "${entry_repos[i]}" ]] || die "清单条目缺少 repository: $file"
    if [[ "${entry_types[i]}" != meta ]]; then
      knowledge_link_value_looks_like_git_remote "${entry_repos[i]}" || die "repository 须为 Git remote URL: $file"
    fi
    if [[ "${entry_types[i]}" != meta ]]; then
      [[ -n "${entry_names[i]}" && -n "${entry_dirs[i]}" ]] || die "清单条目缺少 name/dir: $file"
    fi
    if [[ "${entry_types[i]}" == parent ]]; then
      ((++parents)); ((parents <= 1)) || die "清单存在多个 parent: $file"
    elif [[ "${entry_types[i]}" == child ]]; then
      validate_name "${entry_names[i]}" >/dev/null
      local identity="$(git_remote_identity_key "${entry_repos[i]}")"
      [[ -z "${identities[$identity]:-}" && -z "${names[${entry_names[i],,}]:-}" ]] || die "child identity/name 重复: $file"
      identities[$identity]=1; names[${entry_names[i],,}]=1
    fi
  done
}

write_entries() {
  knowledge_links_write_entries "$1" "${2}r" "${2}p" "${2}d" "${2}n" "${2}l" "${2}t" "$3" "$4"
}

SRC_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || die '请在源 Git 仓库根执行'
SRC_ROOT="$(cd "$SRC_ROOT" && pwd -P)"
[[ "$(pwd -P)" == "$SRC_ROOT" ]] || die '当前 cwd 必须是源 Git 仓库根'
baseline_args+=(--baseline "$SRC_ROOT/.docsconfig" "$(python3 -B "$FEDERATION_WRITE" fingerprint "$SRC_ROOT/.docsconfig")")
srepo='' sdoc='' sdir='' sar='' skt='' sad=''
docsconfig_abs_for_config "$SRC_ROOT/.docsconfig" srepo sdoc sdir sar skt sad || die '无法解析源 .docsconfig'
case "$skt" in
  company) target_kind=solution; src_child=solution; src_parent=none; tgt_child=sys; tgt_parent=company ;;
  solution) target_kind=system; src_child=sys; src_parent=company; tgt_child=app; tgt_parent=solution ;;
  system) target_kind=application; src_child=app; src_parent=solution; tgt_child=app; tgt_parent=sys ;;
  *) die "源 KNOWLEDGE_TYPE=$skt 不支持建联（仅 company、solution、system）" ;;
esac
sdoc="$(doc_root_in_repo "$SRC_ROOT" "$sdoc")"
LIST_FILE="$sdoc/knowledge-links.yaml"
declare -a sr=() sp=() sd=() sn=() sl=() st=()
declare -a tr=() tp=() td=() tn=() tl=() tt=()
if [[ "$CMD" == check || "$CMD" == repair ]]; then
  # 维护只读既有登记；独立分流，不进入双边清单写出流程。
  maintenance_main
  exit $?
fi
load_entries "$LIST_FILE" s

# URL 只定位既有登记；实际访问仍用该条在源工作区展开的 path。
matched=-1
TGT_ROOT=''
if knowledge_link_value_looks_like_git_remote "$TARGET_RAW"; then
  for i in "${!sp[@]}"; do
    if [[ "${st[i]}" == child && "$(git_remote_identity_key "${sr[i]}")" == "$(git_remote_identity_key "$TARGET_RAW")" ]]; then
      matched=$i
      TGT_ROOT="$(knowledge_link_expand_stored_path "${sp[i]}" "$LIST_FILE")"
      break
    fi
  done
  [[ -n "$TGT_ROOT" ]] || die 'URL 未登记；首次建联请提供本地仓库根'
else
  TGT_ROOT="$(normalize_target_repo_root "$TARGET_RAW")"
  target_remote="$(knowledge_link_git_remote_url_prefer_origin "$TGT_ROOT" 2>/dev/null || true)"
  for i in "${!sp[@]}"; do
    [[ "${st[i]}" == child ]] || continue
    stored_root="$(knowledge_link_expand_stored_path "${sp[i]}" "$LIST_FILE")"
    if [[ "$(git_remote_identity_key "${sr[i]}")" == "$(git_remote_identity_key "$target_remote")" || "$stored_root" == "$TGT_ROOT" ]]; then
      matched=$i; break
    fi
  done
fi
if [[ "$CMD" == unlink && "$matched" == -1 ]]; then
  printf '未找到登记项，跳过: %s\n' "$TARGET_RAW"
  exit 0
fi

TGT_LINKS='' tdoc='' tdir='' target_available=0
if [[ -f "$TGT_ROOT/.docsconfig" ]]; then
  baseline_args+=(--baseline "$TGT_ROOT/.docsconfig" "$(python3 -B "$FEDERATION_WRITE" fingerprint "$TGT_ROOT/.docsconfig")")
  trepo='' tar='' tkt=''
  docsconfig_abs_for_config "$TGT_ROOT/.docsconfig" trepo tdoc tdir tar tkt || die '无法解析目标 .docsconfig'
  [[ "$tkt" == "$target_kind" ]] || die "目标须为 $target_kind（收到 $tkt）"
  tdoc="$(doc_root_in_repo "$TGT_ROOT" "$tdoc")"
  TGT_LINKS="$tdoc/knowledge-links.yaml"
  if [[ -e "$TGT_LINKS" || -L "$TGT_LINKS" ]]; then
    load_entries "$TGT_LINKS" t
    target_available=1
  fi
fi
if [[ "$CMD" == link ]]; then
  ((target_available)) || die '目标缺少 .docsconfig 或 knowledge-links.yaml；请先 docs-install'
  top="$(git -C "$TGT_ROOT" rev-parse --show-toplevel 2>/dev/null)" || die '目标不是 Git 仓库'
  [[ "$(cd "$top" && pwd -P)" == "$TGT_ROOT" ]] || die 'target 必须是目标 Git 根'
  target_remote="$(knowledge_link_git_remote_url_prefer_origin "$TGT_ROOT" || true)"
  [[ -n "$target_remote" ]] || die '目标仓库缺少 Git remote URL（repository 必填）'
  knowledge_link_value_looks_like_git_remote "$target_remote" || die '目标 repository 须为 Git remote URL'
fi
source_remote="$(knowledge_link_git_remote_url_prefer_origin "$SRC_ROOT" || true)"
target_identity="${target_remote:-}"
((matched < 0)) || target_identity="${sr[matched]}"
if [[ "$CMD" == link || "$target_available" == 1 ]]; then
  [[ -n "$source_remote" ]] || die '源仓库缺少 Git remote URL（parent.repository 必填）'
  knowledge_link_value_looks_like_git_remote "$source_remote" || die '源 repository 须为 Git remote URL'
fi
if [[ "$matched" != -1 && ( -d "$TGT_ROOT/.git" || -f "$TGT_ROOT/.git" ) ]]; then
  actual_remote="$(knowledge_link_git_remote_url_prefer_origin "$TGT_ROOT" || true)"
  [[ "$(git_remote_identity_key "$actual_remote")" == "$(git_remote_identity_key "${sr[matched]}")" ]] || die '目标本地仓 remote 与登记不符；先核对身份'
fi

old_name='' old_slot='' old_doc=''
if ((matched >= 0)); then
  old_name="${sn[matched]}"
  old_root="$(knowledge_link_expand_stored_path "${sp[matched]}" "$LIST_FILE")"
  old_doc="$(doc_root_in_repo "$old_root" "${sd[matched]}")"
fi
if [[ "$CMD" == link ]]; then
  name="$(validate_name "${CLI_NAME:-${old_name:-$(basename "$TGT_ROOT")}}")"
else
  name="$(validate_name "$old_name")"
fi
slots="$sdoc/$target_kind-slots"
slot="$slots/$target_kind-$name"
[[ -z "$old_name" || "$old_name" == "$name" ]] || old_slot="$slots/$target_kind-$old_name"

check_slot() {
  local path="$1" expected="$2" actual
  [[ ! -L "$slots" ]] || die "槽位父目录不能是软链: $slots"
  [[ ! -e "$slots" || -d "$slots" ]] || die "槽位父路径不是目录: $slots"
  if [[ -L "$path" ]]; then
    actual="$(readlink "$path")"
    [[ "$actual" == /* ]] || actual="$slots/$actual"
    actual="$(abs_path "$actual")"
    [[ "$actual" == "$expected" ]] || die "槽位指向另一目录，须先核对: $path"
  elif [[ -e "$path" ]]; then
    die "槽位被普通文件/目录占用，保留并停止: $path"
  fi
}
if [[ "$CMD" == link ]]; then
  for i in "${!sp[@]}"; do
    [[ "${st[i]}" != child || "$i" == "$matched" || "${sn[i],,}" != "$name" ]] || die "槽位名称已被其他 child 使用: $name"
  done
  expected="$tdoc"
  [[ "$name" != "$old_name" || -z "$old_doc" ]] || expected="$old_doc"
  check_slot "$slot" "$expected"
else
  check_slot "$slot" "$old_doc"
fi
[[ -z "$old_slot" ]] || check_slot "$old_slot" "$old_doc"

# 生成两侧输出；未命中的条目（含 meta、child、其他 parent）原字段保留。
declare -a nr=() np=() nd=() nn=() nl=() nt=()
rewrite_args=()
if ((target_available)); then
  for i in "${!tp[@]}"; do
    if [[ "${tt[i]}" == parent ]]; then
      if [[ "$CMD" == link ]]; then
        if ((REWRITE_HTTP)); then
          rewrite_args=(rewrite-http --doc-root "$tdoc" --old-repository "${tr[i]}" --old-path "${tp[i]}" --old-doc-dir "${td[i]}"
            --new-repository "$source_remote" --new-path "$(knowledge_link_stored_path_from_absolute "$SRC_ROOT" "$TGT_LINKS")" --new-doc-dir "$sdir")
        fi
        continue
      elif [[ "$(git_remote_identity_key "${tr[i]}")" == "$(git_remote_identity_key "$source_remote")" ]]; then
        continue
      fi
    fi
    nr+=("${tr[i]}"); np+=("${tp[i]}"); nd+=("${td[i]}"); nn+=("${tn[i]}"); nl+=("${tl[i]}"); nt+=("${tt[i]}")
  done
  if [[ "$CMD" == link ]]; then
    nr=("$source_remote" "${nr[@]}")
    np=("$(knowledge_link_stored_path_from_absolute "$SRC_ROOT" "$TGT_LINKS")" "${np[@]}")
    nd=("$sdir" "${nd[@]}"); nn=("$(basename "$SRC_ROOT")" "${nn[@]}")
    nl=("$(basename "$SRC_ROOT")" "${nl[@]}"); nt=(parent "${nt[@]}")
  fi
fi
if [[ "$CMD" == link ]]; then
  index=$matched
  ((index >= 0)) || index=${#sp[@]}
  sr[index]="$target_remote"
  sp[index]="$(knowledge_link_stored_path_from_absolute "$TGT_ROOT" "$LIST_FILE")"
  sd[index]="$tdir"; sn[index]="$name"; sl[index]="${sl[index]:-$name}"; st[index]=child
else
  unset 'sr[matched]' 'sp[matched]' 'sd[matched]' 'sn[matched]' 'sl[matched]' 'st[matched]'
  # 共享写出器要求连续下标。
  sr=("${sr[@]}"); sp=("${sp[@]}"); sd=("${sd[@]}"); sn=("${sn[@]}"); sl=("${sl[@]}"); st=("${st[@]}")
fi

# 同一计划同时用于预览与实跑预检；Python -B 保证预览不产生缓存。
(DRY=1; write_entries "$LIST_FILE" s "$src_child" "$src_parent")
if ((target_available)); then
  (DRY=1; write_entries "$TGT_LINKS" n "$tgt_child" "$tgt_parent")
else
  printf '警告: 目标失联或缺少清单，仅处理源登记与槽位；目标侧未更新: %s\n' "$TGT_ROOT" >&2
fi
rewrite_py=''
if ((${#rewrite_args[@]})); then
  # HTTP helper 会跟随 Markdown 文件软链；先校验其真实路径仍在 knowledge 内。
  python3 -B - "$tdoc" <<'PY'
from pathlib import Path
import sys
try:
    doc = Path(sys.argv[1]).resolve()
    knowledge = doc / 'knowledge'
    root = knowledge.resolve()
    root.relative_to(doc)
    for path in knowledge.rglob('*'):
        path.resolve().relative_to(root)
except (ValueError, OSError, RuntimeError) as exc:
    sys.exit(f'HTTP 改写路径越界或无法解析: {exc}')
PY
  for candidate in "$SCRIPT_DIR/../../docs-okf/scripts/okf_parent.py" "$sar/$sad/skills/docs-okf/scripts/okf_parent.py" "$HOME/.agents/skills/docs-okf/scripts/okf_parent.py"; do
    [[ -f "$candidate" ]] || continue
    rewrite_py="$candidate"; break
  done
  [[ -n "$rewrite_py" ]] || die '未找到 okf_parent.py'
  python3 -B "$rewrite_py" --dry-run "${rewrite_args[@]}"
fi
printf '[计划] identity=%s name=%s rewrite-http=%s\n' "$target_identity" "$name" "$REWRITE_HTTP"
if [[ "$CMD" == link ]]; then
  printf '[计划] 将确保软链: %s → %s\n' "$slot" "$tdoc"
  [[ -z "$old_slot" ]] || printf '[计划] 将移除旧名称软链: %s\n' "$old_slot"
else
  printf '[计划] 将移除槽位软链（若存在）: %s\n' "$slot"
fi
plan_args=(legacy --source "$sdoc" --action "$CMD" --slot "$slot" --old-slot "$old_slot" "${baseline_args[@]}" "${consumer_args[@]}")
((target_available == 0)) || plan_args+=(--target-doc "$tdoc")
for i in "${!sp[@]}"; do
  plan_args+=(--source-entry "${st[i]}" "${sr[i]}" "${sp[i]}" "${sd[i]}" "${sn[i]}" "${sl[i]}")
done
if ((target_available)); then
  for i in "${!np[@]}"; do
    plan_args+=(--target-entry "${nt[i]}" "${nr[i]}" "${np[i]}" "${nd[i]}" "${nn[i]}" "${nl[i]}")
  done
fi
((REWRITE_HTTP == 0)) || plan_args+=(--rewrite-http)
((DOWNGRADE_HTTP == 0)) || plan_args+=(--downgrade-http)
((DRY == 0)) || plan_args+=(--dry-run)
python3 -B "$FEDERATION_WRITE" "${plan_args[@]}"
