# changelogs — 变更与索引运维

**元数据**：[applications/app-APPNAME/changelogs/changelogs_meta.yaml](changelogs_meta.yaml) — 单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers`（`key`: human → index_ops）。

---

## 人类可读

- [applications/app-APPNAME/changelogs/CHANGELOG.md](CHANGELOG.md) — **本应用联邦单元**维护性变更（导航、约定、模板链接等）；中央库见 [system/changelogs/](../../../system/changelogs)  
- 业务实体或知识条目的变更说明可写在提交信息或 ADR 中  

---

## 机器 / 工作流（可选）

与 **Slash 技能**（`SKILL.md`，**非** `scripts/` 可执行脚本）配合时使用（非日常编辑必跑）：

| 文件 | 用途 |
|------|------|
| `changes-index.json` / `changes-index.md` | **document-change Skill**（[.ai/skills/document-change/SKILL.md](../../../.ai/skills/document-change/SKILL.md)）产出汇总 |
| `indexing-log.jsonl` | **document-indexing Skill**（[.ai/skills/document-indexing/SKILL.md](../../../.ai/skills/document-indexing/SKILL.md)）运行记录 |

详见仓库根目录 [README.md](../../../README.md) 命令表与 [AGENTS.md](../../../AGENTS.md)（Skill 以 `.ai/skills/` 为权威路径）。
