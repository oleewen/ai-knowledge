# 知识库治理规则

> **定位**：四层知识库**语义设计** SSOT（职责、各层聚焦/首次定义、5A 边类方向、引用边界）。  
> **层根人类入口**：[`company/DESIGN.md`](../../company/DESIGN.md) · [`solution/DESIGN.md`](../../solution/DESIGN.md) · [`system/DESIGN.md`](../../system/DESIGN.md) · [`application/DESIGN.md`](../../application/DESIGN.md)（契约短表 + 引用本文；本文仍为语义 SSOT）。  
> **不分管**：路径 / overview / 槽位 / 联邦流水线 → [knowledge-layout.md](../references/knowledge-layout.md)；ID 语法 → [naming-conventions.md](naming-conventions.md)；缩写/词义/映射字段 → [glossary.md](glossary.md)；文件分型 → [okf-spec.md](okf-spec.md)。  
> 组件索引与使用顺序见同目录 [README.md](README.md)。协作闸门见 [CONVENTIONS.md](../rules/CONVENTIONS.md)。

**最后更新**: 2026-10-10

---

## 使命

决策 **透明、一致、可追溯**，避免架构随口语漂移。

---

## 四层职责边界

| 层级 | 目录 | 治理职责 | 实体 SSOT（首次定义） |
| --- | --- | --- | --- |
| 公司 | `company/` | 完整价值链 VC；域架构（哪个 BD 支撑 VC）；企业技术准入 | VC、BD、CAP、BSD-L1、BL、TPL |
| 解决方案 | `solution/` | 一个交付包（一仓一 SLN）；架构、模型、主流程、产品框架、数据主权、技术选型。本层不出现 SYS | SLN、PL、PD、BP、BSP、BSD-L2、BS、MDG、TS |
| 系统 | `system/` | 一个 SYS 的实现边界与架构聚合；应用镜像槽位 | SYS、BSD-L3、BC、AGG、AB、PM、FT、FR、UC、BR、APP、MS、DS、ENT |
| 应用 | `application/` | 实现级实体、SDD 阶段交付、物理锚点 | API、TBL、MW、CMP |

**命名、术语与 OKF 文件分型**：统一以 `agent/knowledge/` 为准（见 [README.md](README.md)）。路径与槽位名见 [knowledge-layout.md](../references/knowledge-layout.md)。实体首次定义细节见下文「各层聚焦摘要」。

| 面 | 规则 |
| --- | --- |
| 联邦 | parent 仅 `application → system → solution → company`（向上 1:1）。公司不直管系统。蒸馏按层上收，禁止跳层当默认 |
| 禁止 | 跨层字段语义双源；公司/解决方案正文写单应用实现细节 |
| 引用 | 有 parent → HTTP 到首次定义层 SSOT；无 parent → 纯 ID（详见下文「业务 knowledge 引用边界」） |
| 基数 | 一仓一 SLN；一 SLN 一个 PL、一条 BP、多个 PD；PD→BS→BSD-L2 均 1:1；SYS→PD **1:1**；一 SLN 多个 MDG、多个 TS |

---

## 各层聚焦摘要

**首次定义**以本节为准：= 治理语义、字段口径与上游主定义所在层；下游可做实例登记、实现映射、物理锚点。不建 reference 文件，只写纯 ID。不等同于「只允许在该层出现」。他处不重复字段语义；缩写短义见 [glossary.md](glossary.md)；引用形态见「业务 knowledge 引用边界」。

### 公司层

| 视角 | 实体 | 公司层聚焦 |
| --- | --- | --- |
| 业务 | VC | 价值链；`supported_by`→BD，`implemented_by`→CAP |
| 业务 | BD | 业务域；`supports_to`→VC，`children`→BSD-L1 |
| 业务 | BL | 业务线；无 `parent`；`maps_to`→BSD-L1 一对一，`mapped_by`→PL（纯 ID） |
| 业务 | BSD-L1 | 公司层业务子域；`level: 1`，`parent`→BD，`children`→BSD-L2（对端 `parent` 存在时必须，纯 ID），`maps_to`→CAP，`mapped_by`→BL |
| 业务 | CAP | 业务能力目录；`implements_to`→VC，`mapped_by`→BSD-L1 |
| 产品 | — | **无 PL / PD**。企业产品标准（概述、度量、体验） |
| 应用 | — | **无 SLN**（SLN ∈ 解决方案） |
| 数据 | — | **无 MDG**（MDG ∈ 解决方案） |
| 技术 | TPL | 云 / DevOps / 安全 / 开发环境 / 可观测；企业技术准入；`implemented_by`→TS（纯 ID）；`TS.implements_to`→TPL |

