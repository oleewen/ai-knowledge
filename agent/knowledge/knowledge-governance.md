# 知识库治理规则

> **定位**：四层知识库**语义设计** SSOT（职责、各层聚焦/首次定义、5A 边类方向、引用边界）。  
> **层根人类入口**：[`company/DESIGN.md`](../../company/DESIGN.md) · [`solution/DESIGN.md`](../../solution/DESIGN.md) · [`system/DESIGN.md`](../../system/DESIGN.md) · [`application/DESIGN.md`](../../application/DESIGN.md)（契约短表 + 引用本文；本文仍为语义 SSOT）。  
> **不分管**：路径 / overview / 槽位 / 联邦流水线 → [knowledge-layout.md](../references/knowledge-layout.md)；ID 语法 → [naming-conventions.md](naming-conventions.md)；缩写/词义/映射字段 → [glossary.md](glossary.md)；文件分型 → [okf-spec.md](okf-spec.md)。  
> 组件索引与使用顺序见同目录 [README.md](README.md)。协作闸门见 [CONVENTIONS.md](../rules/CONVENTIONS.md)。

**最后更新**: 2026-10-04

---

## 使命

决策 **透明、一致、可追溯**，避免架构随口语漂移。

---

## 四层职责边界

| 层级 | 目录 | 治理职责 | 实体 SSOT（首次定义） |
| --- | --- | --- | --- |
| 公司 | `company/` | 完整价值链 VC；域架构（哪个 BD 支撑 VC）；企业技术准入 | VC、BD、CAP、BSD(L1)、PL、TPL |
| 解决方案 | `solution/` | 一个交付包（一仓一 SLN）；跨 SYS 共性（架构、模型、主流程、产品框架、数据主权、技术选型） | SLN、PD、BSD(L2)、MDG、TSD、BP |
| 系统 | `system/` | 一个 SYS 的实现边界与架构聚合；应用镜像槽位 | SYS、BC、AGG、AB、PM、FT、FR、UC、BR、APP、MS、DS、ENT |
| 应用 | `application/` | 实现级实体、SDD 阶段交付、物理锚点 | API、TBL、MW、CMP |

**命名、术语与 OKF 文件分型**：统一以 `agent/knowledge/` 为准（见 [README.md](README.md)）。路径与槽位名见 [knowledge-layout.md](../references/knowledge-layout.md)。实体首次定义细节见下文「各层聚焦摘要」。

| 面 | 规则 |
| --- | --- |
| 联邦 | parent 仅 `application → system → solution → company`（向上 1:1）。公司不直管系统。蒸馏按层上收，禁止跳层当默认 |
| 禁止 | 跨层字段语义双源；公司/解决方案正文写单应用实现细节 |
| 引用 | 有 parent → HTTP 到首次定义层 SSOT；无 parent → 纯 ID（详见下文「业务 knowledge 引用边界」） |
| 基数 | 一仓一 SLN；一 SLN 多个 PD；PD↔SYS **1:1** `maps_to`；BSD(L2)↔PD **1:1**；一 SLN 多个 MDG、多个 TSD |

---

## 各层聚焦摘要

**首次定义**以本节为准：= 治理语义、字段口径与上游主定义所在层；下游可做实例登记、实现映射、物理锚点或 reference，不等同于「只允许在该层出现」。他处不重复字段语义；缩写短义见 [glossary.md](glossary.md)；引用形态见「业务 knowledge 引用边界」。

### 公司层

| 视角 | 实体 | 公司层聚焦 |
| --- | --- | --- |
| 业务 | VC | 价值链；`supported_by`→BD，`implemented_by`→CAP |
| 业务 | BD | 业务域；`supports_to`→VC，`children`→BSD(L1) |
| 业务 | BSD(L1) | 公司层业务子域；`level: 1`，`parent`→BD，`maps_to`→PL\|CAP |
| 业务 | CAP | 业务能力目录；`implements_to`→VC，`maps_to`→BSD(L1) |
| 产品 | PL | 产品线；`maps_to`→BSD(L1)\|SLN；**无 PD**（PD ∈ 解决方案） |
| 应用 | — | **无 SLN**（SLN ∈ 解决方案） |
| 数据 | — | **无 MDG**（MDG ∈ 解决方案） |
| 技术 | TPL | 云 / DevOps / 安全 / 开发环境 / 可观测；企业技术准入；`TSD.implements_to`→TPL |

- SDD：`domains/` = 域架构（哪条 BD 支撑 VC）；**无** `solutions/`、`analysis/`、`requirements/`。入口技能 `/sdx-domains`
- 槽位 / 同步：见 [knowledge-layout.md](../references/knowledge-layout.md)（`solution-slots/solution-{NAME}`）
- 入口：[company/README.md](../../company/README.md) · [company/knowledge/](../../company/knowledge/README.md)

### 解决方案层

