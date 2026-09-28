---
type: Documentation
title: company INDEX-GUIDE
---
# company INDEX-GUIDE

> **最后更新**: 2026-09-28  
> **定位**: `company/` 九章索引指南。目录索引：[index.md](index.md)。契约见 [DESIGN.md](DESIGN.md)。

---

## 一、项目概览

### 1.1 速查

* [README.md](README.md) — 人类入口  
* [index.md](index.md) — OKF 目录索引  
* [DESIGN.md](DESIGN.md) — 本层设计入口  
* [knowledge/README.md](knowledge/README.md) — 五视角  
* [knowledge-links.yaml](knowledge-links.yaml) — 建联清单  
* [changelogs/README.md](changelogs/README.md) — 变更/索引  

### 1.2 元信息

* **角色**: 公司知识库；`knowledge/` = VC/BD/BSD(L1)/CAP/PL/SLN/TPL SSOT（无 BSD(L2)/PD/SYS/MDG）；`system-slots/system-{NAME}` = 联邦槽位（软链）  
* **栈**: Markdown、YAML  
* **范围**: `knowledge/` · `solutions/` · `analysis/` · `adr/` · `system-slots/` · `changelogs/`  

---

## 二、架构视图

### 2.1 模块结构

```text
company/
├── README.md / DESIGN.md / INDEX-GUIDE.md / index.md / docs-meta.md
├── knowledge-links.yaml
├── knowledge/ · solutions/ · analysis/ · adr/
├── system-slots/
│   ├── system-{NAME}           # 软链 → 系统 DOC_ROOT
│   └── changelogs/             # ARCHIVE-LOG；同步追溯 git / SYNC_OK
└── changelogs/
```

### 2.2 依赖关系

* `knowledge/` ↔ `system/knowledge/`：公司实体参照  
* `solutions/` → `analysis/` → 各系统 `requirements/`  
* `knowledge-links.yaml` → `system-slots/system-{NAME}/`  

门禁与同步：[DESIGN.md](DESIGN.md) § 同步与门禁。

### 2.3 包结构

[未索引] 本层为 Markdown/YAML 知识库，无应用包名树。

### 2.4 文档目录

入口：[knowledge/](knowledge/README.md) · [solutions/](solutions/README.md) · [analysis/](analysis/README.md) · [adr/](adr/README.md) · [system-slots/](system-slots/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + `knowledge-links.yaml`（细则 [DESIGN.md](DESIGN.md)）。

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

---

## 四、领域模型

### 4.1 业务术语

[未索引] 术语 SSOT ∈ [glossary.md](../agent/knowledge/glossary.md) / [knowledge-governance.md](../agent/knowledge/knowledge-governance.md)；本层不重复表。

### 4.2 聚合根（知识组织）

| 聚合 | 职责 | 关键落点 |
|------|------|----------|
| 公司级实体 | VC / BD / BSD(L1) / CAP / PL / SLN / TPL | [knowledge/](knowledge/README.md)；台账 ∈ 各视角 README |
| overview 缓冲 | distill / extract / archive / tag | [knowledge/overview/](knowledge/overview/README.md) |
| SDD 上游 | 跨系统方案与分析 | `solutions/` · `analysis/`（无 `requirements/`） |
| 联邦槽位 | 系统 DOC_ROOT 软链 | `system-slots/system-{NAME}/` · [knowledge-links.yaml](knowledge-links.yaml) |

### 4.3 领域服务

[未索引] 无运行时领域服务；协作能力见根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §4.3 与本层 Skill 入口（§3.2 / §9.3）。

### 4.4 领域事件

[未索引] 无运行时领域事件；索引运行见 [changelogs/INDEXING-LOG.md](changelogs/INDEXING-LOG.md)。

### 4.5 视角导航

<!-- docs-build:entity-index:begin -->
> 本块由 `/docs-build` 写入；实体台账 ∈ 各视角 README；正文 ∈ per-entity `{ID}.md`；九章骨架 ∈ `/docs-indexing`。

> 本层登记公司级 **VC / BD / BSD(L1) / CAP / PL / SLN / TPL**。

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

[未索引] 本层无运行时状态机 / 枚举实现；SDD 上游正文 ∈ `solutions/` · `analysis/`，不在此展开。

---

## 六、数据映射

### 6.1 数据源

| 数据源 | 类型 | 用途 |
|--------|------|------|
| `{ID}.md` | Markdown + YAML | 公司实体 SSOT |
| `knowledge/overview/` | Markdown | overview 缓冲；入口 [overview/README.md](knowledge/overview/README.md) |
| `knowledge-links.yaml` | YAML | 联邦建联 |
| `viz.html` | HTML | OKF 可视化 |

### 6.2 实体映射

[未索引] 字段与 ID 链 SSOT ∈ 治理 / 各视角 README；不在此贴表。

### 6.3 关系映射

[未索引] 跨视角以 ID / YAML 字段维护；见 [knowledge/README.md](knowledge/README.md)。

### 6.4 SQL 索引

[未索引] 无 RDBMS 表结构。

---

## 七、配置中心

[未索引] 本层无运行时配置中心；装机与 `.docsconfig` 见仓库根与 `/docs-install`。

---

## 八、索引边界

### 8.1 覆盖范围

[未索引] 本轮为结构对齐薄版，未做全量文件枚举；范围见 §1.2。

### 8.2 排除列表

[未索引] 未单列排除模式；生成物 / 槽位内容以对应 README 与 git 为准。

### 8.3 维护规则

* [changelogs/](changelogs/README.md)：`INDEXING-LOG`；溯源 git  
* 槽位日志 ∈ `system-slots/changelogs/ARCHIVE-LOG.md`  
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
| 索引运行日志 | [INDEXING-LOG.md](changelogs/INDEXING-LOG.md) | docs-indexing 基线 |

### 9.2 相关项目

[未索引] 上下游系统仓由 `knowledge-links.yaml` / `system-slots/` 登记；当前以槽位为准。

### 9.3 工具链

| 工具 | 说明 |
|------|------|
| `/docs-okf` | [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md) |
| `/docs-indexing` | 九章骨架（须保留 entity-index 标记块） |
| `/docs-build` | 刷新 §4.5 标记块（契约文案仍称「第五章」，另开对齐） |
