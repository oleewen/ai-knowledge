# docs-change 闸门与边界

与 [collection-rules.md](collection-rules.md)（采集细则）互补；**操作层易错点**见上级 [gotchas.md](../gotchas.md)。

---

## 适用边界与禁止产物

- **本技能负责**：从 Git、`CHANGELOG*` / `CHANGE-LOG.md`、本地 mtime 多源采集，聚合写入 `{output_dir}/CHANGE-LOG.md`，文末保留 `<!-- docs-change:baseline_time_ms=... -->` 供增量。
- **本技能不负责**：生成或更新 `INDEX_GUIDE.md`、修改知识实体、批量改写 `README.md` / `AGENTS.md`（这些走 **docs-indexing**、**docs-build** 等）。
- **分流**：用户明确只要全量/增量文档地图、只要 `INDEX_GUIDE` 时，以 **docs-indexing** 为主路径，不把「仅跑 docs-change」当作替代。

---

## 前置确认与歧义处理

**默认**：无歧义时不强制问答；按 [workflow.md](workflow.md) 与 [collection-rules.md](collection-rules.md) 直接执行。

在下列情况下**须先向用户确认**再继续：

- 时间基准不清（无 `--since`、无有效文末基线、且用户未说明范围）
- `--output` 存在多个合理候选且优先级可能不符合用户意图
- 用户要求**仅采集某一来源**（例如只要 Git、不要 CHANGELOG / 本地 mtime）

**执行侧约定**：

- **已确认仅 Git**：`git log` 仍用 `baseline_time`；不采集 CHANGELOG 条目与本地 mtime；`CHANGE-LOG.md` 中仅写入 Git 来源条目，文末基线注释仍按本轮聚合结果更新。
- **多候选输出目录**：以用户在前置确认中选择的目录为准；若用户未表态，则按 [collection-rules.md](collection-rules.md)「输出目录定位」优先级自动解析。

上级 [SKILL.md](../SKILL.md) 设有 **「前置确认（可选）」** 锚点，便于外部链接；细则以本节为准。
