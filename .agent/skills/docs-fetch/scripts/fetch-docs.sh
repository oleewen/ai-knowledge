#!/usr/bin/env bash
set -euo pipefail

# docs-fetch — 从目标工程拉取知识库文档
#
# 职责：
#   1. git clone 目标工程到临时目录
#   2. 将 {docs_root}/ 内容同步到 applications/app-{APPNAME}/
#   3. 保护本地 changelogs/ 和 manifest 文件不被覆盖
#   4. 输出同步统计（新增/修改/删除文件数）供 Agent 生成 changelog
#
# 用法：
#   scripts/fetch-docs.sh \
#     --app APPNAME \
#     --repo https://github.com/org/repo.git \
#     --branch main \
#     --docs-root docs \
#     --target applications/app-APPNAME

# ── 参数解析 ──────────────────────────────────────────────────────────────────

APP=""
REPO_URL=""
BRANCH="main"
DOCS_ROOT="docs"
TARGET=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --app)       APP="$2";       shift 2 ;;
        --repo)      REPO_URL="$2";  shift 2 ;;
        --branch)    BRANCH="$2";    shift 2 ;;
        --docs-root) DOCS_ROOT="$2"; shift 2 ;;
        --target)    TARGET="$2";    shift 2 ;;
        --dry-run)   DRY_RUN=true;   shift ;;
        -h|--help)
            echo "Usage: $0 --app APPNAME --repo URL --branch BRANCH --docs-root PATH --target PATH [--dry-run]"
            exit 0 ;;
        *) echo "[ERROR] Unknown option: $1"; exit 1 ;;
    esac
done

# ── 参数校验 ──────────────────────────────────────────────────────────────────

if [[ -z "$APP" || -z "$REPO_URL" || -z "$TARGET" ]]; then
    echo "[ERROR] --app、--repo、--target 为必填参数"
    exit 1
fi

if [[ ! -d "$TARGET" ]]; then
    echo "[ERROR] 目标目录不存在: $TARGET"
    echo "        请先执行 docs-init --mode=central 完成应用注册"
    exit 1
fi

MANIFEST="${TARGET}/${APP}_manifest.yaml"
if [[ ! -f "$MANIFEST" ]]; then
    echo "[ERROR] manifest 文件不存在: $MANIFEST"
    echo "        请先执行 docs-init --mode=central 完成应用注册"
    exit 1
fi

echo "=== docs-fetch ==="
echo "  app        : $APP"
echo "  repo       : $REPO_URL"
echo "  branch     : $BRANCH"
echo "  docs_root  : $DOCS_ROOT"
echo "  target     : $TARGET"
echo "  dry_run    : $DRY_RUN"
echo ""

if $DRY_RUN; then
    echo "[DRY-RUN] 将执行以下操作："
    echo "  1. git clone --depth=1 --branch $BRANCH $REPO_URL <tmpdir>"
    echo "  2. 备份 $TARGET/changelogs/ 和 $MANIFEST"
    echo "  3. rsync <tmpdir>/$DOCS_ROOT/ -> $TARGET/"
    echo "  4. 恢复 changelogs/ 和 manifest"
    echo "  5. 更新 manifest 中的 last_fetched_* 字段"
    echo "  6. 输出同步统计"
    exit 0
fi

# ── 步骤 1：备份保护文件 ──────────────────────────────────────────────────────

BACKUP_DIR=$(mktemp -d)
trap "rm -rf $BACKUP_DIR" EXIT

echo "[INFO] 备份 changelogs/ 和 manifest..."
if [[ -d "$TARGET/changelogs" ]]; then
    cp -r "$TARGET/changelogs" "$BACKUP_DIR/changelogs"
fi
cp "$MANIFEST" "$BACKUP_DIR/$(basename "$MANIFEST")"

# ── 步骤 2：克隆目标工程 ──────────────────────────────────────────────────────

CLONE_DIR=$(mktemp -d)
trap "rm -rf $BACKUP_DIR $CLONE_DIR" EXIT

echo "[INFO] 克隆仓库 $REPO_URL (branch: $BRANCH)..."
if ! git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$CLONE_DIR" 2>&1; then
    echo "[ERROR] 克隆失败，请检查仓库地址和分支名"
    echo "        可用分支请执行: git ls-remote --heads $REPO_URL"
    exit 1
