---
type: Documentation
title: system INDEX-GUIDE
---
# system INDEX-GUIDE

> **最后更新**: 2026-07-18  
> **定位**: `system/` 九章索引指南。目录索引见 [index.md](index.md)。

---

## 一、项目概览

### 1.1 速查

* [README.md](README.md) — 人类入口  
* [index.md](index.md) — OKF 目录索引  
* [DESIGN.md](DESIGN.md) — 本层设计入口（契约短表 + 治理引用）  
* [knowledge/README.md](knowledge/README.md) — 五视角  
* [knowledge-links.yaml](knowledge-links.yaml) — 建联清单  
* [changelogs/README.md](changelogs/README.md) — 变更/索引  

### 1.2 元信息

* **角色**: 系统知识库；`knowledge/` = 系统层实体 SSOT + 五视角；`application-slots/application-{NAME}` = 软链槽位  
* **栈**: Markdown、YAML  
* **范围**: `knowledge/` · `solutions/` · `analysis/` · `requirements/` · `application-slots/` · `adr/` · `changelogs/`  

---

## 二、架构视图

```text
system/
├── README.md / DESIGN.md / INDEX-GUIDE.md / index.md / docs-meta.md
├── knowledge-links.yaml
├── knowledge/ · solutions/ · analysis/ · requirements/ · adr/
├── application-slots/
│   ├── application-{NAME}      # 软链 → 应用 DOC_ROOT
│   └── changelogs/             # 层共用 ARCHIVE-LOG；同步追溯 git / SYNC_OK
└── changelogs/
```

入口：[knowledge/](knowledge/README.md) · [solutions/](solutions/README.md) · [analysis/](analysis/README.md) · [requirements/](requirements/README.md) · [application-slots/](application-slots/README.md)

---

## 三、接口清单

无运行时 API。契约 = 目录 + Markdown + `knowledge-links.yaml`。

---

## 四、模块依赖

* `knowledge/` ↔ `company/knowledge/`：公司实体 reference  
* `knowledge/` ↔ `application/knowledge/`：系统 SSOT / 应用实现映射  
* `solutions/` → `analysis/` → `requirements/`  
* `knowledge-links.yaml` → `application-slots/application-{NAME}/`  

---

## 五、详细索引

<!-- docs-build:entity-index:begin -->
> 扫描生成；非 SSOT。实体正文 ∈ 各视角 per-entity `{ID}.md`。九章骨架由 `/docs-indexing` 维护；本块由 `/docs-build` 写入。

### 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为完整实体 ID（如 `VC-EXAMPLE`）；`别名（英文名）` 为英文编码；`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

### §1 业务视角（business · BSD(L1) → BSD(L2) → BC → AGG → AB）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| BSD | BSD-EXAMPLE |  | 示例一级业务子域 | `business/BSD-EXAMPLE/BSD-EXAMPLE.md` |
| BSD | BSD-EXAMPLE-SUB |  | 示例二级业务子域 | `business/BSD-EXAMPLE/BSD-EXAMPLE-SUB/BSD-EXAMPLE-SUB.md` |
| BC | BC-EXAMPLE |  | 示例限界上下文 | `business/BSD-EXAMPLE/BSD-EXAMPLE-SUB/BC-EXAMPLE/BC-EXAMPLE.md` |
| AGG | AGG-EXAMPLE |  | 示例聚合 | `business/BSD-EXAMPLE/BSD-EXAMPLE-SUB/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md` |
| AB | AB-EXAMPLE |  | 示例能力 | `business/BSD-EXAMPLE/BSD-EXAMPLE-SUB/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md` |

### §2 产品视角（product · PD → PM → FT → FR → UC/BR · BP）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| PD | PD-EXAMPLE |  | 示例产品服务 | `product/PD-EXAMPLE/PD-EXAMPLE.md` |
| PM | PM-EXAMPLE |  | 示例产品模块 | `product/PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md` |
| FT | FT-EXAMPLE |  | 示例功能 | `product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md` |
| FR | FR-EXAMPLE |  | 示例功能需求 | `product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md` |
| UC | UC-EXAMPLE |  | 示例用例 | `product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md` |
| BR | BR-EXAMPLE |  | 示例规则 | `product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md` |
| BP | BP-EXAMPLE |  | 示例业务流程（BP） | `product/BP-EXAMPLE.md` |

