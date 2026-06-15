# 公司知识库设计

本文件定义 `company/` 的设计边界、目录契约、同步闭环与演进策略。  
`company/` 负责公司层知识编排与系统槽位治理，不承载下游系统实现细节。

---

## 阅读顺序

1. [README.md](README.md) — 公司知识库定位与目录说明
2. 本文 — 设计边界、治理规则与流程约束
3. [ea/README.md](ea/README.md) — 企业架构视图入口
4. [system-SYSNAME/README.md](system-SYSNAME/README.md) — 系统槽位模板说明
5. [../system/DESIGN.md](../system/DESIGN.md) — 系统知识库设计（下游对齐参考）

---

## 1. 定位与边界

`company/DESIGN.md` 的定位是公司知识库设计说明，核心职责是定义公司层治理语义、系统槽位编排规则与同步入口约束。

- `company/` 承载公司层聚合视图与导航；
- `system/` 承载系统层治理与架构聚合；
- `application/` 仍是实体事实源与字段语义的 SSOT。

边界约束：

- **治理边界**：`company/` 负责公司层结构语义、导航与归档入口；
- **内容边界**：系统实现细节留在 `system/`，应用实体细节留在 `application/`；架构层只保留企业架构顶层视图，不承载各视角的实现细节文件；
- **流程边界**：`company/` 承载跨系统方案（`solutions/`）与需求分析（`analysis/`）；PRD/ASD/DSD/TDD 等交付物由各系统侧 `requirements/` 承接，不在 `company/` 层定义；
- **引用边界**：优先路径引用与槽位映射，避免跨层复制正文。

---

## 2. 目录契约与治理规则

`company/` 采用「企业架构层 + 系统槽位层 + 建联清单」的轻量契约模型。

| 层级 | 目录 | 职责 |
| --- | --- | --- |
| 企业架构层 | `ea/` | 承载公司级企业架构顶层视图（五视角，聚焦治理叙事，不含实现细节）；含 [`ea/overview/`](ea/overview/NAME-overview.md) 缓冲区（docs-tag / docs-archive 操作对象） |
| 方案层 | `solutions/` | 公司级跨系统解决方案；明确「哪个系统负责提供什么功能」，作为 `analysis/` 上游输入 |
| 分析层 | `analysis/` | 公司级跨系统需求分析；衔接 `solutions/`，输出由各系统侧 `requirements/` 承接 |
| 槽位层 | `system-{name}/` | 挂载系统镜像内容的统一入口 |
| 清单层 | `knowledge-links.yaml` | 记录建联关系与同步编排信息 |

#### 公司级实体

下列实体在 **company/** 首次定义；系统层、应用层仅引用 ID，不重复字段语义（完整表见 [application/DESIGN.md](../application/DESIGN.md) §2.2.1）。

| 视角 | 实体 | 说明 |
| --- | --- | --- |
| 业务 | BD（业务域） | 公司级业务划分 |
| 业务 | CAP（业务能力） | 公司级能力目录（L1/L2/L3） |
| 产品 | PL（产品线） | 跨系统产品族 |
| 应用 | SYS（系统层） | 公司内系统边界 |
| 数据 | MDG（主数据域） | 公司级主数据治理目录 |
| 技术 | TPL（技术平台能力） | 公司级平台能力目录（云/DevOps/安全/开发环境） |

命名细则见 [agent/knowledge/naming-conventions.md](../agent/knowledge/naming-conventions.md)。

#### 系统镜像槽位与上行

`system-{name}/` 承接下游系统知识库的镜像同步结果，供公司层导航与跨系统治理；不承载系统实现细节。上行提炼与 overview/archive 流程见 [system/DESIGN.md](../system/DESIGN.md)（docs-pull、docs-distill、docs-archive）。

治理规则：

- **命名规则**：系统槽位统一 `system-{SYSTEM_NAME}`；
- **职责规则**：`company/` 不承载系统实现细节与应用字段定义；
- **引用规则**：跨层内容使用链接引用，不复制下游正文；
- **变更规则**：新增槽位或调整目录语义时，先更新本文件约束再更新内容。

---

## 3. 同步流程与追溯闭环

`company/` 的流程定位是“公司层编排入口”，流程保持轻量但可审计。

1. **系统侧准备**：下游 `system/` 侧完成可同步内容整理；
2. **公司侧挂载**：通过 fetch 将内容同步到 `company/system-{name}/` 槽位；
3. **治理校核**：在 `company/ea/` 与 `knowledge-links.yaml` 维护一致性；
4. **追溯记录**：对新增、替换、退役槽位记录来源、影响范围与状态。

闭环原则：

- `company/` 负责可见性、可治理性、可追溯性；
- `company/` 不重写下游内容，只维护公司层映射与入口；
- 出现冲突时以下游事实源为准，`company/` 修复映射与导航。

---

## 4. 质量门禁与演进策略

质量门禁采用“轻规则、强一致性”：

- **命名门禁**：槽位目录命名统一，禁止同义目录并存；
- **边界门禁**：`company/` 文档不引入系统实现与应用字段细节；
- **引用门禁**：跨层描述必须可追溯至 `system/` 或 `application/`；
- **变更门禁**：槽位变更先更新设计约束，再更新目录与链接清单。

演进顺序：

1. 稳定目录契约与槽位命名；
2. 完善 `knowledge-links.yaml` 的来源、状态与更新时间信息；
3. 增补自动化巡检（命名一致性、链接可达性、槽位完整性）。

---

## 参考

- [README.md](README.md)
- [ea/README.md](ea/README.md)
- [system-SYSNAME/README.md](system-SYSNAME/README.md)
- [knowledge-links.yaml](knowledge-links.yaml)
- [../system/DESIGN.md](../system/DESIGN.md)
