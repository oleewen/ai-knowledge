# `agent` 目录说明

`agent/` 是本仓库的 AI 协作控制层，负责沉淀可复用的规则、模板与技能工作流。  
它回答的是“如何协作与交付”，而不是“业务知识本体”。

## 职责边界

- `rules/`：编码、设计、测试、文档等协作规范与闸门总表入口。
- `references/`：跨 Skill 协议（意图澄清、单元推进、轻流程动作、grilling、布局、会话工作稿路径）。
- `knowledge/`：知识库治理 SSOT（命名、术语、原则、ADR；原 `*/constitution/`）。
- `skills/`：以 `SKILL.md` 为核心的工作流定义。
- `agent/scripts/`：与 Skill 配套的共享 Bash 库。
- `scripts/`（仓库根）：初始化与分发工具链，把 `agent/` 与知识库模板同步到目标项目。

> `skills/` = 流程定义；仓库根 `scripts/` = 环境初始化；`agent/scripts/` = 技能脚本共享库。

## 结构导览

| 路径 | 用途 |
| --- | --- |
| [rules/CONVENTIONS.md](rules/CONVENTIONS.md) | 规则总入口与产出协议总表 |
| [knowledge/README.md](knowledge/README.md) | 知识治理 SSOT |
| [references/](references) | 跨 Skill 契约（澄清 / 推进环 / 轻流程动作 / 烤干 / 布局 / 工作稿路径） |
| [skills/README.md](skills/README.md) | Slash 命令清单（权威） |
| [scripts/](scripts) | 共享 Bash 库（路径与 `.docsconfig` 解析等；细节见各脚本头注释） |
| [skills/docs-agent/assets/agents-skeleton.md](skills/docs-agent/assets/agents-skeleton.md) | `AGENTS.md` 推荐骨架 |

## 与全仓库文档关系

- 总体协作契约：仓库根 `AGENTS.md`
- 九章地图：`INDEX-GUIDE.md`；目录索引：`index.md`
- 知识库建模：各文档根下 `DESIGN.md` / `CONTRIBUTING.md`（如 `application/`）

## 维护原则

- 增量更新，不破坏既有目录语义与引用路径。
- 规则先于内容：新工作流前先复用已有规则或模板。
- 入口单一：Slash 命令只维护在 [skills/README.md](skills/README.md)。
