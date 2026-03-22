# document-indexing — 参考细则

主流程见 [SKILL.md](SKILL.md)（文首 **符号约定**：本 Skill 节号 vs 产出物 `INDEX_GUIDE.md` 章号）。本文档供按需精读：JSONL 全字段、`INDEX_GUIDE.md` 文首模板、**Step 7** 基线清理、document-change 路径。

**实体 ID**：知识库 **四视角链上** ID（`BD-*`/`PL-*`/`SYS-*`/`DS-*` 等，**不含** DIR 联邦/宪法/阶段）见 **knowledge-build** 与 **`docs/knowledge/KNOWLEDGE_INDEX.md`**。

**主 `INDEX_GUIDE.md` 结构（policy-appeal 落地）**：**九章 + 附录** — **§1** 快速导航 → **§2** 项目结构 → **§3** 接口清单 → **§4** 领域模型 → **§5** 逻辑模型 → **§6** 数据模型（含 Mapper XML 路径索引）→ **§7** 配置索引 → **§8** 索引边界 → **§9** 相关文档 → **附录** 索引变更日志。实现侧类/路径速查见 **§3**、**§2.3**、**§6.3**（以仓库实际为准）。

---

## 1. `indexing-log.jsonl` 字段说明

每次执行在 `<索引日志目录>/indexing-log.jsonl` **追加 1 行** JSON（单行一条，稳定可解析）。

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `indexing_started_at_ms` | number | ✅ | 开始时刻 epoch ms |
| `indexing_finished_at_ms` | number | ✅ | 结束时刻 epoch ms |
| `data_mode` | `"full"` \| `"incremental"` | ✅ | 全量或增量 |
| `read_mode` | `1` \| `2` \| `3` | 建议 | 读取策略，与 SKILL **§6** Step 2.2 所选值及 Step 4「读取模式」表一致 |
| `base_indexing_finished_at_ms` | number | 增量时 | 上次索引结束时间（增量基准） |
| `index_output_path` | string | ✅ | 本次索引正文相对路径（默认 `./docs/INDEX_GUIDE.md` 等，见 document-indexing **SKILL §4.1**） |
| `changed_inputs` | string[] | 增量时建议 | 变更输入路径列表 |

**时间展示**：对用户展示及人类可读字段优先 `yyyy-MM-dd HH:mm:ss.SSS`；`*_ms` 供机器核对。

**日志文件路径写入索引正文**：可在 **`docs/INDEX_GUIDE.md` §2.4 文档结构** 的 `docs/` 树中标注 `docs/changelogs/indexing-log.jsonl`（或仓库实际路径），便于 Agent 回溯。

---

## 2. `INDEX_GUIDE.md` 文首元行（可选）

**本仓库惯例**（`docs/INDEX_GUIDE.md`）：

```markdown
# Policy Appeal 系统索引指南

> **最后更新**: yyyy-MM-dd  
> **文档定位**: AI Agent 与开发者的系统全景导航，按金字塔结构组织，遵循 MECE 原则
```

其它仓库可保留下列精简模板（与 document-indexing **SKILL §7** 所列 `INDEX_GUIDE.md` 九章模板独立，仅作生成时间/模式记录）：

```markdown
# 📘 AI 文档库精要索引指南

> 生成时间：[可读时间戳]  |  read_mode：[1/2/3]  |  索引覆盖率：[已索引数/估算总数或说明]
```

---

## 3. Step 7 基线清理（changes-index）

索引结束后清理 `changes-index.json` / `changes-index.md`，只保留滚动基线，避免文件膨胀：

- `baseline_time`: `yyyy-MM-dd HH:mm:ss.SSS`
- `baseline_time_ms`: epoch ms

**取值**：以本次 **document-change** 产出的「最后一个变更内容时间」为准；若无变更明细，保持原基线不变。

---

## 4. `document-change` 路径

按仓库内 [.cursor/skills/document-change/SKILL.md](../document-change/SKILL.md) 执行；产出目录与其「目录判定」一致。
