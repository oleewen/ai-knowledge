# ID 命名规范

> **定位**：知识实体 ID 的**字面语法**与 IDEA-ID 格式（必遵）。  
> **不分管**：缩写/短义 → [glossary.md](glossary.md)；关系字段 → [entity-relations.md](entity-relations.md)；首次定义层 → [knowledge-governance.md](knowledge-governance.md)；引用边界 → [knowledge-reference-rules.md](knowledge-reference-rules.md)；目录树 / overview / 槽位 / 阶段路径 → [knowledge-layout.md](../references/knowledge-layout.md)；文件分型与 concept `type` → [okf-spec.md](okf-spec.md)。

**适用范围**：`application/`、`system/`、`solution/`、`company/` 及联邦槽位 `system/application-slots/application-{NAME}/`、`solution/system-slots/system-{NAME}/`、`company/solution-slots/solution-{NAME}/` 下的 `knowledge/` 实体。

---

## 1. 实体 ID 格式

- **通用格式**：`{TYPE}-{NAME}`
  - `TYPE`：实体缩写，登记见 [glossary.md § 实体缩写登记](glossary.md#实体缩写登记)（如 `BD`、`CAP`、`API`）
  - `NAME`：英文短名，建议大写 + 连字符
- **示例**：`BD-CHARGING-APPEAL`、`CAP-ORDER-FULFILL`、`BC-BILLING-APPEAL-CORE`、`FT-BILLING-APPEAL-LIFECYCLE`、`APP-BILLING-APPEAL-SERVICE`、`ENT-T_BILLING_APPEAL`、`TPL-K8S-PLATFORM`、`MW-KAFKA-ORDER-EVENTS`、`CMP-DUBBO-CLIENT`

特殊字面格式：

| 实体 | 格式 |
| --- | --- |
| BSD-L1 | `BSD-{NAME}` |
| BSD-L2 / BSD-L3 | 推荐 `BSD-{NAME}-L2` / `BSD-{NAME}-L3`；`-L2` / `-L3` 后缀可选，层级以 frontmatter `level` 为准 |
| API | `API-{NNN}` 或 `API-{NAME}-{NNN}` |
| ENT | `ENT-{NNN}` 或 `ENT-{NAME}` |

跨层**首次定义**见 [knowledge-governance.md#各层聚焦摘要](knowledge-governance.md#各层聚焦摘要)，不在本文件复述。

### 身份范围与限定引用

`id` 和 `{ID}.md` 保留上表的局部字面格式；用于查重、目标解析和跨库引用的完整身份按下表确定。`/` 是限定身份分隔符，不代表文件路径，不写入局部 `id` 或文件名。

| 实体 | 唯一范围 | 完整身份 |
| --- | --- | --- |
| APP | 当前治理联邦内唯一 | `APP-ID` |
| MS | 所属 APP 内唯一 | `APP-ID/MS-ID` |
| API | 所属 MS 内唯一 | `APP-ID/MS-ID/API-ID` |
| 其他实体 | 保持全局唯一要求 | 原实体 ID |

归属取已核实的 `MS.implements_to APP`、`API.implements_to MS`；每条归属恰好一个目标。TBL、MW、CMP 不采用 APP/MS 消歧，不把 `uses_to` 当所有权。APP 不等于仓名、槽位名或部署路径。

例：`APP-ORDER/MS-QUERY/API-001` 与 `APP-PAY/MS-QUERY/API-001` 是两个不同实体。跨文件引用 MS/API 使用完整身份；关系目标类型取最后一段，不能用首段 APP 判断目标类型。同层 Markdown 链仍须解析到实际文件，并核对完整身份；跨层受 [引用规范](knowledge-reference-rules.md) 约束。

既有裸 MS/API ID 只有在已声明的查找范围内唯一且归属链已核实时才能补全；匹配多个目标或归属不明即停止受影响写入，不按扫描顺序任选。完整身份只能消歧，SSOT 文件定位还须核实实体台账及联邦登记，不能凭身份猜文件路径。

查重须报告实际覆盖的库与范围；未读取整个声明范围时不得宣称全局唯一。发现冲突先解决身份，不静默覆盖。归属前缀变化遵 [身份迁移与删除](knowledge-governance.md#身份迁移与删除)。

**工具接入边界**：统一校验、OKF 跨层定位、导航与可视化已共用完整身份目录；歧义候选不覆盖、不任选。API 新建路径含 APP/MS，旧路径只读兼容。`--move-identity` / `--to-owner` 仅输出身份、路径、引用及 dependency 登记影响与阻塞，不执行迁移；用法见[共享工具](../scripts/README.md#统一知识校验)。旧底层校验类不代表本契约全部覆盖。

---

## 2. IDEA-ID

需求链统一标识：格式 `*-{YYMMDD}-{主题slug}` 中的 `{YYMMDD}-{主题slug}` 段。

各阶段类型前缀示例：`SOLUTION` / `ANALYSIS` / `REQUIREMENT`（目录）/ `PRD` / `ASD` / `DSD` / `TDD` 等。阶段目录落点见 [knowledge-layout.md](../references/knowledge-layout.md)。

---

## 3. 引用字面量

跨文件、跨视角在映射字段中使用上述完整身份及 [实体关系模型](entity-relations.md) 所列字段，不写显示名替代身份；实体 frontmatter 的 `id` 仍为局部 ID。

业务 `*/knowledge/**` 跨层链形态（有 parent → HTTP / 无 parent → 纯 ID）见 [业务 knowledge 引用规范](knowledge-reference-rules.md)，本文件不另定规则。
