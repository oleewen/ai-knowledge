# changelogs — 变更留痕与索引运维

本目录聚焦“变更可追溯性”，只记录日志与索引产物入口，不重复阶段文档写作规范。  
**元数据**： [changelogs_meta.yaml](changelogs_meta.yaml)

---

## 人类可读文件

- [CHANGELOG.md](CHANGELOG.md) — `system/` 层面的维护性变更记录（导航、规范、模板链路）
- 细粒度变更可放在提交信息或 ADR，不要求在此重复抄录

---

## 机器产物（可选）

以下文件通常由 Skill 生成，非日常编辑必跑：

| 文件 | 用途 |
|------|------|
| `changes-index.json` / `changes-index.md` | **docs-change Skill**（[../../.ai/skills/docs-change/SKILL.md](../../.ai/skills/docs-change/SKILL.md)）产出汇总 |
| `indexing-log.jsonl` | **docs-indexing Skill**（[../../.ai/skills/docs-indexing/SKILL.md](../../.ai/skills/docs-indexing/SKILL.md)）运行记录 |

命令清单与执行入口统一见 [../../.ai/skills/README.md](../../.ai/skills/README.md)。
