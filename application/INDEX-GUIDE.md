---
type: Documentation
title: application INDEX-GUIDE
---
# application INDEX-GUIDE

> **最后更新**: 2026-10-05  
> **定位**: `application/` 九章索引指南。目录索引见 [index.md](index.md)。

---

## 一、项目概览

### 1.1 速查

* [README.md](README.md) — 人类入口（standalone → [README-s.md](README-s.md)；central → [README-c.md](README-c.md)）
* [index.md](index.md) — OKF 目录索引
* [DESIGN.md](DESIGN.md) — 本层设计入口（契约短表 + 治理引用）
* [knowledge/README.md](knowledge/README.md) — 五视角
* [CONTRIBUTING.md](CONTRIBUTING.md) — 贡献约定
* [changelogs/README.md](changelogs/README.md) — 变更/索引

### 1.2 元信息

* **角色**: 应用知识库；实现级实体（API/TBL/MW/CMP）SSOT + 五视角映射
* **栈**: Markdown、YAML
* **范围**: `knowledge/` · `analysis/` · `features/` · `requirements/` · `adr/` · `changelogs/`
* **规模**（本轮 full/d3，排除 `.agents`）：约 **62** 文件（`.md` 59 · `.yaml` 1 · `viz.html` 1）

---

## 二、架构视图

### 2.1 模块结构

```text
application/
├── README.md / DESIGN.md / INDEX-GUIDE.md / index.md / docs-meta.md
├── knowledge/（含 overview/） · analysis/ · features/ · requirements/ · adr/
└── changelogs/
```

### 2.2 依赖关系

* `knowledge/` 含 `overview/{NAME}-overview.md`（extract / archive）；上行 pull → distill（系统 overview）
* 上层公司/解决方案实体走 parent 链 reference，禁止直链槽位
* `analysis/` → `features/` → `requirements/`（mode=s）

### 2.3 包结构

不适用：本层为 Markdown/YAML 知识库，无应用包名 / FQCN 树（实现类名写在实体正文，非本索引展开）。

### 2.4 文档目录

