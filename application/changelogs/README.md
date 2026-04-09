# changelogs — 变更留痕与索引运维

本目录聚焦「变更可追溯性」，只约定 **Markdown 形态**的日志与索引产物入口，不重复阶段文档写作规范。  
**元数据**： [changelogs_meta.yaml](changelogs_meta.yaml)

---

## 日志文件（仅下列 Markdown）

| 文件 | 用途 |
|------|------|
| [CHANGE-LOG.md](CHANGE-LOG.md) | 维护性变更记录与 **docs-change** 聚合结果；文末 `<!-- docs-change:baseline_time_ms=... -->` 为增量基线 |
| [INDEXING-LOG.md](INDEXING-LOG.md) | **docs-indexing** 运行记录（按次追加）；文末 `<!-- sdx-indexing:indexing_finished_ms=... -->` 为增量基线 |

---

## Skill 指针

| Skill | 说明 |
|-------|------|
| [docs-change](../../.agent/skills/docs-change/SKILL.md) | 聚合 git / CHANGELOG / 本地 mtime，**写入/更新** `CHANGE-LOG.md`（Markdown） |
| [docs-indexing](../../.agent/skills/docs-indexing/SKILL.md) | 生成 `INDEX_GUIDE.md`，**追加** `INDEXING-LOG.md`（Markdown） |

命令清单与执行入口统一见 [../../.agent/skills/README.md](../../.agent/skills/README.md)。
