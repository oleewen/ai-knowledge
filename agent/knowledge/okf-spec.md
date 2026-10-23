---
type: Knowledge Governance
title: OKF 共享规范
description: company、solution、system、application 四层共享的知识文件分类与 OKF 概念实体规范。
tags: [okf, governance, shared-spec]
timestamp: "2026-06-25T00:00:00+08:00"
---
<!-- markdownlint-disable-next-line MD025 -->
# OKF 共享规范

> **职责**：文件分型、per-entity 的 frontmatter 与正文格式、校验和演进。
> **边界**：类型登记见 [glossary.md](glossary.md#实体缩写登记)；实体归属见 [knowledge-governance.md](knowledge-governance.md)；关系语义见 [entity-relations.md](entity-relations.md)；引用范围见 [knowledge-reference-rules.md](knowledge-reference-rules.md)；物理路径见 [knowledge-layout.md](../references/knowledge-layout.md)。

规范来源：[OKF v0.1 SPEC](https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/SPEC.md)；参考实现/讨论：[open-knowledge-framework](https://github.com/google/open-knowledge-framework)。

## 规范总览

先分型，再写入。只有实体概念强制使用本仓 per-entity Profile：九个 frontmatter 字段和四段中文 H2；索引、叙事、元数据各按自身职责组织。

## 0. 规范定位

适用于 company、solution、system、application 四层及其配套文件。OKF Core 仅要求 `type`，允许 extensions；本仓对实体概念加严，不将实体要求套到所有 Markdown。

## 1. 文件分类方式

先判用途，再判稳定 `id` 与实体树位置。OKF Core 的 concept 范围不等于本仓的实体概念范围。

### 1.1 实体概念（per-entity）

有明确边界、唯一 `id`、可被引用的对象，通常为 `knowledge/<perspective>/…/{ID}.md`。MUST 遵守 §2–§4 的 Profile、§9 的关系位置及 §11 的校验；业务属性优先下沉正文。

### 1.2 索引入口

回答从哪读、如何下钻或枚举。典型：README.md、index.md、knowledge/index.md、INDEX-GUIDE.md。MUST 遵 §5，不强套实体 Profile。

### 1.3 叙事文件

主题说明、架构叙事、综述或治理专题，如 `*-overview.md`、各视角章节。MUST 遵 §6，不因提到实体就变成实体概念。

### 1.4 元数据

字段契约、链接编排或运维元信息，如五视角 meta、knowledge-links.yaml、INDEX-GUIDE 增量锚点。MUST 遵 §7，不强套实体 Profile。

### 1.5 分型优先级

多类特征并存时：实体概念 > 索引入口 > 元数据 > 叙事文件。README / index 默认索引入口；五视角 meta、knowledge-links.yaml、变更日志默认元数据。

## 2. 实体概念 Profile：frontmatter（9 必填 + extensions）

每个实体概念 MUST 包含下列九个字段；机器消费的 `title` 不得为消除 MD025 而删除。

| 字段 | 类型 | 约束 |
| --- | --- | --- |
| `type` | 枚举 | 与 hierarchy 精确对应，见 §3 |
| `title` | 字符串 | 实体中文显示名 |
| `description` | 字符串或 null | 一句定义；暂无定义填 null |
| `tags` | 字符串数组 | 必含 perspective 与 hierarchy，如 `[business, BD]` |
| `timestamp` | ISO8601 字符串 | 北京时间格式 `YYYY-MM-DDTHH:MM:SS+08:00` |
| `id` | 字符串 | 全局唯一，字面语法见 [命名规范](naming-conventions.md) |
| `perspective` | 枚举 | business / product / application / data / technical |
| `hierarchy` | 枚举 | 见类型登记表；与 type、perspective 一致 |
| `layer_scope` | 枚举 | company / solution / system / application；与所在知识库一致 |

允许扩展字段。业务扩展属性 SHOULD 写入「详细说明 / 关系 / 跨视角」，**不得据此把上述九个必填字段移出 frontmatter**。确需跨文件机器消费的扩展字段须在本规范登记语义与示例并长期维护，禁止静默新增共享约定。

`resource` 是可选扩展，可写代码仓、表、接口、工单等底层资产 canonical URI；不得借此绕过[引用边界](knowledge-reference-rules.md)。非实体文件的 `okf_version` / `status` 不属于这九个必填字段。

## 3. type 与 hierarchy 映射表

精确的 31 类 `hierarchy ↔ type ↔ perspective` 映射只维护于 [glossary.md § 实体缩写登记](glossary.md#实体缩写登记)。首次定义层只维护于[治理规则](knowledge-governance.md#各层聚焦摘要)。

BSD 还须结合 layer_scope 与正文 level 或 ID 的 `-L2` / `-L3` 后缀区分层级；不能仅由 `hierarchy: BSD` 推断首次定义层。上层实体在下游的出现方式遵引用规范，不生成 reference 实体副本。

## 4. per-entity 四段正文结构（实体概念 Profile）

正文首标题为 H1，文本与 frontmatter title 相同；上一行使用 `<!-- markdownlint-disable-next-line MD025 -->`。随后 MUST 按以下顺序设置四个中文 H2：

| 顺序 | 标题 | 内容 |
| --- | --- | --- |
| 1 | `## 关系` | 按 §9 放结构关系 |
| 2 | `## 跨视角` | 按 §9 放跨 perspective 关系 |
| 3 | `## 详细说明` | 业务定义、属性、职责、不变量与验收 |
| 4 | `## 依据与证据` | 可追溯来源，遵引用边界 |

文件必须位于所属知识树，且九字段与路径层级一致。同层引用使用可解析链接，同一文件保持链接风格一致；跨层形态与可引目标完全遵 [knowledge-reference-rules.md](knowledge-reference-rules.md)。

### 4.1 关系段

动词与合法边见 [entity-relations.md](entity-relations.md)。逐实体必含/选含字段只维护于五视角 meta 的 §2：

| perspective | 字段规范 |
| --- | --- |
| business | [business-meta.md](business-meta.md) |
| product | [product-meta.md](product-meta.md) |
| application | [application-meta.md](application-meta.md) |
| data | [data-meta.md](data-meta.md) |
| technical | [technical-meta.md](technical-meta.md) |

路径父级取值见[布局契约](../references/knowledge-layout.md#文件与目录落点)，不在 frontmatter 另设路径关系。

### 4.2 跨视角段

可用 `business:` / `product:` / `application:` / `data:` / `technical:` 子段组织。无引用填 `(none)`；禁止在本段引用同 perspective 实体，同视角关系写入「关系」。

### 4.3 详细说明段

承载业务定义、关键职责、不变量、ADR 要点、通用语言、根实体/API 列表、目标用户、验收标准及业务扩展属性。无内容填 `(none)`。description 保持一句话，长说明置于本段。

### 4.4 依据与证据段

在[允许的引用范围](knowledge-reference-rules.md)内写文件链接与章节锚点，或外部 URI/资产名；多源用换行或分号。无额外来源可保留 `示例数据`。来源变化时同步证据，不将库外文档路径写入本段。

## 5. 索引入口处理规则

MUST：目录说明清楚、关键文件和子目录入口齐全、下钻链接正确；不强加实体 frontmatter。bundle 根 index.md 的 OKF 区块 frontmatter **仅允许 `okf_version`**。

SHOULD：README 面向人类，index 用于渐进披露；根 index 含 OKF 区块与目录索引。九章索引、视角导航和实体台账的分工见[布局契约](../references/knowledge-layout.md#文件与目录落点)。MAY 添加误用反例。

## 6. 叙事文件处理规则

MUST：保持主题说明角色，不伪装成实体；术语与实体一致，链接遵引用规范。SHOULD：结构化 Markdown；overview 遵 [overview-spec.md](overview-spec.md)。MAY 使用不影响阅读的 HTML 提示或占位。

## 7. 元数据文件处理规则

MUST：保持规则、目录元信息、链接编排或运维职责；不按实体 schema 改造。SHOULD：区分枚举/约束与解释文字，运维留痕遵对应目录 README。MAY 使用长期维护的工具扩展字段。引用本格式规范统一链接本文件。

## 8. 目录哲学

### 8.1 父子同目录可见

物理组织原则与路径差额统一见[布局契约](../references/knowledge-layout.md#文件与目录落点)。

### 8.2 父层目录的 `index.md`

含子概念目录的 index 要求见同一[布局契约](../references/knowledge-layout.md#文件与目录落点)，本规范不另列目录树。

## 9. 跨视角引用规则

本节只规定**写在哪一段**，不重定义合法边或目标类型。

| 关系 / 信息 | 正文位置 |
| --- | --- |
| `parent` / `children` | 关系 |
| `implements_to` / `implemented_by` | 关系 |
| `maps_to` / `mapped_by` | 必填项在关系；选填且跨 perspective 的项可在跨视角 |
| `supports_to` / `supported_by` | 关系 |
| `uses_to` / `used_by` | 跨视角 |
| `depends_to` / `depended_by` | 关系 |
| 同 perspective 引用 | 关系 |
| 上游主定义说明 | 详细说明 |
| 证据来源 | 依据与证据 |

不要求在 frontmatter 表达跨视角链路；不得因在两段都有入口而重复写同一事实。

## 10. 四层共享模板

模板结构遵本文；以下稳定入口只路由层职责，不另定义实体清单：

### 10.1 company

见[公司层](knowledge-governance.md#公司层)。叙事与元数据须和实体概念分型。

### 10.2 solution

见[解决方案层](knowledge-governance.md#解决方案层)。

### 10.3 system

见[系统层](knowledge-governance.md#系统层)。

### 10.4 application

见[应用层](knowledge-governance.md#应用层)。物理锚点、宿主信息与配置证据按本层字段规范提供。

## 11. 校验与演进

### 11.1 layer_scope 规则

layer_scope 必须与所属知识库层级一致。元库路径为 `{layer_scope}/knowledge/...`；消费库物理文档根与层级由其配置区分，见[四层文档根](../references/knowledge-layout.md#四层文档根)。

### 11.2 tags 与 timestamp

逐项校验 §2 的 tags 与 timestamp 约束；不另维护第二份字段定义。

### 11.3 演进

兼容增量在本文末尾追加附录；不兼容变更另起版本文件（如 `okf-spec-v2.md`）。扩展字段成为共享约定时必须同步更新本文。

### 11.4 删除旧规范约束

旧 system schema 规范不再是真源；不得恢复其引用。本文与明确链接的职责模块共同构成现行规范。
