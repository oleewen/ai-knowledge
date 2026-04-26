# 索引运行日志规范

docs-indexing 的增量索引机制依赖各文档根下的 `INDEXING-LOG.md`，同时承担两个职责：记录每次索引运行结果，以及作为**下一次增量扫描的时间锚点**来源。形态与 [docs-distill 的 `distill-log-spec.md`](../../docs-distill/reference/distill-log-spec.md) 对齐：主表、**新记录最新在前**、单一真源、先主产物后日志。

**目录**：[日志文件位置](#日志文件位置) · [日志格式](#日志文件格式markdown-表记录) · [锚点列](#锚点列-indexing_finished_ms) · [增量基线确定逻辑（优先级）](#增量基线确定逻辑优先级) · [写入时机](#日志写入时机) · [dry-run 规则](#dry-run-规则) · [兼容旧版 Markdown 节与 HTML 注释](#兼容旧版-markdown-节与-html-注释) · [示例](#示例)

---

## 日志文件位置

**每个 `DOC_DIR` 独立一份**（与「应用联邦」中每 context 自管 changelog 的边界一致，不做全库单文件）：

```
${DOC_DIR}/changelogs/INDEXING-LOG.md
```

例如：`application/changelogs/INDEXING-LOG.md`、`system/changelogs/INDEXING-LOG.md`。首次成功索引并写日志时自动创建；文件不存在时视为**尚无有效索引锚点**——以技能门禁为准：增量前提不满足时须请用户确认改走全量或中止，**不得静默自动降级**（与当前 `docs-indexing` 契约一致）。

---

## 日志文件格式（Markdown 表记录）

- 文首为 `# INDEXING-LOG` 与简短说明：**增量锚点 = 下表第一行数据**（表头、对齐行之下第一条 `|` 行）。
- **主表**为唯一规范结构；**新行插在表分隔行 `|---|...|` 之后、旧数据第一行之前**，使**最新成功运行始终在第一行**（与 `DISTILL-LOG` 插入规则一致）。

表列固定如下（列顺序不可交换，便于脚本与人工对齐）：

| 列 | 说明 |
|----|------|
| `indexing_finished_ms` | 本次运行结束时的 epoch 毫秒，**主锚点**；必须为纯数字 |
| `indexed_at` | 结束时刻的 ISO 8601 时间，人类可读，建议 UTC（如 `2026-04-26T10:00:00Z`） |
| `mode` | `full` 或 `incremental` |
| `depth` | `1`、`2` 或 `3` |
| `since_ms` | 本 run 在增量时采用的基线（epoch ms）；全量时填 `0` |
| `output_path` | 本次写出的 `INDEX_GUIDE.md`（或用户指定）相对 `DOC_DIR` 或仓库根的约定路径，与技能输出一致 |
| `file_count` | 本 run 统计或扫描涉及的文件数（与 `scan-spec`/实现约定一致，在 spec 中保持同一口径） |
| `duration_ms` | 本 run 耗时（毫秒） |
| `summary` | 可空；极短说明，如 `incremental depth3` |

```markdown
# INDEXING-LOG

> 由 **docs-indexing** 维护。增量基线取自主表**第一行**的 `indexing_finished_ms`（成功写索引后写入；最新在前）。

| indexing_finished_ms | indexed_at | mode | depth | since_ms | output_path | file_count | duration_ms | summary |
|---:|---|---|:---:|---:|---|---:|---:|---|
| 1714108800000 | 2026-04-26T10:00:00Z | incremental | 3 | 1714022400000 | ./INDEX_GUIDE.md | 376 | 1200 | depth3 |
```

---

## 锚点列 `indexing_finished_ms`

- **唯一机器锚点**：从主表**第一行数据**读取 `indexing_finished_ms`。
- 解析失败（表缺失、无数据行、该格非正整数）→ 本文件**无有效锚点**；增量须走门禁，不得臆造基线。

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
    无有效基线 → 停在与用户确认的门禁（不静默降级）
```

**说明**：变更文件列表仍依赖 `docs-change` 与 `CHANGE-LOG.md`；`INDEXING-LOG` 只解决「索引运行自身」的**成功边界时间**，与 `distill` 中「蒸馏批次对应变更区间」角色对称。

---

## 日志写入时机

**`INDEX_GUIDE.md`（或等效已确认输出）落盘成功之后**再写 `INDEXING-LOG`（原子性，对齐 distill：先主产物、后总账）：

1. 完成 `INDEX_GUIDE.md` 的生成与写盘
2. **最后**更新 `${DOC_DIR}/changelogs/INDEXING-LOG.md`（新行插于表内、最新在前）

若步骤 1 失败，不写入 `INDEXING-LOG`，下次重试仍使用旧表锚，避免「记了日志但未产出索引」的假进度。

---

## dry-run 规则

与 distill 的 dry-run 精神一致；具体是否由脚本单独暴露 `--dry-run` 以技能/脚本实现为准。约束为：

- 不写入/覆盖 `INDEX_GUIDE.md`（或等效输出）
- 不写入 `${DOC_DIR}/changelogs/INDEXING-LOG.md`
- 可打印**拟插入表行**与**将采用的 `since`/`基线` 来源**的摘要，供用户确认

---

## 兼容旧版 Markdown 节与 HTML 注释

迁移期允许实现**只读**回退，避免一次性手工改坏多份历史文件：

- 若主表**不存在**或**无法从第一行解析** `indexing_finished_ms`：可回退为扫描全文、取**最后一次**匹配成功的 `<!-- sdx-indexing:indexing_finished_ms=(\d+) -->`（与旧 `indexing.sh` 行为一致）。
- `<!-- indexing_finished_time=... -->` 等**非 ms**注释**不得**作为锚点；无 ms 时视为无有效锚点，走全量/中止门禁。
- 新写入的日志**仅**采用**主表**形式，不依赖文末 HTML 注释；历史「## 运行记录 — …」可保留在表下方为只读档案，或迁移后由运维删除；**以表第一行为准**。

在新文件与所有引用更新完成后，可移除对 HTML 回退的依赖（实现与文档同时收紧）。

---

## 示例

```markdown
# INDEXING-LOG

> 由 **docs-indexing** 维护。增量基线取自主表**第一行**的 `indexing_finished_ms`。

| indexing_finished_ms | indexed_at | mode | depth | since_ms | output_path | file_count | duration_ms | summary |
|---:|---|---|:---:|---:|---|---:|---:|---|
| 1714200000000 | 2026-04-27T08:00:00Z | full | 3 | 0 | ./INDEX_GUIDE.md | 400 | 3000 | regen full |
| 1714108800000 | 2026-04-26T10:00:00Z | incremental | 3 | 1714022400000 | ./INDEX_GUIDE.md | 376 | 1200 | depth3 |
```

第一行是最近一次成功运行；`incremental` 的下一默认基线为 `1714200000000`（以技能与 `docs-change` 的变更时间语义为准）。

---

## 与 DISTILL-LOG 的对位关系

| 维度 | DISTILL-LOG | INDEXING-LOG（本规范） |
|------|-------------|------------------------|
| 文件粒度的 | 全库单文件，用 `app` 列区分 | **每 `DOC_DIR` 一文件**（无 `app` 列） |
| 锚点 | 按 `app` 取最新行 `changelog_id` / 行序 | 全表**第一行** `indexing_finished_ms`（该文件即单 scope） |
| 插入方向 | 最新在前 | 最新在前（同） |
| 主产物后写日志 | 是 | 是（先 `INDEX_GUIDE` 后本文件） |
| dry-run 不写日志 | 是 | 是 |

若下游技能（`agent-guide`、`docs-build`）引用 `INDEXING-LOG` 的读法，**以本规范**为准更新说明。
