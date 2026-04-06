# `.ai` 目录说明

`.ai/` 是本仓库的 AI 协作控制层，负责沉淀可复用的规则、模板与技能工作流。  
它回答的是“如何协作与交付”，而不是“业务知识本体”。

## 职责边界

- `rules/`：规范与模板入口，约束文档结构、命名、提交流程与阶段产物格式。
- `skills/`：以 `SKILL.md` 为核心的工作流定义，由 Agent 按步骤执行并生成产物。
- `scripts/`（仓库根）：初始化与分发工具链，负责把 `.ai/` 与知识库模板同步到目标项目。

> `skills/` 是“流程定义”，`scripts/` 是“环境初始化”，二者职责不同。

## 结构导览


| 路径                                                                                           | 用途                        |
| -------------------------------------------------------------------------------------------- | ------------------------- |
| [rules/CONVENTIONS.md](rules/CONVENTIONS.md)                                                 | 规则总入口（编码/设计/测试/文档交付规范）    |
| [rules](rules)                                                                               | 分域规则与模板集合                 |
| [skills](skills)                                                                             | Skill 工作流目录（每个子目录对应一个能力域） |
| [skills/README.md](skills/README.md)                                                         | Skills 使用入口与命令清单（权威）      |
| [skills/agent-guide/assets/agents-skeleton.md](skills/agent-guide/assets/agents-skeleton.md) | `AGENTS.md` 推荐骨架模板        |


## 与全仓库文档关系

- 总体协作契约见 [AGENTS.md](../AGENTS.md)。
- 全局路径与检索地图见 [INDEX_GUIDE.md](../INDEX_GUIDE.md)。
- 知识库建模与维护流程见 [system/DESIGN.md](../system/DESIGN.md) 与 [system/CONTRIBUTING.md](../system/CONTRIBUTING.md)。

## 维护原则

- 优先保持稳定：尽量增量更新，不破坏既有目录语义与引用路径。
- 规则先于内容：新增工作流前先确认是否已有规则或模板可复用。
- 入口单一：Slash 命令与技能说明统一维护在 [skills/README.md](skills/README.md)，避免在本文件重复定义。

> 历史文档若出现 `.ai/CONVENTIONS.md`，请以当前路径 [rules/CONVENTIONS.md](rules/CONVENTIONS.md) 为准。