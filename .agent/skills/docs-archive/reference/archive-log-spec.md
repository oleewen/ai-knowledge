# 归档锚点规范

docs-archive 的增量归档机制依赖归档锚点文件，记录每次归档到的 changelog 位置，下次从该位置之后继续。

---

## 锚点文件位置

每个应用独立维护一个锚点文件：

```
system/application-{name}/changelogs/ARCHIVE-LOG.md
```

首次归档时自动创建；不存在则视为从未归档，执行全量归档。

---

## 锚点文件格式（Markdown 记录）

```markdown
# ARCHIVE LOG - {APPNAME}

| changelog_id | changelog_time | archived_at |
|---|---|---|
| v1.3.0 | 2026-04-05 10:00 | 2026-04-05T10:30:00+08:00 |
```

---

## changelog_id 的确定规则

`changelog_id` 是 `CHANGE-LOG.md` 中条目的唯一标识，按以下优先级确定：

| 优先级 | 来源 | 示例 |
|--------|------|------|
| 1 | 条目标题中的版本号 | `v1.2.0` |
| 2 | 条目标题中的日期 | `2026-04-05` |
| 3 | 条目标题的 slug（去除特殊字符） | `add-billing-appeal-ms` |
| 4 | 条目在文件中的行号（兜底） | `line:42` |

**推荐**：应用 `CHANGE-LOG.md` 使用 `## {版本号} - {日期}` 格式，便于精确定位。

---

## 增量范围确定逻辑（优先级）

参数与锚点来源的优先级为：

1. `--full`（最高优先级）
2. `--since`
3. `ARCHIVE-LOG.md` 最后一条 marker（默认增量）

```
if CHANGE-LOG.md 不存在:
    归档范围 = 0（无输入，提示缺少变更源）

elif --full 参数:
    归档范围 = CHANGE-LOG.md 全部条目

elif --since 参数指定:
    归档范围 = CHANGE-LOG.md 中 since 之后的条目

elif ARCHIVE-LOG.md 存在且有 marker:
    last_id = ARCHIVE-LOG.md 最后一条记录的 changelog_id
    归档范围 = CHANGE-LOG.md 中 last_id 之后的所有条目
    若 last_id 在 CHANGE-LOG.md 中找不到 → 警告并请用户确认是否全量归档

else:
    归档范围 = CHANGE-LOG.md 全部条目（首次归档）
```

---

## 锚点更新时机

**归档写入成功后才更新锚点**（原子性保证）：

1. 完成 **`system/architecture/` 下本次批次涉及的全部写入**（按当前归档规则落盘）
2. 生成或追加批次归档文档（`system/changelogs/CHANGE-LOG.md`）
3. **最后**更新 `system/application-{name}/.../ARCHIVE-LOG.md`

若步骤 1–2 任一失败，不更新锚点，下次重试时从同一位置开始，避免漏归档。

---

## dry-run 规则

`--dry-run` 只输出计划动作与匹配到的变更范围：

- 不写入 `system/architecture/` 任何文件
- 不追加 `system/changelogs/CHANGE-LOG.md`
- 不更新 `system/application-{name}/changelogs/ARCHIVE-LOG.md`

---

## 示例

```markdown
# ARCHIVE LOG - billing-appeal

| changelog_id | changelog_time | archived_at |
|---|---|---|
| v1.2.0 | 2026-03-20 14:00 | 2026-03-20T15:00:00+08:00 |
| v1.3.0 | 2026-04-05 10:00 | 2026-04-05T10:30:00+08:00 |
```
