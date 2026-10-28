# 知识库布局契约（Agent SSOT）

> **职责**：四层文档根、实体物理路径、索引落点与阶段目录。
> **边界**：实体归属见 [knowledge-governance.md](../knowledge/knowledge-governance.md)；字段见五视角 meta；文件格式见 [okf-spec.md](../knowledge/okf-spec.md)；联邦清单见 [federation-config.md](../knowledge/federation-config.md)；overview 表结构见 [overview-spec.md](../knowledge/overview-spec.md)。

**最后更新**: 2026-10-28

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
| 视角实体 | `knowledge/{business,product,application,data,technical}/…/{ID}.md`；文件名保留局部 ID，台账按完整身份定位 |
| 字段定义 | `agent/knowledge/{perspective}-meta.md` §2；应用注册等可使用 `{id}.yaml`，实体正文仍遵 OKF |
| 目录导航 | `knowledge/index.md` 及子目录 `index.md`，由 docs-okf 维护；含子概念的目录必须提供 index.md |
| 实体台账 | 各视角 README；视角导航在 INDEX-GUIDE.md 第四章，由 docs-build 维护 |
| 阶段说明 | 各阶段目录 README |
| ADR | 四层各自 `adr/`；命名与台账见 [adr-guidelines.md](../knowledge/adr-guidelines.md) |

**实体目录父级**：从正文关系段先取同层 `parent`，没有则取同层 `implements_to`；frontmatter 不另写路径父级。跨层关系仅在下表明确的宿主场景提供已核实宿主 ID，不沿跨层父链普遍推导本层路径。有子概念的父实体与子实体尽量在父层目录可见。上层 ID 可以作宿主目录或普通导航，不能复制上层实体。

### 各层路径差额

下表相对各层 `knowledge/`；仅定义物理落点，不重复实体归属与关系语义。

| 层 / 视角 | 路径差额 |
| --- | --- |
| 公司 / 业务 | `business/BD/{BD-ID}/{BD-ID}.md`，BSD-L1 同域目录；`business/BL/{BL-ID}.md`；`business/{VC-ID}/`，CAP 可同 VC 目录或在 CAP/ 子目录 |
| 公司 / 技术 | `technical/TPL/{TPL-ID}.md` |
| 解决方案 / 业务 | BSD-L2：`business/{L1宿主}/{ID}/{ID}.md`；新建时从已核实 L1 `parent` 取得显式宿主，不从子 ID 换后缀猜名。既有实体沿用核实后的实际目录链（含旧 `BSD-*-L1` 宿主）；目录名不反推关系。缺宿主或显式宿主与既有落点冲突时停止生成并澄清 |
| 解决方案 / 产品 | PL：`product/{PL-ID}/{PL-ID}.md`；PD：`product/{PL-ID}/{PD-ID}.md`；BP/BSP 保持 BP/ 类型桶 |
| 解决方案 / 技术 | `technical/TS/{ID}.md` |
| 系统 / 业务 | `business/BSD-{L2}/BSD-{L3}/BSD-{L3}.md`，其下 BC/AGG/AB；L2 仅宿主，不加 L1 段，不落 L2 实体；聚合使用普通 README/index |
| 系统 / 产品 | 可留 `product/PD-{NAME}/` 宿主，其下 PM 目录承载 FT/FR/UC/BR |
| 系统 / 应用 | `application/SYS-{NAME}/APP-{NAME}/MS-{NAME}/`；既有扁平 MS-*.md 仅在完整身份能唯一解析且路径不冲突时保留 |
| 系统 / 数据 | `data/MDG-{NAME}/DS-{NAME}/`，承载 DS/ENT；MDG 为宿主 |
| 应用 / 接口 | 新建采用 `application/{APP-ID}/{MS-ID}/{API-ID}.md`，APP/MS 仅目录宿主。既有 `application/{MS-ID}/` 可在归属链核实且路径不冲突时保留，不自动迁移 |

