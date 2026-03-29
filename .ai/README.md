# `.ai` — AI 规范与技能

本目录存放 **SDD 阶段模板与工程规范**（`rules/`）以及 **Slash 技能**（`skills/`）。**Skills 为 `SKILL.md` 工作流，不是 `scripts/` 可执行脚本。** 根目录 `scripts/knowledge-init.sh` 初始化目标工程时，会将 `.ai/` 一并拷贝到目标项目的 `.ai/`，便于在任意仓库复用同一套文档与 Agent 契约。

---

## 目录结构

| 路径 | 说明 |
|------|------|
| [.ai/rules/CONVENTIONS.md](rules/CONVENTIONS.md) | 规范总索引：编码、设计、测试、解决方案/分析/需求/文档等子目录入口与摘要 |
| [.ai/skills/agent-guide/assets/agents-skeleton.md](skills/agent-guide/assets/agents-skeleton.md) | 根目录 `AGENTS.md` 推荐骨架（agent-guide） |
| [.ai/skills/](skills) | 各 Skill 的 `SKILL.md`（Slash 命令实现与流程说明） |
| [.ai/skills/README.md](skills/README.md) | **Slash 命令一览**（`/document-indexing`、`/knowledge-build` 等） |

---

## 与仓库其他文档的关系

- **人类与 Agent 总契约**：根目录 [AGENTS.md](../AGENTS.md)
- **权威路径地图**：根目录 [INDEX_GUIDE.md](../INDEX_GUIDE.md)（七段 Index Guide）
- **系统知识库治理**：[system/DESIGN.md](../system/DESIGN.md)、[system/CONTRIBUTING.md](../system/CONTRIBUTING.md)
- **Slash 命令表**：以 [.ai/skills/README.md](skills/README.md) 为准（本仓库权威路径为 `.ai/skills/`）。

> **路径说明**：历史文档或旧拷贝可能写作「`.ai/CONVENTIONS.md`」；本仓库规范索引的权威路径为 **`.ai/rules/CONVENTIONS.md`**（与上表 [.ai/rules/CONVENTIONS.md](rules/CONVENTIONS.md) 一致）。

---

## 修改约定（精要）

- 勿在未评估影响面的情况下大改模板结构；与 `system/knowledge` 的 **ID 引用链** 保持一致。
- 提交信息建议遵循 Conventional Commits，描述用中文或中英文均可，与团队习惯一致（见 [.ai/rules/coding/git-guidelines.md](rules/coding/git-guidelines.md)）。

更完整的禁止项与查阅顺序见 [AGENTS.md](../AGENTS.md)。
