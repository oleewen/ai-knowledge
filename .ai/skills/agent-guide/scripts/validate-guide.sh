#!/usr/bin/env bash
#
# validate-guide.sh — 验证 README.md / AGENTS.md / INDEX 路径一致性
#
# 用法：
#   scripts/validate-guide.sh [--root <project-root>]
#
# 检查项：
#   1. INDEX 落盘路径是否存在
#   2. README.md 中引用的相对路径是否可达
#   3. AGENTS.md 中引用的相对路径是否可达
#   4. README 与 AGENTS 之间是否存在大段重复
#   5. AGENTS 首条参考是否指向实际 INDEX

set -euo pipefail

ROOT="${1:-.}"
ERRORS=0
WARNINGS=0

log_error() { echo "[ERROR] $1"; ((ERRORS++)); }
log_warn()  { echo "[WARN]  $1"; ((WARNINGS++)); }
log_ok()    { echo "[OK]    $1"; }

# --- 1. INDEX 落盘检测 ---

INDEX_PATH=""
for candidate in \
    "INDEX_GUIDE.md" \
    "system/INDEX_GUIDE.md" \
    "INDEX-GUIDE.md" \
    "system/INDEX-GUIDE.md"; do
    if [[ -f "$ROOT/$candidate" ]]; then
        INDEX_PATH="$candidate"
        break
    fi
done

if [[ -n "$INDEX_PATH" ]]; then
    log_ok "INDEX 落盘路径: $INDEX_PATH"
else
    log_error "未找到 INDEX 落盘文件（INDEX_GUIDE.md、system/INDEX_GUIDE.md、INDEX-GUIDE.md）"
fi

# --- 2. README.md 路径校验 ---

README="$ROOT/README.md"
if [[ -f "$README" ]]; then
    log_ok "README.md 存在"
    # 提取 markdown 链接中的相对路径（排除 http/https/mailto/#）
    while IFS= read -r link; do
        [[ -z "$link" ]] && continue
        resolved="$ROOT/$link"
        if [[ ! -e "$resolved" ]]; then
            log_warn "README.md 引用路径不存在: $link"
        fi
    done < <(grep -oP '\]\(\K[^)]+' "$README" 2>/dev/null \
             | grep -vE '^(https?://|mailto:|#)' \
             | sed 's/#.*//' \
             | sort -u)
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
    done < <(grep -oP '\]\(\K[^)]+' "$AGENTS" 2>/dev/null \
             | grep -vE '^(https?://|mailto:|#)' \
             | sed 's/#.*//' \
             | sort -u)

    # --- 5. AGENTS 首条参考指向 INDEX ---
    if [[ -n "$INDEX_PATH" ]]; then
        if grep -q "$INDEX_PATH" "$AGENTS" 2>/dev/null; then
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
    readme_lines=$(wc -l < "$README")
    agents_lines=$(wc -l < "$AGENTS")
    if [[ $readme_lines -gt 10 && $agents_lines -gt 10 ]]; then
        dup_lines=$(comm -12 \
            <(sed 's/^[[:space:]]*//' "$README" | grep -v '^$' | sort) \
            <(sed 's/^[[:space:]]*//' "$AGENTS" | grep -v '^$' | sort) \
            | wc -l)
        threshold=$(( (readme_lines < agents_lines ? readme_lines : agents_lines) / 4 ))
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