| 视角 | 解决方案层聚焦 |
| --- | --- |
| 业务 | BSD(L2) SSOT（`parent`→公司 BSD(L1)，`maps_to`→本层 PD 1:1）；跨 SYS 共性域叙事 |
| 产品 | PD SSOT（`implements_to`→公司 PL）；BP SSOT（解决方案主流程：`implements_to`→SLN，可 `maps_to` 多个 PD） |
| 应用 | SLN SSOT（一仓一 SLN；`maps_to`→公司 PL；`implemented_by`→SYS）；**无 SYS 正文**（SYS ∈ 系统） |
| 数据 | MDG SSOT（一 SLN 多个数据域；跨 SYS 逻辑模型与数据主权） |
| 技术 | TSD SSOT（本方案选用与例外；`implements_to`→公司 TPL；一 SLN 多条） |

- SDD：仅 `solutions/`（`/sdx-solution` **只**本层）。SA 第一至四章进 `knowledge/`；第五至八章进 `SOLUTION-*.md`。**无** `analysis/`、`features/`、`requirements/`
- 槽位 / 同步：见 layout（`system-slots/system-{NAME}`）
- 入口：[solution/README.md](../../solution/README.md) · 五视角同构于 `solution/knowledge/`

### 系统层

| 视角 | 系统层聚焦 |
| --- | --- |
| 业务 | BC→AGG→AB（`implements_to`/`implemented_by`）；BSD(L2) 为解决方案 reference |
| 产品 | PM→FT→FR→UC/BR（整链 `implements_to`）；PD/BP 为解决方案 reference；PM `implements_to`→PD |
| 应用 | SYS 本层 SSOT（`maps_to`→解决方案 PD 1:1；`implements_to`→SLN）；APP→MS（`implements_to`）；`uses_to`→MDG\|TSD（上层） |
| 数据 | DS→ENT（`implements_to` MDG）；MDG 为解决方案 reference；TBL ∈ application |
| 技术 | MW/CMP ∈ application；TSD 为解决方案 reference |

- 上层 reference（可留薄文件）：`SLN/PD/BSD(L2)/MDG/TSD/BP` 及公司层实体；`definition_scope: reference`，不重复字段语义
- SDD：`analysis/` → `features/` → `requirements/REQUIREMENT-{IDEA-ID}/`（目录物理改名见 GRILL-LOG）
- 槽位 / 同步：见 layout（`application-slots/application-{NAME}`）
- 入口：[system/README.md](../../system/README.md) · [system/knowledge/](../../system/knowledge/README.md)

### 应用层

| 原则 | 说明 |
| --- | --- |
| **SSOT** | 见 [glossary.md](glossary.md)「单一事实源」 |
| **本层角色** | API / TBL / MW / CMP 首次定义；上游 ref 或纯 ID |
| **stub** | 可对系统 / 解决方案 / 公司首次定义实体留薄 reference（HTTP 沿 parent 链） |
| **闭环** | analysis → features → requirements；本库 extract/archive 写 overview 与 `chapters/`；上行 pull → distill（**仅**系统 overview） |
| **五视角 / 5A** | 层级链与本层角色见下节「核心映射（5A）」；细则 ∈ 各 `*-meta.md` + README |

- 入口：[application/README.md](../../application/README.md) · [application/knowledge/](../../application/knowledge/README.md)

---

## 核心映射（5A 方向）

