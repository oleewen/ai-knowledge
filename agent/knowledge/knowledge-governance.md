# 知识库治理规则

> **定位**：三层知识库**语义设计** SSOT（职责、各层聚焦/首次定义、5A 边类方向、引用边界）。  
> **层根人类入口**：[`company/DESIGN.md`](../../company/DESIGN.md) · [`system/DESIGN.md`](../../system/DESIGN.md) · [`application/DESIGN.md`](../../application/DESIGN.md)（契约短表 + 引用本文；本文仍为语义 SSOT）。  
> **不分管**：路径 / overview / 槽位 / 联邦流水线 → [knowledge-layout.md](../references/knowledge-layout.md)；ID 语法 → [naming-conventions.md](naming-conventions.md)；缩写/词义/映射字段 → [glossary.md](glossary.md)；文件分型 → [okf-spec.md](okf-spec.md)。  
> 组件索引与使用顺序见同目录 [README.md](README.md)。协作闸门见 [CONVENTIONS.md](../rules/CONVENTIONS.md)。

**最后更新**: 2026-09-15

---

## 使命

决策 **透明、一致、可追溯**，避免架构随口语漂移。

---

## 三层职责边界

| 层级 | 目录 | 治理职责 | 实体 SSOT（首次定义） |
| --- | --- | --- | --- |
| 公司 | `company/` | 公司级 EA 叙事、跨系统方案与分析、系统槽位 | VC、BD、一级 BSD、CAP、PL、SLN、TPL |
| 系统 | `system/` | 系统级架构聚合、应用镜像槽位、蒸馏归档 | PD、SYS、MDG、二级 BSD、BC、AGG、AB、PM、FT、FR、UC、BP、BR、APP、MS、DS、ENT、TSD 等 |
| 应用 | `application/` | 实现级实体、SDD 阶段交付、物理锚点 | API、TBL、MW、CMP |

**命名、术语与 OKF 文件分型**：统一以 `agent/knowledge/` 为准（见 [README.md](README.md)）。路径与槽位名见 [knowledge-layout.md](../references/knowledge-layout.md)。实体首次定义细节见下文「各层聚焦摘要」。

| 面 | 规则 |
| --- | --- |
| 联邦 | 系统管边界与索引；应用管实现细节并上行对齐；公司聚合导航与公司级 SSOT |
| 禁止 | 跨层字段语义双源；公司正文写实现细节 |
| 引用 | 有 parent → HTTP 到首次定义层 SSOT；无 parent → 纯 ID（详见下文「业务 knowledge 引用边界」） |

---

## 各层聚焦摘要

**首次定义**以本节为准：= 治理语义、字段口径与上游主定义所在层；下游可做实例登记、实现映射、物理锚点或 reference，不等同于「只允许在该层出现」。他处不重复字段语义；缩写短义见 [glossary.md](glossary.md)；引用形态见「业务 knowledge 引用边界」。

### 公司层

| 视角 | 实体 | 公司层聚焦 |
| --- | --- | --- |
| 业务 | VC | 价值链；`supported_by_bd`→BD，`implemented_by_cap`→CAP |
| 业务 | BD | 业务域；`supports_to_vc`→VC，`children`→一级 BSD |
| 业务 | 一级 BSD | 公司层业务子域；`level: 1`，`parent`→BD，`maps_to_pl`→PL，`maps_to_cap`→CAP |
| 业务 | CAP | 业务能力目录；`implements_to_vc`→VC，`maps_to_bsd`→一级 BSD |
| 产品 | PL | 产品线；`maps_to_bsd`→一级 BSD；**无 PD / 无 SLN**（PD ∈ 系统；SLN ∈ 公司 application） |
| 应用 | SLN | 解决方案（对应 PL）（AA 台账）；**无 SYS**；**无** `uses_mdg_ids` |
| 数据 | — | **无 MDG**（MDG ∈ 系统；SYS `uses_mdg_ids`） |
| 技术 | TPL | 云 / DevOps / 安全 / 开发环境 / 可观测；由 AA `uses_*` 引用 |

- SDD：`solutions/` + `analysis/` = 跨系统上游；**无** `requirements/`（交付 ∈ 各系统）
- 槽位 / 同步：见 [knowledge-layout.md](../references/knowledge-layout.md)（`system-slots/system-{NAME}`）
- 入口：[company/README.md](../../company/README.md) · [company/knowledge/](../../company/knowledge/README.md)

