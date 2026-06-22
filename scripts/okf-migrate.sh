#!/usr/bin/env bash
set -euo pipefail

# OKF 全量迁移编排：实体迁移 → frontmatter → index → 校验 → 可视化。
# 用法: bash scripts/okf-migrate.sh [--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_HOME="$(cd "$SCRIPT_DIR/../agent" && pwd)"
RESOLVE="${AGENT_HOME}/skills/docs-okf/scripts/resolve-okf-paths.sh"
BUNDLE="${BUNDLE:-}"
BUNDLE_OVERRIDE=0
[[ -n "$BUNDLE" ]] && BUNDLE_OVERRIDE=1
DRY_RUN=0

PERSPECTIVES=(business product application data technical)

usage() {
  cat <<EOF
用法: bash scripts/okf-migrate.sh [--dry-run]

按序执行 OKF 全量迁移（可重复运行）：
  1. migrate_entities（五视角，缺 *-entities.md 则跳过）
  2. inject_frontmatter
  3. generate_index（--recursive）
  4. generate_knowledge_index
  5. validate-okf
  6. visualize

须有效 .docsconfig（含 KNOWLEDGE_TYPE）。bundle 默认取自 DOC_DIR；viz 输出取自 KNOWLEDGE_TYPE。

环境变量:
  BUNDLE   覆盖 .docsconfig 推导的 bundle（DOC_DIR）
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1（支持 --dry-run）" >&2
      exit 1
      ;;
  esac
done

# shellcheck disable=SC1091
source "$RESOLVE"
resolve_okf_paths "$SCRIPT_DIR"

if [[ "$BUNDLE_OVERRIDE" -eq 0 ]]; then
  BUNDLE="$OKF_BUNDLE"
elif [[ "$BUNDLE" != "$OKF_BUNDLE" ]]; then
  echo "[okf] BUNDLE 已由环境变量覆盖为 ${BUNDLE}（.docsconfig DOC_DIR=${DOC_DIR}）" >&2
fi

OKF_DIR="$REPO_ROOT/scripts/okf"

run_cmd() {
  local desc="$1"
  shift
  echo ""
  echo "=== ${desc} ==="
  echo ">>> $*"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    "$@"
  fi
}

cd "$REPO_ROOT"

echo "=== okf-migrate ==="
echo "REPO_ROOT:      ${REPO_ROOT}"
echo "DOC_DIR:        ${DOC_DIR}"
echo "KNOWLEDGE_TYPE: ${KNOWLEDGE_TYPE}"
echo "BUNDLE:         ${BUNDLE}"
echo "OKF_VIZ_OUT:    ${OKF_VIZ_OUT}"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "MODE:           dry-run（仅打印命令）"
fi

for perspective in "${PERSPECTIVES[@]}"; do
  entities_rel="${BUNDLE}/knowledge/${perspective}/${perspective}-entities.md"
  entities_path="${REPO_ROOT}/${entities_rel}"
  if [[ ! -f "$entities_path" ]]; then
    echo ""
    echo "=== migrate_entities (${perspective}): skip（缺少 ${entities_rel}）==="
    continue
  fi
  migrate_args=(
    "$OKF_DIR/migrate_entities.py"
    --bundle "$BUNDLE"
    --entities "$entities_rel"
    --perspective "$perspective"
  )
  if [[ "$DRY_RUN" -eq 1 ]]; then
    migrate_args+=(--dry-run)
  fi
  run_cmd "migrate_entities (${perspective})" python3 "${migrate_args[@]}"
done

inject_args=(
  "$OKF_DIR/inject_frontmatter.py"
  --bundle "$BUNDLE"
)
if [[ "$DRY_RUN" -eq 1 ]]; then
  inject_args+=(--dry-run)
fi
run_cmd "inject_frontmatter" python3 "${inject_args[@]}"

index_args=(
  "$OKF_DIR/generate_index.py"
  --bundle "$BUNDLE"
  --recursive
)
if [[ "$DRY_RUN" -eq 1 ]]; then
  index_args+=(--dry-run)
fi
run_cmd "generate_index" python3 "${index_args[@]}"

knowledge_index_args=(
  "$OKF_DIR/generate_knowledge_index.py"
  --bundle "$BUNDLE"
)
if [[ "$DRY_RUN" -eq 1 ]]; then
  knowledge_index_args+=(--dry-run)
fi
run_cmd "generate_knowledge_index" python3 "${knowledge_index_args[@]}"

run_cmd "validate-okf" bash "$REPO_ROOT/scripts/validate-okf.sh" --bundle "$BUNDLE"

run_cmd "visualize" python3 \
  "$OKF_DIR/visualize.py" \
  --bundle "$BUNDLE" \
  --out "$OKF_VIZ_OUT" \
  --name "$OKF_VIZ_NAME"

echo ""
echo "=== okf-migrate 完成 ==="
