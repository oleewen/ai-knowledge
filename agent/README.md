# `agent` 目录说明

`agent/` 是本仓库 AI 协作控制层（规则 / 协议 / 技能 / 共享脚本），回答「如何协作与交付」，不是业务知识本体。  
全仓契约与地图见根 [AGENTS.md](../AGENTS.md)、[INDEX-GUIDE.md](../INDEX-GUIDE.md)。装机编排：[bootstrap.sh](../bootstrap.sh)。

## 结构导览

| 路径 | 用途 |
| --- | --- |
| [rules/CONVENTIONS.md](rules/CONVENTIONS.md) | 规则总入口与产出协议总表 |
| [knowledge/README.md](knowledge/README.md) | 知识语义 SSOT：层职责、关系、引用、联邦配置、overview 与 OKF |
| [references/README.md](references/README.md) | 协作执行 SSOT：流程路由、澄清、推进、烤干、待办与路径 |
| [skills/README.md](skills/README.md) | Slash 命令清单（权威） |
| [scripts/README.md](scripts/README.md) | 共享脚本职责、兼容入口、依赖与测试路由 |
| [hooks.json](hooks.json) · [hooks/README.md](hooks/README.md) | Hooks 配置 SSOT；目录说明 |
