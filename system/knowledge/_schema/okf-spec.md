---
type: OKF Schema
title: OKF v1 规则文档
description: OKF（Open Knowledge Framework）per-entity concept 的统一 schema 规范，定义 frontmatter 字段、正文 4 段结构、目录哲学与跨视角引用规则。本文档为 ai-knowledge 与下游仓库的 SSOT。
tags: [okf, schema, ssoT]
timestamp: "2026-06-23T00:00:00Z"
version: "1.0"
layer_scope: system
---

# OKF v1 规则文档

> **谷歌OKF规范参考**：[github.com/google/open-knowledge-framework](https://github.com/google/open-knowledge-framework)
> **SSOT**：本仓库 `system/knowledge/_schema/okf-spec.md`（单一事实源）
> **示例**：`system/knowledge/{business,product}` 下的 5+3 个 example（BD-EXAMPLE / BSD-EXAMPLE+BC-EXAMPLE+AGG-EXAMPLE+AB-EXAMPLE / PM-EXAMPLE+FT-EXAMPLE+UC-EXAMPLE-001）

---

## 0. 版本与适用范围

| 字段 | 取值 |
|------|------|
| OKF 版本 | v1 |
| 适用范围 | ai-knowledge 仓库 + 下游 policy-vas-docs 等同步仓库 |
| shape-of-truth | `system/knowledge/{business,product}/` 8 个 example 文件 |
| 演进 | 演进走 v2（不向后兼容时强制升级）；不破坏 v1 兼容性走增量附录 |

---

## 1. frontmatter schema

每个 per-entity 文件**必须**包含以下 10 字段。

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `type` | 枚举 | ✅ | 层级英文名，§2 映射表 |
| `title` | 字符串 | ✅ | 中文名（实体显示名） |
| `description` | 字符串 \| null | ✅ | 业务定义短句；无定义时填 `null` |
| `tags` | 字符串数组 | ✅ | 必含 `[<perspective>, <hierarchy>]`，如 `[business, BD]` |
| `timestamp` | ISO8601 字符串 | ✅ | 形如 `2026-06-23T00:00:00Z` |
| `full_id` | 字符串 | ✅ | 全局唯一 ID，格式：`<hierarchy>-<name>`，如 `BD-VALUE-ADDED-CHARGING` |
| `perspective` | 枚举 | ✅ | `business` / `product` / `application` / `data` / `technical` |
| `hierarchy` | 枚举 | ✅ | §2 映射表（与 type 一致） |
| `parent_id` | 字符串 \| null | ✅ | 父层 full_id；BD 与 PL 允许 `null`；其他层级必填 |
| `layer_scope` | 枚举 | ✅ | `company` / `system`；与文件路径前缀对应（§9） |

**禁止字段**（不得出现在 frontmatter）：

```
id（仅 OKF 内部序号，无语义）
alias（中文叙述应放入「详细说明」段）
children / bounded_contexts / aggregates / abilities（应放入「关系」段）
ubiquitious_language / root_entity / entities / invariants（应放入「详细说明」段）
capability / apis / target_users（应放入「详细说明」段）
invokes_api_ids / realizes_use_case_ids / acceptance_criteria（应放入「详细说明」段）
strategic_classification（公司层 BD 用，公司层投影才需）
cross_references / evidence_chain（应放入正文「跨视角」段与「依据与证据」段）
```

---

## 2. type 与 hierarchy 映射表

24 行精确映射。**`type` 与 `hierarchy` 必须一一对应**。

| hierarchy | type | perspective | 知识库 |
|-----------|------|-------------|--------|
| BD | `Business Domain` | business | company |
| CAP | `Business Capability` | business | company |
| PL | `Product Line` | product | company |
| SYS | `System` | application | company |
| MDG | `Master Data Domain` | data | company |
| TPL | `Technical Platform` | technical | company |
| BSD | `Business Subdomain` | business | system |
| BC | `Bounded Context` | business | system |
| AGG | `Aggregate` | business | system |
| AB | `Ability` | business | system |
| PM | `Product Module` | product | system |
| BP | `Business Process` | product | system |
| FT | `Feature` | product | system |
| UC | `Use Case` | product | system |
| BR | `Business Rule` | product | system |
| APP | `Application` | application | system |
| MS | `Microservice` | application | system |
| DS | `Data Store` | data | system |
| ENT | `Entity` | data | system |
| TSD | `Technical Subdomain` | technical | system |
| API | `API Endpoint` | application | application |
| TBL | `Data Table` | data | application |
| MW | `Middleware Binding` | technical | application |
| CMP | `Component` | technical | application |

> 说明：本仓库暂无 application / data / technical 视角的 example（缺源码）；预留 perspective 枚举以便后续扩展。

---

## 3. 4 段正文结构

每个 per-entity 文件**必须**包含 4 个二级标题。OKF v1 的语义分段保持不变，但本仓库落地标题统一使用中文，英文仅作为语义映射参考。

| 顺序 | 标题 | 内容 |
|------|------|------|
| 1 | `## 关系`（Relations） | 父子、聚合、能力、应用实现指针（按层级差异化） |
| 2 | `## 跨视角`（Cross-perspective） | 跨 perspective 引用（business↔product↔application↔data↔technical） |
| 3 | `## 详细说明`（Details） | 业务定义、不变量、关键 ADR、关键职责、验收标准等中文叙述 |
| 4 | `## 依据与证据`（Evidence） | 文件路径 + 章节锚点（多源用换行或分号） |

### 3.1 关系段（Relations，按层级差异化）

| 层级 | 必含子段 | 选含子段 |
|------|---------|---------|
| BD | `parent: null` + `children: [...]` | — |
| BSD | `parent: [...]` + `bounded_contexts: [...]` | — |
| BC | `parent: [...]` + `aggregates: [...]` | — |
| AGG | `parent: [...]` + `abilities: [...]` | — |
| AB | `parent: [...]` + `implemented_by_app_id: [...]`（允许 `(none)`） | — |
| PL | `children: [...]` | `parent: null` |
| PM | `parent: [...]` + `children: [...]` | — |
| FT | `parent: [...]` + `children: [...]`（如有 UC 子节点） | — |
| UC | `parent: [...]` | — |

**指针格式**：
- 同文件目录：`[X-XXX](X-XXX.md)` 或 `[X-XXX](X-XXX/X-XXX.md)`
- 跨 perspective：`[X-XXX](../../<other-perspective>/X-XXX/X-XXX.md)`

### 3.2 跨视角段（Cross-perspective）

- 跨 perspective 引用：明列 `business:` / `product:` / `application:` / `data:` / `technical:` 子段
- 无引用时填 `(none)`，对应 perspective 子段可省略
- 本仓库无源码时 `application:` / `data:` / `technical:` 统一标 `(none)` 或 `待源码/工程化阶段补充`

### 3.3 详细说明段（Details）

中文短句段落。允许包含：
- 业务定义 / 关键职责 / 关键不变量
- 关键 ADR 摘要（链接到 `adr/` 路径）
- 通用语言（ubiquitous language）列表
- 根实体 / 实体列表 / API 列表 / 验收标准 / 目标用户

**模板**：无“详细说明”内容时填 `(none)`（与 example 一致）

### 3.4 依据与证据段（Evidence）

- 文件路径 + 章节锚点
- 多源用换行或分号串接
- 模板（与 example 一致）：
  - `docs/knowledge/business/business-domain-division.md §核心域`
  - `docs/knowledge/business/business-rules-and-strategies.md PM-002/BR-001`

---

## 4. 目录哲学

### 4.1 父子同目录可见

example 哲学：**BC/AGG/AB 全部放在父层目录内**，肉眼可见父子从属。

```
business/
├── BD-EXAMPLE.md                    ← 独立文件（无目录）
├── business-overview.md
├── BSD-EXAMPLE/                     ← BSD 独立目录
│   ├── BSD-EXAMPLE.md               ← BSD 文件
│   ├── BC-EXAMPLE.md                ← BC 文件下沉到 BSD 目录
│   ├── AGG-EXAMPLE.md               ← AGG 文件下沉到 BSD 目录
│   ├── AB-EXAMPLE.md                ← AB 文件下沉到 BSD 目录
│   └── index.md
└── ...
```

### 4.2 product 侧

```
product/
├── PL-XXX.md                        ← PL 独立文件
├── PM-EXAMPLE/                      ← PM 独立目录
│   ├── PM-EXAMPLE.md
│   ├── FT-EXAMPLE.md                ← FT 文件下沉到 PM 目录
│   ├── UC-EXAMPLE-001.md            ← UC 文件下沉到 PM 目录
│   └── index.md
└── ...
```

### 4.3 父层目录的 `index.md`

每个**含子概念**的目录必须挂 `index.md` 罗列子概念。模板参考 `system/knowledge/business/BSD-EXAMPLE/index.md`：

```markdown
# BSD-EXAMPLE

## Concepts

* [示例业务能力](AB-EXAMPLE.md)
* [示例聚合](AGG-EXAMPLE.md)
* [示例限界上下文](BC-EXAMPLE.md)
* [示例业务子域](BSD-EXAMPLE.md) - 仅用于演示业务视角数据结构（示例）。
```

---

## 5. 跨视角引用规则

| 引用类型 | 位置 | 形式 |
|---------|------|------|
| 父子 / 聚合 / 能力 | 关系段 | `parent: [...]` / `children: [...]` / `bounded_contexts: [...]` / `aggregates: [...]` / `abilities: [...]` |
| 应用实现 | 关系段 | `implemented_by_app_id: [...]`（仅 AB） |
| 跨 perspective | 跨视角段 | `business:` / `product:` / `application:` / `data:` / `technical:` |
| 段内引用 | 跨视角段内 | 同 perspective 引用走关系段；**禁止**在跨视角段内引同 perspective 实体 |

---

## 6. 依据与证据多源表达

- **多源用换行或分号串接**：
  ```markdown
  ## 依据与证据

  docs/knowledge/business/business-domain-division.md §核心域
  docs/knowledge/business/business-rules-and-strategies.md PM-002/BR-001
  ```
- **可信度不强制 frontmatter 字段**：v1 不引入 `confidence` 字段；可信度由“依据与证据”段的来源（业务域划分 high / 业务规则 high / 第三方文档 medium）隐式表达
- **多源不必区分类型**：v1 不引入 `type: document | interview | data` 字段

---

## 7. parent_id 引用规则

- `parent_id` 必填；BD 与 PL 允许 `null`
- `parent_id` 指向的 `full_id` **必须**在同 perspective 内存在
- 同 perspective 内 full_id 唯一性：
  - 不允许 `full_id` 重复
  - 不允许 `full_id` 与 `parent_id` 冲突
  - 不允许 `full_id` 形成循环（A.parent=B, B.parent=C, C.parent=A）

---

## 8. tags 与 timestamp 规则

### 8.1 tags

- 必含 `[<perspective>, <hierarchy>]`
- 例：`tags: [business, BD]`
- 可选额外标签：`[okf, ssoT]`（本文档类型）/ `[example]`（example 演示用）

### 8.2 timestamp

- ISO8601 格式：`YYYY-MM-DDTHH:MM:SSZ`
- 含义：实体**最后修订时间**（非创建时间）
- 校验器 R9 仅校验格式合法性，不校验时间值的合理性

---

## 9. layer_scope 规则

| layer_scope | 文件路径前缀 | 含义 |
|-------------|-------------|------|
| `application` | `application/knowledge/...` | 应用层投影（联邦 bundle 槽位） |
| `company` | `company/knowledge/...` | 公司层 SSOT，公司级字段 |
| `system` | `system/knowledge/...` | 系统层投影 |

**约束**：
- `layer_scope` 与文件路径前缀必须一致
- `application/knowledge/...` ⇒ `layer_scope: application`
- `company/knowledge/...` ⇒ `layer_scope: company`
- `system/knowledge/...` ⇒ `layer_scope: system`
- 单一仓库内**不**允许 `layer_scope` 与路径前缀错位
- v1 阶段三 bundle 全部支持（应用 / 公司 / 系统）

---

## 10. 与 example 的对照

11 个 example 文件（5+3 基础 + 3 流程/规则/数据表扩展），分布在 company / system / application 三层。

### 10.1 基础 8 个 example（system bundle）

| 字段 | BD-EXAMPLE | BSD-EXAMPLE | BC-EXAMPLE | AGG-EXAMPLE | AB-EXAMPLE | PM-EXAMPLE | FT-EXAMPLE | UC-EXAMPLE-001 |
|------|------------|-------------|------------|-------------|------------|------------|------------|----------------|
| `type` | Business Domain | Business Subdomain | Bounded Context | Aggregate | Ability | Product Module | Feature | Use Case |
| `tags` | `[business, BD]` | `[business, BSD]` | `[business, BC]` | `[business, AGG]` | `[business, AB]` | `[product, PM]` | `[product, FT]` | `[product, UC]` |
| `parent_id` | `null` | `BD-EXAMPLE` | `BSD-EXAMPLE` | `BC-EXAMPLE` | `AGG-EXAMPLE` | `PL-EXAMPLE` | `PM-EXAMPLE` | `FT-EXAMPLE` |
| `layer_scope` | `system` | `system` | `system` | `system` | `system` | `system` | `system` | `system` |
| 关系段 | `children:` | `parent: + bounded_contexts:` | `parent: + aggregates:` | `parent: + abilities:` | `parent: + implemented_by_app_id:` | `parent: + children:` | `parent: + children:` | `parent:` |
| 跨视角段 | `(none)` | `(none)` | `(none)` | `(none)` | `implemented_by_app_id: [APP-EXAMPLE]` | `(none)` | `(none)` | `(none)` |
| 详细说明段 | `(none)` | `(none)` | `(none)` | `(none)` | `(none)` | `(none)` | `(none)` | `(none)` |
| 依据与证据段 | `示例数据` | `示例数据` | `示例数据` | `示例数据` | `示例数据` | `示例数据` | `示例数据` | `示例数据` |

### 10.2 扩展 3 个 example（BP / BR / TBL）

| 字段 | BP-EXAMPLE | BR-EXAMPLE | TBL-EXAMPLE |
|------|------------|------------|-------------|
| `type` | Business Process | Business Rule | Data Table |
| `tags` | `[product, BP]` | `[product, BR]` | `[data, TBL]` |
| `parent_id` | `PM-EXAMPLE` | `PM-EXAMPLE` | `DS-EXAMPLE` |
| `layer_scope` | `system` | `system` | `application` |
| 关系段 | `parent:` | `parent:` | `parent:` |
| 跨视角段 | `(none)` | `(none)` | `(none)` |
| 详细说明段 | `(none)` | `(none)` | `(none)` |
| 依据与证据段 | `示例数据` | `示例数据` | `示例数据` |

### 10.3 落点

| example | 路径 | 父层目录 |
|---------|------|---------|
| BP-EXAMPLE | `system/knowledge/product/PM-EXAMPLE/BP-EXAMPLE.md` | `PM-EXAMPLE/` |
| BR-EXAMPLE | `system/knowledge/product/PM-EXAMPLE/BR-EXAMPLE.md` | `PM-EXAMPLE/` |
| TBL-EXAMPLE | `application/knowledge/data/DS-EXAMPLE/TBL-EXAMPLE.md` | `DS-EXAMPLE/` |

---

## 11. 演进与版本

| 事件 | 处理 |
|------|------|
| v1 增量（不破坏兼容性） | 在本 spec 末尾追加 §12+ 附录 |
| v1 不兼容变更 | 新增 `system/knowledge/_schema/okf-spec-v2.md`，**旧 v1 spec 不删除**，作为历史快照 |
| 校验器同步 | 校验器版本与 spec 同步标注 v1；演进时新增 `check-okf-schema-v2.sh` 平行运行 |

**禁止行为**：
- ❌ 静默修改 v1 spec 字段
- ❌ 删除 v1 spec
- ❌ 在 frontmatter 引入新字段而不更新 spec