- SDD：只 `domains/`。只写 BD/BSD-L1 如何支撑 VC，不放 SLN，不建 `solutions/` / `analysis/` / `features/` / `requirements/`。入口技能 `/sdx-domains`
- 槽位 / 同步：见 [knowledge-layout.md](../references/knowledge-layout.md)（`solution-slots/solution-{NAME}`）
- 入口：[company/README.md](../../company/README.md) · [company/knowledge/](../../company/knowledge/README.md)

### 解决方案层

| 视角 | 解决方案层聚焦 |
| --- | --- |
| 业务 | BSD-L2 SSOT（`parent`→公司 BSD-L1，`children`→BSD-L3（对端 `parent` 存在时必须，纯 ID），`mapped_by`→BS）；BS SSOT（无 `parent`，`maps_to`→BSD-L2 1:1，`mapped_by`→PD） |
| 产品 | PL / PD / BP / BSP SSOT。`SLN.maps_to`→PL 1:1；`PL.maps_to`→BL 1:1，`implemented_by`→PD，`mapped_by`→SLN；`PD.implements_to`→PL，`maps_to`→BS 1:1，`implemented_by`→BSP、PM（PM 纯 ID），`uses_to`→MDG\|TS；`BP.implements_to`→SLN，`children`→BSP；BSP `parent`→BP、`implements_to`→PD |
| 应用 | SLN SSOT（一仓一 SLN；`maps_to`→PL 1:1；`implemented_by`→BP）。本层不出现 SYS |
| 数据 | MDG SSOT（一 SLN 多个数据域；逻辑模型与数据主权；`implemented_by`→DS（纯 ID），`used_by`→PD） |
| 技术 | TS SSOT（方案级技术服务选用；`implements_to`→公司 TPL，`implemented_by`→MW（纯 ID），`used_by`→PD；一 SLN 多条） |

- SDD：仅 `solutions/`（`/sdx-solution`）。`SOLUTION-*.md` 是交付包切分叙事。**无** `analysis/`、`features/`、`requirements/`。七章需求分析在系统/应用，入口 `/sdx-analysis`
- 槽位 / 同步：见 layout（`system-slots/system-{NAME}`）
- 入口：[solution/README.md](../../solution/README.md) · 五视角同构于 `solution/knowledge/`

### 系统层

| 视角 | 系统层聚焦 |
| --- | --- |
| 业务 | BSD-L3→BC→AGG→AB（`parent`→解决方案 BSD-L2；盘面挂 L2 **目录宿主** 下）。不落 BSD-L1；样例不落 BSD-L2 实体（业务仓可留 L2 实体作聚合） |
| 产品 | PM→FT→FR→UC/BR（整链 `implements_to`）；PD/BP 不建本层文件，只写纯 ID；PM `implements_to`→PD |
| 应用 | SYS 本层 SSOT（`maps_to`→解决方案 PD 1:1；`implements_to`→SLN，纯 ID）。不 `uses_to` MDG\|TS。APP→MS（`implements_to`）；MS `implemented_by`→API（纯 ID） |
| 数据 | DS→ENT（`implements_to` MDG）；ENT `implemented_by`→TBL（纯 ID）；MDG 不建本层文件，只写纯 ID；TBL ∈ application |
| 技术 | MW/CMP ∈ application；TS 不建本层文件，只写纯 ID |

- 上层实体不建本层文件，正文只写纯 ID：`SLN/PL/PD/BP/BSP/BSD-L2/BS/MDG/TS` 及公司层实体。有 `type: parent` 时，关系段或依据段可 HTTP 指向上层首次定义 SSOT。不重复字段语义。宿主目录可留
- SDD：`analysis/` → `features/` → `requirements/REQUIREMENT-{IDEA-ID}/`。不建 `solutions/`。`analysis` 从原始输入开写，不等 `SOLUTION`
- 槽位 / 同步：见 layout（`application-slots/application-{NAME}`）
- 入口：[system/README.md](../../system/README.md) · [system/knowledge/](../../system/knowledge/README.md)

### 应用层