**5A** 短义（BA/PA/AA/DA/TA）见 [glossary.md § 知识库术语](glossary.md#知识库术语)；边类方向与层级以本节为准。

### 5A ↔ 五视角层级

| 5A | 视角目录 | 层级（摘要） | 应用层角色 |
| --- | --- | --- | --- |
| BA | business | BD → BSD(L1) → BSD(L2) → BC → AGG → AB | 实现映射；BD/L1/L2 多为 ref |
| PA | product | PL；PD → PM → …；BP 挂 SLN | 实现映射；PL 公司；PD/BP 解决方案 |
| AA | application | SLN → SYS → APP → MS → **API** | **API SSOT** |
| DA | data | MDG → DS → ENT → **TBL** | **TBL SSOT** |
| TA | technical | TPL → TSD → **MW** → **CMP** | **MW/CMP SSOT** |

技术链：`TPL ← TSD ← MW ← CMP`（`implements_to`）；**MS `uses_to`→CMP**。无 APP↔TPL、APP↔CMP 直连。**MW** 基础设施绑定；**MS/API** 业务入口，二者不互替。

关系动词总则与允许边见 [glossary.md § 映射关系](glossary.md#映射关系常用)。摘要：

| 边类 | 动词 | 代表 |
| --- | --- | --- |
| 同类树 | `parent` / `children` | BD↔BSD(L1)↔BSD(L2) |
| 同视角组成 | `implements_to` / `implemented_by` | BSD(L2)↔BC↔AGG↔AB；产品/应用/数据链；CAP↔VC；BP→SLN；SYS→SLN |
| 同级对标 | `maps_to` | CAP↔BSD(L1)；BSD(L1)↔PL；BSD(L2)↔PD；SLN↔PL；PD↔SYS；BP 可 `maps_to` 多 PD；MS↔AGG；AB↔API；AGG↔ENT；PM↔BC；UC↔API |
| 支撑 | `supports_to` / `supported_by` | BD↔VC；APP↔BC；API→FT |
| 使用 | `uses_to` / `used_by` | SYS→MDG\|TSD；APP→DS\|MW；MS→ENT\|TBL\|CMP；MW→DS |
| 模块依赖 | `depends_to` / `depended_by` | PM↔PM |

禁止：SYS 绕过 PD 去 `maps_to` PL。

---

## 业务 knowledge 引用边界

**适用范围**：仅 `application|system|solution|company` 下 `*/knowledge/**`（含 overview、视角章、per-entity、meta、README）。**不含** `agent/knowledge/**`（Agent 元知识可链规则与布局文档）。

**层级方向**（高 → 低）：`company` > `solution` > `system` > `application`。只许向上引用；禁止引下层 knowledge 与联邦槽位（`system/application-slots/application-*`、`solution/system-slots/system-*`、`company/solution-slots/solution-*`）。

| 允许 | 禁止 |
| --- | --- |
| 同层 `…/knowledge/**` 内互引（bundle-relative） | 引同层 knowledge **外**（`adr/`、`domains/`、`solutions/`、`analysis/`、`features/`、`requirements/`、`INDEX-GUIDE.md`、根 `index.md`、`agent/**` 等） |
| 有 `{DOC_ROOT}/knowledge-links.yaml` 中 `type: parent`：上层实体 Markdown 链到 **首次定义层 SSOT 文件的 HTTP**（见下） | 手写 `../` 爬层、仓库相对跨 `DOC_DIR`、`/company/knowledge/...` 逻辑前缀、与生成函数结果不一致的 URL |
| 无 `type: parent`：正文只写实体 ID / `id` | 无 parent 时仍写跨层 HTTP 或跨层文件路径 |
| `resource` / 依据段：外部 **URI、表名、API 名、仓名**（非库外文档相对路径） | Markdown 链或路径字面量指向库外 **文档文件**（ADR 等：**留字去链**） |

**parent（1:1）**：`docs-link` 在下级 `knowledge-links.yaml` 写入恰好一条 `type: parent`：`repository`、`path`、`doc_dir`（=上级 DOC_DIR）、以及层相关 name/label（solution 子仓用 `company_*`，system 子仓用 `solution_*`，application 子仓用 `sys_*`）；HTTP `ref` 固定 `main`。上级清单仍向下登记 child（缺省无 `type`）。一个 application 只对应一个 system parent，一个 system 只对应一个 solution parent，一个 solution 只对应一个 company parent；换上级且传 `--rewrite-http` 时才替换旧 HTTP 前缀。`docs-install` 重装保留已有 `knowledge-links.yaml`。不再读写 `knowledge-parent.yaml`（旧文件可留盘，读忽略）。company 无 parent 条。

**HTTP 生成（唯一函数；技能 / docs-link / 校验共用）**：输入 `id` 与首次定义层。沿 parent 链走到该层，解析根优先 `{repository}/{doc_dir}`，否则 `{path}/{doc_dir}`。`repository`：SSH→HTTPS、去 `.git`；GitHub `/blob/{ref}/`，GitLab `/-/blob/{ref}/`，Gitee `/blob/{ref}/`；未知宿主不写 HTTP，只用 `path`+`doc_dir`（本机不存在则正文保持 ID）。文件相对路径用 **目标层** `entity_relpath`，不链中间层 stub。禁止手写与推导不同的 href。`docs-link` 变更 `repository`/`ref`/`doc_dir` 时扫描下级 `*/knowledge/**` 替换旧 web_base；`unlink` 能改为纯 ID 则改，否则停并列清单。

**下层 stub**：首次定义在上层的实体，下层可留同 `id` 的薄 reference（`definition_scope: reference`，`layer_scope` 为本层），不重复字段语义；`parent_id` 仍在本 bundle 解析。有 parent 时 stub 的关系/依据段用上述 HTTP 指向上层 SSOT。**系统仓与应用仓均允许**对非本层首次定义实体建 stub。

**校验（默认离线）**：有 parent 则 href 必须等于「推导 web_base + 目标层 relpath」；`path` 在本机存在时再查文件。不 HTTP GET。无 parent 出现跨层 HTTP 则失败。不得把 `/knowledge/...` 回退到下游 bundle。

**读写分离**：技能可读 knowledge 外源（solutions、槽位等）；**落盘进** `*/knowledge/**` 的正文、链接、路径字面量、frontmatter 外指须满足上表。脚本实现（生成函数、docs-link 写 parent、校验）另批落地，本节为行为契约。

**违规处理（写技能）**：能机械修复则修（库外/下层去链或纯 ID；跨层手写路径改为生成函数 HTTP，无 parent 则纯 ID）；目标层或实体不明则停，列清单交人。

**SSOT**：本节；OKF 段结构对齐见 [okf-spec.md](okf-spec.md) §4。
