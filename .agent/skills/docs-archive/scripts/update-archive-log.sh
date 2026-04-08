#!/usr/bin/env bash
set -euo pipefail

# update-archive-log.sh — 更新应用归档锚点文件
#
# 职责：
#   1. 读取现有 archive-log.yaml（不存在则初始化）
#   2. 将本次归档记录追加到 history（保留最近 10 条）
#   3. 更新 last_archive 为本次归档信息
#
# 用法：
#   scripts/update-archive-log.sh \
#     --app APPNAME \
#     --app-id APP-MYSERVICE \
#     --changelog-id v1.3.0 \
#     --changelog-time "2026-04-05 10:00" \
#     --archive-file "system/architecture/changelogs/upstream-from-applications/ARCHIVE-20260405-xxx.md" \
#     --entities-technical 3 \
#     --entities-data 2 \
#     --entities-business 1 \
#     --entities-product 0

# ── 参数解析 ──────────────────────────────────────────────────────────────────

APP=""
APP_ID=""
CHANGELOG_ID=""
CHANGELOG_TIME=""
ARCHIVE_FILE=""
ENT_TECHNICAL=0
ENT_DATA=0
ENT_BUSINESS=0
ENT_PRODUCT=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --app)                  APP="$2";              shift 2 ;;
        --app-id)               APP_ID="$2";           shift 2 ;;
        --changelog-id)         CHANGELOG_ID="$2";     shift 2 ;;
        --changelog-time)       CHANGELOG_TIME="$2";   shift 2 ;;
        --archive-file)         ARCHIVE_FILE="$2";     shift 2 ;;
        --entities-technical)   ENT_TECHNICAL="$2";    shift 2 ;;
        --entities-data)        ENT_DATA="$2";         shift 2 ;;
        --entities-business)    ENT_BUSINESS="$2";     shift 2 ;;
        --entities-product)     ENT_PRODUCT="$2";      shift 2 ;;
        -h|--help)
            echo "Usage: $0 --app APPNAME --app-id APP-ID --changelog-id ID --changelog-time TIME --archive-file PATH [--entities-* N]"
            exit 0 ;;
        *) echo "[ERROR] Unknown option: $1"; exit 1 ;;
    esac
done

# ── 参数校验 ──────────────────────────────────────────────────────────────────

if [[ -z "$APP" || -z "$CHANGELOG_ID" || -z "$ARCHIVE_FILE" ]]; then
    echo "[ERROR] --app、--changelog-id、--archive-file 为必填参数"
    exit 1
fi

LOG_FILE="system/application-${APP}/changelogs/archive-log.yaml"
NOW_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ── 更新锚点文件 ──────────────────────────────────────────────────────────────

python3 - "$LOG_FILE" "$APP" "$APP_ID" "$CHANGELOG_ID" "$CHANGELOG_TIME" \
    "$ARCHIVE_FILE" "$NOW_ISO" \
    "$ENT_TECHNICAL" "$ENT_DATA" "$ENT_BUSINESS" "$ENT_PRODUCT" <<'PYEOF'
import sys, os, yaml
from datetime import datetime

log_file = sys.argv[1]
app      = sys.argv[2]
app_id   = sys.argv[3] or f"APP-{app.upper()}"
cl_id    = sys.argv[4]
cl_time  = sys.argv[5]
arc_file = sys.argv[6]
now_iso  = sys.argv[7]
ent_tech = int(sys.argv[8])
ent_data = int(sys.argv[9])
ent_biz  = int(sys.argv[10])
ent_prod = int(sys.argv[11])

# 读取现有文件或初始化
if os.path.exists(log_file):
    with open(log_file, 'r') as f:
        data = yaml.safe_load(f) or {}
else:
    data = {}

# 初始化结构
data.setdefault('schema_version', '1.0')
data['app_id']   = app_id
data['app_name'] = app
data.setdefault('history', [])

# 将旧的 last_archive 移入 history
if 'last_archive' in data and data['last_archive']:
    data['history'].insert(0, data['last_archive'])

# 保留最近 10 条历史
data['history'] = data['history'][:10]

# 更新 last_archive
data['last_archive'] = {
    'changelog_id':   cl_id,
    'changelog_time': cl_time,
    'archive_file':   arc_file,
    'archived_at':    now_iso,
    'archived_entities': {
        'technical': ent_tech,
        'data':      ent_data,
        'business':  ent_biz,
        'product':   ent_prod,
    }
}

# 写回文件
os.makedirs(os.path.dirname(log_file), exist_ok=True)
with open(log_file, 'w') as f:
    yaml.dump(data, f, allow_unicode=True, default_flow_style=False, sort_keys=False)

print(f"[OK] 归档锚点已更新: {log_file}")
print(f"     changelog_id = {cl_id}")
print(f"     archived_at  = {now_iso}")
PYEOF