入口：[knowledge/](knowledge/README.md) · [knowledge/overview/](knowledge/overview/README.md) · [analysis/](analysis/README.md) · [features/](features/README.md) · [requirements/](requirements/README.md) · [adr/](adr/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + 实体 `{ID}.md`。

### 3.1 服务接口

| 小节 | 状态 | 说明 |
|------|------|------|
| 3.1 服务接口 | 不适用 | 无 Dubbo/gRPC 运行时；接口形状 ∈ `API-*` 实体 |
| 3.2 HTTP 接口 | 不适用 | 无 REST 服务；人类读 Markdown / 本地 `viz.html` |
| 3.3 定时任务 | 不适用 | 无内嵌调度 |
| 3.4 消息队列 | 不适用 | 无 Topic/消费者 |

### 3.2 CLI / Slash 入口

| 入口 | 类型 | 路径/命令 | 说明 |
|------|------|-----------|------|
| `/docs-okf` | Slash | [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md) | 刷新本层 `index.md` / `viz.html` |
| `/docs-indexing` | Slash | [docs-indexing/SKILL.md](../agent/skills/docs-indexing/SKILL.md) | 九章骨架（须保留 entity-index） |
| `/docs-build` | Slash | [docs-build/SKILL.md](../agent/skills/docs-build/SKILL.md) | 刷新 §4.5 视角导航块 |
| `/docs-install` | Slash | [docs-install/SKILL.md](../agent/skills/docs-install/SKILL.md) | standalone / central 装机 |

---

## 四、领域模型

### 4.1 业务术语

不适用贴表：术语 SSOT ∈ [glossary.md](../agent/knowledge/glossary.md) / [knowledge-governance.md](../agent/knowledge/knowledge-governance.md)；本层只引不抄。

### 4.2 聚合根（知识组织）

| 聚合 | 职责 | 关键落点 |
|------|------|----------|
| 本层首次实体 | API / TBL / MW / CMP | [knowledge/](knowledge/README.md)；台账 ∈ 各视角 README |
| 上游引用 | 纯 ID 或 parent HTTP；PL∈公司，SLN/PD∈解决方案，SYS 链∈系统 | 不重复字段语义 |
| SDD | 分析 → 特性 → 需求（mode=s） | `analysis/` · `features/` · `requirements/` |

### 4.3 领域服务

不适用运行时服务：协作能力见根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §4.3 与本层 Skill 入口（§3.2 / §9.3）。

### 4.4 领域事件

不适用运行时事件：索引运行见 [changelogs/INDEXING-LOG.md](changelogs/INDEXING-LOG.md)。

### 4.5 视角导航

<!-- docs-build:entity-index:begin -->
> 本块由 `/docs-build` 写入；实体台账 ∈ 各视角 README；正文 ∈ per-entity `{ID}.md`；九章骨架 ∈ `/docs-indexing`。

> 本层仅登记 **API / TBL / MW / CMP**。PL 见公司；SLN/PD/BP/BSD(L2)/MDG/TSD 见解决方案；SYS 链见系统。

### 视角入口

- [知识库总说明](knowledge/README.md)
- [目录索引](knowledge/index.md)
- [业务](knowledge/business/README.md)
- [产品](knowledge/product/README.md)
- [应用](knowledge/application/README.md)
- [数据](knowledge/data/README.md)
- [技术](knowledge/technical/README.md)
<!-- docs-build:entity-index:end -->

---

## 五、业务逻辑

不适用运行时状态机 / 枚举。SDD / 本层首次实体样例：

| 路径 | 说明 |
|------|------|
| [analysis/ANALYSIS-EXAMPLE.md](analysis/ANALYSIS-EXAMPLE.md) | 分析样例 |
| [features/FEATURE-EXAMPLE.md](features/FEATURE-EXAMPLE.md) | 特性样例 |
| [analysis/](analysis/README.md) | 分析入口 |
| [features/](features/README.md) | 特性入口 |
| [requirements/REQUIREMENT-EXAMPLE/](requirements/REQUIREMENT-EXAMPLE/) | 需求样例目录 |
| [adr/](adr/README.md) | ADR |
| `knowledge/application/MS-EXAMPLE/API-EXAMPLE.md` | API SSOT 样例 |
| `knowledge/data/DS-EXAMPLE/TBL-EXAMPLE.md` | TBL 样例 |
| `knowledge/technical/MW-EXAMPLE/` · `CMP-EXAMPLE` | MW/CMP 样例 |

OpenAPI/DDL 全文不在九章展开（实体可链外部）。

---

## 六、数据映射

### 6.1 数据源

| 数据源 | 类型 | 用途 |
|--------|------|------|
| `{ID}.md` | Markdown + YAML | 应用实体 SSOT（含 API/TBL/MW/CMP） |
| `viz.html` | HTML | OKF 可视化 |
| `manifest.md` | Markdown | 应用清单 |

### 6.2 实体映射

不适用贴表：字段与 ID 链 SSOT ∈ 治理 / 各视角 README；本层首次样例见 §5。

### 6.3 关系映射

跨视角以 ID + 关系动词维护；入口 [knowledge/README.md](knowledge/README.md)。上游实体纯 ID → 其首次定义层（公司 / 解决方案 / 系统）。

### 6.4 SQL 索引

不适用真实 DDL：`TBL-*` 为字段形状样例，非库表建表脚本。

---

## 七、配置中心

### 7.1 配置项

不适用运行时配置中心键值表。装机相关：仓库根 [`.docsconfig`](../.docsconfig)；本层 [knowledge-links.yaml](knowledge-links.yaml)（现 `links: []`）；mode 入口 [README-s.md](README-s.md) · [README-c.md](README-c.md)。

### 7.2 环境差异（接入模式）

standalone / central 差异与安装约定见仓库根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §7.2 与 [docs-install/SKILL.md](../agent/skills/docs-install/SKILL.md)。本库 mode 入口：[README-s.md](README-s.md) · [README-c.md](README-c.md)。

### 7.3 敏感信息

不适用承载密钥：本层文档禁止写入真实凭证；样例用占位符。

---

## 八、索引边界

### 8.1 覆盖范围

本轮 **full / depth 3** 覆盖 `application/` 可读文本（约 62 文件）。九章已消减 `[未索引]`；实体台账仍以各视角 README 与 per-entity 为准。

### 8.2 排除列表

| 排除 | 原因 |
|------|------|
| `application/.agents/` | Agent 软链树，非知识正文 |
| `.git/` · IDE · `node_modules/` | 常规 |
| `viz.html` 内嵌快照 | 生成物；源以 Markdown 为准 |

### 8.3 维护规则

* [changelogs/](changelogs/README.md)：`INDEXING-LOG.md`；溯源 git  
* 大目录或契约变更后跑 `/docs-indexing`；索引后按需 `/docs-okf`

---

## 九、扩展资源

### 9.1 核心文档

| 文档 | 路径 | 描述 |
|------|------|------|
| 本层九章 | [INDEX-GUIDE.md](INDEX-GUIDE.md) | 本文 |
| 目录索引 | [index.md](index.md) | OKF 渐进披露 |
| 设计入口 | [DESIGN.md](DESIGN.md) | 契约与门禁 |
| OKF 可视化 | [viz.html](viz.html) | 图视图 |
| 应用清单 | [manifest.md](manifest.md) | 清单 |
| 系统对照 | [../system/INDEX-GUIDE.md](../system/INDEX-GUIDE.md) | 上层九章 |

### 9.2 相关项目

| 关系 | 状态 |
|------|------|
| 本层 `knowledge-links.yaml` | **空**（`links: []`；可挂 `type: parent` → system） |
| 联邦槽位 | **无**本层槽位目录；登记在公司/系统 `knowledge-links.yaml` |
| 同仓邻层 | [system/](../system/README.md) · [company/](../company/README.md) |

### 9.3 工具链

| 工具 | 说明 |
|------|------|
| `/docs-okf` | [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md) |
| `/docs-indexing` | 九章骨架（须保留 entity-index 标记块） |
| `/docs-build` | 刷新 §4.5 标记块 |
