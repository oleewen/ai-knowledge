# 知识库治理规则

> **定位**：四层职责、实体首次定义层与层间基数的唯一真源。字段必填性见五视角 meta；关系见 [entity-relations.md](entity-relations.md)；引用见 [knowledge-reference-rules.md](knowledge-reference-rules.md)；联邦配置见 [federation-config.md](federation-config.md)。组件入口见 [README.md](README.md)。

**最后更新**：2026-10-23

## 使命

使架构决策透明、一致、可追溯；同一事实只维护一处正文。

## 四层职责边界

| 层级 | 职责 |
| --- | --- |
| 公司 | 完整价值链、域架构、企业技术准入；不写单应用实现细节 |
| 解决方案 | 一个交付包的架构、主流程、产品框架、数据主权与技术选型；本层不登记 SYS |
| 系统 | 一个 SYS 的实现边界与架构聚合 |
| 应用 | 实现级实体、SDD 交付与物理锚点 |

跨层不得重复定义字段语义。阶段目录、槽位与流水线见 [知识布局](../references/knowledge-layout.md)，不在本文维护第二套路径表。

**联邦**：parent 仅允许 `application → system → solution → company`，向上 1:1；公司不直管系统。蒸馏按层上收，禁止默认跳层。

**基数**：一仓一 SLN；一 SLN 一个 PL、一条 BP、多个 PD；BL→BSD-L1、BSD-L1→CAP、PL→BL、PD→BS→BSD-L2、SYS→PD 均 1:1；一 SLN 多个 MDG、多个 TS。

## 各层聚焦摘要

**首次定义**指治理语义、字段口径和上游主定义所在层，不等于其他层不能提及。下游承接实现映射与物理锚点；上层实体不建下层 reference 文件，宿主目录可留。引用形态见 [引用规范](knowledge-reference-rules.md)。

| 首次定义层 | 实体 |
| --- | --- |
| 公司 | VC、BD、CAP、BSD-L1、BL、TPL |
| 解决方案 | SLN、PL、PD、BP、BSP、BSD-L2、BS、MDG、TS |
| 系统 | SYS、BSD-L3、BC、AGG、AB、PM、FT、FR、UC、BR、APP、MS、DS、ENT |
| 应用 | API、TBL、MW、CMP |

### 公司层

公司域架构说明 BD/BSD-L1 如何支撑 VC。产品视角只放企业产品标准，无产品实体；应用与数据视角无首次定义实体。各层目录见 [知识布局](../references/knowledge-layout.md)。

### 解决方案层

围绕交付包形成跨系统共性。SYS 的上游归属由系统侧声明；解决方案不登记 SYS 的反向关系。具体允许边见 [关系模型](entity-relations.md#例外与禁止)。

### 系统层

不复制上层实体。元模板中的 BSD-L2、MDG 仅作目录宿主；业务仓可保留 BSD-L2 实体作聚合导航，不改变其上层 SSOT。需求分析从原始输入开始，不要求先有 SOLUTION。

### 应用层

承接上游实现映射。业务、产品视角无首次定义实体；本层需求分析同样可从原始输入开始。overview、章节归档与上行目标见 [overview 规范](overview-spec.md)和 [知识布局](../references/knowledge-layout.md)。

## 核心映射（5A 方向）

5A 短义及视角对应见 [术语表](glossary.md#知识库术语)；关系方向、双向要求与例外见 [实体关系模型](entity-relations.md)。

### 5A ↔ 五视角层级

各视角字段分别见 [业务](business-meta.md)、[产品](product-meta.md)、[应用](application-meta.md)、[数据](data-meta.md)、[技术](technical-meta.md)。本节保留旧入口，不重复实体链。

## 业务 knowledge 引用边界

允许目标、跨层形态、读写分离及违规处理见 [业务 knowledge 引用规范](knowledge-reference-rules.md)。`knowledge-links.yaml` 字段、工作区路径、HTTP 生成与离线校验见 [联邦配置契约](federation-config.md)。本节保留旧入口。