| 原则 | 说明 |
| --- | --- |
| **SSOT** | 见 [glossary.md](glossary.md)「单一事实源」 |
| **本层角色** | API / TBL / MW / CMP 首次定义；上游不建 reference 文件，只写纯 ID |
| **上游** | 不建 reference 实体文件。有 parent 则 HTTP 指向上层首次定义；无 parent 则纯 ID。宿主目录可留 |
| **闭环** | `analysis/` → `features/` → `requirements/`，不建 `solutions/`；`analysis` 从原始输入开写。本库 extract/archive 写 overview 与 `chapters/`；上行 pull → distill（**仅**系统 overview） |
| **五视角 / 5A** | 层级链与本层角色见下节「核心映射（5A）」；细则 ∈ `agent/knowledge/{视角}-meta.md` + 各层 README |

- 入口：[application/README.md](../../application/README.md) · [application/knowledge/](../../application/knowledge/README.md)

---

## 核心映射（5A 方向）

**5A** 短义（BA/PA/AA/DA/TA）见 [glossary.md § 知识库术语](glossary.md#知识库术语)；边类方向与层级以本节为准。

### 5A ↔ 五视角层级

| 5A | 视角目录 | 层级（摘要） | 应用层角色 |
| --- | --- | --- | --- |
| BA | business | BD → BSD-L1 → BSD-L2 → BSD-L3 → BC → AGG → AB | 实现映射；BD/L1/L2 不在系统落文件；BSD-L3 为系统 SSOT |
| PA | product | PL；PD → PM → …；BP 挂 SLN；BSP `parent` BP | 实现映射；PL/PD/BP/BSP 解决方案 |
| AA | application | SLN → SYS → APP → MS → **API** | **API SSOT** |
| DA | data | MDG → DS → ENT → **TBL** | **TBL SSOT** |
| TA | technical | TPL → TS → **MW** → **CMP** | **MW/CMP SSOT** |

技术链：`TPL ← TS ← MW ← CMP`（`implements_to`）。无 APP↔TPL、APP↔CMP 直连。**MW** 基础设施绑定；**MS/API** 业务入口，二者不互替。

关系动词总则与允许边见 [glossary.md § 映射关系](glossary.md#映射关系常用)。摘要：

| 边类 | 动词 | 代表 |
| --- | --- | --- |
| 同类树 | `parent` / `children` | 两边都写，含跨层。children：BD→BSD-L1、BP→BSP、BSD-L1→BSD-L2、BSD-L2→BSD-L3 |
| 同视角组成 | `implements_to` / `implemented_by` | 两边都写，含跨层。下层 `implements_to`，上层 `implemented_by` |
| 同级对标 | `maps_to` / `mapped_by` | 两边都写，含跨层。下层 `maps_to`，上层 `mapped_by` |
| 支撑 | `supports_to` / `supported_by` | 两边都写，含跨层。BD↔VC；APP↔BC；API→FT |
| 使用 | `uses_to` / `used_by` | 两边都写，含跨层。PD→MDG\|TS；APP→DS；APP→MW；MS→ENT；MW→DS |
| 模块依赖 | `depends_to` / `depended_by` | PM↔PM |

禁止：SYS 绕过 PD 去 `maps_to` PL。例外：解决方案层不出现 SYS。系统层 `SYS.implements_to`→SLN、`SYS.maps_to`→PD 都写纯 ID；解决方案层不回写 `implemented_by` SYS，PD 也不写 `mapped_by` SYS。指向下层的 `children` / `implemented_by` / `mapped_by` / `supported_by` / `used_by` / `uses_to` 只写纯 ID，见引用边界。

---

## 业务 knowledge 引用边界

**适用范围**：仅 `application|system|solution|company` 下 `*/knowledge/**`（含 overview、视角章、per-entity、meta、README）。**不含** `agent/knowledge/**`（Agent 元知识可链规则与布局文档）。

**层级方向**（高 → 低）：`company` > `solution` > `system` > `application`。只许向上引用。禁止引下层 knowledge 与联邦槽位（`system/application-slots/application-*`、`solution/system-slots/system-*`、`company/solution-slots/solution-*`）。例外：上层反向边指向更低层时只写纯 ID，见下表。

| 允许 | 禁止 |
| --- | --- |
| 同层 `…/knowledge/**` 内互引（bundle-relative） | 引同层 knowledge **外**（`adr/`、`domains/`、`solutions/`、`analysis/`、`features/`、`requirements/`、`INDEX-GUIDE.md`、根 `index.md` 等） |
| Markdown 链解析后只落在 `agent/knowledge/{business,product,application,data,technical}-meta.md`（可带锚点）。元库写法是从当前文件到仓库根的深度相对路径。消费库由安装重写为 `DOC_DIR` 下 `.agents/knowledge/` 同名文件 | 其他 `agent/**` |
| 有 `{文档目录}/knowledge-links.yaml` 中 `type: parent`：上层实体 Markdown 链到 **首次定义层 SSOT 文件的 HTTP**（见下） | 目标不是上一行这 5 个文件时：手写 `../` 爬层、仓库相对跨 `DOC_DIR`、`/company/knowledge/...` 逻辑前缀、与生成函数结果不一致的 URL |
| 无 `type: parent`：正文只写实体 ID / `id` | 无 parent 时仍写跨层 HTTP 或跨层文件路径 |
| 上层反向边指向更低层时只写纯 ID：`children`、`implemented_by`、`mapped_by`、`supported_by`、`used_by`，以及上层 `uses_to` | 上述字段以 Markdown 链或 HTTP 指向下层 |
| `resource` / 依据段：外部 **URI、表名、API 名、仓名**（非库外文档相对路径） | Markdown 链或路径字面量指向库外 **文档文件**。adr 不链：只可摘录决策要点；无要点则写尚无 |

**parent（1:1）**：`docs-link` 在下级 `knowledge-links.yaml` 写入恰好一条 `type: parent`：`repository`、`path`、`dir`（=上级 DOC_DIR）、`name`、`label`（label 缺省等于 name）。HTTP `ref` 固定 `main`。上级清单向下登记 `type: child`，字段同为 `name` / `label`。层别由该文件所在库的 `KNOWLEDGE_TYPE` 与该条 `type` 决定，键上不写层前缀。`type` 必写，仅 `parent`、`child`、`meta`。`type: meta` 只写 `repository`、`path`、`dir`（dir = 本库 `KNOWLEDGE_TYPE`，指向元仓模板子树）。一个 application 只对应一个 system parent，一个 system 只对应一个 solution parent，一个 solution 只对应一个 company parent；换上级且传 `--rewrite-http` 时才替换旧 HTTP 前缀。`docs-install` 重装保留已有 `knowledge-links.yaml`。不再读写 `knowledge-parent.yaml`（旧文件可留盘，读忽略）。company 无 parent 条。

**HTTP 生成（唯一函数；技能 / docs-link / 校验共用）**：输入 `id` 与首次定义层。沿 parent 链走到该层，解析根优先 `{repository}/{dir}`，否则 `{path}/{dir}`。`repository`：SSH→HTTPS、去 `.git`；GitHub `/blob/{ref}/`，GitLab `/-/blob/{ref}/`，Gitee `/blob/{ref}/`；未知宿主不写 HTTP，只用 `path`+`dir`（本机不存在则正文保持 ID）。文件相对路径用 **目标层** `entity_relpath`，不链中间层路径。禁止手写与推导不同的 href。`docs-link` 变更 `repository`/`ref`/`dir` 时扫描下级 `*/knowledge/**` 替换旧 web_base；`unlink` 能改为纯 ID 则改，否则停并列清单。

**下层不建 reference 文件**：首次定义在上层的实体，下层不建同 `id` 的实体文件，正文只写纯 ID。宿主目录可留。路径父级取自关系段同层 `parent`，否则同层 `implements_to`。有 knowledge-links 的 `type: parent` 时，关系段或依据段可用 HTTP 指向上层 SSOT 文件，不链中间层。无 parent 则纯 ID。不重复字段语义。

**校验（默认离线）**：有 parent 则 href 必须等于「推导 web_base + 目标层 relpath」；`path` 在本机存在时再查文件。不 HTTP GET。无 parent 出现跨层 HTTP 则失败。不得把 `/knowledge/...` 回退到下游 bundle。

**读写分离**：技能可读 knowledge 外源（solutions、槽位等）；**落盘进** `*/knowledge/**` 的正文、链接、路径字面量、frontmatter 外指须满足上表。脚本实现（生成函数、docs-link 写 parent、校验）另批落地，本节为行为契约。

**违规处理（写技能）**：能机械修复则修（库外/下层去链或纯 ID；跨层手写路径改为生成函数 HTTP，无 parent 则纯 ID）；目标层或实体不明则停，列清单交人。

**SSOT**：本节；OKF 段结构对齐见 [okf-spec.md](okf-spec.md) §4。
