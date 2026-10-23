# 知识库布局契约（Agent SSOT）

> **职责**：四层文档根、实体物理路径、索引落点与阶段目录。
> **边界**：实体归属见 [knowledge-governance.md](../knowledge/knowledge-governance.md)；字段见五视角 meta；文件格式见 [okf-spec.md](../knowledge/okf-spec.md)；联邦清单见 [federation-config.md](../knowledge/federation-config.md)；overview 表结构见 [overview-spec.md](../knowledge/overview-spec.md)。

**最后更新**: 2026-10-23

## 四层文档根

四层知识均落 `{DOC_DIR}/knowledge/`。下表使用元库目录名；消费库以 `.docsconfig` 的 DOC_DIR 为文档根。

| 层 | 人类入口 | 联邦槽位 |
| --- | --- | --- |
| 公司 | [README](../../company/README.md) · [DESIGN](../../company/DESIGN.md) | `company/solution-slots/solution-{NAME}/` |
| 解决方案 | [README](../../solution/README.md) · [DESIGN](../../solution/DESIGN.md) | `solution/system-slots/system-{NAME}/` |
| 系统 | [README](../../system/README.md) · [DESIGN](../../system/DESIGN.md) | `system/application-slots/application-{NAME}/` |
| 应用 | [README](../../application/README.md) · [DESIGN](../../application/DESIGN.md) | 无 |

层级与 parent 基数以[治理规则](../knowledge/knowledge-governance.md#四层职责边界)为准；槽位不能成为业务 knowledge 的链接目标，见[引用规范](../knowledge/knowledge-reference-rules.md)。

## 文件与目录落点

### 通用落点

| 对象 | 路径 / 规则 |
| --- | --- |
| 层根契约 | `{DOC_DIR}/DESIGN.md` |
| 知识树入口 | `{DOC_DIR}/knowledge/README.md` |
| 视角实体 | `knowledge/{business,product,application,data,technical}/…/{ID}.md`；目录与实体 ID 一致，或在索引中按 ID 查找 |
| 字段定义 | `agent/knowledge/{perspective}-meta.md` §2；应用注册等可使用 `{id}.yaml`，实体正文仍遵 OKF |
| 目录导航 | `knowledge/index.md` 及子目录 `index.md`，由 docs-okf 维护；含子概念的目录必须提供 index.md |
| 实体台账 | 各视角 README；视角导航在 INDEX-GUIDE.md 第四章，由 docs-build 维护 |
| 阶段说明 | 各阶段目录 README |
| ADR | 四层各自 `adr/`；命名与台账见 [adr-guidelines.md](../knowledge/adr-guidelines.md) |

**实体目录父级**：从正文关系段先取同层 `parent`，没有则取同层 `implements_to`；跨层关系不参与本层路径推导，frontmatter 不另写路径父级。有子概念的父实体与子实体尽量在父层目录可见。上层 ID 可以作宿主目录，不能据此推定可复制上层实体；例外以[治理规则](../knowledge/knowledge-governance.md#各层聚焦摘要)为准。

### 各层路径差额

下表相对各层 `knowledge/`；仅定义物理落点，不重复实体归属与关系语义。

| 层 / 视角 | 路径差额 |
| --- | --- |
| 公司 / 业务 | `business/BD/{BD-ID}/{BD-ID}.md`，BSD-L1 同域目录；`business/BL/{BL-ID}.md`；`business/{VC-ID}/`，CAP 可同 VC 目录或在 CAP/ 子目录 |
| 公司 / 技术 | `technical/TPL/{TPL-ID}.md` |
| 解决方案 / 业务 | BSD-L2：`business/BSD-*-L1/{ID}/{ID}.md`，L1 为目录宿主；将 L2 ID 的 `-L2` 后缀替换为 `-L1` 得宿主名 |
| 解决方案 / 产品 | PL：`product/{PL-ID}/{PL-ID}.md`；PD：`product/{PL-ID}/{PD-ID}.md`；BP/BSP 保持 BP/ 类型桶 |
| 解决方案 / 技术 | `technical/TS/{ID}.md` |
| 系统 / 业务 | `business/BSD-{L2}/BSD-{L3}/BSD-{L3}.md`，其下 BC/AGG/AB；L2 为宿主，不加 L1 段。元模板不落 L2 实体，既有业务仓聚合例外见治理规则 |
| 系统 / 产品 | 可留 `product/PD-{NAME}/` 宿主，其下 PM 目录承载 FT/FR/UC/BR |
| 系统 / 应用 | `application/SYS-{NAME}/APP-{NAME}/MS-{NAME}/`；允许仓内既有扁平 MS-*.md 形态 |
| 系统 / 数据 | `data/MDG-{NAME}/DS-{NAME}/`，承载 DS/ENT；MDG 为宿主 |
| 应用 / 接口 | `application/MS-{NAME}/` 可作 API 宿主，不据此创建 MS 实体 |

未单列的实体遵通用落点及现有层模板；ID 字面规则见 [naming-conventions.md](../knowledge/naming-conventions.md)。

## overview

四层统一使用 `{DOC_DIR}/knowledge/overview/{NAME}-overview.md`。表结构、层级内容边界、章节顺序和写入技能只在 [overview-spec.md](../knowledge/overview-spec.md) 维护；第三列算法由该规范链接到技能真源。

## 知识流水线

此节仅提供入口顺序，执行规则由各技能维护：

1. [docs-link](../skills/docs-link/SKILL.md)：登记清单、建槽位；`--check` 只读检查，异常槽位逐项 `--repair`。内容更新走下级仓普通 Git 工作流；槽位维护不访问远端、不改 Git 状态。
2. [docs-distill](../skills/docs-distill/SKILL.md)：从槽位上行提炼到目标层 overview，不写 DISTILL-LOG；非槽位源走 [docs-extract](../skills/docs-extract/SKILL.md)。适用层见 [overview-spec.md](../knowledge/overview-spec.md#写入能力)。
3. [docs-tag](../skills/docs-tag/SKILL.md) 标记关键词、摘录架构；[docs-archive](../skills/docs-archive/SKILL.md) 归档到本层五视角。

## SDD 与 KNOWLEDGE_TYPE

| KNOWLEDGE_TYPE | 阶段目录 | 不建立 |
| --- | --- | --- |
| `company` | `domains/`、`adr/` | solutions / analysis / features / requirements |
| `solution` | `solutions/`、`adr/` | analysis / features / requirements |
| `system` / `application` | `analysis/`、`features/`、`requirements/REQUIREMENT-{IDEA-ID}/`、`adr/` | solutions |

系统/应用由 `/sdx-analysis` 从原始输入写七章 ANALYSIS（不等 SOLUTION），`/sdx-feature` 写六章 FEATURE；PRD/ASD/DSD/TDD 落 requirements。样例为 `analysis/ANALYSIS-EXAMPLE.md`、`features/FEATURE-EXAMPLE.md`。IDEA-ID 见[命名规范](../knowledge/naming-conventions.md#2-idea-id)。

公司 domains 表达 BD/BSD-L1 如何支撑 VC，不放 SLN；解决方案 solutions 表达交付包切分。系统联邦 ASD 概要与应用详设的分工见 [knowledge-type-modes.md](../skills/sdx-architect/references/knowledge-type-modes.md)。可选会话稿另遵 [session-spec-path.md](session-spec-path.md)。
