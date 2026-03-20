# changelogs — 变更与索引运维（应用知识库根目录）

**元数据**：[changelogs_meta.yaml](./changelogs_meta.yaml)（目录级约定；字段以 YAML 为准）。

---

## 人类可读

- [CHANGELOG.md](./CHANGELOG.md) — **本应用**文档维护性变更（导航、约定、与中央库对齐的链接等）  
- 业务实体或知识条目的变更说明可写在提交信息或 ADR 中（ADR 见 `knowledge/constitution/adr/`）  

---

## 机器 / 工作流（可选）

与 **Slash 技能**（`SKILL.md`，**非** `scripts/` 可执行脚本）配合时使用（非日常编辑必跑）。路径相对于**仓库根**：

| 文件 | 用途 |
|------|------|
| `changes-index.json` / `changes-index.md` | **document-change Skill**（[../../../.cursor/skills/document-change/SKILL.md](../../../.cursor/skills/document-change/SKILL.md)）产出汇总 |
| `indexing-log.jsonl` | **document-indexing Skill**（[../../../.cursor/skills/document-indexing/SKILL.md](../../../.cursor/skills/document-indexing/SKILL.md)）运行记录 |

详见仓库根目录 [../../../README.md](../../../README.md) 命令表与 [../../../AGENTS.md](../../../AGENTS.md)。
