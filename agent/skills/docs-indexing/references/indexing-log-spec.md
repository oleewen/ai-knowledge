# 索引运行日志（INDEXING-LOG）

每次运行记录 + **下次 incremental 时间锚**。形近 [distill-log-spec.md](../../docs-distill/references/distill-log-spec.md)：主表、**新行在上**、先 INDEX 后 LOG。

节：位置 · 表格式 · `indexing_finished_ms` · 基线优先级 · 写入时机 · dry-run · HTML 回退 · 示例

---

## 日志文件位置

**每个 `DOC_DIR` 独立一份**（与「应用联邦」中每 context 自管 changelog 的边界一致，不做全库单文件）：

```
${DOC_DIR}/changelogs/INDEXING-LOG.md
```

例：`application/changelogs/INDEXING-LOG.md`。无存档 = 无锚点：增量时须让用户确认改走 full **或中止**，勿静默降级。

---

## 日志文件格式（Markdown 表记录）

- 文首 `# INDEXING-LOG`；说明：**锚点 = 主表分隔行后的第一行数据**。
- **新行插在表分隔行下、压在旧数据之上**（最新在上，同 DISTILL）。

表列固定如下（列顺序不可交换，便于脚本与人工对齐）：

| 列 | 说明 |
|----|------|
| `indexing_finished_ms` | 本次运行结束时的 epoch 毫秒，**主锚点**；必须为纯数字 |
| `indexed_at` | 结束时刻的 ISO 8601 时间，人类可读，建议 UTC（如 `2026-04-26T10:00:00Z`） |
| `mode` | `full` 或 `incremental` |
| `depth` | `1`、`2` 或 `3` |
| `since_ms` | 本 run 在增量时采用的基线（epoch ms）；全量时填 `0` |
| `output_path` | 本次写出的索引指南（如 `index.md` / `index.md`；或用户指定）相对 `DOC_DIR` 或仓库根的约定路径，与技能输出一致 |
| `file_count` | 本 run 统计或扫描涉及的文件数（与 `scan-spec`/实现约定一致，在 spec 中保持同一口径） |
| `duration_ms` | 本 run 耗时（毫秒） |
| `summary` | 可空；极短说明，如 `incremental depth3` |

```markdown
# INDEXING-LOG

> 由 **docs-indexing** 维护。增量基线取自主表**第一行**的 `indexing_finished_ms`（成功写索引后写入；最新在前）。

| indexing_finished_ms | indexed_at | mode | depth | since_ms | output_path | file_count | duration_ms | summary |
|---:|---|---|:---:|---:|---|---:|---:|---|
| 1714108800000 | 2026-04-26T10:00:00Z | incremental | 3 | 1714022400000 | ./index.md | 376 | 1200 | depth3 |
```

---

## 锚点列 `indexing_finished_ms`

- **唯一机器锚点**：从主表**第一行数据**读取 `indexing_finished_ms`。
- 解析失败（表缺失、无数据行、该格非正整数）→ 本文件**无有效锚点**；增量时须停下确认，不得臆造基线。

---

## 增量基线确定逻辑（优先级）

在**已选 `incremental` 且用户未强制全量**的前提下，**时间基线**按以下顺序确定（与 `distill-log-spec` 的「full > since > 日志」同构，索引侧无 `app` 过滤）：

1. **`--full`（或用户显式确认全量）**  
   不按 `INDEXING-LOG` 取时间基线；扫描范围以 `scan-spec`/技能为准作全量。

2. **显式 `--since`（epoch ms）**  
   以该值作为本 run 的变更时间基线，**不读取**表锚（与 distill 的 `--since` 优先一致）。

3. **主表第一行的 `indexing_finished_ms`（默认增量）**  
   作为「上次索引成功结束时间」，供与 `docs-change` 产出的变更时间对比，或驱动「仅处理变更子集」的路径集合。

4. **两者皆无**（无文件、无表、无有效首行）  
   判定为**无有效基线** → 按技能向用户说明，请改全量或中止；**不**自动全量。

伪代码（时间基线，非文件列表逻辑）：

```
if 用户/参数确认 full:
    基线 = 全量模式（不采用 INDEXING-LOG 的时间锚点）

elif 提供了 --since:
    基线 = since 的 epoch ms

elif INDEXING-LOG 主表存在且第一行 indexing_finished_ms 可解析:
    基线 = 该值

else:
    无有效基线 → 停下等待用户确认（不静默降级）
```

变更文件列表仍靠 `docs-change`/`CHANGE-LOG`；本文件只管**索引成功结束时间**。

---

## 写入时机

INDEX **成功落盘后**再写 LOG（先主产物、后总账）：

1. 写索引指南  
2. 再 `${DOC_DIR}/changelogs/INDEXING-LOG.md`（新行插顶）

若 1 败：不写 LOG，避免假进度。


---

## dry-run

与 distill 同理；脚本是否暴露 `--dry-run` 以实现为准。约束：不写 INDEX、不写 LOG；可打印拟插行与 `since`/基线摘要。

---

## HTML 回退（迁移期）

- 无主表或可解析首行：可全文找**最后**一条 `<!-- sdx-indexing:indexing_finished_ms=(\d+) -->`  
- 非 ms 注释不作锚  
- **新写入只用主表**；旧 Markdown 段落可归档在表下；真源**表第一行**

收紧后可 deprecate HTML 回退。

---

## 示例

```markdown
# INDEXING-LOG

> 由 **docs-indexing** 维护。增量基线取自主表**第一行**的 `indexing_finished_ms`。

| indexing_finished_ms | indexed_at | mode | depth | since_ms | output_path | file_count | duration_ms | summary |
|---:|---|---|:---:|---:|---|---:|---:|---|
| 1714200000000 | 2026-04-27T08:00:00Z | full | 3 | 0 | ./index.md | 400 | 3000 | regen full |
| 1714108800000 | 2026-04-26T10:00:00Z | incremental | 3 | 1714022400000 | ./index.md | 376 | 1200 | depth3 |
```

首行=最近成功 incremental 的默认基线以技能与 docs-change 语义为准。

---

## 与 DISTILL-LOG

| | DISTILL | INDEX |
|--|---------|-------|
| 文件 | 全库一单表+`app` | **每 DOC_DIR 一文件** |
| 锚 | 按 app 最新行 | 表首行 `indexing_finished_ms` |
| 插入 | 新在前 | 同 |
| 顺序 | 先主产物 | 先 INDEX |

下游读法**以本文**为准。
