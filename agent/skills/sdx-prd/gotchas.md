# 易错点（sdx-prd）

反模式表 [references/anti-patterns.md](references/anti-patterns.md)；原则 [references/design-principles.md](references/design-principles.md)。总览 [SKILL.md](SKILL.md)；填充摘要 [references/workflow.md](references/workflow.md)。

## 前置

- **无 ANALYSIS**：硬输入缺失则停 → `sdx-analysis`；否则 US 无法追溯 FR。  
- **未锁 MVP**：只写 `--mvp` 内 FR；混后续阶段 → 范围失控。  
- **ANALYSIS 结构残**：须警告并列缺口；可标「基于不完整基线」。

## §2

- 主流程与分支/异常分开；扩展节点或子图标触发条件。  
- 跨系统节点：系统名、同步/异步、关键 I/O；异步标回调。  
- 节点不写长规则正文；旁标 `[BR-n]`，正文汇 §7。

## §4

- 参与者用**业务角色**（非「某某服务」泛名当角色）。  
- UC 须有前后置条件。  
- UC 描述与 US **双向**互标。

## §5

- 每 US 须有 GWT；含边界/异常。  
- US 须能独立演示（INVEST）；强依赖则合并或拆。  
- 每 US 标 **关联 FR-n、BR-n**。

## §6–§8

- 模块按**业务能力域**，不按前后端分层。  
- BR 有优先级；互斥写化解策略。  
- 字典字段：类型、必填、枚举、含义；状态机有终态与非法转换策略。

## §9–§11 与元数据

- NAC 指回 §9 或写明不适用。  
- 不重排十一章；空节标不适用/待补充。  
- **勿**文件头 YAML；**仅**文末 `## 文档元数据`；含 `parent`、`mvp_phase` 等。  
- PRD 不写「怎么用 Redis」「调哪个 RPC」——属 DSD。  
- 歧义标待澄清，勿自假设。  
- Mermaid：`flowchart` / `sequenceDiagram` / `stateDiagram-v2` / `graph` 等按需选对类型。
