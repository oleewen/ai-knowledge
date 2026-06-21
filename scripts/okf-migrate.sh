#!/usr/bin/env bash
set -euo pipefail

# OKF 全量迁移编排：实体迁移 → frontmatter → index → 校验 → 可视化。
# 用法: bash scripts/okf-migrate.sh [--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE="${BUNDLE:-application}"
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

环境变量:
  BUNDLE   bundle 名称（默认 application）
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

repo_root="$(cd "$SCRIPT_DIR/.." && pwd)"
agent_home="$(cd "$SCRIPT_DIR/../agent" && pwd)"
bootstrap="${agent_home}/scripts/config-bootstrap.sh"
if [[ -f "$repo_root/.docsconfig" && -f "$bootstrap" ]]; then
  # shellcheck disable=SC1091
  source "$bootstrap"
  validate_bootstrap_docsconfig "$SCRIPT_DIR" || exit 1
  repo_root="${REPO_ROOT:-$repo_root}"
elif command -v git >/dev/null 2>&1; then
  git_root="$(git -C "$repo_root" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$git_root" ]] && repo_root="$git_root"
fi
REPO_ROOT="$repo_root"
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
echo "REPO_ROOT: ${REPO_ROOT}"
echo "BUNDLE:    ${BUNDLE}"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "MODE:      dry-run（仅打印命令）"
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
  --out "${BUNDLE}/viz.html" \
  --name "${BUNDLE} OKF"

echo ""
echo "=== okf-migrate 完成 ==="
