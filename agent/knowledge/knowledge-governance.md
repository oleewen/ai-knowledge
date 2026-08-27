# 知识库治理规则

本文件只定义 **三层知识库职责边界** 与 **业务 knowledge 引用边界**。组件索引、使用顺序见同目录 [README.md](README.md)。

协作闸门与编码规范见 [CONVENTIONS.md](../rules/CONVENTIONS.md)。路径/overview/流水线见 [knowledge-layout.md](../references/knowledge-layout.md)。

## 使命

决策 **透明、一致、可追溯**，避免架构随口语漂移。

## 三层职责边界

| 层级 | 目录 | 治理职责 | 实体 SSOT |
| --- | --- | --- | --- |
| 公司 | `company/` | 公司级 EA 叙事、跨系统方案与分析、系统槽位 | BD、PL、SYS、CAP、MDG、TPL（公司级目录实体） |
| 系统 | `system/` | 系统级架构聚合、应用镜像槽位、蒸馏归档 | BSD、PM、APP、DS、TSD 等（见各层 DESIGN §2.2.1） |
| 应用 | `application/` | 五视角实体事实源、SDD 阶段交付 | BC、AGG、AB、FT、UC、MS、API、ENT、MW、CMP 等 |

**命名、术语与 OKF 文件分型**：统一以 `agent/knowledge/` 为准（见 [README.md](README.md)）；`system/` / `company/` 维护本层目录语义与映射。

## 业务 knowledge 引用边界

**适用范围**：仅 `application|system|company` 下 `*/knowledge/**`（含 overview、视角章、per-entity、meta、README）。**不含** `agent/knowledge/**`（Agent 元知识可链规则与布局文档）。

**层级方向**（高 → 低）：`company` > `system` > `application`。

| 允许 | 禁止 |
| --- | --- |
| 同层 `…/knowledge/**` 内互引（bundle-relative） | 引同层 knowledge **外**（`adr/`、`solutions/`、`analysis/`、`requirements/`、`DESIGN.md`、`INDEX-GUIDE.md`、根 `index.md`、`agent/**` 等） |
| 指向上层 knowledge 实体：正文写 **实体 ID / `full_id`** | 手写 `../` 爬层跨 `DOC_DIR` 文件路径 |
| 同仓跨层解析：经本层或上层登记的 `knowledge-links.yaml` 定位 `DOC_DIR`，再解析 ID→路径（技能/校验侧） | 引下层 knowledge（含联邦槽位语义下层：`system/application-*`、`company/system-*`） |
| `resource` / 依据段：外部 **URI、表名、API 名、仓名**（非文档相对路径） | Markdown 链或路径字面量指向库外 **文档文件** |

**读写分离**：技能可读 knowledge 外源（solutions、槽位等）；**落盘进** `*/knowledge/**` 的正文、链接、路径字面量、frontmatter 外指须满足上表。

**overview / 表行**：需提及 ADR 等库外对象时，**留字去链**（纯文本），不链 `adr/` 等。

**违规处理（写技能）**：能机械修复则修（去链、跨层路径→纯 ID、下层路径→纯 ID）；目标层或实体不明则停，列清单交人。

**SSOT**：本节；OKF 依据段对齐见 [okf-spec.md](okf-spec.md) §4。

## 设计入口

- [application/DESIGN.md](../../application/DESIGN.md)
- [system/DESIGN.md](../../system/DESIGN.md)
- [company/DESIGN.md](../../company/DESIGN.md)
