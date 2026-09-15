# `agent` 目录说明

`agent/` 是本仓库 AI 协作控制层（规则 / 协议 / 技能 / 共享脚本），回答「如何协作与交付」，不是业务知识本体。  
全仓契约与地图见根 [AGENTS.md](../AGENTS.md)、[INDEX-GUIDE.md](../INDEX-GUIDE.md)。装机编排：[bootstrap.sh](../bootstrap.sh)。

## 结构导览

| 路径 | 用途 |
| --- | --- |
| [rules/CONVENTIONS.md](rules/CONVENTIONS.md) | 规则总入口与产出协议总表 |
| [knowledge/README.md](knowledge/README.md) | 知识治理 SSOT |
| [references/](references) | 跨 Skill 契约（澄清 / 推进 / 轻流程 / 烤干 / 布局 / 工作稿路径） |
| [skills/README.md](skills/README.md) | Slash 命令清单（权威） |
| [scripts/](scripts) | 共享 Bash 库（路径与 `.docsconfig` 解析等） |
| [hooks.json](hooks.json) · [hooks/README.md](hooks/README.md) | Hooks 配置 SSOT；目录说明 |
