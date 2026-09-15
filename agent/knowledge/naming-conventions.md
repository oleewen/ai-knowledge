# ID 命名规范

> **定位**：知识实体 ID 的**字面语法**与 IDEA-ID 格式（必遵）。  
> **不分管**：缩写/短义/映射字段 → [glossary.md](glossary.md)；首次定义层 / 引用边界 → [knowledge-governance.md](knowledge-governance.md)；目录树 / overview / 槽位 / 阶段路径 → [knowledge-layout.md](../references/knowledge-layout.md)；文件分型与 concept `type` → [okf-spec.md](okf-spec.md)。

**适用范围**：`application/`、`system/`、`company/` 及联邦槽位 `system/application-slots/application-{NAME}/`、`company/system-slots/system-{NAME}/` 下的 `knowledge/` 实体。

---

## 1. 实体 ID 格式

- **通用格式**：`{TYPE}-{NAME}`
  - `TYPE`：实体缩写，登记见 [glossary.md § 实体缩写登记](glossary.md#实体缩写登记)（如 `BD`、`CAP`、`API`）
  - `NAME`：英文短名，建议大写 + 连字符
- **示例**：`BD-CHARGING-APPEAL`、`CAP-ORDER-FULFILL`、`BC-BILLING-APPEAL-CORE`、`FT-BILLING-APPEAL-LIFECYCLE`、`APP-BILLING-APPEAL-SERVICE`、`ENT-T_BILLING_APPEAL`、`TPL-K8S-PLATFORM`、`MW-KAFKA-ORDER-EVENTS`、`CMP-DUBBO-CLIENT`

跨层**首次定义**见 [knowledge-governance.md#各层聚焦摘要](knowledge-governance.md#各层聚焦摘要)，不在本文件复述。

---

## 2. IDEA-ID

需求链统一标识：格式 `*-{YYMMDD}-{主题slug}` 中的 `{YYMMDD}-{主题slug}` 段。

各阶段类型前缀示例：`SOLUTION` / `ANALYSIS` / `REQUIREMENT`（目录）/ `PRD` / `ASD` / `DSD` / `TDD` 等。阶段目录落点见 [knowledge-layout.md](../references/knowledge-layout.md)。

---

## 3. 引用字面量

跨文件、跨视角在 frontmatter / 映射字段中**写实体 ID 字符串**（及 [glossary.md § 映射关系](glossary.md#映射关系常用) 所列字段），不写显示名替代 ID。

业务 `*/knowledge/**` 跨层链形态（有 parent → HTTP / 无 parent → 纯 ID）见 [knowledge-governance.md § 业务 knowledge 引用边界](knowledge-governance.md#业务-knowledge-引用边界)，本文件不另定规则。