### 系统层

| 视角 | 系统层聚焦 |
| --- | --- |
| 业务 | 二级 BSD→AB；一级 BSD / BD 为 company reference；二级 BSD `level: 2`、`parent`→一级 BSD、`maps_to_pd`→PD |
| 产品 | PD→PM→FT→FR→UC/BR、BP；PL 公司 SSOT（本层不落盘）；PD 本层 SSOT |
| 应用 | SYS→APP/MS；SYS 本层 SSOT（`parent_id→公司 SLN`）；`uses_mdg_ids` / `uses_tsd_ids` / `uses_tpl_ids` |
| 数据 | MDG/DS/ENT 本层 SSOT；TBL ∈ application |
| 技术 | TSD；MW/CMP ∈ application；AA `uses_*` |

- 公司层 reference（可留薄文件）：`BD/一级BSD/CAP/PL/SLN/TPL`（正文 SSOT ∈ company）；VC 仅公司层；**无**公司二级 BSD/PD/SYS/MDG
- SDD：solutions → analysis → `requirements/REQUIREMENT-{IDEA-ID}/`
- 槽位 / 同步：见 layout（`application-slots/application-{NAME}`）
- 入口：[system/README.md](../../system/README.md) · [system/knowledge/](../../system/knowledge/README.md)

### 应用层

| 原则 | 说明 |
| --- | --- |
| **SSOT** | 见 [glossary.md](glossary.md)「单一事实源」 |
| **本层角色** | API / TBL / MW / CMP 首次定义；上游 ref 或纯 ID |
| **闭环** | solutions → analysis → requirements；上行 pull → distill（**仅**系统 overview）→ archive；**不**回写本库 knowledge |
| **五视角 / 5A** | 层级链与本层角色见下节「核心映射（5A）」；细则 ∈ 各 `*-meta.md` + README |

- 入口：[application/README.md](../../application/README.md) · [application/knowledge/](../../application/knowledge/README.md)

---

## 核心映射（5A 方向）

