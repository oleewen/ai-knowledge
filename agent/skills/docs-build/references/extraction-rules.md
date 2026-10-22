# 五视角提取规则

只读当前视角对应节与 meta。先用 [knowledge-governance.md](../../../knowledge/knowledge-governance.md) 确定本层职责，再定位来源；不得把代码中的所有概念都落到应用库。

| 视角 | 字段真源 | 本节关注 |
| --- | --- | --- |
| [应用](#1-应用视角application) | [application-meta.md](../../../knowledge/application-meta.md) | 运行边界、宿主聚类、四类 API |
| [数据](#2-数据视角data) | [data-meta.md](../../../knowledge/data-meta.md) | 数据主权、数据源、物理表身份 |
| [业务](#3-业务视角business) | [business-meta.md](../../../knowledge/business-meta.md) | 业务边界与领域模型证据 |
| [产品](#4-产品视角product) | [product-meta.md](../../../knowledge/product-meta.md) | 产品链、流程链与用户场景 |
| [技术](#5-技术视角technical) | [technical-meta.md](../../../knowledge/technical-meta.md) | 技术准入、绑定、关键依赖 |

关系字段按当前 meta 与治理规则核对，已知冲突处理见 [builtin-config.md](builtin-config.md)。本文件保留提取方法，不再复制所有必填字段表。

## 1. 应用视角（Application）

从主 INDEX 定位解决方案边界、启动配置、宿主类及入口实现；只读能支撑当前候选的文件。

### SLN（解决方案层级）

从解决方案边界识别一仓一 SLN，并核实 PL 与 BP。治理规则规定方案层不登记 SYS；不要沿用旧样例的 SYS 反向边。

### SYS（系统层级）

从系统 README 与架构边界确认 SYS；不能仅凭仓库名推断。SYS 对标 PD、实现 SLN；不绕过 PD 声明 MDG/TS 使用边。

### APP（应用层级）

从可部署启动单元识别。Java 工程可用 `main(String[] args)`、`Main.run()`、`SpringApplication.run()` 与启动插件交叉核实；Maven 模块存在本身不是 APP 证据。

### MS（微服务层级）

按 API 宿主类聚类，别名取 SimpleName 去业务无关后缀（如 Api、ApiImpl、Controller）。同义宿主合并须有实现对应证据；同模块可有多个宿主 MS。禁止直接用 Maven 模块名或包名尾段替代 MS 身份。应用库仅引用已登记 MS，并保留其 API 宿主目录。

### API（接口层级）

检查选定来源中实际存在的四类入口；未发现的类型如实说明，不补造。每条 API 的 `implements_to` 指向已核实 MS；别名以 `{MS别名}.` 开头。

| 类型 | 识别线索 | 边界与详细说明 |
| --- | --- | --- |
| Dubbo | `@DubboService`、Dubbo 包的 `@Service`、`<dubbo:service interface="...">`、RPC 实现接口 | 只提 Provider；接口全名与协议可选 |
| HTTP | Controller、RequestMapping/GetMapping 等映射，或已暴露 Gateway 端点 | 核实类与方法的组合路径；HTTP 方法/路径可写详细说明 |
| MQ | RocketMQ/Kafka/Rabbit listener 注解、MessageListener 实现或 Consumer 注册 | 提 Consumer，不提 Producer；同一 Consumer 多 Tag 仍一条 API；别名 `{MS别名}.on{Topic简写}` |
| Job | XxlJob、Scheduled、IJobHandler、Quartz Job 或调度平台注册 | 别名 `{MS别名}.job{HandlerAlias}`；handler、Cron 可写详细说明 |

宿主、模块、方法签名与入口类型属于详细说明；可选字段缺失不自动判失败。缺 MS 归属则列待确认，不就近猜父级。

## 2. 数据视角（Data）

从 INDEX 定位主数据划分、数据源配置、实体映射、DDL 与 Mapper XML。

### MDG（主数据域层级）

依据解决方案数据主权划分，可有多个 MDG；不以 MDG 代替 DS 或 ENT。使用关系按治理对标 PD。

### DS（数据源层级）

从数据源配置识别逻辑存储，核实所属 MDG。存储类型、配置键、事务注解可写详细说明；不抄凭据。

### ENT（实体层级）

从实体类、Table 映射和物理表证据识别。相同物理表的类合并一个 ENT；先区分数据源，不能只按表名合并。禁止用包名或 Mapper 类名代替实体身份。

### TBL（数据表层级）

从已核实物理表和 DDL 提取，一表一 TBL；必须明确 ENT 归属，缺父级不落盘。

## 3. 业务视角（Business）

先读业务叙事与已登记边界；包路径、宿主类和聚合根仅作为实现证据，不单独证明业务划分。

### VC（价值链层级）

从公司价值链或商业模式识别；组织部门不是价值链，VC 与 CAP 不混用。

### CAP（业务能力层级）

从公司能力目录识别，核实所属 VC；缺 VC 时不落盘。

### BD（业务域层级）

从业务域定义识别，包路径只能辅助核验；children 只登记 BSD-L1。

### BSD（业务子域层级）

按公司 L1、解决方案 L2、系统 L3 分层提取；核对 level 与 parent，不新增四级 BSD、不把 BC 当 BSD、不跨 L1 合并 L2。L1/L2 的 children 在对端 parent 已存在时须对应；下层反向边仅纯 ID。

### BL（业务线层级）

依据公司业务线定义；核实与 BSD-L1 的一对一映射，不当作域模型链的父级。

### BS（业务服务层级）

依据解决方案业务服务定义；核实与 BSD-L2 的一对一映射，不以技术接口充当 BS。

### BC（限界上下文层级）

从模型边界及上下文包证据识别，归属 BSD-L3；不直接挂 BSD-L2，不按 Maven 模块机械生成 BC，也不将单个上下文包拆为多个 BC。

### AGG（聚合层级）

以聚合根和一致性边界为证据；无聚合根依据时列待补充，不造 AGG。不变量可写详细说明。

### AB（聚合边界层级）

从聚合入口与生命周期边界识别，归属 AGG；能力概述可写详细说明。

## 4. 产品视角（Product）

从产品定义、README、PRD 与已核实业务/应用 ID 提取；技术操作本身不等于用户功能或用例。

### PL（产品线层级）

从解决方案产品线定义提取，核实公司 BL 映射。目标用户可写详细说明。

### PD（产品服务层级）

从产品架构、交付边界识别，归属 PL 并一对一映射 BS。PD 首次定义在解决方案；不在公司、系统、应用重复落文件。

### BP（业务流程层级）

从解决方案主业务流程识别，一个 SLN 一条 BP；implements_to 为 SLN，不混入产品组成链。

### BSP（业务子流程层级）

从主流程的子流程识别，同时核实 parent BP 与 implements_to PD。core/branch/exception 分类可写详细说明。

### PM（产品模块层级）

从产品功能分解识别，核实所属 PD；不直接挂 PL，不跨系统关联 PD。模块依赖在已读证据支持时记录，对端 depended_by 与 depends_to 对称。

### FT（功能特性层级）

从用户操作与接口能力提炼，归属 PM；技术实现细节不是 FT。验收标准可写详细说明。

### FR（功能需求层级）

从 FT 下的需求条目提取；UC/BR 必须经 FR 归属，不能直挂 FT。

### BR（业务规则层级）

从需求约束提取，implements_to 指向 FR；不凭经验编造规则。

### UC（用例层级）

从用户场景识别，implements_to 指向 FR；单一技术操作不自动形成 UC。

## 5. 技术视角（Technical）

从平台准入、方案技术选用、部署绑定与关键依赖清单提取。默认未选 technical 时先收口范围。

### TPL（技术平台层级）

从公司技术准入识别；平台能力与产品/应用实现分开，不建 APP↔TPL 直连。

### TS（技术服务层级）

从解决方案技术选用及例外识别，归属 TPL；使用边按治理指向 PD。

### MW（中间件绑定）

从数据源、缓存、MQ Topic/Group、注册配置等部署绑定识别；不是 MS/API 宿主类。Consumer 类仍归 API，绑定配置归 MW。

### CMP（组件）

从已确认 allowlist 中的关键依赖提取（如 Dubbo、MyBatis、Redis/Kafka Client、关键 Starter），核实 MW 归属与 Maven 坐标。禁止全量依赖生成 CMP 或建立 APP↔CMP 直连。

## 跨视角依赖

合法边与双向规则见 [knowledge-governance.md](../../../knowledge/knowledge-governance.md)、[glossary.md](../../../knowledge/glossary.md#映射关系常用)。同层链接留在 knowledge 内；范围外反向边只列依赖，不扩写。

有 parent 的上层实体链接由相邻 docs-okf 的 `okf_cross_layer.cross_layer_href(start_doc_root, id, path_parent=...)` 生成；输入为当前文档根、已核实 ID 与必要父链。函数无可用结果时保留纯 ID；配置无效或层/实体不明时报错澄清，不手拼 URL。无 parent 与指向下层时均只写纯 ID。

## 通用字段说明

正式实体遵 [okf-spec.md](../../../knowledge/okf-spec.md) 的九字段 frontmatter、与 title 一致的 H1（前置 MD025 单行豁免）及四个中文 H2；关系、业务属性、证据分别进入对应正文。可用 [entity-template.md](../assets/entity-template.md)，替换全部占位并填写已核实内容。

路径遵 [knowledge-layout.md](../../../references/knowledge-layout.md)，需要推导时用 `okf_lib.entity_relpath(perspective, id, path_parent=..., bundle=知识层)`；其结果相对文档根。父链来自已核实关系与宿主目录，不用 EXAMPLE 回退。

[knowledge-schema-template.json](../assets/knowledge-schema-template.json) 仅保留可编程消费的字段样例，不是落盘 JSON schema，也不是批量实体集合模板。
