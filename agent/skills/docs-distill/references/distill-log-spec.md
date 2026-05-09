# DISTILL-LOG

增量依赖本文件：既记结果，也当下次锚点。

## 位置

`system/changelogs/DISTILL-LOG.md`（全应用共用；首跑可创建）。读锚点：**按 `app` 过滤，取该 app 最新一条**。

## 表格式

```markdown
# DISTILL LOG

| app | changelog_id | changelog_time | distilled_at | summary |
|-----|----------------|----------------|--------------|---------|
| billing-appeal | v1.3.0 | 2026-04-05 10:00 | 2026-04-05T10:30:00+08:00 | overview distill |
```

## changelog_id 优先级

| 序 | 来源 | 例 |
| -- | ---- | -- |
| 1 | 标题版本号 | `v1.2.0` |
| 2 | 标题日期 | `2026-04-05` |
| 3 | 标题 slug | `add-billing-appeal-ms` |
| 4 | 行号兜底 | `line:42` |

建议 CHANGE-LOG 用 `## {版本} - {日期}`。

## 增量优先级

1. `--full`  
2. `--since`  
3. DISTILL-LOG 该 app 最新 `changelog_id`  
4. 无记录 → 视为首次，用 CHANGE-LOG 全量

**找不到锚点 id** → 警告，请用户修锚点 / `--since` / 授权全量，**勿静默**。

伪码：

```
无 CHANGE-LOG → 无输入，提示
--full → 全条目
--since → since 之后
有 DISTILL 记录 → last_id 之后；last_id 缺失则上同
否则 → 全条目（首次）
```

## 写入时机

**4.3（overview 第三列）全部成功后**再 4.4；本仓 `system/architecture/` 本轮写完后**最后**追加 DISTILL；新行**最前**。  
4.3 失败 → **不写** DISTILL，便于重试同位。

## dry-run

不碰 `system/architecture/**`、不写 DISTILL-LOG；只输出计划与匹配区间。

## 示例（多 app）

同表多行；按 `app` 各自取「文件内最新一条」为锚。