**5A** 短义（BA/PA/AA/DA/TA）见 [glossary.md § 知识库术语](glossary.md#知识库术语)；边类方向与层级以本节为准。

### 5A ↔ 五视角层级

| 5A | 视角目录 | 层级（摘要） | 应用层角色 |
| --- | --- | --- | --- |
| BA | business | BD → BSD → BC → AGG → AB | 实现映射；BD 多为 ref |
| PA | product | PL；PD → PM → … | 实现映射；PL/SLN 公司；PD 系统（本层不落盘） |
| AA | application | SYS → APP → MS → **API** | **API SSOT** |
| DA | data | MDG → DS → ENT → **TBL** | **TBL SSOT**（MDG/DS/ENT ∈ 系统） |
| TA | technical | TSD → **MW** → **CMP** | **MW/CMP SSOT** |

技术链补充：`TPL → TSD → MW`；`CMP` 挂 `MW` 或 `APP`（`parent_mw_id` / `parent_app_id`）。**MW** 登记基础设施绑定；**MS/API** 仍登记业务入口宿主，二者不互替。

### 跨 A 边

源实体 frontmatter 写**目标实体 ID**。字段语义见 [glossary.md § 映射关系](glossary.md#映射关系常用)。

| 边类 | 方向 | 代表 |
| --- | --- | --- |
| 实现与支撑 | `implements_to_vc` / `implemented_by_cap` / `supported_by_bd` / `supports_to_vc` | BA：VC↔CAP、VC↔BD |
| 对标 | `maps_to_*` | BA：CAP↔一级 BSD；**PA**：一级 BSD↔PL、二级 BSD↔PD、SLN→PL；PA↔AA：PD→SYS |
| PA → BA | 依赖 | `relies_on_context_ids` |
| PA → AA | 调用 | `invokes_api_ids` |
| AA → BA | **implements** | `implements_bc_ids` / `implements_agg_ids` |
| AA → DA / TA | **uses** | `uses_mdg_ids`（挂 **SYS**）/ `uses_ds_ids` / `uses_tsd_ids` 等 |
| BA ↔ DA | 持久化 | `persisted_as_entity_ids` / `maps_to_aggregate_id` |

---

## 业务 knowledge 引用边界

**适用范围**：仅 `application|system|company` 下 `*/knowledge/**`（含 overview、视角章、per-entity、meta、README）。**不含** `agent/knowledge/**`（Agent 元知识可链规则与布局文档）。

**层级方向**（高 → 低）：`company` > `system` > `application`。只许向上引用；禁止引下层 knowledge 与联邦槽位（`system/application-slots/application-*`、`company/system-slots/system-*`）。

| 允许 | 禁止 |
| --- | --- |
| 同层 `…/knowledge/**` 内互引（bundle-relative） | 引同层 knowledge **外**（`adr/`、`solutions/`、`analysis/`、`requirements/`、`INDEX-GUIDE.md`、根 `index.md`、`agent/**` 等） |
| 有 `{DOC_ROOT}/knowledge-links.yaml` 中 `type: parent`：上层实体 Markdown 链到 **首次定义层 SSOT 文件的 HTTP**（见下） | 手写 `../` 爬层、仓库相对跨 `DOC_DIR`、`/company/knowledge/...` 逻辑前缀、与生成函数结果不一致的 URL |
| 无 `type: parent`：正文只写实体 ID / `full_id`（纯文本） | 无 parent 时仍写跨层 HTTP 或跨层文件路径 |
| `resource` / 依据段：外部 **URI、表名、API 名、仓名**（非库外文档相对路径） | Markdown 链或路径字面量指向库外 **文档文件**（ADR 等：**留字去链**） |

**parent（1:1）**：`docs-link` 在下级 `knowledge-links.yaml` 写入恰好一条 `type: parent`：`repository`、`path`、`doc_dir`（=上级 DOC_DIR）、以及层相关 name/label（system 子仓用 `company_*`，application 子仓用 `sys_*`）；HTTP `ref` 固定 `main`。上级清单仍向下登记 child（缺省无 `type`）。一个 application 只对应一个 system parent，一个 system 只对应一个 company parent；换上级且传 `--rewrite-http` 时才替换旧 HTTP 前缀。`docs-install` 重装保留已有 `knowledge-links.yaml`。不再读写 `knowledge-parent.yaml`（旧文件可留盘，读忽略）。company 无 parent 条。

**HTTP 生成（唯一函数；技能 / docs-link / 校验共用）**：输入 `full_id` 与首次定义层。沿 parent 链走到该层，解析根优先 `{repository}/{doc_dir}`，否则 `{path}/{doc_dir}`。`repository`：SSH→HTTPS、去 `.git`；GitHub `/blob/{ref}/`，GitLab `/-/blob/{ref}/`，Gitee `/blob/{ref}/`；未知宿主不写 HTTP，只用 `path`+`doc_dir`（本机不存在则正文保持 ID）。文件相对路径用 **目标层** `entity_relpath`，不链中间层 stub。禁止手写与推导不同的 href。`docs-link` 变更 `repository`/`ref`/`doc_dir` 时扫描下级 `*/knowledge/**` 替换旧 web_base；`unlink` 能改为纯 ID 则改，否则停并列清单。

**下层 stub**：首次定义在上层的实体，下层可留同 `full_id` 的薄 reference（`definition_scope: reference`，`layer_scope` 为本层），不重复字段语义；`parent_id` 仍在本 bundle 解析。有 parent 时 stub 的关系/依据段用上述 HTTP 指向上层 SSOT。

**校验（默认离线）**：有 parent 则 href 必须等于「推导 web_base + 目标层 relpath」；`path` 在本机存在时再查文件。不 HTTP GET。无 parent 出现跨层 HTTP 则失败。不得把 `/knowledge/...` 回退到下游 bundle。

**读写分离**：技能可读 knowledge 外源（solutions、槽位等）；**落盘进** `*/knowledge/**` 的正文、链接、路径字面量、frontmatter 外指须满足上表。脚本实现（生成函数、docs-link 写 parent、校验）另批落地，本节为行为契约。

**违规处理（写技能）**：能机械修复则修（库外/下层去链或纯 ID；跨层手写路径改为生成函数 HTTP，无 parent 则纯 ID）；目标层或实体不明则停，列清单交人。

**SSOT**：本节；OKF 段结构对齐见 [okf-spec.md](okf-spec.md) §4。
