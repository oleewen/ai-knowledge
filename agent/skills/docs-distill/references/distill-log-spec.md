# 蒸馏日志规范

docs-distill 的增量蒸馏机制依赖 DISTILL-LOG，它同时承担两个职责：记录每次蒸馏结果，以及作为下次增量蒸馏的锚点来源。

**目录**：[日志文件位置](#日志文件位置) · [日志格式](#日志文件格式markdown-记录) · [changelog_id 确定规则](#changelog_id-的确定规则) · [增量范围逻辑](#增量范围确定逻辑优先级) · [写入时机](#日志写入时机) · [dry-run 规则](#dry-run-规则) · [示例](#示例)

---

## 日志文件位置

所有应用共用一个日志文件：

```
system/changelogs/DISTILL-LOG.md
```

首次蒸馏时自动创建；不存在则视为从未蒸馏，执行全量蒸馏。读取锚点时按 `app` 列过滤，取该应用最新一条记录。

---

## 日志文件格式（Markdown 记录）

```markdown
# DISTILL LOG

| app | changelog_id | changelog_time | distilled_at | summary |
|---|---|---|---|---|
| billing-appeal | v1.3.0 | 2026-04-05 10:00 | 2026-04-05T10:30:00+08:00 | overview distill |
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
3. `DISTILL-LOG.md` 中该 app 最新一条记录（默认增量）

```
if CHANGE-LOG.md 不存在:
    蒸馏范围 = 0（无输入，提示缺少变更源）

elif --full 参数:
    蒸馏范围 = CHANGE-LOG.md 全部条目

elif --since 参数指定:
    蒸馏范围 = CHANGE-LOG.md 中 since 之后的条目

elif DISTILL-LOG.md 存在且有该 app 的记录:
    last_id = DISTILL-LOG.md 中 app=当前应用 的最新一条 changelog_id
    蒸馏范围 = CHANGE-LOG.md 中 last_id 之后的所有条目
    若 last_id 在 CHANGE-LOG.md 中找不到 → 警告并请用户确认是否全量蒸馏

else:
    蒸馏范围 = CHANGE-LOG.md 全部条目（首次蒸馏）
```

---

## 日志写入时机

**overview 写入成功后才写入 DISTILL-LOG**（原子性保证）：

1. 完成 **`system/architecture/` 下本次批次涉及的全部写入**（按当前蒸馏规则落盘）
2. **最后**写入 `system/changelogs/DISTILL-LOG.md`（新记录最新在前）

若步骤 1 失败，不写入 DISTILL-LOG，下次重试时从同一位置开始，避免漏蒸馏。

---

## dry-run 规则

`--dry-run` 只输出计划动作与匹配到的变更范围：

- 不写入 `system/architecture/` 任何文件
- 不写入 `system/changelogs/DISTILL-LOG.md`

---

## 示例

```markdown
# DISTILL LOG

| app | changelog_id | changelog_time | distilled_at | summary |
|---|---|---|---|---|
| billing-appeal | v1.3.0 | 2026-04-05 10:00 | 2026-04-05T10:30:00+08:00 | overview distill |
| payment | v2.1.0 | 2026-04-01 09:00 | 2026-04-01T09:30:00+08:00 | overview distill |
| billing-appeal | v1.2.0 | 2026-03-20 14:00 | 2026-03-20T15:00:00+08:00 | overview distill |
```