fi

# 获取提交信息
COMMIT_HASH=$(git -C "$CLONE_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
COMMIT_MSG=$(git -C "$CLONE_DIR" log -1 --format="%s" 2>/dev/null || echo "")
COMMIT_TIME=$(git -C "$CLONE_DIR" log -1 --format="%cI" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "[INFO] 最新提交: $COMMIT_HASH ($COMMIT_MSG)"

# ── 步骤 3：同步文档内容 ──────────────────────────────────────────────────────

SOURCE_DIR="$CLONE_DIR/$DOCS_ROOT"
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "[ERROR] 目标工程中未找到 docs_root 目录: $DOCS_ROOT"
    echo "        请检查 manifest 中的 docs_root 字段"
    exit 1
fi

echo "[INFO] 同步 $SOURCE_DIR -> $TARGET ..."

# 统计变更（使用 rsync --dry-run 先统计）
ADDED=0
MODIFIED=0
DELETED=0

if command -v rsync >/dev/null 2>&1; then
    # rsync 统计
    RSYNC_STATS=$(rsync -av --delete \
        --exclude="changelogs/" \
        --exclude="${APP}_manifest.yaml" \
        --dry-run \
        "$SOURCE_DIR/" "$TARGET/" 2>/dev/null || true)

    ADDED=$(echo "$RSYNC_STATS" | grep -c "^>f+++++++++" 2>/dev/null || echo "0")
    MODIFIED=$(echo "$RSYNC_STATS" | grep -c "^>f\." 2>/dev/null || echo "0")
    DELETED=$(echo "$RSYNC_STATS" | grep -c "^deleting " 2>/dev/null || echo "0")

    # 实际执行
    rsync -av --delete \
        --exclude="changelogs/" \
        --exclude="${APP}_manifest.yaml" \
        "$SOURCE_DIR/" "$TARGET/"
else
    # fallback: cp -r
    echo "[WARN] rsync 不可用，使用 cp -r（无法统计删除文件）"
    cp -r "$SOURCE_DIR/." "$TARGET/"
fi

# ── 步骤 4：恢复保护文件 ──────────────────────────────────────────────────────

echo "[INFO] 恢复 changelogs/ 和 manifest..."
if [[ -d "$BACKUP_DIR/changelogs" ]]; then
    rm -rf "$TARGET/changelogs"
    cp -r "$BACKUP_DIR/changelogs" "$TARGET/changelogs"
fi
cp "$BACKUP_DIR/$(basename "$MANIFEST")" "$MANIFEST"

# ── 步骤 5：更新 manifest 中的同步信息 ───────────────────────────────────────

NOW_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 更新或追加 last_fetched_* 字段
python3 - "$MANIFEST" "$BRANCH" "$COMMIT_HASH" "$NOW_ISO" <<'PYEOF'
import sys, re

manifest_path, branch, commit, fetched_at = sys.argv[1:]

with open(manifest_path, 'r') as f:
    content = f.read()

fields = {
    'last_fetched_at': fetched_at,
    'last_fetched_branch': branch,
    'last_fetched_commit': commit,
}

for key, value in fields.items():
    pattern = rf'^{key}:.*$'
    replacement = f'{key}: "{value}"'
    if re.search(pattern, content, re.MULTILINE):
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    else:
        content = content.rstrip('\n') + f'\n{replacement}\n'

with open(manifest_path, 'w') as f:
    f.write(content)
PYEOF

# ── 输出统计 ──────────────────────────────────────────────────────────────────

echo ""
echo "=== 同步完成 ==="
echo "  branch     : $BRANCH"
echo "  commit     : $COMMIT_HASH"
echo "  added      : $ADDED"
echo "  modified   : $MODIFIED"
echo "  deleted    : $DELETED"
echo "  synced_at  : $NOW_ISO"
echo ""
echo "FETCH_RESULT_BRANCH=$BRANCH"
echo "FETCH_RESULT_COMMIT=$COMMIT_HASH"
echo "FETCH_RESULT_COMMIT_MSG=$COMMIT_MSG"
echo "FETCH_RESULT_ADDED=$ADDED"
echo "FETCH_RESULT_MODIFIED=$MODIFIED"
echo "FETCH_RESULT_DELETED=$DELETED"
echo "FETCH_RESULT_SYNCED_AT=$NOW_ISO"