未单列的实体遵通用落点及现有层模板；ID 字面规则见 [naming-conventions.md](../knowledge/naming-conventions.md)。

身份与物理路径分开：限定身份不是 href，目录名不能替代归属证据；完整身份到已有文件须核对台账。旧路径生成器尚未接入限定身份时，不用它处理局部重名实体；新增 APP 宿主布局须待工具兼容后执行。

### 治理元数据

下列容器位于 knowledge 外，按需建立，不属于业务实体或阶段产物；不要求初始化时创建空目录。

| 对象 | 路径 | 契约 |
| --- | --- | --- |
| 持久证据登记 | `{DOC_DIR}/governance/evidence/` | [知识证据](../knowledge/knowledge-evidence.md)；纳入版本管理，不复制源正文 |
| 联邦操作恢复记录 | `{DOC_DIR}/governance/operations/` | [联邦配置](../knowledge/federation-config.md)；区分操作进度与完成，不替代知识证据 |
| Profile 采用记录 | `{DOC_DIR}/governance/profile.md` | [Profile v2](../knowledge/knowledge-profile-v2.md#采用记录)；记录规则与工具基线、迁移状态，不替代内容发布版本 |

元库按被处理层使用 `company|solution|system|application` 文档根，不把本仓 `.docsconfig` 的默认层当作所有对象的落点。证据记录不进入实体图；临时恢复材料也不充当正式知识入口。TODO 仅记录开放动作，不能替代上述持久记录。

## overview

四层统一使用 `{DOC_DIR}/knowledge/overview/{NAME}-overview.md`。表结构、层级内容边界、章节顺序与共用增量语义只在 [overview-spec.md](../knowledge/overview-spec.md) 维护；各技能维护自身输入、写入与回写方式。

## 知识流水线

此节仅提供入口顺序，执行规则由各技能维护：

1. [docs-link](../skills/docs-link/SKILL.md)：登记清单、建槽位；`--check` 只读检查，异常槽位逐项 `--repair`。内容更新走下级仓普通 Git 工作流；槽位维护不访问远端、不改 Git 状态。
2. [docs-distill](../skills/docs-distill/SKILL.md)：从槽位上行提炼到目标层 overview，不写 DISTILL-LOG 运行史；来源与派生目标另记 [持久证据](../knowledge/knowledge-evidence.md)。非槽位源走 [docs-extract](../skills/docs-extract/SKILL.md)，消费登记不自动加入槽位蒸馏。适用层见 [overview-spec.md](../knowledge/overview-spec.md#写入能力)。
3. [docs-tag](../skills/docs-tag/SKILL.md) 标记关键词、摘录架构；[docs-archive](../skills/docs-archive/SKILL.md) 归档到本层五视角。

## SDD 与 KNOWLEDGE_TYPE

| KNOWLEDGE_TYPE | 阶段目录 | 不建立 |
| --- | --- | --- |
| `company` | `domains/`、`adr/` | solutions / analysis / features / requirements |
| `solution` | `solutions/`、`adr/` | analysis / features / requirements |
| `system` / `application` | `analysis/`、`features/`、`requirements/REQUIREMENT-{IDEA-ID}/`、`adr/` | solutions |

系统/应用由 `/sdx-analysis` 从原始输入写七章 ANALYSIS（不等 SOLUTION），`/sdx-feature` 写六章 FEATURE；PRD/ASD/TDD 落 requirements。DSD 只落应用库；系统 ASD 内列应用承接清单。样例为 `analysis/ANALYSIS-EXAMPLE.md`、`features/FEATURE-EXAMPLE.md`。IDEA-ID 见[命名规范](../knowledge/naming-conventions.md#2-idea-id)。

公司 domains 表达 BD/BSD-L1 如何支撑 VC，不放 SLN；解决方案 solutions 表达交付包切分。系统联邦 ASD 概要与应用详设的分工见 [knowledge-type-modes.md](../skills/sdx-architect/references/knowledge-type-modes.md)。可选会话稿另遵 [session-spec-path.md](session-spec-path.md)。
