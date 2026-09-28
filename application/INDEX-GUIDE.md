---
type: Documentation
title: application INDEX-GUIDE
---
# application INDEX-GUIDE

> **最后更新**: 2026-09-28  
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
* **范围**: `knowledge/` · `solutions/` · `analysis/` · `requirements/` · `adr/` · `changelogs/`

---

## 二、架构视图

### 2.1 模块结构

```text
application/
├── README.md / DESIGN.md / INDEX-GUIDE.md / index.md / docs-meta.md
├── knowledge/ · solutions/ · analysis/ · requirements/ · adr/
└── changelogs/
```

### 2.2 依赖关系

* `knowledge/` ↔ `system/knowledge/`：系统 SSOT / 本层实现映射；上行 pull → distill（系统 overview）
* `knowledge/` ↔ `company/knowledge/`：公司实体 reference
* `solutions/` → `analysis/` → `requirements/`（mode=s）

### 2.3 包结构

[未索引] 本层为 Markdown/YAML 知识库，无应用包名树。

### 2.4 文档目录

入口：[knowledge/](knowledge/README.md) · [solutions/](solutions/README.md) · [analysis/](analysis/README.md) · [requirements/](requirements/README.md) · [adr/](adr/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + 实体 `{ID}.md`。

### 3.1 服务接口

| 小节 | 状态 | 说明 |
|------|------|------|
| 3.1 服务接口 | [未索引] | 无 Dubbo/gRPC |
| 3.2 HTTP 接口 | [未索引] | 无 REST |
| 3.3 定时任务 | [未索引] | 无内嵌调度 |
| 3.4 消息队列 | [未索引] | 无 Topic/消费者 |

### 3.2 CLI / Slash 入口

| 入口 | 类型 | 路径/命令 | 说明 |
|------|------|-----------|------|
| `/docs-okf` | Slash | [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md) | 刷新本层 `index.md` / `viz.html` |
| `/docs-build` · `/docs-indexing` | Slash | 见 [agent/skills/README.md](../agent/skills/README.md) | 实体与九章 |

---

## 四、领域模型

### 4.1 业务术语

[未索引] 术语 SSOT ∈ [glossary.md](../agent/knowledge/glossary.md) / [knowledge-governance.md](../agent/knowledge/knowledge-governance.md)；本层不重复表。

### 4.2 聚合根（知识组织）

| 聚合 | 职责 | 关键落点 |
|------|------|----------|
| 本层首次实体 | API / TBL / MW / CMP | [knowledge/](knowledge/README.md)；台账 ∈ 各视角 README |
| 上游引用 | BD/SYS/MDG/TSD 等纯 ID；PL/SLN∈公司，PD/PM∈系统 | 不落 reference 文件 |
| SDD | 方案 → 分析 → 需求（mode=s） | `solutions/` · `analysis/` · `requirements/` |

### 4.3 领域服务

[未索引] 无运行时领域服务；协作能力见根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §4.3 与本层 Skill 入口（§3.2 / §9.3）。

### 4.4 领域事件

[未索引] 无运行时领域事件；索引运行见 [changelogs/INDEXING-LOG.md](changelogs/INDEXING-LOG.md)。

### 4.5 视角导航

<!-- docs-build:entity-index:begin -->
> 本块由 `/docs-build` 写入；实体台账 ∈ 各视角 README；正文 ∈ per-entity `{ID}.md`；九章骨架 ∈ `/docs-indexing`。

> 本层仅登记本层首次定义样例（API/TBL/MW/CMP）。上游 BD/SYS/MDG/TSD 等以纯 ID 引用公司/系统 SSOT，本层不落 reference 文件。产品 **PL/SLN** 见公司；**PD/PM** 见系统层。

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

[未索引] 本层无运行时状态机 / 枚举实现；SDD 正文 ∈ `solutions/` · `analysis/` · `requirements/`，不在此展开。API/TBL 实体在 `knowledge/`，不承载运行时 OpenAPI/DDL 全文（可链外部）。

---

## 六、数据映射

### 6.1 数据源

| 数据源 | 类型 | 用途 |
|--------|------|------|
| `{ID}.md` | Markdown + YAML | 应用实体 SSOT（含 API/TBL/MW/CMP） |
| `viz.html` | HTML | OKF 可视化 |
| `manifest.md` | Markdown | 应用清单 |

### 6.2 实体映射

[未索引] 字段与 ID 链 SSOT ∈ 治理 / 各视角 README；不在此贴表。

### 6.3 关系映射

[未索引] 跨视角以 ID / YAML 字段维护；见 [knowledge/README.md](knowledge/README.md)。

### 6.4 SQL 索引

[未索引] 无 RDBMS 表结构；`TBL-*` 为字段形状样例，非真实 DDL。

---

## 七、配置中心

### 7.1 配置项

[未索引] 无运行时配置中心键值表。

### 7.2 环境差异（接入模式）

standalone / central 差异与安装约定见仓库根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §7.2 与 [docs-install/SKILL.md](../agent/skills/docs-install/SKILL.md)。本库 mode 入口：[README-s.md](README-s.md) · [README-c.md](README-c.md)。

### 7.3 敏感信息

[未索引] 本层文档不承载密钥；勿写入真实凭证。

---

## 八、索引边界

### 8.1 覆盖范围

[未索引] 本轮为结构对齐薄版，未做全量文件枚举；范围见 §1.2。

### 8.2 排除列表

[未索引] 未单列排除模式；生成物以对应 README 与 git 为准。

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

[未索引] 联邦登记在系统/公司 `knowledge-links.yaml`；本层无槽位目录。

### 9.3 工具链

| 工具 | 说明 |
|------|------|
| `/docs-okf` | [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md) |
| `/docs-indexing` | 九章骨架（须保留 entity-index 标记块） |
| `/docs-build` | 刷新 §4.5 标记块（契约文案仍称「第五章」，另开对齐） |