### §3 应用视角（application · SYS → APP → MS）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| SYS | SYS-EXAMPLE |  | 示例系统 | `application/SYS-EXAMPLE.md` |
| APP | APP-EXAMPLE |  | 示例应用 | `application/APP-EXAMPLE/APP-EXAMPLE.md` |
| MS | MS-EXAMPLE |  | 示例微服务 | `application/APP-EXAMPLE/MS-EXAMPLE/MS-EXAMPLE.md` |

### §4 数据视角（data · MDG → DS → ENT）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| MDG | MDG-EXAMPLE |  | 示例主数据域 | `data/MDG-EXAMPLE.md` |
| DS | DS-EXAMPLE |  | 示例数据源 | `data/DS-EXAMPLE/DS-EXAMPLE.md` |
| ENT | ENT-EXAMPLE |  | 示例实体 | `data/DS-EXAMPLE/ENT-EXAMPLE.md` |

### §5 技术视角（technical · TSD → MW）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| TSD | TSD-EXAMPLE |  | 中间件域 | `technical/TSD-EXAMPLE.md` |

> 公司级 **TPL-*** / **SLN-*** / **PL-*** 不在本索引登记。本层 **BSD(L2) / PD / SYS / MDG** 首次定义；产品自 **PD** 起；应用自 **SYS** 起。

---

### 物化目录映射（示例）

| 索引 ID | 命名式 ID（锚点目录） |
|---------|----------------------|
| BSD-EXAMPLE | `business/BSD-EXAMPLE/BSD-EXAMPLE.md`（一级 reference） |
| BSD-EXAMPLE-SUB | `business/BSD-EXAMPLE/BSD-EXAMPLE-SUB/BSD-EXAMPLE-SUB.md` |
| PD-EXAMPLE | `product/PD-EXAMPLE/` |
| PM-EXAMPLE | `product/PD-EXAMPLE/PM-EXAMPLE/` |
| SYS-EXAMPLE | `application/SYS-EXAMPLE.md` |
| APP-EXAMPLE | `application/APP-EXAMPLE/` |
| MDG-EXAMPLE | `data/MDG-EXAMPLE.md` |
| DS-EXAMPLE | `data/DS-EXAMPLE/` |
| TSD-EXAMPLE | `technical/TSD-EXAMPLE.md` |

---

### 交叉引用

- 目录索引：`knowledge/index.md`
- 应用：`knowledge/application/`
- 业务：`knowledge/business/`
- 产品：`knowledge/product/`
- 数据：`knowledge/data/`
- 技术：`knowledge/technical/`
- 知识库总说明：`knowledge/README.md`
<!-- docs-build:entity-index:end -->

## 六、API / 字典边界

不承载运行时 API。overview：[knowledge/overview/](knowledge/overview/README.md)

---

## 七、变更与运维

[changelogs/](changelogs/README.md)：`INDEXING-LOG.md`；变更溯源 `git log` / `git diff`；槽位蒸馏日志在 `application-slots/changelogs/ARCHIVE-LOG.md`

---

## 八、技能与脚本

* `/docs-okf` — 刷新 `index.md` / `viz.html`  
* `/docs-distill` · `/docs-archive` — overview 上行  
* `/docs-pull` — 填充 `application-slots/application-{NAME}/`  
* [docs-okf/SKILL.md](../agent/skills/docs-okf/SKILL.md)  

---

## 九、附录

[viz.html](viz.html) · 索引记录 [INDEXING-LOG.md](changelogs/INDEXING-LOG.md) · 公司对照 [../company/INDEX-GUIDE.md](../company/INDEX-GUIDE.md)
