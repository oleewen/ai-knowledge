# 软件系统知识文档库（ai-knowledge）

本仓库是系统级知识底座，核心目标是以 **SSOT（单一事实源）+ 联邦治理** 管理架构与交付文档。
本文件只提供入口导航与初始化方式，细节规则分散在各子域 README 中，避免重复维护。

## 快速启动

1、方式一：Agent初始化（推荐）

提示词：

```text
按 https://github.com/oleewen/ai-knowledge README.md 的快速启动方法二或三，初始化知识库到 ./docs
```

2、方式二：远程初始化：

```bash
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh" | bash -s -- [选项]
```

3、方式三：本地初始化（已克隆仓库）：

```bash
cd /path/to/your-workspaces

git clone https://github.com/oleewen/ai-knowledge 

./ai-knowledge/scripts/docs-init.sh [--选项] ./your-project/docs
```

初始化参数与模式说明见 [scripts/README.md](scripts/README.md)。

## 常见 Skill 说明与流程

Skill 是由 Agent 执行的流程化命令，主要用于文档治理、索引维护与阶段交付；完整命令清单以 [.ai/skills/README.md](.ai/skills/README.md) 为准。

### 推荐流程（从初始化到交付）

1. 初始化环境：按“快速启动”执行 `docs-bootstrap.sh` 或 `docs-init.sh`。  
2. 建立索引：执行 `/docs-indexing`，先形成可检索入口 `INDEX_GUIDE.md`。  
3. 生成约束：当导航或协作约束变化时执行 `/agent-guide`，生成 `README.md`、`AGENTS.md`。  
4. 构建知识：执行 `/docs-build`，从代码/文档提取四视角实体并更新 `system/knowledge/` 索引。  
5. 进入阶段交付：按需要依次使用 `/sdx-solution` → `/sdx-analysis` → `/sdx-prd` → `/sdx-design` → `/sdx-test`。  
6. 同步变更：执行 `/docs-change`，将阶段产物变化沉淀到 `system/changelogs/`，方便 `docs-indexing` 增量更新。  

### 常见 Skill（按用途）

| 场景 | 推荐 Skill | 说明 |
| --- | --- | --- |
| 生成全库索引与检索入口 | `/docs-indexing` | 产出或更新 `INDEX_GUIDE.md`，用于 AI/RAG 路径检索与知识定位。 |
| 构建或补全文档资产 | `/docs-build` | 按知识工程流程补全结构、关系与资产。 |
| 同步仓库协作入口 | `/agent-guide` | 更新 `AGENTS.md` 与 `README.md` 的导航与约束说明。 |
| 阶段化交付（SDD） | `/sdx-solution` `/sdx-analysis` `/sdx-prd` `/sdx-design` `/sdx-test` | 对应方案、分析、需求、设计、测试阶段产物。 |
| 维护文档变更追踪 | `/docs-change` | 聚合变更信息到 `system/changelogs/`，便于审计与回溯。 |

> 提示：`skills/` 是流程定义，`scripts/` 是初始化工具；二者互补，不互相替代。

## 入口导航（按阅读目的）


| 目的                                                                | 入口                                                       |
| --------------------------------------------------------------------- | ------------------------------------------------------------ |
| 全库路径地图（AI/RAG）                                              | [INDEX_GUIDE.md](INDEX_GUIDE.md)                           |
| 人类与 Agent 协作约束                                               | [AGENTS.md](AGENTS.md)                                     |
| 系统知识库主线（knowledge -> solution -> analysis -> requirements） | [system/README.md](system/README.md)                       |
| 应用侧联邦知识库                                                    | [applications/README.md](applications/README.md)           |
| AI 协作规则与技能                                                   | [.ai/README.md](.ai/README.md)                             |
| 技能命令清单（Slash）                                               | [.ai/skills/README.md](.ai/skills/README.md)               |
| 变更记录与索引运维                                                  | [system/changelogs/README.md](system/changelogs/README.md) |

## 最小目录视图

```text
ai-knowledge/
├── INDEX_GUIDE.md
├── AGENTS.md
├── system/
├── applications/
├── scripts/
└── .ai/
```
