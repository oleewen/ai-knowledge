# 联邦与 overview 写入

布局契约（路径、表行、流水线）：[knowledge-layout.md](../../../references/knowledge-layout.md)。

## 目标

**系统库**唯一落盘：`system/knowledge/overview/{APPNAME}-overview.md`。  
新建：从 `NAME-overview.md` 拷；**文件名 + 文内标题** `NAME` → `APPNAME`。

**公司库** overview 缓冲区：`company/knowledge/overview/{NAME}-overview.md`（`docs-extract` / `docs-archive` / `docs-tag` 同工作流；`docs-distill` 上行目标仍为系统库 overview）。

**非目标**（只当来源）：各层 `architecture/` 或 `ea/` 下五视角长篇、应用 knowledge、应用 SDD。

## 联邦层级（摘要）

| 层 | 适合 | 不适合 |
| -- | ---- | ------ |
| 应用库 | 规则细节、故事、接口/类图、部署、表结构 | 跨应用映射、系统级摘要 |
| 系统库 | 五视角**摘要**、ID 契约 | OpenAPI 全文、DDL、故事原文 |
| 公司库（`ea/`） | 企业架构顶层标准、跨系统方案输入 | 系统实现细节、应用字段定义 |

## 规则（第三列）

**提炼**：从 knowledge + SDD 取信息，按五架构视角**逐行**写第三列；禁止整段粘贴。

**步骤**（每行）：① 打开副标题链对应章的「应填内容 + 产出建议」② 从应用源取对应信息 ③ 写第三列并标变动：

- 原 `—`/空 → 有内容 → `**[A]**`
- 原有且改 → `**[U]**`
- 原有且本次删 → `**[D]**` 并清空
- 无变化 → 保持，**不加标**（与 gotchas 一致）

**顺序**（自上而下逐节，勿跳行；与各层 `overview/NAME-overview.md` 模板表行一致，以各视角 **README 表行**为准）：

### 系统库（`system/knowledge/overview/`）

- 业务：概述 → 域划分 → 术语 → 流程 → 能力地图
- 产品：概述 → 产品架构 → 信息架构 → 产品功能 → 用户旅程
- 应用：系统概述 → 应用架构 → 领域模型 → 服务设计 → 领域能力 → ADR
- 技术：技术概述 → 基础设施 → 中间件 → 性能扩展 → 高可用 → 可观测性
- 数据：数据概述 → 数据模型 → 数据存储 → 数据分析 → 数据流转

### 公司库（`company/knowledge/overview/`）

- 业务：概述 → 域划分 → 商业模式 → 价值链 → 组织角色 → 业务能力
- 产品：概述 → 产品线 → 度量标准 → 体验设计
- 应用：系统概述 → 应用架构
- 技术：技术概述 → 云基础设施 → DevOps → 技术安全 → 开发环境
- 数据：数据概述 → 数据治理 → 数仓与湖 → 数据安全

`docs-distill` **落盘目标仍为** `system/knowledge/overview/{APPNAME}-overview.md`；公司侧表行仅作模板对照与 `docs-extract` / `docs-archive` / `docs-tag` 落盘依据。

**其它**：先读规范再写；第三列可多段/列表/小表；无对应信息写 `—`；**不写** `(来源…)` 堆链。

## 自检

- [ ] 五行视角**所有表行**已处理（内容或 `—`）  
- [ ] 符「应填内容」，非原文搬运  
- [ ] A/U/D 与事实一致  
- [ ] 无不当细节（全文 OpenAPI、整段 DDL 等）挤占第三列  
- [ ] 文件名 + 标题 `APPNAME` / `NAME` 一致  
