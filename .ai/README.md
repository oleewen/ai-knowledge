# `.ai` — AI 规范与技能

本目录存放 **SDD 阶段模板与工程规范**（`rules/`）以及 **Slash 技能**（`skills/`）。**Skills 为 `SKILL.md` 工作流，不是 `scripts/` 可执行脚本。** 根目录 `scripts/sdx-init.sh` 初始化目标工程时，会将 `.ai/` 一并拷贝到目标项目的 `.ai/`，便于在任意仓库复用同一套文档与 Agent 契约。

---

## 目录结构

| 路径 | 说明 |
|------|------|
| [`rules/CONVENTIONS.md`](rules/CONVENTIONS.md) | 规范总索引：编码、设计、测试、解决方案/分析/需求/文档等子目录入口与摘要 |
| [`rules/agents-template.md`](rules/agents-template.md) | Agent 说明模板参考 |
| [`skills/`](skills/) | 各 Skill 的 `SKILL.md`（Slash 命令实现与流程说明） |
| [`skills/README.md`](skills/README.md) | **Slash 命令一览**（`/document-indexing`、`/knowledge-build` 等） |

---

## 与仓库其他文档的关系

- **人类与 Agent 总契约**：根目录 [`AGENTS.md`](../AGENTS.md)
- **权威路径地图**：根目录 [`INDEX_GUIDE.md`](../INDEX_GUIDE.md)（七段 Index Guide；[`PROJECT_INDEX.md`](../PROJECT_INDEX.md) 为兼容短入口）
- **系统知识库治理**：[`system/DESIGN.md`](../system/DESIGN.md)、[`system/CONTRIBUTING.md`](../system/CONTRIBUTING.md)
- **编辑器侧入口**：Cursor 下见 [`.cursor/README.md`](../.cursor/README.md)，与 `skills/` 镜像；Slash 命令表以 [`skills/README.md`](skills/README.md) 为准。

> **路径说明**：部分文档仍写作「`.ai/CONVENTIONS.md`」；当前仓库中规范索引文件为 **`rules/CONVENTIONS.md`**。

---

## 修改约定（精要）

- 勿在未评估影响面的情况下大改模板结构；与 `system/knowledge` 的 **ID 引用链** 保持一致。
- 提交信息建议遵循 Conventional Commits，描述用中文或中英文均可，与团队习惯一致（见 `rules/coding/git-guidelines.md`）。

更完整的禁止项与查阅顺序见 [`AGENTS.md`](../AGENTS.md)。
