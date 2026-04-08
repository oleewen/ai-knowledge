# 归档锚点规范

docs-archive 的增量归档机制依赖归档锚点文件，记录每次归档到的 changelog 位置，下次从该位置之后继续。

---

## 锚点文件位置

每个应用独立维护一个锚点文件：

```
system/application-{name}/changelogs/archive-log.yaml
```

首次归档时自动创建；不存在则视为从未归档，执行全量归档。

---

## 锚点文件格式

```yaml
schema_version: "1.0"
app_id: "{APP-ID}"
app_name: "{APPNAME}"

# 最近一次归档记录（最新在前）
last_archive:
  changelog_id: "{changelog 条目 ID 或标题锚点}"
  changelog_time: "{YYYY-MM-DD HH:mm}"
  archive_file: "system/architecture/changelogs/upstream-from-applications/ARCHIVE-{YYYYMMDD}-{简述}.md"
  archived_at: "{ISO-8601}"
  archived_entities:
    technical: {count}   # 本次归档的技术视角实体数
    data: {count}        # 数据视角
    business: {count}    # 业务视角
    product: {count}     # 产品视角

# 历史归档记录（追加，保留最近 10 条）
history:
  - changelog_id: "{...}"
    changelog_time: "{...}"
    archive_file: "{...}"
    archived_at: "{...}"
```

---

## changelog_id 的确定规则

`changelog_id` 是 `CHANGELOG.md` 中条目的唯一标识，按以下优先级确定：

| 优先级 | 来源 | 示例 |
|--------|------|------|
| 1 | 条目标题中的版本号 | `v1.2.0` |
| 2 | 条目标题中的日期 | `2026-04-05` |
| 3 | 条目标题的 slug（去除特殊字符） | `add-billing-appeal-ms` |
| 4 | 条目在文件中的行号（兜底） | `line:42` |

**推荐**：应用 CHANGELOG.md 使用 `## {版本号} - {日期}` 格式，便于精确定位。

---

## 增量范围确定逻辑

```
if archive-log.yaml 不存在 or --full 参数:
    归档范围 = CHANGELOG.md 全部条目

elif --since 参数指定:
    归档范围 = CHANGELOG.md 中 since 之后的条目

else:
    last_id = archive-log.yaml.last_archive.changelog_id
    归档范围 = CHANGELOG.md 中 last_id 之后的所有条目
    若 last_id 在 CHANGELOG.md 中找不到 → 警告并请用户确认是否全量归档
```

---

## 锚点更新时机

**归档写入成功后才更新锚点**（原子性保证）：

1. 完成 **`system/architecture/` 下本次批次涉及的全部写入**（不限于 `system/architecture/knowledge/`，须覆盖本次 `--scope` 与变更所触及的 solutions/analysis/requirements/specs、批次 changelog、以及需同步的 `INDEX_GUIDE` / 各 `README` 等）
2. 生成批次归档文档（`system/architecture/changelogs/upstream-from-applications/ARCHIVE-*.md`）
3. **最后**更新 `system/application-{name}/.../archive-log.yaml`

若步骤 1–2 任一失败，不更新锚点，下次重试时从同一位置开始，避免漏归档。

---

## 示例

```yaml
schema_version: "1.0"
app_id: "APP-BILLING-APPEAL"
app_name: "billing-appeal"

last_archive:
  changelog_id: "v1.3.0"
  changelog_time: "2026-04-05 10:00"
  archive_file: "system/architecture/changelogs/upstream-from-applications/ARCHIVE-20260405-billing-appeal.md"
  archived_at: "2026-04-05T10:30:00+08:00"
  archived_entities:
    technical: 3
    data: 2
    business: 1
    product: 0

history:
  - changelog_id: "v1.2.0"
    changelog_time: "2026-03-20 14:00"
    archive_file: "system/architecture/changelogs/upstream-from-applications/ARCHIVE-20260320-billing-appeal.md"
    archived_at: "2026-03-20T15:00:00+08:00"
```
