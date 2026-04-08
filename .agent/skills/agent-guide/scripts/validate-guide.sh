#!/usr/bin/env bash
#
# validate-guide.sh — 验证 README.md / AGENTS.md / INDEX 路径一致性
#
# 用法（自仓库根执行）：
#   bash .agent/skills/agent-guide/scripts/validate-guide.sh [--root <project-root>]
#
# 检查项：
#   1. INDEX 落盘路径是否存在
#   2. README.md 中引用的相对路径是否可达
#   3. AGENTS.md 中引用的相对路径是否可达
#   4. README 与 AGENTS 之间是否存在大段重复
#   5. AGENTS 首条参考是否指向实际 INDEX

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AI_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AI_HOME/scripts/docsconfig-bootstrap.sh"
validate_bootstrap_docsconfig "$SCRIPT_DIR"

DOC_ROOT="$(resolve_repo_doc_root "" "$REPO_ROOT")"

ROOT=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --root) ROOT="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$ROOT" ]]; then
    ROOT="$REPO_ROOT"
else
    ROOT="$(cd "$ROOT" && pwd)"
fi

ERRORS=0
WARNINGS=0

log_error() { echo "[ERROR] $1"; ERRORS=$((ERRORS + 1)); }
log_warn()  { echo "[WARN]  $1"; WARNINGS=$((WARNINGS + 1)); }
log_ok()    { echo "[OK]    $1"; }

# --- 1. INDEX 落盘检测（REPO_ROOT 优先，再 DOC_ROOT）---

DOC_SEG="${DOC_ROOT#"$REPO_ROOT"/}"
INDEX_PATH=""
for candidate in \
    "INDEX_GUIDE.md" \
    "INDEX-GUIDE.md" \
    "${DOC_SEG}/INDEX_GUIDE.md" \
    "${DOC_SEG}/INDEX-GUIDE.md" \
    "application/INDEX_GUIDE.md" \
    "application/INDEX-GUIDE.md"; do
    [[ -z "$candidate" ]] && continue
    if [[ -f "$ROOT/$candidate" ]]; then
        INDEX_PATH="$candidate"
        break
    fi
done

if [[ -n "$INDEX_PATH" ]]; then
    log_ok "INDEX 落盘路径: $INDEX_PATH"
else
    log_error "未找到 INDEX 落盘文件（INDEX_GUIDE.md、application/INDEX_GUIDE.md 等）"
fi

# --- 提取 markdown 文件中的相对路径链接 ---

extract_links() {
    local file="$1"
    # 提取 [text](path) 中的 path，排除外链和锚点
    grep -oE '\]\([^)]+\)' "$file" 2>/dev/null \
        | sed 's/^\]//' \
        | sed 's/^(//' \
        | sed 's/)$//' \
        | grep -vE '^(https?://|mailto:|#|ftp://)' \
        | sed 's/#.*//' \
        | grep -v '^[[:space:]]*$' \
        | sort -u
}

# --- 2. README.md 路径校验 ---

README="$ROOT/README.md"
if [[ -f "$README" ]]; then
    log_ok "README.md 存在"
    while IFS= read -r link; do
        [[ -z "$link" ]] && continue
        resolved="$ROOT/$link"
        if [[ ! -e "$resolved" ]]; then
            log_warn "README.md 引用路径不存在: $link"
        fi
    done < <(extract_links "$README")
else
    log_error "README.md 不存在"
fi

# --- 3. AGENTS.md 路径校验 ---

AGENTS="$ROOT/AGENTS.md"
if [[ -f "$AGENTS" ]]; then
    log_ok "AGENTS.md 存在"
    while IFS= read -r link; do
        [[ -z "$link" ]] && continue
        resolved="$ROOT/$link"
        if [[ ! -e "$resolved" ]]; then
            log_warn "AGENTS.md 引用路径不存在: $link"
        fi
    done < <(extract_links "$AGENTS")

    # --- 5. AGENTS 首条参考指向 INDEX ---
    if [[ -n "$INDEX_PATH" ]]; then
        if grep -qF "$INDEX_PATH" "$AGENTS" 2>/dev/null; then
            log_ok "AGENTS.md 引用了 INDEX: $INDEX_PATH"
        else
            log_warn "AGENTS.md 未引用当前 INDEX ($INDEX_PATH)"
        fi
    fi
else
    log_error "AGENTS.md 不存在"
fi

# --- 4. README 与 AGENTS 大段重复检测 ---

if [[ -f "$README" && -f "$AGENTS" ]]; then
    readme_lines=$(wc -l < "$README" | tr -d ' ')
    agents_lines=$(wc -l < "$AGENTS" | tr -d ' ')

    if [[ $readme_lines -gt 10 && $agents_lines -gt 10 ]]; then
        # 去除空行和纯空白行后比较
        dup_lines=$(comm -12 \
            <(sed 's/^[[:space:]]*//' "$README" | grep -v '^[[:space:]]*$' | sort) \
            <(sed 's/^[[:space:]]*//' "$AGENTS" | grep -v '^[[:space:]]*$' | sort) \
            | wc -l | tr -d ' ')

        min_lines=$(( readme_lines < agents_lines ? readme_lines : agents_lines ))
        threshold=$(( min_lines / 4 ))
        threshold=$(( threshold < 5 ? 5 : threshold ))

        if [[ $dup_lines -gt $threshold ]]; then
            log_warn "README 与 AGENTS 存在 ${dup_lines} 行重复内容（阈值 ${threshold}），请去重"
        else
            log_ok "README 与 AGENTS 重复度在可接受范围（${dup_lines}/${threshold}）"
        fi
    fi
fi

# --- 汇总 ---

echo ""
echo "========================================="
echo "验证完成: ${ERRORS} 错误, ${WARNINGS} 警告"
echo "========================================="

exit $ERRORS
