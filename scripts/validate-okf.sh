#!/usr/bin/env bash
set -euo pipefail

# OKF bundle 校验入口。默认 bundle=application；路径可经 .docsconfig 解析仓库根。
# 用法: bash scripts/validate-okf.sh [--bundle NAME]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE="${BUNDLE:-application}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bundle)
      [[ $# -ge 2 ]] || {
        echo "缺少 --bundle 参数值" >&2
        exit 1
      }
      BUNDLE="$2"
      shift 2
      ;;
    --bundle=*)
      BUNDLE="${1#*=}"
      shift
      ;;
    -h | --help)
      cat <<EOF
用法: bash scripts/validate-okf.sh [--bundle NAME]

校验 OKF bundle（frontmatter、full_id、链接、index 条目）。
默认 bundle=application；存在 .docsconfig 时 REPO_ROOT 取自配置。

环境变量:
  BUNDLE   覆盖默认 bundle 名
EOF
      exit 0
      ;;
    *)
      echo "未知参数: $1（支持 --bundle NAME）" >&2
      exit 1
      ;;
  esac
done

sdx_okf_resolve_repo_root() {
  local script_dir="$1"
  local repo_root
  repo_root="$(cd "$script_dir/.." && pwd)"
  local agent_home bootstrap
  agent_home="$(cd "$script_dir/../agent" && pwd)"
  bootstrap="${agent_home}/scripts/config-bootstrap.sh"
  if [[ -f "$repo_root/.docsconfig" && -f "$bootstrap" ]]; then
    # shellcheck disable=SC1091
    source "$bootstrap"
    validate_bootstrap_docsconfig "$script_dir" || return 1
    repo_root="${REPO_ROOT:-$repo_root}"
  elif command -v git >/dev/null 2>&1; then
    local git_root
    git_root="$(git -C "$repo_root" rev-parse --show-toplevel 2>/dev/null || true)"
    [[ -n "$git_root" ]] && repo_root="$git_root"
  fi
  printf '%s' "$repo_root"
}

REPO_ROOT="$(sdx_okf_resolve_repo_root "$SCRIPT_DIR")" || exit 1

cd "$REPO_ROOT" || exit 1

echo "=== validate-okf ==="
echo "REPO_ROOT: ${REPO_ROOT}"
echo "BUNDLE:    ${BUNDLE}"
echo ""

python3 "$REPO_ROOT/scripts/okf/validate_bundle.py" --bundle "$BUNDLE" --repo "$REPO_ROOT"
