# 软件系统知识文档库（ai-knowledge）

本仓库是系统级知识底座，核心目标是以 **SSOT（单一事实源）+ 联邦治理** 管理架构与交付文档。  
本文件只提供入口导航与初始化方式，细节规则分散在各子域 README 中，避免重复维护。

## 快速启动

远程初始化（推荐）：

```bash
curl -sL "https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/knowledge-init-bootstrap.sh" | bash -s -- [选项]
```

本地初始化（已克隆仓库）：

```bash
cd /path/to/your-project
REPO_ROOT=/path/to/ai-knowledge /path/to/ai-knowledge/scripts/knowledge-init.sh [选项]
```

初始化参数与模式说明见 [scripts/README.md](scripts/README.md)。

## 入口导航（按阅读目的）

| 目的 | 入口 |
|------|------|
| 全库路径地图（AI/RAG） | [INDEX_GUIDE.md](INDEX_GUIDE.md) |
| 人类与 Agent 协作约束 | [AGENTS.md](AGENTS.md) |
| 系统知识库主线（knowledge -> solution -> analysis -> requirements） | [system/README.md](system/README.md) |
| 应用侧联邦知识库 | [applications/README.md](applications/README.md) |
| AI 协作规则与技能 | [.ai/README.md](.ai/README.md) |
| 技能命令清单（Slash） | [.ai/skills/README.md](.ai/skills/README.md) |
| 变更记录与索引运维 | [system/changelogs/README.md](system/changelogs/README.md) |

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


