---
type: Knowledge Governance
title: OKF 共享规范
description: company、system、application 三层共享的知识文件分类与 OKF 概念实体规范。
tags: [okf, governance, shared-spec]
timestamp: "2026-06-25T00:00:00Z"
---
<!-- markdownlint-disable-next-line MD025 -->
# OKF 共享规范

> **谷歌 OKF v0.1 规范**：[`GoogleCloudPlatform/knowledge-catalog/okf/SPEC.md`](https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/SPEC.md)
> **参考实现/讨论**：[github.com/google/open-knowledge-framework](https://github.com/google/open-knowledge-framework)
> **共享 SSOT**：本仓库 `agent/knowledge/okf-spec.md`
> **边界**：本文管**文件分型**与 **per-entity Profile**（frontmatter/正文/引用）。三层路径、overview 缓冲、联邦流水线 → [knowledge-layout.md](../references/knowledge-layout.md)；ID **语法** → [naming-conventions.md](naming-conventions.md)；缩写/短义/映射字段 → [glossary.md](glossary.md)；首次定义 / 引用边界 → [knowledge-governance.md](knowledge-governance.md)。
> **适用对象**：`company/`、`system/`、`application/` 三层知识库，以及围绕知识库组织的索引入口、叙事文档与元数据文件

---

## 规范总览

先分型，再写入。实体概念须 frontmatter 10 字段 + 正文 4 段中文 H2（§2～§4）；索引/叙事/元数据不按实体 Profile（§5～§7）。OKF Core：`type` 唯一必填，允许 extensions；本仓库对实体概念加严（§0、§2）。机器规约类文件的 `frontmatter title` 为契约字段，不得仅为消 `MD025` 而删。

| 问题 | 是 | 否 |
| --- | --- | --- |
| 可被引用的对象，且需稳定 `full_id`？ | 实体概念（per-entity） | 继续判断 |
| 从哪读 / 怎么下钻 / 怎么枚举？ | 索引入口 | 继续判断 |
| 主题说明 / 架构叙事 / 综述 / 治理专题？ | 叙事文件 | 元数据 |

## 0. 规范定位

面向 AI Agent 的三层共享治理模板。目标：降误用（勿把 README/overview/meta 当实体）→ 三层同类结构一致 → 兼容 OKF v0.1 Core 并定义本仓 per-entity Profile。答：分型、各类 MUST/SHOULD/MAY、三层如何复用。

---

## 1. 文件分类方式

先分类，再决定是否按实体概念 Profile。顺序：用途（对象事实 vs 导航/说明/契约/运维）→ 是否需稳定 `full_id` → 是否在 `*/knowledge/<perspective>/...` 实体树。OKF Core 可将多数 `.md` 视作 concept；本仓再拆「实体概念」与「索引/叙事/元数据」。

### 1.1 实体概念（per-entity）

有明确边界、唯一 `full_id`、可被引用的对象（通常 `{ID}.md`）。

- 模式：`{DOC_DIR}/knowledge/<perspective>/…/{ID}.md`（含 `/{ID}/{ID}.md`）
- 路径 / ID / 缩写：见 [knowledge-layout.md](../references/knowledge-layout.md)、[naming-conventions.md](naming-conventions.md)、[glossary.md](glossary.md)；EXAMPLE 见各层 `knowledge/`，勿在本规范维护长清单
- MUST：遵 §2–§10；四段中文 H2；frontmatter 10 必填（可 extensions；业务属性优先下沉正文）

### 1.2 索引入口

目录导航、阅读顺序、渐进披露、索引聚合。

- 典型：`README.md`、各级 `index.md`、`knowledge/index.md`（目录）、各根 `INDEX-GUIDE.md`（九章 + 第五章实体表，见 [knowledge-layout.md](../references/knowledge-layout.md)）
- MUST：不按实体 Profile；目录说明清晰、入口齐全、术语一致、下钻链路正确

### 1.3 叙事文件

主题 / 架构 / 综述 / 治理专题说明。

- 典型：`*-overview.md`、`business-*.md`、`product-*.md`、`application-*.md`、`data-*.md`、`technical-*.md`
- MUST：不强制实体 Profile；术语与实体一致、引用路径正确、与索引链路不冲突

### 1.4 元数据

目录、规则、链接、日志或治理元信息。

- 典型：`*-meta.md`、`docs-meta.md`、`knowledge-links.yaml`、`INDEXING-LOG.md`；层设计 SSOT 见 [knowledge-governance.md](knowledge-governance.md)
- MUST：不按实体 Profile；字段/职责与规范引用一致

### 1.5 分型优先级

多类特征并存时：concept → 索引入口 → 元数据 → 叙事文件。`README.md` / `index.md` 默认索引入口；`*-meta.md` / `docs-meta.md` / `knowledge-links.yaml` / 变更日志默认元数据。

---

## 2. 实体概念 Profile：frontmatter（10 必填 + extensions）

本节定义实体概念（per-entity）的 frontmatter Profile。

- OKF Core：仅 `type` 为必填；允许任意扩展字段（extensions）。
- 本仓库 Profile：对实体概念要求 10 字段齐全，并约束 `type`/`hierarchy`/`layer_scope` 等一致性；同时允许扩展字段。

每个 per-entity 文件必须包含以下 10 个字段，并允许附加扩展字段（extensions）。同时，为了帮助读者理解当前 worktree 现状，下表也并列展示当前已观测到的非实体文档键。

| 分类 | 字段 | 类型 | 必填 | 说明 | 举例 |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 核心键 + 观测键 | `type` | 枚举 | ✅（实体概念） / -（其他文档） | 对 per-entity 而言是 OKF Core 唯一必填字段；在其他文档中用于标识文件类别 | 实体概念：`Business Domain` / `API Endpoint` / `Component`；索引入口：`Documentation Root` / `Documentation` / `Agent Index Guide` / `Knowledge Index`；叙事文件：`Architecture Chapter` / `Architecture Overview Buffer`；元数据：`Directory Meta` / `Perspective Meta` / `Perspective Tree Meta` / `Change Log` / `Indexing Log` / `Requirement Package` / `Solution Document` / `Analysis Document` / `Design Document` / `Manifest` / `Contributing Guide` |
| 实体概念核心键 | `title` | 字符串 | ✅ | 中文名（实体显示名）；非实体文档中也广泛使用 | `计费业务域` / `应用知识库` |
| 实体概念核心键 | `description` | 字符串 \| null | ✅ | 业务定义短句；无定义时填 `null` | `统一管理主数据定义。` / `null` |
| 实体概念核心键 | `tags` | 字符串数组 | ✅ | per-entity 必含 `[<perspective>, <hierarchy>]`；其他文档可按用途扩展 | `[business, BD]` / `[okf, governance, shared-spec]` |
| 实体概念核心键 | `timestamp` | ISO8601 字符串 | ✅ | 形如 `2026-06-25T00:00:00Z` | `"2026-06-25T00:00:00Z"` |
| 实体概念核心键 | `full_id` | 字符串 | ✅ | 全局唯一 ID，格式：`<hierarchy>-<name>` | `BD-EXAMPLE` / `API-EXAMPLE-001` |
| 实体概念核心键 | `perspective` | 枚举 | ✅ | 与实体所属视角一致 | `business` / `product` / `application` / `data` / `technical` |
| 实体概念核心键 | `hierarchy` | 枚举 | ✅ | 与 `type` 一一对应 | `BU` / `BD` / `CAP` / `PL` / `SLN` / `PD` / `SYS` / `MDG` / `TPL` / `BSD` / `BC` / `AGG` / `AB` / `PM` / `BP` / `FT` / `UC` / `BR` / `APP` / `MS` / `DS` / `ENT` / `TSD` / `API` / `TBL` / `MW` / `CMP` |
| 实体概念核心键 | `parent_id` | 字符串 \| null | ✅ | 父层 full_id；BD 与 PL 允许 `null` | `BD-EXAMPLE` / `PM-EXAMPLE` / `null` |
| 实体概念核心键 | `layer_scope` | 枚举 | ✅ | 与知识库路径前缀对应 | `company` / `system` / `application` |
| 非实体文档键 | `okf_version` | 字符串 | - | 当前只出现在 bundle 根 `index.md` | `"0.1"` / `"1.0"` |
| 非实体文档键 | `status` | 字符串 | - | 当前只出现在公司层示例方案/分析文档 | `draft` / `"draft"` |

规则：

- 上述字段如仍有业务价值，推荐下沉到 `## 详细说明`、`## 关系` 或 `## 跨视角`，避免把“内容模型”固化进 frontmatter。
- 允许扩展字段（OKF extensions）。当某扩展字段成为“本仓库共享约定”（需要跨文件机器消费）时，必须更新本规范并写清语义与示例。

---

## 3. type 与 hierarchy 映射表

27 行精确映射。`type` 与 `hierarchy` 必须一一对应。

| hierarchy | type | perspective | 首次定义层 |
| ----------- | ------ | ------------- | ----------- |
| BU | `Business Unit` | business | company |
| BD | `Business Domain` | business | company |
| CAP | `Business Capability` | business | company |
| PL | `Product Line` | product | company |
| SLN | `Solution` | application | company |
| MDG | `Master Data Domain` | data | system |
| TPL | `Technical Platform` | technical | company |
| BSD | `Business Subdomain` | business | system |
| BC | `Bounded Context` | business | system |
| AGG | `Aggregate` | business | system |
| AB | `Ability` | business | system |
| PD | `Product` | product | system |
| PM | `Product Module` | product | system |
| BP | `Business Process` | product | system |
| FT | `Feature` | product | system |
| UC | `Use Case` | product | system |
| BR | `Business Rule` | product | system |
| SYS | `System` | application | system |
| APP | `Application` | application | system |
| MS | `Microservice` | application | system |
| DS | `Data Store` | data | system |
| ENT | `Entity` | data | system |
| TSD | `Technical Subdomain` | technical | system |
| API | `API Endpoint` | application | application |
| TBL | `Data Table` | data | application |
| MW | `Middleware Binding` | technical | application |
| CMP | `Component` | technical | application |

说明：

- “首次定义层”表示该概念的治理语义与模板首次出现在哪一层。
- 下游层允许做投影、实例登记、实现映射或物理锚点，不等于“只允许在该层出现”。

---

## 4. per-entity 四段正文结构（实体概念 Profile）

### 三层实证要点（per-entity）

MUST：

- 文件为 `{ID}.md` 且在三层 `*/knowledge/<perspective>/...` 下，可被其他文件以链接引用。
- frontmatter 满足实体概念 Profile 的 10 字段必填（见 §2），并保持 `type`/`hierarchy`/`perspective`/`layer_scope` 一致。
- 正文包含 4 个中文 H2（见本节），用于承载关系、跨视角、说明与证据。
- 关系与跨视角引用使用可解析链接；同一文件内链接风格保持一致。
- 业务三层 `*/knowledge/**` 的跨文件引用方向与形态遵守 [knowledge-governance.md](knowledge-governance.md)「业务 knowledge 引用边界」（同层 bundle-relative；向上有 parent 则 HTTP 到首次定义层 SSOT，无 parent 则纯 ID；禁下层/槽位/爬层；依据段不链库外文档路径）。

SHOULD：

- `description` 保持“一句话可复述”的短句；更长说明放 `## 详细说明`。
- 知识内证据优先用同层 bundle-relative 链，或上层首次定义层 HTTP（有 `knowledge-parent.yaml`）/ 纯 ID（无 parent）；库外证据用 URI/资产名（见治理边界），变更时同步。
- 扩展字段（OKF extensions）仅用于“确需机器消费且跨文件共享”的字段；否则下沉到正文以降低耦合。

MAY：

- 添加 `resource`（OKF 推荐字段）指向底层资产（代码仓、表、接口、工单等）的 canonical URI（非库外文档相对路径）。
- 添加少量扩展字段（OKF extensions）以支持自动化生成/索引，但必须在团队约定下长期维护。

代表性文件：

- 落点模式见 [knowledge-layout.md](../references/knowledge-layout.md)；EXAMPLE 见各层 `knowledge/` 样例树
- ID 语法见 [naming-conventions.md](naming-conventions.md)；缩写见 [glossary.md](glossary.md)；`type` 见本文 §3

每个 per-entity 文件必须包含 4 个二级标题，标题统一使用中文：

| 顺序 | 标题 | 内容 |
| ------ | ------ | ------ |
| 1 | `## 关系` | 父子、聚合、能力、应用实现等结构关系 |
| 2 | `## 跨视角` | 跨 perspective 引用 |
| 3 | `## 详细说明` | 业务定义、职责、不变量、验收标准等 |
| 4 | `## 依据与证据` | 同层链、上层 SSOT HTTP 或纯 ID；或外部 URI/资产名（见 [knowledge-governance.md](knowledge-governance.md)） |

### 4.1 关系段

按层级差异化：

| 层级 | 必含子段 | 选含子段 |
| ------ | --------- | --------- |
| BD | `parent: null` + `children: [...]` | — |
| BSD | `parent: [...]` + `bounded_contexts: [...]` | — |
| BC | `parent: [...]` + `aggregates: [...]` | — |
| AGG | `parent: [...]` + `abilities: [...]` | — |
| AB | `parent: [...]` + `implemented_by_app_id: [...]`（允许 `(none)`） | — |
| PL | `children: [...]` | `parent: null` |
| PM | `parent: [...]` + `children: [...]` | — |
| FT | `parent: [...]` + `children: [...]` | — |
| UC | `parent: [...]` | — |
| APP | `parent: [...]` + `service_ids: [...]` | — |
| SYS | `children: [...]` | `parent: null` |
| DS | `parent: [...]` 或 `(none)` | — |
| ENT | `parent: [...]` | — |
| TSD | `children: [...]` | — |
| MW | `parent_tsd_id: [...]` 或 `(none)` | — |
| CMP | `(none)` 或 `parent_mw_id: [...]` | `parent_app_id: [...]` |

指针格式：

- 同目录：`[X-XXX](X-XXX.md)` 或 `[X-XXX](X-XXX/X-XXX.md)`
- 跨 perspective（同 bundle）：`[X-XXX](../../<other-perspective>/X-XXX/X-XXX.md)` 或 `/knowledge/...`
- 跨层：遵守 [knowledge-governance.md](knowledge-governance.md)（生成函数 HTTP 或纯 ID）；禁止手写跨 `DOC_DIR` 相对路径。

### 4.2 跨视角段

- 跨 perspective 引用可按 `business:` / `product:` / `application:` / `data:` / `technical:` 子段组织。
- 无引用时填 `(none)`。
- 禁止在跨视角段内引用同 perspective 实体；同 perspective 关系应写在 `## 关系`。

### 4.3 详细说明段

允许包含：

- 业务定义 / 关键职责 / 关键不变量
- 关键 ADR 摘要
- 通用语言列表
- 根实体 / API 列表 / 目标用户 / 验收标准
- 原 frontmatter 中下沉的业务属性

无内容时填 `(none)`。

### 4.4 依据与证据段

- 使用文件路径 + 章节锚点
- 多源用换行或分号串接
- 无额外来源时可保留 `示例数据`

---

## 5. 索引入口处理规则

典型见 §1.2。路径布局见 [knowledge-layout.md](../references/knowledge-layout.md)。

MUST：

- 目录说明清晰；当前目录关键文件与子目录入口齐全
- 与 concept / 叙事 / 元数据分型一致；不强行加 concept frontmatter
- bundle 根 `index.md` 的 OKF 区块 frontmatter **仅允许** `okf_version`

SHOULD：

- `README.md`：人类入口；`index.md`：渐进披露（根 = OKF 区块 + 目录索引；子目录 = 渐进披露）
- `<DOC_DIR>/INDEX-GUIDE.md`：九章机器索引（docs-indexing 骨架；第五章实体表由 docs-build 写入标记块）；`knowledge/index.md`：目录索引入口

MAY：索引入口可加「常见问题/反例」（哪些文件不应按实体概念写）。

---

## 6. 叙事文件处理规则

典型见 §1.3。overview 路径/行序/第三列落点见 [knowledge-layout.md](../references/knowledge-layout.md)；本文只定「叙事 / 非 concept」分型。

MUST：保持主题说明/架构叙事角色；不伪装成 concept；引用实体用稳定路径与术语（与本规范及实体文件一致）。

SHOULD：结构化 Markdown；overview 按「主标题/副标题/归档列」稳定维护（docs-tag / archive / extract 联动）。

MAY：HTML 注释作写作提示/占位，不影响正文可读性。

---

## 7. 元数据文件处理规则

典型见 §1.4。层设计 SSOT 见 [knowledge-governance.md](knowledge-governance.md)；链接路径语义见 [knowledge-layout.md](../references/knowledge-layout.md)。

MUST：保持规则 / 目录元信息 / 链接编排 / 运维日志职责；不按 concept schema 改造；引用本规范时统一指向本文件。

SHOULD：区分约定/枚举字段与解释性文字；运维留痕遵循各目录 README，避免多处定义同一条规则。

MAY：工具链 extensions 字段可加，须可控长期维护。

模式：`{DOC_DIR}/docs-meta.md`、`knowledge/knowledge-meta.md`、`knowledge/<perspective>/*-meta.md`；`knowledge-links.yaml`；`INDEXING-LOG.md`（`changelogs/`）；变更溯源 `git log` / `git diff`。

---

## 8. 目录哲学

### 8.1 父子同目录可见

有下层概念的目录，父子实体尽量同父层目录可见（如 `BSD-{ID}/` 下同时见 `BSD-{ID}.md` 与子 `{ID}.md`）。树形与落点见 [knowledge-layout.md](../references/knowledge-layout.md)。

### 8.2 父层目录的 `index.md`

每个含子概念目录必须提供 `index.md` 罗列子概念（OKF Concepts 列表）；样例见各层 `knowledge/` EXAMPLE 树，勿在本规范维护长清单。

---

## 9. 跨视角引用规则

| 引用类型 | 位置 | 形式 |
| --------- | ------ | ------ |
| 父子 / 聚合 / 能力 | `## 关系` | `parent:` / `children:` / `aggregates:` / `abilities:` |
| 应用实现 | `## 关系` | `implemented_by_app_id:` |
| 跨 perspective | `## 跨视角` | `business:` / `product:` / `application:` / `data:` / `technical:` |
| 证据来源 | `## 依据与证据` | 路径 + 锚点 |

补充规则：

- 同 perspective 内引用优先走 `## 关系`
- 跨层但同实体的“上游主定义”说明优先放在 `## 详细说明`
- 不要求在 frontmatter 中表达跨视角链路

---

## 10. company / system / application 三层共享模板

各层**重点概念 / 首次定义**见 [knowledge-governance.md § 各层聚焦摘要](knowledge-governance.md#各层聚焦摘要)。本节只补 OKF 文件组成差异：

### 10.1 company

公司级实体 + 治理叙事 + 系统槽位为主；叙事/元数据占比高，须严格区分 concept 与非 concept。

### 10.2 system

example 与叙事/目录组织更密；company 语义 → application 实现的中间层。

### 10.3 application

承接上游投影与实现细节；物理锚点、宿主信息与配置证据要求更高。

---

## 11. 校验与演进

### 11.1 layer_scope 规则

| layer_scope | 文件路径前缀 |
| ------------- | ------------- |
| `company` | `company/knowledge/...` |
| `system` | `system/knowledge/...` |
| `application` | `application/knowledge/...` |

### 11.2 tags 与 timestamp

- `tags` 必含 `[<perspective>, <hierarchy>]`
- `timestamp` 使用 ISO8601 UTC 格式：`YYYY-MM-DDTHH:MM:SSZ`

### 11.3 演进

- 不破坏兼容性的增量修改，在本规范末尾追加附录。
- 不兼容变更另起新版本文件，例如 `okf-spec-v2.md`。
- 允许扩展字段；但当扩展字段成为“本仓库共享约定”时，不允许静默新增，必须同步更新本规范。

### 11.4 删除旧规范约束

- 旧 system 下 schema 规范删除后，本文件为唯一 SSOT。
- 仓库内不应再出现对旧路径的引用。
